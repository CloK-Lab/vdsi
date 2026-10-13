import VDSI.Cases.PaidCall.Spec
import VDSI.Cases.PaidCall.Execution
import Std.Tactic

namespace VDSI.Cases.PaidCall

theorem execute_preservesFunds (before after : State) (action : Action)
    (accepted : execute before action = some after) :
    PreservesFunds before after := by
  rcases before with ⟨buyer, provider, phase⟩
  cases phase <;> cases action <;>
    simp_all [execute, PreservesFunds, totalFunds, escrow]
  · rcases accepted with ⟨funded, rfl⟩
    simp_all <;> omega
  · cases accepted
    simp_all <;> omega
  · cases accepted
    simp_all <;> omega

theorem run_preservesFunds (before after : State) (actions : List Action)
    (accepted : run before actions = some after) :
    PreservesFunds before after := by
  induction actions generalizing before with
  | nil =>
      simp [run] at accepted
      subst after
      rfl
  | cons action rest ih =>
      cases stepEq : execute before action with
      | none => simp [run, stepEq] at accepted
      | some next =>
          have tailEq : run next rest = some after := by
            simpa [run, stepEq] using accepted
          exact (ih next tailEq).trans (execute_preservesFunds before next action stepEq)

theorem terminal_rejects (s : State) (action : Action) (finished : Terminal s) :
    execute s action = none := by
  rcases finished with settled | refunded
  · simp [execute, settled]
  · simp [execute, refunded]

/-- A fully funded reservation can always be refunded in this accounting model. -/
theorem reserve_refund (buyer provider price : Nat) (funded : price ≤ buyer) :
    run (initial buyer provider) [.reserve price, .refund] =
      some ⟨buyer, provider, .refunded⟩ := by
  simp [run, execute, initial, funded, Nat.sub_add_cancel funded]

end VDSI.Cases.PaidCall
