"""Test 1591 (Domino FU Joker offer pricing) story in the FINAL Domino deck (1gHkK8mNPg5pDKwlIe3FdMSqq2UqQx2bPihgu4ve_mks), after fu6_slide.
Four slides built by duplicating tx_end (title / box / measure / bottom line / footer) and adding native shapes.
Numbers: claude/domino-fu-pricing-hypothesis-2026-10-29.md (§1-§6). Prints the batchUpdate request list as JSON
(sent with the Google Slides MCP update_presentation); argv[1] = 0-based insertion index, argv[2] = optional file prefix (one JSON per slide)."""
import json, sys
INS = int(sys.argv[1]) if len(sys.argv) > 1 else 118
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
    sp['outline'] = {'outlineFill': {'solidFill': {'color': {'rgbColor': outline}}}, 'weight': {'magnitude': 19050, 'unit': 'EMU'}} if outline else {'propertyState': 'NOT_RENDERED'}
    R.append({'updateShapeProperties': {'objectId': oid, 'shapeProperties': sp, 'fields': 'shapeBackgroundFill,outline'}})
def text(page, oid, x, y, w, h, t, size, col, bold=False, align='START', valign='TOP'):
    R.append({'createShape': {'objectId': oid, 'shapeType': 'TEXT_BOX', 'elementProperties': el(page, x, y, w, h)}})
    R.append({'insertText': {'objectId': oid, 'text': t}})
    R.append({'updateTextStyle': {'objectId': oid, 'style': {'fontFamily': 'Oswald', 'bold': bold, 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'foregroundColor': {'opaqueColor': {'rgbColor': col}}}, 'fields': 'fontFamily,bold,fontSize,foregroundColor'}})
    R.append({'updateParagraphStyle': {'objectId': oid, 'style': {'alignment': align}, 'fields': 'alignment'}})
    R.append({'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'contentAlignment': valign}, 'fields': 'contentAlignment'}})
SUB_Y = 820000
# ---------- 1. what the test was ----------
c = 'p91a_slide'; dup(c, 0); dele(c, 'a1', 'a1h', 'a1b', 'ml', 'mb')
rep(c, 'ti', 'Test 1591: Joker Offer Price for FU Players, Usual vs Smaller Raise')
text(c, c + '_su', 557784, SUB_Y, 8000000, 220000, 'Domino album 20, last week (Oct 5–11) · players at FU split at random · Joker offers: 1+9 Album, 1+12 Joker card, Buy Them All+', 10, LGREY)
cards = [('CONTROL · usual raise', '$29.44', 'avg price paid for a Joker offer\n(raise planned at 2.0× CZ)', GREY, WHITE),
         ('TEST · smaller raise', '$27.85', 'avg price paid for a Joker offer\n(raise planned at 1.8× CZ)', GOLD, GOLD)]
for i, (hd, big, sub, ol, col) in enumerate(cards):
    x = 762550 + i * 3900000
    rect(c, f'{c}_c{i}', x, 1250000, 3600000, 2000000, BOX, ol)
    text(c, f'{c}_h{i}', x, 1330000, 3600000, 300000, hd, 14, col, True, 'CENTER')
    text(c, f'{c}_n{i}', x, 1680000, 3600000, 700000, big, 40, col, True, 'CENTER', 'MIDDLE')
    text(c, f'{c}_s{i}', x, 2450000, 3600000, 600000, sub, 11, LGREY, False, 'CENTER')
text(c, c + '_who', 762550, 3420000, 7500000, 300000, '137,670 players at FU (68,155 vs 69,515) · 15% of active players · 73% of album-20 revenue', 14, WHITE, True, 'CENTER')
text(c, c + '_pz', 762550, 3760000, 7500000, 250000, 'Puzzle offers (cheaper, about 1.7× CZ) had the same price in both groups', 11, LGREY, False, 'CENTER')
rep(c, 'bl', 'The question: does a smaller raise move buyers from cheap puzzle offers to Joker offers, and lift total spend?')
# ---------- 2. album 20: who bought what, spend, finish ----------
c = 'p91b_slide'; dup(c, 1); dele(c, 'a1', 'a1h', 'a1b', 'ml', 'mb')
rep(c, 'ti', 'Album 20 Last Week, Control vs Test: Offer Buyers, Spend and Finish Rate')
text(c, c + '_su', 557784, SUB_Y, 8000000, 220000, 'All 137,670 players at FU (15% of active players, 73% of album-20 revenue) · per assigned player, from entry to Oct 11\nJoker offer = 1+9 Album, 1+12 Joker card, Buy Them All+, 1PO Joker · puzzle offer = Joker / Golden Puzzle, Sunny Deal Puzzle\nAlbum $ = album spend ÷ all assigned players (payers or not) · finished = 144 stickers by the end of Oct 12', 9, LGREY)  # 3 lines, added 10-29 on Eden's request
text(c, c + '_lg', 5000000, 1050000, 3600000, 220000, '■ Control (usual raise)   ■ Test (smaller raise)', 10, LGREY, False, 'END')
pan = [('Bought a Joker offer', [2.88, 3.39], '{:.2f}%', '+18%', True), ('Bought a puzzle offer', [2.81, 2.64], '{:.2f}%', '−6%', True),
       ('Album $ per player', [11.22, 10.94], '${:.2f}', '−1% vs before (±6%)', False), ('Finished album 20', [14.19, 14.18], '{:.2f}%', 'same', False)]
B, H, bw = 3550000, 1500000, 600000
for i, (nm, vals, fmt, chg, key) in enumerate(pan):
    gx = 850000 + i * 1950000; m = max(vals)
    text(c, f'{c}_t{i}', gx - 250000, 1350000, 2 * bw + 580000, 300000, nm, 12, WHITE, True, 'CENTER')
    for j, v in enumerate(vals):
        x = gx + j * (bw + 80000); h = int(v / m * H)
        col = GREY if j == 0 else (GOLD if key else LGREY)
        rect(c, f'{c}_r{i}{j}', x, B - h, bw, h, col)
        text(c, f'{c}_v{i}{j}', x - 150000, B - h - 280000, bw + 300000, 260000, fmt.format(v), 12, GOLD if (key and j) else WHITE, True, 'CENTER', 'BOTTOM')
    rect(c, f'{c}_ax{i}', gx - 60000, B, 2 * bw + 200000, 6350, GREY)
    text(c, f'{c}_g{i}', gx - 250000, B + 50000, 2 * bw + 580000, 250000, chg, 12, GOLD if key else LGREY, True, 'CENTER')
rep(c, 'bl', 'The smaller raise moved buyers from puzzle offers to Joker offers, but total spend and finishing did not change.')
# ---------- 3. album 21 by spend level ----------
c = 'p91c_slide'; dup(c, 2); dele(c, 'a1', 'a1h', 'a1b', 'ml', 'mb')
rep(c, 'ti', 'Album 21 Days 1–14: Test vs Control Spend, by Spend Level Before the Test')
text(c, c + '_su', 557784, SUB_Y, 8000000, 220000, 'Change vs each player’s own 14 days before entry, Test − Control, as % of Control’s album-21 spend · level = $ a day before entry · label: players per group · % of album-21 revenue', 10, LGREY)
grp = [('All', '68–70K · 100%', -3.5, '±3.1%', LGREY), ('No spend', '38–39K · 5%', 1.6, '±14%', GREY), ('≤$2 a day', '16–17K · 17%', -1.4, '±3.8%', GREY),
       ('$2–5', '6.6–6.8K · 18%', -1.4, '±4.4%', GREY), ('$5–20', '5.5K · 35%', -3.5, '±4.3%', GREY), ('>$20', '1.1–1.2K · 25%', -10.7, '±8.6%', RED)]
Z, k, bw = 1950000, 120000, 800000
for i, (nm, sz, v, rng, col) in enumerate(grp):
    x = 900000 + i * 1250000; h = int(abs(v) * k); y = Z if v < 0 else Z - h
    text(c, f'{c}_t{i}', x - 250000, 1150000, bw + 500000, 250000, nm, 12, RED if col == RED else WHITE, True, 'CENTER', 'BOTTOM')
    text(c, f'{c}_s{i}', x - 250000, 1400000, bw + 500000, 220000, sz, 9, LGREY, False, 'CENTER')
    rect(c, f'{c}_r{i}', x, y, bw, h, col)
    vy = Z + h + 30000 if v < 0 else Z + 40000
    text(c, f'{c}_v{i}', x - 250000, vy, bw + 500000, 280000, f'{v:+.1f}%'.replace('-', '−'), 15, RED if col == RED else WHITE, True, 'CENTER')
    text(c, f'{c}_e{i}', x - 250000, vy + 270000, bw + 500000, 220000, rng, 9, LGREY, False, 'CENTER')
rect(c, c + '_ax', 800000, Z, 7500000, 6350, LGREY)
text(c, c + '_ck', 557784, 3850000, 8000000, 250000, 'Checked, not the cause: test not running in album 21 · CZ rose the same in both · same payers and active days · gap = fewer buys per payer (6.29 vs 6.48)', 10, LGREY, False, 'CENTER')
rep(c, 'bl', 'Album 21 was 3.5% lower in Test, mostly from the >$20 players (1.7% of players); cause not found.')
# ---------- 4. decision ----------
c = 'p91d_slide'; dup(c, 3)
rep(c, 'ti', 'Domino FU Joker Offers: Keep the Usual Raise')
rep(c, 'a1h', 'KEEP the usual FU raise (Control)')
rep(c, 'a1b', 'A smaller raise moved buyers to Joker offers but did not lift spend in album 20, and album 21 was 3.5% lower.')
rep(c, 'ml', 'OPEN')
rep(c, 'mb', 'The value of the FU raise itself (raise vs no raise) was not tested · FU rule and Jokers per offer: ask the Domino team · watch >$20 payers if the raise changes')
rep(c, 'bl', 'Keep the usual raise; test raise vs no raise only if the team needs the value of the raise itself.')
out = sys.argv[2] if len(sys.argv) > 2 else None
if out:
    chunks, cur = [], []
    for r in R:
        if 'duplicateObject' in r and cur: chunks.append(cur); cur = []
        cur.append(r)
    chunks.append(cur)
    for i, ch in enumerate(chunks, 1): json.dump(ch, open(f'{out}_{i}.json', 'w'), ensure_ascii=False)
    print([len(ch) for ch in chunks])
else:
    print(json.dumps(R, ensure_ascii=False))
