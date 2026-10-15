import VDSI.Identity.SeedFile
import VDSI.Identity.Entropy

namespace VDSI.Identity.Storage

private def invalid : IO α :=
  throw (IO.userError "Identity file is incomplete or invalid; no new identity was created")

/-- Explicit creation in a new directory only. The parent must already exist
and be trusted. An existing directory (including failed initialization) is never
reused. Plaintext research storage; permissions do not protect against the owner,
root, hostile ACLs, or concurrent filesystem replacement. No fsync guarantee. -/
def create (directory : System.FilePath) : IO (List UInt8) := do
  IO.FS.createDir directory
  IO.setAccessRights directory { user := { read := true, write := true, execution := true } }
  let seed ← Entropy.freshSeed
  let some bytes := SeedFile.encode seed | invalid
  let pending := directory / "identity.pending"
  IO.FS.withFile pending .write fun handle => do
    IO.setAccessRights pending { user := { read := true, write := true } }
    handle.write ⟨bytes.toArray⟩
    handle.flush
  IO.FS.rename pending (directory / "identity.seed")
  return seed

/-- Read a bounded, exact-size file. Missing/invalid state never invokes entropy
or repairs itself. Reject final-component symlinks and nonregular files; ancestor
directories and absence of hostile concurrent mutation remain assumptions. -/
def restore (directory : System.FilePath) : IO (List UInt8) := do
  unless (← directory.symlinkMetadata).type == .dir do
    throw (IO.userError "Identity directory must be a real directory")
  let path := directory / "identity.seed"
  let metadata ← path.symlinkMetadata
  unless metadata.type == .file && metadata.numLinks == 1 do
    throw (IO.userError "Identity seed must be a regular file with one link")
  unless metadata.byteSize == SeedFile.size.toUInt64 do invalid
  let bytes ← IO.FS.withFile path .read fun handle => do
    let mut bytes := ByteArray.empty
    -- One extra byte detects growth between metadata and read; bounded even
    -- if an input changes concurrently. Short positive reads are supported.
    for _ in [:SeedFile.size + 1] do
      let chunk ← handle.read (SeedFile.size + 1 - bytes.size).toUSize
      if chunk.size == 0 then break
      bytes := bytes ++ chunk
      if bytes.size > SeedFile.size then break
    return bytes.data.toList
  let some seed := SeedFile.decode bytes | invalid
  return seed

end VDSI.Identity.Storage
