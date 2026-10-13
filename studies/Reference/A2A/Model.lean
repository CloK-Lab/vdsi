namespace VDSI.Reference.A2A

/-- Selected fields of a2a.proto AgentInterface. -/
structure AgentInterface where
  url : String
  protocolBinding : String
  protocolVersion : String
  deriving DecidableEq, Repr

structure AgentSkill where
  id : String
  name : String
  description : String
  tags : List String
  deriving DecidableEq, Repr

/-- Capability-discovery projection; payment accounts are not card fields here. -/
structure AgentCard where
  name : String
  description : String
  version : String
  supportedInterfaces : List AgentInterface
  skills : List AgentSkill
  deriving DecidableEq, Repr

inductive TaskState where
  | unspecified | submitted | working | completed | failed | canceled
  | inputRequired | rejected | authRequired
  deriving DecidableEq, Repr

end VDSI.Reference.A2A
