import VDSI.IdGeneration.Model

namespace VDSI.IdGeneration

/-- For at most one billion draws in total, across all participants and locations,
independent uniform 256-bit IDs have collision probability strictly below 2⁻¹²⁸.
This is a criterion for the sampling model, not an assertion about the IO runtime. -/
def BillionIdRiskSpec : Prop :=
  ∀ draws : Nat, draws ≤ 1000000000 →
    collisionProbability 256 draws < (1 : ℚ) / 2 ^ 128

end VDSI.IdGeneration
