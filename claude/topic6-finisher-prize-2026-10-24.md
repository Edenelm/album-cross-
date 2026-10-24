# Topic 6 point 1: why finishers come back at different levels: prize size or game? (2026-10-24)

Eden (handoff `next-session-prompt-2026-10-26.md`, point 1): finishers come back at different levels, maybe because of the prize size or how the game works after the album. Find which game is the problem, which population, and its revenue share. Same measure in all three games; compare the week after with the last week before close.
SQL: `claude/topic6_finisher_prize_2026-10-24.sql` (Domino 155–162 GB, Disney album 15 only 223 GB, Dice 118 GB). Slides: **t6e_slide, t6f_slide** (ALBUM END, after s6b, before t7a). Generator `claude/slide_t6_finisher_prize_2026-10-24.py`; images `claude/slides/t6e.png`, `t6f.png`.

## Definitions
- Population, spend level, last week, week after: exactly as `topic6-before-after-2026-10-24.md`. Paying finishers = standard-population payers with 144 stickers on close−1. Spend level = album $ a day before the last quarter (= own pace).
- **Prize in days of own play** = album prize ÷ the player's own play per day (album start to close−1). Same measure in all three games:
  - Dice: `album_reward_value` (rolls, last row before close) ÷ rolls out per day (`30_intermediate.user_daily_rolls_in_out`).
  - Domino: 'album completed' coins ÷ coins out per day, allowance units (`prod_10_staging.stg_coins_in_vw` / `stg_coins_out_vw`; filters as the payout check: units 0–1000, not IL/RO). Staging approved by Eden 2026-10-24.
  - Disney: same from `mp_raw_prod_vw.mp_coins_in_vw` / `mp_coins_out_vw` (units 0–1000, balance 0–5000).
- Buckets <2 / 2–4 / 4+ days: **my choice** (round numbers, as in topic 7).
- Revenue share = share of all standard-population paying players' album revenue.
- Albums: Dice 61/63, Domino 19/20, **Disney 15 only** (both albums = 490 GB; I said ~230 GB when asking, so I ran the latest album only).
- Checks: payer finisher counts match earlier docs (Dice 63 19,688 = topic 7; $2–20 finishers Domino 20 4,025 and Disney 15 7,498 = topic 6). Mistake caught on the way: the first Domino run cut coin events at 10-05 but album 20 closes 10-12 (95% "no prize"); re-run with 10-12, no prize now 5%.

## Results
### How big the prize is (paying finishers, % with a recorded prize)
| Game · album | Median prize (days of own play) | <2 days | 2–4 days | 4+ days | 2+ days: players · % of payers · % of album revenue |
|---|---|---|---|---|---|
| Dice 63 | 2.2 | 46% | 35% | 19% | 10,606 · 5% · 7% |
| Dice 61 | 2.2 | 46% | 35% | 19% | 7,832 · 4% · 6% |
| Domino 20 | 1.3 | 74% | 23% | 3% | 2,007 · 2% · 3% |
| Domino 19 | 1.0 | 83% | 15% | 1% | 756 · 0.6% · 1% |
| Disney 15 | 1.1 | 85% | 14% | 1% | 1,926 · 0.6% · 0.7% |
No prize found: Domino 20 443 (5%), Domino 19 489 (10%), Disney 15 58, Dice 0.

### Last week → week after (% of own pace), and bought in the week after, latest album
| Spend level · prize | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| ≤$2 · <2 days | 639 → 243 · 55% (2,655) | 594 → 277 · 52% (1,733) | 605 → 345 · 59% (2,141) |
| ≤$2 · 2–4 | 590 → 198 · 51% (3,429) | 621 → 298 · 56% (1,013) | 598 → 308 · 59% (995) |
| ≤$2 · 4+ | 573 → 157 · 42% (2,568) | 644 → 242 · 44% (178) | 657 → 362 · 54% (83) |
| $2–5 · <2 | 303 → 135 · 70% (2,178) | 309 → 169 · 75% (1,158) | 291 → 175 · 76% (2,325) |
| $2–5 · 2–4 | 289 → 119 · 70% (1,954) | 315 → 168 · 77% (364) | 249 → 158 · 73% (538) |
| $2–5 · 4+ | 278 → 104 · 65% (875) | 313 → 147 · 69% (45) | small (31) |
| $5–20 · <2 | 209 → 110 · 80% (2,864) | 201 → 136 · 86% (1,887) | 169 → 119 · 86% (4,300) |
| $5–20 · 2–4 | 200 → 98 · 79% (1,429) | 181 → 128 · 87% (340) | 156 → 128 · 85% (274) |
| >$20 · <2 | 135 → 85 · 87% (1,385) | 122 → 101 · 94% (843) | 110 → 86 · 94% (1,863) |
Dice 61, $2–5 · <2: 309 → 158 · 72%; $5–20 · <2: 210 → 119 · 80%. Domino 19: 355 → 181; 207 → 127.

## Reading
- **Fact:** Dice gives far bigger prizes for the player's own play: half of Dice paying finishers get 2+ days (both albums); Domino 1 in 4 (album 20; 1 in 6 in album 19), Disney 1 in 7.
- **Fact:** inside each game, a bigger prize goes with fewer buyers in the next week in light payers (≤$2: Dice 55% → 42%, Domino 52% → 44%, Disney 59% → 54%). In Domino and Disney the 4+ groups are small (45–178 players).
- **Fact:** with a small prize (<2 days), Dice finishers still come back the lowest: $2–5 135% vs 169% / 175%; $5–20 110% vs 136% / 119%, after the same push in the last week. Album 61 is better (158% / 119%) but still below Domino.
- **Interpretation:** two things add up in Dice: (1) many more big prizes (a ladder that never goes down), and (2) a weaker return even without a big prize, which points to how Dice starts the next album, or to album 63 being weak at every level (topic7-top-payers). Not tested.
- **Money:** most of these groups still spend at or above their own album pace in the week after (below pace: >$20 in Dice 63 and Disney 15, and Dice 63 $5–20 with a 2+ day prize at 90–98%), so the cost is mainly a smaller rebound, not a loss against pace. No $ estimate (no test result). The population worth working on is Dice payers ≤$5 a day with a 2+ day prize: 8,826 players, 4% of payers, 4% of album revenue (album 63). The same group in Domino 20 is 1,600 players (1.3% of revenue), in Disney 15 1,647 (0.5%).
- **Which game:** Dice. Domino and Disney show the same direction in light payers, but on small groups and with a smaller prize.

## Recommendation
- Prize: **TEST** as already proposed in t7c (prize = 2–3 days of own play), no change.
- The "small-prize Dice finishers also come back low" gap: **do not adopt anything yet**. Next check: compare the first days of the next album across games for small-prize finishers (gates, roll stock, offers), and re-run Dice with albums 63 → 65 when the after-week is complete (album 67 day 8 = 2026-10-27) to see if it is only album 63.

## Open
- Disney 14 not run (490 GB for both albums). Run only if Eden wants the second Disney album.
- Domino 19: 10% of finishers with no 'album completed' coins found (Domino 20: 5%). Not checked why (maybe a different source name or the prize arrived on the close day).
