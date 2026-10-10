namespace VDSI

structure ParticipantId where
  value : Nat
  deriving DecidableEq, Repr

structure Participant where
  id : ParticipantId
  deriving Repr

end VDSI
