import VDSI.Identity.Encoding

namespace VDSI.Identity

/-- Only the supported registration domain, version, and key width produce bytes. -/
theorem signingBytes_requires_supported_statement (statement : Statement) (bytes : List UInt8)
    (encoded : signingBytes statement = some bytes) :
    statement.domain = "vdsi.identity.register" ∧ statement.version = 1 ∧
      statement.publicKey.bytes.length = 32 := by
  unfold signingBytes at encoded
  split at encoded
  · assumption
  · contradiction

/-- Among successfully encoded statements, identical messages imply identical
statements. This is an encoding theorem, not a signature-security theorem. -/
theorem signingBytes_injective (left right : Statement) (bytes : List UInt8)
    (leftEncoded : signingBytes left = some bytes)
    (rightEncoded : signingBytes right = some bytes) : left = right := by
  have leftShape := signingBytes_requires_supported_statement left bytes leftEncoded
  have rightShape := signingBytes_requires_supported_statement right bytes rightEncoded
  have messages := leftEncoded.trans rightEncoded.symm
  simp [signingBytes, leftShape, rightShape] at messages
  obtain ⟨keys, networks⟩ := List.append_inj messages (leftShape.2.2.trans rightShape.2.2.symm)
  have networkEqual : left.network = right.network := by
    apply String.toByteArray_inj.mp
    exact ByteArray.ext (Array.toList_inj.mp networks)
  cases left with
  | mk ld lv ln lk =>
    cases right with
    | mk rd rv rn rk =>
      cases lk
      cases rk
      simp_all

/-- The byte adapter cannot accept a statement that has no canonical v1 encoding. -/
theorem unsupported_encoding_rejected
    (check : PublicKey → List UInt8 → List UInt8 → Bool)
    (statement : Statement) (signature : List UInt8)
    (unsupported : signingBytes statement = none) :
    verifierFromBytes check statement signature = false := by
  simp [verifierFromBytes, unsupported]

/-- Any successful adapter call checked the exact canonical message and claimed key. -/
theorem byte_verifier_acceptance_uses_encoding
    (check : PublicKey → List UInt8 → List UInt8 → Bool)
    (statement : Statement) (signature : List UInt8)
    (accepted : verifierFromBytes check statement signature = true) :
    ∃ bytes, signingBytes statement = some bytes ∧ check statement.publicKey bytes signature = true := by
  unfold verifierFromBytes at accepted
  split at accepted
  · contradiction
  · rename_i bytes encoded
    exact ⟨bytes, encoded, accepted⟩

end VDSI.Identity
