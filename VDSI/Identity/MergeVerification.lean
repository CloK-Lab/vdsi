import VDSI.Identity.Merge
import VDSI.Identity.Verification

namespace VDSI.Identity

theorem mergeRegistry_success (network : String) (verify : Verifier)
    (localRecords incoming result : Registry)
    (accepted : mergeRegistry network verify localRecords incoming = some result) :
    result = combineRecords localRecords incoming ∧ RegistryInvariant network verify result := by
  unfold mergeRegistry at accepted
  cases hlocal : restoreRegistry network verify localRecords <;> simp [hlocal] at accepted
  cases hincoming : restoreRegistry network verify incoming <;> simp [hincoming] at accepted
  exact ⟨((restoreRegistry_success_iff _ _ _ _).mp accepted).1,
    restoreRegistry_preserves_invariant _ _ _ _ accepted⟩

theorem mergeRegistry_preserves_records (network : String) (verify : Verifier)
    (localRecords incoming result : Registry)
    (accepted : mergeRegistry network verify localRecords incoming = some result) :
    ∀ record ∈ localRecords, record ∈ result := by
  rw [(mergeRegistry_success _ _ _ _ _ accepted).1]
  exact fun _ member => List.mem_append_left _ member

/-- Agreement concerns public-key membership, not record order or signature bytes. -/
theorem combineRecords_keys (localRecords incoming : Registry) (key : PublicKey) :
    key ∈ (combineRecords localRecords incoming).map (·.statement.publicKey) ↔
      key ∈ localRecords.map (·.statement.publicKey) ∨
      key ∈ incoming.map (·.statement.publicKey) := by
  simp only [combineRecords, List.map_append, List.mem_append]
  constructor
  · intro member
    rcases member with old | added
    · exact Or.inl old
    · obtain ⟨record, present, equal⟩ := List.mem_map.mp added
      exact Or.inr (List.mem_map.mpr ⟨record, (List.mem_filter.mp present).1, equal⟩)
  · intro member
    by_cases known : key ∈ localRecords.map (·.statement.publicKey)
    · exact Or.inl known
    · rcases member with old | added
      · exact False.elim (known old)
      · obtain ⟨record, present, equal⟩ := List.mem_map.mp added
        apply Or.inr
        apply List.mem_map.mpr
        refine ⟨record, List.mem_filter.mpr ⟨present, ?_⟩, equal⟩
        simp [equal, known]

theorem mergeRegistry_keys (network : String) (verify : Verifier)
    (localRecords incoming result : Registry)
    (accepted : mergeRegistry network verify localRecords incoming = some result)
    (key : PublicKey) :
    key ∈ result.map (·.statement.publicKey) ↔
      key ∈ localRecords.map (·.statement.publicKey) ∨
      key ∈ incoming.map (·.statement.publicKey) := by
  rw [(mergeRegistry_success _ _ _ _ _ accepted).1]
  exact combineRecords_keys _ _ _

/-- A successful repeated import whose keys are already known changes nothing. -/
theorem mergeRegistry_known_keys_unchanged (network : String) (verify : Verifier)
    (localRecords incoming result : Registry)
    (accepted : mergeRegistry network verify localRecords incoming = some result)
    (known : ∀ record ∈ incoming, record.statement.publicKey ∈ localRecords.map (·.statement.publicKey)) :
    result = localRecords := by
  rw [(mergeRegistry_success _ _ _ _ _ accepted).1]
  have empty : incoming.filter (fun record =>
      !(localRecords.map (·.statement.publicKey)).contains record.statement.publicKey) = [] := by
    apply List.filter_eq_nil_iff.mpr
    intro record member
    simp [known record member]
  simp only [combineRecords, empty, List.append_nil]

/-- Importing each other's snapshots yields equal key sets whenever both imports
succeed. No claim about network delivery, list ordering, or identical signatures. -/
theorem mergeRegistry_exchange_agrees (network : String) (verify : Verifier)
    (left right leftResult rightResult : Registry)
    (leftAccepted : mergeRegistry network verify left right = some leftResult)
    (rightAccepted : mergeRegistry network verify right left = some rightResult)
    (key : PublicKey) :
    key ∈ leftResult.map (·.statement.publicKey) ↔ key ∈ rightResult.map (·.statement.publicKey) := by
  rw [mergeRegistry_keys _ _ _ _ _ leftAccepted, mergeRegistry_keys _ _ _ _ _ rightAccepted]
  exact or_comm

end VDSI.Identity
