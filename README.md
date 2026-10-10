# ν-DSI

*Verified Decentralized Superintelligence with Digital Tokenomics*

ν-DSI studies human-agent coordination and resource allocation through digital
tokenomics, using formal models, specifications, executable code, and proofs in
Lean.

## This branch

`feature/participant-model` starts the model again from its basic definitions.
It currently contains a Lean library for participant registration and local
node messaging, with specifications, proofs, and tests. Proof-task experiments
are separate from the core library. There is no standalone node service yet.

The previous code, proofs, notes, and reference tools are preserved at
[commit 43f2620](https://github.com/CloK-Lab/vdsi/tree/43f26201474a144b68924d2b485a0e3fd857c483),
also named `archive/pre-participant-model-20261010`. They can be consulted
without importing their definitions into this branch.

## Files

| File | Purpose |
| --- | --- |
| `VDSI.lean`, `VDSI/` | Core library: participants, registration, nodes, and messages |
| `Tests/` | Core regression tests |
| `Experiments/` | Optional experiments and their own checks |
| `scripts/check.sh` | Build, run core tests, and audit theorem assumptions |
| `scripts/Audit.lean` | Axiom dependency checks for public theorems |
| `lakefile.toml`, `lean-toolchain` | Build configuration and pinned Lean version |
| `docs/`, `tools/` | Documentation, renderer, and authoring tools |

Add source files only as a concrete definition, operation, or property needs
them. See [Contributing](CONTRIBUTING.md) and the
[current architecture status](docs/ARCHITECTURE.md).

## Run

Run these commands from the repository root:

| Command | Purpose |
| --- | --- |
| `./scripts/check.sh` | Recommended after code changes: build the library and tests, run core tests, and audit theorem assumptions |
| `lake exe tests` | Run only the core tests for registration, messaging, and the local network |
| `lake exe proof-experiment` | Run the separate proof-task experiment, including its own regression checks |

The system check does not build or run experiments. The proof experiment uses
prewritten submissions and real Lean kernel checking; it does not call an AI
prover. There is no `lake exe vdsi` startup command: tests and experiments import
the core library directly.

For documentation, run `npm ci` once, then `npm run build` or `npm run dev`.
See the [notebook guide](docs/README.md). This branch's local overview describes
the restart; the [published notebook](https://www.clok.tech/docs/give-and-take)
continues to follow the main branch.

Licensed under [Apache-2.0](LICENSE).
