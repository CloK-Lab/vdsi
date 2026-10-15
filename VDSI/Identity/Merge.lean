import VDSI.Identity.Execution

namespace VDSI.Identity

/-- Keep the local signed record when both registries contain its key. -/
def combineRecords (localRecords incoming : Registry) : Registry :=
  localRecords ++ incoming.filter (fun record =>
    !(localRecords.map (·.statement.publicKey)).contains record.statement.publicKey)

/-- All-or-nothing import. Validate both inputs before combining; validate the
candidate with the same recovery rule. Never accept a malformed known-key record
merely because its key is already present locally. -/
def mergeRegistry (network : String) (verify : Verifier)
    (localRecords incoming : Registry) : Option Registry := do
  let _ ← restoreRegistry network verify localRecords
  let _ ← restoreRegistry network verify incoming
  restoreRegistry network verify (combineRecords localRecords incoming)

end VDSI.Identity
