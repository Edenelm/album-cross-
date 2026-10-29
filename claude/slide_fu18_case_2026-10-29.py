"""FU18 case slide (final deck, after fu3): one near player under 5 locked vs 3 locked, with the real group numbers.
Numbers: claude/domino-fu18-checks-2026-10-29.md §6, §8 (Easy at FU on Jun 27 paying $5-20 a day before the test)."""
import json
P = 'fucase_slide'
GOLD = {'red': 1, 'green': 0.8745098, 'blue': 0.52156866}; RED = {'red': 1, 'green': 0.043137256, 'blue': 0.2784314}
GREY = {'red': 0.42, 'green': 0.42, 'blue': 0.42}; LG = {'red': 0.74, 'green': 0.74, 'blue': 0.74}
WH = {'red': 0.96, 'green': 0.96, 'blue': 0.96}; BOX = {'red': 0.1686, 'green': 0.1686, 'blue': 0.1686}
R = [{'duplicateObject': {'objectId': 'fu1_slide', 'objectIds': {'fu1_slide': P, 'fu1_slide_ti': P + '_ti', 'fu1_slide_ft': P + '_ft', 'fu1_slide_a1': P + '_a1',
      'fu1_slide_a1h': P + '_a1h', 'fu1_slide_a1b': P + '_a1b', 'fu1_slide_ml': P + '_ml', 'fu1_slide_mb': P + '_mb', 'fu1_slide_bl': P + '_bl'}}}]
for e in ['a1', 'a1h', 'a1b', 'ml', 'mb', 'bl', 'ti']: R.append({'deleteObject': {'objectId': f'{P}_{e}'}})
def el(x, y, w, h): return {'pageObjectId': P, 'size': {'width': {'magnitude': 3e6, 'unit': 'EMU'}, 'height': {'magnitude': 3e6, 'unit': 'EMU'}},
                            'transform': {'scaleX': w / 3e6, 'scaleY': h / 3e6, 'translateX': x, 'translateY': y, 'unit': 'EMU'}}
def text(oid, x, y, w, h, t, size, col, bold=False, align='START', valign='TOP', runs=()):
    R.append({'createShape': {'objectId': oid, 'shapeType': 'TEXT_BOX', 'elementProperties': el(x, y, w, h)}})
    R.append({'insertText': {'objectId': oid, 'text': t}})
    R.append({'updateTextStyle': {'objectId': oid, 'style': {'fontFamily': 'Oswald', 'bold': bold, 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'foregroundColor': {'opaqueColor': {'rgbColor': col}}}, 'fields': 'fontFamily,bold,fontSize,foregroundColor'}})
    for a, b, c, bb in runs:
        R.append({'updateTextStyle': {'objectId': oid, 'textRange': {'type': 'FIXED_RANGE', 'startIndex': a, 'endIndex': b}, 'style': {'foregroundColor': {'opaqueColor': {'rgbColor': c}}, 'bold': bb}, 'fields': 'foregroundColor,bold'}})
    R.append({'updateParagraphStyle': {'objectId': oid, 'style': {'alignment': align}, 'fields': 'alignment'}})
    R.append({'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'contentAlignment': valign}, 'fields': 'contentAlignment'}})
def box(oid, x, y, w, h, line):
    R.append({'createShape': {'objectId': oid, 'shapeType': 'RECTANGLE', 'elementProperties': el(x, y, w, h)}})
    R.append({'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': BOX}}},
              'outline': {'outlineFill': {'solidFill': {'color': {'rgbColor': line}}}, 'weight': {'magnitude': 19050 if line != GREY else 9525, 'unit': 'EMU'}}}, 'fields': 'shapeBackgroundFill,outline'}})
text(P + '_t', 557784, 300000, 8000000, 460000, 'One Near Player, Two Album Endings: 5 vs 3 Locked', 24, WH)
text(P + '_su', 557784, 800000, 8000000, 250000, 'Example player: about $10 a day, 5 stickers missing with 8 days left (Jun 27). Numbers = real group: Easy players at FU paying $5–20 a day before the test, ~1,150 a side', 10, LG)
rows = [('5 locked', 1250000, GREY, [
            ('Jun 27', '5 missing, 8 days left', GREY),
            ('Pays to chase', 'the last stickers', GREY),
            ('All 5 locked', 'Stuck at 3–5 missing\n55% of these players', RED),
            ('Next album', 'Spends as usual', GREY)]),
        ('3 locked', 2700000, GOLD, [
            ('Jun 27', '5 missing, 8 days left', GREY),
            ('Pays about the same', 'during the test', GREY),
            ('Only 3 locked', 'Finishes: 39% (vs 26%)\n+32% get to 1–2 short', GOLD),
            ('Next album', 'Spends 11% less\n(72 days, ±10)', RED)])]
X0, W, G, H = 1700000, 1600000, 230000, 1150000
for r, (lab, y, lc, steps) in enumerate(rows):
    text(f'{P}_lab{r}', 300000, y + 350000, 1300000, 450000, lab, 18, lc, True, 'START', 'MIDDLE')
    for i, (h1, body, line) in enumerate(steps):
        x = X0 + i * (W + G)
        box(f'{P}_b{r}{i}', x, y, W, H, line)
        hc = RED if line == RED else (GOLD if line == GOLD else WH)
        t = h1 + '\n' + body
        text(f'{P}_x{r}{i}', x + 60000, y + 80000, W - 120000, H - 160000, t, 12, LG, False, 'CENTER', 'MIDDLE', runs=[(0, len(h1), hc, True)])
        if i < 3:
            text(f'{P}_ar{r}{i}', x + W - 20000, y + 380000, G + 40000, 400000, '→', 16, GREY, True, 'CENTER', 'MIDDLE')
text(P + '_bl', 557784, 4150000, 8000000, 330000, 'Same money during the album, more finishers. The open question is the next album: near players who finished spent less.', 13, WH)
note = ("How to read: one near player (about $10 a day, 5 stickers missing with 8 days left on Jun 27) goes through the album end twice. Under 5 locked all 5 missing stickers are locked: she pays to chase them and stays stuck. Under 3 locked she pays about the same, finishes or gets to 1–2 short. "
        "Real numbers for this group (Easy, at FU on Jun 27, $5–20 a day in Jun 14–27; 1,161 vs 1,144 players): finished album 18 39% vs 26%, 1–2 short 32% vs 20%, still 3–5 missing 30% vs 55%. "
        "Whole at-FU group in the test window: $30.65 vs $31.86 per player (−2.8% after the 14-day before gap, within noise), so the album revenue did not drop. Over 72 days (Jun 28 – Sep 7) this $5–20 group spent −11% (±9.6), the main source of the small overall gap (−1.5%). "
        "Players paying >$20 a day finished about as often in both groups (52% vs 47%), so the test barely changed them. Hypothesis (not tested): finishing album 18 lowered these players' spend in the next album.\n"
        "Source: claude/domino-fu18-checks-2026-10-29.md (§6–§8) | SQL: claude/domino_fu18_checks_2026-10-29.sql (q34–q36) | Script: claude/slide_fu18_case_2026-10-29.py")
print(json.dumps({'requests': R, 'note': note}))
