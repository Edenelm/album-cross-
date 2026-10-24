# Week after close: 3-album average vs a calendar-neutral index (2026-10-24)

Eden (2026-10-24): the week after close depends on the calendar (early September weak in all games, October strong; see `topic6-game-revenue-after-close-2026-10-24.md`). She asked to see both options side by side before choosing:
- **A:** a 3-album average.
- **B:** a measure that removes the calendar.

SQL: `claude/topic6_calendar_neutral_return_2026-10-24.sql` (Dice 104 GB, Domino 24 GB, Disney 45 GB). Raw sums: `claude/results/topic6_calendar_neutral_return_2026-10-24.csv`. Compute script: `claude/topic6_calendar_neutral_compute_2026-10-24.py`.

## Definitions
- **Albums:** the agreed 3-album set: Dice 59/61/63, Domino 17/19/20, Disney 12/14/15.
  - Close dates: Dice 06-22 / 07-27 / 09-07; Domino 05-11 / 08-24 / 10-12; Disney 06-22 / 08-24 / 10-05.
  - First I took Domino 18 and Disney 13, then replaced them. Disney 13 is a 21-day mini album with at most 97 stickers, so it has no finishers. Domino 18 has up to 168 stickers.
  - Disney 12 also shows up to 161 stickers. It is in the agreed set and was counted before with the 144 rule, so it is kept here. Flagged.
- **Population, status and own pace:** as s6c (`topic6_before_after_2026-10-24.sql`). Standard-population payers; status on close−1; own pace = album $ a day before the last quarter; week after = close+1..+7.
- **A = week after ÷ own pace,** simple average of the 3 albums.
- **B = index = group's week after ÷ all non-finishers' week after.** Both sides are vs their own pace, in the same game, same album and same spend level. Then averaged over the 3 albums.
  - Example: finishers 110%, non-finishers 73% → index 1.51.
  - A weak week hits both sides, so the ratio removes most of the calendar.
- **Check:** Dice 63 and Domino 20 finishers ($2–20) give 110% and 140%, the same as s6c.

## Results: paying finishers, $2–20 a day
| | Dice | Domino | Disney |
|---|---|---|---|
| **A** average (per album) | **121%** (123 / 129 / 110) | **131%** (117 / 134 / 140) | **132%** (131 / 135 / 128) |
| **B** index average (per album) | **1.50** (1.56 / 1.42 / 1.51) | **1.71** (1.71 / 1.70 / 1.73) | **1.74** (1.72 / 1.75 / 1.75) |
| Non-finishers' week after, the B divisor (per album) | 79 / 91 / 73% | 69 / 79 / 81% | 76 / 77 / 73% |

## Players 1–2 short, $2–20 a day
| | Dice | Domino | Disney |
|---|---|---|---|
| A | 98% (98 / 105 / 90) | 102% (92 / 110 / 103) | 111% (113 / 111 / 108) |
| B | 1.21 (1.24 / 1.16 / 1.23) | 1.34 (1.34 / 1.40 / 1.27) | 1.46 (1.47 / 1.44 / 1.47) |

## By spend level, B (3-album average)
| Level | Finishers: Dice / Domino / Disney | 1–2 short: Dice / Domino / Disney |
|---|---|---|
| ≤$2 | 1.87 / 2.53 / 2.85 | 1.32 / 1.61 / 2.00 |
| $2–5 | 1.55 / 1.86 / 2.05 | 1.22 / 1.45 / 1.64 |
| $5–20 | 1.50 / 1.77 / 1.73 | 1.22 / 1.34 / 1.45 |
| >$20 | 1.56 / 2.02 / 1.70 | 1.25 / 1.46 / 1.41 |

A by level, finishers (3-album average):
- ≤$2: 229 / 296 / 333%
- $2–5: 138 / 161 / 176%
- $5–20: 114 / 124 / 122%
- >$20: 92 / 96 / 92%

## Reading
- **Fact:** B is very stable inside each game across albums: Domino 1.70–1.73, Disney 1.72–1.75, Dice 1.42–1.56. A moves with the calendar: Domino 117–140%, Dice 110–129%. So B removes most of the week-to-week noise.
- **Fact:** on B, Dice finishers come back the least in every album (1.42–1.56 vs 1.70–1.75), at every spend level, and the same holds for players 1–2 short.
- **Fact:** on A, Dice 61 (129%) looks like Domino 19 and Disney 14. On B it is Dice's lowest album (1.42), because all Dice payers came back strongly that week (non-finishers 91%).
- **Answer:** the "Dice finishers come back slowest" gap is real and not the calendar. It shows in all three albums.
  - Size on B: Dice 1.50 vs 1.71 / 1.74, about 12–14% lower.
  - Size on A: smaller than on s6c (121% vs 131–132%, instead of 110% vs 140% / 128%).
- **Caveat:** B compares finishers with each game's own non-finishers. If non-finishers behave differently by game (for example how many slowed before close), part of the gap can come from the divisor. The divisors are close (69–91% in every album), so this is a small risk.

## Not done
- Slides: not changed. Eden decides which measure to use first.
- Payout by level for the extra albums: not run (heavy). The payout change after close is game design, not the calendar.
