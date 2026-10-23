# Topic 6: after the album — how payers start the next album, by spend level and end status (2026-10-24)

Eden: continue to topic 6 (after the album), in the topic-5 style (by spend level, fast, toward a recommendation).
SQL: `claude/topic6_after_album_2026-10-24.sql` (Disney 25 GB `solitaire-dreams-411507.bi_prod.user_daily_album`, Domino 10 GB `domino-dreams-dbt.prod_40_mart.user_daily_album`, Dice 104 GB `dice-dreams-dbt.50_reporting.user_daily_album`).

## Definitions
- Population and spend levels: exactly as `topic5-tiers-2026-10-23.md` (standard-population payers; level = album spend per day before the last quarter = the player's own pace).
- End status on close−1: finished / 1–3 missing / 4+ missing (far).
- After = the 7 days after the close day (close+1 … close+7 = next album days 2–8), from the next album's rows (Dice 63/65, Domino 20/21, Disney 15/16; previous: Dice 61→63, Domino 19→20, Disney 14→15). Close day itself left out. Payers with no row in the next album count as $0.
- After vs own pace = group's after-week spend per day ÷ the same group's album pace per day (group totals). 100% = back at their album pace.
- Bought = % with any purchase in the 7 days.

## Results — latest album (after-week spend per day as % of own album pace; bought in 7 days in brackets)
| Spend level | Game | Finished | 1–3 missing | 4+ missing (far) |
|---|---|---|---|---|
| $2–5 | Dice 63 | 123% (69%) | 88% (68%) | 62% (48%) |
| $2–5 | Domino 20 | 167% (75%) | 105% (74%) | 61% (47%) |
| $2–5 | Disney 15 | 172% (75%) | 118% (73%) | 69% (56%) |
| $5–20 | Dice 63 | 105% (80%) | 77% (75%) | 46% (47%) |
| $5–20 | Domino 20 | 134% (86%) | 88% (82%) | 40% (42%) |
| $5–20 | Disney 15 | 119% (86%) | 87% (81%) | 51% (59%) |
| >$20 | Dice 63 | 85% (87%) | 59% (78%) | 28% (41%) |
| >$20 | Domino 20 | 101% (94%) | 64% (83%) | 22% (32%) |
| >$20 | Disney 15 | 86% (94%) | 63% (84%) | 31% (53%) |
≤$2 a day: same order (finished > 1–3 > far) but all above 100% (a $1 a day pace is easy to beat in a new album's first week); not used for the message.
Previous albums show the same order in every level and game (e.g. $5–20 far: Dice 61 76%, Domino 19 54%, Disney 14 51%).

## Money in the gap ($2–20 a day, far payers, 7 days after close)
| Album | Far $2–20 payers' album pace × 7 | Spent in the 7 days after | Short of own pace |
|---|---|---|---|
| Dice 63 | $489,573 | $255,257 | $234,316 |
| Domino 20 | $229,565 | $111,689 | $117,876 |
| Disney 15 | $1,763,790 | $1,033,795 | $729,995 |
| Disney 14 | $1,997,450 | $1,178,625 | $818,825 |
This is the gap to the group's own album pace in one week, not a forecast of what can be won.

## Reading
- **Fact:** in every game, level and album the order is the same: payers who finish start the next album at or above their pace; 1–3 missing a bit below; far payers at about half (Domino 20 $5–20: 134% / 88% / 40%).
- **Fact:** far payers are also less likely to buy at all in that week ($5–20: 42–59% vs 75–82% for 1–3 missing).
- **Fact:** Disney's far middle payers spent $729,995 less than their own album pace in the 7 days after album 15 ($818,825 after album 14).
- **Fact (side):** Dice finishers start slower than Domino / Disney finishers in the middle levels ($2–5: 123% vs 167% / 172%; $5–20: 105% vs 134% / 119%) — the grand-prize effect from `post-album-events-2026-10-19.md`.
- **Interpretation:** a weak end costs twice — in the last days of the album and in the first week of the next one. So the ≤3 goal at close−4 (topic 5) also protects the next album's start.
- **Hypothesis, not proven:** far payers may have been slowing down already before the end (the cut is by end status). Check: their spend in the last quarter vs their pace; proof of cause needs the topic-5 Disney test (measure the next album's first week as a second outcome).
