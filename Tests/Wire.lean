import VDSI.Node.Runtime.Wire
import Tests.Support

namespace Tests.Wire

def run : IO Unit := do
  let participants : List VDSI.Participant :=
    [{ id := { value := 0 } }, { id := { value := 18446744073709551616 } }]
  let .ok decoded := VDSI.Node.Runtime.Wire.decode (VDSI.Node.Runtime.Wire.encode participants)
    | throw (IO.userError "Snapshot round trip failed")
  check (decoded.map (fun p => p.id.value) == [0, 18446744073709551616])
    "The wire format truncated or changed participant IDs"
  for malformed in ["", "[1,", "[-1]", "[1.5]", "[\"1\"]", "{}", "[1] trailing"] do
    match VDSI.Node.Runtime.Wire.decode malformed with
    | .ok _ => throw (IO.userError s!"Accepted malformed snapshot: {malformed}")
    | .error _ => pure ()

end Tests.Wire
