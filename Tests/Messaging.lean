import VDSI.Node.Messaging
import Tests.Support

namespace Tests.Messaging

def run : IO Unit := do
  let alice : VDSI.Participant := { id := { value := 1 } }
  let bob : VDSI.Participant := { id := { value := 2 } }
  let nodeA := VDSI.Node.init { value := 1 }
  let nodeB := VDSI.Node.init { value := 2 }
  let nodeC := VDSI.Node.init { value := 3 }
  check (nodeA.registrationMessage nodeB.id alice.id).isNone
    "A message was prepared for an unregistered participant"

  let registeredA := nodeA.processRegistrations [alice, bob]
  let some aliceMessage := registeredA.registrationMessage nodeB.id alice.id
    | throw (IO.userError "Preparing Alice's message failed")
  let some bobMessage := registeredA.registrationMessage nodeB.id bob.id
    | throw (IO.userError "Preparing Bob's message failed")
  check (aliceMessage.sender == nodeA.id && aliceMessage.recipient == nodeB.id)
    "The message has incorrect routing information"
  check nodeB.registry.participants.isEmpty "Node B changed before delivery"

  -- Deliver Bob first, then Alice, then Alice again.
  let afterBob := nodeB.receiveRegistration bobMessage
  check (afterBob.registry.participants.map (fun p => p.id.value) == [2])
    "Receiving Bob's message registered the wrong participant"
  let afterAlice := afterBob.receiveRegistration aliceMessage
  let afterRepeatedAlice := afterAlice.receiveRegistration aliceMessage
  check (afterRepeatedAlice.registry.participants.map (fun p => p.id.value) == [2, 1])
    "Delivery lost an existing participant or introduced a duplicate"
  check (afterRepeatedAlice.id == nodeB.id) "Receiving a message changed the recipient's ID"
  check ((afterRepeatedAlice.registry.findParticipant alice.id).map (fun p => p.id.value) == some 1)
    "The delivered participant cannot be found"

  -- A message addressed to B must not register anyone on C.
  let wrongRecipient := nodeC.receiveRegistration aliceMessage
  check (wrongRecipient.id == nodeC.id && wrongRecipient.registry.participants.isEmpty)
    "A message addressed to another node changed this node"

end Tests.Messaging
