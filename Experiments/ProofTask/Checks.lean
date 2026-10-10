import Experiments.ProofTask.Execution
import Experiments.ProofTask.Submissions

namespace Experiments.ProofTask.Checks

open Experiments.ProofTask

/-- Fail this experiment if one of its regression checks does not hold. -/
private def check (condition : Bool) (message : String) : IO Unit := do
  unless condition do
    throw (IO.userError message)

def run : IO Unit := do
  let task := aliceTask
  let valid := validSubmission

  -- A real theorem about another statement must not satisfy Alice's task.
  let (afterWrong, wrongVerdict) ← task.receive wrongStatement
  check (wrongVerdict == .kernelRejected && afterWrong == task)
    "A proof of the wrong statement completed the task"

  -- `sorryAx` is accepted by the kernel as an axiom, so the separate policy must reject it.
  let (afterSorry, sorryVerdict) ← afterWrong.receive sorrySubmission
  check (sorryVerdict == .forbiddenAxioms #[``sorryAx] && afterSorry == task)
    "An admitted proof passed the axiom policy"

  -- The policy also rejects a logically valid use of an axiom other than `sorryAx`.
  let usingChoice := Lean.mkApp2 (Lean.mkConst ``Classical.choice [.zero])
    (Lean.mkConst ``ZeroAdd)
    (Lean.mkApp2 (Lean.mkConst ``Nonempty.intro [.zero]) (Lean.mkConst ``ZeroAdd) valid.proof)
  let choiceVerdict ← checkProof task.goal usingChoice
  check (choiceVerdict == .forbiddenAxioms #[``Classical.choice])
    "The no-axioms policy allowed Classical.choice"

  -- Ill-typed applications, unknown constants, and open terms are not proofs.
  for invalid in [Lean.mkApp valid.proof (Lean.mkSort .zero),
      Lean.mkConst `NoSuchProviderProof, Lean.mkBVar 0] do
    check ((← checkProof task.goal invalid) == .kernelRejected) "The kernel accepted an invalid proof term"

  -- The goal is supplied by the requester; it is not fixed inside the checker.
  let otherGoal := { task.goal with declarationName := ``AddZero }
  check ((← checkProof otherGoal wrongStatement.proof) == .accepted)
    "The verifier did not accept a proof of the second requested goal"
  check ((← checkProof otherGoal valid.proof) == .kernelRejected)
    "The verifier accepted a proof of the first goal for a different task"
  for invalidName in [`NoSuchGoal, ``Nat] do
    check ((← checkProof { task.goal with declarationName := invalidName } valid.proof) == .invalidGoal)
      "The verifier accepted a missing goal or a declaration that is not a proposition"

  let mismatched : List Submission := [
    { valid with taskId := 2 },
    { valid with requester := task.provider },
    { valid with provider := task.requester }
  ]
  for submission in mismatched do
    let (unchanged, verdict) ← task.receive submission
    check (unchanged == task && verdict == .wrongTask) "A submission for another task was accepted"

  -- Earlier rejections must not prevent a later valid proof from completing the task.
  let (completed, verdict) ← afterSorry.receive valid
  check (verdict == .accepted && completed == { task with status := .completed })
    "A valid axiom-free proof did not complete the task"

  -- Acceptance is based on kernel checking, not matching a known expression or theorem name.
  let anotherProof := Lean.mkLambda `n .default (Lean.mkConst ``Nat)
    (Lean.mkApp valid.proof (Lean.mkBVar 0))
  check ((← checkProof task.goal anotherProof) == .accepted) "A second valid proof term was rejected"

  for submission in [valid, wrongStatement, sorrySubmission] do
    let (unchanged, repeatedVerdict) ← completed.receive submission
    check (unchanged == completed && repeatedVerdict == .alreadyCompleted)
      "A later submission changed a completed task"

end Experiments.ProofTask.Checks
