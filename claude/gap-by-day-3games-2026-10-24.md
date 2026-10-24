# The gap to finishers by album day: is the Disney pattern a release-design effect? (2026-10-24)

SQL: `claude/gap_by_day_3games_2026-10-24.sql` (Disney 11 GB, Domino 5 GB, Dice 104 GB). Rows: `claude/results/gap_by_day_3games_2026-10-24.csv`.

## Definitions
- **Population:** standard-population payers.
- **Groups:** finishers (144 on close−1) vs far payers (140 or fewer on close−1, i.e. 4+ away).
- **Measure:** mean unique set stickers per album day.
- **Albums:** latest only. Dice 63 (42 days), Domino 20 (49 days), Disney 15 (42 days).
- **Group size (finishers / far payers):** Dice 20,966 / 69,251; Domino 8,548 / 57,958; Disney 13,184 / 262,515.

## Gap (finishers minus far payers, in stickers) by share of the album
| | 10% | 20% | 30% | 50% | 70% | 90% | Last day |
|---|---|---|---|---|---|---|---|
| Dice 63 | 6 | 7 | 8 | 9 | 11 | 12 | 12 |
| Domino 20 | 5 | 7 | 10 | 12 | 12 | 9 | 12 |
| Disney 15 | 7 | 10 | 12 | **16** | **17** | 11 | 13 |

## Reading
- **Fact:** in all three games, far payers start a little behind and fall further behind gradually. This is normal player difference, not Disney-only.
- **Fact:** Disney's gap opens faster and wider in the first half. It is 10 at 20% of the album (7 in Dice and Domino) and 16–17 at 50–70% (Dice 9–11, Domino 12). By the end it narrows to 13, close to the others (12).
- **Interpretation:** part of the Disney pattern is common to all games. On top of that there is an extra mid-album gap of about 4–6 stickers in Disney. That fits the wave release (Disney day 30: 76% held vs 82% Dice, 88% Domino), but it is not proven.
- **Caveats:**
  - One album per game.
  - Disney's far group is much bigger (81% of payers vs about a quarter to a half in the others), so it includes weaker players.
- **For slide v144b:** "they fall behind gradually" holds. "Release days cause it" is not shown. The Disney-specific part is the bigger gap in the middle of the album.
