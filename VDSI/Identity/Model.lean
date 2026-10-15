namespace VDSI.Identity

/-- The full candidate public-key encoding identifies a participant in this model.
Length and signature acceptance are checked before registration. This type alone
does not establish that the bytes encode a valid cryptographic key. -/
structure PublicKey where
  bytes : List UInt8
  deriving DecidableEq, Repr

/-- A registration authorizes publication of this key in one network only.
It grants no spending or task authority. There is no process ID in the statement. -/
structure Statement where
  domain : String
  version : Nat
  network : String
  publicKey : PublicKey
  deriving DecidableEq, Repr

structure Registration where
  statement : Statement
  signature : List UInt8
  deriving DecidableEq, Repr

/-- An explicit boundary: a verifier must bind the entire statement and its key.
No cryptographic implementation or soundness assumption is supplied here. -/
abbrev Verifier := Statement → List UInt8 → Bool

/-- A local list of signed records. The invariant is stated separately. -/
abbrev Registry := List Registration

/-- Construct version 1 of a registration statement, without generating a key. -/
def statementFor (network : String) (publicKey : PublicKey) : Statement :=
  { domain := "vdsi.identity.register", version := 1, network, publicKey }

end VDSI.Identity
