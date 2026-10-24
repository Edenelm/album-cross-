"""ALBUM END: VIP refinement of a6s9v (Eden 2026-10-24) — not a new message, a sharper version of "help them finish".
vipa: VIP who end 1-3 short vs finishers, 28 days after close vs the same players' normal week, 2 albums per game.
vipt: test proposal, Disney first, help in the last 4 days before close, 3 arms.
Source: claude/vip-review-2026-10-24.md (steps 3-5; SQL vip_normal_week_churn / vip_third_album / vip_gift_recipients 2026-10-24).
Usage (from claude/): python3 slide_vip_album_end_2026-10-24.py <vipa|vipt|notes> [insertionIndex|-]"""
import json, sys, importlib.util as u
s = u.spec_from_file_location('h', 'slide_t7_dice_prize_2026-10-25.py'); h = u.module_from_spec(s); s.loader.exec_module(h)
DICE, DOMINO, DISNEY = {'red': 0.435, 'green': 0.639, 'blue': 1}, {'red': 0.961, 'green': 0.627, 'blue': 0.29}, {'red': 0.235, 'green': 0.784, 'blue': 0.706}
DIM = {'red': 0.45, 'green': 0.45, 'blue': 0.45}

def card(S, k, x, y, w, hh):
    return h.box(S, f'{S}_{k}', x, y, w, hh, 'RECTANGLE') + [{'updateShapeProperties': {'objectId': f'{S}_{k}', 'shapeProperties': {
        'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': h.CARD}}},
        'outline': {'outlineFill': {'solidFill': {'color': {'rgbColor': h.EDGE}}}, 'weight': {'magnitude': 1, 'unit': 'PT'}}},
        'fields': 'shapeBackgroundFill.solidFill.color,outline.outlineFill.solidFill.color,outline.weight'}}]

def vipa(idx=None):
    S = 'vipa_slide'
    msg = 'In 6 of 6 albums VIP who end 1–3 short spend 7–19% less than in their own normal week, while finishers drop less. In Disney they also leave more.'
    R = h.page(S, 'VIP Spend After Close vs Normal Week: Finished vs 1–3 Short',
               'VIP = paying players with LTV $5K+ at album start · 28 days after close vs the same players\' normal mid-album week (album days 21–27) · 2 albums per game',
               msg, msg_red='they also leave more', idx=idx, msg_y=4.6)
    R += card(S, 'pc', 0.61, 1.2, 5.3, 3.25)
    R += h.tbox(S, f'{S}_pt', 0.75, 1.24, 3.0, 0.28, '28 days after close vs normal week', 10, h.WHITE, True)
    R += h.rect(S, f'{S}_lg1', 3.4, 1.33, 0.13, 0.13, DIM)
    R += h.tbox(S, f'{S}_lt1', 3.55, 1.26, 0.95, 0.25, 'grey = finished', 8, h.GREY)
    R += h.tbox(S, f'{S}_lt2', 4.4, 1.26, 1.8, 0.25, 'colour = ended 1–3 short', 8, h.GREY)
    zero, per, w = 2.2, 0.075, 0.3
    R += h.rect(S, f'{S}_z', 0.75, zero, 5.0, 0.012, h.GREY)
    data = [('Dice', DICE, [('61', -11, -17), ('63', -4, -15)]),
            ('Domino', DOMINO, [('17', -8, -19), ('19', -8, -16)]),
            ('Disney', DISNEY, [('12', -9, -18), ('14', 7, -7)])]
    for g, (name, col, albums) in enumerate(data):
        gx = 0.9 + g * 1.65
        R += h.tbox(S, f'{S}_g{g}', gx - 0.1, 4.08, 1.5, 0.28, name, 11, col, True, 'CENTER')
        for a, (alb, fin, near) in enumerate(albums):
            ax = gx + a * 0.72
            R += h.tbox(S, f'{S}_a{g}{a}', ax - 0.1, 3.9, 0.82, 0.22, f'album {alb}', 7.5, h.GREY, False, 'CENTER')
            for b, (v, c, lc) in enumerate([(fin, DIM, h.GREY), (near, col, h.RED)]):
                x, hgt = ax + b * w, max(abs(v) * per, 0.02)
                y = zero - hgt if v >= 0 else zero
                R += h.rect(S, f'{S}_b{g}{a}{b}', x, y, w - 0.03, hgt, c)
                ty = y - 0.22 if v >= 0 else y + hgt + 0.01
                R += h.tbox(S, f'{S}_v{g}{a}{b}', x - 0.15, ty, w + 0.27, 0.22, f'{v:+d}%', 8, lc, b == 1, 'CENTER')
    for i, (num, lab, c) in enumerate([('4–12%', 'of album revenue comes from VIP who end 1–3 short (most in Dice)', h.WHITE),
                                       ('−15% to −20%', 'same drop for $1K–5K payers who end 1–3 short (6 of 6 albums)', h.WHITE),
                                       ('1.6–2.5× churn', 'Disney only: 4.5–6.1% of VIP 1–3 short leave in days 15–28 vs 2.4–2.8% of finishers', h.RED)]):
        y = 1.2 + i * 1.1
        R += card(S, f't{i}', 6.1, y, 3.3, 1.0)
        R += h.tbox(S, f'{S}_tn{i}', 6.22, y + 0.05, 3.1, 0.45, num, 22, c, True)
        R += h.tbox(S, f'{S}_tl{i}', 6.22, y + 0.52, 3.1, 0.45, lab, 8.5, h.WHITE)
    return R

def vipt(idx=None):
    S = 'vipt_slide'
    msg = 'Test in Disney first: that is where near-miss VIP also leave. Do not copy the Dice gift as is: it reaches VIP who are already 4+ away, and 86% of them still do not finish.'
    R = h.page(S, 'Test in Disney: Help Near-Finish VIP in the Last 4 Days',
               'Disney VIP and $1K–5K payers close to 144 in the last 4 days before close · random split into 3 groups · entry rule and offer sizes are management choices',
               msg, msg_red='Do not copy the Dice gift as is', idx=idx, msg_y=4.45)
    arms = [('ct', 'Control', h.GREY, 'TODAY', 'No help.\nToday about 1 in 3 Disney VIP finish; about half of the rest end 1–3 short.'),
            ('gf', 'Gift', h.GOLD, 'ARM A', 'A free gift like the Dice VIP gift, but sent in the last 4 days and only to players who are close to 144.'),
            ('of', 'Offer', h.GOLD, 'ARM B', 'A paid offer on the player\'s own missing stickers in the last 4 days.')]
    for i, (k, name, gc, lab, body) in enumerate(arms):
        x = 0.61 + i * 2.97
        R += card(S, f'{k}_card', x, 1.25, 2.82, 1.85)
        R += h.tbox(S, f'{S}_{k}_h', x + 0.18, 1.33, 1.8, 0.42, name, 20, gc, True)
        R += h.tbox(S, f'{S}_{k}_l', x + 1.7, 1.4, 0.95, 0.3, lab, 9, h.GREY, True, 'END')
        R += h.tbox(S, f'{S}_{k}_b', x + 0.18, 1.85, 2.5, 1.2, body, 11, h.WHITE)
    R += h.tbox(S, f'{S}_m_l', 0.61, 3.3, 1.2, 0.25, 'MEASURE', 9, h.GREY, True)
    R += h.tbox(S, f'{S}_m_b', 0.61, 3.52, 8.8, 0.6, 'Main: revenue per player in the 28 days after close vs own normal week · Guardrails: finish rate, churn in days 15–28 after close, album revenue, cost of the help', 11, h.WHITE)
    return R

NOTES = {
 'vipa_slide': """Refinement of the previous slide (a6s9v), not a new message: the same drop after close is also there for VIP over 28 days.
Who: standard population, paying players with LTV $5K+ at album start (VIP). Finished = 144 unique set stickers by the end of the close day. 1–3 short = 141–143 at the end of the close day.
Measure: spend in the 28 days after close vs the same players' normal mid-album week (album days 21–27), both as % of their usual pace (album days 0–20). Same calendar weeks for finishers and near-missers, so the calendar does not explain the gap.
VIP 1–3 short vs normal week: Dice 61 −17%, 63 −15%; Domino 17 −19%, 19 −16%; Disney 12 −18%, 14 −7%. VIP finishers, same albums: Dice −11 / −4%; Domino −8 / −8%; Disney −9 / +7%.
Players (VIP finished / 1–3 short): Dice 61 2,538 / 4,694; Dice 63 3,509 / 6,152; Domino 17 832 / 576; Domino 19 832 / 720; Disney 12 932 / 1,180; Disney 14 1,127 / 1,549.
$1K–5K payers who end 1–3 short: Dice −19% / −20%, Domino −15% / −17%, Disney −18% / −17% (albums 63 / 61, 19 / 17, 14 / 12).
Size: VIP are 9–29% of album revenue; VIP who end 1–3 short are 4–12% (Dice 11–12%, Domino 5%, Disney 4–5%; albums Dice 63/65, Domino 19/20, Disney 14/15).
Churn (no active day in days 15–28 after close), VIP finished vs 1–3 short: Disney 12 2.8% vs 4.5%, Disney 14 2.4% vs 6.1%. Dice and Domino: about the same as finishers (1.5–3.6%).
Ceiling, not a forecast: the 28-day gap vs normal-week pace for VIP 1–3 short was about $11,524 a day in Dice, $2,071 in Domino, $2,333 in Disney (one album each).
Caveat: descriptive, no control group. Doc: claude/vip-review-2026-10-24.md.""",
 'vipt_slide': """Recommendation: TEST (not adopt). Disney first, because there the near-miss VIP also leave more (4.5–6.1% vs 2.4–2.8% of finishers); in Dice and Domino they churn like finishers.
Who: Disney VIP (LTV $5K+) and $1K–5K payers who are close to 144 in the last 4 days before close. The exact entry rule (how many missing on which day) and the gift / offer size are management choices. Size: Disney VIP who end 1–3 short are about 1,500 an album (1,549 in album 14; 4–5% of album revenue), so 3 groups are small: plan 2+ albums or include $1K–5K payers.
Groups: Control (today) · A: free gift in the style of the Dice VIP gift, but timed in the last 4 days and only for players close to 144 · B: a paid offer on the player's own missing stickers.
Main measure: revenue per player in the 28 days after close vs own normal week (album days 21–27). Guardrails: finish rate, churn in days 15–28 after close, album revenue, cost of the help.
Why not copy the Dice gift as is: the "VIP FU album treatment" ran Sep 1–2 (album 63) and Oct 8–14 (album 65), about a week before close. In album 63 all ~2,000 VIP recipients were already 4+ away 6 days before close; 86% still did not finish (14% vs 26% of similar VIP who did not get it, but recipients spend about half as much, so this is not proof the gift does nothing). It does not reach VIP who end 1–3 short.
Not proven: that helping them finish brings the spend back. The test answers that.
Doc: claude/vip-review-2026-10-24.md (steps 3–5)."""
}

if __name__ == '__main__':
    if sys.argv[1] == 'notes': print(json.dumps(NOTES, ensure_ascii=False))
    else: print(json.dumps(globals()[sys.argv[1]](int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] != '-' else None), ensure_ascii=False, separators=(',', ':')))
