# Payers who finish 2+ days early, and what each game gives them (2026-10-24)

Why: Eden wants to propose to Dice a test of a post-album event like Domino Deluxe / Disney Legendary.
SQL: `claude/early_finishers_event_2026-10-24.sql` (Disney 10.2 GB, Domino 4.5 GB, Dice 91.5 GB).
Population: standard-population payers (not first album, not excluded, login ratio ≥ 0.5, row on close−1, album spend > 0 up to close−1), latest album.
Finish date: first day with 144 unique set stickers in the daily album table (close day not in the window: close-day finishers are in "not finished" here).
Revenue: album-table spend, album start to close−1.

| Game / album | Group | Payers | % of payers | Album revenue | % of album revenue |
|---|---|---|---|---|---|
| Dice 63 | finished 2+ days before close | 13,085 | 6.5% | $4,757,310 | 19.3% |
| Dice 63 | finished the day before close | 7,881 | 3.9% | $2,104,738 | 8.5% |
| Dice 63 | not finished by close−1 | 181,699 | 89.7% | $17,776,970 | 72.1% |
| Domino 20 | finished 2+ days before close | 5,935 | 5.6% | $3,084,138 | 24.0% |
| Domino 20 | finished the day before close | 2,613 | 2.5% | $853,538 | 6.7% |
| Domino 20 | not finished by close−1 | 97,972 | 92.0% | $8,886,868 | 69.3% |
| Disney 15 | finished 2+ days before close | 5,440 | 1.7% | $3,373,822 | 9.2% |
| Disney 15 | finished the day before close | 7,744 | 2.4% | $3,380,339 | 9.3% |
| Disney 15 | not finished by close−1 | 311,971 | 95.9% | $29,759,306 | 81.5% |

Check: finishers by close−1 = 20,966 / 8,548 / 13,184, same as `gap-by-day-3games-2026-10-24.md`. Early finishers = 62% / 69% / 41% of them.

What each game gives after 144: Dice = Fortune Wheel + Lava Quest (rolls; no purchases tagged to them); Domino = Deluxe album (free, keep collecting, tier rewards, grand prize; Confluence "Album (Deluxe) Recompletion"); Disney = Legendary set (12 extra stickers).
Evidence an event adds money: Disney T113 (test) +15.85% revenue during Legendary, −0.2% in the 2 weeks after. Domino Deluxe before/after (albums 15/16 vs 19/20): +4.2 pts buyers in days 1–7 for early vs late finishers (not a test). How much the events sell themselves is not known (`event-spend-fields-2026-10-24.md`).
Recommendation: TEST in Dice a post-album collection event for payers who finish 2+ days early (Control = today). Slide: ev1_slide (`claude/slide_early_finishers_event_2026-10-24.py`).
