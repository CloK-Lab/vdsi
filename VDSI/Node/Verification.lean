import VDSI.Node.Lemmas
import VDSI.Node.Messaging

namespace VDSI.Node

/-- Nodes starting with the same IDs finish with the same IDs when their requests
contain the same IDs, even if order and duplicate counts differ.
This assumes both request lists are processed; it does not guarantee delivery. -/
theorem same_requested_ids_produce_same_registered_ids
    (left right : Node)
    (leftRequests rightRequests : List Participant)
    (sameInitialIds : SameParticipantIds left.registry.participants right.registry.participants)
    (sameRequestedIds : SameParticipantIds leftRequests rightRequests) :
    SameParticipantIds
      (left.processRegistrations leftRequests).registry.participants
      (right.processRegistrations rightRequests).registry.participants := by
  -- Both executions satisfy the specification, which guarantees agreement.
  exact registration_spec_guarantees_agreement leftRequests rightRequests left right _ _
    sameInitialIds sameRequestedIds
    (processRegistrations_satisfies_spec left leftRequests)
    (processRegistrations_satisfies_spec right rightRequests)

/-- Receiving any message obeys the routing and registration specification. -/
theorem receiveRegistration_satisfies_spec
    (before : Node) (message : RegistrationMessage) :
    ReceiveRegistrationSpec before message (before.receiveRegistration message) := by
  unfold ReceiveRegistrationSpec receiveRegistration
  split
  · -- A correctly addressed message reuses the verified registration processor.
    exact processRegistrations_satisfies_spec before [message.participant]
  · -- A message for another node makes no change.
    rfl

end VDSI.Node
