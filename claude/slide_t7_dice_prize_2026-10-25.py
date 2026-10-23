"""ALBUM END: topic-7 slides, Dice finishers and the grand prize (2026-10-25). New slides drawn from scratch (no template copy).
Source: claude/topic7-dice-prize-2026-10-25.md (SQL claude/topic7_dice_prize_2026-10-25.sql).
Usage: python3 slide_t7_dice_prize_2026-10-25.py <t7a|t7b|t7c|notes>  -> prints update_presentation requests (JSON)."""
import json, sys
E = 914400
RED, GOLD, GREY = {'red': 1, 'green': 0.043, 'blue': 0.278}, {'red': 1, 'green': 0.875, 'blue': 0.522}, {'red': 0.741, 'green': 0.741, 'blue': 0.741}
BLUE, WHITE, DARK = {'red': 0.424, 'green': 0.62, 'blue': 1}, {'red': 0.961, 'green': 0.961, 'blue': 0.961}, {'red': 0.353, 'green': 0.353, 'blue': 0.353}
CARD, EDGE, FOOT = {'red': 0.169, 'green': 0.169, 'blue': 0.169}, {'red': 0.267, 'green': 0.267, 'blue': 0.267}, {'red': 0.62, 'green': 0.62, 'blue': 0.62}

def box(S, oid, x, y, w, h, kind='TEXT_BOX'):
    return [{'createShape': {'objectId': oid, 'shapeType': kind, 'elementProperties': {'pageObjectId': S,
        'size': {'width': {'magnitude': int(w * E), 'unit': 'EMU'}, 'height': {'magnitude': int(h * E), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x * E), 'translateY': int(y * E), 'unit': 'EMU'}}}}]
def tbox(S, oid, x, y, w, h, t, size, c, bold=False, align=None):
    R = box(S, oid, x, y, w, h) + [{'insertText': {'objectId': oid, 'text': t}},
        {'updateTextStyle': {'objectId': oid, 'textRange': {'type': 'ALL'}, 'style': {'fontFamily': 'Oswald', 'bold': bold, 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'foregroundColor': {'opaqueColor': {'rgbColor': c}}}, 'fields': 'fontFamily,bold,fontSize,foregroundColor'}}]
    if align:
        R += [{'updateParagraphStyle': {'objectId': oid, 'textRange': {'type': 'ALL'}, 'style': {'alignment': align}, 'fields': 'alignment'}}]
    return R
def rect(S, oid, x, y, w, h, c):
    return box(S, oid, x, y, w, h, 'RECTANGLE') + [{'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': c}}}, 'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill.solidFill.color,outline.propertyState'}}]
def red_part(oid, text, part, c=RED):
    i = text.index(part)
    return [{'updateTextStyle': {'objectId': oid, 'textRange': {'type': 'FIXED_RANGE', 'startIndex': i, 'endIndex': i + len(part)}, 'style': {'foregroundColor': {'opaqueColor': {'rgbColor': c}}}, 'fields': 'foregroundColor'}}]
def page(S, title, sub, msg, msg_red=None, idx=None, msg_y=4.6):
    cs = {'objectId': S, 'slideLayoutReference': {'predefinedLayout': 'BLANK'}}
    if idx is not None: cs['insertionIndex'] = idx
    R = [{'createSlide': cs},
         {'updatePageProperties': {'objectId': S, 'pageProperties': {'pageBackgroundFill': {'solidFill': {'color': {'rgbColor': {'red': 0.129, 'green': 0.129, 'blue': 0.129}}}}}, 'fields': 'pageBackgroundFill'}}]
    R += tbox(S, S + '_ti', 0.61, 0.33, 8.8, 0.5, title, 24, WHITE)
    R += tbox(S, S + '_su', 0.61, 0.82, 8.8, 0.3, sub, 9.5, GREY)
    R += tbox(S, S + '_ms', 0.61, msg_y, 7.1, 0.5, msg, 11, WHITE)
    if msg_red: R += red_part(S + '_ms', msg, msg_red)
    R += tbox(S, S + '_ft', 7.78, 5.25, 1.72, 0.2, 'SuperPlay 2026', 8, FOOT)
    return R

def t7a(idx=None):   # 200K prize in days of own play, by spend level (Dice 63 payer finishers with the 200K prize)
    S, BASE, PER = 't7a_slide', 3.55, 0.38   # inches per day of play
    msg = 'The same 200K prize is 5 days of play for a $2-a-day payer and 1 day for a top payer.'
    R = page(S, 'Dice 200K Prize in Days of the Player\'s Own Play, by Spend Level',
             'Dice 63 payer finishers with the 200K-roll prize · days = 200K ÷ the player\'s own rolls played per day in the album (median) · spend level = $ a day before the last quarter',
             msg, msg_red='5 days of play', idx=idx)
    data = [('≤$2 a day', 4.9, '1,599 players · 1% of revenue', RED),
            ('$2–5 a day', 3.6, '1,401 players · 1% of revenue', BLUE),
            ('$5–20 a day', 2.4, '1,789 players · 4% of revenue', BLUE),
            ('>$20 a day', 1.2, '843 players · 7% of revenue', BLUE)]
    for i, (lab, d, who, c) in enumerate(data):
        x, h = 1.05 + i * 2.1, d * PER
        R += rect(S, f'{S}_b{i}', x, BASE - h, 1.1, h, c)
        R += tbox(S, f'{S}_v{i}', x - 0.3, BASE - h - 0.45, 1.7, 0.4, f'{d} days', 18, WHITE, True, 'CENTER')
        R += tbox(S, f'{S}_l{i}', x - 0.4, BASE + 0.06, 1.9, 0.3, lab, 13, WHITE, True, 'CENTER')
        R += tbox(S, f'{S}_w{i}', x - 0.4, BASE + 0.36, 1.9, 0.25, who, 9, GREY, False, 'CENTER')
    R += rect(S, f'{S}_base', 0.8, BASE, 8.4, 0.012, GREY)
    return R

def t7b(idx=None):   # bought in the week after close, by prize in days of own play
    S, BASE, PER = 't7b_slide', 3.55, 0.024   # inches per 1%
    msg = 'The bigger the prize compared with own play, the fewer payers buy the next week: 55% → 42% at $2 a day or less.'
    R = page(S, 'Payers Who Bought the Week After Close, by Prize in Days of Play',
             'Dice 63 payer finishers · bought = any purchase in the 7 days after close (next album days 2–8) · prize in days = final prize ÷ own rolls played per day in the album',
             msg, msg_red='55% → 42%', idx=idx)
    groups = [('≤$2 a day', [55, 51, 42]), ('$2–5 a day', [70, 70, 65]), ('$5–20 a day', [80, 79, 75])]
    cols, caps = [GREY, DARK, RED], ['<2 days', '2–4 days', '4+ days']
    for g, (lab, vals) in enumerate(groups):
        gx = 1.0 + g * 2.85
        for j, v in enumerate(vals):
            x, h = gx + j * 0.78, v * PER
            R += rect(S, f'{S}_b{g}{j}', x, BASE - h, 0.66, h, cols[j])
            R += tbox(S, f'{S}_v{g}{j}', x - 0.2, BASE - h - 0.36, 1.06, 0.32, f'{v}%', 14, RED if j == 2 else WHITE, True, 'CENTER')
            R += tbox(S, f'{S}_c{g}{j}', x - 0.2, BASE + 0.04, 1.06, 0.22, caps[j], 8.5, GREY, False, 'CENTER')
        R += tbox(S, f'{S}_g{g}', gx - 0.2, BASE + 0.3, 2.4, 0.3, lab, 13, WHITE, True, 'CENTER')
    R += rect(S, f'{S}_base', 0.8, BASE, 8.4, 0.012, GREY)
    return R

def t7c(idx=None):   # test proposal: Control | Test
    S = 't7c_slide'
    msg = 'Size the prize to the player\'s own play, not to past spend. Test first: the data shows a link, not a cause.'
    R = page(S, 'Test: Dice Grand Prize Sized to the Player\'s Own Play',
             'Dice payer finishers, random 50/50 at album start · prize sizes and limits below are options for management',
             msg, msg_red='Test first', idx=idx, msg_y=4.0)
    cards_ = [('ct', 0.61, 'Control', GREY, 'Today', 'Prize by past spend: 25K–200K rolls.\nThe same 200K = 5 days of play at ≤$2 a day, 1 day at >$20.'),
              ('ts', 5.14, 'Test', GOLD, 'Change', 'Prize = 2–3 days of the player\'s own rolls (e.g. min 25K, max 350K).\nLess for 3,722 payers whose prize is 4+ days (2% of revenue). More for 1,457 >$20 payers (12% of revenue).')]
    for k, x, name, gc, lab, body in cards_:
        R += box(S, f'{S}_{k}_card', x, 1.3, 4.25, 1.65, 'ROUND_RECTANGLE')
        R += [{'updateShapeProperties': {'objectId': f'{S}_{k}_card', 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': CARD}}},
               'outline': {'outlineFill': {'solidFill': {'color': {'rgbColor': EDGE}}}, 'weight': {'magnitude': 1, 'unit': 'PT'}}}, 'fields': 'shapeBackgroundFill.solidFill.color,outline.outlineFill.solidFill.color,outline.weight'}}]
        R += tbox(S, f'{S}_{k}_h', x + 0.25, 1.42, 2.6, 0.45, name, 20, gc, True)
        R += tbox(S, f'{S}_{k}_l', x + 2.85, 1.48, 1.15, 0.35, lab.upper(), 9, GREY, True, 'END')
        R += tbox(S, f'{S}_{k}_b', x + 0.25, 1.95, 3.75, 1.0, body, 12, WHITE)
    R += tbox(S, f'{S}_m_l', 0.61, 3.15, 1.2, 0.25, 'MEASURE', 9, GREY, True)
    R += tbox(S, f'{S}_m_b', 0.61, 3.35, 8.8, 0.5, 'Main: % who buy in the 7 days after close · Also: week-1 spend vs own album pace, next album revenue per payer, rolls given', 12, WHITE)
    return R

NOTES = {
 't7a_slide': """Dice 63 payer finishers (standard population, finished = 144 on close−1) with the 200K-roll final prize (code 7): 5,632 of 19,688 payer finishers (29%), 13% of paying players' album revenue.
Days of play = 200,000 ÷ the player's own rolls played per day during the album (median per level). Album 61: 5.3 / 3.8 / 2.5 / 1.2 days — same picture.
Revenue % = share of all paying players' album revenue (standard population, album start to close−1). ≤$2: 0.5%, $2–5: 1.1%, $5–20: 3.7%, >$20: 7.5%.
Why it happens: the prize code is set from past spend and never goes down, so players who now spend little keep a big prize.
Fact: 28% of 200K finishers spend $2 a day or less. Interpretation: for them the prize is a stock of free play, which delays the next purchase (next slide).""",
 't7b_slide': """Dice 63 payer finishers by spend level and prize size in days of their own play. Bought = any purchase in the 7 days after the close day (next album days 2–8).
≤$2: 55% / 51% / 42% (2,655 / 3,429 / 2,568 players). $2–5: 70% / 70% / 65% (2,178 / 1,954 / 875). $5–20: 80% / 79% / 75% (2,864 / 1,429 / 279 — small group).
Album 61, same order: ≤$2 58% / 52% / 46%; $2–5 72% / 71% / 61%; $5–20 flat (80% / 77% / 79%). >$20 payers almost all have a prize under 2 days (not shown).
Fact: in light and middle payers, a bigger prize vs own play goes with fewer buyers in the next week, in both albums.
Caveat: descriptive, no control group. A long prize also means a player who plays less than their code suggests (past spend was higher), and these players may already be slowing down. The test on the next slide settles cause.
Money: these groups still spend at or above their own album pace in that week (they speed up at the end), so the cost is mainly fewer buyers, not a big $ gap. Payers with a 4+ day prize: 3,722 players, 2% of album revenue.
Other games: no need for this test now. Domino and Disney finishers start the next album at 140% / 128% of own pace ($2–20 a day) vs Dice 110% (slide s6b).""",
 't7c_slide': """Recommendation: TEST (not adopt). Dice payer finishers, random 50/50 at album start.
Control: today's ladder (25K–200K rolls by past spend). Test: prize = about 2–3 days of the player's own rolls played per day in the album. Floor / cap (e.g. 25K / 350K) and the number of days are management choices.
Who changes (album 63): less for 3,722 payers whose prize is 4+ days of own play (2% of album revenue); more for the 1,457 payer finishers over $20 a day, almost all with a prize under 2 days of play (12% of album revenue) — this is the earlier 250K / 350K grand-prize proposal for top payers.
Main measure: % who buy in the 7 days after close. Also: week-1 spend vs own album pace, next-album revenue per payer, rolls given (cost).
Guardrail: album revenue and finish rate in the test album must not drop (a smaller prize may lower the will to finish).
If the prize cannot go down ("never less"), run only the top-payer arm first.
Not proven: that the prize causes the slow return; the data shows a link only (previous slide)."""
}
def notes():
    print(json.dumps(NOTES, ensure_ascii=False))

if __name__ == '__main__':
    if sys.argv[1] == 'notes': notes()
    else: print(json.dumps(globals()[sys.argv[1]](int(sys.argv[2]) if len(sys.argv) > 2 else None), ensure_ascii=False, separators=(',', ':')))
