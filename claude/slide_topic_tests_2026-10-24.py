"""ALBUM END: one short test slide after each topic + topic-9 summary (Eden 2026-10-24: "a slide with little text after every topic, with the relevant test or tests").
Eden's 4 Disney levers are EXTRA arms next to the deck's existing tests, not replacements: more Royals + Joker sale at the end; more Goldens + Golden sale at the end;
Royals from regular packs; locked end stickers 2 Royals + 1 Golden instead of 2 Goldens + 1 Royal.
Usage (from claude/): python3 slide_topic_tests_2026-10-24.py <slide key|notes> [insertionIndex|-]"""
import json, sys, importlib.util as u
s = u.spec_from_file_location('h', 'slide_t7_dice_prize_2026-10-25.py'); h = u.module_from_spec(s); s.loader.exec_module(h)

def card(S, k, x, y, w, hh):
    return h.box(S, f'{S}_{k}', x, y, w, hh, 'RECTANGLE') + [{'updateShapeProperties': {'objectId': f'{S}_{k}', 'shapeProperties': {
        'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': h.CARD}}},
        'outline': {'outlineFill': {'solidFill': {'color': {'rgbColor': h.EDGE}}}, 'weight': {'magnitude': 1, 'unit': 'PT'}}},
        'fields': 'shapeBackgroundFill.solidFill.color,outline.outlineFill.solidFill.color,outline.weight'}}]

def test_slide(S, title, who, control, arms, measure, msg, idx=None):
    """Who line · Control card | one card per test arm · measure line · bottom line. arms: (name, text, is_new)."""
    R = [r for r in h.page(S, title, '-', msg, idx=idx, msg_y=4.45) if f'{S}_su' not in json.dumps(r)]
    R += h.tbox(S, f'{S}_wl', 0.61, 0.95, 0.8, 0.25, 'WHO', 9, h.GREY, True)
    R += h.tbox(S, f'{S}_wb', 0.61, 1.15, 8.8, 0.45, who, 12, h.WHITE)
    y, hh, cw = 1.75, 1.6, 2.3
    R += card(S, 'c0', 0.61, y, cw, hh)
    R += h.tbox(S, f'{S}_c0h', 0.75, y + 0.08, 2.0, 0.4, 'Control', 18, h.GREY, True)
    R += h.tbox(S, f'{S}_c0b', 0.75, y + 0.55, cw - 0.25, hh - 0.6, control, 10.5, h.WHITE)
    n, gap = len(arms), 0.12
    aw = (9.39 - 0.61 - cw - 0.2 - (n - 1) * gap) / n
    for i, (name, text, new) in enumerate(arms):
        x = 0.61 + cw + 0.2 + i * (aw + gap)
        R += card(S, f'a{i}', x, y, aw, hh)
        R += h.tbox(S, f'{S}_a{i}h', x + 0.12, y + 0.08, aw - 0.2, 0.4, name, 16 if n < 4 else 13, h.GOLD, True)
        if new:
            R += h.tbox(S, f'{S}_a{i}n', x + aw - 0.62, y + hh - 0.3, 0.55, 0.22, 'NEW', 7.5, h.RED, True, 'END')
        R += h.tbox(S, f'{S}_a{i}b', x + 0.12, y + 0.55, aw - 0.2, hh - 0.6, text, 10.5 if n < 4 else 9.5, h.WHITE)
    R += h.tbox(S, f'{S}_ml', 0.61, 3.5, 1.2, 0.25, 'MEASURE', 9, h.GREY, True)
    R += h.tbox(S, f'{S}_mb', 0.61, 3.7, 8.8, 0.5, measure, 11, h.WHITE)
    return R

SLIDES = {
 'tx_gate': dict(title='Test: Locked End Stickers in Disney',
    who='All Disney payers (325,842–371,049 per album). 16–20% end 1–3 short = 37–38% of album revenue; 86–97% of them miss a locked sticker.',
    control='2 Goldens + 1 Royal locked to the end.',
    arms=[('2 Royals + 1 Golden', 'Like Domino (1 Golden + 2 Royals) and Dice (1 Golden + 2 Supers).', True)],
    measure='Main: finish rate and revenue per payer in the last 4 days · Guardrail: next-album spend',
    msg='Disney is the only game that locks 2 Goldens to the end. Test the Domino mix.'),
 'tx_gold': dict(title='Tests: Goldens in Disney',
    who='89–97% of Disney payers miss a Golden that is already out 10 days before close (57–86% of album revenue); 28–30% miss only 1–3 of them (35–54%).',
    control='24 Goldens; packs and rotating offers.',
    arms=[('Pick your Golden', 'A daily offer for the Golden you miss, last 10 days.', False),
          ('More Goldens + sale', 'More Goldens in the album (Dice / Domino: 28), sold at the end.', True)],
    measure='Main: Goldens missing at close, revenue per payer in the last 10 days · Guardrail: next-album spend',
    msg='Goldens are what Disney payers miss most. Test a way to get the missing ones at the end.'),
 'tx_royal': dict(title='Tests: Royals and the Joker in Disney',
    who='Disney middle payers (P50–95) 4+ stickers away 14 days before close: 22% of game revenue. Payers end 2.7 of 7 Royals short.',
    control='7 Royals, only from a Royal pack. Joker sold in the last 3 days.',
    arms=[('Steady Royal', 'A Royal every few days in the last 14 days.', False),
          ('Royals in packs', 'Royals can drop from regular packs.', True),
          ('More Royals + Joker', 'More Royals in the album, Joker sold at the end.', True),
          ('Joker earlier', 'Sale from 7 days before close, or an event prize.', False)],
    measure='Main: stickers missing at close, revenue per payer in the last 14 days · Guardrail: next-album spend',
    msg='Disney has the fewest rares, and they come mainly from Royal packs. Test more ways in, one arm each.'),
 'tx_end': dict(title='End Goal per Spend Level: Disney Test, Domino Adopt',
    who='Disney $2–20 a day payers who end 4+ stickers away: 26% of album revenue (Dice 10%, Domino 11%).',
    control='Disney: one end for everyone. Domino: album 19 end.',
    arms=[('Disney: TEST', 'An extra sticker source for $2–20 payers from 14 days before close.', False),
          ('Domino: ADOPT', 'Album 20 end as the standard; watch the goal per level daily from close−14.', False)],
    measure='Disney main: revenue per payer in the last 4 days, share within 3 stickers at close−4 · Guardrail: finish rate',
    msg='Domino already found the end that works. Disney needs a test.'),
 'tx_rv': dict(title='Test: Rewarded Video Limits in Domino',
    who='Domino 20 finishers who never paid in the album: 7,517 players; their ad revenue was 0.28% of game revenue.',
    control='RV without a daily limit; RV gives sticker packs and Puzzle pieces.',
    arms=[('Daily RV cap', 'A cap on views per day (level = management choice).', False),
          ('RV without stickers', 'RV keeps coins and energy, no sticker packs / Puzzle pieces.', False)],
    measure='Main: payer conversion · Guardrails: retention, ad revenue, next-album 14 days',
    msg='Free finishers get the album from videos. Test limits; keep Puzzle Jokers for payers.'),
 'tx_event': dict(title='Test: A Post-Album Collection Event in Dice',
    who='Dice payers who finish 2+ days before close: 13,085 players (6.5% of payers), 19% of album revenue.',
    control='After 144: Fortune Wheel + Lava Quest, nothing to collect.',
    arms=[('Collection event', 'Extra stickers to collect after 144, like Domino Deluxe / Disney Legendary.', False)],
    measure='Main: revenue per player from completion to next-album day 7 · Guardrails: next-album spend, finish rate',
    msg='Disney tested this (T113): +16% revenue during the event, +2.75% over the whole period. Dice early finishers have nothing to collect.'),
}

def t9(idx=None):
    S = 't9_slide'
    msg = 'Order: evidence from a real test first, then size. Disney end tests share players: run them one after another.'
    R = h.page(S, 'Recommendations and Test Order', 'Order and sizes are options for management · % = share of album revenue of the players in the test',
               msg, idx=idx, msg_y=4.55)
    rows = [('1', 'Dice', 'Post-album collection event', 'early finishers · 19%', 'TEST', 'Disney test T113'),
            ('2', 'Disney', 'Rares and Goldens: more ways in, new locked mix', '$2–20 ending 4+ away · 26%', 'TEST', 'descriptive'),
            ('3', 'Disney first', 'Help near-finishers in the last 4 days', 'VIP / >$20 1–3 short · 4–9%', 'TEST', '9 of 9 albums'),
            ('4', 'Domino', 'Album 20 end as standard, daily goal watch', 'all payers', 'ADOPT', 'album 20 worked'),
            ('5', 'Domino', 'RV daily cap / RV without stickers', 'free finishers · 7,517', 'TEST', 'descriptive'),
            ('6', 'Dice', 'Bigger grand prize for $2K+', '~300 finishers · 7%', 'TEST', 'descriptive'),
            ('✗', 'All', 'Payout change after close · Dice VIP gift as is', '', 'DO NOT ADOPT', 'not the lever')]
    cols = [(0.61, 0.35), (0.96, 1.05), (2.01, 3.3), (5.31, 1.9), (7.21, 0.95), (8.16, 1.25)]  # live slide: DO NOT ADOPT box widened to 1.2in, its evidence cell moved to 8.4in
    heads = ['#', 'Game', 'What', 'Who · revenue', 'Decision', 'Evidence']
    for j, (x, w) in enumerate(cols):
        R += h.rect(S, f'{S}_h{j}', x, 1.2, w - 0.03, 0.3, {'red': 0.259, 'green': 0.522, 'blue': 0.957})
        R += h.tbox(S, f'{S}_ht{j}', x + 0.04, 1.21, w - 0.08, 0.28, heads[j], 9.5, h.WHITE, True)
    for i, row in enumerate(rows):
        y = 1.55 + i * 0.4
        R += h.rect(S, f'{S}_r{i}', 0.61, y, 8.77, 0.36, h.CARD)
        for j, (x, w) in enumerate(cols):
            if not row[j]: continue
            c = h.GOLD if (j == 4 and row[4] != 'DO NOT ADOPT') else (h.RED if j == 4 else h.WHITE)
            R += h.tbox(S, f'{S}_c{i}{j}', x + 0.04, y + 0.03, w - 0.08, 0.32, row[j], 9.5, c, j in (0, 4))
    return R

NOTES = {
 'tx_gate': """Fact: Disney locks 2 Goldens + 1 Royal to the end; Domino 1 Golden + 2 Royals; Dice 1 Golden + 2 Supers. Disney near-finishers missing at least one locked sticker: 97% / 86% (albums 14 / 15, old end status close−1); 2% / 5.5% of payers hold the top locked sticker 2 days before close (Dice 7.5–11%, Domino 5.6–9.3%).
Test (Eden's idea, 2026-10-24): 2 Royals + 1 Golden locked to the end. Hypothesis, not a decision; size of the change and which stickers = product team.
The locked-sticker share (86–97%) is from the old gates slide; topic-4 gates were not rerun for Disney. Sizes: claude/topic9-disney-test-sizes-2026-10-24.md.
Source: claude/topic4-gates-2026-10-22.md, dz7 slide.""",
 'tx_gold': """Existing test (gtest slide): daily 'pick the Golden you miss' offer in the last 10 days (Dice sells Goldens every day to 3–5% of active payers; Disney 14 1.1–5.1% a day).
New arm (Eden): more Goldens in the album and a Golden sale at the end. Caution: more Goldens without more supply can raise what payers miss — the sale at the end is part of the arm.
Disney 15 payers miss on average 4.2 of 24 Goldens at close (18%); Goldens are 42–56% of what Disney payers miss (Dice 2.0 of 28).
Sizes: claude/topic9-disney-test-sizes-2026-10-24.md (22 of 24 Goldens out by close−10; missing any 89–97% of payers, 1–3 missing 28–30%).
Source: claude/disney-stalls-missing-2026-10-23.md, claude/golden-offers-by-day-2026-10-23.md.""",
 'tx_royal': """Who: Disney middle payers (P50–95 of spend so far) with 4+ missing 14 days before close: 22% of Disney game revenue. After their last new Royal (11–13 days before close) they stay active 72% of days but spend only 3–4% of their album spend. Disney 15 payers miss 2.7 of 7 Royals at close (39%).
Arms: existing steady Royal source (tst slide) and Joker earlier — sale from close−7 or event prize (dj1 slide; Domino 20 event Joker: payers spent 1.8× their usual pace in those 2 days). New (Eden): Royals from regular packs; more Royals in the album with a Joker sale at the end.
Today: Royal only from a Royal pack; Joker sold only in the last 3 days (about 0.1% of payers a day get a Joker before that).
One arm per group, same Control; the number of arms depends on group size. Hypotheses, not decisions. Free Royals linked to more progress, not to more paying (descriptive) — measure spend, not only progress.
Source: claude/far-rare-gate-gap-2026-10-23.md, claude/royal-then-pay-check-2026-10-23.md.""",
 'tx_end': """Disney (TEST): below the goal in every level under $20; $2–20 payers who end 4+ away = 26% of album revenue (Dice 10%, Domino 11%). Few Disney payers are within 3 when the last stickers unlock (9% → 12% from close−6 to close−4). Test: extra sticker source for $2–20 payers from close−14; Control vs Test.
Domino (ADOPT): album 20 reached Dice's level in 3 of 4 levels; album 19 was far below under $20. Make album 20's end the standard and watch the goal per level daily from close−14 to close−4.
The payers-within-3 ↔ end-revenue link is a correlation across 6 albums. Source: r2 slide notes.""",
 'tx_rv': """Domino 20 finishers with no purchase on any album day: 7,517. Median watcher 2,887 views in the album (~93 a day); RV packs gave ~18 new stickers each; Puzzle Joker gave 60% their last sticker. Ad revenue $45,084 (0.28% of game purchase revenue during the album); 1% paid in the week after.
Test (Control = today): daily RV cap (level = management) and RV rewards without sticker packs / Puzzle pieces (keep coins, energy). Measures: payer conversion, retention, ad revenue, next album 14 days. Caveat: ~93 views a day may include automated viewing — ask the Domino ads team.
Source: claude/domino-rv-rewards-2026-10-20.md, claude/domino-rv-3albums-2026-10-24.md.""",
 'tx_event': """Dice 63: 13,085 payers finished 2+ days before close (6.5% of payers) = 19% of album revenue ($4,757,310). After 144: grand prize, Fortune Wheel spin, Lava Quest (rolls), nothing new to collect.
Evidence: Disney T113 (Legendary set, 50/50, Feb 2026): revenue Test vs Control +15.85% during the event (raw), −0.2% the 2 weeks after; DiD whole period +2.75%. Domino Deluxe before/after (not a test): early minus late finishers week-after spend −7/−8 → −1/−2 points of own pace.
Main measure: revenue per player from completion to next-album day 7. Effect size not estimated. Source: ev2 slide notes, claude/early-finishers-event-2026-10-24.md.""",
 't9_slide': """Order rule (my proposal; management decides): tests backed by a real test in another game first, then by size of the population.
1 Dice post-album event (19% of album revenue; Disney T113). 2 Disney end for $2–20 payers ending 4+ away (26%): existing arms (steady Royal, pick your Golden, Joker earlier, extra source from close−14) + Eden's arms (more Royals + Joker sale, more Goldens + Golden sale, Royals in packs, locked stickers 2 Royals + 1 Golden). 3 Help near-finishers in the last 4 days, Disney first (VIP 1–3 short 4–5% of Disney album revenue; >$20 1–2 short 4–9% in all games; 9 of 9 albums below normal week). 4 Domino: adopt the album-20 end (no test), in parallel. 5 Domino RV cap (7,517 free finishers). 6 Dice bigger prize for $2K+ (~300 finishers per album, 7%; needs 2–3 albums).
Disney tests 2 and 3 reach the same players in the last days: run them one after another or with separate groups.
Do not adopt: a payout change after close; the Dice VIP gift as is (it reaches VIP already 4+ away; 86% still do not finish).
Each test has its own slide after its topic."""}

if __name__ == '__main__':
    k = sys.argv[1]
    if k == 'notes': print(json.dumps(NOTES, ensure_ascii=False)); sys.exit()
    idx = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] != '-' else None
    R = t9(idx) if k == 't9_slide' else test_slide(k, idx=idx, **SLIDES[k])
    print(json.dumps(R, ensure_ascii=False, separators=(',', ':')))
