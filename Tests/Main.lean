import Tests.Registration
import Tests.Wire
import Tests.System
import Tests.IdGeneration
import Tests.Identity
import Tests.IdentityEncoding
import Tests.IdentityCrypto
import Tests.IdentityRecovery

def main : IO Unit := do
  Tests.Identity.run
  Tests.IdentityRecovery.run
  IO.println "[PASS] Identity registry recovery, codec, invalid saves, and failed rename"
  IO.println "[PASS] Identity registration policy (fixture verifier; no cryptography)"
  Tests.IdentityEncoding.run
  IO.println "[PASS] Canonical identity signing bytes and byte-verifier adapter"
  Tests.IdentityCrypto.run
  IO.println "[PASS] Research Ed25519: RFC vectors, tampering, registration, and entropy failures"
  Tests.Registration.run
  IO.println "[PASS] Registration"
  Tests.Wire.run
  IO.println "[PASS] Wire"
  Tests.System.run
  IO.println "[PASS] System"
  Tests.IdGeneration.run
  IO.println "[PASS] ID generation model"
