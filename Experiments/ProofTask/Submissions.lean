import Experiments.ProofTask.Model
import Experiments.ProofTask.Goals

namespace Experiments.ProofTask

def aliceTask : Task := {
  id := 1
  requester := { value := 1 }
  provider := { value := 2 }
  goal := { moduleName := `Experiments.ProofTask.Goals, declarationName := ``ZeroAdd }
}

/-- Simulate Bob supplying the proof term `Nat.zero_add` from Lean's standard library.
This is a prewritten submission, not a live AI prover or a proof-search implementation. -/
def validSubmission : Submission := {
  taskId := 1
  requester := { value := 1 }
  provider := { value := 2 }
  proof := Lean.mkConst ``Nat.zero_add
}

/-- A valid proof of a different statement: `n + 0 = n` instead of `0 + n = n`. -/
def wrongStatement : Submission :=
  { validSubmission with proof := Lean.mkConst ``Nat.add_zero }

/-- Untrusted expression data for a rejection test, not an admitted project theorem. -/
def sorrySubmission : Submission := {
  validSubmission with
  proof := Lean.mkApp2 (Lean.mkConst ``sorryAx [.zero])
    (Lean.mkConst ``ZeroAdd) (Lean.mkConst ``Bool.false)
}

end Experiments.ProofTask
