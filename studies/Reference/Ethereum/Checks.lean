import VDSI.Reference.Ethereum.Examples

open VDSI.Foundation

namespace VDSI.Reference.Ethereum

-- Illustrative inputs, not a live gas quote.
def transferGas : Quantities.Gas := ⟨21000⟩
def effectivePrice : Quantities.PricePerGas ether :=
  ⟨2 * 10 ^ 9⟩

#guard (Quantities.fee transferGas effectivePrice).units = 42000000000000
#guard (Quantities.fee ⟨0⟩ effectivePrice).units = 0

def exampleAccount : Account := ⟨⟨0⟩, milliEther 10⟩

#guard (milliEther 3).units = 3000000000000000
#guard (milliEther 1000).units = weiPerEther
#guard exampleAccount.balance.units = 10000000000000000
#guard ether ≠ { ether with network := ⟨"eip155", "11155111"⟩ }

#guard transferExample = some {
  senderBalance := milliEther 7, recipientBalance := milliEther 5, senderNonce := ⟨8⟩ }
#guard (applyTransfer initialState { payment with nonce := ⟨8⟩ }).isNone
#guard (applyTransfer initialState { payment with value := milliEther 11 }).isNone

-- Once nonce 7 has been consumed, neither replay nor a conflicting spend is accepted.
#guard ((applyTransfer initialState payment).bind fun next =>
  applyTransfer next payment).isNone
#guard ((applyTransfer initialState payment).bind fun next =>
  applyTransfer next { payment with recipient := "Carol" }).isNone

-- A self-transfer preserves value while advancing the nonce.
#guard ((applyTransfer initialState { payment with recipient := "Alice" }).map
  fun next => next "Alice") = some ⟨⟨8⟩, milliEther 10⟩
#guard ((applyTransfer initialState { payment with value := ⟨0⟩ }).map
  fun next => next "Alice") = some ⟨⟨8⟩, milliEther 10⟩
#guard ((applyTransfer initialState { payment with recipient := "Carol" }).map
  fun next => next "Carol") = some ⟨⟨0⟩, milliEther 3⟩
#guard ((applyTransfer initialState payment).map fun next => next "Carol") =
  some (initialState "Carol")
#guard ((applyTransfer initialState payment).bind fun next =>
  (applyTransfer next { payment with nonce := ⟨8⟩ }).map fun final =>
    ((final "Alice").balance.units, (final "Bob").balance.units,
      (final "Alice").nonce.value)) = some (4000000000000000, 8000000000000000, 9)

end VDSI.Reference.Ethereum
