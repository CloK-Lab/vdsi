import VDSI.Identity.Model

namespace VDSI.Identity

/-- Application-level signing prefix: ASCII domain, NUL separator, version byte 1.
This is part of the message, not an Ed25519ctx context or a transport frame. -/
def signingPrefix : List UInt8 :=
  "vdsi.identity.register".toByteArray.data.toList ++ [0, 1]

/-- Canonical v1 signing message: prefix, exactly 32 public-key bytes, then the
network's exact UTF-8 bytes through end-of-message. No Unicode normalization or
case folding is performed. Other domains, versions, and key widths are rejected.
The signature is not part of its own signing message. -/
def signingBytes (statement : Statement) : Option (List UInt8) :=
  if statement.domain = "vdsi.identity.register" ∧ statement.version = 1 ∧
      statement.publicKey.bytes.length = 32 then
    some (signingPrefix ++ (statement.publicKey.bytes ++ statement.network.toByteArray.data.toList))
  else
    none

/-- Adapt a byte-oriented signature checker to the registration policy.
The checker receives the claimed public key, canonical message, and signature.
No default cryptographic checker is supplied. Unsupported statements fail closed. -/
def verifierFromBytes
    (check : PublicKey → List UInt8 → List UInt8 → Bool) : Verifier :=
  fun statement signature =>
    match signingBytes statement with
    | none => false
    | some message => check statement.publicKey message signature

end VDSI.Identity
