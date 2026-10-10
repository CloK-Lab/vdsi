import VDSI.Registration.Lemmas

namespace VDSI

/-- A participant list together with a proof that its IDs are unique. -/
structure Registry where
  participants : List Participant
  idsAreUnique : UniqueIds participants

/-- Start with no participants; an empty list has no duplicate IDs. -/
def Registry.empty : Registry where
  participants := []
  idsAreUnique := by
    simp [UniqueIds]

/-- Return a new registry with the participant added, or `none` if the ID is registered. -/
def Registry.register (registry : Registry) (participant : Participant) : Option Registry :=
  match registrationSucceeded : VDSI.register registry.participants participant with
  | none => none
  | some updatedParticipants =>
      some {
        participants := updatedParticipants
        idsAreUnique := register_preserves_unique_ids
          registry.participants participant updatedParticipants
          registry.idsAreUnique registrationSucceeded
      }

/-- Return the participant with the requested ID, or `none` if the ID is absent. -/
def Registry.findParticipant (registry : Registry) (id : ParticipantId) :
    Option Participant :=
  VDSI.findParticipant registry.participants id

end VDSI
