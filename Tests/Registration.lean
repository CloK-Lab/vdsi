import VDSI.Node
import Tests.Support

namespace Tests.Registration

def run : IO Unit := do
  let alice : VDSI.Participant := { id := { value := 1 } }
  let bob : VDSI.Participant := { id := { value := 2 } }
  let empty := VDSI.Registry.empty
  check (empty.findParticipant alice.id).isNone "Empty registry returned a participant"

  let some afterAlice := empty.register alice
    | throw (IO.userError "Registering Alice failed")
  let some afterBob := afterAlice.register bob
    | throw (IO.userError "Registering Bob failed")
  check (afterBob.participants.map (fun p => p.id.value) == [1, 2])
    "Registration did not preserve both participants in order"
  check (afterBob.register alice).isNone "Duplicate Alice ID was accepted"
  check (afterBob.register bob).isNone "Duplicate Bob ID was accepted"
  check ((afterBob.findParticipant alice.id).map (fun p => p.id.value) == some 1)
    "Lookup did not return Alice"
  check (afterBob.findParticipant { value := 3 }).isNone "Lookup returned an absent ID"

  -- Reordering and repeating requests must not change which IDs are registered.
  let nodeA := VDSI.Node.init { value := 1 }
  let nodeB := VDSI.Node.init { value := 2 }
  let finalA := nodeA.processRegistrations [alice, alice, bob, bob]
  let finalB := nodeB.processRegistrations [bob, alice, bob]
  let idsA := finalA.registry.participants.map (fun p => p.id.value)
  let idsB := finalB.registry.participants.map (fun p => p.id.value)
  check (idsA == [1, 2]) "Repeated requests lost or duplicated a participant"
  check (idsA.all (fun id => idsB.contains id) && idsB.all (fun id => idsA.contains id))
    "Reordered requests registered different ID sets"
  check (idsB.length == 2) "Reordered requests introduced a duplicate"
  check (finalA.id == nodeA.id && finalB.id == nodeB.id) "Processing changed a node ID"

end Tests.Registration
