import VDSI.Cases.PaidTask.Execution
import VDSI.Reference.Ethereum.Model

open VDSI.Reference
open VDSI.Foundation VDSI.Native

namespace VDSI.Cases.PaidTask.Examples

def network : NetworkId := Ethereum.mainnet
def ether : AssetId := Ethereum.ether
def otherAsset : AssetId := { ether with network := ⟨"eip155", "11155111"⟩ }
def buyerAccount : AccountId := ⟨network, "0x0000000000000000000000000000000000000001"⟩
def providerAccount : AccountId := ⟨network, "0x0000000000000000000000000000000000000002"⟩
def otherAccount : AccountId := { buyerAccount with network := otherAsset.network }
def buyer : AgentId := ⟨"agent-a"⟩
def provider : Agent := ⟨⟨"agent-b"⟩, "https://agent-b.example/a2a", ["echo"], providerAccount⟩

def wallet : Wallet := ⟨buyer, buyerAccount, ether, (Ethereum.milliEther 3), [providerAccount]⟩
def request : TaskRequest := ⟨⟨1⟩, buyer, provider.id, "echo", "hello"⟩
def task : Task := ⟨request, .requested⟩
def terms : PaymentTerms := ⟨request, buyerAccount, providerAccount, ether, (Ethereum.milliEther 3), 100⟩

def initialLedger : Ledger :=
  { balances := fun account asset =>
      if asset = ether then
        if account = buyerAccount then 10000000000000000
        else if account = providerAccount then 2000000000000000
        else 0
      else if asset = otherAsset ∧ account = otherAccount then 7
      else 0 }

def approved : Option Authorization := authorize wallet buyer terms 0

def paid : Option (Ledger × Task) := do
  settle wallet provider task initialLedger (← approved) 10

structure Report where
  buyerWei : Nat
  providerWei : Nat
  otherAssetUnits : Nat
  phase : TaskPhase
  deriving DecidableEq, Repr

/-- Execute the example echo service and report balances from the settled ledger. -/
def demo : Option Report := do
  let (ledger, paidTask) ← paid
  if paidTask.request.service ≠ "echo" then none else do
    let finished ← complete provider.id paidTask paidTask.request.input
    pure ⟨ledger.balances buyerAccount ether,
      ledger.balances providerAccount ether,
      ledger.balances otherAccount otherAsset, finished.phase⟩

#guard demo = some ⟨7000000000000000, 5000000000000000, 7, .completed "hello"⟩
#guard (paid.map fun result => result.2.phase) = some .paid
#guard (authorize wallet ⟨"intruder"⟩ terms 0).isNone
#guard (authorize wallet buyer { terms with amount := ⟨3000000000000001⟩ } 0).isNone
#guard (authorize wallet buyer
  { terms with asset := otherAsset, amount := ⟨3000000000000000⟩ } 0).isNone
#guard (authorize wallet buyer { terms with payee := ⟨network, "stranger"⟩ } 0).isNone
#guard (authorize wallet buyer
  { terms with payee := ⟨⟨"eip155", "11155111"⟩, "provider"⟩ } 0).isNone
#guard (complete provider.id task "hello").isNone

-- Fresh task state cannot make an already used payment authorization usable again.
#guard (do
  let (ledger, _) ← paid
  settle wallet provider task ledger (← approved) 11).isNone

-- The deadline is exclusive; the authorization does not outlive it.
#guard (do settle wallet provider task initialLedger (← approved) 100).isNone

-- Binding only a task ID would miss this change to the requested input.
#guard (do
  let altered := { task with request := { request with input := "different work" } }
  settle wallet provider altered initialLedger (← approved) 10).isNone

#guard (do
  let empty : Ledger := { balances := fun _ _ => 0 }
  settle wallet provider task empty (← approved) 10).isNone

#guard (do
  let (_, paidTask) ← paid
  complete buyer paidTask "forged result").isNone

-- A provider cannot collect payment at an account other than its configured payee.
#guard (do
  let changed := { provider with payee := buyerAccount }
  settle wallet changed task initialLedger (← approved) 10).isNone

-- A reused task cannot be charged again even with a fresh nonce.
#guard (do
  let (ledger, paidTask) ← paid
  let fresh ← authorize wallet buyer terms 1
  settle wallet provider paidTask ledger fresh 11).isNone

-- Network validation still applies when the address is explicitly permitted.
#guard (let foreign : AccountId := ⟨⟨"eip155", "11155111"⟩, "provider"⟩
  let permissive := { wallet with recipients := [foreign] }
  authorize permissive buyer { terms with payee := foreign } 0).isNone

-- A transfer to the paying account must not destroy or create funds.
#guard (do
  let selfWallet := { wallet with recipients := [buyerAccount] }
  let selfProvider := { provider with payee := buyerAccount }
  let selfTerms := { terms with payee := buyerAccount }
  let authorization ← authorize selfWallet buyer selfTerms 0
  let (ledger, _) ← settle selfWallet selfProvider task initialLedger authorization 10
  pure (ledger.balances buyerAccount ether, ledger.balances providerAccount ether)) =
    some (10000000000000000, 2000000000000000)

-- The same address on another network is a different account and asset.
#guard buyerAccount ≠ { buyerAccount with network := ⟨"eip155", "11155111"⟩ }
#guard ether ≠ { ether with network := ⟨"eip155", "11155111"⟩ }

end VDSI.Cases.PaidTask.Examples
