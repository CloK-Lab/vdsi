import VDSI.Reference.X402.Execution

open VDSI.Foundation

namespace VDSI.Reference.X402

-- Core fields from the pinned scheme_exact_evm.md EIP-3009 example.
def exampleRequirements : PaymentRequirements :=
  { scheme := "exact"
    network := ⟨"eip155", "84532"⟩
    asset := "0x036CbD53842c5426634e7929541eC2318f3dCF7e"
    amount := "10000"
    payTo := "0x209693Bc6afc0C5328bA36FaF03C514EF312287C"
    maxTimeoutSeconds := 60 }

#guard amountUnits exampleRequirements = some 10000
#guard amountUnits { exampleRequirements with amount := "0.01" } = none
#guard amountUnits { exampleRequirements with amount := "-1" } = none
#guard amountUnits { exampleRequirements with amount := "invalid" } = none
#guard exampleRequirements.network ≠ (⟨"eip155", "1"⟩ : NetworkId)

end VDSI.Reference.X402
