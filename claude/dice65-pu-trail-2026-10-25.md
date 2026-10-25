# Dice 65 vs 63: paying users per day, and the Trail as a source (2026-10-25)

Question (Eden): show that there were enough payers (PU) in Dice 65. Also, was the Trail as a source at the same level in 63 as in 65?
SQL: `claude/dice65_pu_trail_2026-10-25.sql` (Q1 83 GB, Q2 8 GB).

## Q1: PU per day (standard-population payers: 203,118 in 63, 192,616 in 65)
| | Days 11–5 before close (avg) | Final weekend Fri / Sat / Sun |
|---|---|---|
| Active rate 63 / 65 | 87% / 88% | 85 / 84 / 84% vs 86 / 85 / 85% |
| PU rate 63 | 15.0% | 14.8 / 15.7 / 15.8% |
| PU rate 65 | **16.2%** | 14.7 / 13.8 / 14.6% |
| ARPPU 63 | $18.70 | $21.81 / $22.36 / $21.62 |
| ARPPU 65 | $18.50 | $18.78 / $19.19 / $18.99 |

- **Fact:** players were there. The active rate was the same in both albums (84–86% on the final weekend). Dice 65 had *more* payers a day before the end (16.2% vs 15.0% of payers in days 11–5).
- **Fact:** on the final weekend, 65 had about 11% fewer payers a day than in its own days 11–5 (14.4% vs 16.2%). Those who paid spent about the same as before ($19.0 vs $18.5). In 63 the number of payers held, and those who paid spent 17% more ($21.9 vs $18.7).

## Q2: Trail as a sticker source, last 14 days, all players
| | 63 | 65 |
|---|---|---|
| Trail – Chest stickers, last 14 days | 2,703,459 | 2,930,994 (+8%) |
| Trail – Final Reward stickers, last 14 days | 336,233 (48,492 Wild-filled) | 377,520 (+12%; 62,208 Wild-filled) |
| Players a day getting a Trail chest sticker, final weekend Fri / Sat / Sun | 71,078 / 33,862 / 49,967 | **115,970 / 97,901 / 98,164** |
| Players a day getting a Trail final reward sticker, final weekend | 16,893 / 21,337 / 19,770 | 17,689 / 25,432 / 33,492 |
| Trail chest peak | 14 and 11–10 days before close | 10–9 days before close (232K / 215K players) |

- **Fact:** the Trail was *not* weaker in 65. It gave 8–12% more stickers in the last 14 days. On the final weekend, about twice as many players a day got Trail chest stickers (98–116K vs 34–71K).
- **Reading (hypothesis, fits Eden's earlier idea "album too easy"):** in 65 the free Trail fed players on the final weekend. They got stickers without paying, so fewer needed to buy, and buyers did not top up. That fits fewer payers and flat ARPPU on the final weekend. Not proven. A test, or the Dice team's Trail config for 65 vs 63, would settle it.

## Q3: normalised by active players (Eden 2026-10-25)
Active players a day were similar: 517K–532K in 63, 525K–552K in 65. Share of active players that day who got at least one Trail chest sticker:

| Days before close | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 (Fri) | 2 (Sat) | 1 (Sun) |
|---|---|---|---|---|---|---|---|---|---|---|
| 63 | 36% | 27% | 33% | 24% | 15% | 26% | 24% | 14% | 6% | 10% |
| 65 | 44% | 41% | 28% | 21% | 15% | 27% | 24% | **21%** | **18%** | **18%** |

Trail chest stickers per active player on the final weekend: 63 0.20 / 0.12 / 0.17, 65 0.34 / 0.29 / 0.32.
- **Fact:** normalised, the picture holds. On the final weekend about twice the share of active players got Trail chest stickers in 65 (18–21% vs 6–14%). Days 7–4 are about the same in both albums.
- The `d65t_slide` chart now shows this share instead of player counts.

## Q4: which stickers did the Trail give? (Eden 2026-10-25)
Every Trail row in `fact_user_album_stickers` turned out to be a **new** sticker for the player (first copy). The table holds new stickers only.

| Final weekend (Fri–Sun) | 63 | 65 | per 1,000 active player-days, 63 → 65 |
|---|---|---|---|
| Trail – Chest: new commons | 148,576 | 274,926 | 95 → 168 |
| Trail – Chest: new Goldens | 60,327 | 87,752 | 38 → 54 |
| Trail – Chest: new Supers | 53,385 | 157,102 | 34 → 96 |
| Trail – Chest: all new set stickers | 262,288 | 519,780 | 167 → 318 |
| Trail – Final Reward: Wild (filled a new Super / Golden / common) | 48,487 | 62,207 | 31 → 38 |
| Trail – Final Reward: a Super directly | 10,995 | 16,835 | 7 → 10 |
Active player-days on the final weekend: 1,568,891 (63), 1,633,978 (65).

- **Fact:** the Trail chest gives regular new set stickers, not Wilds. On 65's final weekend it gave about twice as many new stickers per active player as in 63, and about 3× as many new Supers.
- The Wild comes only from the Trail **final reward**, and it is close between the two albums (31 vs 38 per 1,000 active player-days).
- (Days 10–4 also show "pixie" rows, which are not one of the 144 set stickers. They are left out above.)

## Q5: PU / PAU — share of active payers who paid that day (Eden 2026-10-25)
Same population as Q1 (standard-population payers). PAU = those payers active that day; PU = those who spent that day. Pooled over the days.

| | Days 11–5 before close | Final weekend (days 3–1) | Change |
|---|---|---|---|
| Dice 63 (`dice-dreams-dbt`) | 17.2% | 18.3% | **+7%** |
| Dice 65 | 18.4% | 16.9% | **−8%** |

By day (11..1 before close): 63 15.5 / 18.5 / 17.0 / 18.4 / 17.9 / 15.5 / 17.3 / 15.9 / 17.5 / 18.7 / 18.8%; 65 17.3 / 17.4 / 19.2 / 20.2 / 19.0 / 17.0 / 18.7 / 16.9 / 17.2 / 16.4 / 17.1%.
- Fact: normalised by active payers, the picture holds: in 65 fewer active payers paid on the final weekend (−8% vs its days 11–5), in 63 more did (+7%). The raw "payers a day" change on the d65t slide (−11% / +3%) included a small drop in active payers.
SQL: Q5 in `dice65_pu_trail_2026-10-25.sql`.
