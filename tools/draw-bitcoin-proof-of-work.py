"""Draw transaction propagation, proof-of-work search, and history rewriting."""
from pathlib import Path
from base64 import b64encode
from html import escape

root = Path(__file__).resolve().parents[1]
fonts, licenses = [], []
for package, family in [('jost', 'Jost'), ('ibm-plex-mono', 'Plex')]:
    directory = root / 'node_modules/@fontsource' / package
    font = b64encode((directory / 'files' / f'{package}-latin-400-normal.woff2').read_bytes()).decode()
    fonts.append(f"@font-face{{font-family:{family};src:url(data:font/woff2;base64,{font}) format('woff2');font-weight:400}}")
    licenses.append((directory / 'LICENSE').read_text())

blue, purple, gold = '#86b9d5', '#b6a4c9', '#c6ad79'
parts = ['''<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1050" viewBox="0 0 1000 1050" role="img" aria-labelledby="title description">
<title id="title">Bitcoin — from a transaction to proof of work</title>
<desc id="description">Peers relay a signed transaction. Miners build candidate blocks and vary the header until its double SHA-256 hash is at or below the target. Full nodes verify proof of work and transactions. Changing an old payment changes the Merkle root and block hash, forcing changes to later headers and new proof of work for every affected block. A replacement branch must overtake the growing honest chain.</desc>
''', '<metadata>' + escape('\n\n'.join(licenses)) + '</metadata>', '<style>', *fonts, '''
text{font-family:Jost,sans-serif;font-weight:400;fill:#dfebf4}
.mono{font-family:Plex,monospace;letter-spacing:1.5px}
.muted{fill:#9fa6b2}.blue{fill:#86b9d5}.purple{fill:#b6a4c9}.gold{fill:#c6ad79}
.compact{display:none}.wire{fill:none;stroke-width:2;stroke-linejoin:round;stroke-linecap:round}
@media(max-width:620px){.wide{display:none}.compact{display:inline}}
</style><defs>
''']
for name, color in [('blue', blue), ('purple', purple), ('gold', gold)]:
    parts.append(f'<marker id="{name}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M2 1 L8 5 L2 9" fill="none" stroke="{color}" stroke-width="1.4"/></marker>')
parts.append('</defs><rect width="1000" height="1050" fill="#0a0a0f"/>')

def txt(x, y, value, size=22, css='', anchor='middle'):
    parts.append(f'<text x="{x}" y="{y}" font-size="{size}" class="{css}" text-anchor="{anchor}">{escape(value)}</text>')

def path(d, color='blue', dashed=False, arrow=True):
    col = dict(blue=blue, purple=purple, gold=gold)[color]
    attrs = f' marker-end="url(#{color})"' if arrow else ''
    if dashed:
        attrs += ' stroke-dasharray="5 7"'
    parts.append(f'<path d="{d}" class="wire" stroke="{col}"{attrs}/>')

def box(x,y,w,h,fill,stroke):
    parts.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="8" fill="{fill}" stroke="{stroke}" stroke-width="1"/>')

def cube(x, y, size, kind, color):
    """Three planar faces and a small line glyph; all geometry remains editable."""
    tones = {
        'blue': ('#172936','#111f2c','#0c1823',blue),
        'purple': ('#2c2237','#21192c','#18121f',purple),
        'gold': ('#3b3220','#2d2518','#211c13',gold)
    }
    top,left,right,edge = tones[color]
    parts.append(f'<g transform="translate({x} {y}) scale({size/50})">')
    parts.append(f'<path d="M0 -55 L50 -27 L0 1 L-50 -27 Z" fill="{top}" stroke="{edge}" stroke-width="1.5"/>')
    parts.append(f'<path d="M-50 -27 L0 1 L0 58 L-50 30 Z" fill="{left}" stroke="{edge}" stroke-width="1.5"/>')
    parts.append(f'<path d="M0 1 L50 -27 L50 30 L0 58 Z" fill="{right}" stroke="{edge}" stroke-width="1.5"/>')
    parts.append(f'<g transform="translate(10 6) skewY(-29)" fill="none" stroke="{edge}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">')
    if kind == 'agent':
        parts.append('<circle cx="15" cy="10" r="6"/><path d="M4 31 V27 C4 16 26 16 26 27 V31"/>')
    elif kind == 'wallet':
        parts.append('<rect x="1" y="3" width="28" height="27" rx="2"/><path d="M21 12 H30 V22 H21 Z"/><circle cx="25" cy="17" r="1"/>')
    elif kind == 'payment':
        parts.append('<path d="M1 10 H27 L22 5 M27 10 L22 15 M29 26 H3 L8 21 M3 26 L8 31"/>')
    else:
        parts.append('<path d="M1 4 H28 V32 H1 Z M7 11 H22 M7 18 H22 M7 25 H17"/>')
    parts.append('</g></g>')


# Bitboy's classic mark, via Wikimedia Commons, is public domain.
# Keep its original orange and white; the rest follows the CloK palette.
logo = (root / 'tools/assets/bitcoin-logo.svg').read_text()
logo = logo[logo.index('<g '):logo.rindex('</svg>')]
def bitcoin(x, y, size):
    parts.append(f'<g transform="translate({x} {y}) scale({size / 64})">{logo}</g>')

parts.append('<metadata>Bitcoin logo: Bitboy; SVG via https://commons.wikimedia.org/wiki/File:Bitcoin.svg ; public domain. Retrieved 2026-10-08.</metadata>')

parts.append('<g class="wide">')
bitcoin(24,12,46)
txt(87,46,'BITCOIN',22,'mono','start')
txt(976,46,'TRANSACTION → BLOCK',17,'mono muted','end')
for x,fill,stroke in [(0,'#14111b','#322a40'),(365,'#17150f','#3b3325'),(730,'#17150f','#3b3325')]:
    box(x,90,270,240,fill,stroke)
txt(22,125,'01  BROADCAST',17,'mono purple','start')
txt(387,125,'02  MINE',17,'mono gold','start')
txt(752,125,'03  VERIFY',17,'mono gold','start')
cube(135,194,34,'wallet','purple')
cube(500,194,34,'ledger','gold')
cube(865,194,34,'ledger','gold')
path('M177 194 H458','purple')
txt(316,174,'relay transaction',18,'purple')
path('M542 194 H823','gold')
txt(682,174,'broadcast block',18,'gold')
txt(135,267,'Alice → peers',25)
txt(500,267,'Miners',25)
txt(865,267,'Full nodes',25)
txt(135,303,'signed payment',18,'muted')
txt(500,303,'transactions + header',18,'muted')
txt(865,303,'check proof + transactions',18,'muted')

box(0,367,1000,338,'#10141a','#30363f')
txt(24,406,'FIND A VALID HASH',17,'mono gold','start')
txt(976,406,'target set by network rules',18,'muted','end')
box(24,475,310,201,'#211c13','#51452f')
txt(45,507,'CANDIDATE HEADER',16,'mono gold','start')
txt(45,547,'previous block hash',21,'','start')
txt(45,581,'Merkle root of transactions',19,'','start')
txt(45,618,'nonce · time · target · …',20,'','start')
txt(45,652,'vary the nonce / other data',18,'muted','start')
box(425,504,225,84,'#17150f','#51452f')
txt(537,539,'SHA-256 twice',23,'gold')
txt(537,570,'a new hash each trial',17,'muted')
box(744,504,230,84,'#17150f','#51452f')
txt(859,554,'hash ≤ target?',24,'gold')
path('M335 546 H420','gold')
path('M651 546 H739','gold')
# A failed hash sends the miner back to change the candidate header.
path('M859 503 V454 H180 V469','gold')
txt(520,442,'No: change header and try again',19,'muted')
path('M859 589 V625','gold')
txt(859,658,'Yes: broadcast block',20,'gold')

box(0,743,1000,249,'#10141a','#30363f')
txt(24,782,'CHANGING AN EARLIER PAYMENT',17,'mono gold','start')
for x,top,bottom in [(24,'Change a payment','new Merkle root'),(377,'Update next header','new parent hash'),(730,'Update next header','new parent hash')]:
    box(x,817,246,93,'#211c13','#51452f')
    txt(x+123,855,top,21)
    txt(x+123,889,bottom,18,'muted')
path('M272 864 H370','gold')
path('M625 864 H724','gold')
txt(321,844,'new hash',16,'gold')
txt(673,844,'new hash',16,'gold')
txt(500,958,'Redo proof of work for every affected block.',23,'gold')
txt(500,1031,'Then overtake the honest chain, which keeps growing.',21,'muted')
parts.append('</g><g class="compact">')
bitcoin(34,12,68)
txt(126,65,'BITCOIN',43,'mono','start')
for y,fill,stroke in [(105,'#14111b','#322a40'),(265,'#17150f','#3b3325'),(425,'#17150f','#3b3325')]:
    box(25,y,950,133,fill,stroke)
for y,kind,color in [(170,'wallet','purple'),(330,'ledger','gold'),(490,'ledger','gold')]:
    cube(113,y,34,kind,color)
txt(210,156,'Broadcast: Alice → peers',43,'','start')
txt(210,211,'Relay the signed payment',40,'purple','start')
path('M113 240 V262','purple')
txt(210,316,'Mine: build a candidate block',43,'','start')
txt(210,371,'Search for a valid header hash',39,'gold','start')
path('M113 400 V422','gold')
txt(210,476,'Verify: full nodes check it',43,'','start')
txt(210,531,'Proof of work + transactions',39,'gold','start')
box(25,591,950,200,'#10141a','#30363f')
txt(500,638,'prev hash + tx root + nonce + …',40,'gold')
txt(500,694,'↓ SHA-256 twice',46)
txt(500,752,'hash ≤ target? Share; otherwise retry.',40,'gold')
box(25,824,950,199,'#10141a','#30363f')
txt(500,871,'Change an old payment',45)
txt(500,924,'→ redo its proof and every later proof',39,'gold')
txt(500,980,'→ overtake the growing honest chain',39,'muted')
parts.append('</g></svg>\n')
(root / 'docs/assets/bitcoin-proof-of-work.svg').write_text(''.join(parts))
