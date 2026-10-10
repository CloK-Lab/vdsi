import VDSI

def main : IO Unit := do
  let alice : VDSI.Participant := { id := { value := 1 } }
  let bob : VDSI.Participant := { id := { value := 2 } }

  let some afterAlice := VDSI.register [] alice
    | throw (IO.userError "Registering Alice failed")
  IO.println s!"Register Alice: {reprStr afterAlice}"

  let some afterBob := VDSI.register afterAlice bob
    | throw (IO.userError "Registering Bob failed")
  IO.println s!"Register Bob: {reprStr afterBob}"

  if afterBob.map (fun participant => participant.id.value) != [1, 2] then
    throw (IO.userError "Registration did not retain both participants in order")

  if (VDSI.register afterBob alice).isSome then
    throw (IO.userError "Duplicate Alice ID was accepted")
  IO.println "Register Alice again: rejected (ID already registered)"

  if (VDSI.register afterBob bob).isSome then
    throw (IO.userError "Duplicate Bob ID was accepted")
  IO.println "Register Bob again: rejected (ID already registered)"
