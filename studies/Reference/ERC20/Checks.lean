import VDSI.Reference.ERC20.Execution
import VDSI.Reference.Ethereum.Model

open VDSI.Foundation

namespace VDSI.Reference.ERC20

-- A local contract fixture, not a deployed token.
def exampleToken : Token :=
  ⟨⟨Ethereum.mainnet, "0x0000000000000000000000000000000000000010"⟩, 18⟩
def alice : String := "0x0000000000000000000000000000000000000001"
def bob : String := "0x0000000000000000000000000000000000000002"
def initial : State exampleToken :=
  ⟨fun holder => if holder = alice then 100 else 0, 100⟩

def transferReport : Option (Nat × Nat × Nat) := do
  let next ← transfer initial alice bob ⟨30⟩
  pure (next.balanceOf alice, next.balanceOf bob, next.totalSupply)

#guard transferReport = some (70, 30, 100)
#guard (transfer initial alice bob ⟨101⟩).isNone
#guard (transfer initial alice zeroAddress ⟨0⟩).isNone
#guard (transfer initial zeroAddress bob ⟨0⟩).isNone
#guard ((transfer initial alice alice ⟨30⟩).map fun s => s.balanceOf alice) = some 100
#guard ((transfer initial alice bob ⟨0⟩).map fun s => s.balanceOf alice) = some 100
#guard displayScale exampleToken = 1000000000000000000
#guard displayScale { exampleToken with decimals := 6 } = 1000000
#guard exampleToken.asset = { exampleToken with decimals := 6 }.asset

end VDSI.Reference.ERC20
