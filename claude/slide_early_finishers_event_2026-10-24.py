"""ALBUM END: slide proposing a post-album collection event test for Dice (Eden 2026-10-24).
Bars = share of album revenue from payers who had all 144 stickers 2+ days before close; box = what each game gives them after 144.
Data: claude/early-finishers-event-2026-10-24.md (SQL claude/early_finishers_event_2026-10-24.sql); event spend fields: claude/event-spend-fields-2026-10-24.md.
Usage (from claude/): python3 slide_early_finishers_event_2026-10-24.py <ev1|notes> [insertionIndex|-] [logo_dice logo_domino logo_disney]"""
import json, sys, importlib.util as u
s = u.spec_from_file_location('h', 'slide_t7_dice_prize_2026-10-25.py'); h = u.module_from_spec(s); s.loader.exec_module(h)
E, S = h.E, 'ev1_slide'
LOGOS = sys.argv[3:6] if len(sys.argv) > 5 else [None, None, None]
# game, color, % album revenue, payers, % payers, event head, event body
DATA = [('Dice', {'red': 0.435, 'green': 0.639, 'blue': 1}, 19, '13,085', '6.5%', 'Fortune Wheel + Lava Quest', 'rolls only, nothing new to collect'),
        ('Domino', {'red': 0.961, 'green': 0.627, 'blue': 0.29}, 24, '5,935', '5.6%', 'Deluxe album', 'keep collecting: upgrade stickers to Deluxe'),
        ('Disney', {'red': 0.235, 'green': 0.784, 'blue': 0.706}, 9, '5,440', '1.7%', 'Legendary set', '12 extra stickers · test T113: +16% revenue')]

def ev1(idx=None):
    msg = '→ In Dice, payers who finish 2+ days early bring 19% of album revenue, but they get only rolls until the next album. Test a collection event like Domino\'s Deluxe for them.'
    R = h.page(S, 'Finishers 2+ Days Early: Revenue Share and Post-Album Event',
               'Paying players, latest album (Dice 63, Domino 20, Disney 15) · bar = % of album revenue from payers with all 144 stickers 2+ days before close · box = what the game gives them after 144',
               msg, idx=idx, msg_y=4.62)
    R += h.red_part(S + '_ms', msg, 'Test a collection event like Domino\'s Deluxe for them.', h.GOLD)
    BASE, PER = 3.0, 0.055
    for g, (name, col, v, n, pp, head, body) in enumerate(DATA):
        cx, k = 1.9 + g * 3.1, name.lower()
        hgt = v * PER
        R += h.rect(S, f'{S}_{k}_b', cx - 0.45, BASE - hgt, 0.9, hgt, col)
        R += h.tbox(S, f'{S}_{k}_v', cx - 0.8, BASE - hgt - 0.33, 1.6, 0.3, f'{v}%', 16, h.WHITE, True, 'CENTER')
        if LOGOS[g]:
            R += [{'createImage': {'objectId': f'{S}_{k}_logo', 'url': LOGOS[g], 'elementProperties': {'pageObjectId': S,
                   'size': {'width': {'magnitude': int(0.89 * E), 'unit': 'EMU'}, 'height': {'magnitude': int(0.31 * E), 'unit': 'EMU'}},
                   'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int((cx - 0.445) * E), 'translateY': int((BASE + 0.05) * E), 'unit': 'EMU'}}}}]
        R += h.tbox(S, f'{S}_{k}_n', cx - 1.3, BASE + 0.37, 2.6, 0.22, f'{n} payers · {pp} of payers', 9, h.GREY, False, 'CENTER')
        R += h.rect(S, f'{S}_{k}_c', cx - 1.3, 3.66, 2.6, 0.72, h.CARD)
        R += h.tbox(S, f'{S}_{k}_ch', cx - 1.25, 3.7, 2.5, 0.25, head, 11, h.RED if g == 0 else h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_{k}_cb', cx - 1.25, 3.96, 2.5, 0.38, body, 9, h.GREY, False, 'CENTER')
    R += h.rect(S, f'{S}_base', 0.8, BASE, 8.4, 0.012, h.GREY)
    return R

NOTES = {S: """What this shows: paying players who had all 144 stickers at least 2 days before the album closed, latest album. The bar is their share of album revenue (start to close−1); the box is what each game gives them after 144.
Numbers: Dice 63 13,085 payers (6.5% of payers, 62% of payer finishers) = 19% of album revenue ($4,757,310). Domino 20 5,935 (5.6%, 69% of finishers) = 24% ($3,084,138). Disney 15 5,440 (1.7%, 41% of finishers) = 9% ($3,373,822).
Example: a Domino payer who finishes 5 days before close can open the Deluxe album and keep collecting (duplicates upgrade stickers to Deluxe, tier rewards, a grand prize). A Dice payer who finishes 5 days before close gets the grand prize, a Fortune Wheel spin and a Lava Quest: rolls, but nothing new to collect until the next album.
Evidence that such an event adds money (not only moves it): Disney test T113 (Legendary vs control): revenue +15.85% during the event, −0.2% in the 2 weeks after (no payback dip). Domino (before/after Deluxe launch, albums 15/16 vs 19/20, early vs late finishers): +4.2 pts buyers in days 1–7 after completion — not a test.
Not known: how much the events sell themselves. The event spend fields in the data count ALL purchases while the player is in the event, not event items (claude/event-spend-fields-2026-10-24.md).
Recommendation: TEST in Dice a post-album collection event for payers who finish 2+ days before close; Control = today (Fortune Wheel + Lava Quest). Measure revenue per player from completion to day 7 of the next album, and next-album spend and finish rate (guardrails).
Who: standard-population payers (not first album, not excluded, login ratio ≥ 0.5, active on close−1, paid during the album). Finish date = first day with 144 unique set stickers before close.
SQL: claude/early_finishers_event_2026-10-24.sql. Doc: claude/early-finishers-event-2026-10-24.md."""}

if __name__ == '__main__':
    if sys.argv[1] == 'notes': print(json.dumps(NOTES, ensure_ascii=False))
    else: print(json.dumps(globals()[sys.argv[1]](int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] != '-' else None), ensure_ascii=False, separators=(',', ':')))
