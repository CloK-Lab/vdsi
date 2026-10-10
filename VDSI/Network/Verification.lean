import VDSI.Network
import VDSI.Network.Spec
import VDSI.Node.Verification

namespace VDSI.Network

/-- Every delivery attempt obeys the queue and node-receiving specification.
This is a single-step guarantee; it does not guarantee eventual delivery. -/
theorem deliverNext_satisfies_spec (before : Network) (recipient : Node) :
    DeliverNextSpec before recipient (before.deliverNext recipient) := by
  unfold DeliverNextSpec deliverNext
  cases before.pending with
  | nil => rfl
  | cons message remaining =>
      by_cases addressedToRecipient : message.recipient = recipient.id
      · -- Remove one message and reuse the verified receiving operation.
        simp only [ite_eq_left addressedToRecipient]
        exact ⟨_, rfl, Node.receiveRegistration_satisfies_spec recipient message⟩
      · -- No update is returned when the next message belongs to another node.
        simp only [ite_eq_right addressedToRecipient]

end VDSI.Network
