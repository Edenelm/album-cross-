"""ALBUM END: evidence slide for the Dice post-album event test (Eden 2026-10-24: "show what Deluxe did in Domino and what Legendary did in Disney,
then show there is an opportunity"). Panels: Disney T113 test (Test vs Control revenue by period) · Domino before/after Deluxe launch
(early minus late finishers, week-after spend vs own usual pace) · Dice early finishers with no collection event.
Sources: T113 deck (Omer Cohen, 2026-02-05, https://docs.google.com/presentation/d/1eQVrW24bW9gZd4axM_KDQ2Mop4yzLZN9raDPfrKKFrI);
claude/post-album-events-2026-10-19.md (Deluxe before/after); claude/early-finishers-event-2026-10-24.md (Dice 63).
Usage (from claude/): python3 slide_event_evidence_2026-10-24.py <ev2|notes> [insertionIndex|-]"""
import json, sys, importlib.util as u
s = u.spec_from_file_location('h', 'slide_t7_dice_prize_2026-10-25.py'); h = u.module_from_spec(s); s.loader.exec_module(h)
S = 'ev2_slide'
DICE, DOMINO, DISNEY = {'red': 0.435, 'green': 0.639, 'blue': 1}, {'red': 0.961, 'green': 0.627, 'blue': 0.29}, {'red': 0.235, 'green': 0.784, 'blue': 0.706}
DIM = {'red': 0.45, 'green': 0.45, 'blue': 0.45}

def bars(R, k, x0, zero, per, data, w=0.5, gap=0.78):
    """data: (label, value %, colour, red label). Positive bars go up from the zero line, negative bars go down."""
    for i, (lab, v, col, red) in enumerate(data):
        x, hgt = x0 + i * gap, max(abs(v) * per, 0.02)
        y = zero - hgt if v >= 0 else zero
        R += h.rect(S, f'{S}_{k}_b{i}', x, y, w, hgt, col)
        ty = y - 0.27 if v >= 0 else y + hgt + 0.02
        R += h.tbox(S, f'{S}_{k}_v{i}', x - 0.2, ty, w + 0.4, 0.25, f'{v:+.0f}%' if abs(v) >= 1 else f'{v:+.1f}%', 11,
                    h.GOLD if red else h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_{k}_l{i}', x - 0.2, 3.72, w + 0.4, 0.4, lab, 8, h.GREY, False, 'CENTER')
    return R

def ev2(idx=None):
    msg = '→ A post-album collection event added revenue in a Disney test, and Deluxe closed the gap for early finishers in Domino. Dice gives its early finishers (19% of album revenue) nothing to collect: test a collection event in Dice.'
    R = h.page(S, 'Post-Album Events: Disney Test, Domino Deluxe, Dice Today',
               'Disney: test T113 (Feb 2026, album completers, 50/50) · Domino: before vs after the Deluxe launch (not a test) · Dice 63: payers who finish 2+ days before close',
               msg, idx=idx, msg_y=4.55)
    R += h.red_part(S + '_ms', msg, 'test a collection event in Dice.', h.GOLD)
    for g, (k, name, col, head) in enumerate([('dis', 'Disney', DISNEY, 'Legendary set: revenue, Test vs Control'),
                                               ('dom', 'Domino', DOMINO, 'Deluxe: early vs late finishers, week after'),
                                               ('dice', 'Dice', DICE, 'Early finishers today')]):
        px = 0.55 + g * 3.05
        R += h.rect(S, f'{S}_{k}_p', px, 1.2, 2.85, 3.2, h.CARD)
        R += h.tbox(S, f'{S}_{k}_g', px + 0.12, 1.25, 2.6, 0.3, name, 14, col, True)
        R += h.tbox(S, f'{S}_{k}_h', px + 0.12, 1.53, 2.6, 0.25, head, 8.5, h.GREY)
    # Disney T113: raw Test vs Control uplift by period (pre-test shows the groups were alike)
    R += h.rect(S, f'{S}_dis_z', 0.7, 3.2, 2.55, 0.01, h.GREY)
    R = bars(R, 'dis', 0.85, 3.2, 0.07, [('before\nthe test', -1.84, DIM, False), ('4 days of\nLegendary', 15.85, DISNEY, True), ('2 weeks\nafter', -0.2, DIM, False)])
    # Domino: early minus late finishers, spend in days 1-7 after completion vs own usual pace (pts of own pace)
    R += h.rect(S, f'{S}_dom_z', 3.75, 2.25, 2.55, 0.01, h.GREY)
    R = bars(R, 'dom', 3.82, 2.25, 0.12, [('album 15', -7, DIM, False), ('album 16', -8, DIM, False), ('album 19\nDeluxe', -1, DOMINO, True), ('album 20\nDeluxe', -2, DOMINO, True)], w=0.42, gap=0.62)
    R += h.tbox(S, f'{S}_dom_k', 3.7, 1.8, 2.6, 0.3, 'below 0 = early finishers spent less than late ones', 7.5, h.GREY)
    # Dice: the opportunity
    R += h.tbox(S, f'{S}_dice_n', 6.7, 1.95, 2.6, 0.7, '19%', 40, h.WHITE, True, 'CENTER')
    R += h.tbox(S, f'{S}_dice_t', 6.75, 2.7, 2.5, 0.5, 'of album revenue comes from 13,085 payers who finish 2+ days early', 9.5, h.WHITE, False, 'CENTER')
    R += h.tbox(S, f'{S}_dice_r', 6.75, 3.3, 2.5, 0.6, 'After 144 they get Fortune Wheel + Lava Quest: rolls only, nothing new to collect', 9.5, h.RED, True, 'CENTER')
    return R

NOTES = {S: """Question: does a post-album event for finishers bring money, and is there room for one in Dice?
Disney, test T113 (Legendary set, 12 extra stickers for album completers; start 2026-02-10; Control 12,394 / Test 12,287, 50/50; analysis deck by Omer Cohen). Revenue Test vs Control: pre-test −1.84%, during Legendary (Feb 13–16) +15.85%, 2 weeks after (Feb 16 – Mar 2) −0.2%, whole period +0.91%; diff-in-diff vs pre-test +2.75% revenue, +1.42% PU. PU during Legendary +13.39%. No payback dip after the event. Decision: Deploy.
Domino, Deluxe album (free for completers: keep collecting by upgrading duplicates to Deluxe, tier rewards, grand prize). Not a test: before (albums 15, 16) vs after the launch (19, 20). Early finishers (2+ days before close, have time in Deluxe) vs late finishers (close day or day before, almost no Deluxe time). Spend in days 1–7 after completion vs own usual pace, early minus late: 15 −7, 16 −8 → 19 −1, 20 −2 (points of own pace). Buyers in days 1–7: +4.2 pts (diff-in-diff). Caveat: album 17 (half of finishers in Deluxe) shifted too, so part may be other album differences; a holdout is the clean proof.
Dice 63: 13,085 payers finished 2+ days before close (6.5% of payers, 62% of payer finishers) = 19% of album revenue ($4,757,310). After 144 they get the grand prize, a Fortune Wheel spin and a Lava Quest (rolls), nothing new to collect until the next album.
Recommendation: TEST in Dice a post-album collection event (like Deluxe / Legendary) for payers who finish 2+ days before close; Control = today. Primary metric: revenue per player from completion to day 7 of the next album (catches pull-forward). Guardrails: next-album spend and finish rate. Effect size is not estimated: the Disney and Domino numbers come from other games.
Sources: T113 deck https://docs.google.com/presentation/d/1eQVrW24bW9gZd4axM_KDQ2Mop4yzLZN9raDPfrKKFrI · claude/post-album-events-2026-10-19.md (Deluxe before/after; SQL claude/deluxe_did_domino.sql) · claude/early-finishers-event-2026-10-24.md."""}

if __name__ == '__main__':
    if sys.argv[1] == 'notes': print(json.dumps(NOTES, ensure_ascii=False))
    else: print(json.dumps(globals()[sys.argv[1]](int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] != '-' else None), ensure_ascii=False, separators=(',', ':')))
