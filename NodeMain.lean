import VDSI.Node.Runtime.Process

private def parsePort (text : String) : IO UInt16 := do
  match text.toNat? with
  | some value =>
      if value ≤ 65535 then return value.toUInt16
      else throw (IO.userError "Port must be between 0 and 65535")
  | none => throw (IO.userError "Port must be a natural number")

def main (args : List String) : IO Unit := do
  match args with
  | idText :: portText :: peerTexts =>
      let some id := idText.toNat? | throw (IO.userError "Node ID must be a natural number")
      let port ← parsePort portText
      let peers ← peerTexts.mapM parsePort
      if peers.contains 0 then throw (IO.userError "Peer ports must be nonzero")
      VDSI.Node.Runtime.run { value := id } port peers
  | _ =>
      IO.println "Usage: lake exe node NODE_ID PORT [PEER_PORT ...]"
      IO.println "Loopback only. Commands: register ID | show | quit"
