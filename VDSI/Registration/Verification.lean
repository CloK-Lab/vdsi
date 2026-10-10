import VDSI.Registry

namespace VDSI.Registry

/-- After successful registration, lookup in the returned registry finds that participant.
Each registry already carries a proof that its participant IDs are unique. -/
theorem register_then_find_returns_participant
    (before : Registry)
    (participant : Participant)
    (after : Registry)
    (registrationSucceeded : before.register participant = some after) :
    after.findParticipant participant.id = some participant := by
  -- 1. A successful registry operation contains the successful list operation.
  unfold Registry.register at registrationSucceeded
  split at registrationSucceeded
  · contradiction
  · rename_i updatedParticipants listRegistrationSucceeded
    have newListMatchesResult : after.participants = updatedParticipants := by
      have registriesEqual := Option.some.inj registrationSucceeded
      exact (congrArg Registry.participants registriesEqual).symm

    -- 2. The registration specification places the participant in the new list.
    have registrationMeetsSpec := register_satisfies_spec before.participants participant
    rw [listRegistrationSucceeded] at registrationMeetsSpec
    have newListIsAppend : updatedParticipants = before.participants ++ [participant] :=
      registrationMeetsSpec.2
    have participantIsInNewList : participant ∈ after.participants := by
      rw [newListMatchesResult, newListIsAppend]
      simp

    -- 3. The new registry supplies unique IDs; lookup therefore returns this member.
    exact (findParticipant_returns_iff_present_with_matching_id
      after.participants participant.id participant after.idsAreUnique).mpr
        ⟨participantIsInNewList, rfl⟩

end VDSI.Registry
