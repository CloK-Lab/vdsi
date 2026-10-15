import VDSI.Identity.Snapshot
import VDSI.Identity.Signing
import VDSI.Identity.Merge

namespace VDSI.Identity.RegistryStorage

/-- Research snapshot limit, including JSON overhead, in bytes. -/
def maxBytes : Nat := 65536

private def checkDirectory (directory : System.FilePath) : IO Unit := do
  unless (← directory.symlinkMetadata).type == .dir do
    throw (IO.userError "Registry directory must be a real directory")

private def checkFile (path : System.FilePath) : IO Unit := do
  let info ← path.symlinkMetadata
  unless info.type == .file && info.numLinks == 1 do
    throw (IO.userError "Snapshot must be a regular file with one link")

/-- Missing files are errors. Read at most the limit plus one byte and validate
the whole snapshot before returning any state. No automatic repair or reset. -/
def loadFile (path : System.FilePath) (network : String) : IO Registry := do
  checkFile path
  unless (← path.metadata).byteSize ≤ maxBytes.toUInt64 do
    throw (IO.userError "Registry snapshot exceeds size limit")
  let bytes ← IO.FS.withFile path .read fun handle => do
    let mut result := ByteArray.empty
    for _ in [:maxBytes + 1] do
      let chunk ← handle.read (maxBytes + 1 - result.size).toUSize
      if chunk.size == 0 then break
      result := result ++ chunk
      if result.size > maxBytes then break
    return result
  unless bytes.size ≤ maxBytes do throw (IO.userError "Registry snapshot exceeds size limit")
  let some text := String.fromUTF8? bytes | throw (IO.userError "Invalid snapshot UTF-8")
  match Snapshot.decode network ed25519Verifier text with
  | .ok registry => return registry
  | .error _ => throw (IO.userError "Registry recovery failed: invalid snapshot; no state loaded")

def load (directory : System.FilePath) (network : String) : IO Registry := do
  checkDirectory directory
  loadFile (directory / "registry.json") network

/-- Single writer, trusted directory. Flush a new snapshot before rename. No
success is returned on write/rename failure. Stale pending data is not recovered.
No fsync, rollback protection, or hostile-filesystem race protection is claimed. -/
def save (directory : System.FilePath) (network : String) (records : Registry) : IO Unit := do
  checkDirectory directory
  unless (restoreRegistry network ed25519Verifier records).isSome do
    throw (IO.userError "Refusing to save invalid registry")
  let encoded := (Snapshot.encode network records).toUTF8
  unless encoded.size ≤ maxBytes do throw (IO.userError "Registry snapshot exceeds size limit")
  let pending := directory / "registry.pending"
  -- Missing is allowed; all other metadata failures propagate. Reject links
  -- before opening an existing temporary file (trusted single-writer boundary).
  try checkFile pending catch
    | .noFileOrDirectory .. => pure ()
    | error => throw error
  IO.FS.withFile pending .write fun handle => do
    IO.setAccessRights pending { user := { read := true, write := true } }
    handle.write encoded
    handle.flush
  IO.FS.rename pending (directory / "registry.json")

def create (directory : System.FilePath) (network : String) : IO Unit := do
  IO.FS.createDir directory
  IO.setAccessRights directory { user := { read := true, write := true, execution := true } }
  save directory network []

/-- Load and validate current state, apply registration, save changes, then
return the new state. The caller can acknowledge success only after return. -/
def accept (directory : System.FilePath) (network : String)
    (record : Registration) : IO Registry := do
  let before ← load directory network
  let some after := register network ed25519Verifier before record
    | throw (IO.userError "Registration rejected")
  unless after == before do save directory network after
  return after

/-- Export to a new directory, never overwriting an existing destination. Only
public signed records are written; no identity seed is read. -/
def exportRecords (directory destination : System.FilePath) (network : String) : IO Unit := do
  let records ← load directory network
  IO.FS.createDir destination
  IO.setAccessRights destination { user := { read := true, write := true, execution := true } }
  save destination network records

def importRecords (directory source : System.FilePath) (network : String) : IO Registry := do
  let before ← load directory network
  let incoming ← loadFile source network
  let some after := mergeRegistry network ed25519Verifier before incoming
    | throw (IO.userError "Registry import rejected")
  unless after == before do save directory network after
  return after

end VDSI.Identity.RegistryStorage
