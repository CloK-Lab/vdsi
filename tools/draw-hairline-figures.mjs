// SPDX-License-Identifier: Apache-2.0
// Static notebook compositions built with Hairline's unchanged geometry module.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import ts from 'typescript';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const read = p => fs.readFileSync(path.join(root, p), 'utf8');
const compiled = ts.transpileModule(read('tools/vendor/hairline/iso.ts'), {
  compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.ES2022 },
}).outputText;
const { Cam, proj, facing, prism, rings, rrect, ringAt, hull, poly, open, seg, circ } =
  await import(`data:text/javascript;base64,${Buffer.from(compiled).toString('base64')}`);

const colors = { blue: '#86b9d5', purple: '#b6a4c9', gold: '#c6ad79', text: '#dfebf4', muted: '#9fa6b2' };
const esc = s => String(s).replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('"', '&quot;');
const fonts = [], licenses = [read('tools/vendor/hairline/LICENSE')];
for (const [name, family] of [['jost', 'Jost'], ['ibm-plex-mono', 'Plex']]) {
  const base = `node_modules/@fontsource/${name}`;
  const data = fs.readFileSync(path.join(root, base, 'files', `${name}-latin-400-normal.woff2`)).toString('base64');
  fonts.push(`@font-face{font-family:${family};src:url(data:font/woff2;base64,${data}) format('woff2')}`);
  licenses.push(read(`${base}/LICENSE`));
}

let out;
function start(title, description, height) {
  out = [`<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="${height}" viewBox="0 0 1000 ${height}" role="img" aria-labelledby="title desc">
<title id="title">${esc(title)}</title><desc id="desc">${esc(description)}</desc>
<metadata>${esc(licenses.join('\n\n'))}</metadata><style>${fonts.join('')}
text{font-family:Jost,sans-serif;font-weight:400;fill:${colors.text}}
.mono{font-family:Plex,monospace;letter-spacing:1.6px}
.compact{display:none}@media(max-width:620px){.wide{display:none}.compact{display:inline}}
path,circle{stroke-linecap:round;stroke-linejoin:round}
</style><defs>`];
  for (const [key, color] of Object.entries(colors)) {
    out.push(`<marker id="arrow-${key}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="${color}" stroke-width="1.3"/></marker>`);
  }
  out.push(`</defs><rect width="1000" height="${height}" fill="#0a0a0f"/>`);
}
function text(x, y, s, size = 25, color = 'text', extra = '') {
  out.push(`<text x="${x}" y="${y}" text-anchor="middle" font-size="${size}" style="fill:${colors[color]}" ${extra}>${esc(s)}</text>`);
}
function stroke(d, color = 'blue', width = 1.3, opacity = 1, extra = '') {
  out.push(`<path d="${d}" fill="none" stroke="${colors[color]}" stroke-width="${width}" opacity="${opacity}" ${extra}/>`);
}
function dot(x, y, color, r = 2) {
  out.push(`<circle cx="${x}" cy="${y}" r="${r}" fill="${colors[color]}"/>`);
}
function solid(paths, color = 'blue') {
  // Opaque plates occlude distant geometry; a dim inset crease suggests the bevel.
  out.push(`<path d="${paths.sil}" fill="#0d1118" stroke="${colors[color]}" stroke-width="1.35"/>`);
  stroke(paths.crease, color, .8, .42);
}
function camera(x, y, scale = 1) {
  const C = Cam(45, .5, scale); C.ox = x; C.oy = y;
  return { C, P: proj(C), front: facing(C) };
}
function plate(cam, x0, y0, x1, y1, z0, z1, color, radius = 3) {
  const [ring, inner] = rings(x0, y0, x1, y1, radius, 1.2);
  solid(prism(cam.P, cam.front, ring, inner, z0, z1), color);
}
function line3(cam, points, color = 'blue', opacity = .65) {
  stroke(open(points.map(p => cam.P(...p))), color, 1, opacity);
}
function topRing(cam, ring, z, color, opacity = .65) {
  stroke(poly(ringAt(cam.P, ring, z)), color, 1, opacity);
}
function slab(cam, ring, depth0, depth1, color = 'blue') {
  const at = d => ring.map(q => cam.P(q.u, d, q.v));
  solid({ sil: poly(hull(at(depth0).concat(at(depth1)))), crease: '' }, color);
}

// Every object has a physical silhouette and a small number of identifying details.
function hardware(x, y, scale = 1) {
  const c = camera(x, y, scale);
  plate(c, -67, -56, 67, 56, 0, 5, 'blue', 5);
  for (const side of [-1, 1]) for (let i = -3; i <= 3; i++) {
    line3(c, [[i * 10, side * 22, 6], [i * 10, side * 42, 6]], 'blue', .5);
    line3(c, [[side * 29, i * 8, 6], [side * 53, i * 8, 6]], 'blue', .5);
  }
  plate(c, -34, -29, 34, 29, 7, 14, 'blue');
  plate(c, -25, -21, 25, 21, 18, 27, 'blue');
  topRing(c, rrect(-18, -14, 18, 14, 2), 28, 'blue');
  for (const [u, v] of [[-53, -42], [53, -42], [-53, 42], [53, 42]]) {
    topRing(c, circ(2, 16).map(q => ({ ...q, u: q.u + u, v: q.v + v })), 6, 'blue');
  }
}
function compute(x, y, scale = 1) {
  const c = camera(x, y, scale);
  plate(c, -66, -40, 66, 43, 0, 5, 'blue', 5);
  for (const [cx, cy, h] of [[-30, -10, 110], [30, 9, 83]]) {
    plate(c, cx - 23, cy - 24, cx + 23, cy + 24, 7, h, 'blue', 3);
    for (let z = 20; z < h - 8; z += 14) {
      const front = cy + 24.2;
      line3(c, [[cx - 16, front, z], [cx + 16, front, z]], 'blue', .6);
      line3(c, [[cx - 16, front, z + 6], [cx + 5, front, z + 6]], 'blue', .3);
      const p = c.P(cx + 16, front, z + 6); dot(...p, 'blue', 1.2);
    }
  }
}
function software(x, y, scale = 1) {
  const c = camera(x, y, scale);
  plate(c, -68, -45, 68, 55, 0, 5, 'blue', 5);
  topRing(c, rrect(-21, 25, 21, 47, 3), 6, 'blue', .4);
  for (let v = -25; v < 15; v += 9) for (let u = -51; u < 51; u += 13)
    topRing(c, rrect(u, v, u + 10, v + 6, 1), 6, 'blue', .27);
  slab(c, rrect(-68, 7, 68, 96, 5), -43, -39);
  const at = (u, z) => c.P(u, -38.5, z);
  stroke(poly(rrect(-60, 17, 60, 87, 3).map(q => at(q.u, q.v))), 'blue', .8, .6);
  stroke(seg(at(-60, 75), at(60, 75)), 'blue', .8, .4);
  for (const [z, end] of [[61, 26], [48, 43], [35, 12]]) {
    stroke(open([at(-45, z + 3), at(-40, z), at(-45, z - 3)]), 'blue', 1.1);
    stroke(seg(at(-29, z), at(end, z)), 'blue', .8, .55);
  }
}
function science(x, y, scale = 1) {
  const c = camera(x, y, scale);
  plate(c, -65, -48, 65, 48, 0, 4, 'blue', 5);
  const paper = rrect(-51, -38, 19, 35, 3);
  topRing(c, paper, 6, 'blue', .55);
  line3(c, [[-41, -28, 7], [-41, 22, 7], [7, 22, 7]], 'blue', .5);
  line3(c, [[-37, 15, 7], [-29, 11, 7], [-22, 14, 7], [-13, -2, 7], [-4, -7, 7], [4, -20, 7]]);
  const P = c.P;
  // A flask is a revolved vessel: wide belly, narrow neck, visible rim.
  const at = (r, z) => circ(r, 48).map(q => P(q.u + 30, q.v + 4, z));
  solid({ sil: poly(hull([...at(23, 10), ...at(23, 24), ...at(8, 53), ...at(8, 73)])), crease: open(at(20, 20).slice(0, 25)) });
  stroke(poly(at(10, 75)), 'blue', 1.2);
  for (const z of [21, 31]) { const p = P(30, 18, z); dot(...p, 'blue', 1.3); }
}
function agent(x, y, scale = 1) {
  const c = camera(x, y, scale);
  plate(c, -28, -23, 28, 23, 0, 5, 'blue');
  slab(c, rrect(-20, 9, 20, 44, 4), -10, -5, 'blue');
  for (const u of [-8, 8]) { const p = c.P(u, -4, 29); dot(...p, 'blue', 1.6); }
  line3(c, [[-7, -4, 19], [7, -4, 19]], 'blue');
}
function person(x, y, scale = 1) {
  const c = camera(x, y, scale);
  plate(c, -28, -23, 28, 23, 0, 5, 'blue');
  const p = c.P(0, 0, 35);
  out.push(`<circle cx="${p[0]}" cy="${p[1]}" r="${7 * scale}" fill="#0d1118" stroke="${colors.blue}" stroke-width="1.3"/>`);
  const [bx, by] = c.P(0, 0, 9);
  stroke(`M${bx - 13 * scale} ${by}v${-6 * scale}c0 ${-18 * scale} ${26 * scale} ${-18 * scale} ${26 * scale} 0v${6 * scale}`, 'blue');
}
function wallet(x, y, scale = 1) {
  const c = camera(x, y, scale);
  plate(c, -28, -22, 28, 22, 0, 7, 'purple');
  plate(c, -23, -18, 23, 18, 9, 14, 'purple');
  plate(c, 8, -7, 29, 8, 15, 17, 'purple', 2);
  const p = c.P(19, 0, 18); dot(...p, 'purple', 1.8);
}
function ledger(x, y, scale = 1) {
  const c = camera(x, y, scale);
  for (let z = 0; z <= 16; z += 8) plate(c, -34, -29, 34, 29, z, z + 5, 'gold');
  for (let v = -16; v <= 16; v += 8) line3(c, [[-21, v, 22], [21, v, 22]], 'gold');
}
function payment(x, y, scale = 1) {
  const c = camera(x, y, scale);
  plate(c, -35, -28, 35, 28, 0, 8, 'gold');
  for (const [u, v, z] of [[-10, -4, 12], [10, 4, 17]])
    solid(prism(c.P, c.front, circ(14, 48).map(q => ({ ...q, u: q.u + u, v: q.v + v })), null, z, z + 4), 'gold');
}
function wire(d, color, dashed = false, arrow = false) {
  stroke(d, color, 1.55, .7, `${dashed ? 'stroke-dasharray="5 7"' : ''} ${arrow ? `marker-end="url(#arrow-${color})"` : ''}`);
}
function network(x, y, scale = 1) {
  out.push(`<g transform="translate(${x} ${y}) scale(${scale})">`);
  // Gold settlement links sit inside the blue coordination network.
  const nodes = [[0, -112], [150, -44], [150, 74], [0, 143], [-150, 74], [-150, -44]];
  wire(poly(nodes), 'blue');
  wire(poly(nodes.map(([a, b]) => [a * .52, b * .52])), 'gold');
  nodes.forEach(([a, b]) => wire(seg([a * .52, b * .52], [a, b]), 'purple'));
  nodes.slice(0, 2).forEach(([a, b], i) => (i % 2 ? agent : person)(a, b, .9));
  person(...nodes[5], .9);
  ledger(0, 26, 1.05);
  for (const [a, b] of nodes) wallet(a * .52, b * .52, .48);
  agent(...nodes[4], .9); person(...nodes[2], .9); agent(...nodes[3], .9);
  out.push('</g>');
}
function save(name) {
  out.push('</svg>\n');
  fs.writeFileSync(path.join(root, 'docs/assets', name), out.join('\n'));
}

start('Verified infrastructure', 'Research scope: people and agents coordinate hardware, compute, software, and science. Blue links describe work; purple wallets describe authority; a gold ledger describes digital tokenomics and settlement. This is not a diagram of the current runtime.', 880);
out.push('<g class="wide">');
text(500, 46, 'Verified infrastructure', 34);
text(500, 82, 'Build · verify · improve', 21, 'blue');
// Work links are a different layer from the settlement ring.
for (const d of ['M248 239L350 362', 'M752 239L650 362', 'M250 628L350 480', 'M750 628L650 480']) wire(d, 'blue');
hardware(190, 232, 1.05); compute(810, 246, 1.05);
text(190, 298, 'Hardware', 28); text(810, 298, 'Compute', 28);
software(190, 663, 1.05); science(810, 646, 1.05);
text(190, 731, 'Software', 28); text(810, 731, 'Science', 28);
text(500, 249, 'DSI network', 31); text(500, 284, 'People + agents', 20, 'muted');
network(500, 447);
text(500, 666, 'Digital tokenomics', 25, 'gold');
text(500, 698, 'Pricing · funding · settlement · rewards', 19, 'muted');
wire('M144 807H174', 'blue'); text(299, 814, 'Work and resources', 19, 'blue');
wire('M444 807H474', 'purple'); text(561, 814, 'Authority', 19, 'purple');
wire('M697 807H727', 'gold'); text(814, 814, 'Settlement', 19, 'gold');
out.push('</g><g class="compact">');
text(500, 49, 'Verified infrastructure', 43);
text(500, 97, 'Build · verify · improve', 31, 'blue');
hardware(160, 253, 1); compute(395, 259, .87);
software(635, 259, .86); science(864, 246, .85);
for (const [x, label] of [[160, 'Hardware'], [395, 'Compute'], [635, 'Software'], [864, 'Science']]) text(x, 326, label, 34);
wire('M160 353V379H864V353M395 353V379M635 353V379M500 379V438', 'blue');
network(500, 589, .92);
text(500, 439, 'DSI network · People + agents', 35);
text(500, 794, 'Digital tokenomics', 38, 'gold');
text(500, 842, 'Pricing · funding · settlement · rewards', 28, 'muted');
out.push('</g>'); save('economy-overview.svg');

start('A paid task: modules and interactions', 'The preserved paid-task model: an agent requests a task and spending authorization. Wallet approval and service terms permit payment, which transfers funds in a local ledger. Settlement enables task execution and the provider returns the result. ETH amounts are measured in wei.', 820);
out.push('<g class="wide">');
text(500, 48, 'A paid task', 34);
text(500, 85, 'Request · authorize · settle · execute', 21, 'muted');
text(175, 155, 'AGENTS', 17, 'blue', 'class="mono"');
text(500, 155, 'AUTHORITY', 17, 'purple', 'class="mono"');
text(825, 155, 'SETTLEMENT', 17, 'gold', 'class="mono"');
wire('M246 252H421', 'purple', false, true); text(335, 230, 'spend request', 20, 'purple');
wire('M500 334V462', 'purple', false, true); text(565, 410, 'approve', 21, 'purple');
wire('M247 530H421', 'blue', false, true); text(333, 509, 'terms', 21, 'blue');
wire('M423 579H247', 'blue', true, true); text(333, 610, 'execute', 21, 'blue');
wire('M569 531H947V389H901', 'gold', false, true); text(780, 509, 'transfer', 21, 'gold');
wire('M787 396H672V571H569', 'gold', true, true); text(713, 418, 'paid', 21, 'gold');
wire('M175 329V463', 'blue', false, true); text(217, 405, 'Task', 25, 'blue');
wire('M106 531H60V252H106', 'blue', true, true); text(65, 424, 'result', 19, 'blue', 'transform="rotate(-90 65 424)"');
person(175, 268, 1.65); text(175, 321, 'Agent A', 27);
agent(175, 547, 1.65); text(175, 645, 'Agent B', 27);
wallet(500, 271, 1.65); text(500, 321, 'Wallet', 27);
payment(500, 547, 1.5); text(500, 645, 'Payment', 27);
ledger(825, 389, 1.75); text(825, 460, 'Ledger', 29);
text(500, 716, 'Local model · Asset: ETH · Amounts: wei', 22, 'muted');
wire('M143 770H172', 'blue'); text(275, 777, 'Task interaction', 19, 'blue');
wire('M424 770H453', 'purple'); text(562, 777, 'Spending authority', 19, 'purple');
wire('M731 770H760', 'gold'); text(844, 777, 'Value transfer', 19, 'gold');
out.push('</g><g class="compact">');
text(500, 53, 'A paid task', 47);
for (const [y, label, sub, draw, color] of [
  [177, 'Agent + Task', 'request → provider → result', agent, 'blue'],
  [348, 'Wallet', 'owner · asset · limit · recipient', wallet, 'purple'],
  [519, 'Payment', 'terms + approval → settle', payment, 'gold'],
  [690, 'Ledger', 'local balances · ETH / wei', ledger, 'gold'],
]) {
  draw(151, y, 1.7); text(583, y - 5, label, 42); text(583, y + 49, sub, 32, color);
  if (y < 690) wire(`M151 ${y + 61}V${y + 112}`, color, false, true);
}
out.push('</g>'); save('native-system.svg');
console.log('Wrote economy-overview.svg and native-system.svg using Hairline geometry.');
