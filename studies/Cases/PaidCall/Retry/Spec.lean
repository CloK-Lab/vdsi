import VDSI.Cases.PaidCall.Retry.Model

namespace VDSI.Cases.PaidCall.Retry

/-- Either no payment has occurred, or exactly the approved price has moved
once and the corresponding receipt has been saved.
-/
def Accounting (call : Call) (buyer provider : Nat) (s : State) : Prop :=
  (s.funds = PaidCall.initial buyer provider ∧ s.saved = none ∧ s.commits = 0) ∨
  (call.price ≤ buyer ∧
    s.funds = ⟨buyer - call.price, provider + call.price, .settled⟩ ∧
    s.saved = some (receiptFor call) ∧ s.commits = 1)

/-- Replies can only contain the result committed for the approved purchase. -/
def RepliesMatch (s : State) : Prop :=
  (∀ r, s.pending = some r → s.saved = some r) ∧
  (∀ r, s.received = some r → s.saved = some r)

def Invariant (call : Call) (buyer provider : Nat) (s : State) : Prop :=
  Accounting call buyer provider s ∧ RepliesMatch s

end VDSI.Cases.PaidCall.Retry
