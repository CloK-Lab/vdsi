# ν-DSI

*Verified Decentralized Superintelligence with Digital Tokenomics*

[![Documentation](https://img.shields.io/badge/Documentation-clok.tech-7fb8d1)](https://www.clok.tech/docs/give-and-take)

ν-DSI develops formal models, specifications, executable code, and proofs in Lean toward a verified decentralized superintelligence (DSI) system. Its design combines human-agent collaboration with digital tokenomics to allocate physical and computational resources for building, verifying, and improving hardware, compute, software, and scientific infrastructure.

We study digital tokenomics as a means of pricing and funding resources,
settling payments, and defining rewards for contributions. This includes the
design of digital assets and monetary rules, alongside the incentives those
rules create for participants. The project's own chain, stablecoin mechanisms, wallets, and agent protocols are components of this economic infrastructure.

Executable Lean models of external infrastructure provide comparison cases.
The research target is to relate selected reference compositions and the native
implementation to common specifications, with explicit observation mappings
and assumptions. Those correspondence proofs are not yet implemented.

[Modules and interactions](VDSI/Cases/PaidTask/System/Note.mdx) introduces the environment
of an on-chain agent economy. The source studies cover Bitcoin, Ethereum
execution-specs, Solana and Agave, OpenZeppelin ERC-20, PASS wallets, x402, AP2,
Circle Gateway, Nevermined, and A2A.
The blockchain examples model Ethereum balance-and-nonce transfers and Solana
account-access conflicts, including contention on a shared fee payer.
The [paid-call example](VDSI/Cases/PaidCall/Note.mdx#recover-a-lost-reply)
models a lost reply and retry, proving at-most-once payment and fund conservation
under atomic local accounting and receipt storage.

The current implementation consists of local executable models and proofs.
Block production, a persistent node, and stablecoin issuance and redemption are
not yet implemented. Run the existing examples with:

```sh
lake build
lake exe demo
```

The source is organized by responsibility:

```text
VDSI/
  Foundation/    Shared identities, asset amounts, and quantities
  Reference/     Ethereum, Solana, ERC-20, x402, and A2A models
  Native/Wallet/ The project's spending policy
  Cases/         PaidCall (including Retry) and PaidTask (including System)
```

Start with [PaidCall/Model.lean](VDSI/Cases/PaidCall/Model.lean),
[Spec.lean](VDSI/Cases/PaidCall/Spec.lean), and
[Execution.lean](VDSI/Cases/PaidCall/Execution.lean) to follow one
reservation, settlement, or refund. Then read
[Verification.lean](VDSI/Cases/PaidCall/Verification.lean) for the proofs.
`Retry/` adds lost replies to that same case. Read the reference models as a case
needs them; they are not prerequisites for running the demo.

`Specs/` and `Comparisons/` will hold common specifications and correspondence
proofs when the first concrete comparison is implemented. They do not exist yet.
Notes remain beside their code; website navigation and URLs use note metadata
and are independent of the source layout.

The [architecture](docs/ARCHITECTURE.md) specifies the first chain and monetary
subsystem, with an experimental reserve-and-redemption case. Its milestone is a
local node that records transfers, mints and redeems against test reserves, and
restores the same state after restart.

Optional [external reference tools](tools/reference/README.md) collect comparison
data. They are independent of the Lean runtime and are not project milestones.

Licensed under [Apache-2.0](LICENSE).
