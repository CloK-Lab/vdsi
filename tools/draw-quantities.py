"""Draw the two executable quantity relations in the notebook's visual style."""
from pathlib import Path
from base64 import b64encode
from html import escape

root = Path(__file__).resolve().parents[1]
fonts, licenses = [], []
for package, family in [('jost', 'Jost'), ('ibm-plex-mono', 'Plex')]:
    directory = root / 'node_modules/@fontsource' / package
    data = (directory / 'files' / f'{package}-latin-400-normal.woff2').read_bytes()
    encoded = b64encode(data).decode()
    fonts.append(f"@font-face{{font-family:{family};src:url(data:font/woff2;base64,{encoded}) format('woff2');font-weight:400}}")
    licenses.append((directory / 'LICENSE').read_text())

blue, purple, gold = '#86b9d5', '#b6a4c9', '#c6ad79'
parts = ['''<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="780" viewBox="0 0 1000 780" role="img" aria-labelledby="title description">
<title id="title">Execution fees and physical energy</title>
<desc id="description">Two independent illustrative calculations. Protocol accounting: 21,000 gas at an effective price of 2 gwei per gas gives a fee of 42,000 gwei, or 0.000042 ETH. Physical consumption: constant power of 100 watts over 2 seconds gives 200 joules. These inputs do not refer to the same execution. One ETH equals one billion gwei and one quintillion wei. There is no fixed conversion from gas to joules.</desc>
''', '<metadata>' + escape('\n\n'.join(licenses)) + '</metadata>', '''
<metadata>Original quantity diagram. Gas reference: https://ethereum.org/developers/docs/gas/ (EVM diagram credited there to Takenobu Tani's Ethereum EVM illustrated). Units: https://ethereum.org/developers/docs/intro-to-ether/ and https://www.nist.gov/glossary-term/34606 . Accessed 2026-10-08. Numerical inputs match Quantities/Checks.lean; the gas and energy examples are independent.</metadata>
''', '<style>', *fonts, '''
text{font-family:Jost,sans-serif;font-weight:400;fill:#dfebf4}
.mono{font-family:Plex,monospace;letter-spacing:1.5px}
.muted{fill:#9fa6b2}.blue{fill:#86b9d5}.purple{fill:#b6a4c9}.gold{fill:#c6ad79}
.compact{display:none}.wire{fill:none;stroke-width:2;stroke-linejoin:round;stroke-linecap:round}
@media(max-width:620px){.wide{display:none}.compact{display:inline}}
</style><defs>
''']
for name, color in [('blue', blue), ('gold', gold)]:
    parts.append(f'<marker id="{name}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M2 1 L8 5 L2 9" fill="none" stroke="{color}" stroke-width="1.4"/></marker>')
parts.append('</defs><rect width="1000" height="780" fill="#0a0a0f"/>')


def txt(x, y, value, size=22, css='', anchor='middle'):
    parts.append(f'<text x="{x}" y="{y}" font-size="{size}" class="{css}" text-anchor="{anchor}">{escape(value)}</text>')


def box(x, y, width, height, fill, stroke):
    parts.append(f'<rect x="{x}" y="{y}" width="{width}" height="{height}" rx="8" fill="{fill}" stroke="{stroke}"/>')


def arrow(x1, x2, y, color):
    ink = {'blue': blue, 'gold': gold}[color]
    parts.append(f'<path d="M{x1} {y} H{x2}" class="wire" stroke="{ink}" marker-end="url(#{color})"/>')


def cube(x, y, size, kind, color):
    tones = {
        'blue': ('#172936', '#111f2c', '#0c1823', blue),
        'purple': ('#2c2237', '#21192c', '#18121f', purple),
        'gold': ('#3b3220', '#2d2518', '#211c13', gold),
    }
    top, left, right, edge = tones[color]
    parts.append(f'<g transform="translate({x} {y}) scale({size/50})">')
    parts.append(f'<path d="M0 -55 L50 -27 L0 1 L-50 -27 Z" fill="{top}" stroke="{edge}" stroke-width="1.5"/>')
    parts.append(f'<path d="M-50 -27 L0 1 L0 58 L-50 30 Z" fill="{left}" stroke="{edge}" stroke-width="1.5"/>')
    parts.append(f'<path d="M0 1 L50 -27 L50 30 L0 58 Z" fill="{right}" stroke="{edge}" stroke-width="1.5"/>')
    parts.append(f'<g transform="translate(10 6) skewY(-29)" fill="none" stroke="{edge}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">')
    if kind == 'wallet':
        parts.append('<rect x="1" y="3" width="28" height="27" rx="2"/><path d="M21 12 H30 V22 H21 Z"/><circle cx="25" cy="17" r="1"/>')
    elif kind == 'power':
        parts.append('<path d="M18 1 L4 19 H14 L10 34 L27 13 H17 Z"/>')
    elif kind == 'time':
        parts.append('<circle cx="15" cy="17" r="13"/><path d="M15 8 V17 L23 21"/>')
    else:
        parts.append('<path d="M1 4 H28 V32 H1 Z M7 11 H22 M7 18 H22 M7 25 H17"/>')
    parts.append('</g></g>')


def units(x, y, size):
    parts.append(f'<text x="{x}" y="{y}" text-anchor="middle" font-size="{size}">1 ETH = 10<tspan baseline-shift="super" font-size="70%">9</tspan> gwei = 10<tspan baseline-shift="super" font-size="70%">18</tspan> wei</text>')


parts.append('<g class="wide">')
txt(24, 34, 'QUANTITIES AND UNITS', 19, 'mono blue', 'start')
txt(976, 34, 'INDEPENDENT EXAMPLES', 16, 'mono muted', 'end')

# Two dimensionally distinct multiplications. Arrows lead to their results.
box(0, 68, 1000, 275, '#17150f', '#3b3325')
txt(24, 105, '01  EXECUTION FEE', 18, 'mono gold', 'start')
cube(145, 185, 39, 'ledger', 'gold')
cube(475, 185, 39, 'wallet', 'purple')
cube(850, 185, 39, 'ledger', 'gold')
txt(310, 200, '×', 38, 'muted')
arrow(560, 778, 185, 'gold')
txt(669, 166, 'fee', 20, 'gold')
txt(145, 263, '21,000 gas', 28)
txt(475, 263, '2 gwei / gas', 28)
txt(850, 263, '42,000 gwei', 28)
txt(145, 306, 'Gas used', 22, 'muted')
txt(475, 306, 'Effective price', 22, 'purple')
txt(850, 306, '0.000042 ETH', 22, 'gold')

box(0, 369, 1000, 257, '#0e151d', '#263440')
txt(24, 406, '02  PHYSICAL ENERGY', 18, 'mono blue', 'start')
txt(976, 406, 'constant power', 20, 'muted', 'end')
cube(145, 479, 39, 'power', 'blue')
cube(475, 479, 39, 'time', 'blue')
cube(850, 479, 39, 'power', 'blue')
txt(310, 494, '×', 38, 'muted')
arrow(560, 778, 479, 'blue')
txt(669, 460, 'energy', 20, 'blue')
txt(145, 556, '100 W', 28)
txt(475, 556, '2 s', 28)
txt(850, 556, '200 J', 28)
txt(145, 600, 'Power', 22, 'muted')
txt(475, 600, 'Duration', 22, 'muted')
txt(850, 600, 'Energy', 22, 'blue')

box(0, 652, 1000, 80, '#0f1118', '#2b303b')
txt(24, 700, 'ETH UNITS', 18, 'mono gold', 'start')
units(635, 700, 28)
txt(500, 769, 'Gas follows protocol rules; joules measure physical consumption.', 20, 'muted')

parts.append('</g><g class="compact">')
txt(34, 46, 'QUANTITIES AND UNITS', 38, 'mono blue', 'start')
txt(34, 94, 'Two independent examples', 38, 'muted', 'start')
box(25, 128, 950, 215, '#17150f', '#3b3325')
cube(115, 210, 39, 'wallet', 'purple')
txt(205, 181, 'EXECUTION FEE', 34, 'mono gold', 'start')
txt(205, 242, '21,000 gas × 2 gwei / gas', 44, '', 'start')
txt(205, 304, '= 42,000 gwei', 49, 'gold', 'start')
box(25, 366, 950, 215, '#0e151d', '#263440')
cube(115, 449, 39, 'power', 'blue')
txt(205, 419, 'PHYSICAL ENERGY', 34, 'mono blue', 'start')
txt(205, 480, '100 W × 2 s = 200 J', 49, '', 'start')
txt(205, 538, 'Constant power over the interval', 36, 'muted', 'start')
box(25, 606, 950, 149, '#0f1118', '#2b303b')
txt(500, 657, '42,000 gwei = 0.000042 ETH', 43, 'gold')
units(500, 718, 42)
parts.append('</g></svg>\n')
(root / 'docs/assets/quantities.svg').write_text(''.join(parts))
