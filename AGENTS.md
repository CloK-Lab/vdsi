# Working on ν-DSI

This is a CloK learning and research project toward a verified decentralized
superintelligence (DSI) system. Its purpose is to build formal models,
specifications, and executable code in Lean for human-agent coordination and
resource allocation through digital tokenomics, supporting the construction,
verification, and improvement of infrastructure. Agent protocols, payments,
tokenized assets, incentives, and safety are parts of that system.

- Implement the project's own chain, stablecoin mechanisms, wallets, payment
  rules, and agent protocols natively in Lean. External infrastructure is
  reference material only; do not build the runtime on external chains, issued
  stablecoins, hosted payment services, or their SDKs. Keep reference probes
  separate from project execution and record the actual implementation status.
- The previous code and notes are preserved at commit
  `43f26201474a144b68924d2b485a0e3fd857c483` on
  `archive/pre-participant-model-20261010`. This branch restarts the model from
  basic definitions. Consult archived models as references; do not restore the
  whole implementation or predefine its architecture without discussing the
  next small modeling question with the user.
- Compare reference and native models through explicit common specifications
  and observation mappings. Distinguish shared safety properties, refinement,
  and behavioral equivalence; model proofs do not by themselves establish
  conformance of deployed external systems.
- Prioritize learning: explain one small question clearly before adding topics.
  Use worked examples in the relevant subsections to explain modeling choices.
  Keep reader navigation small, leave undeveloped topics as drafts, and avoid
  unnecessary frameworks, checklists, and duplicate explanations.
- Open each note with a concise academic statement of its subject, scope, and
  actual modeling or implementation work. Cite the main reference documents
  where relevant. Keep writing advice, learning methods, project positioning, and
  promises about future work in contributor documentation, not reader-facing prose.
  End notes when the subject is explained; do not append generic outlook or
  open-question sections.
- State the Lean-native positioning once in the overview introduction. Do not
  repeat it in note headings, captions, alt text, or introductory filler. Name
  sections for their subject (for example, "Spending policy", not "In Lean").
  Preserve actual project names, source filenames, and code syntax.
- Use English for repository documentation and code comments; converse with the
  user in their preferred language.
- Read README.md, CONTRIBUTING.md, and the guide for the case being changed.
- Keep definitions, specifications, execution, and verification separate.
  The demo and proofs must refer to the same executable Lean definitions.
- Keep README.md and docs/ARCHITECTURE.md consistent with the code that exists.
  Create source directories as concrete definitions need them. Keep restored
  reference models separate from native execution. Website navigation is
  independent of source paths; preserve note slugs when moving modules.
- Add concrete cases before introducing general frameworks. Do not create empty
  modules for planned features or describe reading notes as implementations.
- Preserve explicit units, assumptions, source versions, and proof boundaries.
  Do not conflate protocol execution, service quality, economic incentives,
  external asset backing, or chain settlement.
- Do not introduce admitted proofs, custom axioms, or native evaluation axioms.
  Audit new public theorems in scripts/Audit.lean.
- Run lake build, lake exe demo, and lake env lean scripts/Audit.lean.
- Keep case notes beside their Lean source as Note.mdx and use source excerpts
  instead of copying definitions or proofs. Follow docs/README.md and clok.json.
- For documentation changes, run npm run build and inspect the affected pages.
  Preserve the shared CloK documentation format and notebook visual conventions.
- Follow docs/DIAGRAMS.md for diagrams. The approved native-system.svg sets the
  isometric geometry, semantic colors, typography, and connector conventions.
- Keep generated build files, credentials, and local runtime data out of Git.
