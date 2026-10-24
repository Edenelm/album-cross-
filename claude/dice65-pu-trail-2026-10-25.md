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
