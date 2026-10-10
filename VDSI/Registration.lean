import VDSI.Participant

namespace VDSI

def register (participants : List Participant) (participant : Participant) :
    Option (List Participant) :=
  if participants.any (fun existing => decide (existing.id = participant.id)) then
    none
  else
    some (participants ++ [participant])

/-- Return the first participant with the requested ID, or `none` if it is absent. -/
def findParticipant (participants : List Participant) (id : ParticipantId) :
    Option Participant :=
  participants.find? (fun participant => decide (participant.id = id))

end VDSI
