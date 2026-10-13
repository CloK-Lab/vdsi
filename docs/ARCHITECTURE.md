# Architecture status

The project contains a Lean library for participant registration, ID sampling,
node operations, and system execution, with specifications and proofs.
`Tests/` checks the core library. `Experiments/` contains the separate proof-task
model, candidate submissions, kernel verification, and experiment checks.
The core library does not import experiments.

`IdGeneration/Model.lean` defines finite samples, their value-preserving
conversion to `ParticipantId`, the collision event, and its exact probability
under the uniform product distribution. `Spec.lean` requires collision risk
below `2^-128` for at most one billion independent uniform 256-bit draws.
`Verification.lean` proves the general birthday bound and this concrete
requirement using pinned mathlib v4.34.0. Small enumerated examples are checked
in `Tests/IdGeneration.lean`. The runtime does not import this sampling model
and still takes manually supplied IDs. No random source or generator is
implemented, and no IO conformance or private-key/address security is proved.

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
Their directory structure and modeling choices are not requirements for the
current implementation. The reference models remain available there for later
comparisons.

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
