import VDSI.Registration.Lemmas

namespace VDSI

/-- If the original IDs are unique and registration succeeds,
looking up the registered participant's ID in the new list returns that participant. -/
theorem register_then_find_returns_participant
    (before : List Participant)
    (participant : Participant)
    (after : List Participant)
    (idsWereUnique : UniqueIds before)
    (registrationSucceeded : register before participant = some after) :
    findParticipant after participant.id = some participant := by
  -- 1. The registration specification places the participant in the new list.
  have registrationMeetsSpec := register_satisfies_spec before participant
  rw [registrationSucceeded] at registrationMeetsSpec
  have newListIsAppend : after = before ++ [participant] := registrationMeetsSpec.2
  have participantIsInNewList : participant ∈ after := by
    simp [newListIsAppend]

  -- 2. Registration preserves unique IDs in the new list.
  have newIdsAreUnique : UniqueIds after :=
    register_preserves_unique_ids before participant after
      idsWereUnique registrationSucceeded

  -- 3. Lookup finds this member by its ID, using the lookup equivalence.
  exact (findParticipant_returns_iff_present_with_matching_id
    after participant.id participant newIdsAreUnique).mpr
      ⟨participantIsInNewList, rfl⟩

end VDSI
