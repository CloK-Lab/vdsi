"""Draw resource, balance, and state views for three concrete learning examples."""
from pathlib import Path
from base64 import b64encode
from html import escape

ROOT = Path(__file__).resolve().parents[1]
INK = '#dfebf4'
MUTED = '#9fa6b2'
BLUE = '#86b9d5'
PURPLE = '#b6a4c9'
GOLD = '#c6ad79'


class Drawing:
    def __init__(self, name, height, title, description):
        self.name = name
        self.parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="{height}" viewBox="0 0 1000 {height}" role="img" aria-labelledby="title description">',
                      f'<title id="title">{escape(title)}</title><desc id="description">{escape(description)}</desc>']
        fonts, licenses = [], []
        for package, family in [('jost', 'Jost'), ('ibm-plex-mono', 'Plex')]:
            directory = ROOT / 'node_modules/@fontsource' / package
            data = b64encode((directory / 'files' / f'{package}-latin-400-normal.woff2').read_bytes()).decode()
            fonts.append(f"@font-face{{font-family:{family};src:url(data:font/woff2;base64,{data}) format('woff2')}}")
            licenses.append((directory / 'LICENSE').read_text())
        self.add('<metadata>' + escape('\n\n'.join(licenses)) + '</metadata>')
        self.add('<style>' + ''.join(fonts) + '''
text{font-family:Jost,sans-serif;font-weight:400}
.mono{font-family:Plex,monospace;letter-spacing:1.3px}
.compact{display:none}
@media(max-width:620px){.wide{display:none}.compact{display:inline}}
</style><defs>''')
        for name, color in [('blue', BLUE), ('purple', PURPLE), ('gold', GOLD)]:
            self.add(f'<marker id="{name}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="8" markerHeight="8" orient="auto"><path d="M2 1 L8 5 L2 9" fill="none" stroke="{color}" stroke-width="1.4"/></marker>')
        self.add(f'</defs><rect width="1000" height="{height}" fill="#0a0a0f"/>')

    def add(self, value):
        self.parts.append(value)

    def text(self, x, y, value, size=24, color=INK, anchor='start', mono=False):
        self.add(f'<text x="{x}" y="{y}" font-size="{size}" fill="{color}" text-anchor="{anchor}" class="{"mono" if mono else ""}">{escape(str(value))}</text>')

    def rect(self, x, y, width, height, fill, stroke='none', radius=10, opacity=1):
        self.add(f'<rect x="{x}" y="{y}" width="{width}" height="{height}" rx="{radius}" fill="{fill}" stroke="{stroke}" fill-opacity="{opacity}"/>')

    def path(self, path, color, width=2, arrow=None, dash=False):
        attrs = (f' marker-end="url(#{arrow})"' if arrow else '') + (' stroke-dasharray="7 8"' if dash else '')
        self.add(f'<path d="{path}" fill="none" stroke="{color}" stroke-width="{width}" stroke-linecap="round" stroke-linejoin="round"{attrs}/>')

    def icon(self, x, y, kind, color, scale=1):
        self.add(f'<g transform="translate({x} {y}) scale({scale})" fill="none" stroke="{color}" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">')
        if kind == 'power':
            self.add('<circle r="27"/><path d="M5 -19 L-12 3 H0 L-5 19 L13 -4 H2 Z"/>')
        elif kind == 'chip':
            self.add('<rect x="-17" y="-17" width="34" height="34" rx="3"/><rect x="-8" y="-8" width="16" height="16"/>')
            for n in [-10, 0, 10]:
                self.add(f'<path d="M{n} -24 V-17 M{n} 17 V24 M-24 {n} H-17 M17 {n} H24"/>')
        elif kind == 'network':
            self.add('<rect x="-10" y="-24" width="20" height="15" rx="2"/><path d="M0 -9 V5 H-19 V13 M0 5 H19 V13"/><rect x="-27" y="13" width="16" height="14" rx="2"/><rect x="11" y="13" width="16" height="14" rx="2"/>')
        self.add('</g>')

    def ribbon(self, x1, y1, x2, y2, width, opacity):
        # Both ends have the same vertical width: one scale, in joules.
        mid = (x1 + x2) / 2
        self.add(f'<path d="M{x1} {y1} C{mid} {y1} {mid} {y2} {x2} {y2} L{x2} {y2 + width} C{mid} {y2 + width} {mid} {y1 + width} {x1} {y1 + width} Z" fill="{BLUE}" fill-opacity="{opacity}" stroke="{BLUE}" stroke-opacity=".65"/>')

    def save(self):
        self.add('</svg>\n')
        (ROOT / 'docs/assets' / f'{self.name}.svg').write_text(''.join(self.parts))


def energy_flow():
    d = Drawing('energy-allocation', 760, 'Energy used across three devices',
                'Illustrative constant-power inputs, not measured hardware data. Over two seconds, a GPU at 60 watts uses 120 joules, a CPU at 25 watts uses 50 joules, and a separate network device at 15 watts uses 30 joules. Total: 100 watts and 200 joules. Ribbon width is proportional to energy, with disjoint device boundaries. These are consumption allocations, not energy converted into information.')
    for mobile in [False, True]:
        d.add(f'<g class="{"compact" if mobile else "wide"}">')
        if mobile:
            d.text(24, 48, 'ENERGY USE', 40, BLUE, mono=True)
            d.text(24, 104, 'Illustrative · same 2 s interval', 38, MUTED)
            d.rect(10, 135, 980, 475, '#0e151d', '#283643')
            d.text(36, 245, '200 J', 72)
            d.text(36, 297, 'Total', 40, MUTED)
            for sy, ty, amount, alpha in [(325, 193, 120, .40), (445, 385, 50, .25), (495, 521, 30, .14)]:
                d.ribbon(230, sy, 530, ty, amount, alpha)
            d.rect(218, 325, 12, 200, BLUE, radius=0)
            for y, name, value, power in [(166, 'GPU', '120 J', '60 W'), (353, 'CPU', '50 J', '25 W'), (489, 'Network', '30 J', '15 W')]:
                h = 163 if y == 166 else 111
                d.rect(530, y, 439, h, '#14232e', '#365366')
                d.text(553, y + 47, name, 43, BLUE)
                d.text(942, y + 47, value, 49, INK, 'end')
                d.text(553, y + 95, power, 39, MUTED)
            d.rect(10, 636, 980, 109, '#10141b', '#303541')
            d.text(500, 683, '120 + 50 + 30 = 200 J', 46, INK, 'middle')
            d.text(500, 727, 'Band width represents energy', 36, MUTED, 'middle')
        else:
            d.text(24, 37, 'RESOURCE FLOW', 19, BLUE, mono=True)
            d.text(976, 37, 'ILLUSTRATIVE INPUTS', 17, MUTED, 'end', True)
            d.text(24, 92, 'Energy consumption by device', 33)
            d.text(976, 90, '100 W × 2 s = 200 J', 29, BLUE, 'end')
            d.rect(0, 130, 1000, 479, '#0e151d', '#283643')
            d.text(24, 170, 'ELECTRICITY CONSUMED', 16, MUTED, mono=True)
            d.text(976, 170, 'OVER THE SAME 2 s', 16, MUTED, 'end', True)
            for sy, ty, amount, alpha in [(287, 218, 120, .40), (407, 410, 50, .25), (457, 547, 30, .14)]:
                d.ribbon(230, sy, 650, ty, amount, alpha)
            d.rect(23, 260, 207, 253, '#101d27', '#365366')
            d.icon(63, 306, 'power', BLUE, .8)
            d.text(48, 384, '200 J', 54)
            d.text(48, 430, 'Total energy', 25, BLUE)
            d.text(48, 471, '100 W for 2 s', 22, MUTED)
            for y, name, value, detail, glyph, height in [
                (195, 'GPU', '120 J', '60 W · 60%', 'chip', 164),
                (382, 'CPU', '50 J', '25 W · 25%', 'chip', 110),
                (512, 'Network', '30 J', '15 W · 15%', 'network', 80)]:
                d.rect(650, y, 328, height, '#14232e', '#365366')
                d.icon(689, y + 40, glyph, BLUE, .7)
                d.text(727, y + 38, name, 25, BLUE)
                d.text(954, y + 38, value, 32, INK, 'end')
                d.text(727, y + 70, detail, 22, MUTED)
            d.rect(0, 634, 1000, 86, '#10141b', '#303541')
            d.text(24, 683, 'ENERGY ACCOUNT', 17, BLUE, mono=True)
            d.text(970, 688, '120 J + 50 J + 30 J = 200 J', 35, INK, 'end')
            d.text(500, 750, 'Band width ∝ joules · each device is counted once', 22, MUTED, 'middle')
        d.add('</g>')
    d.save()


def token_transfer():
    d = Drawing('token-transfer', 700, 'A token transfer changes two balances',
                'One token contract, all amounts in base units. Before: Alice 100, Bob 0. Alice transfers 30 to Bob. After: Alice 70, Bob 30. Total supply remains 100. The bars partition the same 100 units between the two holders; no tokens are minted or burned.')
    for mobile in [False, True]:
        d.add(f'<g class="{"compact" if mobile else "wide"}">')
        d.text(24, 46 if mobile else 37, 'TOKEN TRANSFER', 40 if mobile else 19, GOLD, mono=True)
        if not mobile:
            d.text(976, 37, 'ONE CONTRACT · BASE UNITS', 17, MUTED, 'end', True)
        d.rect(0, 75, 1000, 87, '#17150f', '#3b3325')
        d.text(28, 130, 'Alice → Bob', 48 if mobile else 33)
        d.text(971, 130, '30 base units', 45 if mobile else 31, GOLD, 'end')
        for x, heading, alice, bob in [(0, 'BEFORE', 100, 0), (560, 'AFTER', 70, 30)]:
            d.rect(x, 197, 440, 315, '#12141b', '#303541')
            d.rect(x + 1, 198, 438, 68, '#1a1c25', radius=9)
            d.text(x + 26, 244, heading, 37 if mobile else 20, MUTED, mono=True)
            for y, person, value in [(335, 'Alice', alice), (414, 'Bob', bob)]:
                d.text(x + 28, y, person, 43 if mobile else 29)
                d.text(x + 403, y + 3, value, 58 if mobile else 44, GOLD, 'end')
            d.path(f'M{x + 25} 362 H{x + 414}', '#303541', 1)
            d.rect(x + 28, 458, 382 * alice / 100, 22, GOLD, radius=2, opacity=.7)
            if bob:
                d.rect(x + 28 + 382 * alice / 100, 458, 382 * bob / 100, 22, GOLD, '#c6ad79', radius=0, opacity=.20)
            if not mobile:
                d.text(x + 28, 502, '100 units across both holders', 18, MUTED)
        d.path('M452 355 H548', GOLD, 2, 'gold')
        d.text(500, 323, '30', 45 if mobile else 31, GOLD, 'middle')
        d.rect(0, 548, 1000, 113, '#17150f', '#3b3325')
        d.text(28, 593, 'TOTAL SUPPLY', 36 if mobile else 19, GOLD, mono=True)
        d.text(974, 601, '100 → 100', 51 if mobile else 43, INK, 'end')
        d.text(28, 639, '100 + 0 = 70 + 30', 40 if mobile else 28, MUTED)
        d.text(500, 695, 'Only the holder balances change.', 36 if mobile else 22, MUTED, 'middle')
        d.add('</g>')
    d.save()


def paid_call():
    d = Drawing('paid-call-paths', 1000, 'Reserve, then settle or refund',
                'All amounts are in one common unit, with no fees. Ready: buyer 100, provider 20, reserved 0. Reserve 30: buyer 70, provider 20, reserved 30. Choose one ending. Settle: buyer 70, provider 50, reserved 0. Or refund: buyer 100, provider 20, reserved 0. Total remains 120 along either path. Settled and refunded are terminal states; there is no transition between them.')

    def card(x, y, title, color, values, mobile, terminal=False):
        d.rect(x, y, 440, 299, '#15131d' if title == 'Reserved' else '#12141b', '#41354d' if title == 'Reserved' else '#303541')
        d.rect(x + 1, y + 1, 438, 68, '#252031' if title == 'Reserved' else '#1a1c25', radius=9)
        d.text(x + 25, y + 48, title, 48 if mobile else 31, color)
        if terminal:
            d.add(f'<circle cx="{x + 403}" cy="{y + 35}" r="12" fill="none" stroke="{color}"/><circle cx="{x + 403}" cy="{y + 35}" r="6" fill="{color}"/>')
        for i, (label, value) in enumerate(zip(['Buyer', 'Provider', 'Reserved'], values)):
            yy = y + 125 + 64 * i
            if label == 'Reserved':
                d.rect(x + 14, yy - 38, 412, 53, PURPLE, radius=4, opacity=.07)
            d.text(x + 26, yy, label, 42 if mobile else 26, PURPLE if label == 'Reserved' else MUTED)
            d.text(x + 402, yy + 2, value, 50 if mobile else 36, color if value else MUTED, 'end')

    for mobile in [False, True]:
        d.add(f'<g class="{"compact" if mobile else "wide"}">')
        d.text(24, 47 if mobile else 37, 'A RESERVED PAYMENT', 39 if mobile else 19, PURPLE, mono=True)
        if not mobile:
            d.text(976, 37, 'ONE CALL · TWO POSSIBLE ENDINGS', 17, MUTED, 'end', True)
        card(0, 134, 'Ready', BLUE, [100, 20, 0], mobile)
        card(560, 134, 'Reserved', PURPLE, [70, 20, 30], mobile)
        d.text(500, 97, 'reserve 30', 42 if mobile else 27, PURPLE, 'middle')
        d.path('M220 133 V113 H780 V133', PURPLE, 2, 'purple')
        d.path('M780 433 V475', PURPLE)
        d.add(f'<circle cx="780" cy="475" r="6" fill="{PURPLE}"/>')
        d.path('M780 475 H220 V598', GOLD, 2, 'gold')
        d.path('M780 475 V598', BLUE, 2, 'blue')
        # A label in open space, without obscuring the branch connectors.
        d.text(500, 466, 'choose one', 37 if mobile else 23, MUTED, 'middle')
        d.text(252, 549, 'settle', 44 if mobile else 30, GOLD)
        d.text(814, 549, 'refund', 44 if mobile else 30, BLUE)
        card(0, 608, 'Settled', GOLD, [70, 50, 0], mobile, True)
        card(560, 608, 'Refunded', BLUE, [100, 20, 0], mobile, True)
        d.text(500, 969, 'Buyer + provider + reserved = 120', 43 if mobile else 31, INK, 'middle')
        d.add('</g>')
    d.save()


if __name__ == '__main__':
    energy_flow()
    token_transfer()
    paid_call()
