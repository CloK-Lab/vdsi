import VDSI.Node.Lemmas

namespace VDSI.Node

/-- A successful restore preserves the exact decoded data and carries the
registry's uniqueness proof. Duplicate IDs are rejected. JSON and disk IO remain
outside this theorem and are checked by runtime tests. -/
theorem restoreRegistry_satisfies_spec (id : NodeId) (participants : List Participant) :
    RestoreRegistrySpec id participants (restoreRegistry id participants) := by
  unfold restoreRegistry
  split
  · exact ⟨rfl, rfl⟩
  · assumption

/-- Nodes starting with the same IDs finish with the same IDs when their requests
contain the same IDs, even if order and duplicate counts differ.
This assumes both request lists are processed; it does not guarantee delivery. -/
theorem same_requested_ids_produce_same_registered_ids
    (ν₁ ν₂ : Node)
    (leftRequests rightRequests : List Participant)
    (sameInitialIds : ν₁ ≈ ν₂)
    (sameRequestedIds : SameParticipantIds leftRequests rightRequests) :
    ν₁.processRegistrations leftRequests ≈ ν₂.processRegistrations rightRequests := by
  -- Both executions satisfy the specification, which guarantees agreement.
  exact registration_spec_guarantees_agreement leftRequests rightRequests ν₁ ν₂ _ _
    sameInitialIds sameRequestedIds
    (processRegistrations_satisfies_spec ν₁ leftRequests)
    (processRegistrations_satisfies_spec ν₂ rightRequests)

private theorem processing_preserves_node_id
    {before after : Node} {requests : List Participant}
    (meetsSpec : ProcessRegistrationsSpec before requests after) :
    after.id = before.id := by
  induction meetsSpec with
  | done => rfl
  | registered _ _ _ _ _ nodeIdIsPreserved _ _ remainingPreservesId =>
      exact remainingPreservesId.trans nodeIdIsPreserved
  | rejected _ _ _ _ _ _ remainingPreservesId => exact remainingPreservesId

/-- Every merge retains the local IDs and adds precisely the incoming IDs.
This is a property of the actual state transition used by the TCP runtime. -/
theorem mergeRegistry_satisfies_spec (before : Node) (incoming : List Participant) :
    MergeRegistrySpec before incoming (before.mergeRegistry incoming) := by
  have processingMeetsSpec := processRegistrations_satisfies_spec before incoming
  exact ⟨processing_preserves_node_id processingMeetsSpec,
    registration_spec_contains_exactly_initial_and_requested_ids
      before _ incoming processingMeetsSpec⟩

/-- Two nodes merging each other's snapshots obtain the same ID set, even if
their initial registries differ. This assumes delivery and no intervening updates;
it does not prove eventual delivery, process reliability, or socket correctness. -/
theorem merging_each_others_registry_agrees (ν₁ ν₂ : Node) :
    ν₁.mergeRegistry ν₂.registry.participants ≈ ν₂.mergeRegistry ν₁.registry.participants := by
  intro id
  rw [(mergeRegistry_satisfies_spec ν₁ ν₂.registry.participants).2 id,
      (mergeRegistry_satisfies_spec ν₂ ν₁.registry.participants).2 id]
  exact or_comm

end VDSI.Node
