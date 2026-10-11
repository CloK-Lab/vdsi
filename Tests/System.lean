import VDSI.System.Execution
import Tests.Support

namespace Tests.System

open VDSI VDSI.System

def run : IO Unit := do
  let a : Fin 3 := 0
  let b : Fin 3 := 1
  let c : Fin 3 := 2
  let alice : Participant := { id := { value := 1 } }
  let bob : Participant := { id := { value := 2 } }
  let savedIds := fun (state : State 3) index =>
    (state.nodes index).saved.participants.map (fun p => p.id.value)

  -- Sending captures the current registry and leaves recipients unchanged.
  let registered := execute (initial 3) [.register a alice true]
  let noMessage := step registered (.deliver 0 true)
  check (savedIds noMessage a == [1] && savedIds noMessage b == [] &&
      savedIds noMessage c == [] && noMessage.pending.isEmpty)
    "An empty queue changed a registry or produced a message"
  let queued := execute noMessage [
    .send a b, .duplicate 0, .register a bob true, .send a b]
  check (savedIds queued a == [1, 2] && savedIds queued b == [] &&
      savedIds queued c == [] && queued.pending.length == 3)
    "Sending updated another node before delivery or lost a queued snapshot"
  let invalidDelivery := step queued (.deliver 3 true)
  check (savedIds invalidDelivery a == [1, 2] && savedIds invalidDelivery b == [] &&
      savedIds invalidDelivery c == [] && invalidDelivery.pending.length == 3)
    "An out-of-range delivery changed a registry or consumed a snapshot"

  -- Each delivery consumes one snapshot and updates only its recipient.
  let first := step invalidDelivery (.deliver 0 true)
  check (savedIds first a == [1, 2] && savedIds first b == [1] &&
      savedIds first c == [] && first.pending.length == 2)
    "Delivery changed another node or failed to preserve the snapshot's contents"
  let repeated := step first (.deliver 0 true)
  check (savedIds repeated b == [1] && repeated.pending.length == 1)
    "Repeated delivery introduced a duplicate or consumed another snapshot"
  let delivered := step repeated (.deliver 0 true)
  check (savedIds delivered a == [1, 2] && savedIds delivered b == [1, 2] &&
      savedIds delivered c == [] && delivered.pending.isEmpty)
    "Later delivery lost a participant or updated a node other than the recipient"
  for index in [a, b, c] do
    let some node := (delivered.nodes index).memory
      | throw (IO.userError "Delivery stopped an online node")
    check (node.id.value == index.val) "Delivery changed a node's ID"
    check (node.registry.participants.map (fun p => p.id.value) == savedIds delivered index)
      "Delivery published a registry different from the saved snapshot"
  let exhausted := step delivered (.deliver 0 true)
  check (savedIds exhausted a == [1, 2] && savedIds exhausted b == [1, 2] &&
      savedIds exhausted c == [] && exhausted.pending.isEmpty)
    "An exhausted queue changed a registry or delivered another snapshot"

  -- Registrations on separate nodes do not become visible remotely at once.
  let separate := execute (initial 3) [.register a alice true, .register b bob true]
  check (savedIds separate a == [1] && savedIds separate b == [2])
    "A local registration changed a remote registry without delivery"

  -- Deliver the second snapshot first, then duplicate and lose the first.
  -- Failed storage must leave B's old registry intact; a fresh exchange retries.
  let failed := execute separate [
    .send a b, .send b a, .deliver 1 true,
    .duplicate 0, .drop 0, .deliver 0 false]
  check (savedIds failed a == [1, 2] && savedIds failed b == [2])
    "Reordering lost a registration or failed storage published an update"
  let synced := execute failed [.send a b, .duplicate 0, .deliver 1 true, .deliver 0 true]
  check (savedIds synced a == [1, 2] && savedIds synced b == [2, 1] && synced.pending.isEmpty)
    "Retries and duplicates did not converge without losing either registration"

  -- Both nodes stop. Recovery comes from local saved state, with no peer online.
  let stopped := execute synced [.stop a, .stop b, .register a bob true]
  check ((stopped.nodes a).memory.isNone && (stopped.nodes b).memory.isNone)
    "An offline node accepted an operation"
  let partiallyRecovered := execute stopped [.restart a true, .restart b false]
  check ((partiallyRecovered.nodes b).memory.isNone && savedIds partiallyRecovered b == [2, 1])
    "Failed recovery changed the saved state or brought the node online"
  let recovered := execute partiallyRecovered [.restart b true]
  for index in [a, b] do
    let some node := (recovered.nodes index).memory
      | throw (IO.userError "Successful recovery left a node offline")
    for id in [alice.id, bob.id] do
      let some participant := node.registry.findParticipant id
        | throw (IO.userError "Recovery lost a previously saved participant")
      check (participant.id == id) "Recovered lookup returned the wrong participant"

end Tests.System
