# Architecture status

## Repository map

| Path | Responsibility | Current boundary |
| --- | --- | --- |
| `VDSI/Participant.lean`, `Registration/`, `Registry.lean` | Numeric participant IDs, registration, lookup, and uniqueness | Does not authenticate an identity |
| `VDSI/Node.lean`, `Node/` | One node's registry, merge and restore rules, and their proofs | `Node/Runtime/` adds TCP, JSON, storage, and process IO |
| `VDSI/System/` | Model multiple nodes, message schedules, saves, failures, and recovery | Safety proofs concern the model; eventual propagation is unproved |
| `VDSI/IdGeneration/` | Uniform ID sampling and collision probability | No runtime random generator |
| `VDSI/Identity/` | Registration policy, encoding proofs, and research signing implementation | Local signed-registration demo; not wired into nodes |
| `Experiments/ProofTask/` | Check prewritten proof submissions against a requested goal | Separate executable experiment; no AI prover or payment |
| `Tests/`, `scripts/` | Executable checks, process tests, and theorem axiom audit | Tests and proofs have distinct roles |
| `studies/` | Preserved protocol, wallet, and payment studies | Excluded from the current Lean build |
| `docs/`, `tools/` | Overview, architecture, and notebook rendering | Notes beside code supply the published pages |

`VDSI.lean` exports the core library. `NodeMain.lean` starts the node process;
`Tests/Main.lean` runs core tests. `lakefile.toml` declares build targets and
`lean-toolchain` pins the compiler version. `.lake/`, `node_modules/`, and `dist/`
are generated dependencies or build outputs, not project source.

The running node follows numeric-ID registration through `Registry` and `Node`
operations to the TCP/storage boundary. `System` models compositions of those
operations. `IdGeneration` and `Identity` are separate studies in the core
library; neither currently supplies identities to the node runtime.

Within `Identity/`, `Model.lean` defines keys, statements, and signed records;
`Spec.lean` defines validity and the registry invariant; `Execution.lean` implements
registration; `Verification.lean` proves properties of that same operation.
`Encoding.lean` supplies canonical v1 signing bytes and a byte-verifier adapter;
`EncodingVerification.lean` proves encoding and adapter properties. `Note.mdx`
explains them, and `Tests/Identity.lean` and `Tests/IdentityEncoding.lean` exercise
the operations with test fixtures. `Crypto/` implements SHA-512 and Ed25519;
`Signing.lean` connects them to canonical registration. `Entropy.lean` reads a
32-byte seed from `/dev/urandom` on macOS/Linux and fails on read errors, without
a fallback. `SeedFile.lean` encodes and checks a versioned plaintext seed/public-key
pair; `Storage.lean` creates or restores its local file. `IdentityMain.lean` runs
`identity-demo`, including explicit `init` and `resume` modes. The identity seed
can persist. Separate `registry-*` modes use `Snapshot.lean` for JSON and
`RegistryStorage.lean` for bounded file reads and save-before-acknowledgement.
They call `restoreRegistry` from `Execution.lean`, whose two recovery theorems
live in `Verification.lean`. Existing `init`/`resume` still run an in-memory demo.

## Implementation and proof boundaries

The project contains a Lean library for participant registration, ID sampling,
node operations, and system execution, with specifications and proofs.
`Tests/` checks the core library. `Experiments/` contains the separate proof-task
model, candidate submissions, kernel verification, and experiment checks.
The core library does not import experiments.

`Identity/` is a separate executable registration-policy model. A full candidate
public key identifies a participant; statements bind a domain, version, network,
and key. `register` checks these fields, key/signature widths, and a supplied
verifier before duplicate detection. Valid replays retain the original record.
Five audited theorems cover required validation, invalid-input rejection,
unchanged replay, record preservation, and preservation of validated unique-key
registries. They are conditional on a fixed verifier, not proofs of its
cryptographic soundness. The policy tests retain explicit allowlist fixtures;
`Tests/IdentityCrypto.lean` separately checks the real research backend against
RFC 8032 vectors, hash-padding fixtures, malformed input, registration tampering,
and injected entropy failures. `Tests/identity_processes.py` checks persisted
identity recovery across processes, copied identity, corruption rejection,
exclusive initialization, and creation permissions. There is no node integration;
`ParticipantId` and the numeric-ID runtime remain unchanged. The canonical v1
encoder signs a fixed application prefix, a 32-byte key, and the exact network
UTF-8 bytes. Four additional audited theorems cover supported input shape,
injectivity of successful encodings, fail-closed adapter behavior, and binding
adapter acceptance to the exact encoded message and key. No transport decoder
or stream framing is supplied.

The Ed25519 backend follows RFC 8032 PureEd25519. It uses the uncofactored
verification equation and additionally requires nonidentity prime-subgroup A
and R, canonical encodings, and S below the subgroup order. This is stricter
than RFC cofactored verification. Cryptographic arithmetic, SHA-512 correctness,
constant-time execution, secure memory erasure, and OS entropy are not proved.
The implementation uses variable-time `Nat` arithmetic and is research-only.
`tools/check-identity-interop.mjs` compares 27 public deterministic fixtures
against Node crypto. Node is reference infrastructure, not a runtime dependency
of the Lean identity demo. The default demo does not save its seed. Explicit
`init DIRECTORY` creates a new directory, restricts it to `0700`, writes a
versioned seed/public-key pair to `identity.pending` with mode `0600`, flushes,
and renames it to `identity.seed`. It refuses any existing destination directory.
`resume DIRECTORY` requires an exact-size regular file and checks the marker and
derived public key. Missing, damaged, or unfinished state fails without new key
generation. The seed is never printed. Recovery is tested, not formally proved.
Trusted ancestors, preserved private permissions, intact storage, and absence of
hostile concurrent filesystem mutation are assumptions. Storage is unencrypted,
does not authenticate whole-file replacement, and provides no power-loss durability
or rollback protection. Key rotation and revocation are absent.

The identity registry snapshot is versioned JSON bound to a configured network,
with complete statements and signatures; it contains no private seed. Decoding
rejects out-of-range byte values. The recovery operation checks every record and
key uniqueness, returning exactly the input list or rejecting the whole list.
Two additional audited theorems establish this equivalence and invariant
preservation. They do not prove the JSON parser, crypto backend, or disk IO.
`registry-init` creates an empty snapshot in a new directory. `registry-show`
requires a present, valid snapshot. `registry-register` restores the seed and
registry, signs, validates, and saves changes before printing confirmation.
Replays do not rewrite storage. Single-writer and trusted-directory assumptions
apply; there is no lock for concurrent updates. Reads/writes are bounded at
64 KiB. Flushed temporary data is renamed over the snapshot; stale temporary
data is ignored on recovery. Failed saves throw before acknowledgement. An older
valid file or valid subset can still pass; no historical completeness, rollback,
power-loss durability, or identity-node transport guarantee is established.

`Merge.lean` validates both registries, retains every local record, appends
incoming records with previously unknown keys, and validates the candidate.
`MergeVerification.lean` supplies six audited theorems for successful imports:
candidate equality and invariant, local-record preservation, exact key-set union,
known-key replay, and key-set agreement after exchanging snapshots (including
the unconditional key-union lemma for the candidate operation). `registry-export`
writes a public snapshot in a new directory; `registry-import` reads a bounded
snapshot file, verifies, merges, and saves before acknowledgement. Seed files
are never accessed by either command. Bad input rejects the whole import;
duplicate keys within an incoming file are rejected, while overlap between
valid registries retains local records. File ordering and signature byte equality
are not agreement criteria. `Tests/identity_exchange_processes.py` exercises two
independent registries, rejection without partial import, failed save, repeated
import without writes, and restart. TCP integration and delivery liveness remain absent.

`IdGeneration/Model.lean` defines finite samples, their value-preserving
conversion to `ParticipantId`, the collision event, and its exact probability
under the uniform product distribution. `Spec.lean` requires collision risk
below `2^-128` for at most one billion independent uniform 256-bit draws.
`Verification.lean` proves the general birthday bound and this concrete
requirement using pinned mathlib v4.34.0. Small enumerated examples are checked
in `Tests/IdGeneration.lean`. The runtime does not import this sampling model
and still takes manually supplied IDs. No numeric-ID random generator is
implemented, and no IO conformance or private-key/address security is proved.
The separate identity demo's key generation is not covered by that probability theorem.

`Node.lean` defines one node and its registry operations.
`Node/Spec.lean`, `Lemmas.lean`, and `Verification.lean` state and prove their properties.
`System/` combines nodes, local saved state, and pending snapshots in one model.
`NodeMain.lean` starts an independent process using `VDSI/Node/Runtime/Process.lean`:
each process owns a registry, listens on loopback TCP, and periodically
exchanges JSON snapshots with configured peers. No central coordinator is used.
Local commands and incoming snapshots use `Node.mergeRegistry` under a mutex;
network waits occur outside the lock. The process test in `Tests/node_processes.py`
checks exchange, duplicate input, malformed frames, and peer restart.

`Node/Runtime/Storage.lean` loads and saves `.vdsi/node-ID.json` in the working
directory, with one writer per node ID. Changed state is written and flushed to
a temporary file, then renamed over the snapshot, under the same mutex used for
merging. The process publishes the new in-memory state only after saving succeeds.
Malformed snapshots fail explicitly. Duplicate registrations do not write again.
The process test also checks independent recovery with all peers stopped,
corrupt snapshots, and failed writes. Test data lives in temporary directories.
No snapshot history is retained, and power-loss durability is not guaranteed.

`restoreRegistry_satisfies_spec` proves that restoring decoded participants keeps
the node ID and exact list, rejecting duplicate IDs. JSON decoding and filesystem
operations are tested but are outside the formal proof.

`MergeRegistrySpec` describes node identity preservation and exact ID-set union.
`mergeRegistry_satisfies_spec` verifies the operation used by the runtime;
`merging_each_others_registry_agrees` verifies agreement after both nodes merge
the other's snapshot, assuming delivery and no intervening updates. Registry
uniqueness is carried by the `Registry` type. These proofs do not verify the TCP
implementation, JSON codec, compiler, runtime, or operating system, and do not
prove eventual delivery. The prototype has no authentication,
consensus, or cross-machine transport; snapshots are bounded to 64 KiB.

`System/Model.lean` describes an arbitrary finite number of nodes, saved state,
and pending snapshots. `System/Execution.lean` executes explicit schedules using
the same `Node.mergeRegistry` and `Node.restoreRegistry` as the runtime. Its
actions cover local registration, snapshot send/delivery, message loss and
duplication, failed saves, stops, and recovery. Delivery can select any queued
message. Concurrent updates are represented by interleavings of atomic
save-and-publish operations, corresponding to the runtime's mutex boundary.

`System/Spec.lean` separates `SafetySpec` from the unproved `PropagationSpec`.
`System/Verification.lean` proves preservation of safety for every finite
schedule from a consistent state and proves that a confirmed registration
remains saved and queryable whenever its node is online. The model assumes one
writer per node, intact saved data, and exact successful reads/writes. It omits
crashes inside an unfinished save-and-publish operation. These assumptions are
not proofs of the filesystem, locking implementation, or IO refinement.
`SuccessfulDeliverySpec` and `successful_delivery_satisfies_spec` additionally
establish that every ID in a successfully delivered snapshot is saved at its
online recipient and remains saved through any finite continuation. Successful
delivery and storage are premises; the theorem does not ensure that a message
will eventually arrive.
`Tests/System.lean` checks delayed delivery, recipient isolation, empty queues,
interleaved registrations, reordered and duplicate snapshots, failed storage,
and independent recovery. Eventual propagation still
requires a formal execution and fairness model; it is not implied by safety.

The previous source tree, models, proofs, and architecture proposal are preserved
at [commit 43f2620](https://github.com/CloK-Lab/vdsi/tree/43f26201474a144b68924d2b485a0e3fd857c483).
The corresponding notes are published from `studies/`, beside the exact archived
source files they excerpt. `studies/SNAPSHOT.json` records their original paths
and digests. This documentation snapshot is excluded from the current Lean
build; it is not a second runtime or a complete library. The complete archived
checkout supplies the executable studies and their audit. Their directory
structure and modeling choices are not requirements for the current implementation.

## Developing the model

Record each modeling decision with its definition and a concrete example before
adding another concept. Account ownership, wallet authority,
ledger state, and the behavior of a running node need their own definitions
when the model reaches them.

Create source directories only when they contain substantive code. Keep
definitions, specifications, executable operations, and proofs separate.
Tests, experiments, and proofs must use the same operations.

Implement the project's runtime in Lean. External infrastructure can supply
reference designs and comparison cases. A common specification and explicit
observation mappings are required for claims about correspondence; no such
comparison is implemented in the current library.
