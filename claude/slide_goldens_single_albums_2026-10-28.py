# 2026-10-28 (Eden): copy of "% of the Album's Goldens Collected, by % of Album Time" (slide h621288aadfa9fec0_0_2399) with single albums
# instead of averages: Dice 63, Domino 20 (Hard + Easy), Disney 15. New slide sg1_slide right after the original. Lines are re-shaped in place.
# Data: goldens_decile_d63_s15_2026-10-28.sql (Dice 63, Disney 15); domino_easy_goldens_progression_2026-10-26.sql (Domino 20).
import json, sys
SRC, NEW, P = 'h621288aadfa9fec0_0_2399', 'sg1_slide', 'sg1_'
D63 = [0, 16.7, 26.8, 30.4, 33.8, 40.9, 47.7, 58.4, 79.1, 90.6, 93.0]
H20 = [0, 6, 12, 20, 29, 48, 58, 70, 82, 88, 94]
E20 = [0, 5, 10, 14, 22, 39, 51, 64, 77, 82, 89]
S15 = [0, 8.5, 18.3, 20.6, 29.2, 42.6, 53.3, 58.7, 71.9, 78.8, 82.5]
Y0, Y100, SEG = 3891280, 1938020, 198000
X0 = {'dice': 952500, 'dom': 3695700, 'dis': 6438900}
series = {'dice_s': D63, 'dom_s': H20, 'dom_e': E20, 'dis_s': S15,
          'dom_dice_d': D63, 'dis_dice_d': D63, 'dice_dom_d': H20, 'dis_dom_d': H20, 'dice_dis_d': S15, 'dom_dis_d': S15}
Y = lambda v: Y0 - v / 100 * (Y0 - Y100)
els = json.load(open(sys.argv[1]))['content']['pageElements']
R = [{'duplicateObject': {'objectId': SRC, 'objectIds': {SRC: NEW, **{e['objectId']: P + e['objectId'] for e in els}}}},
     {'updateSlidesPosition': {'slideObjectIds': [NEW], 'insertionIndex': 41}}]
tr = lambda o, sx, sy, x, y: R.append({'updatePageElementTransform': {'objectId': P + o, 'applyMode': 'ABSOLUTE',
     'transform': {'scaleX': sx, 'scaleY': sy, 'shearX': 0, 'shearY': 0, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}})
for name, v in series.items():
    x0 = X0[name.split('_')[0]]
    for i in range(10):
        dy = Y(v[i]) - Y(v[i + 1])
        tr(f'gs_{name}{i}', 0.066, -max(dy, 1) / 3000000, x0 + i * SEG, Y(v[i]))
cx = lambda g: X0[g] + 10 * SEG
for o, g, v in (('gs_dice_dot', 'dice', 93.0), ('gs_dom_dot', 'dom', 94), ('gs_dom_edot', 'dom', 89), ('gs_dis_dot', 'dis', 82.5)):
    tr(o, 0.022, 0.022, cx(g) - 33000, Y(v) - 33000)
def rep(a, b): R.append({'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [NEW]}})
rep('94%', '93%'); rep('90%', '94%'); rep('82%', '89%')
rep('Average paying player · Domino: Hard (orange, 8–10% of payers, 42–48% of album revenue) and Easy (gold, 90–92%, 52–58%), albums 17/19/20',
    'Average paying player, single albums · Domino 20: Hard (orange, 8,825 · 8% of payers) and Easy (gold, 97,937 · 92%)')
rep('Domino Easy payers trail Hard by about 7 points from early in the album (59% vs 66% at 70%); the gap is in Goldens and Royals, not commons.',
    'Domino 20 Easy trails Hard all album (64% vs 70% at 70% of the album) and ends at 89% vs 94%; Dice 63 ends at 93%, Disney 15 at 83%.')

R.append({'updatePageElementTransform': {'objectId': P + 'gs_dom_elbl', 'applyMode': 'RELATIVE', 'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': 0, 'translateY': 60000, 'unit': 'EMU'}}})
rep('of 28 Goldens', 'Album 63 · of 28 Goldens')
rep('Hard · Easy · Album 63 · of 28 Goldens', 'Album 20 · Hard · Easy · of 28 Goldens')
rep('of 24 Goldens', 'Album 15 · of 24 Goldens')
json.dump(R, open(sys.argv[2], 'w'), separators=(',', ':'))
print(len(R))
