"""FU18 test story in the FINAL deck (1gHkK8mNPg5pDKwlIe3FdMSqq2UqQx2bPihgu4ve_mks), after tx_royal.
Six slides built by duplicating tx_end (title / box / measure / bottom line / footer) and adding native shapes.
Numbers: claude/domino-fu18-ab-test-2026-10-29.md (R1-R12) and claude/domino-fu18-cumulative-2026-10-29.md.
Prints the batchUpdate request list as JSON (sent with the Google Slides MCP update_presentation)."""
import json, sys
INS = int(sys.argv[1]) if len(sys.argv) > 1 else 82   # 0-based insertion index (after tx_royal)
OLD = {'ti': 'Domino Adopt: End Goal per Spend Level ', 'a1h': 'Domino: ADOPT',
       'a1b': 'Album 20 end as the standard; watch the goal per level daily from close−14.', 'ml': 'MEASURE',
       'mb': 'Watch daily from close−14: share within 3 stickers at close−4 per level vs album 20 · Guardrail: revenue per payer in the last 4 days',
       'bl': "Album 20's end left $2–20 payers far at 11% of album revenue vs 28% in album 19 — keep it as the standard."}
GOLD = {'red': 1, 'green': 0.8745098, 'blue': 0.52156866}; RED = {'red': 1, 'green': 0.043137256, 'blue': 0.2784314}
GREY = {'red': 0.42, 'green': 0.42, 'blue': 0.42}; LGREY = {'red': 0.74, 'green': 0.74, 'blue': 0.74}
WHITE = {'red': 0.96, 'green': 0.96, 'blue': 0.96}; BOX = {'red': 0.1686, 'green': 0.1686, 'blue': 0.1686}
R = []
def dup(code, k):
    ids = {'tx_end': code}
    for e in ['ti', 'ft', 'a1', 'a1h', 'a1b', 'ml', 'mb', 'bl']: ids[f'tx_end_{e}'] = f'{code}_{e}'
    R.append({'duplicateObject': {'objectId': 'tx_end', 'objectIds': ids}})
    R.append({'updateSlidesPosition': {'slideObjectIds': [code], 'insertionIndex': INS + k}})
def rep(code, e, new):
    R.append({'insertText': {'objectId': f'{code}_{e}', 'insertionIndex': 0, 'text': new}})
    R.append({'deleteText': {'objectId': f'{code}_{e}', 'textRange': {'type': 'FIXED_RANGE', 'startIndex': len(new), 'endIndex': len(new) + len(OLD[e])}}})
def dele(code, *es):
    for e in es: R.append({'deleteObject': {'objectId': f'{code}_{e}'}})
def el(page, x, y, w, h): return {'pageObjectId': page, 'size': {'width': {'magnitude': 3000000, 'unit': 'EMU'}, 'height': {'magnitude': 3000000, 'unit': 'EMU'}},
                                  'transform': {'scaleX': w / 3e6, 'scaleY': max(h, 1) / 3e6, 'translateX': x, 'translateY': y, 'unit': 'EMU'}}
def rect(page, oid, x, y, w, h, fill, outline=None):
    R.append({'createShape': {'objectId': oid, 'shapeType': 'RECTANGLE', 'elementProperties': el(page, x, y, w, h)}})
    sp = {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': fill}}}}
    sp['outline'] = {'outlineFill': {'solidFill': {'color': {'rgbColor': outline}}}, 'weight': {'magnitude': 12700, 'unit': 'EMU'}} if outline else {'propertyState': 'NOT_RENDERED'}
    R.append({'updateShapeProperties': {'objectId': oid, 'shapeProperties': sp, 'fields': 'shapeBackgroundFill,outline'}})
def text(page, oid, x, y, w, h, t, size, col, bold=False, align='START', valign='TOP'):
    R.append({'createShape': {'objectId': oid, 'shapeType': 'TEXT_BOX', 'elementProperties': el(page, x, y, w, h)}})
    R.append({'insertText': {'objectId': oid, 'text': t}})
    R.append({'updateTextStyle': {'objectId': oid, 'style': {'fontFamily': 'Oswald', 'bold': bold, 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'foregroundColor': {'opaqueColor': {'rgbColor': col}}}, 'fields': 'fontFamily,bold,fontSize,foregroundColor'}})
    R.append({'updateParagraphStyle': {'objectId': oid, 'style': {'alignment': align}, 'fields': 'alignment'}})
    R.append({'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'contentAlignment': valign}, 'fields': 'contentAlignment'}})
SUB_Y = 820000
# ---------- 1. the assumption ----------
c = 'fu1_slide'; dup(c, 0)
rep(c, 'ti', 'Album 18 Test: Easy FU at 3 vs 5 Locked Stickers')
rep(c, 'a1h', 'The assumption behind 5 locked')
rep(c, 'a1b', 'With only 3 locked, Easy players finish without paying, so album revenue falls. The FU deck read the test as −1.75% Easy revenue.')
rep(c, 'ml', 'THE TEST')
rep(c, 'mb', 'Album 18, last 8 days (Jun 28 – Jul 6) · Easy players split by user ID · 3 locked 626,792 vs 5 locked 628,564 · FU = all stickers except the locked ones')
rep(c, 'bl', 'We checked the assumption three ways: album revenue, who finished, and what came after.')
# ---------- 2. album revenue ----------
c = 'fu2_slide'; dup(c, 1); dele(c, 'a1', 'a1h', 'a1b', 'ml', 'mb')
rep(c, 'ti', 'Easy $ per Player, 3 vs 5 Locked: Before and During the Test')
text(c, c + '_su', 557784, SUB_Y, 8000000, 220000, 'Easy players level 35+ · 336,223 (3 locked) vs 336,942 (5 locked) · album spend per player · gap = 3 locked vs 5 locked', 10, LGREY)
tiles = [('−1.1%', 'Before the test\nMay 11 – Jun 27\n$15.43 vs $15.60', LGREY), ('−1.0%', 'During the test\nJun 28 – Jul 5\n$3.98 vs $4.02', LGREY),
         ('+0.2%', 'During the test, after\nremoving the gap that\nwas there before', GOLD)]
for i, (num, lab, col) in enumerate(tiles):
    x = 762550 + i * 2600000
    rect(c, f'{c}_b{i}', x, 1350000, 2300000, 2350000, BOX, WHITE if i == 2 else GREY)
    text(c, f'{c}_n{i}', x, 1550000, 2300000, 800000, num, 44, col, True, 'CENTER', 'MIDDLE')
    text(c, f'{c}_l{i}', x, 2450000, 2300000, 1000000, lab, 13, WHITE, False, 'CENTER')
rep(c, 'bl', '3 locked did not lower album revenue: the small gap was already there before the test.')
# ---------- 3. finishers and where the money went ----------
c = 'fu3_slide'; dup(c, 2); dele(c, 'a1', 'a1h', 'a1b', 'ml', 'mb')
rep(c, 'ti', 'Where Easy Test-Window Revenue Ended Up, by End State: 5 vs 3 Locked')
text(c, c + '_su', 557784, SUB_Y, 8000000, 220000, '% of each group’s Easy album spend Jun 28 – Jul 5, by stickers missing at the end of Jul 5 · small label = % of players, 5 locked → 3 locked', 10, LGREY)
ctrl = [29, 20, 38, 13]; tst = [42, 30, 17, 10]
names = ['Finished', '1–2 missing', '3–5 missing', '6+ missing']
pl = ['players 1.3% → 3.4% (2.6×)', 'players 2.5% → 7.6%', 'players 16.1% → 13.3%', 'players 80.1% → 75.8%']
B, k, bw = 3650000, 52000, 600000
for i in range(4):
    gx = 900000 + i * 1950000
    for j, (v, col) in enumerate([(ctrl[i], RED if i == 2 else GREY), (tst[i], GOLD)]):
        x = gx + j * (bw + 80000); h = int(v * k)
        rect(c, f'{c}_r{i}{j}', x, B - h, bw, h, col)
        text(c, f'{c}_v{i}{j}', x - 100000, B - h - 300000, bw + 200000, 280000, f'{v}%', 14, RED if (i == 2 and j == 0) else (GOLD if j else WHITE), True, 'CENTER', 'BOTTOM')
    text(c, f'{c}_g{i}', gx - 100000, B + 40000, 2 * bw + 280000, 230000, names[i], 12, WHITE, True, 'CENTER')
    text(c, f'{c}_p{i}', gx - 150000, B + 260000, 2 * bw + 380000, 220000, pl[i], 9, LGREY, False, 'CENTER')
rect(c, c + '_ax', 800000, B, 7700000, 6350, GREY)
text(c, c + '_lg', 6200000, 1150000, 2400000, 220000, '■ 5 locked   ■ 3 locked', 10, LGREY, False, 'END')
rep(c, 'bl', '3 locked finished 2.6× more players; 38% of the money under 5 locked was stuck at 3–5 missing.')
# ---------- 4. the revenue drop after the album ----------
c = 'fu4_slide'; dup(c, 3); dele(c, 'a1', 'a1h', 'a1b', 'ml', 'mb')
rep(c, 'ti', 'Easy $ per Player Gap, 3 vs 5 Locked, by Period')
text(c, c + '_su', 557784, SUB_Y, 8000000, 220000, 'A/B test definition: all Easy album-18 players · 626,792 vs 628,564 · in-app $ per player · gap = 3 locked vs 5 locked', 10, LGREY)
per = [('Usual gap\nMay 12 – Jul 2', -1.28, GREY), ('2 weeks after album 18\nJul 7 – 20', -5.36, RED), ('Album 19\nJul 21 – Aug 24', -2.62, GREY), ('2 weeks after album 19\nAug 25 – Sep 7', -0.62, GREY)]
Z, k = 1900000, 330000
for i, (lab, v, col) in enumerate(per):
    x = 1200000 + i * 1800000; h = int(-v * k)
    text(c, f'{c}_t{i}', x - 300000, 1250000, 1500000, 450000, lab, 11, WHITE, True, 'CENTER', 'BOTTOM')
    rect(c, f'{c}_r{i}', x, Z, 900000, h, col)
    text(c, f'{c}_v{i}', x - 200000, Z + h + 30000, 1300000, 300000, f'{v:+.1f}%'.replace('-', '−'), 16, RED if col == RED else WHITE, True, 'CENTER')
rect(c, c + '_ax', 900000, Z, 7300000, 6350, LGREY)
text(c, c + '_pa', 4200000, 3700000, 4300000, 300000, 'Payers per day in the 2 weeks after album 18: 1.28% vs 1.30% (same)', 10, LGREY, False, 'END')
rep(c, 'bl', 'The only revenue drop: about 4 points in the 2 weeks after album 18, beyond the usual ~1% gap; gone by album 19’s end.')
# ---------- 5. who: 72 days, by state before the test ----------
c = 'fu5_slide'; dup(c, 4); dele(c, 'a1', 'a1h', 'a1b', 'ml', 'mb')
rep(c, 'ti', 'Gap per Player Over 72 Days, by Stickers Missing Before the Test')
text(c, c + '_su', 557784, SUB_Y, 8000000, 220000, 'Jun 28 – Sep 7 (test start to 2 weeks after album 19) · in-app $ per player, 3 vs 5 locked, after removing each group’s before-test gap · state on Jun 27', 10, LGREY)
grp = [('All Easy players', '626,792 vs 628,564', -1.6, WHITE), ('At FU (3–5 missing)', '1.3% of players · 16% of revenue', -9.0, RED),
       ('6–10 missing', '4.5% of players · 32% of revenue', 2.0, GREY), ('11+ missing', '94% of players · 52% of revenue', -1.2, GREY)]
Z, k = 2050000, 170000
for i, (nm, sz, v, col) in enumerate(grp):
    x = 1200000 + i * 1800000; h = int(abs(v) * k); y = Z if v < 0 else Z - h
    text(c, f'{c}_t{i}', x - 350000, 1180000, 1600000, 260000, nm, 12, WHITE, True, 'CENTER', 'BOTTOM')
    text(c, f'{c}_s{i}', x - 350000, 1440000, 1600000, 230000, sz, 9, LGREY, False, 'CENTER')
    rect(c, f'{c}_r{i}', x, y, 900000, h, col if col != WHITE else LGREY)
    vy = Z + h + 30000 if v < 0 else Z + 40000
    text(c, f'{c}_v{i}', x - 200000, vy, 1300000, 300000, f'{v:+.1f}%'.replace('-', '−'), 16, RED if col == RED else WHITE, True, 'CENTER')
rect(c, c + '_ax', 900000, Z, 7300000, 6350, LGREY)
rep(c, 'bl', 'Overall no clear loss (−1.6%); the drop sits in the 1.3% of players already at FU before the test (−9%).')
# ---------- 6. recommendation ----------
c = 'fu6_slide'; dup(c, 5)
rep(c, 'ti', 'Domino Easy: Back to 3 Locked')
rep(c, 'a1h', 'Domino Easy: ADOPT 3 locked')
rep(c, 'a1b', 'Tested: 2.6× more finishers, no loss in album revenue, no clear loss over 72 days. Add a mechanic for players left 1–2 short.')
rep(c, 'ml', 'WATCH')
rep(c, 'mb', 'Guardrail: next-album spend of players at FU (they spent −9% over 72 days) · judge future FU tests on the month after the album, not only the test window')
rep(c, 'bl', 'Back to 3 locked: no overall loss and 2.6× more finishers; protect the near group with a 1–2-short mechanic.')
out = sys.argv[2] if len(sys.argv) > 2 else None
if out:  # one file per slide (smaller API calls)
    chunks, cur = [], []
    for r in R:
        if 'duplicateObject' in r and cur: chunks.append(cur); cur = []
        cur.append(r)
    chunks.append(cur)
    for i, ch in enumerate(chunks, 1): json.dump(ch, open(f'{out}_{i}.json', 'w'))
    print([len(ch) for ch in chunks])
else:
    print(json.dumps(R))
