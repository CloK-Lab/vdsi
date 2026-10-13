import VDSI.Foundation.Quantities.Model

namespace VDSI.Foundation.Quantities

def Nonce.next (nonce : Nonce) : Nonce :=
  ⟨nonce.value + 1⟩

/-- Price an already supplied gas usage at one effective rate. -/
def fee {asset : AssetId}
    (used : Gas) (price : PricePerGas asset) :
    Amount asset :=
  ⟨used.units * price.units⟩

/-- Constant power times duration; not a conversion from gas. -/
def energy (power : Power) (duration : Duration) :
    Energy :=
  ⟨power.watts * duration.seconds⟩

end VDSI.Foundation.Quantities
