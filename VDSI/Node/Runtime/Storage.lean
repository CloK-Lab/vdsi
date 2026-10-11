import VDSI.Node
import VDSI.Node.Runtime.Wire

namespace VDSI.Node.Runtime.Storage

/-- One snapshot per node in the current working directory. Each node ID must
have a single running writer in this directory. -/
def pathFor (id : NodeId) : System.FilePath :=
  System.FilePath.mk ".vdsi" / s!"node-{id.value}.json"

/-- A missing snapshot starts an empty registry. Unreadable, malformed, or
duplicate-ID snapshots fail explicitly and are never overwritten during load. -/
def load (id : NodeId) : IO Node := do
  let path := pathFor id
  let text ← try IO.FS.readFile path catch
    | .noFileOrDirectory .. => return Node.init id
    | error => throw error
  let participants ← match Wire.decode text with
    | .ok participants => pure participants
    | .error message => throw (IO.userError s!"Invalid snapshot {path}: {message}")
  let some restored := Node.restoreRegistry id participants
    | throw (IO.userError s!"Invalid snapshot {path}: duplicate participant IDs")
  return restored

/-- Flush a replacement snapshot before renaming it over the old file. The
temporary filename is reused; no history or backups accumulate. This supports
process restart, not guaranteed durability after power loss (no fsync). -/
def save (node : Node) : IO Unit := do
  let path := pathFor node.id
  let temporary := System.FilePath.mk (path.toString ++ ".tmp")
  try
    IO.FS.createDirAll ".vdsi"
    let handle ← IO.FS.Handle.mk temporary .write
    handle.putStr (Wire.encode node.registry.participants ++ "\n")
    handle.flush
    IO.FS.rename temporary path
  catch error =>
    try IO.FS.removeFile temporary catch _ => pure ()
    throw (IO.userError s!"Could not save snapshot {path}: {error}")

end VDSI.Node.Runtime.Storage
