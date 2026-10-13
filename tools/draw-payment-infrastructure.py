"""Draw authorization, settlement, and billing mechanisms from official sources.

AP2: v0.2, revision e1ea56db72a6385bce3e5c1112b3a56ce60acb43.
Circle Gateway and Nevermined: documentation consulted 2026-10-09.
The prices and balances are illustrative, with fees excluded.
"""
from pathlib import Path
from runpy import run_path

shared = run_path(str(Path(__file__).with_name('draw-learning-figures.py')))
Drawing = shared['Drawing']
INK, MUTED, BLUE, PURPLE, GOLD = (shared[key] for key in
                                ['INK', 'MUTED', 'BLUE', 'PURPLE', 'GOLD'])


def ap2_authorization():
    d = Drawing(
        'ap2-authorization', 1100, 'AP2 authorization evidence',
        'Autonomous purchase under AP2 v0.2, revision e1ea56d. Illustrative '
        'terms: a user approves a report purchase up to USD 1.00; the merchant '
        'offers a report for USD 0.60. User-approved open mandates constrain '
        'the agent key. The agent signs closed Checkout and Payment Mandates '
        'bound to the merchant-signed checkout. The merchant checks the '
        'checkout and constraints. The credential provider verifies payment '
        'authorization and issues a scoped credential; the payment processor '
        'checks its scope. The merchant and processor return signed receipts. '
        'This is an evidence diagram, not a complete message sequence.')
    d.add('<g class="wide">')
    d.text(24, 44, 'AP2 authorization evidence', 34)
    d.text(24, 84, 'Autonomous purchase · AP2 v0.2 · illustrative terms', 23, MUTED)
    for x, title, first, second, color in [
        (24, 'User approval', 'Open mandates · limit USD 1.00',
         'Trusted Surface · agent public key', PURPLE),
        (536, 'Merchant checkout', 'Report · USD 0.60',
         'Merchant-signed checkout', BLUE),
    ]:
        d.rect(x, 136, 440, 155, '#12141b', '#303541')
        d.text(x + 25, 180, title, 30, color)
        d.text(x + 25, 225, first, 25)
        d.text(x + 25, 267, second, 23, MUTED)
    d.path('M244 293 V368', PURPLE, 2, 'purple')
    d.text(266, 338, 'Delegate authority', 22, PURPLE)
    d.path('M756 293 V368', BLUE, 2, 'blue')
    d.text(734, 338, 'Supply checkout', 22, BLUE, 'end')

    d.rect(180, 378, 640, 150, '#1a1621', '#51425f')
    d.text(500, 422, 'Agent signs closed mandates', 30, PURPLE, 'middle')
    d.text(500, 467, 'Checkout Mandate + Payment Mandate', 26, INK, 'middle')
    d.text(500, 508, 'Both bind to the same checkout hash', 24, MUTED, 'middle')
    d.path('M244 530 V610', PURPLE, 2, 'purple')
    d.text(266, 576, 'Checkout evidence', 22, PURPLE)
    d.path('M756 530 V610', GOLD, 2, 'gold')
    d.text(734, 576, 'Payment evidence', 22, GOLD, 'end')

    for x, title, first, second, color in [
        (24, 'Merchant verifies', 'Checkout signature and hash',
         'Approved purchase constraints', BLUE),
        (536, 'Payment parties verify', 'Provider: payment authorization',
         'Processor: credential scope', GOLD),
    ]:
        d.rect(x, 620, 440, 162, '#12141b', '#303541')
        d.text(x + 25, 666, title, 29, color)
        d.text(x + 25, 711, first, 24)
        d.text(x + 25, 752, second, 24, MUTED)
    d.path('M244 784 V880', BLUE, 2, 'blue', dash=True)
    d.text(266, 838, 'Checkout receipt', 22, BLUE)
    d.path('M756 784 V880', GOLD, 2, 'gold', dash=True)
    d.text(734, 838, 'Payment receipt', 22, GOLD, 'end')
    d.rect(180, 890, 640, 112, '#12141b', '#303541')
    d.text(500, 934, 'Signed outcomes returned to the agent', 29, INK, 'middle')
    d.text(500, 974, 'Each receipt refers to its mandate', 24, MUTED, 'middle')
    d.text(500, 1070, 'Evidence relationships · payment processing has its own execution flow',
           23, MUTED, 'middle')
    d.add('</g>')

    d.add('<g class="compact">')
    d.text(24, 51, 'AP2 authorization evidence', 49)
    d.text(24, 103, 'Autonomous purchase · v0.2', 38, MUTED)
    cards = [
        ('Input: user approval', 'Open mandates · limit USD 1.00',
         'Trusted Surface · agent public key', PURPLE),
        ('Input: merchant checkout', 'Report · USD 0.60',
         'Merchant-signed checkout', BLUE),
        ('Agent signs closed mandates', 'Checkout and Payment Mandates',
         'Both bind to the checkout hash', PURPLE),
        ('Merchant verifies', 'Checkout signature and hash',
         'Approved purchase constraints', BLUE),
        ('Payment parties verify', 'Provider: payment authorization',
         'Processor: credential scope', GOLD),
        ('Signed receipts', 'Merchant: checkout outcome',
         'Processor: payment outcome', BLUE),
    ]
    for i, (title, first, second, color) in enumerate(cards):
        y = 134 + i * 153
        d.rect(24, y, 952, 137, '#12141b', '#303541')
        d.rect(25, y + 1, 5, 135, color, radius=0)
        d.text(54, y + 42, title, 44, color)
        d.text(54, y + 85, first, 39)
        d.text(54, y + 125, second, 37, MUTED)
    d.text(24, 1081, 'Evidence relationships · illustrative terms', 36, MUTED)
    d.add('</g>')
    d.save()


def gateway_settlement():
    d = Drawing(
        'gateway-batch-settlement', 800, 'Gateway balances through settlement',
        'Illustrative USDC balances for one buyer and one seller, excluding fees. '
        'Three API calls cost 0.003, 0.004, and 0.003 USDC, totaling 0.010 USDC. '
        'Before requests: buyer available 1.000, seller pending 0, seller '
        'available 0. After Gateway accepts the payments: buyer available '
        '0.990, seller pending 0.010, seller available 0. After batch '
        'confirmation: buyer available 0.990, seller pending 0, seller available '
        '0.010. The service can return before batch confirmation. Based on '
        'Circle Gateway batching documentation consulted 9 October 2026.')
    states = [
        ('Before requests', ['1.000', '0.000', '0.000']),
        ('Requests accepted', ['0.990', '0.010', '0.000']),
        ('Batch confirmed', ['0.990', '0.000', '0.010']),
    ]
    d.add('<g class="wide">')
    d.text(24, 43, 'Gateway balances through settlement', 34)
    d.text(24, 84, 'Illustrative USDC amounts · one buyer and seller · fees excluded', 23, MUTED)
    d.rect(24, 120, 952, 78, '#17150f', '#3b3325')
    d.text(500, 171, '0.003 + 0.004 + 0.003 = 0.010 USDC', 34, GOLD, 'middle')
    d.path('M166 285 V249 H464 V285', GOLD, 2, 'gold')
    d.text(315, 236, 'Accept requests', 23, GOLD, 'middle')
    d.path('M536 285 V249 H834 V285', GOLD, 2, 'gold')
    d.text(685, 236, 'Confirm batch', 23, GOLD, 'middle')
    for i, (title, values) in enumerate(states):
        x = 24 + i * 334
        d.rect(x, 296, 284, 256, '#12141b', '#303541')
        d.text(x + 142, 338, title, 26, GOLD, 'middle')
        d.path(f'M{x + 18} 359 H{x + 266}', '#303541', 1)
        for j, (label, value) in enumerate(zip(
                ['Buyer available', 'Seller pending', 'Seller available'], values)):
            y = 404 + j * 59
            d.text(x + 18, y, label, 21, MUTED)
            d.text(x + 266, y + 1, value, 28, INK, 'end')
    d.rect(24, 598, 952, 151, '#111d27', '#365366')
    d.text(51, 642, 'Service response', 26, BLUE)
    d.text(379, 642, 'After Gateway accepts the payment', 26)
    d.path('M51 670 H949', '#303541', 1)
    d.text(51, 714, 'Onchain confirmation', 26, GOLD)
    d.text(379, 714, 'Seller funds become available', 26)
    d.text(500, 791, 'Circle Gateway batching documentation · 9 October 2026', 22, MUTED, 'middle')
    d.add('</g>')

    d.add('<g class="compact">')
    d.text(24, 48, 'Gateway balances · USDC', 49)
    d.text(24, 95, 'Three charges total 0.010 · fees excluded', 36, MUTED)
    for i, (title, values) in enumerate(states):
        y = 122 + i * 205
        d.rect(24, y, 952, 177, '#12141b', '#303541')
        d.text(52, y + 42, title, 44, GOLD)
        for j, (label, value) in enumerate(zip(
                ['Buyer available', 'Seller pending', 'Seller available'], values)):
            yy = y + 82 + j * 40
            d.text(52, yy, label, 40, MUTED)
            d.text(943, yy, value, 45, INK, 'end')
        if i < 2:
            d.path(f'M500 {y + 179} V{y + 201}', GOLD, 2, 'gold')
    d.text(24, 752, 'Service may return before batch confirmation.', 36, BLUE)
    d.text(24, 796, 'Illustrative balances · Circle docs, 9 Oct 2026', 34, MUTED)
    d.add('</g>')
    d.save()


def nevermined_billing():
    d = Drawing(
        'nevermined-billing', 880, 'Nevermined billing models',
        'Illustrative prices for one successful API call. Prepaid: buy '
        '100 credits for USD 1.00, verify that three credits are available, '
        'execute the service, and redeem three credits, leaving 97. '
        'Pay-as-you-go: authorize a payment method, verify the terms, execute '
        'the service, and charge USD 0.03, with a payment receipt. Credits are '
        'units of plan usage; USD is the payment currency. Based on Nevermined '
        'documentation consulted 9 October 2026.')
    d.add('<g class="wide">')
    d.text(24, 44, 'Nevermined billing models', 34)
    d.text(24, 84, 'Illustrative prices · one successful API call', 23, MUTED)
    for x, title, price, steps in [
        (24, 'Prepaid credits', 'USD 1.00 buys 100 credits', [
            ('Buy a plan', 'Balance: 100 credits', GOLD),
            ('Verify permissions', '3 credits available for this call', PURPLE),
            ('Execute the service', 'One API call', BLUE),
            ('Settle usage', '100 − 3 = 97 credits remaining', GOLD),
        ]),
        (536, 'Pay-as-you-go', 'USD 0.03 per request', [
            ('Authorize payment method', 'Permission to charge', PURPLE),
            ('Verify permissions', 'Payment terms accepted', PURPLE),
            ('Execute the service', 'One API call', BLUE),
            ('Charge and return receipt', 'USD 0.03 charged', GOLD),
        ]),
    ]:
        d.rect(x, 123, 440, 666, '#101219', '#303541')
        d.text(x + 25, 167, title, 31, BLUE)
        d.text(x + 25, 207, price, 25, MUTED)
        for i, (action, detail, color) in enumerate(steps):
            y = 236 + i * 138
            d.rect(x + 18, y, 404, 105, '#181a22', '#303541')
            d.text(x + 38, y + 40, action, 27, color)
            d.text(x + 38, y + 80, detail, 24)
            if i < 3:
                d.path(f'M{x + 220} {y + 107} V{y + 131}', color, 2,
                       'purple' if color == PURPLE else 'blue' if color == BLUE else 'gold')
    d.text(500, 838, 'Credits measure plan usage; USD records the payment amount.',
           25, MUTED, 'middle')
    d.text(500, 876, 'Nevermined documentation · 9 October 2026', 22, MUTED, 'middle')
    d.add('</g>')

    d.add('<g class="compact">')
    d.text(24, 51, 'Nevermined billing models', 49)
    d.text(24, 103, 'Illustrative prices · one successful call', 36, MUTED)
    for y, title, lines in [
        (143, 'Prepaid credits', [
            'Buy 100 credits for USD 1.00',
            'Verify 3 credits → execute service',
            'Settle usage: 100 → 97 credits',
            'Payment occurs when the plan is bought',
        ]),
        (501, 'Pay-as-you-go', [
            'Authorize a payment method',
            'Verify terms → execute service',
            'Charge USD 0.03 → return receipt',
            'A charge for each successful request',
        ]),
    ]:
        d.rect(24, y, 952, 320, '#12141b', '#303541')
        d.text(52, y + 51, title, 49, BLUE)
        for i, line in enumerate(lines):
            d.text(52, y + 111 + i * 58, line, 39 if i == 3 else 43,
                   MUTED if i == 3 else GOLD if i == 2 else INK)
    d.text(24, 873, 'Nevermined documentation · 9 October 2026', 35, MUTED)
    d.add('</g>')
    d.save()


if __name__ == '__main__':
    ap2_authorization()
    gateway_settlement()
    nevermined_billing()
