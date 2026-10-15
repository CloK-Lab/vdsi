import VDSI.Identity.Spec

namespace VDSI.Identity

/-- Invalid records are rejected before duplicate detection. A valid replay
returns the unchanged registry; a new full public key appends its signed record.
The caller retains its old state on `none`. This is an atomic, local operation. -/
def register (network : String) (verify : Verifier) (records : Registry)
    (record : Registration) : Option Registry :=
  if ValidRegistration network verify record then
    if record.statement.publicKey ∈ records.map (fun entry => entry.statement.publicKey) then
      some records
    else
      some (records ++ [record])
  else
    none

/-- Restore the entire candidate snapshot or reject it. Duplicate keys are an
error, not silently normalized. Every record is rechecked with the current policy. -/
def restoreRegistry (network : String) (verify : Verifier)
    (records : Registry) : Option Registry :=
  if ∀ record ∈ records, ValidRegistration network verify record then
    if (records.map (fun record => record.statement.publicKey)).Nodup then some records else none
  else none

end VDSI.Identity
