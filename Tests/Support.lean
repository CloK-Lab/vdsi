namespace Tests

/-- Fail the test executable with a descriptive error if a check is false. -/
def check (condition : Bool) (message : String) : IO Unit := do
  unless condition do
    throw (IO.userError message)

end Tests
