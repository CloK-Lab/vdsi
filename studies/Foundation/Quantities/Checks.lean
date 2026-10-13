import VDSI.Foundation.Quantities.Verification

namespace VDSI.Foundation.Quantities

#guard energy ⟨100⟩ ⟨2⟩ = ⟨200⟩
#guard (Nonce.next ⟨7⟩).value = 8

-- Separate devices over the same two seconds; illustrative, not measured data.
def deviceEnergy : List Energy :=
  [energy ⟨60⟩ ⟨2⟩,   -- GPU
   energy ⟨25⟩ ⟨2⟩,   -- CPU
   energy ⟨15⟩ ⟨2⟩]   -- Network device

#guard deviceEnergy.map Energy.joules = [120, 50, 30]
#guard (deviceEnergy.map Energy.joules).sum =
  (energy ⟨100⟩ ⟨2⟩).joules

end VDSI.Foundation.Quantities
