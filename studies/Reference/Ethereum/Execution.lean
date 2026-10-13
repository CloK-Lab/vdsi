import VDSI.Reference.Ethereum.Spec
import VDSI.Foundation.Quantities.Execution

open VDSI.Foundation

namespace VDSI.Reference.Ethereum

/-- Evaluate the transfer rule against one immutable account-state snapshot. -/
def applyTransfer : Transition State Transfer :=
  fun state tx =>
    if ValidTransfer state tx then
      some fun address =>
        let account := state address
        let debit :=
          if address = tx.sender then tx.value.units else 0
        let credit :=
          if address = tx.recipient then tx.value.units else 0
        let nextNonce :=
          if address = tx.sender then account.nonce.next
          else account.nonce
        { balance :=
            ⟨account.balance.units - debit + credit⟩
          nonce := nextNonce }
    else none

end VDSI.Reference.Ethereum
