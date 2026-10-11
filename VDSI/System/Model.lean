import VDSI.Node

namespace VDSI.System

/-- An offline node has no volatile state. Its saved registry survives process
failure. Disk corruption and power loss are outside this first model. -/
structure LocalState where
  memory : Option Node
  saved : Registry

/-- A decoded snapshot waiting for delivery. The scheduler can delay, duplicate,
drop, or reorder it. Authentication and byte encoding are outside this model. -/
structure Snapshot (nodeCount : Nat) where
  recipient : Fin nodeCount
  participants : List Participant

/-- A fixed, finite collection of nodes and their in-flight snapshots. Each index
identifies one node and one exclusive writer to its saved state. -/
structure State (nodeCount : Nat) where
  nodes : Fin nodeCount → LocalState
  pending : List (Snapshot nodeCount) := []

/-- Actions describe an arbitrary interleaving of node operations. `saved = true`
means the complete save-and-publish operation succeeds; `false` means it fails
without confirming the update. These operations are atomic under the runtime
mutex. A crash during a write, before confirmation, is not modeled here. -/
inductive Action (nodeCount : Nat) where
  | register (atNode : Fin nodeCount) (participant : Participant) (saved : Bool)
  | send (source recipient : Fin nodeCount)
  | deliver (messageIndex : Nat) (saved : Bool)
  | drop (messageIndex : Nat)
  | duplicate (messageIndex : Nat)
  | stop (atNode : Fin nodeCount)
  | restart (atNode : Fin nodeCount) (readSucceeded : Bool)

end VDSI.System
