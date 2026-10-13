import VDSI.Reference.A2A.Model

namespace VDSI.Reference.A2A

/-- Respect the card's preference order among interfaces this client supports. -/
def selectInterface (card : AgentCard) (binding version : String) : Option AgentInterface :=
  card.supportedInterfaces.find? fun endpoint =>
    endpoint.protocolBinding == binding && endpoint.protocolVersion == version

def isTerminal : TaskState → Bool
  | .completed | .failed | .canceled | .rejected => true
  | _ => false

end VDSI.Reference.A2A
