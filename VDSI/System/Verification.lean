import VDSI.System.Execution
import VDSI.System.Spec
import VDSI.Node.Verification

namespace VDSI.System

private def SavedIdsPreserved (σ σ' : State n) : Prop :=
  ∀ i, ParticipantIdsIncluded (σ.nodes i).saved.participants (σ'.nodes i).saved.participants

private theorem commit_preserves_local_state (i : Fin n) (before : LocalState)
    (incoming : List Participant) (saved : Bool) (consistent : LocalStateSpec i before) :
    LocalStateSpec i (before.commit incoming saved) ∧
    ∀ id, IdIsRegistered id before.saved.participants →
      IdIsRegistered id (before.commit incoming saved).saved.participants := by
  cases memory : before.memory with
  | none => simp [LocalState.commit, memory]; exact consistent
  | some ν =>
      have localMatchesDisk := consistent ν memory
      cases saved with
      | false => simp [LocalState.commit, memory]; exact consistent
      | true =>
          have mergeMeetsSpec := Node.mergeRegistry_satisfies_spec ν incoming
          have existingIdsRetained : ν ⊑ ν.mergeRegistry incoming :=
            fun id wasRegistered => (mergeMeetsSpec.2 id).mpr (Or.inl wasRegistered)
          simp only [LocalState.commit, memory, ↓reduceIte]
          constructor
          · intro ν' result
            cases result
            exact ⟨mergeMeetsSpec.1.trans localMatchesDisk.1, rfl⟩
          · intro id wasSaved
            exact existingIdsRetained id (localMatchesDisk.2 ▸ wasSaved)

private theorem update_preserves_state (σ : State n) (i : Fin n) (replacement : LocalState)
    (consistent : Consistent σ) (replacementConsistent : LocalStateSpec i replacement)
    (retained : ∀ id, IdIsRegistered id (σ.nodes i).saved.participants →
      IdIsRegistered id replacement.saved.participants) :
    Consistent (σ.update i replacement) ∧ SavedIdsPreserved σ (σ.update i replacement) := by
  constructor
  · intro j
    by_cases sameNode : j = i
    · subst j; simpa [State.update] using replacementConsistent
    · simpa [State.update, sameNode] using consistent j
  · intro j id wasSaved
    by_cases sameNode : j = i
    · subst j; simpa [State.update] using retained id wasSaved
    · simpa [State.update, sameNode] using wasSaved

private theorem step_preserves_state (σ σ' : State n) (α : Action n)
    (consistent : Consistent σ) (transition : σ ⟶[α] σ') :
    Consistent σ' ∧ SavedIdsPreserved σ σ' := by
  subst σ'
  have unchanged : Consistent σ ∧ SavedIdsPreserved σ σ := ⟨consistent, fun _ _ h => h⟩
  cases α with
  | register i π saved =>
      obtain ⟨localConsistent, retained⟩ :=
        commit_preserves_local_state i _ [π] saved (consistent i)
      exact update_preserves_state σ i _ consistent localConsistent retained
  | send source recipient =>
      simp only [step]
      split <;> exact unchanged
  | deliver messageIndex saved =>
      simp only [step]
      split
      · exact unchanged
      · rename_i message found
        obtain ⟨localConsistent, retained⟩ :=
          commit_preserves_local_state message.recipient _ message.participants saved (consistent _)
        exact update_preserves_state σ message.recipient _ consistent localConsistent retained
  | drop messageIndex => exact unchanged
  | duplicate messageIndex =>
      simp only [step]
      split <;> exact unchanged
  | stop i =>
      apply update_preserves_state σ i _ consistent
      · intro ν impossible; cases impossible
      · exact fun _ h => h
  | restart i readSucceeded =>
      cases readSucceeded with
      | false => exact unchanged
      | true =>
          apply update_preserves_state σ i _ consistent
          · intro ν restored
            have restoreMeetsSpec := Node.restoreRegistry_satisfies_spec
              { value := i.val } (σ.nodes i).saved.participants
            change Node.restoreRegistry _ _ = some ν at restored
            rw [restored] at restoreMeetsSpec
            exact restoreMeetsSpec
          · exact fun _ h => h

private theorem execute_preserves_state (σ : State n) (τ : List (Action n))
    (consistent : Consistent σ) :
    Consistent (ℰ τ σ) ∧ SavedIdsPreserved σ (ℰ τ σ) := by
  induction τ generalizing σ with
  | nil => exact ⟨consistent, fun _ _ h => h⟩
  | cons α remaining remainingPreserves =>
      obtain ⟨nextConsistent, savedInNext⟩ := step_preserves_state σ _ α consistent rfl
      obtain ⟨finalConsistent, savedInFinal⟩ := remainingPreserves (step σ α) nextConsistent
      exact ⟨finalConsistent, fun i id wasSaved => savedInFinal i id (savedInNext i id wasSaved)⟩

/-- For any finite number of nodes and any schedule, previously saved IDs survive
all modeled operations and remain locally queryable when online. Every prefix
also satisfies this result. Storage integrity, one writer per node, and atomic
save-and-publish are model assumptions; TCP/IO conformance is not proved here. -/
theorem execution_preserves_safety (σ σ' : State n) (τ : List (Action n))
    (consistent : Consistent σ) (execution : ℰ τ σ = σ') :
    SafetySpec σ σ' := by
  subst σ'
  obtain ⟨finalConsistent, retained⟩ := execute_preserves_state σ τ consistent
  refine ⟨finalConsistent, fun i => ((ℰ τ σ).nodes i).saved.idsAreUnique, ?_⟩
  intro i id wasSaved
  have stillSaved := retained i id wasSaved
  refine ⟨stillSaved, ?_⟩
  intro ν online
  have localMatchesDisk := (finalConsistent i ν online).2
  have presentLocally : IdIsRegistered id ν.registry.participants := localMatchesDisk ▸ stillSaved
  obtain ⟨π, member, matchingId⟩ := List.mem_map.mp presentLocally
  exact ⟨π, (findParticipant_returns_iff_present_with_matching_id
    ν.registry.participants id π ν.registry.idsAreUnique).mpr ⟨member, matchingId⟩,
    matchingId⟩

/-- Once an online node completes a registration and its save succeeds, that ID
remains saved through every subsequent schedule, including stops and restarts.
Whenever that node is online, its real registry lookup can find the participant. -/
theorem confirmed_registration_survives_execution
    (σ : State n) (i : Fin n) (π : Participant)
    (ν : Node) (online : (σ.nodes i).memory = some ν)
    (consistent : Consistent σ) (τ : List (Action n)) :
    SavedAndQueryable (ℰ τ (step σ (.register i π true))) i π.id := by
  have afterRegistrationConsistent :=
    (step_preserves_state σ _ (.register i π true) consistent rfl).1
  have savedAfterRegistration : IdIsRegistered π.id
      ((step σ (.register i π true)).nodes i).saved.participants := by
    simp only [step, State.update, ↓reduceIte, LocalState.commit, online]
    apply ((Node.mergeRegistry_satisfies_spec ν [π]).2 π.id).mpr
    exact Or.inr (by simp [IdIsRegistered])
  exact (execution_preserves_safety _ _ τ afterRegistrationConsistent rfl).2.2
    i π.id savedAfterRegistration

end VDSI.System
