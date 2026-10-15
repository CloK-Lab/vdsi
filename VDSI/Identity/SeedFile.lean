import VDSI.Identity.Crypto.Ed25519

namespace VDSI.Identity.SeedFile

/-- Versioned local research format: marker, 32 secret seed bytes, 32 public
key bytes. This is plaintext, not an encrypted or authenticated backup. -/
def marker : List UInt8 := "vdsi.identity.seed.v1\n".toUTF8.data.toList

def size : Nat := marker.length + 64

def encode (seed : List UInt8) : Option (List UInt8) := do
  let key ← Crypto.Ed25519.publicKey seed
  return marker ++ seed ++ key

/-- Reject truncation, trailing bytes, unknown formats, and mismatched seed/key
pairs. Replacing both seed and key is not detectable without an external anchor. -/
def decode (bytes : List UInt8) : Option (List UInt8) := do
  if bytes.length != size || bytes.take marker.length != marker then none
  else
    let seed := (bytes.drop marker.length).take 32
    let key ← Crypto.Ed25519.publicKey seed
    if key == bytes.drop (marker.length + 32) then some seed else none

end VDSI.Identity.SeedFile
