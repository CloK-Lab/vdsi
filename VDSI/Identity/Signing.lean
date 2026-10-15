import VDSI.Identity.Encoding
import VDSI.Identity.Crypto.Ed25519

namespace VDSI.Identity

/-- The research Ed25519 implementation adapted to the same registration policy
used by the model proofs. Those proofs do not verify this cryptographic backend. -/
def ed25519Verifier : Verifier :=
  verifierFromBytes (fun key message signature => Crypto.Ed25519.verify key.bytes message signature)

/-- Derive the key and sign a canonical registration. The seed is secret input;
do not log it or use this variable-time research signer for valuable credentials. -/
def signRegistration (seed : List UInt8) (network : String) : Option Registration := do
  let key ← Crypto.Ed25519.publicKey seed
  let statement := statementFor network ⟨key⟩
  let message ← signingBytes statement
  let signature ← Crypto.Ed25519.sign seed message
  return ⟨statement, signature⟩

end VDSI.Identity
