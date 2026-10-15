import VDSI.Identity.Signing
import VDSI.Identity.Entropy
import VDSI.Identity.Execution
import Tests.Support

namespace Tests.IdentityCrypto

open VDSI.Identity

private def digit (c : Char) : Nat :=
  if c >= 'a' then c.toNat - 'a'.toNat + 10 else c.toNat - '0'.toNat

-- Only used for the lowercase, even-length public constants below.
private def parseHex : List Char → List UInt8
  | a :: b :: rest => UInt8.ofNat (16 * digit a + digit b) :: parseHex rest
  | _ => []
private def hex (s : String) : List UInt8 := parseHex s.toList

-- RFC 8032 section 7.1, tests 1, 2, and 3. These are PUBLIC test seeds.
private def vectors : List (String × String × String × String) := [
  ("9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60",
   "d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a", "",
   "e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b"),
  ("4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb",
   "3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c", "72",
   "92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00"),
  ("c5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7",
   "fc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025", "af82",
   "6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a")]

private def expectFailure (action : IO (List UInt8)) : IO Unit := do
  let failed ← try
    let _ ← action
    pure false
  catch _ => pure true
  check failed "Entropy failure produced a seed"

def run : IO Unit := do
  check (Crypto.SHA512.hash "abc".toByteArray.data.toList == hex
    "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f")
    "SHA-512 abc vector mismatch"
  -- Fixed SHA-512 fixtures independently computed with Python hashlib; padding boundaries.
  let hashVectors : List (Nat × String) := [
    (0, "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"),
    (111, "a1a111449b198d9b1f538bad7f3fc1022b3a5b1a5e90a0bc860de8512746cbc31599e6c834de3a3235327af0b51ff57bf7acf1974a73014d9c3953812edc7c8d"),
    (112, "c5fbd731d19d2ae1180f001be72c2c1aaba1d7b094b3748880e24593b8e117a750e11c1bd867cc2f96dace8c8b74abd2d5c4f236be444e77d30d1916174070b9"),
    (127, "eab89674feaa34e27aebeeff3c0a4d70070bb872d5e9f186cf1dbbdee517b6e35724d629ff025a5b07185e911ada7e3c8acf830aa0e4f71777bd2d44f504f7f0"),
    (128, "1dffd5e3adb71d45d2245939665521ae001a317a03720a45732ba1900ca3b8351fc5c9b4ca513eba6f80bc7b1d1fdad4abd13491cb824d61b08d8c0e1561b3f7"),
    (129, "1d9da57fbbdab09afb3506ab2d223d06109d65c1c8ad197f50138f714bc4c3f2fe5787922639c680acad1c651f955990425954ce2cba0c5cc83f2667d878eb0f"),
    (255, "15025c9d135861ff5a549df0bfd6c398fd126613496d4e97627651e68b7b1f80407f187d7978464f0f78bfeea787600faaebbe991eddb60671cd0ce874f0a744")]
  for (size, expected) in hashVectors do
    check (Crypto.SHA512.hash ((List.range size).map UInt8.ofNat) == hex expected)
      s!"SHA-512 padding vector mismatch at {size} bytes"
  for (seedText, keyText, messageText, signatureText) in vectors do
    let seed := hex seedText
    let key := hex keyText
    let message := hex messageText
    let signature := hex signatureText
    check (Crypto.Ed25519.publicKey seed == some key) "RFC public key mismatch"
    check (Crypto.Ed25519.sign seed message == some signature) "RFC signature mismatch"
    check (Crypto.Ed25519.verify key message signature) "RFC signature rejected"
    check (!Crypto.Ed25519.verify key (message ++ [0]) signature) "Changed message accepted"
    check (!Crypto.Ed25519.verify key message (signature.take 63)) "Truncated signature accepted"
    let badR := List.replicate 32 255 ++ signature.drop 32
    check (!Crypto.Ed25519.verify key message badR) "Noncanonical R accepted"
    let scalarOrder := hex "edd3f55c1a631258d69cf7a2def9de14000000000000000000000000000000010"
    check (!Crypto.Ed25519.verify key message (signature.take 32 ++ scalarOrder))
      "Out-of-range scalar accepted"
    let fromLE := fun (bs : List UInt8) => bs.foldr (fun b n => b.toNat + 256 * n) 0
    let tooLarge := fromLE (signature.drop 32) + fromLE scalarOrder
    let noncanonicalS := (List.range 32).map fun i => UInt8.ofNat (tooLarge >>> (8 * i))
    check (!Crypto.Ed25519.verify key message (signature.take 32 ++ noncanonicalS))
      "Equivalent scalar plus subgroup order was accepted"
  check ((Crypto.Ed25519.publicKey []).isNone) "Short seed accepted"
  check ((Crypto.Ed25519.sign (List.replicate 33 0) []).isNone) "Long seed accepted"
  let identityPoint : List UInt8 := 1 :: List.replicate 31 0
  let degenerateSignature := identityPoint ++ List.replicate 32 0
  check (!Crypto.Ed25519.verify identityPoint [] degenerateSignature)
    "Identity-point forgery accepted"
  check (!Crypto.Ed25519.verify (List.replicate 32 0) [] degenerateSignature)
    "Small-order public key accepted"
  check (!Crypto.Ed25519.verify (List.replicate 31 1) [] degenerateSignature)
    "Wrong-length public key accepted"
  let badSign := (identityPoint.take 31) ++ [128]
  check (!Crypto.Ed25519.verify badSign [] degenerateSignature)
    "Noncanonical sign bit for x=0 accepted"

  let seed := hex "9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60"
  let some record := signRegistration seed "network-A"
    | throw (IO.userError "Signing a registration failed")
  let some registry := register "network-A" ed25519Verifier [] record
    | throw (IO.userError "Real signed registration rejected")
  check (register "network-A" ed25519Verifier registry record == some registry)
    "Real-signature replay changed state"
  let some recreated := signRegistration seed "network-A"
    | throw (IO.userError "Reusing the same seed failed")
  check (recreated == record) "The same seed and statement did not recreate the same signed identity"
  check (register "network-A" ed25519Verifier registry recreated == some registry)
    "A second instance with the same seed created another identity"
  let changed := { record with statement := { record.statement with network := "network-B" } }
  check (!ed25519Verifier changed.statement changed.signature) "Tampered declaration verified"
  check (register "network-B" ed25519Verifier [] changed == none) "Tampered declaration registered"
  let bobSeed := List.replicate 32 7
  let some bob := signRegistration bobSeed "network-A"
    | throw (IO.userError "Bob signing failed")
  check ((register "network-A" ed25519Verifier registry bob).map List.length == some 2)
    "Different signed identities did not register independently"
  check (register "network-A" ed25519Verifier [] { record with signature := bob.signature } == none)
    "Another identity's signature authorized Alice's registration"

  let exact ← Entropy.readSeed (fun n => pure ((List.replicate n.toNat 7).toByteArray))
  check (exact == List.replicate 32 7) "Exact entropy read changed bytes"
  let short ← Entropy.readSeed (fun _ => pure ([9] : List UInt8).toByteArray)
  check (short == List.replicate 32 9) "Short positive entropy reads were not accumulated"
  expectFailure (Entropy.readSeed (fun _ => pure ByteArray.empty))
  let calls ← IO.mkRef 0
  expectFailure (Entropy.readSeed (fun _ => do
    let count ← calls.get
    calls.set (count + 1)
    if count == 0 then pure ((List.replicate 16 7 : List UInt8).toByteArray)
    else pure ByteArray.empty))
  expectFailure (Entropy.readSeed (fun _ => throw (IO.userError "injected failure")))
  expectFailure (Entropy.readSeed (fun _ => pure ((List.replicate 33 0 : List UInt8).toByteArray)))

end Tests.IdentityCrypto
