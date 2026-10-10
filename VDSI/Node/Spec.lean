import VDSI.Node.Message

namespace VDSI

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

/-- A message for this node follows the registration rules, including duplicate
rejection. A message for another node leaves the entire local node unchanged. -/
def ReceiveRegistrationSpec
    (before : Node) (message : RegistrationMessage) (after : Node) : Prop :=
  if message.recipient = before.id then
    ProcessRegistrationsSpec before [message.participant] after
  else
    after = before

/-- Both lists contain the same participant IDs. Order and repetition do not matter. -/
def SameParticipantIds (left right : List Participant) : Prop :=
  ∀ id, IdIsRegistered id left ↔ IdIsRegistered id right

/-- Nodes starting with the same IDs must finish with the same IDs if their
request lists contain the same IDs. Request order and duplicate counts may differ.
This compares processed requests; it does not guarantee message delivery. -/
def RegistrationAgreementSpec
    (leftRequests rightRequests : List Participant)
    (leftBefore rightBefore leftAfter rightAfter : Node) : Prop :=
  SameParticipantIds leftBefore.registry.participants rightBefore.registry.participants →
  SameParticipantIds leftRequests rightRequests →
  ProcessRegistrationsSpec leftBefore leftRequests leftAfter →
  ProcessRegistrationsSpec rightBefore rightRequests rightAfter →
  SameParticipantIds leftAfter.registry.participants rightAfter.registry.participants

end VDSI
