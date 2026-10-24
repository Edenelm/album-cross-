# Domino: did album 20's easier end pay a second time, at the start of album 21? (2026-10-24)

Eden: Part 1 deck slides 38–47 (chapter 7) + topic 6 → "finishing pays twice"? The missing link was Domino: album 20 made the end easier (two Puzzle Jokers, +44% paying finishers, spend held — Part 1 slides 38–41). Did the next album start better?
SQL: `claude/domino_easy_end_pays_twice_2026-10-24.sql` (`domino-dreams-dbt.prod_40_mart.user_daily_album` + `user_daily_metrics`, 18 GB).

## Definitions
- Same as topic 6 (`topic6-after-album-2026-10-24.md`): standard-population payers; spend level = album $ a day before the last quarter (own pace); end status on close−1 (finished / 1–3 missing / 4+ missing).
- After-week = 7 days after the close day (next album days 2–8). After vs own pace = group spend per day that week ÷ group album pace per day.
- Albums 18 / 19 / 20 (close 2026-07-06 / 08-24 / 10-12) → next albums 19 / 20 / 21. Album 20 = the easier end.
- **Album 18 is used only for "all payers" rows.** It has 14 sets, so the 144-sticker rule does not work there (it marks 61% of ≤$2 payers as finished). The all-payers row does not use stickers.
- ≤$2 a day left out of the message (a $1 a day pace is easy to beat in a new album's first week; same as topic 6).

## Results — all payers in the level, after-week spend vs own album pace
| Spend level | Players (18 / 19 / 20) | % of album revenue | 18 → 19 | 19 → 20 | **20 → 21** |
|---|---|---|---|---|---|
| $2–5 | 17,466 / 16,040 / 15,092 | 18% / 18% / 19% | 87% | 97% | **100%** |
| $5–20 | 12,148 / 11,031 / 10,440 | 36% / 36% / 37% | 73% | 80% | **90%** |
| >$20 | 2,334 / 2,077 / 1,837 | 28% / 28% / 26% | 64% | 69% | **77%** |
| $2+ together: short of own pace in that week | | | $495,365 (28%) | $326,001 (20%) | **$183,097 (12%)** |
(≤$2: 115% / 129% / 136%.)

## Why: where the payers ended (share of the level's payers, album 19 → 20)
| Spend level | Finished | 1–3 missing | 4+ missing (far) |
|---|---|---|---|
| $2–5 | 6% → 11% | 20% → 60% | 74% → 29% |
| $5–20 | 14% → 23% | 33% → 57% | 53% → 21% |
| >$20 | 37% → 49% | 34% → 35% | 29% → 16% |
After-week vs own pace by end status, album 19 → 20 ($5–20): finished 126% → 134%; 1–3 missing 97% → 88%; far 54% → 40%.
(1–3 missing on close−1 includes many who finished on the close day with the Puzzle Jokers.)

## Reading
- **Fact:** after album 20 (the easier end), the next album started better than after album 19, in every spend level ($5–20: 80% → 90% of own pace; >$20: 69% → 77%). Payers at $2+ a day were $183,097 short of their own pace in that week, vs $326,001 after album 19.
- **Fact:** the gain comes from where payers ended: far payers fell from 53% to 21% of $5–20 payers. Inside each end status the week was not better (far payers 54% → 40%: the ones left far are the weakest).
- **Fact, against:** the start was already improving one album earlier, before the easier end (18 → 19: $5–20 73% → 80%, >$20 64% → 69%). The player base is also shrinking (the payers who stay may be the more loyal ones). Album 18 is a different album (14 sets, 56 days).
- **Interpretation:** fits "finishing pays twice": the easier end moved payers from far to close/finished, and those start the next album at a higher pace. Two albums, a trend already there → not proven.
- **What it means for tests:** add "first week of the next album, spend vs own pace" as a second measure to the end tests already proposed (Domino one vs two Puzzle Jokers, Part 1 slide 41; Disney test 1, slide 47; the ≤3 goal in topic 5). Then the second payment is measured, not assumed.
