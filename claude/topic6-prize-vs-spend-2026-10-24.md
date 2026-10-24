# Album prize relative to own play, finishers by spend level, three games (2026-10-24)

Eden (2026-10-24) asked two things:
- Dice has the biggest prize. Is that the reason for the slow return?
- She wants to discuss a bigger prize for strong players. Some players consistently spend a lot relative to what the prize gives them.

She also asked to check this in Domino and Disney.

SQL: `claude/topic6_prize_vs_spend_2026-10-24.sql`. Sizes: Domino 19/20 166 GB, Disney 15 223 GB, Dice 61/63 118 GB. Disney 14 was not run because of cost.

## Definitions
- **Population:** paying finishers in the standard population. Finisher = 144 stickers on close−1 (the slide cut). Album revenue share is out of all standard-population payers in the same album.
- **Spend level:** own pace = album $ a day before the last quarter. The levels are ≤$2, $2–5, $5–20 and >$20.
- **Prize in days of own play** = album-complete prize ÷ the player's own average daily use over the album.
  - **Dice:** `album_reward_value` (rolls) ÷ rolls bet a day (`30_intermediate.user_daily_rolls_in_out`).
  - **Domino:** coins from source `album completed` ÷ coins spent a day. Both are in allowance units, from Mixpanel coins in/out.
  - **Disney:** same as Domino.
  - **Example:** a Disney player who plays 400 coins a day and gets a 150-coin prize has a prize worth 0.4 day of their own play.
  - My choice of measure: it puts the three games on one scale. It is the same idea as the stock check, which also uses days of own play.
- **Week after:** close+1..+7 spend vs own pace, for the whole group.

## Results: median prize in days of own play (share of players under 1 day)
| Spend level | Dice 61 / 63 | Domino 19 / 20 | Disney 15 |
|---|---|---|---|
| ≤$2 | 2.9 / 2.8 (7% / 8%) | 1.6 / 1.7 (22% / 17%) | 1.7 (10%) |
| $2–5 | 2.2 / 2.2 (15% / 16%) | 1.2 / 1.4 | 1.4 (25%) |
| $5–20 | 1.7 / 1.6 (27% / 28%) | 0.9 / 1.1 | 0.9 (55%) |
| **>$20** | **0.8 / 0.9 (59% / 58%)** | **0.6 / 0.7 (76% / 70%)** | **0.4 (94%)** |
| All finishers | 2.2 / 2.1 | 1.1 / 1.3 | 1.1 (42%) |

### >$20 finishers: size and week after
| | Dice 61 / 63 | Domino 19 / 20 | Disney 15 |
|---|---|---|---|
| Share of payers | 0.6% / 0.7% | 0.7% / 0.9% (772 / 908 players) | 0.6% (1,889 players) |
| Share of album revenue | 11% / 12% | 13% / 15% | 10% |
| Median $ a day | $33 / $33 | | $35 |
| Week after vs own pace | 102% / 85% | 101% (album 20, from t6k) | 86% |

### Prize size in game units (median)
- **Dice** (rolls): 100,000 for ≤$2, 125,000 for $5–20, and 200,000 for >$20. Dice already scales the prize by player segment, so >$20 players get twice the ≤$2 prize. Their spend a day is about 40 times higher ($33 vs $0.8).
- **Disney** (allowance units): 147 for ≤$2 and 179 for >$20, so the prize is almost flat.

## Reading
- **Fact:** relative to own play, Dice gives the biggest prize in every spend level: about 2 days for all finishers, against about 1.1–1.3 days in Domino and Disney.
- **Fact:** in all three games, the prize shrinks with spend level. The >$20 finishers get under one day of their own play: 0.8–0.9 in Dice, 0.6–0.7 in Domino and 0.4 in Disney. They are 0.6–0.7% of payers and 10–15% of album revenue.
- **Fact:** the >$20 finishers are also the group that comes back below its own pace after close (85–102%).
- **"Is the big Dice prize the reason for the slow return?"** Not shown. The stock check found under 0.1 day of balance left at the end of the close day in all games. So the bigger Dice prize is used up before the next album starts and is not carried over. A link through habit or expectation is possible, but it is a hypothesis and these data cannot test it.
- **"A bigger prize for strong players":** the gap is real and consistent across three games. Strong players get a prize that is small relative to how they play. Whether a bigger prize changes their spend or return is not known. Only a test can show it, and their revenue weight (10–15%) makes the test worth its cost.

## Recommendation
- Bigger album prize for >$20 finishers: **TEST**, do not adopt yet.
  - **Example design:** prize scaled to about 1–2 days of own play, against today's prize as control.
  - **Main measure:** spend vs own pace in the 14 days after close.
  - **Guardrails:** next album finish rate and total payout cost.
  - The size of the bigger prize is a product decision. Options: 1 day, 1.5 days or 2 days of own play.
- Dice payout test (t6j): unchanged, still TEST.

## Players 1–2 short: the prize they missed, in days of own play (Eden 2026-10-24)
SQL: `claude/topic6_prize_short12_2026-10-24.sql`. Latest album only: Dice 63 (117 GB), Domino 20 (87 GB), Disney 15 (223 GB).
- **Dice:** the player's own `album_reward_value`. It is set for non-finishers too.
- **Domino and Disney:** there is no prize column per player. I used the median 'album completed' prize of finishers in the same `album_segment`. This is my choice and it is an estimate.
  - Domino: 161 units for most segments, 361 for the >$20 segment.
  - Disney: 148 units, flat.

Median days of own play:

| Level | Dice 63 finishers / 1–2 short | Domino 20 | Disney 15 |
|---|---|---|---|
| ≤$2 | 2.9 / 3.2 | 1.7 / 2.3 | 1.7 / 1.8 |
| $2–5 | 2.3 / 2.7 | 1.4 / 1.9 | 1.3 / 1.4 |
| $5–20 | 1.6 / 2.0 | 1.1 / 1.6 | 0.9 / 1.0 |
| >$20 | **0.9 / 1.1** | **0.7 / 1.0** | **0.4 / 0.4** |

1–2 short >$20: Dice 1,185 players, 8% of album revenue; Domino 356 players, 5%; Disney 1,664 players, 7%. Of them, 45% / 53% / 99% would get under 1 day.

### Reading
- **Fact:** the prize at stake for 1–2 short is the same size as for finishers or a little bigger. They play a bit less, so the same prize is worth more of their play.
- **Fact:** over $20 a day the prize is about one day of play or less in every game, for both groups.
- **Note:** 1–2 short >$20 come back the weakest (69–76% of their usual pace). Finishers >$20 come back at 92–96%. These are different players, so this is not proof that missing the prize causes the drop.
