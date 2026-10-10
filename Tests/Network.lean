import VDSI.Network
import Tests.Support

namespace Tests.Network

def run : IO Unit := do
  let alice : VDSI.Participant := { id := { value := 1 } }
  let bob : VDSI.Participant := { id := { value := 2 } }
  let nodeA := (VDSI.Node.init { value := 1 }).processRegistrations [alice, bob]
  let nodeB := VDSI.Node.init { value := 2 }
  let some aliceMessage := nodeA.registrationMessage nodeB.id alice.id
    | throw (IO.userError "Preparing Alice's message failed")
  let some bobMessage := nodeA.registrationMessage nodeB.id bob.id
    | throw (IO.userError "Preparing Bob's message failed")

  check (VDSI.Network.empty.deliverNext nodeB).isNone "An empty network delivered a message"
  let network := ((VDSI.Network.empty.send aliceMessage).send aliceMessage).send bobMessage
  check (network.pending.length == 3 && nodeB.registry.participants.isEmpty)
    "Sending did not retain pending messages until delivery"
  check (network.deliverNext nodeA).isNone "A message was delivered to the wrong recipient"

  let some (afterFirst, firstB) := network.deliverNext nodeB
    | throw (IO.userError "The first queued message could not be delivered")
  check (firstB.registry.participants.map (fun p => p.id.value) == [1] && afterFirst.pending.length == 2)
    "The first delivery did not process exactly the first message"

  let some (afterRepeat, repeatedB) := afterFirst.deliverNext firstB
    | throw (IO.userError "The repeated message could not be delivered")
  check (repeatedB.registry.participants.map (fun p => p.id.value) == [1] && afterRepeat.pending.length == 1)
    "Repeated delivery introduced a duplicate or consumed another message"

  let some (finished, finalB) := afterRepeat.deliverNext repeatedB
    | throw (IO.userError "Bob's message was blocked by the duplicate request")
  check (finalB.registry.participants.map (fun p => p.id.value) == [1, 2])
    "Later delivery did not preserve Alice and register Bob"
  check (finalB.id == nodeB.id && finished.pending.isEmpty)
    "Delivery changed the node ID or left a processed message queued"
  check (finished.deliverNext finalB).isNone "An exhausted queue delivered another message"

end Tests.Network
