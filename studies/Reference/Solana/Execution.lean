import VDSI.Reference.Solana.Spec

namespace VDSI.Reference.Solana

/-- Decide access compatibility, without executing or scheduling a transaction. -/
def canRunTogether (left right : AccountAccess) : Bool :=
  decide (Compatible left right)

end VDSI.Reference.Solana
