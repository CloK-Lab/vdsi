import VDSI.Registration
import VDSI.Registration.Spec

namespace VDSI

/-- Every result of `register` satisfies `RegisterSpec`. -/
theorem register_satisfies_spec
    (before : List Participant) (candidate : Participant) :
    RegisterSpec before candidate (register before candidate) := by
  unfold register
  split
  · rename_i h_exists
    simpa [RegisterSpec, IdIsRegistered, List.mem_map] using h_exists
  · rename_i h_fresh
    refine ⟨?_, rfl⟩
    simpa [IdIsRegistered, List.any_eq_true, List.mem_map] using h_fresh

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

/-- Every result of `findParticipant` satisfies `FindParticipantSpec`. -/
theorem findParticipant_satisfies_spec
    (participants : List Participant) (id : ParticipantId) :
    FindParticipantSpec participants id (findParticipant participants id) := by
  cases lookupResult : findParticipant participants id with
  | none =>
      -- No result means that no member of the list has the requested ID.
      simpa [FindParticipantSpec, findParticipant, List.find?_eq_none, IdIsRegistered, List.mem_map]
        using lookupResult
  | some found =>
      -- A result must be a member of the list with the requested ID.
      unfold findParticipant at lookupResult
      have foundIsInList : found ∈ participants :=
        List.mem_of_find?_eq_some lookupResult
      have foundIdMatches : found.id = id := by
        simpa using List.find?_some lookupResult
      exact ⟨foundIsInList, foundIdMatches⟩

/-- In a list with unique IDs, two members with the same ID are equal. -/
private theorem members_with_same_id_are_equal
    (participants : List Participant)
    (left right : Participant)
    (idsAreUnique : UniqueIds participants)
    (leftIsInList : left ∈ participants)
    (rightIsInList : right ∈ participants)
    (sameId : left.id = right.id) : left = right := by
  revert idsAreUnique leftIsInList rightIsInList
  induction participants with
  | nil =>
      intro _ leftIsInEmptyList _
      cases leftIsInEmptyList
  | cons first rest membersInRestAreEqual =>
      intro idsAreUnique leftIsInList rightIsInList
      have uniqueIdsInParts :
          first.id ∉ rest.map Participant.id ∧ UniqueIds rest := by
        simpa [UniqueIds] using idsAreUnique
      obtain ⟨firstIdIsAbsentFromRest, restIdsAreUnique⟩ := uniqueIdsInParts
      rcases List.mem_cons.mp leftIsInList with rfl | leftIsInRest
      · rcases List.mem_cons.mp rightIsInList with rfl | rightIsInRest
        · rfl
        · -- One member is first and the other is in the rest: their IDs cannot agree.
          have firstIdIsInRest : left.id ∈ rest.map Participant.id :=
            List.mem_map.mpr ⟨right, rightIsInRest, sameId.symm⟩
          exact False.elim (firstIdIsAbsentFromRest firstIdIsInRest)
      · rcases List.mem_cons.mp rightIsInList with rfl | rightIsInRest
        · have firstIdIsInRest : right.id ∈ rest.map Participant.id :=
            List.mem_map.mpr ⟨left, leftIsInRest, sameId⟩
          exact False.elim (firstIdIsAbsentFromRest firstIdIsInRest)
        · -- Both members are in the rest, where IDs are still unique.
          exact membersInRestAreEqual restIdsAreUnique leftIsInRest rightIsInRest

/-- When IDs are unique, lookup returns a participant if and only if
that participant is in the list and has the requested ID. -/
theorem findParticipant_returns_iff_present_with_matching_id
    (participants : List Participant)
    (id : ParticipantId)
    (participant : Participant)
    (idsAreUnique : UniqueIds participants) :
    findParticipant participants id = some participant ↔
      participant ∈ participants ∧ participant.id = id := by
  have resultMeetsSpec := findParticipant_satisfies_spec participants id
  constructor
  · -- Forward: the successful-result clause gives both required facts.
    intro lookupSucceeded
    rw [lookupSucceeded] at resultMeetsSpec
    exact resultMeetsSpec
  · -- Backward: the absence clause rules out failure; unique IDs identify the result.
    intro ⟨participantIsInList, idMatches⟩
    cases lookupResult : findParticipant participants id with
    | none =>
        rw [lookupResult] at resultMeetsSpec
        have idIsRegistered : IdIsRegistered id participants :=
          List.mem_map.mpr ⟨participant, participantIsInList, idMatches⟩
        exact False.elim (resultMeetsSpec idIsRegistered)
    | some found =>
        rw [lookupResult] at resultMeetsSpec
        obtain ⟨foundIsInList, foundIdMatches⟩ := resultMeetsSpec
        have foundIsParticipant : found = participant :=
          members_with_same_id_are_equal participants found participant idsAreUnique
            foundIsInList participantIsInList (foundIdMatches.trans idMatches.symm)
        rw [foundIsParticipant]

end VDSI
