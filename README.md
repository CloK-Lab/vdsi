# ν-DSI

*Verified Decentralized Superintelligence with Digital Tokenomics*

ν-DSI studies human-agent coordination and resource allocation through digital
tokenomics, using formal models, specifications, executable code, and proofs in
Lean.

## Current implementation

The executable prototype registers and looks up participant IDs across independent
node processes on one machine. Nodes keep their own registries, exchange snapshots
with configured peers, and save and restore their state locally. Registration,
lookup, and snapshot merging have formal specifications and proofs. A separate
system model proves preservation of saved registrations, including registrations
received in a successfully delivered snapshot.

The ID sampling model proves the birthday bound for independent uniform
`bits`-bit values, including collision risk below `2^-128` for at most one
billion 256-bit draws across the system. The probability is defined by counting
actual colliding outcomes. Conversion to `ParticipantId` preserves the sampled
value. The runtime still uses manually supplied IDs; a random generator and its
conformance to the sampling model are not implemented or verified.

The project does not yet implement a blockchain, consensus, wallet authority,
payments, or token issuance and redemption. The optional proof-task experiment
checks prewritten Lean submissions with the kernel; it is separate from the
core library and does not call an AI prover.

The previous code, proofs, notes, and reference tools are preserved at
[commit 43f2620](https://github.com/CloK-Lab/vdsi/tree/43f26201474a144b68924d2b485a0e3fd857c483),
also named `archive/pre-participant-model-20261010`. They are reference material
and are not part of the current executable system.

## Files

| File | Purpose |
| --- | --- |
| `VDSI.lean`, `VDSI/` | Core library: participants, registration, nodes, and system execution |
| `VDSI/IdGeneration/` | Finite uniform ID sampling model, collision-risk specification, and birthday-bound proof |
| `VDSI/System/` | System model, execution schedules, safety specification and proofs, and an unproved propagation target |
| `NodeMain.lean`, `VDSI/Node/Runtime/` | Command-line entry, TCP node process, snapshots, and wire encoding |
| `Tests/` | Core regression tests and a two-process TCP integration test |
| `Experiments/` | Optional experiments and their own checks |
| `scripts/check.sh` | Build, run core tests, and audit theorem assumptions |
| `scripts/Audit.lean` | Axiom dependency checks for public theorems |
| `lakefile.toml`, `lean-toolchain` | Build configuration and pinned Lean version |
| `docs/`, `tools/` | Documentation, renderer, and authoring tools |

Add source files only as a concrete definition, operation, or property needs
them. See [Contributing](CONTRIBUTING.md) and the
[current architecture status](docs/ARCHITECTURE.md).

## Run

The probability proof uses mathlib v4.34.0, pinned to commit `5ed2965` in
`lakefile.toml` and `lake-manifest.json`. On a fresh checkout, `lake update`
fetches the dependencies and mathlib's compiled cache; this requires network
access.

Run these commands from the repository root:

| Command | Purpose |
| --- | --- |
| `./scripts/check.sh` | Build, run core and two-process TCP tests, and audit theorem assumptions; requires Python 3 and loopback sockets |
| `lake exe tests` | Run only the Lean core tests, without opening sockets |
| `lake exe node ID PORT [PEER_PORT ...]` | Run an independent node on loopback |
| `lake exe proof-experiment` | Run the separate proof-task experiment, including its own regression checks |

The system check does not build or run experiments.

To try two nodes, run `lake exe node 1 7101 7102` in one terminal and
`lake exe node 2 7102 7101` in another. Enter `register 1` in the first and
`register 2` in the second. After a successful exchange, `show` in either
terminal reports both IDs. Repeating a registration adds no duplicate; `quit`
stops that process. Peers retry every 500 ms after each exchange round.

Each node saves its current registry to `.vdsi/node-ID.json`, relative to the
working directory. Local and peer updates are saved before becoming visible;
duplicates do not rewrite the file. Stop both nodes, then run `lake exe node 1 7101`
and enter `show` to restore node 1 without any peer. Use only one running process
per node ID in the same directory. `.vdsi/` is ignored by Git; tests use temporary
directories and do not touch your snapshots.

Missing snapshots start empty; malformed or duplicate-ID snapshots fail with an
error. Saving replaces the previous file through one temporary file, without
keeping a history. Write failures are reported. This supports process restart;
power-loss durability is not guaranteed.

This prototype uses unauthenticated loopback TCP. It has no blockchain or
consensus protocol. Snapshot messages are limited
to 64 KiB. The proved merge operation preserves the node ID and produces the
union of the local and incoming ID sets, with no duplicate IDs. Delivery,
serialization, disk IO, OS sockets, and process scheduling are outside that proof.

`VDSI/System/Spec.lean` states the system-level requirements. The executable model
reuses node merge and restore operations and allows reordered, duplicated, and
lost messages, failed saves, stops, and restarts. Safety is proved for any finite
schedule from a consistent state: saved IDs remain saved and queryable when the
node is online. The model assumes intact storage, one writer per node, and atomic
save-and-publish operations; the IO runtime's correspondence to the model is not
formally proved. Eventual propagation is specified but not yet proved.

For documentation, run `npm ci` once, then `npm run build` or `npm run dev`.
See the [overview](docs/Overview.mdx), the
[ID collision note](VDSI/IdGeneration/Note.mdx), and the
[notebook guide](docs/README.md). The
[published notebook](https://www.clok.tech/docs/give-and-take) uses a pinned
repository commit. Successful checks on `main` make an update eligible for the
website's documentation sync; publication requires its update PR to be merged.

Licensed under [Apache-2.0](LICENSE).
