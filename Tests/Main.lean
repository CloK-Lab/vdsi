import Tests.Registration
import Tests.Wire
import Tests.System
import Tests.IdGeneration

def main : IO Unit := do
  Tests.Registration.run
  IO.println "[PASS] Registration"
  Tests.Wire.run
  IO.println "[PASS] Wire"
  Tests.System.run
  IO.println "[PASS] System"
  Tests.IdGeneration.run
  IO.println "[PASS] ID generation model"
