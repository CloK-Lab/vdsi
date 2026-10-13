import VDSI.Native.Wallet.Model

open VDSI.Foundation

namespace VDSI.Native

/-- A selected spending policy; authentication and key custody are external inputs. -/
def CanSpend (wallet : Wallet) (actor : AgentId) (request : SpendRequest) : Prop :=
  actor = wallet.owner ∧
  request.payer = wallet.account ∧
  request.asset = wallet.asset ∧
  request.amount.units ≤ wallet.perCallLimit.units ∧
  request.payee ∈ wallet.recipients ∧
  request.payer.network = request.asset.network ∧
  request.payee.network = request.asset.network

instance (wallet : Wallet) (actor : AgentId) (request : SpendRequest) :
    Decidable (CanSpend wallet actor request) := by
  unfold CanSpend
  infer_instance

end VDSI.Native
