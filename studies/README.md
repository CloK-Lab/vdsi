# Preserved studies

These notes retain the project's protocol studies, quantities, wallet policy,
and two payment examples from
[commit 43f2620](https://github.com/CloK-Lab/vdsi/tree/43f26201474a144b68924d2b485a0e3fd857c483).
Their published slugs and reading order are unchanged.

Only the Lean files needed by source excerpts are copied here, byte for byte.
`SNAPSHOT.json` records each original path and SHA-256 digest. This is a
documentation source snapshot, not a complete or buildable Lean library.
Imports keep their original `VDSI` names to preserve the source. The current
`lakefile.toml` does not include this directory, and the current node runtime
does not import it. Proofs displayed here belong to the recorded study revision;
the current core audit does not recheck them.

To build and run the complete study revision in a separate checkout:

```sh
git clone --branch archive/pre-participant-model-20261010 https://github.com/CloK-Lab/vdsi.git vdsi-studies
cd vdsi-studies
lake build
lake exe demo
lake env lean scripts/Audit.lean
```

`npm run build` in the current checkout checks the notes, links, and source
excerpts. Revise the explanations here as needed; introduce executable changes
in the current library only after settling the corresponding modeling question.
