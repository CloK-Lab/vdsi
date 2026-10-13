# Diagram style

Use the [overview](assets/economy-overview.svg) and
[system diagram](assets/native-system.svg) as the visual references for ν-DSI.
They use [Hairline](https://hairline.lucasmarkes.com/figures) geometry with the
project's semantic colors and typography. Keep this guide in contributor
documentation, not in the learning notes.

## Visual language

- Dark background, opaque plates, rounded silhouettes, a dim inset crease,
  and a few identifying details. Use Hairline's 45-degree orthographic camera
  and rounded prisms for actors and infrastructure. Paint back to front so
  distant lines do not show through solids. Use the diagram forms below when
  the subject is a quantity, a state, or a sequence.
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

The overview depicts research scope. The module diagram describes the preserved
paid-task study, not the current participant-node runtime. Earlier case diagrams
and their generators accompany the restored study notes.

Author diagrams as editable SVG. The
[generator](../tools/draw-hairline-figures.mjs) imports the unchanged Hairline
geometry module vendored at commit `a221785`; its source and MIT license are
recorded in [`tools/vendor/hairline/`](../tools/vendor/hairline/README.md).
Keep the rendering dependency at build time: the published notebook uses static
SVG, without custom browser scripts or an animation dependency.

```sh
node tools/draw-hairline-figures.mjs
npm run build
```

The script uses the fonts installed by `npm ci`. Embed font data and license
metadata in SVG files. Include a title, description, and meaningful alt text.

Use a 1000-unit canvas, 1–1.6-unit strokes, 27–34-unit node titles, and
19–22-unit annotations. At rendered widths of 620px or less, use a compact
layout with larger labels. Preserve the module roles and interaction order.
Check notebook and phone-width rendering. External labels and semantic colors
adapt Hairline's geometry to explanatory diagrams; these are not interactive
Hairline figures.

Keep one canonical copy of each diagram. Explain each module and interaction
in the accompanying note and identify proposed components explicitly.
