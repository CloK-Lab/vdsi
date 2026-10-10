# Writing a learning note

Work through one question at a time. Open with a concise academic introduction
stating the subject, scope, and modeling or implementation work in the note.
Name and link the main reference documents where relevant. Develop worked
examples in the relevant subsections, explain the modeling choices, and connect
the Lean definitions to the behavior being studied. Include
enough reasoning for a reader to follow the result. Prefer revising an unclear
note to adding another topic. Earlier worked examples are preserved in the
[archive](https://github.com/CloK-Lab/vdsi/tree/43f26201474a144b68924d2b485a0e3fd857c483).

## Preview locally

With Node.js 22.12 or newer:

```sh
npm ci
npm run dev
```

Open the URL printed by Astro. Before committing, run `npm run build` and inspect
the changed pages, including at phone width. `npm run preview` serves the built site.

## Keep the note beside its code

Write `Note.mdx` beside the relevant module under `VDSI/`. Create the module
and its note when there is a concrete definition to explain. The note's
metadata supplies the navigation:

```yaml
---
title: "Your question"
description: "What the reader will learn."
slug: your-question
order: 2
---
```

Use a unique slug and choose an order for the reading sequence. Add `draft: true`
while a note is unfinished; drafts stay out of the site. Preserve slugs,
section labels, and ordering when moving source directories. Reading groups
do not prescribe code dependencies or directories.

The page supplies its own title, so start the body with prose. Use ordinary
Markdown for the explanation and `$...$` for inline math. There is no required
section template or minimum number of definitions, theorems, or examples.

## Show the actual Lean source

An empty fence imports a declaration and its proof from a path relative to the note:

````mdx
```lean4 file="./Verification.lean" declaration="execute_preservesFunds"
```
````

Omit `declaration` to include the whole file. The excerpt updates with the code;
a missing declaration fails the build. Use ordinary fences for commands or
small expressions. A long excerpt can be folded:

````mdx
<CodePreview title="Conservation for one action">

```lean4 file="./Verification.lean" declaration="execute_preservesFunds"
```

</CodePreview>
````

Link between published notes using relative source paths. Use GitHub links for
repository files that are not notebook pages. Explain assumptions and what a
result means beside the relevant code.

## Diagrams

Follow the [diagram style](DIAGRAMS.md): editable SVG, CloK typography,
and consistent colors for task interaction, spending authority, and settlement.
Use isometric nodes for module relationships, proportional bands for resource
allocation, ledger views for balance changes, and state graphs for alternative
outcomes. The retained `tools/draw-native-system.py` supplies the approved
geometry. Its diagram is a style reference, not the current implementation.

## Shared documentation format

`clok.json` selects pages; [Overview.mdx](Overview.mdx) is the entry point. The
renderer and styling follow
[`same-but-better`](https://github.com/CloK-Lab/same-but-better/tree/6891ef09fa04860573561909c02841e156bf852c),
adapted under Apache-2.0. The notebook builds independently of other repositories.

Read the notebook on [CloK](https://www.clok.tech/docs/give-and-take), where the
main website supplies the navbar. The local Astro preview shows the document body.

The GitHub repository is `CloK-Lab/vdsi`, and the project title is `ν-DSI`.
Keep the published project slug `give-and-take` so existing documentation URLs
continue to resolve. The repository name and Lean module root are independent
of that stable publication identifier.

The shared `Sync project documentation` workflow checks registered projects hourly
and proposes updates after their CI passes. Website checks and the deployment
preview must pass before the publication PR is merged. See the
[CloK documentation protocol](CLOK_PROTOCOL.md) for the full contract.
