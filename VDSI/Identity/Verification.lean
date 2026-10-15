import VDSI.Identity.Execution

namespace VDSI.Identity

/-- Success requires every policy check, even for an already registered key. -/
theorem registration_requires_validation
    (network : String) (verify : Verifier) (before after : Registry)
    (record : Registration)
    (accepted : register network verify before record = some after) :
    ValidRegistration network verify record := by
  unfold register at accepted
  split at accepted
  · assumption
  · contradiction

/-- Invalid input returns no replacement state, regardless of registry contents. -/
theorem invalid_registration_rejected
    (network : String) (verify : Verifier) (records : Registry) (record : Registration)
    (invalid : ¬ ValidRegistration network verify record) :
    register network verify records record = none := by
  simp [register, invalid]

/-- Relaying a valid record for a known key cannot replace its stored record. -/
theorem valid_replay_unchanged
    (network : String) (verify : Verifier) (records : Registry) (record : Registration)
    (valid : ValidRegistration network verify record)
    (known : record.statement.publicKey ∈ records.map (fun entry => entry.statement.publicKey)) :
    register network verify records record = some records := by
  simp [register, valid, known]

/-- Accepted registration preserves all existing signed records. -/
theorem registration_preserves_records
    (network : String) (verify : Verifier) (before after : Registry)
    (record : Registration)
    (accepted : register network verify before record = some after) :
    ∀ existing ∈ before, existing ∈ after := by
  unfold register at accepted
  split at accepted
  · split at accepted
    · cases Option.some.inj accepted
      exact fun _ member => member
    · cases Option.some.inj accepted
      intro existing member
      exact List.mem_append_left _ member
  · contradiction

/-- A valid starting registry stays valid and contains at most one record per key.
This proves enforcement of the supplied verifier, not its cryptographic soundness. -/
theorem registration_preserves_invariant
    (network : String) (verify : Verifier) (before after : Registry)
    (record : Registration)
    (invariant : RegistryInvariant network verify before)
    (accepted : register network verify before record = some after) :
    RegistryInvariant network verify after := by
  unfold register at accepted
  split at accepted
  · rename_i valid
    split at accepted
    · cases Option.some.inj accepted
      exact invariant
    · rename_i fresh
      cases Option.some.inj accepted
      constructor
      · intro entry member
        rcases List.mem_append.mp member with old | added
        · exact invariant.1 entry old
        · have same : entry = record := by simpa using added
          subst entry
          exact valid
      · simp only [List.map_append, List.map_cons, List.map_nil, List.nodup_append]
        refine ⟨invariant.2, by simp, ?_⟩
        intro key member other singleton
        have same : other = record.statement.publicKey := by simpa using singleton
        subst other
        intro equal
        exact fresh (equal ▸ member)
  · contradiction

/-- Recovery accepts exactly the valid, unique-key snapshots and returns all
records unchanged. This is the operation used after the runtime JSON decoder. -/
theorem restoreRegistry_success_iff (network : String) (verify : Verifier)
    (records restored : Registry) :
    restoreRegistry network verify records = some restored ↔
      restored = records ∧ RegistryInvariant network verify records := by
  unfold restoreRegistry
  split
  · rename_i valid
    split
    · rename_i unique
      constructor
      · intro accepted
        exact ⟨(Option.some.inj accepted).symm, valid, unique⟩
      · intro accepted
        exact congrArg some accepted.1.symm
    · rename_i duplicate
      constructor
      · intro impossible
        cases impossible
      · intro accepted
        exact False.elim (duplicate accepted.2.2)
  · rename_i invalid
    constructor
    · intro impossible
      cases impossible
    · intro accepted
      exact False.elim (invalid accepted.2.1)

/-- Any successful recovery produces a registry satisfying the policy. -/
theorem restoreRegistry_preserves_invariant (network : String) (verify : Verifier)
    (records restored : Registry)
    (accepted : restoreRegistry network verify records = some restored) :
    RegistryInvariant network verify restored := by
  obtain ⟨same, valid⟩ := (restoreRegistry_success_iff network verify records restored).mp accepted
  simpa [same] using valid

end VDSI.Identity
