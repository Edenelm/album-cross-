# Dice: $2K+ payers spend album after album but stay on a fixed 200K prize (2026-10-24)

Eden (2026-10-24) wanted a slide showing that these players spend a lot album after album, while the prize stays fixed.
SQL: `claude/topic7_fixed_prize_spend_2026-10-24.sql` (7 GB).

## Definitions
- **Cohort:** Dice album 63, prize code 7 (200K) on the last row before close, not excluded.
  - **Top group:** album spend from start to close−1 of $2,000 or more. 591 players.
  - **Comparison group:** album spend under $150. 14,667 players.
- The same players are followed back to albums 59 and 61.

## Results (median player)
| Group | Album | Players | Album spend (median / average) | $2K+ | Prize | Rolls of prize per $ |
|---|---|---|---|---|---|---|
| $2K+ in 63 | 59 | 571 | $2,155 / $2,761 | 53% | 200K | 78 |
| | 61 | 589 | $2,017 / $2,600 | 51% | 200K | 88 |
| | 63 | 591 | $2,838 / $3,577 | 100% | 200K | 70 |
| Under $150 in 63 | 59 | 14,367 | $71 / $157 | 0.6% | 200K | 2,150 |
| | 61 | 14,304 | $44 / $99 | 0.3% | 200K | 3,376 |
| | 63 | 14,667 | $40 / $50 | 0% | 200K | 3,642 |

## Reading
- **Fact:** the top payers spend about $2,000–2,800 (median) in every album. About half of them crossed $2,000 in each of the two earlier albums. Their prize was 200K every time.
- **Fact:** per dollar spent, the prize gives them 70–88 rolls. A sub-$150 player in the same tier gets 2,150–3,642, which is about 28–52 times more.
- **Not a cause:** this shows the prize design. Whether a bigger prize changes their spend is what the test checks.

## Clean rerun (Eden 2026-10-24): payers only, finished vs all, exact revenue share
SQL: `claude/topic7_fixed_prize_spend_v2_2026-10-24.sql` (3 GB, album 63).

### What changed from the first run
- The first light group, "under $150" with 14,667 players, also included 2,781 players with $0 spend. It is now **payers only: $1–149**.
- The ratio is the prize value (the tier's 200K) ÷ the player's album spend.

### Results (album 63)
| Group | Who | Players | % of payers | % of album revenue | Median spend | Rolls of prize per $ (median player / whole group) |
|---|---|---|---|---|---|---|
| $2K+ | All | 591 | 0.2% | 7.1% ($2,113,765) | $2,823 | 70 / 56 |
| $2K+ | Finished | 296 | 0.1% | 3.8% | $3,078 | 64 / 53 |
| $1–149 | All | 11,886 | 3.9% | 2.5% ($729,414) | $56 | 3,548 / 3,259 |
| $1–149 | Finished | 2,183 | 0.7% | 0.6% | $77 | 2,586 / 2,534 |

### Reading
- **Fact:** 591 top payers bring 7.1% of album revenue. That is about 3 times the 2.5% from 11,886 light payers. Both groups have the same 200K prize.
- **Fact:** per dollar, the prize gives top payers about 40–50 times less than light payers (70 vs 3,548 for all players; 64 vs 2,586 for finishers).

### Slides updated
- **Eden's slide h22531cc986c0856e_34_269:** $2,823 vs $56, "11,886 players (2.5% rev share)", message "about 50 times".
- **t7f:**
  - Tile changed to "about 3,500" for payers spending $1–149.
  - Message changed to "40–50 times less".
  - The album-63 median changed to $2,823. The earlier $2,838 was an approximate-median difference between the two runs.
