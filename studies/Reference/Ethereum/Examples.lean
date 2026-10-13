import VDSI.Reference.Ethereum.Execution

open VDSI.Foundation

namespace VDSI.Reference.Ethereum

open Quantities

-- Local address labels, not deployed accounts.
def initialState : State := fun address =>
  if address = "Alice" then
    { nonce := ⟨7⟩, balance := milliEther 10 }
  else if address = "Bob" then
    { nonce := ⟨0⟩, balance := milliEther 2 }
  else
    { nonce := ⟨0⟩, balance := ⟨0⟩ }

def payment : Transfer :=
  { sender := "Alice"
    recipient := "Bob"
    value := milliEther 3
    nonce := ⟨7⟩ }

/-- The three values inspected in the payment example. -/
structure TransferSnapshot where
  senderBalance : Wei
  recipientBalance : Wei
  senderNonce : Nonce
  deriving DecidableEq, Repr

def transferExample : Option TransferSnapshot := do
  let next ← applyTransfer initialState payment
  let sender := next payment.sender
  let recipient := next payment.recipient
  pure {
    senderBalance := sender.balance
    recipientBalance := recipient.balance
    senderNonce := sender.nonce
  }

end VDSI.Reference.Ethereum
