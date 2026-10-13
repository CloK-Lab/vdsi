import VDSI.Cases.PaidCall.Model

namespace VDSI.Cases.PaidCall

/-- Execute one accounting action. `none` rejects without returning a new state.
This model does not authenticate callers or determine whether service was delivered.
-/
def execute (s : State) (action : Action) : Option State :=
  match s.phase, action with
  | .ready, .reserve price =>
      if price ≤ s.buyer then
        some ⟨s.buyer - price, s.provider, .reserved price⟩
      else
        none
  | .reserved price, .settle =>
      some ⟨s.buyer, s.provider + price, .settled⟩
  | .reserved price, .refund =>
      some ⟨s.buyer + price, s.provider, .refunded⟩
  | _, _ => none

/-- Replay a sequence; a rejected action rejects the sequence.
This is a pure interpreter, with no committed intermediate external effects.
-/
def run (s : State) : List Action → Option State
  | [] => some s
  | action :: rest => (execute s action).bind fun next => run next rest

end VDSI.Cases.PaidCall
