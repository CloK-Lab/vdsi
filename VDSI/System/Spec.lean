import VDSI.System.Model

namespace VDSI.System

/- Symbol convention: `σ` is a system state, `ν` a node, `π` a participant,
`α` an action, and `τ` a schedule or trace. Node indices use `i` and `j`;
participant IDs use `id`. The type names and operation names remain explicit. -/

/-- At each visible operation boundary, an online node has its configured ID
and exactly the registry saved locally. Offline nodes need not answer queries. -/
def LocalStateSpec (i : Fin n) (localState : LocalState) : Prop :=
  ∀ ν, localState.memory = some ν →
    ν.id = { value := i.val } ∧ ν.registry.participants = localState.saved.participants

def Consistent (σ : State n) : Prop :=
  ∀ i, LocalStateSpec i (σ.nodes i)

/-- A participant is saved locally and is returned by lookup whenever the node
is online. Both stored and live registries carry the no-duplicate-ID invariant. -/
def SavedAndQueryable (σ : State n) (i : Fin n) (id : ParticipantId) : Prop :=
  IdIsRegistered id (σ.nodes i).saved.participants ∧
  ∀ ν, (σ.nodes i).memory = some ν →
    ∃ π, ν.registry.findParticipant id = some π ∧ π.id = id

/-- Requirements after any finite execution: node state matches saved state,
IDs remain unique, and every previously saved ID remains saved and queryable
when online. This concerns the atomic model, not an IO refinement proof. -/
def SafetySpec (σ σ' : State n) : Prop :=
  Consistent σ' ∧
  (∀ i, UniqueIds (σ'.nodes i).saved.participants) ∧
  ∀ i id, IdIsRegistered id (σ.nodes i).saved.participants →
    SavedAndQueryable σ' i id

/-- The liveness target for an infinite execution: any saved ID eventually
reaches every node, which can then answer a local lookup. This is a target, not
a proved property. A proof needs a valid execution with sufficient connectivity,
fair retries, successful storage, and recovery of the target nodes. Safety alone
does not imply it; a schedule that drops every message is a counterexample. -/
def PropagationSpec (τ : Nat → State n) : Prop :=
  ∀ time source id, IdIsRegistered id ((τ time).nodes source).saved.participants →
    ∀ target, ∃ later, time ≤ later ∧
      ((τ later).nodes target).memory.isSome = true ∧
      SavedAndQueryable (τ later) target id

end VDSI.System
