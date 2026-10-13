import VDSI.Reference.Solana.Execution

namespace VDSI.Reference.Solana

/-- Each sender also pays its own transaction fee. -/
def aliceToBob : AccountAccess :=
  { readOnly := ["SystemProgram"]
    writable := ["Alice", "Bob"] }

def carolToDave : AccountAccess :=
  { readOnly := ["SystemProgram"]
    writable := ["Carol", "Dave"] }

/-- A shared fee payer adds a writable account to each access set. -/
def withSponsor (access : AccountAccess) : AccountAccess :=
  { access with writable := "Sponsor" :: access.writable }

def paymentAccessExample : Bool × Bool :=
  (canRunTogether aliceToBob carolToDave,
   canRunTogether
     (withSponsor aliceToBob) (withSponsor carolToDave))

end VDSI.Reference.Solana
