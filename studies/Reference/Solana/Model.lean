namespace VDSI.Reference.Solana

/-- Resolved account permissions, including the writable fee payer.
    Strings name accounts; address and message validation happen upstream. -/
structure AccountAccess where
  readOnly : List String
  writable : List String
  deriving DecidableEq, Repr

end VDSI.Reference.Solana
