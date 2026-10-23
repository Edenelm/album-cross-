"""ALBUM END: topic-5 'why adopt the <=3 at close-4 measure' slides (2026-10-24). Copies t5d_slide (bars) and t5c_slide (card rows),
then rewrites text and bar heights. Sources: topic5-end-lift-2026-10-24.md, topic5-sensitivity-2026-10-24.md, topic5-tiers-2026-10-23.md.
Usage: python3 slide_t5_story_2026-10-24.py <n1|n2|n5|n3|n4>  -> prints update_presentation requests (JSON)."""
import json, sys
E = 914400
BASE, SCALE = 3.95, 3.6          # t5d: baseline (in), inches per 100%
X0 = {'dice0': 1.25, 'dice1': 2.10, 'domino0': 4.30, 'domino1': 5.15, 'disney0': 7.35, 'disney1': 8.20}
OLD = {'dice0': 39, 'dice1': 54, 'domino0': 31, 'domino1': 55, 'disney0': 44, 'disney1': 43}   # t5d bar values
RED, GOLD, GREY = {'red': 1, 'green': 0.043, 'blue': 0.278}, {'red': 1, 'green': 0.875, 'blue': 0.522}, {'red': 0.741, 'green': 0.741, 'blue': 0.741}
T5D = ['ti', 'su', 'base', 'ms', 'ft'] + [f'{g}{j}_{p}' for g in ('dice', 'domino', 'disney') for j in (0, 1) for p in ('bar', 'v', 'a', 'l')]
T5C = ['ti', 'su', 'ms', 'ft'] + [f'h{i}' for i in range(5)] + [f'row{r}' for r in range(5)] + [f'c{r}{c}' for r in range(5) for c in range(5)]

def dup(src, new, parts):
    m = {src: new}; m.update({f'{src}_{p}': f'{new}_{p}' for p in parts})
    return [{'duplicateObject': {'objectId': src, 'objectIds': m}}]
def txt(oid, t):
    return [{'deleteText': {'objectId': oid, 'textRange': {'type': 'ALL'}}}, {'insertText': {'objectId': oid, 'text': t}}]
def color(oid, c):
    return [{'updateTextStyle': {'objectId': oid, 'textRange': {'type': 'ALL'}, 'style': {'foregroundColor': {'opaqueColor': {'rgbColor': c}}}, 'fields': 'foregroundColor'}}]
def bar(S, k, val):
    h = val / 100 * SCALE; x = X0[k]   # copies keep a 3000000 EMU base size: scale = real size / 3000000
    return [{'updatePageElementTransform': {'objectId': f'{S}_{k}_bar', 'applyMode': 'ABSOLUTE', 'transform': {'scaleX': 0.1981, 'scaleY': round(h * E / 3e6, 4), 'shearX': 0, 'shearY': 0, 'translateX': int(x * E), 'translateY': int((BASE - h) * E), 'unit': 'EMU'}}},
            {'updatePageElementTransform': {'objectId': f'{S}_{k}_v', 'applyMode': 'ABSOLUTE', 'transform': {'scaleX': 0.2591, 'scaleY': 0.0853, 'shearX': 0, 'shearY': 0, 'translateX': int((x - 0.1) * E), 'translateY': int((BASE - h - 0.3) * E), 'unit': 'EMU'}}}]
def bars_slide(S, title, sub, msg, vals, labels, caps, capcolors, msg_red=None):
    R = dup('t5d_slide', S, T5D) + txt(f'{S}_ti', title) + txt(f'{S}_su', sub) + txt(f'{S}_ms', msg)
    if msg_red:
        i = msg.index(msg_red)
        R += color(f'{S}_ms', {'red': 0.961, 'green': 0.961, 'blue': 0.961})
        R += [{'updateTextStyle': {'objectId': f'{S}_ms', 'textRange': {'type': 'FIXED_RANGE', 'startIndex': i, 'endIndex': i + len(msg_red)}, 'style': {'foregroundColor': {'opaqueColor': {'rgbColor': RED}}}, 'fields': 'foregroundColor'}}]
    else:
        R += color(f'{S}_ms', {'red': 0.961, 'green': 0.961, 'blue': 0.961})
    for k in X0:
        R += bar(S, k, vals[k]) + txt(f'{S}_{k}_v', f'{vals[k]}%') + txt(f'{S}_{k}_a', labels[k]) + txt(f'{S}_{k}_l', caps[k]) + color(f'{S}_{k}_l', capcolors[k])
    return R

def n1():
    return bars_slide('n1_slide',
        'Payers Within 3 Stickers at Close−4: Share of Payers vs Last-4-Days Revenue',
        'Latest album · grey = % of paying players at ≤3 missing on close−4 · colour = their % of revenue in the last 4 days (close−4 to close−1)',
        'A quarter of the payers bring two thirds of the last 4 days in Dice and Domino. In Disney only 12% are close.',
        {'dice0': 30, 'dice1': 64, 'domino0': 23, 'domino1': 67, 'disney0': 12, 'disney1': 51},
        {'dice0': 'Dice 63', 'dice1': 'Dice 63', 'domino0': 'Domino 20', 'domino1': 'Domino 20', 'disney0': 'Disney 15', 'disney1': 'Disney 15'},
        {k: ('of payers' if k.endswith('0') else 'of last 4 days') for k in X0},
        {k: (GREY if k.endswith('0') else GOLD) for k in X0}, msg_red='In Disney only 12% are close.')
def n2():
    return bars_slide('n2_slide',
        'Paying Players Within 3 Stickers, 6 vs 4 Days Before Close, Latest Album',
        '% of paying players at ≤3 missing · the last 3 stickers are locked until about 4 days before close',
        'When the lock opens, Dice and Domino payers are ready (6% → 30%, 2% → 23%). Disney payers are not (9% → 12%).',
        {'dice0': 6, 'dice1': 30, 'domino0': 2, 'domino1': 23, 'disney0': 9, 'disney1': 12},
        {'dice0': 'close−6', 'dice1': 'close−4', 'domino0': 'close−6', 'domino1': 'close−4', 'disney0': 'close−6', 'disney1': 'close−4'},
        {'dice0': 'Dice 63', 'dice1': 'Dice 63', 'domino0': 'Domino 20', 'domino1': 'Domino 20', 'disney0': 'Disney 15', 'disney1': 'Disney 15'},
        {k: (RED if k.startswith('disney') else GOLD) for k in X0}, msg_red='Disney payers are not (9% → 12%).')
def n5():
    return bars_slide('n5_slide',
        'Album Revenue from Middle Payers ($2–20 a Day) Who End 4+ Stickers Away',
        '% of paying players\' album revenue · middle payers = $2–20 a day before the last quarter · 4+ missing on close−1',
        'This is the money the ≤3 goal goes after. Dice and Domino cut it to 10–11% in one album; Disney still leaves 26%.',
        {'dice0': 18, 'dice1': 10, 'domino0': 28, 'domino1': 11, 'disney0': 26, 'disney1': 26},
        {'dice0': 'Dice 61', 'dice1': 'Dice 63', 'domino0': 'Domino 19', 'domino1': 'Domino 20', 'disney0': 'Disney 14', 'disney1': 'Disney 15'},
        {k: ('previous' if k.endswith('0') else 'latest') for k in X0},
        {k: (RED if (k.startswith('disney') or k.endswith('0')) else GOLD) for k in X0}, msg_red='Disney still leaves 26%.')

def cards(S, title, sub, msg, heads, rows, gold_row=None, msg_red=None):
    R = dup('t5c_slide', S, T5C) + txt(f'{S}_ti', title) + txt(f'{S}_su', sub) + txt(f'{S}_ms', msg)
    if msg_red:
        i = msg.index(msg_red)
        R += color(f'{S}_ms', {'red': 0.961, 'green': 0.961, 'blue': 0.961})
        R += [{'updateTextStyle': {'objectId': f'{S}_ms', 'textRange': {'type': 'FIXED_RANGE', 'startIndex': i, 'endIndex': i + len(msg_red)}, 'style': {'foregroundColor': {'opaqueColor': {'rgbColor': GOLD}}}, 'fields': 'foregroundColor'}}]
    for i, h in enumerate(heads): R += txt(f'{S}_h{i}', h)
    for r, row in enumerate(rows):
        for c, v in enumerate(row):
            R += txt(f'{S}_c{r}{c}', v)
            if r == gold_row: R += color(f'{S}_c{r}{c}', GOLD)
    return R
def n3():
    return cards('n3_slide', 'Revenue Share Before vs Last 4 Days, by Stickers Missing at Close−4',
        'Share of payers\' revenue held by the close group, before close−4 → in the last 4 days · a bigger jump = a better pointer to end money',
        '≤3 gives the biggest jump in 4 of 6 albums. It is also how the games are built: the last 3 stickers unlock about 4 days before close.',
        ['Missing at close−4', 'Dice 63', 'Domino 20', 'Disney 15', 'Read'],
        [['≤1', '11% → 18%', '15% → 23%', '2% → 5%', 'Too few players'],
         ['≤2', '28% → 39%', '29% → 41%', '10% → 17%', 'Few before the unlock'],
         ['≤3', '54% → 64%', '55% → 68%', '43% → 51%', 'Biggest jump'],
         ['≤5', '83% → 88%', '79% → 87%', '68% → 74%', 'Too many, jump shrinks'],
         ['≤8', '92% → 95%', '90% → 95%', '83% → 88%', 'Almost everyone']], gold_row=2)
def n4():
    return cards('n4_slide', 'Recommendation: One End Goal per Spend Level, All Games',
        'Adopt = use now · Test = run Test vs Control first · goal numbers per tier are a management decision',
        'Same measure in all three games; Dice already runs it. First money to chase: Disney\'s middle payers (26% of album revenue).',
        ['Step', 'What', 'When', 'Owner', 'Call'],
        [['1. One measure', 'Revenue within 3, close−4', 'Every album', 'Analytics', 'Adopt'],
         ['2. Daily goals', 'Goal per tier, every day', 'close−14 to −4', 'Analytics, LiveOps', 'Adopt'],
         ['3. Low tiers', '≤$2 a day: sets, not 144', 'Every album', 'Product', 'Adopt'],
         ['4. Disney middle', 'More stickers, $2–20 payers', 'close−14 to −4', 'Disney LiveOps', 'Test'],
         ['5. Measure it', 'Last-4-days revenue per payer', 'Album end', 'Analytics', 'Test']],
        msg_red='Disney\'s middle payers (26% of album revenue).')

if __name__ == '__main__':
    print(json.dumps(globals()[sys.argv[1]](), ensure_ascii=False, separators=(',', ':')))
