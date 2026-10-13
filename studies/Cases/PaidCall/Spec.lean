import VDSI.Cases.PaidCall.Model

namespace VDSI.Cases.PaidCall

/-- All funds, including the reservation, remain in the two-party system. -/
def PreservesFunds (before after : State) : Prop :=
  totalFunds after = totalFunds before

/-- A finished call cannot be reused for another payment. -/
def Terminal (s : State) : Prop :=
  s.phase = .settled ∨ s.phase = .refunded

end VDSI.Cases.PaidCall
