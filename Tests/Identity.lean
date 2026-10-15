import VDSI.Identity.Execution
import Tests.Support

namespace Tests.Identity

open VDSI.Identity

private def aliceKey : PublicKey := ⟨List.replicate 32 1⟩
private def bobKey : PublicKey := ⟨List.replicate 32 2⟩
private def network := "identity-study"
private def alice : Registration :=
  ⟨statementFor network aliceKey, List.replicate 64 11⟩
private def bob : Registration :=
  ⟨statementFor network bobKey, List.replicate 64 22⟩

/-- An exact allowlist of two fixtures, NOT a signature algorithm.
These public byte patterns must never be used as keys or signatures in a runtime. -/
private def fixtureVerifier : Verifier := fun statement signature =>
  decide ((statement = alice.statement ∧ signature = alice.signature) ∨
    (statement = bob.statement ∧ signature = bob.signature))

def run : IO Unit := do
  let some first := register network fixtureVerifier [] alice
    | throw (IO.userError "Valid Alice fixture was rejected")
  let forged := { alice with signature := bob.signature }
  check (register network fixtureVerifier [] forged == none)
    "Copying Alice's key with Bob's signature was accepted"
  check (register network fixtureVerifier first forged == none)
    "An invalid duplicate bypassed validation"
  check (register network fixtureVerifier first alice == some first)
    "Relaying Alice's valid record changed the registry"
  let restoredInstance := alice
  check (register network fixtureVerifier first restoredInstance == some first)
    "A second instance of the same identity created a new record"
  let some both := register network fixtureVerifier first bob
    | throw (IO.userError "Independent Bob fixture was rejected")
  check (both.length == 2) "Distinct keys did not produce two identities"
  check (register network fixtureVerifier [] { alice with
    statement := { alice.statement with publicKey := bobKey } } == none)
    "Changed public key retained acceptance of Alice's signature"

  -- Isolate policy checks from cryptography: even an always-true verifier must
  -- not bypass domain, version, network, key-width, or signature-width checks.
  let permissive : Verifier := fun _ _ => true
  let malformed := [
    { alice with statement := { alice.statement with domain := "vdsi.payment" } },
    { alice with statement := { alice.statement with version := 2 } },
    { alice with statement := { alice.statement with network := "another-network" } },
    { alice with statement := { alice.statement with publicKey := ⟨[1]⟩ } },
    { alice with signature := [11] }]
  for record in malformed do
    check (register network permissive first record == none)
      "Malformed or out-of-scope record bypassed policy checks"
  check (register "another-network" fixtureVerifier [] alice == none)
    "A record was accepted by a different network"
  check (register network (fun _ _ => false) [] alice == none)
    "A verifier rejection was ignored"
  check (register network fixtureVerifier [] alice == some first)
    "A receiving registry could not independently validate a relayed record"

end Tests.Identity
