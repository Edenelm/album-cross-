# 2026-10-28 (Eden): Domino 19-only copy of "Share of Active Payers Who Bought a New Golden, per Day, Last 10 Days" (h621288aadfa9fec0_0_2520),
# placed right after it. Data: golden_buy_share_d65_d20_s15_2026-10-25.sql Domino section run for album 19 (results in domino-19-golden-buy-2026-10-28.md).
import json
SRC, NEW, P = 'h621288aadfa9fec0_0_2520', 'gb19_slide', 'gb19_'
V = [3.90, 4.87, 5.39, 3.81, 2.94, 2.78, 3.99, 6.26, 4.04, 2.33]   # d-10 .. d-1
X = lambda i: 3791585 + i * 199009
Y = lambda v: 3891280 - v * 244157.5
RED = {'red': 1, 'green': 0.0431, 'blue': 0.2784}; ORA = {'red': 0.9608, 'green': 0.6275, 'blue': 0.2902}
side = [f'h621288aadfa9fec0_0_{n}' for n in list(range(2524, 2543)) + list(range(2564, 2583))] + \
       [f'h30_{g}_grid{k}' for g in ('dice', 'disney') for k in range(3)] + \
       [f'h32_{g}_b{k}' for g in ('dice', 'disney') for k in range(9)] + ['h32_dice_dot', 'h32_disney_dot', 'h33_dice_note',
       'h33_dis_a', 'h33_dis_a_pt', 'h33_dis_b', 'h33_dis_b_pt']
side = [s for s in side if s not in ('h621288aadfa9fec0_0_2527', 'h621288aadfa9fec0_0_2543', 'h621288aadfa9fec0_0_2567', 'h621288aadfa9fec0_0_2583')]
mine = [f'h32_domino_b{k}' for k in range(9)] + ['h32_domino_dot', 'h33_dom_a', 'h33_dom_a_pt', 'h33_dom_b', 'h33_dom_b_pt']
R = [{'duplicateObject': {'objectId': SRC, 'objectIds': {SRC: NEW, **{o: P + o for o in side + mine}}}},
     {'updateSlidesPosition': {'slideObjectIds': [NEW], 'insertionIndex': 45}}]
R += [{'deleteObject': {'objectId': P + o}} for o in side]
def tr(o, sx, sy, x, y):
    R.append({'updatePageElementTransform': {'objectId': P + o, 'applyMode': 'ABSOLUTE',
              'transform': {'scaleX': sx, 'scaleY': round(sy, 5), 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}})
for i in range(9):
    tr(f'h32_domino_b{i}', 0.0663, (Y(V[i + 1]) - Y(V[i])) / 3000000, X(i), Y(V[i]))
    if i:
        col = RED if V[i + 1] < V[i] and i not in (0,) else ORA
        R.append({'updateLineProperties': {'objectId': P + f'h32_domino_b{i}', 'lineProperties': {'lineFill': {'solidFill': {'color': {'rgbColor': col}}}}, 'fields': 'lineFill'}})
tr('h32_domino_dot', 0.022, 0.022, X(9) - 33000, Y(V[9]) - 33000)
for lab, i in (('a', 2), ('b', 7)):
    tr(f'h33_dom_{lab}_pt', 0.0186, 0.0186, X(i) - 27900, Y(V[i]) - 27900)
    tr(f'h33_dom_{lab}', 0.3387, 0.0508, X(i) - 27900 - 480150, Y(V[i]) - 27900 - 190000)
def rep(a, b): R.append({'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [NEW]}})
rep('6 Box + 8 Box', '8 Box'); rep('8 Box\n', '8 Box + 6 Box\n') if False else None
rep('album 20', 'album 19'); rep('last day 3%', 'last day 2%')
print(json.dumps(R, separators=(',', ':'), ensure_ascii=False))
