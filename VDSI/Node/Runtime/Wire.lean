import Lean.Data.Json
import VDSI.Participant

namespace VDSI.Node.Runtime.Wire

/-- A peer snapshot is a JSON array of natural-number participant IDs. -/
def encode (participants : List Participant) : String :=
  (Lean.toJson (participants.map (fun participant => participant.id.value))).compress

/-- Decode the whole snapshot before applying any registration. -/
def decode (text : String) : Except String (List Participant) := do
  let ids : List Nat ← Lean.fromJson? (← Lean.Json.parse text)
  return ids.map fun id => { id := { value := id } }

end VDSI.Node.Runtime.Wire
