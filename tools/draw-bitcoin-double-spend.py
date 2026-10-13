"""Draw Bitcoin double spending and proof of work using the shared diagram geometry."""
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
parts = ['''<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="850" viewBox="0 0 1000 850" role="img" aria-labelledby="title description">
<title id="title">Bitcoin — one input, two competing payments</title>
<desc id="description">Alice signs Tx1 to Bob and Tx2 to Carol, each spending the same unspent output u. Nodes check signatures and unspent inputs. Two valid branches can contain different spends, but a valid chain cannot include both. Nodes follow the valid branch with the greatest accumulated proof of work. The illustrated blocks have equal difficulty.</desc>
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
parts.append('</defs><rect width="1000" height="850" fill="#0a0a0f"/>')

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
txt(976,46,'ONE INPUT · TWO PAYMENTS',17,'mono muted','end')
box(0,90,560,285,'#14111b','#322a40')
box(690,90,310,285,'#17150f','#3b3325')
txt(24,124,'01  DOUBLE SPEND',17,'mono purple','start')
txt(714,124,'02  VERIFY',17,'mono gold','start')
cube(100,210,36,'wallet','purple')
txt(100,282,'Alice',26)
txt(100,312,'output u',20,'purple')
path('M145 210 H208 V184 H280','purple')
path('M208 210 V285 H280','purple')
txt(243,245,'signs',17,'purple')
for y,label in [(148,'Tx1 → Bob'),(251,'Tx2 → Carol')]:
    box(285,y,250,76,'#1d1826','#50445e')
    txt(410,y+31,label,24)
    txt(410,y+59,'spends output u',18,'purple')
txt(280,352,'Both signatures can be valid.',20,'muted')
path('M536 186 H617 V235 H683','gold')
path('M536 289 H617 V235','gold',arrow=False)
txt(621,166,'broadcast',16,'gold')
for x,y in [(747,218),(845,187),(943,218)]:
    cube(x,y,24,'ledger','gold')
path('M773 210 L817 192','gold',arrow=False)
path('M872 192 L917 210','gold',arrow=False)
path('M774 236 H916','gold',arrow=False)
txt(845,301,'Nodes check signatures',20)
txt(845,333,'and unspent inputs.',20,'muted')

box(0,416,1000,374,'#10141a','#30363f')
txt(24,453,'03  PROOF OF WORK',17,'mono gold','start')
txt(976,453,'equal difficulty in this example',17,'muted','end')
cube(105,621,37,'ledger','gold')
txt(105,699,'Shared',22)
txt(105,726,'history',22)
for x in (290,550,810):
    box(x,512,165,80,'#211c13','#655534')
    txt(x+82,543,'PoW block',21,'gold')
    txt(x+82,574,'Tx1 → Bob' if x==290 else '…',21)
# Parent-hash references point back towards the common history.
path('M290 552 H215 V608 H148','gold')
path('M550 552 H458','gold')
path('M810 552 H718','gold')
txt(505,533,'hash',16,'muted')
txt(765,533,'hash',16,'muted')
txt(975,625,'More accumulated work → followed by nodes',20,'gold','end')
box(290,673,165,80,'#11171e','#3e4854')
txt(372,704,'PoW block',21,'muted')
txt(372,735,'Tx2 → Carol',21,'muted')
path('M290 713 H215 V635 H148','gold')
txt(488,720,'Less accumulated work',20,'muted','start')
txt(500,830,'A valid chain can contain at most one spend of output u.',22)
parts.append('</g><g class="compact">')
bitcoin(34,12,68)
txt(126,65,'BITCOIN',43,'mono','start')
box(25,105,950,218,'#14111b','#322a40')
txt(500,160,'Alice owns one unspent output: u',43)
path('M500 177 V189 H255 V210','purple')
path('M500 189 H745 V210','purple')
for x,label in [(55,'Tx1 → Bob'),(550,'Tx2 → Carol')]:
    box(x,213,395,87,'#1d1826','#50445e')
    txt(x+197,250,label,44)
    txt(x+197,286,'spends u',38,'purple')
box(25,353,950,135,'#17150f','#3b3325')
cube(113,422,34,'ledger','gold')
txt(210,405,'Nodes check signatures',43,'','start')
txt(210,458,'and unspent inputs.',41,'gold','start')
box(25,518,950,265,'#10141a','#30363f')
txt(59,565,'PROOF OF WORK',38,'mono gold','start')
txt(940,565,'equal difficulty',34,'muted','end')
box(63,640,142,69,'#211c13','#655534')
txt(134,685,'parent',36,'gold')
for x in (327,580,833):
    box(x,603,120,64,'#211c13','#655534')
    txt(x+60,646,'Tx1' if x==327 else '…',38,'gold')
path('M327 635 H268 V665 H208','gold')
path('M580 635 H450','gold')
path('M833 635 H703','gold')
box(327,703,120,64,'#11171e','#3e4854')
txt(387,746,'Tx2',38,'muted')
path('M327 735 H268 V686 H208','gold')
txt(578,751,'Tx1 branch: more work',35,'gold','start')
txt(500,832,'Only one spend of u in a valid chain.',42)
parts.append('</g></svg>\n')
(root / 'docs/assets/bitcoin-double-spend.svg').write_text(''.join(parts))
