namespace Experiments.ProofTask

/-- The proposition supplied by the requester in the local proof experiment. -/
def ZeroAdd : Prop := ∀ n : Nat, 0 + n = n

/-- A second task for checking that the verifier follows the requester's chosen goal. -/
def AddZero : Prop := ∀ n : Nat, n + 0 = n

end Experiments.ProofTask
