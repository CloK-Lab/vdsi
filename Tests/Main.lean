import Tests.Registration
import Tests.Messaging
import Tests.Network

def main : IO Unit := do
  Tests.Registration.run
  IO.println "[PASS] Registration"
  Tests.Messaging.run
  IO.println "[PASS] Messaging"
  Tests.Network.run
  IO.println "[PASS] Network"
