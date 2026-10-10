import VDSI.Registration
import VDSI.Registration.Spec

namespace VDSI

/-- Registration returns `none` exactly when the candidate's ID is already registered. -/
theorem register_rejects_iff_id_is_registered
    (before : List Participant) (candidate : Participant) :
    register before candidate = none ↔ IdIsRegistered candidate.id before := by
  unfold register
  split <;> simp_all [IdIsRegistered, List.mem_map]

/-- Registration appends the candidate exactly when their ID is not already registered. -/
theorem register_succeeds_iff_id_is_new
    (before : List Participant) (candidate : Participant) :
    register before candidate = some (before ++ [candidate]) ↔
      ¬ IdIsRegistered candidate.id before := by
  simp [register, IdIsRegistered, List.mem_map]

/-- Every result obeys the rejection and successful-append rules in `RegistrationSpec`. -/
theorem register_satisfies_spec
    (before : List Participant) (candidate : Participant) :
    RegistrationSpec before candidate (register before candidate) := by
  unfold register
  split
  · rename_i h_exists
    simpa [RegistrationSpec, IdIsRegistered, List.mem_map] using h_exists
  · rename_i h_fresh
    refine ⟨?_, rfl⟩
    simpa [IdIsRegistered, List.any_eq_true, List.mem_map] using h_fresh

/-- Successful registration places the new participant in the returned list. -/
theorem register_contains_participant
    (before : List Participant) (candidate : Participant)
    (after : List Participant)
    (registrationSucceeded : register before candidate = some after) :
    candidate ∈ after := by
  have resultMeetsSpec := register_satisfies_spec before candidate
  rw [registrationSucceeded] at resultMeetsSpec
  have resultIsAppend : after = before ++ [candidate] := resultMeetsSpec.2
  simp [resultIsAppend]

/-- Successful registration preserves uniqueness when the input IDs are unique. -/
theorem register_preserves_unique_ids
    (before : List Participant) (candidate : Participant)
    (after : List Participant)
    (idsWereUnique : UniqueIds before)
    (registrationSucceeded : register before candidate = some after) :
    UniqueIds after := by
  have resultMeetsSpec := register_satisfies_spec before candidate
  rw [registrationSucceeded] at resultMeetsSpec
  have idWasAbsent : candidate.id ∉ before.map Participant.id := resultMeetsSpec.1
  -- Reuse the contract instead of unfolding the registration algorithm.
  rw [resultMeetsSpec.2]
  unfold UniqueIds
  rw [List.map_append, List.nodup_append]
  refine ⟨idsWereUnique, by simp, ?_⟩
  intro existingId wasInList newId isInSingleton idsEqual
  have newIdIsCandidateId : newId = candidate.id := by simpa using isInSingleton
  apply idWasAbsent
  simpa [idsEqual, newIdIsCandidateId] using wasInList

end VDSI
