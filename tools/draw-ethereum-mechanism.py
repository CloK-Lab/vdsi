"""Ethereum mechanism diagram using the approved system diagram geometry."""
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
parts = ['''<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1060" viewBox="0 0 1000 1060" role="img" aria-labelledby="title description">
<title id="title">Ethereum — transactions, state, and blocks</title>
<desc id="description">A wallet signs and broadcasts a transaction. A proposer includes ordered transactions in a block. Other nodes execute them again and check the resulting state; validators attest. Execution reads the previous state and applies a transaction to produce the next state. Execution block headers contain a parent hash, a transaction root, and a state root. Hashing the encoded header gives the block hash; the next block stores it as its parent hash. Validator votes support fork choice and checkpoint finality.</desc>
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
parts.append('</defs><rect width="1000" height="1060" fill="#0a0a0f"/>')

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

parts.append('<g class="wide">')
txt(24,34,'ETHEREUM',19,'mono blue','start')
txt(976,34,'TRANSACTIONS · STATE · BLOCKS',16,'mono muted','end')
for x,w,fill,stroke in [(0,280,'#14111b','#322a40'),(335,310,'#17150f','#3b3325'),(700,300,'#17150f','#3b3325')]:
    box(x,68,w,280,fill,stroke)
txt(24,103,'01  SIGN',17,'mono purple','start')
txt(359,103,'02  PROPOSE',17,'mono gold','start')
txt(724,103,'03  VERIFY',17,'mono gold','start')
path('M185 169 H437','purple')
txt(304,149,'broadcast tx',18,'purple')
path('M535 169 H803','gold')
txt(669,149,'share block',18,'gold')
cube(140,169,38,'wallet','purple')
cube(490,169,38,'ledger','gold')
cube(850,169,38,'ledger','gold')
txt(140,244,'Wallet',27)
txt(490,244,'Proposed block',27)
txt(850,244,'Other nodes',27)
txt(140,281,'nonce · value · recipient',18,'muted')
txt(140,310,'signature · data · gas',18,'muted')
txt(490,281,'ordered transactions',18,'muted')
txt(490,310,'parent hash · state root',18,'muted')
txt(850,281,'re-execute · check state',18,'muted')
txt(850,310,'validators attest',18,'gold')

box(0,384,1000,205,'#10141a','#30363f')
txt(24,417,'STATE TRANSITION',17,'mono gold','start')
txt(976,417,'during block construction and validation',18,'muted','end')
path('M198 478 H452','gold')
txt(325,462,'read state',18,'gold')
path('M548 478 H802','gold')
txt(675,462,'apply tx',18,'gold')
cube(160,478,31,'ledger','gold')
cube(500,478,31,'payment','gold')
cube(840,478,31,'ledger','gold')
txt(160,540,'State S',24)
txt(500,540,'Execution',24)
txt(840,540,'State S′',24)
txt(160,570,'balances · nonces · storage',17,'muted')
txt(500,570,'value transfer / EVM',17,'muted')
txt(840,570,'updated account state',17,'muted')

txt(24,631,'BLOCK HASHES',17,'mono gold','start')
txt(976,631,'execution layer · selected fields',18,'muted','end')
for x,label,parent,digest in [(0,'Block n − 1','…','h0'),(360,'Block n','h0','h1'),(720,'Block n + 1','h1','h2')]:
    box(x,650,280,269,'#17150f','#3b3325')
    txt(x+140,687,label,25,'gold')
    box(x+14,707,252,143,'#211c13','#51452f')
    txt(x+30,733,'HEADER',14,'mono gold','start')
    txt(x+30,767,f'parent hash: {parent}',19,'','start')
    txt(x+30,800,'transaction root',19,'muted','start')
    txt(x+30,831,'state root · …',19,'muted','start')
    txt(x+30,877,'BODY',14,'mono gold','start')
    txt(x+30,905,'tx1 · tx2 · …',20,'','start')
    box(x,942,280,51,'#10141a','#51452f')
    txt(x+140,975,f'{digest} = hash(header)',21,'gold')
# A child header refers back to the hash computed from its parent's header.
path('M374 761 H320 V968 H281','gold')
path('M734 761 H680 V968 H641','gold')
txt(500,1041,'Validator votes → fork choice and checkpoint finality',20,'muted')
parts.append('</g><g class="compact">')
txt(34,44,'ETHEREUM',40,'mono blue','start')
for y,fill,stroke in [(70,'#14111b','#322a40'),(230,'#17150f','#3b3325'),(390,'#17150f','#3b3325')]:
    box(25,y,950,140,fill,stroke)
for y,kind,color in [(140,'wallet','purple'),(300,'ledger','gold'),(460,'ledger','gold')]:
    cube(115,y,36,kind,color)
txt(215,125,'Wallet signs a transaction',48,'','start')
txt(215,179,'recipient · value · nonce · gas',41,'purple','start')
path('M115 211 V226','purple')
txt(215,285,'Proposer builds a block',48,'','start')
txt(215,339,'ordered transactions + state root',41,'gold','start')
path('M115 371 V386','gold')
txt(215,445,'Other nodes verify it',48,'','start')
txt(215,499,'re-execute; validators attest',41,'gold','start')
box(25,554,950,143,'#10141a','#30363f')
txt(500,601,'State S + transaction → State S′',45,'gold')
txt(500,653,'Validator votes → head and finality',40,'muted')
for x,label,parent,digest in [(25,'Block n','h0','h1'),(550,'Block n + 1','h1','h2')]:
    box(x,723,425,268,'#17150f','#3b3325')
    txt(x+212,768,label,45,'gold')
    box(x+15,787,395,143,'#211c13','#51452f')
    txt(x+35,824,'HEADER',33,'mono gold','start')
    txt(x+35,870,f'parent hash: {parent}',40,'','start')
    txt(x+35,911,'tx root · state root · …',33,'muted','start')
    txt(x+212,973,'Body: tx1 · tx2 · …',40)
    txt(x+212,1040,f'{digest} = hash(header)',40,'gold')
path('M565 857 H503 V1029 H453','gold')
parts.append('</g></svg>\n')
(root / 'docs/assets/ethereum-mechanism.svg').write_text(''.join(parts))
