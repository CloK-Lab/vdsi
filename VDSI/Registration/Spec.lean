import VDSI.Participant

namespace VDSI

/-- The list already contains a participant with this ID. -/
def IdIsRegistered (id : ParticipantId) (participants : List Participant) : Prop :=
  id ∈ participants.map Participant.id

/-- Each participant ID occurs at most once in the list. -/
def UniqueIds (participants : List Participant) : Prop :=
  (participants.map (fun participant => participant.id)).Nodup

/-- Requirements for a correct result of `register`:
- `none`: the candidate's ID is already registered.
- `some after`: the candidate's ID is new, and `after` is the original list
  with the candidate added at the end. Existing participants and their order are preserved.
-/
def RegisterSpec
    (before : List Participant)
    (candidate : Participant)
    (result : Option (List Participant)) : Prop :=
  match result with
  | none => IdIsRegistered candidate.id before
  | some after =>
      ¬ IdIsRegistered candidate.id before ∧
      after = before ++ [candidate]

/-- Requirements for a correct result of `findParticipant`:
- `none`: no participant in the list has the requested ID.
- `some participant`: this participant is in the list and has the requested ID.
-/
def FindParticipantSpec
    (participants : List Participant)
    (id : ParticipantId)
    (result : Option Participant) : Prop :=
  match result with
  | none => ¬ IdIsRegistered id participants
  | some participant =>
      participant ∈ participants ∧ participant.id = id

end VDSI
