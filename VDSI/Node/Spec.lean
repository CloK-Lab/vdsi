import VDSI.Node

namespace VDSI

/-- Restoration keeps the supplied node ID and exact participant list when IDs
are unique; otherwise it rejects the list. This concerns decoded data, not disk IO. -/
def RestoreRegistrySpec (id : NodeId) (participants : List Participant)
    (result : Option Node) : Prop :=
  match result with
  | some restored => restored.id = id ∧ restored.registry.participants = participants
  | none => ¬ UniqueIds participants

/-- Requirements for processing registration requests in order.
Each item in the request list asks to register that participant.
A rejected request leaves the node unchanged; processing continues with the rest.
-/
inductive ProcessRegistrationsSpec : Node → List Participant → Node → Prop where
  /-- With no requests left, the final node is the current node. -/
  | done (node : Node) :
      ProcessRegistrationsSpec node [] node
  /-- A successful registration updates the registry, preserves the node ID,
  and is followed by processing the remaining requests. -/
  | registered
      (before next after : Node)
      (participant : Participant) (remaining : List Participant)
      (nodeIdIsPreserved : next.id = before.id)
      (registrationMeetsSpec : RegisterSpec before.registry.participants participant
        (some next.registry.participants))
      (remainingMeetsSpec : ProcessRegistrationsSpec next remaining after) :
      ProcessRegistrationsSpec before (participant :: remaining) after
  /-- A duplicate ID is rejected; the remaining requests use the unchanged node. -/
  | rejected
      (before after : Node)
      (participant : Participant) (remaining : List Participant)
      (rejectionMeetsSpec : RegisterSpec before.registry.participants participant none)
      (remainingMeetsSpec : ProcessRegistrationsSpec before remaining after) :
      ProcessRegistrationsSpec before (participant :: remaining) after

/-- Both lists contain the same participant IDs. Order and repetition do not matter. -/
def SameParticipantIds (left right : List Participant) : Prop :=
  ∀ id, IdIsRegistered id left ↔ IdIsRegistered id right

/-- Every participant ID in the left list also occurs in the right list. -/
def ParticipantIdsIncluded (left right : List Participant) : Prop :=
  ∀ id, IdIsRegistered id left → IdIsRegistered id right

/-- `ν₁ ≈ ν₂` compares registered participant ID sets only. Node identities,
list order, and any future participant fields are not compared. -/
scoped notation:50 ν₁:51 " ≈ " ν₂:51 =>
  SameParticipantIds (Registry.participants (Node.registry ν₁))
    (Registry.participants (Node.registry ν₂))

/-- `ν₁ ⊑ ν₂` means that every participant ID registered at `ν₁` is also registered
at `ν₂`. Neither symbol asserts delivery or agreement of other node state. -/
scoped notation:50 ν₁:51 " ⊑ " ν₂:51 =>
  ParticipantIdsIncluded (Registry.participants (Node.registry ν₁))
    (Registry.participants (Node.registry ν₂))

/-- Merging preserves the node's identity and produces exactly the union of the
local and incoming ID sets. Each resulting registry also carries `UniqueIds`. -/
def MergeRegistrySpec (before : Node) (incoming : List Participant) (after : Node) : Prop :=
  after.id = before.id ∧ ∀ id,
    IdIsRegistered id after.registry.participants ↔
      IdIsRegistered id before.registry.participants ∨ IdIsRegistered id incoming

/-- Nodes starting with the same IDs must finish with the same IDs if their
request lists contain the same IDs. Request order and duplicate counts may differ.
This compares processed requests; it does not guarantee message delivery. -/
def RegistrationAgreementSpec
    (leftRequests rightRequests : List Participant)
    (leftBefore rightBefore leftAfter rightAfter : Node) : Prop :=
  leftBefore ≈ rightBefore →
  SameParticipantIds leftRequests rightRequests →
  ProcessRegistrationsSpec leftBefore leftRequests leftAfter →
  ProcessRegistrationsSpec rightBefore rightRequests rightAfter →
  leftAfter ≈ rightAfter

end VDSI
