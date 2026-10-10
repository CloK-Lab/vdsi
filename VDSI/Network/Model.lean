import VDSI.Node.Message

namespace VDSI

/-- A local simulation of messages waiting for delivery, in FIFO order.
Nodes are kept separately; enqueuing a message does not update its recipient. -/
structure Network where
  pending : List RegistrationMessage := []

end VDSI
