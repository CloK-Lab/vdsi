import VDSI.Cases.PaidTask.Spec

open VDSI.Foundation VDSI.Native VDSI.Cases.PaidTask

namespace VDSI.Cases.PaidTask.System

/-- Fixed participants, spending policy, and a pure service implementation. -/
structure Config where
  wallet : Wallet
  provider : Agent
  service : String → String → Option String

/-- One task's shared state. An approval does not change the ledger. -/
structure State where
  task : Task
  ledger : Ledger
  approval : Option Authorization := none

inductive Action where
  | authorize (actor : AgentId) (terms : PaymentTerms) (nonce : Nat)
  | settle (now : Nat)
  | execute (actor : AgentId)
  deriving Repr

end VDSI.Cases.PaidTask.System
