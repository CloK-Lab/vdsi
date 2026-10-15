import VDSI.Identity.Encoding
import VDSI.Identity.Execution
import Tests.Support

namespace Tests.IdentityEncoding

open VDSI.Identity

-- Independent byte vector: ASCII "vdsi.identity.register", NUL, binary version 1.
private def expectedPrefix : List UInt8 :=
  [118, 100, 115, 105, 46, 105, 100, 101, 110, 116, 105, 116,
    121, 46, 114, 101, 103, 105, 115, 116, 101, 114, 0, 1]

def run : IO Unit := do
  let key : PublicKey := ⟨(List.range 32).map UInt8.ofNat⟩
  let statement := statementFor "lab" key
  let expected := expectedPrefix ++ key.bytes ++ [108, 97, 98]
  check (signingBytes statement == some expected) "Signing bytes differ from the v1 byte vector"
  check (signingBytes (statementFor "" key) == some (expectedPrefix ++ key.bytes))
    "Empty network was encoded inconsistently"
  check (signingBytes (statementFor "网络" key) ==
    some (expectedPrefix ++ key.bytes ++ [231, 189, 145, 231, 187, 156]))
    "Network was not encoded as exact UTF-8 bytes"
  let nulNetwork := String.ofList ['a', Char.ofNat 0, 'b']
  check (signingBytes (statementFor nulNetwork key) ==
    some (expectedPrefix ++ key.bytes ++ [97, 0, 98]))
    "Embedded NUL truncated or altered the network"
  check (signingBytes (statementFor "é" key) !=
    signingBytes (statementFor (String.ofList ['e', Char.ofNat 0x0301]) key))
    "Different Unicode sequences were silently normalized"
  check (signingBytes (statementFor "LAB" key) != some expected)
    "Network names were silently case folded"
  let binaryKey : PublicKey := ⟨[0, 1, 255, 0] ++ List.replicate 28 255⟩
  check (signingBytes (statementFor "lab" binaryKey) ==
    some (expectedPrefix ++ binaryKey.bytes ++ [108, 97, 98]))
    "Binary public-key bytes were treated as text or delimiters"

  let unsupported := [
    { statement with domain := "vdsi.payment" },
    { statement with version := 0 },
    { statement with version := 2 },
    { statement with version := 257 },
    { statement with publicKey := ⟨List.replicate 31 1⟩ },
    { statement with publicKey := ⟨List.replicate 33 1⟩ }]
  for invalid in unsupported do
    check (signingBytes invalid == none) "Unsupported statement produced signing bytes"
    check (!verifierFromBytes (fun _ _ _ => true) invalid [])
      "Permissive checker bypassed encoding rejection"

  -- A public fixture allowlist, not cryptography. Check the adapter's complete
  -- key/message/signature contract against the independent vector above.
  let signature : List UInt8 := List.replicate 64 42
  let checker := fun suppliedKey message suppliedSignature =>
    decide (suppliedKey = key ∧ message = expected ∧ suppliedSignature = signature)
  let verify := verifierFromBytes checker
  let record : Registration := ⟨statement, signature⟩
  let some records := register "lab" verify [] record
    | throw (IO.userError "Byte-verifier fixture could not register")
  check (register "lab" verify records record == some records)
    "Byte-verifier registration replay changed the registry"
  check (!verify { statement with network := "labs" } signature)
    "Changing network retained byte-verifier acceptance"
  check (!verify { statement with publicKey := binaryKey } signature)
    "Changing key retained byte-verifier acceptance"
  check (!verify statement (List.replicate 64 43))
    "Changing signature retained byte-verifier acceptance"
  check (!verifierFromBytes (fun _ _ _ => false) statement signature)
    "Byte-checker rejection was ignored"

end Tests.IdentityEncoding
