import VDSI.Identity.Model

namespace VDSI.Identity

/-- Policy acceptance, conditional on the supplied verifier's result.
The widths follow the Ed25519 encoding sizes; widths alone do not validate keys. -/
def ValidRegistration (network : String) (verify : Verifier)
    (record : Registration) : Prop :=
  record.statement.domain = "vdsi.identity.register" ∧
  record.statement.version = 1 ∧
  record.statement.network = network ∧
  record.statement.publicKey.bytes.length = 32 ∧
  record.signature.length = 64 ∧
  verify record.statement record.signature = true

instance (network : String) (verify : Verifier) (record : Registration) :
    Decidable (ValidRegistration network verify record) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _))

/-- Every stored record passes the same policy; each full key occurs once. -/
def RegistryInvariant (network : String) (verify : Verifier) (records : Registry) : Prop :=
  (∀ record ∈ records, ValidRegistration network verify record) ∧
  (records.map (fun record => record.statement.publicKey)).Nodup

end VDSI.Identity
