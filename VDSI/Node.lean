import VDSI.Registry

namespace VDSI

/-- An identifier for a node, distinct from a participant ID. -/
structure NodeId where
  value : Nat
  deriving DecidableEq, Repr

/-- The local state shared by the node model and the running process. -/
structure Node where
  id : NodeId
  registry : Registry

/-- Initialize a node with an empty participant registry. -/
def Node.init (id : NodeId) : Node where
  id := id
  registry := Registry.empty

/-- Restore exactly the stored participant list, rejecting duplicate IDs. -/
def Node.restoreRegistry (id : NodeId) (participants : List Participant) : Option Node :=
  if unique : (participants.map Participant.id).Nodup then
    some { id, registry := { participants, idsAreUnique := unique } }
  else
    none

/-- Process a registration locally, preserving the node ID.
Return `none` if the participant ID is already registered. -/
def Node.register (node : Node) (participant : Participant) : Option Node :=
  match node.registry.register participant with
  | none => none
  | some updatedRegistry => some { node with registry := updatedRegistry }

/-- Process registration requests in order. A duplicate ID leaves the node
unchanged, and processing continues with the remaining requests. -/
def Node.processRegistrations (node : Node) (requests : List Participant) : Node :=
  match requests with
  | [] => node
  | participant :: remaining =>
      match node.register participant with
      | none => node.processRegistrations remaining
      | some updated => updated.processRegistrations remaining

/-- Merge another registry into this node. Existing IDs are retained and duplicate
IDs are ignored. The same operation handles a local registration as a singleton list. -/
def Node.mergeRegistry (node : Node) (incoming : List Participant) : Node :=
  node.processRegistrations incoming

end VDSI
