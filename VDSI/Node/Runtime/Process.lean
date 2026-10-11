import Std.Async.TCP
import Std.Async.Timer
import Std.Sync.Mutex
import VDSI.Node
import VDSI.Node.Runtime.Wire
import VDSI.Node.Runtime.Storage

namespace VDSI.Node.Runtime

open Std.Async

private def address (port : UInt16) : Std.Net.SocketAddress :=
  .v4 { addr := .ofParts 127 0 0 1, port }

private def snapshot (state : Std.Mutex Node) : IO (List Participant) :=
  state.atomically do return (← get).registry.participants

/-- Serialize local and peer updates through the same verified merge operation.
Save changed state before publishing it in memory or replying to the caller.
No lock is held while waiting for the network. -/
private def merge (state : Std.Mutex Node) (incoming : List Participant) : IO (List Participant) :=
  state.atomically do
    let before ← get
    let updated := before.mergeRegistry incoming
    -- This grow-only registry changes exactly when a new ID is added.
    if updated.registry.participants.length != before.registry.participants.length then
      try Storage.save updated catch error =>
        IO.eprintln s!"{error}"
        throw error
    set updated
    return updated.registry.participants

/-- One snapshot per connection, terminated by TCP write shutdown. Accumulate
fragmented reads, limit the frame to 64 KiB, and time out an idle read after 2 s. -/
private def receiveSnapshot (socket : TCP.Socket.Client) : IO (List Participant) := do
  let mut bytes := ByteArray.empty
  repeat
    if ← IO.checkCanceled then throw (IO.userError "node is stopping")
    let chunk ← (do
      let timeout ← Selector.sleep 2000
      Selectable.one #[
        .case (socket.recvSelector 4096) (fun value => pure value),
        .case timeout (fun _ => throw (IO.userError "peer read timed out"))
      ]).block
    match chunk with
    | none => break
    | some data =>
        if bytes.size + data.size > 65536 then
          throw (IO.userError "snapshot exceeds 64 KiB")
        bytes := bytes ++ data
  let some text := String.fromUTF8? bytes | throw (IO.userError "invalid UTF-8 snapshot")
  match Wire.decode text with
  | .ok participants => return participants
  | .error message => throw (IO.userError message)

private def sendSnapshot (socket : TCP.Socket.Client) (participants : List Participant) : IO Unit := do
  let bytes := (Wire.encode participants).toUTF8
  if bytes.size > 65536 then throw (IO.userError "snapshot exceeds 64 KiB")
  (socket.send bytes).block
  socket.shutdown.block

private def serve (server : TCP.Socket.Server) (state : Std.Mutex Node) : IO Unit := do
  repeat
    if ← IO.checkCanceled then break
    let socket? ← (do
      let timeout ← Selector.sleep 500
      Selectable.one #[
        .case server.acceptSelector (fun socket => pure (some socket)),
        .case timeout (fun _ => pure none)
      ]).block
    let some socket := socket? | continue
    try
      let incoming ← receiveSnapshot socket
      let updated ← merge state incoming
      sendSnapshot socket updated
    catch error =>
      IO.eprintln s!"Rejected peer exchange: {error}"

private def exchange (state : Std.Mutex Node) (port : UInt16) : IO Unit := do
  let outgoing ← snapshot state
  let socket ← TCP.Socket.Client.mk
  (socket.connect (address port)).block
  sendSnapshot socket outgoing
  let incoming ← receiveSnapshot socket
  discard <| merge state incoming

/-- Periodic exchanges retry offline peers and also carry registrations learned
from other peers. This is a local, unauthenticated grow-only registry prototype. -/
private def synchronize (state : Std.Mutex Node) (peers : List UInt16) : IO Unit := do
  repeat
    if ← IO.checkCanceled then break
    for port in peers do
      if ← IO.checkCanceled then break
      try exchange state port catch _ => pure ()
    IO.sleep 500

private def showState (state : Std.Mutex Node) : IO Unit := do
  let node ← state.atomically get
  let text := (Lean.Json.mkObj [
    ("node", Lean.toJson node.id.value),
    ("participants", Lean.toJson (node.registry.participants.map (fun p => p.id.value)))
  ]).compress
  let stdout ← IO.getStdout
  stdout.putStrLn text
  stdout.flush

/-- Run one independent node process on loopback, restoring its local snapshot.
Standard input accepts `register ID`, `show`, and `quit`; peers exchange snapshots
automatically. Authentication and consensus are not provided. The Lean runtime,
JSON codec, filesystem, OS sockets, and thread scheduling are trusted here. -/
def run (id : NodeId) (port : UInt16) (peers : List UInt16) : IO Unit := do
  let state ← Std.Mutex.new (← Storage.load id)
  let server ← TCP.Socket.Server.mk
  server.bind (address port)
  server.listen 32
  let bound ← server.getSockName
  let actualPort := match bound with | .v4 addr => addr.port | .v6 addr => addr.port
  let listener ← IO.asTask (serve server state) Task.Priority.dedicated
  let synchronizer ← IO.asTask (synchronize state peers) Task.Priority.dedicated
  let stdout ← IO.getStdout
  stdout.putStrLn (Lean.Json.mkObj [
    ("ready", Lean.toJson actualPort.toNat), ("node", Lean.toJson id.value)
  ]).compress
  stdout.flush
  let stdin ← IO.getStdin
  try
    repeat
      let line ← stdin.getLine
      if line.isEmpty then break
      match line.trimAscii.toString.splitOn " " with
      | ["quit"] => break
      | ["show"] => showState state
      | ["register", value] =>
          match value.toNat? with
          | none => IO.eprintln "Expected: register NATURAL_NUMBER"
          | some participantId =>
              discard <| merge state [{ id := { value := participantId } }]
              showState state
      | _ => IO.eprintln "Commands: register ID | show | quit"
  finally
    IO.cancel listener
    IO.cancel synchronizer
    IO.ofExcept listener.get
    IO.ofExcept synchronizer.get

end VDSI.Node.Runtime
