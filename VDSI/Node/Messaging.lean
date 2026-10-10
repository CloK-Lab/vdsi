import VDSI.Node.Message

namespace VDSI.Node

/-- Prepare a message for a participant already registered on this node.
Return `none` if the participant ID is absent. Delivery is performed separately. -/
def registrationMessage (sender : Node) (recipient : NodeId) (id : ParticipantId) :
    Option RegistrationMessage := do
  let participant ← sender.registry.findParticipant id
  return { sender := sender.id, recipient, participant }

/-- Receive one registration message locally. Messages addressed to another node
are ignored. A duplicate participant ID leaves the registry unchanged. -/
def receiveRegistration (node : Node) (message : RegistrationMessage) : Node :=
  if message.recipient = node.id then
    node.processRegistrations [message.participant]
  else
    node

end VDSI.Node
