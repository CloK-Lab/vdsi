import VDSI.Reference.Ethereum.Model

open VDSI.Foundation

namespace VDSI.Reference.Ethereum

/-- The two acceptance conditions of the balance-and-nonce model. -/
def ValidTransfer
    (state : State) (tx : Transfer) : Prop :=
  tx.nonce = (state tx.sender).nonce ∧
  tx.value.units ≤ (state tx.sender).balance.units

instance (state : State) (tx : Transfer) :
    Decidable (ValidTransfer state tx) := by
  unfold ValidTransfer
  infer_instance

end VDSI.Reference.Ethereum
