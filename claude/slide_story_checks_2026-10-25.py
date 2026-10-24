"""ALBUM END: slides from the story-review checks (2026-10-24/25). Source: claude/open-checks-2026-10-24.md (C), claude/dice65-end-2026-10-24.md.
d65_slide: Dice spend per payer per day, last 4 days vs days 11-5 before close, albums 63 vs 65, by spend level.
Usage (from claude/): python3 slide_story_checks_2026-10-25.py <d65|notes> [insertionIndex|-]"""
import json, sys, importlib.util as u
s = u.spec_from_file_location('h', 'slide_t7_dice_prize_2026-10-25.py'); h = u.module_from_spec(s); s.loader.exec_module(h)
DICE, DIM = {'red': 0.435, 'green': 0.639, 'blue': 1}, {'red': 0.45, 'green': 0.45, 'blue': 0.45}

def card(S, k, x, y, w, hh):
    return h.box(S, f'{S}_{k}', x, y, w, hh, 'RECTANGLE') + [{'updateShapeProperties': {'objectId': f'{S}_{k}', 'shapeProperties': {
        'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': h.CARD}}},
        'outline': {'outlineFill': {'solidFill': {'color': {'rgbColor': h.EDGE}}}, 'weight': {'magnitude': 1, 'unit': 'PT'}}},
        'fields': 'shapeBackgroundFill.solidFill.color,outline.outlineFill.solidFill.color,outline.weight'}}]

def d65(idx=None):
    S = 'd65_slide'
    msg = 'In Dice 65 the final weekend did not lift spend at any level. Ask the Dice team what ran in the last weekend of 65 vs 63.'
    R = h.page(S, 'Dice Spend per Payer per Day: Last 4 Days vs Days 11–5 Before Close',
               'Paying players past their first album, by daily spend level · last 4 days = Thursday to Sunday before the Monday close · albums 63 and 65',
               msg, msg_red='did not lift spend at any level', idx=idx, msg_y=4.6)
    R += card(S, 'pc', 0.61, 1.2, 5.3, 3.25)
    R += h.tbox(S, f'{S}_pt', 0.75, 1.24, 3.2, 0.28, 'Last 4 days vs days 11–5', 10, h.WHITE, True)
    R += h.rect(S, f'{S}_lg1', 3.9, 1.33, 0.13, 0.13, DIM)
    R += h.tbox(S, f'{S}_lt1', 4.05, 1.26, 0.8, 0.25, 'album 63', 8, h.GREY)
    R += h.rect(S, f'{S}_lg2', 4.85, 1.33, 0.13, 0.13, DICE)
    R += h.tbox(S, f'{S}_lt2', 5.0, 1.26, 0.8, 0.25, 'album 65', 8, h.GREY)
    zero, per, w = 2.75, 0.05, 0.55
    R += h.rect(S, f'{S}_z', 0.75, zero, 5.0, 0.012, h.GREY)
    data = [('$2–5 a day', 18, -4), ('$5–20 a day', 9, -11), ('Over $20 a day', 5, -17)]
    for g, (lab, a, b) in enumerate(data):
        gx = 1.0 + g * 1.65
        R += h.tbox(S, f'{S}_g{g}', gx - 0.25, 4.05, 1.6, 0.28, lab, 11, h.WHITE, True, 'CENTER')
        for k, (v, c) in enumerate([(a, DIM), (b, DICE)]):
            x, hgt = gx + k * (w + 0.05), max(abs(v) * per, 0.02)
            y = zero - hgt if v >= 0 else zero
            R += h.rect(S, f'{S}_b{g}{k}', x, y, w, hgt, c)
            ty = y - 0.27 if v >= 0 else y + hgt + 0.02
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.2, ty, w + 0.4, 0.25, f'{v:+d}%', 11, h.RED if v < 0 else h.WHITE, True, 'CENTER')
    for i, (num, lab, c) in enumerate([('Rise', 'In 63 spend rose again on the final weekend (Fri–Sun) at every level', h.WHITE),
                                       ('Drop', 'In 65 the final weekend was among the lowest days; the weekend before it was higher', h.RED),
                                       ('4%', 'of $2–5 payers had finished by Thursday, yet their spend fell too: not only early finishers', h.WHITE)]):
        y = 1.2 + i * 1.1
        R += card(S, f't{i}', 6.1, y, 3.3, 1.0)
        R += h.tbox(S, f'{S}_tn{i}', 6.22, y + 0.05, 3.1, 0.45, num, 22, c, True)
        R += h.tbox(S, f'{S}_tl{i}', 6.22, y + 0.52, 3.1, 0.45, lab, 8.5, h.WHITE)
    return R

NOTES = {'d65_slide': """Question (Eden): why did Dice 65 have no end lift (+3% vs +15–33% before)?
Who: standard-population payers (past first album, login ratio >= 0.5, row on close-1, not excluded), by daily spend level in the first 75% of the album. Players: $2–5 31,699 / 30,252; $5–20 22,971 / 22,224; >$20 4,594 / 4,345 (albums 63 / 65).
Album spend per payer per day, days 11–5 before close → last 4 days: $2–5 $3.29 → $3.87 (+18%) in 63, $3.43 → $3.28 (−4%) in 65; $5–20 $8.78 → $9.55 (+9%) vs $9.32 → $8.25 (−11%); >$20 $33.83 → $35.46 (+5%) vs $38.07 → $31.54 (−17%).
$5–20 final weekend Fri/Sat/Sun: 63 $9.81 / $10.56 / $9.56; 65 $8.45 / $7.94 / $8.11; 65's weekend 9–8 days before close $10.13 / $10.51.
Ruled out: payers too far (within 3 stickers at close-4 = 55% of revenue in 65 vs 54% in 63); free locked stickers (98.5% of 65 finishers paid for at least one; biggest source paid Wild 60%).
Part of it: more strong payers finished before the weekend (>$20 15% vs 6% at close-4). But $2–5 payers fell too, and only 4% of them had finished.
Hypothesis: the final weekend of 65 had nothing pulling spend (events / offers / rewards). Question for the Dice team. One album only.
Docs: claude/open-checks-2026-10-24.md, claude/dice65-end-2026-10-24.md."""}

if __name__ == '__main__':
    if sys.argv[1] == 'notes': print(json.dumps(NOTES, ensure_ascii=False))
    else: print(json.dumps(globals()[sys.argv[1]](int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] != '-' else None), ensure_ascii=False, separators=(',', ':')))
