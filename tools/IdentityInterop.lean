import VDSI.Identity.Crypto.Ed25519

-- PUBLIC deterministic reference fixtures only. Never supply a real private seed.
private def hex (bytes : List UInt8) : String :=
  let alphabet := "0123456789abcdef".toList.toArray
  String.ofList (bytes.flatMap fun b => [alphabet[b.toNat / 16]!, alphabet[b.toNat % 16]!])
def main : IO Unit := do
  for index in [0:3] do
    let seed := (List.range 32).map fun i => UInt8.ofNat (i + index * 43)
    for size in [0, 1, 111, 112, 127, 128, 129, 255, 1024] do
      let message := (List.range size).map fun i => UInt8.ofNat (i * 17 + index)
      let some key := VDSI.Identity.Crypto.Ed25519.publicKey seed | throw (IO.userError "key")
      let some signature := VDSI.Identity.Crypto.Ed25519.sign seed message | throw (IO.userError "sign")
      unless VDSI.Identity.Crypto.Ed25519.verify key message signature do
        throw (IO.userError "verify")
      IO.println s!"{index} {size} {hex key} {hex signature}"
