import VDSI.Participant

namespace VDSI

/-- The list already contains a participant with this ID. -/
def IdIsRegistered (id : ParticipantId) (participants : List Participant) : Prop :=
  id ∈ participants.map Participant.id

/-- Each participant ID occurs at most once in the list. -/
def UniqueIds (participants : List Participant) : Prop :=
  (participants.map (fun participant => participant.id)).Nodup

/-- Reject exactly existing IDs; otherwise append the new participant,
preserving every existing participant and their order. -/
def RegistrationSpec (before : List Participant) (candidate : Participant)
    (result : Option (List Participant)) : Prop :=
  match result with
  | none => IdIsRegistered candidate.id before
  | some after =>
      ¬ IdIsRegistered candidate.id before ∧
      after = before ++ [candidate]

end VDSI
