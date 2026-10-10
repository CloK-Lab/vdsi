import Lean
import Experiments.ProofTask.Model

namespace Experiments.ProofTask

/-- Check a candidate against the requester's goal using Lean's kernel, then collect
its transitive axiom dependencies. The current policy allows no axioms, including `sorryAx`.

The pinned Lean kernel and locally built imports are trusted. A fresh environment
is used for each attempt; the provider cannot add declarations or change the goal.
This function checks a proof term; it does not run tactics or search for a proof. -/
def checkProof (goal : Goal) (proof : Lean.Expr) : IO Verdict := do
  Lean.initSearchPath (← Lean.findSysroot)
  let env ← Lean.importModules #[{ module := goal.moduleName }] {} (trustLevel := 0)
  let some goalInfo := env.find? goal.declarationName | return .invalidGoal
  if goalInfo.type != Lean.mkSort .zero || !goalInfo.levelParams.isEmpty then
    return .invalidGoal
  let declaration := Lean.Declaration.thmDecl {
    name := `Experiments.ProofTask.submittedProof
    levelParams := []
    type := Lean.mkConst goal.declarationName
    value := proof
  }
  -- Synchronous kernel checking, with a heartbeat and recursion-depth limit.
  match env.addDeclCore 1000000 1000 declaration none (doCheck := true) with
  | .error _ => return .kernelRejected
  | .ok checkedEnv =>
      let axioms ← (Lean.collectAxioms `Experiments.ProofTask.submittedProof : Lean.CoreM _).toIO'
        { fileName := "<proof submission>", fileMap := default } { env := checkedEnv }
      return if axioms.isEmpty then .accepted else .forbiddenAxioms axioms

/-- Complete a matching task only after proof checking and the axiom policy both pass.
Rejected attempts leave the task waiting; completed tasks ignore later submissions.
IO failures propagate as errors and do not return a completed task. -/
def Task.receive (task : Task) (submission : Submission) : IO (Task × Verdict) := do
  if task.status == .completed then
    return (task, .alreadyCompleted)
  if submission.taskId != task.id || submission.requester != task.requester ||
      submission.provider != task.provider then
    return (task, .wrongTask)
  let verdict ← checkProof task.goal submission.proof
  let updated := if verdict == .accepted then { task with status := .completed } else task
  return (updated, verdict)

end Experiments.ProofTask
