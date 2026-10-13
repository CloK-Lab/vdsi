import VDSI.Foundation.Quantities.Model

open VDSI.Foundation

namespace VDSI.Reference.Ethereum

open Quantities

/-- A new state on success, or rejection without a state. -/
abbrev Transition
    (State Transaction : Type) :=
  State → Transaction → Option State

def mainnet : NetworkId := ⟨"eip155", "1"⟩

/-- Native ETH on Ethereum mainnet, using CAIP-19's native-asset reference. -/
def ether : AssetId :=
  ⟨mainnet, "slip44", "60"⟩

/-- Each unit is one wei, not one ETH. -/
abbrev Wei := Amount ether

def weiPerEther : Nat := 10 ^ 18

/-- An exact integer conversion: one milli-ETH is 10^15 wei. -/
def milliEther (n : Nat) : Wei :=
  ⟨n * 10 ^ 15⟩

/-- Projection of execution-specs Account onto nonce and native balance. -/
structure Account where
  /-- Next outgoing nonce. -/
  nonce : Nonce
  /-- Native ETH, in wei. -/
  balance : Wei
  deriving DecidableEq, Repr

/-- Balance and nonce at each address; address validation is external. -/
abbrev State := String → Account

/-- Transfer fields only; the caller is responsible for authenticating the sender. -/
structure Transfer where
  sender : String
  recipient : String
  /-- Amount to move, in wei. -/
  value : Wei
  /-- Must match the sender nonce. -/
  nonce : Nonce
  deriving DecidableEq, Repr

end VDSI.Reference.Ethereum
