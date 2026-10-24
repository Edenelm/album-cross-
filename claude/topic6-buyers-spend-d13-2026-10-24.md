# Days 1–3 after close: % who buy × spend per buyer (2026-10-24)

Eden (2026-10-24): split the return after close into % who buy × spend per buyer, **days 1–3 after close only**. This follows the stock check (`topic6-stock-by-status-2026-10-24.md`) and the free inflow / out-of-stock check (`topic6-free-inflow-oos-2026-10-24.md`), which did not explain the slow Dice return.
SQL: `claude/topic6_buyers_spend_d13_2026-10-24.sql` (Dice 104 GB, Domino 6 GB, Disney 15 GB).

## Definitions
- Population, status (on close−1), levels and own pace (album $ a day before the last quarter): as `topic6-payout-by-status-2026-10-24.md`. Player counts match (Dice 19,688 / 29,743 / 76,491 / 65,898 …).
- Spend days 1–3 = next-album album-table spend close+1..+3 (gross $).
- Return = spend days 1–3 ÷ (3 × own pace). It equals (buyers' share of the group's pace) × (buyers' spend ÷ their own pace), exactly.
- Bought = spend > 0 in days 1–3. $ per buyer = days 1–3 spend of players who bought.

## Results: paying players $2–20 a day
| | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| **Finished**: return days 1–3 (% of own pace) | 102% | 118% | 124% |
| % who bought | 55% | 57% | 59% |
| Buyers: spend vs own pace | 168% | 187% | 193% |
| Median $ per buyer (3 days) | $19 | $26 | $34 |
| Buyers' own pace for 3 days (average) | $21 | $25 | $25 |
| **1–2 short**: return days 1–3 | 86% | 90% | 109% |
| % who bought | 55% | 58% | 63% |
| Buyers: spend vs own pace | 145% | 143% | 161% |
| Median $ per buyer | $19 | $17 | $27 |
Players: finishers 9,579 / 4,025 / 7,498 (13% / 14% / 8% of album revenue); 1–2 short 11,747 / 5,749 / 10,190 (13% / 14% / 9%).

All paying players: same direction. Finishers return 98% / 107% / 105%, bought 46% / 48% / 56%, buyers 145% / 148% / 138% of own pace.

## Split of the gap (finishers, $2–20; log split of the ratio)
- Dice vs Domino (102% vs 118%): about **3/4 from smaller spend per buyer**, 1/4 from fewer buyers.
- Dice vs Disney (102% vs 124%): about **2/3 from smaller spend per buyer**, 1/3 from fewer buyers.
- 1–2 short: Dice ≈ Domino (86% vs 90%). Disney is ahead on both: more buyers (63%) and more per buyer.

## Reading
- **Fact:** in days 1–3 Dice finishers buy almost as often as in Domino and Disney (55% vs 57–59%), but each buyer spends less above their own pace (168% vs 187–193%). The median buyer spends $19 vs $26 / $34. The buyers' own pace is about the same ($21 vs $25), so it is not that Dice buyers are smaller payers.
- **Fact:** in days 1–3 Dice finishers still spend at their own pace (102%), so the gap is a smaller rebound than in the other games, not a drop below pace.
- **Fact:** for 1–2 short, Dice and Domino are about the same; the gap is with Disney.
- **Answer:** the slow Dice start for finishers is mostly **how much** each buyer spends, not **whether** they buy.
- **Hypothesis (not tested):** the purchase options at the start of the new Dice album (offers, price points, what a purchase buys) lead to smaller baskets. Or album 63 was weak (topic 7).

## Next (not run; Eden to decide)
- Days 1–3 purchase mix: number of purchases per buyer × price per purchase, and top price points, three games, finishers.
- Re-run Dice with album 65 after 2026-10-27 (open).
