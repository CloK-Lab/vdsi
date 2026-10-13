import VDSI.Foundation.Asset

open VDSI.Foundation

namespace VDSI.Reference.ERC20

/-- Address strings are treated as already normalized and validated. -/
def zeroAddress : String := "0x0000000000000000000000000000000000000000"

structure Token where
  contract : AccountId
  decimals : Nat
  deriving DecidableEq, Repr

def Token.asset (token : Token) : AssetId :=
  ⟨token.contract.network, "erc20", token.contract.address⟩

/-- The balances inside one token contract, indexed by holder address. -/
structure State (token : Token) where
  balanceOf : String → Nat
  totalSupply : Nat

/-- Display scale only; transfer operates on integer base units. -/
def displayScale (token : Token) : Nat := 10 ^ token.decimals

end VDSI.Reference.ERC20
