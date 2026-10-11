import Tests.Registration
import Tests.Wire
import Tests.System

def main : IO Unit := do
  Tests.Registration.run
  IO.println "[PASS] Registration"
  Tests.Wire.run
  IO.println "[PASS] Wire"
  Tests.System.run
  IO.println "[PASS] System"
