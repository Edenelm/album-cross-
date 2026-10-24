# Topic 6 point 2: payers 1–2 stickers short: what happened after the album, and the payout after close (2026-10-24)

Eden (handoff `next-session-prompt-2026-10-26.md`, point 2): payers 1–2 stickers short. What happened after the album, and how the post-close payout (Part 1 deck slide 36: payout in days 1–3 vs mid-album, by end status) affects them. Same population and windows as the topic 6 rebuild.
SQL: `claude/topic6_short_payers_2026-10-24.sql` (Disney 25 GB, Domino 10 GB, Dice 114 GB). Slide: **t6g_slide** (ALBUM END, after t6f, before t7a). Generator `claude/slide_t6_finisher_prize_2026-10-24.py` (`g`); image `claude/slides/t6g.png`.

## Definitions
- Population, spend level, last week, week after: exactly as `topic6-before-after-2026-10-24.md`. 1–2 short = 142–143 stickers on close−1 (paying players, standard population).
- Close-day outcome = 144 by the end of the close day. Domino and Disney: daily table including the close-day row. Dice: sticker table `30_intermediate.fact_user_album_stickers` (the Dice daily table does not update stickers on the close day).
- Checks: $2–20 group sizes match topic 6 (Dice 63 11,748, Domino 20 5,749, Disney 15 10,190).

## Results — last week → week after (% of own pace), bought in the week after
| Spend level | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| ≤$2 | 270 → 146 · 46% (16,810 · 3%) | 236 → 180 · 56% (7,582 · 3%) | 418 → 238 · 55% (5,329 · 1%) |
| $2–5 | 159 → 100 · 71% (6,202 · 4%) | 153 → 119 · 76% (3,147 · 4%) | 217 → 138 · 76% (4,278 · 2%) |
| $5–20 | 125 → 86 · 78% (5,546 · 10%) | 107 → 96 · 84% (2,602 · 10%) | 134 → 100 · 86% (5,912 · 7%) |
| >$20 | 85 → 68 · 82% (1,185 · 8%) | 68 → 71 · 84% (356 · 5%) | 90 → 76 · 91% (1,664 · 7%) |
| All | 129 → 87 · 59% (29,743 · 24%) | 120 → 104 · 67% (13,687 · 22%) | 132 → 98 · 74% (17,183 · 17%) |
(players · % of paying players' album revenue.)

Previous album, >$20: Dice 61 84 → 80, Domino 19 84 → 73, Disney 14 87 → 80. $5–20: Dice 61 125 → 101, Domino 19 126 → 100, Disney 14 123 → 103.

### Close day
| | Finished on the close day | Week after (finished on close day vs still short) |
|---|---|---|
| Dice 63 | 2,650 of 29,743 (9%) | 84% vs 87% |
| Domino 20 | 1,001 of 13,687 (7%) | 106% vs 103% |
| Disney 15 | 1,949 of 17,183 (11%) | 109% vs 96% |
Previous albums: Dice 61 8%, Domino 19 12%, Disney 14 9%.

### Payout after close (from Part 1 slide 36, not re-run)
Median payout in days 1–3 of the next album vs the same player mid-album, 1–2 short at the end of the close day: Dice +2% to +5%, Domino −4% to −12%, Disney −3% to −12%.

## Reading
- **Fact:** few 1–2-short payers finish on the close day (7–11%), and finishing then barely changes the week after in Dice and Domino (Disney +13 points).
- **Fact:** in every game the 1–2-short payers up to $20 a day push in the last week and come back near or above their pace. Over $20 a day they were already below pace in the last week (68–90%) and in Dice and Disney drop further after close (to 68% / 76%; previous albums 80% / 80%). Domino 20 is the exception (68 → 71); Domino 19 dropped (84 → 73).
- **Fact:** Dice has the weakest return of the three (all levels 87% vs 104% / 98%) even though its payout after close does not fall (+2–5%), while Domino and Disney payout falls 3–12%.
- **Interpretation:** across games, the lower payout after close does not line up with a weaker return, so payout is not the main reason 1–2-short payers come back lower. Within each game this is not checked yet.
- **Money:** >$20 1–2-short payers are 8% (Dice) and 7% (Disney) of album revenue; their week after is 17 / 14 points below the last week. No $ estimate without a test.

## Recommendation
- Soft landing (extra payout in days 1–3) for 1–2-short payers: **do not adopt yet**. The cross-game pattern does not support it; the within-game check comes first.
- >$20 payers 1–2 short in Dice and Disney: the window is before close (they are already below pace in the last week). This is the existing test 3 (offer for the last stickers to $20+ payers before the last 4 days), with the week after added as a measure.

## Open
- Within-game payout check: split 1–2-short payers by their own payout change (days 1–3 vs mid-album) and compare week-after spend. Needs the Mixpanel payout queries (`payout_mixpanel_def_queries.sql`, per player), about 400 GB for the latest albums. Not run, waiting for Eden.
- Part 1 slide 34 uses a different cut ($20+ payers 2–3 short at the end of the close day, last 4 days vs usual spend). There the week after is a partial recovery from the last 4 days; here it is lower than the last 7 days. Both can be true; say so if both slides are shown.
