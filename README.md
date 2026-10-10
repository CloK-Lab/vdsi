# ν-DSI

*Verified Decentralized Superintelligence with Digital Tokenomics*

ν-DSI studies human-agent coordination and resource allocation through digital
tokenomics, using formal models, specifications, executable code, and proofs in
Lean.

## This branch

`feature/participant-model` starts the model again from its basic definitions.
It currently contains the Lean build setup and documentation tools. No
participants, accounts, wallets, ledger rules, or payment operations have been
defined in this version.

The previous code, proofs, notes, and reference tools are preserved at
[commit 43f2620](https://github.com/CloK-Lab/vdsi/tree/43f26201474a144b68924d2b485a0e3fd857c483),
also named `archive/pre-participant-model-20261010`. They can be consulted
without importing their definitions into this branch.

## Files

| File | Purpose |
| --- | --- |
| `VDSI.lean` | Library entry point; no domain definitions yet |
| `Main.lean` | Startup check for the Lean executable |
| `scripts/Audit.lean` | Axiom audit entry point; no public theorems yet |
| `lakefile.toml`, `lean-toolchain` | Build configuration and pinned Lean version |
| `docs/`, `tools/` | Documentation, renderer, and authoring tools |

Add source files only as a concrete definition, operation, or property needs
them. See [Contributing](CONTRIBUTING.md) and the
[current architecture status](docs/ARCHITECTURE.md).

## Run

```sh
lake build
lake exe demo
lake env lean scripts/Audit.lean
```

The demo currently prints a startup message. A successful build checks the
project setup; there are no model properties to verify yet.

For documentation, run `npm ci` once, then `npm run build` or `npm run dev`.
See the [notebook guide](docs/README.md). This branch's local overview describes
the restart; the [published notebook](https://www.clok.tech/docs/give-and-take)
continues to follow the main branch.

Licensed under [Apache-2.0](LICENSE).
