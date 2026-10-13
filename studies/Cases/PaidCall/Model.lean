namespace VDSI.Cases.PaidCall

/-- The reservation stores the agreed price of this one call. -/
inductive Phase where
  | ready
  | reserved (price : Nat)
  | settled
  | refunded
  deriving DecidableEq, Repr

/-- Available balances; reserved funds are accounted for by `phase`. -/
structure State where
  buyer : Nat
  provider : Nat
  phase : Phase
  deriving DecidableEq, Repr

inductive Action where
  | reserve (price : Nat)
  | settle
  | refund
  deriving DecidableEq, Repr

def initial (buyer provider : Nat) : State :=
  ⟨buyer, provider, .ready⟩

def escrow (s : State) : Nat :=
  match s.phase with
  | .reserved price => price
  | _ => 0

def totalFunds (s : State) : Nat :=
  s.buyer + s.provider + escrow s

end VDSI.Cases.PaidCall
