import VDSI.Network.Model
import VDSI.Node.Spec

namespace VDSI

/-- Delivery consumes exactly the first queued message and applies the node's
receiving rules. An empty queue or a different recipient produces no update. -/
def DeliverNextSpec
    (before : Network) (recipient : Node) (result : Option (Network × Node)) : Prop :=
  match before.pending with
  | [] => result = none
  | message :: remaining =>
      if message.recipient = recipient.id then
        ∃ updatedRecipient,
          result = some ({ pending := remaining }, updatedRecipient) ∧
          ReceiveRegistrationSpec recipient message updatedRecipient
      else
        result = none

end VDSI
