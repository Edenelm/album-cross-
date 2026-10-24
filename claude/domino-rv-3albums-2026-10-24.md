# Domino finishers who did not pay: what RV gave them, albums 17 / 19 / 20 (2026-10-24)

Eden (2026-10-24) asked for the Domino 20 RV analysis to cover 3 albums, to keep the 3-album rule.
SQL: `claude/domino_rv_3albums_2026-10-24.sql` (Domino 17: 248 GB, Domino 19: 290 GB). It is the same as `domino_rv_rewards_queries.sql` Q2; only the album id and the dates change. Album 20 comes from `domino-rv-rewards-2026-10-20.md`.
Raw rows: `claude/results/domino_rv_3albums_2026-10-24.csv`.

## Definitions
- **Finishers:** standard population, 144 stickers by the end of the close day.
- **Did not pay:** no spend on any album day, including the close day.
- **RV:** `stg_ad_watch_completed_vw`. Its rewards are read from `reward_syntax_actual`.

## Results: finishers who did not pay
| | Album 17 | Album 19 | Album 20 |
|---|---|---|---|
| Players | 1,865 | 2,953 | 7,517 |
| Watched RV | 79% | 78% | 91% |
| Views per watcher (median / average) | 4,002 / 4,506 | 3,146 / 4,129 | 2,887 / 3,508 |
| Days with RV (average, watchers) | 32 | 34 | 31 |
| Ad revenue, total | $10,607 | $17,099 | $45,084 |
| Ad revenue per view | $0.0016 | $0.0018 | $0.0019 |
| Sticker packs from RV per watcher | 820 | 758 | 644 |
| New stickers from RV packs per player | 30 | 22 | 18 |
| Puzzle pieces from RV per watcher | 5,740 | 5,930 | 5,094 |
| New stickers from Puzzle Jokers per player | 1.0 | 1.0 | 2.4 |

Paying finishers for comparison: 22% / 30% / 32% watched RV, with a median of 10–13 views. They got 0.1–0.2 new stickers from RV packs.

## Reading
- **Fact:** heavy RV watching by non-paying finishers is not new to album 20. In albums 17 and 19 they watched as much or more, and RV gave them more sticker packs (22–30 new stickers each) and as many Puzzle pieces.
- **Fact:** what changed in album 20 is the Puzzle Joker. It gave 2.4 new stickers per player against 1.0, and closed the album for 60% of them. The number of non-paying finishers grew from 1,865 to 2,953 to 7,517.
- **Interpretation:** RV is the fuel (stickers and Puzzle pieces) in all three albums. Album 20's two Puzzle Jokers turned that fuel into finishing.
- **Caveat:** about 93–125 views a day per watcher may include automated viewing. This was not checked.
