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
def bar(S, k, val, scale=None):
    h = val / 100 * (scale or SCALE); x = X0[k]   # copies keep a 3000000 EMU base size: scale = real size / 3000000
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

BLUE, GREEN, WHITE = {'red': 0.424, 'green': 0.62, 'blue': 1}, {'red': 0.235, 'green': 0.784, 'blue': 0.659}, {'red': 0.961, 'green': 0.961, 'blue': 0.961}
def fill(oid, c):
    return [{'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': c}}}}, 'fields': 'shapeBackgroundFill.solidFill.color'}}]
def n6():   # why goals per spend level: one overall number hides the middle
    R = bars_slide('n6_slide',
        'Revenue Within 3 Stickers at Close−4: All Payers vs by Spend Level',
        'Dice 63 (blue) vs Disney 15 (green) · % of the group\'s revenue (up to close−4) from payers at ≤3 missing on close−4',
        'All payers: a small gap (54% vs 43%). By spend level: the same at the top, far behind in the middle (43% vs 23%). One goal for everyone hides it.',
        {'dice0': 54, 'dice1': 43, 'domino0': 68, 'domino1': 71, 'disney0': 43, 'disney1': 23},
        {k: ('Dice 63' if k.endswith('0') else 'Disney 15') for k in X0},
        {'dice0': 'All payers', 'dice1': 'All payers', 'domino0': 'Over $20', 'domino1': 'Over $20', 'disney0': '$2–5 a day', 'disney1': '$2–5 a day'},
        {k: (RED if k == 'disney1' else GREY) for k in X0}, msg_red='far behind in the middle (43% vs 23%)')
    for k in X0: R += fill(f'n6_slide_{k}_bar', BLUE if k.endswith('0') else GREEN)
    return R
def n0():   # opening, info only: spend levels across all games
    R = cards('n0_slide', 'Paying Players and Album Revenue by Spend Level, All Games',
        'Dice 63 + Domino 20 + Disney 15 together · spend level = album spend per day before the last quarter · standard-population payers',
        '2 in 3 payers spend $2 a day or less and bring 15% of revenue. The 13% who spend over $5 a day bring two thirds.',
        ['Spend level ($ a day)', 'Who', '% of paying players', '% of album revenue', 'Revenue per payer'],
        [['Over $20', 'Top spenders', '2%', '29%', '15× average'],
         ['$5–20', 'Strong payers', '11%', '37%', '3× average'],
         ['$2–5', 'Middle payers', '15%', '18%', 'About average'],
         ['$2 or less', 'Light payers', '66%', '15%', '1/5 of average'],
         ['$0', 'Paid only late', '6%', 'Under 1%', 'Close to 0']], msg_red='The 13% who spend over $5 a day bring two thirds.')
    for r in range(5):
        for c in range(5): R += color(f'n0_slide_c{r}{c}', GOLD if c == 3 else WHITE)
    return R

ROWS_UP = [['$0', 'Paid only late', '6%', 'Under 1%', 'Close to 0'],
           ['≤$2', 'Light payers', '66%', '15%', '1/5 of average'],
           ['$2–5', 'Middle payers', '15%', '18%', 'About average'],
           ['$5–20', 'Strong payers', '11%', '37%', '3× average'],
           ['>$20', 'Top spenders', '2%', '29%', '15× average']]   # low to high, same order as t5a / t5b
def reorder_opening():
    R = []
    for r, row in enumerate(ROWS_UP):
        for c, v in enumerate(row):
            R += txt(f'n0_slide_c{r}{c}', v) + txt(f'h621288aadfa9fec0_0_{3045 + 6 * r + c}', v)
    return R
def r1():   # end goal per spend level, Domino and Disney vs Dice 63
    R = cards('r1_slide', 'End Goal per Spend Level: Revenue Within 3 Stickers at Close−4',
        '% of the level\'s revenue (up to close−4) from payers at ≤3 missing on close−4 · goal = Dice 63 level (proposal; final numbers are a management decision)',
        'Domino 20 is at Dice\'s level: keep it. Disney is below in every level under $20: that is where to act.',
        ['Spend level ($ a day)', 'Goal (Dice 63)', 'Domino 20', 'Disney 15', 'Focus'],
        [['$0', 'No goal', '—', '—', '—'],
         ['≤$2', '35%', '30%', '10%', 'Smaller goal (sets)'],
         ['$2–5', '43%', '46%', '23%', 'Disney'],
         ['$5–20', '54%', '58%', '45%', 'Disney'],
         ['>$20', '68%', '72%', '71%', 'Keep']], msg_red=None)
    col_c = {(1, 2): RED, (1, 3): RED, (2, 3): RED, (3, 3): RED, (2, 2): GOLD, (3, 2): GOLD, (4, 2): GOLD, (4, 3): GOLD}
    for r in range(5):
        for c in range(5):
            R += color(f'r1_slide_c{r}{c}', col_c.get((r, c), GREY if r == 0 else WHITE))
    R += color('r1_slide_ms', WHITE)
    i = 'Domino 20 is at Dice\'s level: keep it. Disney is below in every level under $20: that is where to act.'.index('Disney is below')
    R += [{'updateTextStyle': {'objectId': 'r1_slide_ms', 'textRange': {'type': 'FIXED_RANGE', 'startIndex': i, 'endIndex': i + 41}, 'style': {'foregroundColor': {'opaqueColor': {'rgbColor': RED}}}, 'fields': 'foregroundColor'}}]
    return R
def box(S, oid, x, y, w, h, kind='TEXT_BOX'):
    return [{'createShape': {'objectId': oid, 'shapeType': kind, 'elementProperties': {'pageObjectId': S,
        'size': {'width': {'magnitude': int(w * E), 'unit': 'EMU'}, 'height': {'magnitude': int(h * E), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x * E), 'translateY': int(y * E), 'unit': 'EMU'}}}}]
def tbox(S, oid, x, y, w, h, t, size, c, bold=False):
    return box(S, oid, x, y, w, h) + [{'insertText': {'objectId': oid, 'text': t}},
        {'updateTextStyle': {'objectId': oid, 'textRange': {'type': 'ALL'}, 'style': {'fontFamily': 'Oswald', 'bold': bold, 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'foregroundColor': {'opaqueColor': {'rgbColor': c}}}, 'fields': 'fontFamily,bold,fontSize,foregroundColor'}}]
def r2():   # what to do, one card per game
    S = 'r2_slide'
    R = [{'createSlide': {'objectId': S, 'slideLayoutReference': {'predefinedLayout': 'BLANK'}}},
         {'updatePageProperties': {'objectId': S, 'pageProperties': {'pageBackgroundFill': {'solidFill': {'color': {'rgbColor': {'red': 0.129, 'green': 0.129, 'blue': 0.129}}}}}, 'fields': 'pageBackgroundFill'}}]
    R += tbox(S, S + '_ti', 0.61, 0.33, 8.8, 0.5, 'What to Do at the End of the Album: Domino and Disney', 24, WHITE)
    R += tbox(S, S + '_su', 0.61, 0.82, 8.8, 0.25, 'Goal = revenue within 3 stickers at close−4, per spend level (previous slide) · Adopt = use now · Test = Test vs Control first', 9.5, GREY)
    cards_ = [('dm', 0.61, 'Domino', {'red': 0.961, 'green': 0.627, 'blue': 0.29},
               'Album 20 reached the goal in 3 of 4 levels. Album 19 did not (3–31% below $20).',
               'Make album 20\'s end the standard. Track the goal per level every day from close−14; act when a level falls behind.', 'ADOPT'),
              ('ds', 5.14, 'Disney', {'red': 0.235, 'green': 0.784, 'blue': 0.659},
               'Below the goal in every level under $20. 26% of album revenue ends 4+ stickers away.',
               'Give $2–20 payers an extra sticker source from close−14, so they reach 3 missing when the lock opens.', 'TEST')]
    for k, x, name, gc, now, do, call in cards_:
        R += box(S, f'{S}_{k}_card', x, 1.25, 4.25, 3.0, 'ROUND_RECTANGLE')
        R += [{'updateShapeProperties': {'objectId': f'{S}_{k}_card', 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': {'red': 0.169, 'green': 0.169, 'blue': 0.169}}}},
               'outline': {'outlineFill': {'solidFill': {'color': {'rgbColor': {'red': 0.267, 'green': 0.267, 'blue': 0.267}}}}, 'weight': {'magnitude': 1, 'unit': 'PT'}}}, 'fields': 'shapeBackgroundFill.solidFill.color,outline.outlineFill.solidFill.color,outline.weight'}}]
        R += tbox(S, f'{S}_{k}_h', x + 0.25, 1.38, 2.6, 0.45, name, 20, gc, True)
        R += tbox(S, f'{S}_{k}_call', x + 2.85, 1.42, 1.15, 0.4, call, 16, GOLD, True)
        R += [{'updateParagraphStyle': {'objectId': f'{S}_{k}_call', 'textRange': {'type': 'ALL'}, 'style': {'alignment': 'END'}, 'fields': 'alignment'}}]
        R += tbox(S, f'{S}_{k}_nl', x + 0.25, 1.95, 3.75, 0.25, 'NOW', 9, GREY, True)
        R += tbox(S, f'{S}_{k}_now', x + 0.25, 2.17, 3.75, 0.75, now, 13, WHITE)
        R += tbox(S, f'{S}_{k}_dl', x + 0.25, 3.0, 3.75, 0.25, 'DO', 9, GREY, True)
        R += tbox(S, f'{S}_{k}_do', x + 0.25, 3.22, 3.75, 0.9, do, 13, WHITE)
    R += tbox(S, S + '_ms', 0.61, 4.45, 7.0, 0.3, 'Domino: keep what worked in album 20. Disney: bring the middle payers close before the lock opens.', 11, WHITE)
    R += tbox(S, S + '_ft', 7.78, 5.25, 1.72, 0.2, 'SuperPlay 2026', 8, {'red': 0.62, 'green': 0.62, 'blue': 0.62})
    return R

def s6a():   # topic 6: first week after close vs own pace, finished vs far, $2-20 a day
    S, SC = 's6a_slide', 1.8
    vals = {'dice0': 110, 'dice1': 52, 'domino0': 140, 'domino1': 49, 'disney0': 128, 'disney1': 59}
    R = dup('t5d_slide', S, T5D)
    R += txt(f'{S}_ti', 'Spend per Day in the Week After Close vs Own Album Pace, $2–20 a Day Payers')
    R += txt(f'{S}_su', 'Latest album · 7 days after the close day (next album days 2–8) · 100% = the player\'s own spend per day during the album · end status on close−1')
    msg = 'Payers who finish start the next album at full pace or more. Payers who end 4+ stickers away start at about half, in all three games.'
    R += txt(f'{S}_ms', msg) + color(f'{S}_ms', WHITE)
    i = msg.index('Payers who end')
    R += [{'updateTextStyle': {'objectId': f'{S}_ms', 'textRange': {'type': 'FIXED_RANGE', 'startIndex': i, 'endIndex': len(msg)}, 'style': {'foregroundColor': {'opaqueColor': {'rgbColor': RED}}}, 'fields': 'foregroundColor'}}]
    gcol = {'dice': BLUE, 'domino': {'red': 0.961, 'green': 0.627, 'blue': 0.29}, 'disney': GREEN}
    names = {'dice': 'Dice 63', 'domino': 'Domino 20', 'disney': 'Disney 15'}
    for k in X0:
        g = k[:-1]
        R += bar(S, k, vals[k], SC) + txt(f'{S}_{k}_v', f'{vals[k]}%') + txt(f'{S}_{k}_a', names[g])
        R += txt(f'{S}_{k}_l', 'finished' if k.endswith('0') else '4+ missing') + color(f'{S}_{k}_l', GOLD if k.endswith('0') else RED)
        R += fill(f'{S}_{k}_bar', gcol[g] if k.endswith('0') else {'red': 0.353, 'green': 0.353, 'blue': 0.353})
    y = BASE - SC
    R += box(S, f'{S}_ref', 0.9, y, 8.3, 0.012, 'RECTANGLE') + fill(f'{S}_ref', GOLD)
    R += [{'updateShapeProperties': {'objectId': f'{S}_ref', 'shapeProperties': {'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'outline.propertyState'}}]
    R += tbox(S, f'{S}_reft', 8.0, y - 0.27, 1.5, 0.25, 'own pace = 100%', 9, GOLD)
    return R
def s6b():   # topic 6: one after-album problem per game
    S = 's6b_slide'
    R = [{'createSlide': {'objectId': S, 'slideLayoutReference': {'predefinedLayout': 'BLANK'}}},
         {'updatePageProperties': {'objectId': S, 'pageProperties': {'pageBackgroundFill': {'solidFill': {'color': {'rgbColor': {'red': 0.129, 'green': 0.129, 'blue': 0.129}}}}}, 'fields': 'pageBackgroundFill'}}]
    R += tbox(S, S + '_ti', 0.61, 0.33, 8.8, 0.5, 'After the Album: One Gap per Game', 24, WHITE)
    R += tbox(S, S + '_su', 0.61, 0.82, 8.8, 0.25, 'Latest album · first week after close vs the player\'s own album pace · middle payers = $2–20 a day', 9.5, GREY)
    cards_ = [('dc', 0.61, 'Dice', BLUE, '110%', 'Finishers start slow', 'Finishers\' first week vs own pace (Domino 140%, Disney 128%). The grand prize lasts light and middle payers 4–8 days.'),
              ('dm', 3.56, 'Domino', {'red': 0.961, 'green': 0.627, 'blue': 0.29}, '40%', 'Far payers drop the most', '$5–20 payers who end 4+ away, first week vs own pace: the lowest of the three games (over $20: 22%).'),
              ('ds', 6.51, 'Disney', GREEN, '$729,995', 'The biggest far group', 'Far middle payers spent this much less than their own pace in one week (Dice $234,316, Domino $117,876).')]
    for k, x, name, gc, big, head, detail in cards_:
        R += box(S, f'{S}_{k}_card', x, 1.25, 2.85, 3.0, 'ROUND_RECTANGLE')
        R += [{'updateShapeProperties': {'objectId': f'{S}_{k}_card', 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': {'red': 0.169, 'green': 0.169, 'blue': 0.169}}}},
               'outline': {'outlineFill': {'solidFill': {'color': {'rgbColor': {'red': 0.267, 'green': 0.267, 'blue': 0.267}}}}, 'weight': {'magnitude': 1, 'unit': 'PT'}}}, 'fields': 'shapeBackgroundFill.solidFill.color,outline.outlineFill.solidFill.color,outline.weight'}}]
        R += tbox(S, f'{S}_{k}_h', x + 0.22, 1.37, 2.4, 0.4, name, 18, gc, True)
        R += tbox(S, f'{S}_{k}_big', x + 0.22, 1.8, 2.4, 0.6, big, 30, RED, True)
        R += tbox(S, f'{S}_{k}_head', x + 0.22, 2.5, 2.4, 0.35, head, 14, WHITE, True)
        R += tbox(S, f'{S}_{k}_det', x + 0.22, 2.9, 2.45, 1.2, detail, 11, GREY)
    R += tbox(S, S + '_ms', 0.61, 4.45, 7.0, 0.3, 'Each game has its own after-album gap. The end-of-album goal (topic 5) also protects the next album\'s first week.', 11, WHITE)
    R += tbox(S, S + '_ft', 7.78, 5.25, 1.72, 0.2, 'SuperPlay 2026', 8, {'red': 0.62, 'green': 0.62, 'blue': 0.62})
    return R

if __name__ == '__main__':
    print(json.dumps(globals()[sys.argv[1]](), ensure_ascii=False, separators=(',', ':')))
