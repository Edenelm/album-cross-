"""t5ad_slide: copy of t5a_slide in the Domino deck, columns Domino 19 | Domino 20 | Dice 63.
Source: claude/end-status-d19-d20-dice63-2026-10-26.md. Usage: python3 c/slide_t5a_domino_2026-10-27.py <dup|edit>"""
import json, sys
P = 't5a_slide_'; N = 't5ad_'
IDS = ['ti','su','ms','ft','t0','tr0','t1','tr1','t2','tr2','t3','tr3','k0','kl0','k1','kl1','k2','kl2'] + \
      [f'g{c}' for c in range(3)] + [f'{k}{c}{r}' for k in 'fnrvl' for c in range(3) for r in range(4)]
W = 0.6858; Y = [1346200, 2057400, 2768600, 3479800]
COLS = {0: ('Domino 19', 1905000, [(2,8,90,14),(6,20,74,12),(14,33,53,16),(37,34,29,6)]),
        2: ('Dice 63',  6477000, [(7,54,39,4),(16,58,26,4),(20,59,21,6),(32,53,15,4)])}
def txt(o, t):
    return [{'deleteText': {'objectId': o, 'textRange': {'type': 'ALL'}}},
            {'insertText': {'objectId': o, 'text': t, 'insertionIndex': 0}}]
def tf(o, sx, x, y):
    return {'updatePageElementTransform': {'objectId': o, 'applyMode': 'ABSOLUTE', 'transform':
            {'scaleX': sx, 'scaleY': 0.1016, 'shearX': 0, 'shearY': 0, 'translateX': x, 'translateY': y, 'unit': 'EMU'}}}
if sys.argv[1] == 'dup':
    m = {'t5a_slide': 't5ad_slide', **{P+i: N+i for i in IDS}}
    print(json.dumps([{'duplicateObject': {'objectId': 't5a_slide', 'objectIds': m}}])); sys.exit()
R = []
R += txt(N+'ti', 'End Status of Payers by Spend Level: Domino 19, Domino 20, Dice 63')
R += txt(N+'su', 'Level = $ per day before the last quarter · standard-population payers · status on the day before close')
R += txt(N+'ms', 'Domino 20 left fewer payers far than Domino 19 at every level: $2–20 a day far = 11% of revenue (Domino 19: 28%, Dice 63: 10%).')
R += txt(N+'tr2', '36–37% of revenue')
for c, (name, x0, rows) in COLS.items():
    R += txt(f'{N}g{c}', name)
    for r, (fi, near, far, rev) in enumerate(rows):
        x = x0
        for k, p in zip('fnr', (fi, near, far)):
            sx = round(W * p / 100, 4); R.append(tf(f'{N}{k}{c}{r}', sx, x, Y[r])); x += sx * 3e6
        R += txt(f'{N}v{c}{r}', f'{far}%')
        R += txt(f'{N}l{c}{r}', f'far = {rev}% of revenue')
print(json.dumps(R))
