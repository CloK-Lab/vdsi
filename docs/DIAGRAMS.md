# Diagram style

Use the approved [system diagram](assets/native-system.svg) as the visual reference
for ν-DSI. Keep this guide in contributor documentation, not in the
learning notes.

## Visual language

- Dark background, lightly tinted surfaces, outlined shapes, and small line
  icons. Use the reference cube geometry for actors and infrastructure; use the
  diagram forms below when the subject is a quantity, a state, or a sequence.
- Group modules by responsibility. Leave space between groups for labeled arrows.
  Prefer a few meaningful nodes over decorative detail.
- Jost for module names and explanations; IBM Plex Mono for section labels.
  Use short English labels matching the Lean definitions. Keep implementation
  language and project positioning in the introduction, not in diagram headings.
- Thin connectors with open arrowheads. Solid lines show primary requests and
  actions; dashed lines show returned status, results, or execution-ready signals.
  Label each interaction. Do not mix runtime interactions with import dependencies.

| Role | Color |
| --- | --- |
| Canvas | `#0a0a0f` |
| Main text | `#dfebf4` |
| Secondary text | `#9fa6b2` |
| Agents, tasks, physical resources, and service interaction | `#86b9d5` |
| Wallets and spending authority | `#b6a4c9` |
| Ledger and settlement | `#c6ad79` |

Keep these color meanings consistent across diagrams. Pair colors with labels;
color alone must not carry the meaning. Avoid gradients, glow, heavy shadows,
new accent colors, and unrelated project logos.

## Choose a form for the subject

| Subject | Form | What the reader should see |
| --- | --- | --- |
| System responsibilities | Isometric module diagram | Actors, boundaries, and labeled interactions |
| Resource allocation | Proportional flow bands | A stated total, disjoint components, and their units |
| Balance changes | Before/after ledger | The same holders, the transferred amount, and the conserved total |
| Alternatives and lifecycle | State graph | State contents, labeled actions, and separate terminal outcomes |
| Messages over time | Sequence lanes | Sender, recipient, order, and responses |
| Dimensional relations | Annotated equations | Inputs, units, operation, and result |

Give each form the visual weight of the system diagram: a clear group boundary,
a readable heading, prominent values, and supporting details inside the relevant
state or ledger. Use filled bands to show quantities and small glyphs to identify
roles. Avoid adding cubes where a balance row or a formula explains more.

Use the same scale at both ends of a resource flow. Never join joules, tokens,
gas, and money as if they were one conserved flow; label a tariff or exchange
rate when a calculation relates quantities with different units. Distinguish
illustrative inputs from measurements.

## Source and layout

The approved diagram and its generator are retained as a visual reference.
They describe an earlier design, not the implementation status of this branch.
Earlier case diagrams and generators remain in the
[archive](https://github.com/CloK-Lab/vdsi/tree/43f26201474a144b68924d2b485a0e3fd857c483).

Author diagrams as editable SVG. Reuse the `cube`, `box`, `path`, and `txt`
geometry in [the generator](../tools/draw-native-system.py), and keep generators
alongside their outputs.

```sh
python3 tools/draw-native-system.py
npm run build
```

The script uses the fonts installed by `npm ci`. Embed font data and license
metadata in SVG files. Include a title, description, and meaningful alt text.

The reference uses a 1000 × 700 canvas, 2-unit connectors, 25–29-unit node titles,
and 18–22-unit annotations. At rendered widths of 620px or less, use a compact
layout with larger labels. Preserve the module roles and interaction order.
Check notebook and phone-width rendering.

Keep one canonical copy of each diagram. Explain each module and interaction
in the accompanying note and identify proposed components explicitly.
