"""Draw the x402 v2 HTTP authorization flow from the pinned specification."""
from pathlib import Path
from runpy import run_path

shared = run_path(str(Path(__file__).with_name('draw-learning-figures.py')))
Drawing = shared['Drawing']
INK, MUTED, BLUE, PURPLE, GOLD = (shared[key] for key in
                                ['INK', 'MUTED', 'BLUE', 'PURPLE', 'GOLD'])


def payment_flow():
    d = Drawing(
        'x402-payment-flow', 1360, 'Agent payment through x402',
        'Successful HTTP v2 exact EIP-3009 authorization flow, following x402 '
        'revision 7f2b2f1. The agent requests a resource. The server returns HTTP '
        '402 and PAYMENT-REQUIRED. The agent wallet checks spending policy and '
        'signs a transfer authorization, then retries with PAYMENT-SIGNATURE. '
        'The facilitator verifies the authorization. The server executes the '
        'service, then asks the facilitator to settle. The facilitator submits '
        'the token transfer to the chain. After confirmation, the server returns '
        'the resource and PAYMENT-RESPONSE. Verification alone does not move funds. '
        'This is the upstream protocol flow, not an implemented Lean client.')

    d.add('<g class="wide">')
    d.text(24, 42, 'Agent payment through x402', 34)
    d.text(24, 82, 'HTTP v2 · exact / EIP-3009 · authorization flow', 23, MUTED)
    lanes = [
        (130, 'Agent', 'with wallet', BLUE),
        (405, 'Resource server', 'paid service', BLUE),
        (680, 'Facilitator', 'verify and settle', GOLD),
        (900, 'Chain', 'token contract', GOLD),
    ]
    for x, title, detail, color in lanes:
        d.path(f'M{x} 195 V1242', '#303541', 1, dash=True)
        d.rect(x - 96, 120, 192, 75, '#12141b', '#303541')
        d.text(x, 151, title, 25, color, 'middle')
        d.text(x, 181, detail, 21, MUTED, 'middle')

    def message(x1, x2, y, label, color=BLUE, marker='blue', reply=False,
                detail=None):
        mid = (x1 + x2) / 2
        d.text(mid, y - (42 if detail else 17), label, 24, color, 'middle')
        if detail:
            d.text(mid, y - 14, detail, 19, INK, 'middle', mono=True)
        d.path(f'M{x1} {y} H{x2}', color, 2, marker, dash=reply)

    message(130, 405, 265, '1  Request resource')
    message(405, 130, 360, '2  402 Payment Required', reply=True,
            detail='PAYMENT-REQUIRED')

    d.rect(16, 405, 228, 89, '#1a1621', '#51425f')
    d.text(130, 440, '3  Check policy', 26, PURPLE, 'middle')
    d.text(130, 476, 'Sign authorization', 23, INK, 'middle')

    message(130, 405, 565, '4  Retry request', detail='PAYMENT-SIGNATURE')
    message(405, 680, 646, '5  /verify', GOLD, 'gold')
    message(680, 405, 714, 'Valid authorization', GOLD, 'gold', reply=True)

    d.rect(294, 752, 222, 71, '#111d27', '#365366')
    d.text(405, 796, '6  Execute service', 25, BLUE, 'middle')

    message(405, 680, 888, '7  /settle', GOLD, 'gold')
    message(680, 900, 956, 'Token transfer', GOLD, 'gold')
    message(900, 680, 1024, 'Confirmation', GOLD, 'gold', reply=True)
    message(680, 405, 1092, 'Settlement result', GOLD, 'gold', reply=True)
    message(405, 130, 1206, '8  200 OK + resource', reply=True,
            detail='PAYMENT-RESPONSE')

    d.path('M24 1274 H976', '#303541', 1)
    d.text(24, 1314, 'Successful authorization flow · x402 revision 7f2b2f1', 22, MUTED)
    d.add('</g>')

    # Preserve the same eight steps in a vertical layout at notebook phone widths.
    d.add('<g class="compact">')
    d.text(24, 50, 'Agent payment through x402', 49)
    d.text(24, 102, 'HTTP v2 · exact / EIP-3009', 38, MUTED)
    steps = [
        ('Agent → server', 'Request resource', None, BLUE),
        ('Server → agent', '402 Payment Required', 'PAYMENT-REQUIRED', BLUE),
        ('Agent wallet', 'Check policy and sign', 'Transfer authorization', PURPLE),
        ('Agent → server', 'Retry request', 'PAYMENT-SIGNATURE', BLUE),
        ('Server ↔ facilitator', '/verify', 'Valid authorization', GOLD),
        ('Resource server', 'Execute service', None, BLUE),
        ('Server → facilitator → chain', '/settle · token transfer', 'Confirmation returns to server', GOLD),
        ('Server → agent', '200 OK + resource', 'PAYMENT-RESPONSE', BLUE),
    ]
    for i, (actor, action, detail, color) in enumerate(steps):
        y = 140 + i * 144
        d.rect(24, y, 952, 130, '#12141b', '#303541')
        d.rect(25, y + 1, 5, 128, color, radius=0)
        d.text(52, y + 43, str(i + 1), 40, color)
        d.text(115, y + 38, actor, 40, color)
        d.text(115, y + 79, action, 45)
        if detail:
            d.text(115, y + 119, detail, 39, MUTED,
                   mono=detail.startswith('PAYMENT-'))
        if i < len(steps) - 1:
            d.path(f'M70 {y + 131} V{y + 142}', MUTED, 2)
    d.text(24, 1334, 'Successful authorization flow · 7f2b2f1', 39, MUTED)
    d.add('</g>')
    d.save()


if __name__ == '__main__':
    payment_flow()
