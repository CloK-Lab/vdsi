import VDSI.Foundation.Asset
import VDSI.Foundation.Identity

open VDSI.Foundation

namespace VDSI.Native

/-- Fixed authority over one account and asset; funds live in the ledger. -/
structure Wallet where
  owner : AgentId
  account : AccountId
  asset : AssetId
  perCallLimit : Amount asset
  recipients : List AccountId
  deriving DecidableEq, Repr

/-- The exact asset, amount, and destination proposed for one payment. -/
structure SpendRequest where
  payer : AccountId
  payee : AccountId
  asset : AssetId
  amount : Amount asset
  deriving DecidableEq, Repr

end VDSI.Native
