import VDSI.System.Model

namespace VDSI.System

def initial (nodeCount : Nat) : State nodeCount where
  nodes := fun index => { memory := some (Node.init { value := index.val }), saved := Registry.empty }

/-- One node changes; the other node states are retained. -/
def State.update (state : State n) (index : Fin n) (localState : LocalState) : State n :=
  { state with nodes := fun other => if other = index then localState else state.nodes other }

/-- Reuse the runtime's merge operation. A successful storage operation precedes
publication; failed storage and offline nodes leave both copies unchanged. -/
def LocalState.commit (before : LocalState) (incoming : List Participant) (saved : Bool) : LocalState :=
  match before.memory with
  | none => before
  | some node =>
      if saved then
        let updated := node.mergeRegistry incoming
        { memory := some updated, saved := updated.registry }
      else before

/-- Execute one modeled operation. Delivery at any queue index permits arbitrary
ordering. Lost or failed deliveries can be retried by sending another snapshot. -/
def step (state : State n) (action : Action n) : State n :=
  match action with
  | .register index participant saved =>
      state.update index ((state.nodes index).commit [participant] saved)
  | .send source recipient =>
      match (state.nodes source).memory with
      | none => state
      | some node =>
          { state with pending := state.pending ++ [{ recipient, participants := node.registry.participants }] }
  | .deliver messageIndex saved =>
      match state.pending[messageIndex]? with
      | none => state
      | some message =>
          { state.update message.recipient
              ((state.nodes message.recipient).commit message.participants saved) with
            pending := state.pending.eraseIdx messageIndex }
  | .drop messageIndex => { state with pending := state.pending.eraseIdx messageIndex }
  | .duplicate messageIndex =>
      match state.pending[messageIndex]? with
      | none => state
      | some message => { state with pending := state.pending ++ [message] }
  | .stop index => state.update index { state.nodes index with memory := none }
  | .restart index readSucceeded =>
      if readSucceeded then
        let saved := (state.nodes index).saved
        state.update index { memory := Node.restoreRegistry { value := index.val } saved.participants, saved }
      else state

/-- Run a finite schedule; every prefix is itself an execution. -/
def execute (state : State n) (actions : List (Action n)) : State n :=
  match actions with
  | [] => state
  | action :: remaining => execute (step state action) remaining

/-- `ℰ τ σ` executes schedule `τ` from state `σ`. Fixing `τ` gives the state
transformation `ℰ τ : State n → State n`. This is notation for `execute σ τ`. -/
scoped notation "ℰ" => (fun τ σ => execute σ τ)

/-- `σ ⟶[α] σ'` means that executing action `α` in state `σ` produces `σ'`. -/
scoped notation:50 σ:51 " ⟶[" α "] " σ':51 => step σ α = σ'

end VDSI.System
