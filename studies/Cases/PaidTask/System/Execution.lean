import VDSI.Cases.PaidTask.System.Model
import VDSI.Cases.PaidTask.Execution

open VDSI.Foundation VDSI.Cases.PaidTask

namespace VDSI.Cases.PaidTask.System

/-- Compose the existing wallet, payment, ledger, and task operations. -/
def step (config : Config) (state : State) : Action → Option State
  | .authorize actor terms nonce => do
    if state.approval.isSome ∨ state.task.phase ≠ .requested then none else do
      if ¬ MatchesTask config.provider state.task terms then none else do
        let approval ← PaidTask.authorize config.wallet actor terms nonce
        pure { state with approval := some approval }
  | .settle now => do
    let approval ← state.approval
    let (ledger, task) ← PaidTask.settle config.wallet config.provider
      state.task state.ledger approval now
    pure { task, ledger, approval := none }
  | .execute actor => do
    if actor ≠ config.provider.id ∨ state.task.phase ≠ .paid then none else do
      let result ← config.service state.task.request.service state.task.request.input
      let task ← PaidTask.complete actor state.task result
      pure { state with task }

/-- Keep the initial state and every accepted state so the interaction is inspectable. -/
def trace (config : Config) (state : State) : List Action → Option (List State)
  | [] => some [state]
  | action :: rest => do
    let next ← step config state action
    let states ← trace config next rest
    pure (state :: states)

end VDSI.Cases.PaidTask.System
