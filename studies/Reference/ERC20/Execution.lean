import VDSI.Reference.ERC20.Model

open VDSI.Foundation

namespace VDSI.Reference.ERC20

/-- Ordinary transfer branch of OpenZeppelin ERC20: no mint, burn, or allowance. -/
def transfer {token : Token} (state : State token) (sender recipient : String)
    (amount : Amount token.asset) : Option (State token) :=
  if sender = zeroAddress ∨ recipient = zeroAddress then none
  else if amount.units > state.balanceOf sender then none
  else if sender = recipient then some state
  else
    let balances := fun address =>
      if address = sender then state.balanceOf address - amount.units
      else if address = recipient then state.balanceOf address + amount.units
      else state.balanceOf address
    some { state with balanceOf := balances }

end VDSI.Reference.ERC20
