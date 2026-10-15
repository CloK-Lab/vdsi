namespace VDSI.Identity.Entropy

/-- Read exactly 32 bytes. Short positive reads are retried; EOF, oversized reads,
and IO errors fail without a seed. The reader parameter supports failure tests,
not an alternate random generator for the demo. No entropy claim is proved. -/
def readSeed (read : USize → IO ByteArray) : IO (List UInt8) := do
  let mut bytes : ByteArray := ByteArray.empty
  for _ in [:32] do
    if bytes.size == 32 then return bytes.data.toList
    let remaining := 32 - bytes.size
    let chunk ← read remaining.toUSize
    if chunk.size == 0 || chunk.size > remaining then
      throw (IO.userError "Entropy read failed: no complete 32-byte seed")
    bytes := bytes ++ chunk
  if bytes.size != 32 then
    throw (IO.userError "Entropy read failed: no complete 32-byte seed")
  return bytes.data.toList

/-- macOS/Linux entropy boundary. No clock, fixed seed, or pseudo-random fallback.
OS entropy, process-memory protection, and secure erasure are outside the proofs. -/
def freshSeed : IO (List UInt8) :=
  IO.FS.withFile "/dev/urandom" .read fun handle => readSeed handle.read

end VDSI.Identity.Entropy
