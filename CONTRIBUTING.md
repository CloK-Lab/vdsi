# Contributing

ν-DSI grows through shared study. Work through one modeling question at a time,
with changes small enough to read and explain together. Use English for
documentation and code comments.

## Developing the model

The model develops from basic definitions. The core library currently covers
participant registration, the collision probability of uniformly sampled IDs,
node operations, and a system model of snapshot delivery and recovery. The TCP
and storage runtime lives in `VDSI/Node/Runtime/`; task experiments live separately
in `Experiments/`.
The previous implementation and notes are preserved at
[commit 43f2620](https://github.com/CloK-Lab/vdsi/tree/43f26201474a144b68924d2b485a0e3fd857c483).
Their reading notes and source excerpts are retained in `studies/`; see its
[source snapshot guide](studies/README.md). Consult them as references; introduce
a previous definition only after its meaning and assumptions have been
considered for the new model. Rebuilding the runtime does not retire the
notebook's accumulated explanations or change its overall research scope.

Agree on the meaning of one concept before implementing it. Add only the
definitions and concrete examples needed to explain that concept. When adding
an operation, state its inputs, units, rejection behavior, and assumptions.
Keep definitions, specifications, execution, and verification separate, creating
files as needed rather than preparing empty modules.

Tests, experiments, and proofs must use the same executable definitions. Keep IO at the
boundary, and do not make execution depend on verification. Extract shared
abstractions when concrete cases need them.

## References and proof boundaries

Implement the project's own runtime rules in Lean. External chains, issued
currencies, hosted payment services, and SDKs are reference material. Restored
reference models must remain distinct from the native implementation.

A comparison needs a common specification, input and observation mappings, and
explicit assumptions. Shared invariants alone do not establish behavioral
equivalence. Proofs about a Lean reference model do not establish conformance
of a deployed external system.

Preserve explicit units and source versions. Distinguish authorization,
execution, service quality, incentives, asset backing, and chain settlement.
State compiler, runtime, cryptographic, and IO assumptions where relevant.
Do not introduce `sorry`, `admit`, custom axioms, or `native_decide`.
Add each new public theorem to `scripts/Audit.lean`.

## Documentation and checks

Explain a model in a `Note.mdx` beside its source. Include Lean declarations
from their files rather than copying them. Follow the
[notebook guide](docs/README.md) and [diagram style](docs/DIAGRAMS.md).
Keep the README and [architecture status](docs/ARCHITECTURE.md) consistent
with the code that actually exists.

Run:

```sh
./scripts/check.sh
```

This builds the core library and node executable, runs the Lean tests and a
two-process TCP test, and audits theorem assumptions. The process test requires
Python 3 and permission to use loopback sockets. Run `lake exe proof-experiment` separately when changing that
experiment; its checks are included in the experiment command.

Keep the Lean version pinned and add dependencies only when a concrete case
needs them. Export core definitions and proofs through `VDSI.lean`. Core tests
belong in `Tests/`; experiment definitions, submissions, and checks belong in
`Experiments/`. The core library and tests must not import experiment modules.

For documentation changes, run `npm run build` and inspect the affected pages
locally, including navigation, excerpts, and phone-width layout.
