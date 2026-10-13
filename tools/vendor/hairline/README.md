# Hairline geometry

`iso.ts` is copied unchanged from
[`@lucasmarkes/hairline` v0.5.0, commit a221785](https://github.com/lucasmarkes/hairline/blob/a2217852fed6d1a4f20bc7d43d4fad1a3de117b8/packages/hairline/src/core/iso.ts),
by Lucas Marques, under the accompanying MIT license.

`tools/draw-hairline-figures.mjs` uses its orthographic projection, rounded
rings, and silhouette/crease construction to draw static notebook diagrams.
The composition, annotations, and semantic colors are specific to ν-DSI.
The SVGs embed this license and the font licenses.

This uses the package's geometry directly, not its interactive figure runtime
or the `hairline-create` HTML workflow. Static SVG keeps the diagrams portable
through the shared CloK documentation publisher.
