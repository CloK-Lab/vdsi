import VDSI.Foundation.Network

namespace VDSI.Foundation

/-- Asset identity excludes display metadata such as its name and decimal places. -/
structure AssetId where
  network : NetworkId
  namespaceId : String
  reference : String
  deriving DecidableEq, Repr

/-- An integer number of the asset's smallest units. -/
structure Amount (asset : AssetId) where
  units : Nat
  deriving DecidableEq, Repr

/-- Addition requires both amounts to have the same asset index. -/
def Amount.add {asset : AssetId} (a b : Amount asset) : Amount asset :=
  ⟨a.units + b.units⟩

end VDSI.Foundation
