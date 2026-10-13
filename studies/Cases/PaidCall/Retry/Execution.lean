import VDSI.Cases.PaidCall.Execution
import VDSI.Cases.PaidCall.Retry.Model

namespace VDSI.Cases.PaidCall.Retry

/-- Accept the fixed approved terms, or leave state unchanged. Cached retries
only enqueue the saved receipt. A first payment uses the existing accounting
interpreter, atomically saving both its result and the echo receipt.
-/
def request (approved : Call) (s : State) (supplied : Call) : State :=
  if supplied = approved then
    match s.saved with
    | some receipt => { s with pending := some receipt }
    | none =>
        match PaidCall.run s.funds [.reserve approved.price, .settle] with
        | none => s
        | some funds =>
            let receipt := receiptFor approved
            { s with funds, saved := some receipt, pending := some receipt,
                     commits := s.commits + 1 }
  else s

/-- Reply loss and delivery are separate from committing the payment.
All calls come from the same already authenticated client. Actions are serialized.
-/
def execute (approved : Call) (s : State) : Action → State
  | .request supplied => request approved s supplied
  | .dropReply => { s with pending := none }
  | .deliverReply =>
      match s.pending with
      | none => s
      | some receipt => { s with pending := none, received := some receipt }

def run (approved : Call) (s : State) : List Action → State
  | [] => s
  | action :: rest => run approved (execute approved s action) rest

end VDSI.Cases.PaidCall.Retry
