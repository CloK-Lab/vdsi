import VDSI.Foundation.Quantities.Execution

namespace VDSI.Foundation.Quantities

theorem nonce_next_ne (nonce : Nonce) :
    nonce.next ≠ nonce := by
  intro h
  have hvalue := congrArg Nonce.value h
  exact Nat.ne_of_gt (Nat.lt_succ_self nonce.value) hvalue

/-- Usage can be aggregated before pricing when the rate is the same. -/
theorem fee_add {asset : AssetId}
    (first second : Gas) (price : PricePerGas asset) :
    fee ⟨first.units + second.units⟩ price =
      (fee first price).add (fee second price) := by
  simp only [fee, Amount.add, Nat.add_mul]

end VDSI.Foundation.Quantities
