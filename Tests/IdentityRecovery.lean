import VDSI.Identity.RegistryStorage
import Tests.Support

namespace Tests.IdentityRecovery
open VDSI.Identity

private def fails (action : IO Unit) : IO Unit := do
  let failed ← try action; pure false catch _ => pure true
  check failed "Expected registry IO failure"

def run : IO Unit := do
  -- Public deterministic test fixture, not a stored credential.
  let some record := signRegistration (List.replicate 32 42) "network-A"
    | throw (IO.userError "Fixture signing failed")
  check (restoreRegistry "network-A" ed25519Verifier [record] == some [record])
    "Valid recovery rejected"
  check (restoreRegistry "network-A" ed25519Verifier [record, record] == none)
    "Duplicate normalized instead of rejected"
  check (restoreRegistry "network-A" (fun _ _ => false) [record] == none)
    "Recovery skipped verifier"
  match Snapshot.decode "network-A" ed25519Verifier (Snapshot.encode "network-A" [record]) with
  | .ok records => check (records == [record]) "Snapshot round trip changed records"
  | .error _ => throw (IO.userError "Snapshot round trip rejected")
  match Snapshot.decode "network-B" ed25519Verifier (Snapshot.encode "network-A" []) with
  | .error _ => pure ()
  | .ok _ => throw (IO.userError "Empty snapshot lost network binding")
  IO.FS.withTempDir fun directory => do
    -- The temporary directory is test-owned; save refuses an invalid registry.
    fails (RegistryStorage.save directory "network-A" [record, record])
    check (!(← (directory / "registry.json").pathExists)) "Invalid save created a snapshot"
    -- Force failure after writing/flushing but before publishing via rename.
    IO.FS.createDir (directory / "registry.json")
    fails (RegistryStorage.save directory "network-A" [record])
    check ((← (directory / "registry.json").symlinkMetadata).type == .dir)
      "Failed rename replaced destination"
    check (← (directory / "registry.pending").pathExists) "Rename failure not reached"
    fails (do let _ ← RegistryStorage.load directory "network-A"; pure ())

end Tests.IdentityRecovery
