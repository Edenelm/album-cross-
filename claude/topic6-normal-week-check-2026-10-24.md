# Normal-week check: is the >$20 drop after close a return to normal? (2026-10-24)

Eden (2026-10-24) approved running this check before building the problem / pain / recommendation slides.
The question: players over $20 a day spend less in the week after close than their usual pace. Is that the album end, or just a return to normal? (A return to normal means players picked for spending a lot in one period tend to spend less in any later period.)

SQL: `claude/topic6_normal_week_check_2026-10-24.sql` (Disney 45 GB, Domino 24 GB, Dice 104 GB). Raw sums: `claude/results/topic6_normal_week_check_2026-10-24.csv`. Compute script: `claude/topic6_normal_week_compute_2026-10-24.py`.

## Definitions
- **Population:** the same players and albums as `topic6_calendar_neutral_return_2026-10-24.sql`. That is the standard population, status on close−1, 3 albums per game (Dice 59/61/63, Domino 17/19/20, Disney 12/14/15).
- **Base (my choice):** usual pace = album $ a day over album days 0–20, and the spend level comes from the same window.
  - Both compared weeks come after this window and are measured the same way, so the comparison is fair.
  - Numbers differ a little from the slides, which use the first 75% of the album as the base.
- **Normal week:** album days 21–27, a mid-album week with no close.
- **Week after close:** close+1..+7.
- Both weeks are shown as % of the usual pace (group sums), then averaged over the 3 albums.

## Results (% of usual pace, 3-album average; per album in brackets)
| Group | Normal week | Week after close |
|---|---|---|
| Finishers >$20: Dice | 99% (104 / 98 / 96) | 88% (84 / 98 / 82) |
| Finishers >$20: Domino | 95% (102 / 95 / 87) | 91% (88 / 94 / 92) |
| Finishers >$20: Disney | 93% (88 / 91 / 99) | 87% (83 / 95 / 84) |
| 1–2 short >$20: Dice | 89% (93 / 89 / 84) | **68%** (66 / 78 / 62) |
| 1–2 short >$20: Domino | 83% (88 / 92 / 69) | **62%** (60 / 64 / 62) |
| 1–2 short >$20: Disney | 86% (79 / 86 / 92) | **71%** (66 / 72 / 73) |

Week after close as % of the normal week, per album:
- Finishers >$20: Dice 81 / 101 / 85, Domino 86 / 98 / 106, Disney 94 / 105 / 84.
- 1–2 short >$20: Dice 71 / 88 / 73, Domino 68 / 70 / 90, Disney 84 / 84 / 80.

Lower levels: finishers ≤$20 spend more in the week after than in the normal week, in every game. Players 1–2 short at $5–20 are about the same or a little lower.

## Reading
- **Fact:** players over $20 already spend below their usual pace in the normal week. For finishers it is 93–99%, for 1–2 short 83–89%. So part of the drop after close is a return to normal.
- **Fact, finishers >$20:** the extra drop after close is not stable. It is 0 or positive in 4 of 9 albums. So it is mostly a return to normal plus noise, and there is no consistent album-end problem.
- **Fact, 1–2 short >$20:** the week after close is below their normal week in all 9 albums, by 10–32%. This is the album-end problem.
- **Size, 1–2 short >$20, extra drop vs the normal week, per album:**

| Game | Dollars per album | Share of album revenue | Players |
|---|---|---|---|
| Dice | $70,557 / $35,320 / $76,845 | 7–8% | 894–1,190 |
| Domino | $31,644 / $33,947 / $7,385 | 4–6% | 411–477 |
| Disney | $93,247 / $73,382 / $80,230 | 7–9% | 1,597–2,693 |

- **Caution:**
  - The normal week sits mid-album, and the week after close is the start of a new album, so the two weeks are not identical.
  - The money is the size of the gap in one week. It is not money we can surely win back.
  - Why players 1–2 short drop is not known. These are different players from the finishers, so "missing the album causes the drop" is a hypothesis.

## What changes
- The problem is narrower than on the slides. It is players over $20 a day who end 1–2 stickers short, not finishers.
- The test "bigger prize for >$20 finishers" (t7c) loses its basis. Finishers do not drop more than in a normal week. Status: **do not adopt; not a priority to test**.
- The lead for a test is helping >$20 payers finish when they are 1–2 short near the end (the end goal per spend level, t5c). Status: **TEST**. The main measure is spend in the week after close, with album revenue as a guardrail.
