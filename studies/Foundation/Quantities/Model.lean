import VDSI.Foundation.Asset

namespace VDSI.Foundation.Quantities

/-- An account sequence number, not an asset amount. -/
structure Nonce where
  value : Nat
  deriving DecidableEq, Repr

/-- Execution usage counted by the protocol. -/
structure Gas where
  units : Nat
  deriving DecidableEq, Repr

/-- Smallest units of the given asset per gas. -/
structure PricePerGas (asset : AssetId) where
  units : Nat
  deriving DecidableEq, Repr

/-- Constant power over a measured interval, in whole watts. -/
structure Power where
  watts : Nat
  deriving DecidableEq, Repr

/-- A measured interval, in whole seconds. -/
structure Duration where
  seconds : Nat
  deriving DecidableEq, Repr

/-- Energy consumed over the interval, in joules. -/
structure Energy where
  joules : Nat
  deriving DecidableEq, Repr

end VDSI.Foundation.Quantities
