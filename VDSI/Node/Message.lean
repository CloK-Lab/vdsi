import VDSI.Node

namespace VDSI

/-- A registration forwarded between simulated nodes.
The sender field records its origin; it is not an authenticated identity. -/
structure RegistrationMessage where
  sender : NodeId
  recipient : NodeId
  participant : Participant
  deriving Repr

end VDSI
