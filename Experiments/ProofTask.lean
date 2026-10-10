import Experiments.ProofTask.Execution
import Experiments.ProofTask.Submissions
import Experiments.ProofTask.Checks

open Experiments.ProofTask

private def describeStatus : Status → String
  | .waiting => "waiting"
  | .completed => "completed"

private def describeVerdict : Verdict → String
  | .accepted => "accepted (kernel checked; no axioms)"
  | .kernelRejected => "rejected by kernel for the requested goal"
  | .invalidGoal => "rejected: goal must name a closed proposition"
  | .forbiddenAxioms names => s!"rejected: forbidden axioms {names}"
  | .wrongTask => "rejected: task identifiers do not match"
  | .alreadyCompleted => "ignored: task already completed"

/-- Alice checks prewritten proof submissions simulating Bob's replies.
This experiment runs the kernel checker, not an AI prover or proof-search procedure. -/
def main : IO Unit := do
  Checks.run
  IO.println "[PASS] Proof experiment checks"
  let task := aliceTask
  IO.println s!"Alice publishes task {task.id}: prove ∀ n : Nat, 0 + n = n"
  IO.println "Bob's replies are prewritten proof terms; Alice checks them locally."

  let (afterWrong, wrongVerdict) ← task.receive wrongStatement
  IO.println s!"Proof of a different statement: {describeVerdict wrongVerdict}; task={describeStatus afterWrong.status}"

  let (afterSorry, sorryVerdict) ← afterWrong.receive sorrySubmission
  IO.println s!"Proof using sorry: {describeVerdict sorryVerdict}; task={describeStatus afterSorry.status}"

  let (completed, validVerdict) ← afterSorry.receive validSubmission
  IO.println s!"Bob submits Nat.zero_add: {describeVerdict validVerdict}; task={describeStatus completed.status}"

  let (unchanged, repeatedVerdict) ← completed.receive validSubmission
  IO.println s!"Repeated submission: {describeVerdict repeatedVerdict}; task={describeStatus unchanged.status}"
