import Lean.Expr
import VDSI.Participant

namespace Experiments.ProofTask

open VDSI (ParticipantId)

/-- A requester-selected proposition in a trusted, locally built Lean module.
The declaration must have type `Prop` and no universe parameters.
The provider supplies only a proof term; it cannot choose this environment or goal. -/
structure Goal where
  moduleName : Lean.Name
  declarationName : Lean.Name
  deriving DecidableEq, Repr

inductive Status where
  | waiting
  | completed
  deriving DecidableEq, Repr

/-- A request to prove an externally supplied goal. The requester owns the task state. -/
structure Task where
  id : Nat
  requester : ParticipantId
  provider : ParticipantId
  goal : Goal
  status : Status := .waiting
  deriving DecidableEq, Repr

/-- A proof term and its task identifiers. No commands, tactics, or imports are accepted.
Participant IDs are declared fields, not authenticated identities in this local experiment. -/
structure Submission where
  taskId : Nat
  requester : ParticipantId
  provider : ParticipantId
  proof : Lean.Expr

inductive Verdict where
  | accepted
  | kernelRejected
  | invalidGoal
  | forbiddenAxioms (names : Array Lean.Name)
  | wrongTask
  | alreadyCompleted
  deriving DecidableEq, Repr

end Experiments.ProofTask
