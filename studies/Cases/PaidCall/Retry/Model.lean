import VDSI.Cases.PaidCall.Model

namespace VDSI.Cases.PaidCall.Retry

/-- One approved purchase, scoped to a fixed buyer, provider, and asset.
The price is in the asset's integer base units; fees are omitted.
-/
structure Call where
  id : Nat
  price : Nat
  input : String
  deriving DecidableEq, Repr

/-- A local accounting receipt and the result of the pure echo service. -/
structure Receipt where
  call : Call
  result : String
  deriving DecidableEq, Repr

def receiptFor (call : Call) : Receipt :=
  ⟨call, call.input⟩

/-- `funds` and `saved` persist together in one atomic model transition.
`pending` is the reply in transit; `received` is the client's last delivered reply.
`commits` counts model payment commits, not gas or network transactions.
-/
structure State where
  funds : PaidCall.State
  saved : Option Receipt := none
  pending : Option Receipt := none
  received : Option Receipt := none
  commits : Nat := 0
  deriving DecidableEq, Repr

def initial (buyer provider : Nat) : State :=
  { funds := PaidCall.initial buyer provider }

inductive Action where
  | request (call : Call)
  | dropReply
  | deliverReply
  deriving DecidableEq, Repr

end VDSI.Cases.PaidCall.Retry
