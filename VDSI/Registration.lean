import VDSI.Participant

namespace VDSI

def register (participants : List Participant) (participant : Participant) :
    Option (List Participant) :=
  if participants.any (fun existing => decide (existing.id = participant.id)) then
    none
  else
    some (participants ++ [participant])

end VDSI
