import VDSI.Native.Wallet.Spec
import VDSI.Cases.PaidTask.Payment
import VDSI.Cases.PaidTask.Ledger

open VDSI.Foundation VDSI.Native

namespace VDSI.Cases.PaidTask

/-- The actor is an already authenticated principal supplied to this model. -/
def CanAuthorize (wallet : Wallet) (actor : AgentId) (terms : PaymentTerms) : Prop :=
  CanSpend wallet actor ⟨terms.payer, terms.payee, terms.asset, terms.amount⟩ ∧
  actor = terms.task.caller

instance (wallet : Wallet) (actor : AgentId) (terms : PaymentTerms) :
    Decidable (CanAuthorize wallet actor terms) := by
  unfold CanAuthorize
  infer_instance

def MatchesTask (provider : Agent) (task : Task) (terms : PaymentTerms) : Prop :=
  terms.task = task.request ∧
  provider.id = task.request.provider ∧
  task.request.service ∈ provider.services ∧
  terms.payee = provider.payee

instance (provider : Agent) (task : Task) (terms : PaymentTerms) :
    Decidable (MatchesTask provider task terms) := by
  unfold MatchesTask
  infer_instance

/-- Time is measured in abstract ticks; the expiry boundary is exclusive. -/
def CanSettle (wallet : Wallet) (provider : Agent) (task : Task)
    (ledger : Ledger) (authorization : Authorization) (now : Nat) : Prop :=
  CanAuthorize wallet authorization.actor authorization.terms ∧
  MatchesTask provider task authorization.terms ∧
  task.phase = .requested ∧
  now < authorization.terms.expiresAt ∧
  (authorization.terms.payer, authorization.nonce) ∉ ledger.spent ∧
  authorization.terms.amount.units ≤
    ledger.balances authorization.terms.payer authorization.terms.asset

instance (wallet : Wallet) (provider : Agent) (task : Task)
    (ledger : Ledger) (authorization : Authorization) (now : Nat) :
    Decidable (CanSettle wallet provider task ledger authorization now) := by
  unfold CanSettle
  infer_instance

end VDSI.Cases.PaidTask
