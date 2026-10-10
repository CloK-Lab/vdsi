# Architecture status

The `feature/participant-model` branch contains a minimal Lean project and the
notebook tools. It has no domain definitions, operations, or public theorems.
The executable only checks that the project can start.

The previous source tree, models, proofs, and architecture proposal are preserved
at [commit 43f2620](https://github.com/CloK-Lab/vdsi/tree/43f26201474a144b68924d2b485a0e3fd857c483).
Their directory structure and modeling choices are not requirements for this
restart. The reference models remain available there for later comparisons.

## Developing the model

Begin by deciding what identifies a participant and what information belongs
to that participant. Record each decision with its definition and a concrete
example before adding another concept. Account ownership, wallet authority,
ledger state, and the behavior of a running node need their own definitions
when the model reaches them.

Create source directories only when they contain substantive code. Keep
definitions, specifications, executable operations, and proofs separate.
The demo and proofs must use the same operations.

Implement the project's runtime in Lean. External infrastructure can supply
reference designs and comparison cases. A common specification and explicit
observation mappings are required for claims about correspondence; no such
comparison is implemented in this branch.
