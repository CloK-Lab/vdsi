import VDSI.Network.Model
import VDSI.Node.Messaging

namespace VDSI.Network

/-- Start with no messages in transit. -/
def empty : Network := {}

/-- Place a message at the end of the queue, without delivering it. -/
def send (network : Network) (message : RegistrationMessage) : Network :=
  { pending := network.pending ++ [message] }

/-- Deliver the first queued message to its recipient and remove it from the queue.
Return `none` if the queue is empty or the supplied node is not its recipient.
On failure, the caller retains the original network and node. -/
def deliverNext (network : Network) (recipient : Node) : Option (Network × Node) :=
  match network.pending with
  | [] => none
  | message :: remaining =>
      if message.recipient = recipient.id then
        some ({ pending := remaining }, recipient.receiveRegistration message)
      else
        none

end VDSI.Network
