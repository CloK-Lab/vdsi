import VDSI.Reference.Solana.Model

namespace VDSI.Reference.Solana

/-- No address in the first list occurs in the second. -/
def NoOverlap (left right : List String) : Prop :=
  ∀ address ∈ left, address ∉ right

instance (left right : List String) :
    Decidable (NoOverlap left right) := by
  unfold NoOverlap
  infer_instance

/-- Neither transaction writes an account accessed by the other. -/
def Compatible (left right : AccountAccess) : Prop :=
  NoOverlap left.writable
    (right.readOnly ++ right.writable) ∧
  NoOverlap right.writable
    (left.readOnly ++ left.writable)

instance (left right : AccountAccess) :
    Decidable (Compatible left right) := by
  unfold Compatible
  infer_instance

end VDSI.Reference.Solana
