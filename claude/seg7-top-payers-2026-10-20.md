# Dice segment 7 — big spenders after finishing (2026-10-20, Eden)

Question (Eden): inside segment 7 (album reward code 7, 200K prize), show the group that returns to its habit fast and spends a lot of money and rolls — it deserves a bigger prize. How much revenue share is it worth?
Population: Dice payer finishers, standard population, finisher = 144 unique stickers by end of close day (or game finish ts), segment 7 only. Split by album spend THIS album (start..close-1). Habit = close-18..close-5.
SQL: claude/seg7_top_payers_dice.sql (11.4 GB; run 1 by spend segment 11.9 GB, same CTEs).

| Album 63 | Players | % payer finishers | % players | % album revenue | Median rolls/day (habit) | 200K prize lasts (days) | Rolls day 1 vs before | Bought by day 1 / 3 / 7 | Week-1 buying vs habit (pts) | Spend d1-7 vs habit |
|---|---|---|---|---|---|---|---|---|---|---|
| Under $200 | 3,558 | 14.3% | 0.79% | 1.6% | 37K | 5.3 | 7.4x | 18% / 39% / 59% | -7.1 | 0.81 |
| $200-700 | 2,574 | 10.4% | 0.57% | 4.7% | 68K | 2.9 | 4.6x | 30% / 58% / 81% | -6.5 | 0.77 |
| **$700+** | **1,427** | **5.7%** | **0.32%** | **11.7% ($2.44M)** | **143K** | **1.4** | **2.0x** | **44% / 76% / 91%** | **-3.6** | **0.81** |
| of which $2K+ | 319 | 1.3% | 0.07% | 5.7% | 287K | 0.7 | 1.9x | 56% / 86% / 96% | -1.0 | 0.84 |
| All segment 7 | 7,559 | 30.4% | 1.68% | 18.1% | 59K | 3.4 | 5.0x | 27% / 52% / 72% | -6.2 | 0.80 |

Album 61: $700+ = 942 players, 4.9% of payer finishers, 0.21% of players, 10.0% of album revenue ($1.70M); 139K rolls/day; prize 1.4 days; bought by day 3 75%; week-1 buying -2.8 pts; spend 0.93. Under $200: prize 7.7 days, by day 3 39%, -1.3 pts (album 61 has no clear gap for them). $200-700: -5.7.
By spend segment (run 1), segment 7 Extreme: 63 = 1,563, 6.3%, 10.8% of revenue, 121K rolls/day, prize 1.6 days, -1.9 pts; 61 = 1,088, 5.7%, 9.5%, +0.6 pts.

Facts: in segment 7 the $700+ finishers are 0.3% of players and 10-12% of album revenue; they play ~4x the rolls of under-$200 finishers, the 200K prize lasts them 1.4 days (vs 5.3), and 3 in 4 buy again within 3 days. Their week-1 buying gap vs own habit is the smallest of the three tiers in both albums (-3.6 / -2.8).
Caveat: in money, album 63 spend d1-7 is below habit for every tier (0.77-0.84). Descriptive, no control group.
Sizing: a 350K prize = ~2.4 days of their play (143K/day); 1.2 days for $2K+.
Deck: slide seg7-top (v62), prize-rec "Who" line and tests row 5 now = segment 7, $700+ payers who finish (1.4K, 6% of finishers, 12% of revenue).
