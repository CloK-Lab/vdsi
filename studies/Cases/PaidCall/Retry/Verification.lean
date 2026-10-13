import VDSI.Cases.PaidCall.Retry.Spec
import VDSI.Cases.PaidCall.Retry.Execution
import Std.Tactic

namespace VDSI.Cases.PaidCall.Retry

private theorem request_preservesInvariant (call : Call) (buyer provider : Nat)
    (s : State) (supplied : Call) (valid : Invariant call buyer provider s) :
    Invariant call buyer provider (request call s supplied) := by
  by_cases callEq : supplied = call
  · subst supplied
    rcases valid with ⟨accounting, pending, received⟩
    rcases accounting with ⟨funds, saved, commits⟩ | ⟨funded, funds, saved, commits⟩
    · have noReceived : s.received = none := by
        cases h : s.received with
        | none => rfl
        | some r =>
            have impossible := received r h
            simp [saved] at impossible
      by_cases funded : call.price ≤ buyer
      · simp [request, saved, funds, PaidCall.run, PaidCall.execute,
          PaidCall.initial, funded, Invariant, Accounting, RepliesMatch,
          commits, noReceived]
      · simpa [request, saved, funds, PaidCall.run, PaidCall.execute,
          PaidCall.initial, funded] using
          (show Invariant call buyer provider s from
            ⟨Or.inl ⟨funds, saved, commits⟩, pending, received⟩)
    · simp only [request, saved, ↓reduceIte]
      exact ⟨Or.inr ⟨funded, funds, rfl, commits⟩,
        fun _ h => h, fun r h => saved.symm.trans (received r h)⟩
  · simpa [request, callEq] using valid

theorem execute_preservesInvariant (call : Call) (buyer provider : Nat)
    (s : State) (action : Action) (valid : Invariant call buyer provider s) :
    Invariant call buyer provider (execute call s action) := by
  cases action with
  | request supplied => exact request_preservesInvariant call buyer provider s supplied valid
  | dropReply =>
      exact ⟨valid.1, by simp [execute], valid.2.2⟩
  | deliverReply =>
      cases h : s.pending with
      | none => simpa [execute, h] using valid
      | some receipt =>
          simp only [execute, h]
          refine ⟨valid.1, ?_, ?_⟩
          · simp
          · intro r hr
            simp only [Option.some.injEq] at hr
            subst r
            exact valid.2.1 receipt h

theorem run_preservesInvariant (call : Call) (buyer provider : Nat)
    (s : State) (actions : List Action) (valid : Invariant call buyer provider s) :
    Invariant call buyer provider (run call s actions) := by
  induction actions generalizing s with
  | nil => exact valid
  | cons action rest ih =>
      exact ih _ (execute_preservesInvariant call buyer provider s action valid)

theorem initial_invariant (call : Call) (buyer provider : Nat) :
    Invariant call buyer provider (initial buyer provider) := by
  simp [Invariant, Accounting, RepliesMatch, initial]

/-- Any finite trace, including arbitrary losses and retries, commits at most once. -/
theorem run_atMostOnce (call : Call) (buyer provider : Nat) (actions : List Action) :
    (run call (initial buyer provider) actions).commits ≤ 1 := by
  have valid := run_preservesInvariant call buyer provider _ actions
    (initial_invariant call buyer provider)
  rcases valid.1 with h | h <;> omega

theorem run_preservesFunds (call : Call) (buyer provider : Nat) (actions : List Action) :
    PaidCall.totalFunds (run call (initial buyer provider) actions).funds =
      buyer + provider := by
  have valid := run_preservesInvariant call buyer provider _ actions
    (initial_invariant call buyer provider)
  rcases valid.1 with ⟨funds, _, _⟩ | ⟨funded, funds, _, _⟩
  · simp [funds, PaidCall.totalFunds, PaidCall.initial, PaidCall.escrow]
  · simp [funds, PaidCall.totalFunds, PaidCall.escrow]
    omega

/-- A delivered receipt identifies the approved call and an actual model commit. -/
theorem run_receivedReceipt (call : Call) (buyer provider : Nat) (actions : List Action)
    (receipt : Receipt)
    (delivered : (run call (initial buyer provider) actions).received = some receipt) :
    receipt = receiptFor call ∧ (run call (initial buyer provider) actions).commits = 1 := by
  have valid := run_preservesInvariant call buyer provider _ actions
    (initial_invariant call buyer provider)
  have saved := valid.2.2 receipt delivered
  rcases valid.1 with h | h
  · rw [h.2.1] at saved
    cases saved
  · exact ⟨Option.some.inj (saved.symm.trans h.2.2.1), h.2.2.2⟩

/-- A cached retry leaves the ledger, saved result, and commit count unchanged. -/
theorem retry_usesReceipt (call : Call) (s : State) (receipt : Receipt)
    (saved : s.saved = some receipt) :
    request call s call = { s with pending := some receipt } := by
  simp [request, saved]

/-- The full request must match, including both price and service input. -/
theorem changedTerms_rejected (call supplied : Call) (s : State)
    (different : supplied ≠ call) : request call s supplied = s := by
  simp [request, different]

/-- Once committed, a retry followed by delivery recovers the saved receipt. -/
theorem retry_deliversReceipt (call : Call) (s : State) (receipt : Receipt)
    (saved : s.saved = some receipt) :
    (run call s [.request call, .deliverReply]).received = some receipt := by
  simp [run, execute, request, saved]

/-- A funded call recovers from one lost reply when the retry's reply is delivered. -/
theorem lostReply_recovers (call : Call) (buyer provider : Nat) (funded : call.price ≤ buyer) :
    run call (initial buyer provider)
      [.request call, .dropReply, .request call, .deliverReply] =
    { funds := ⟨buyer - call.price, provider + call.price, .settled⟩,
      saved := some (receiptFor call), pending := none,
      received := some (receiptFor call), commits := 1 } := by
  simp [run, execute, request, initial, PaidCall.run, PaidCall.execute,
    PaidCall.initial, funded]

end VDSI.Cases.PaidCall.Retry
