import VDSI.Identity.Signing
import VDSI.Identity.Entropy
import VDSI.Identity.Execution
import VDSI.Identity.Storage
import VDSI.Identity.RegistryStorage

open VDSI.Identity

private def ensure (condition : Bool) (message : String) : IO Unit := do
  unless condition do throw (IO.userError message)

private def hex (bytes : List UInt8) : String :=
  String.ofList (bytes.flatMap fun b =>
    let digits := "0123456789abcdef".toList.toArray
    [digits[b.toNat / 16]!, digits[b.toNat % 16]!])

private def demonstrate (seed : List UInt8) : IO Unit := do
  let some record := signRegistration seed "network-A"
    | throw (IO.userError "Registration signing failed")
  IO.println s!"Public identity: {hex record.statement.publicKey.bytes}"
  IO.println "2. Created network-A registration and its canonical signing bytes."
  IO.println "3. Signed with Ed25519 implemented in Lean."
  ensure (ed25519Verifier record.statement record.signature) "Valid signature failed"
  IO.println "4. Real signature verification: PASS."
  let some registry := register "network-A" ed25519Verifier [] record
    | throw (IO.userError "Verified registration was rejected")
  ensure (registry.length == 1) "Unexpected registry size"
  IO.println "5. Registration accepted; registry contains one identity."
  let changed := { record with statement := { record.statement with network := "network-B" } }
  ensure (!ed25519Verifier changed.statement changed.signature) "Tampered signature accepted"
  -- Use network-B policy to demonstrate cryptographic rejection, not merely
  -- rejection of a network that differs from local configuration.
  ensure (register "network-B" ed25519Verifier [] changed == none) "Tampered registration accepted"
  IO.println "6. Changed A to B without re-signing: verification FAILS; registration rejected."
  ensure (register "network-A" ed25519Verifier registry record == some registry) "Replay changed state"
  IO.println "7. Replayed original signed record: still one identity."
  IO.println "Done. Registry recreated in memory; no registry persistence or network synchronization."

def main (args : List String) : IO Unit := do
  IO.println "Identity demo: research implementation; plaintext storage, not a production key store."
  match args with
  | ["registry-export", directory, destination] =>
    RegistryStorage.exportRecords directory destination "network-A"
    IO.println "Export saved: public signed records only, no private seed."
    return
  | ["registry-import", directory, source] =>
    let records ← RegistryStorage.importRecords directory source "network-A"
    IO.println s!"Import confirmed on disk: {records.length} identities."
    return
  | ["registry-init", directory] =>
    RegistryStorage.create directory "network-A"
    IO.println "Registry created and saved: 0 identities."
    return
  | ["registry-show", directory] =>
    let records ← RegistryStorage.load directory "network-A"
    IO.println s!"Registry restored and verified: {records.length} identities."
    for record in records do IO.println s!"Registered identity: {hex record.statement.publicKey.bytes}"
    return
  | ["registry-register", identityDirectory, registryDirectory] =>
    let seed ← Storage.restore identityDirectory
    let some record := signRegistration seed "network-A"
      | throw (IO.userError "Registration signing failed")
    let records ← RegistryStorage.accept registryDirectory "network-A" record
    IO.println s!"Registration confirmed on disk: {records.length} identities."
    return
  | _ => pure ()
  let seed ← match args with
    | [] => do
      let seed ← Entropy.freshSeed
      IO.println "1. Created an ephemeral seed (not printed or saved)."
      pure seed
    | ["init", directory] => do
      let seed ← Storage.create directory
      IO.println "1. Created and saved an identity in the new directory. Keep identity.seed secret."
      pure seed
    | ["resume", directory] => do
      let seed ← Storage.restore directory
      IO.println "1. Restored the existing identity; no new seed generated."
      pure seed
    | _ => throw (IO.userError "Usage: identity-demo [init DIR | resume DIR | registry-init DIR | registry-show DIR | registry-register IDENTITY_DIR REGISTRY_DIR | registry-export DIR NEW_EXPORT_DIR | registry-import DIR SNAPSHOT_FILE]")
  demonstrate seed
