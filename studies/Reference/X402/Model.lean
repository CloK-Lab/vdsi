import VDSI.Foundation.Network

open VDSI.Foundation

namespace VDSI.Reference.X402

/-- Core fields from the v2 SDK; scheme-specific `extra` is omitted. -/
structure PaymentRequirements where
  scheme : String
  network : NetworkId
  asset : String
  amount : String
  payTo : String
  maxTimeoutSeconds : Nat
  deriving DecidableEq, Repr

/-- A projection of the response: one resource can offer several payment options. -/
structure PaymentRequired where
  x402Version : Nat
  resourceUrl : String
  accepts : List PaymentRequirements
  deriving DecidableEq, Repr

end VDSI.Reference.X402
