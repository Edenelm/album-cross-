# Cross-game album report — Dice vs Domino vs Disney (run 2026-10-07)

## Standing rules (Eden)
- Every section shows all engaged players AND payers (PU).
- Album length label = close − open (close day is next album's day 1): Dice 61 = 35d, 63 = 42d; Domino 17 = 39d, 19 = 49d; Disney 14/15 = 42d. Labels only — numbers computed with the inclusive day count (engaged ratio denominator 36/43/40/50/43).

## Setup (same logic for all three)
| | Dice | Domino | Disney |
|---|---|---|---|
| Project / table | dice-dreams-dbt.50_reporting.user_daily_album | domino-dreams-dbt.prod_40_mart.user_daily_album | solitaire-dreams-411507.bi_prod.user_daily_album |
| Albums | 61 (Jun 22–Jul 27, 35d), 63 (Jul 27–Sep 7, 42d) | 17 (Apr 2–May 11, 39d), 19 (Jul 6–Aug 24, 49d) | 14 (Jul 13–Aug 24, 42d), 15 (Aug 24–Oct 5, 42d) |
| Structure | 12 sets / 144 stickers / 12 Supers (1 per set) | 12 sets / 144 stickers / 8–9 Royals | 12 sets / 144 stickers / 7 Royals |
| Exclusion | is_excluded = FALSE | special_user_flag = FALSE | special_user_flag = FALSE |
| Engaged | distinct is_active days ÷ album_number_of_days ≥ 0.5 | MAX(active_day_in_album) ÷ days ≥ 0.5 | same as Domino |
| Revenue | spent_in_album_today | album_spent_today (USD price points, despite "coins" description) | album_spent_today (USD) |
| Payer | is_album_pu | SUM(album_spent_today) > 0 | SUM(album_spent_today) > 0 |
| Finisher | is_album_finisher | album_finished_flag | album_finished_flag |
| Rare tier | Super (unique_super_stickers_lt) | Royal (unique_royal_stickers_tl) | Royal (unique_royal_stickers_tl) |
- Domino album 18 replaced by 17 (Eden): album 18 data = 14 sets / 168 stickers (all finishers > 144).
- Last 7 days = close−7 … close−1. "Missing 1–3 entering last 7" = not finished and 1–3 short at end of close−8.

## Scorecard — all engaged players
| Metric | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| Players | 536,601 | 516,218 | 505,781 | 385,444 | 1,288,472 | 1,126,616 |
| Completion | 4.85% | 5.81% | 2.65% | 3.05% | 2.0% | 1.9% |
| Avg / median sets | 8.53 / 9 | 8.94 / 10 | 6.92 / 7 | 7.22 / 7 | 6.69 / 7 | 6.40 / 7 |
| ≥1 / ≥3 / ≥6 / ≥9 sets | 99.2 / 98.3 / 89.3 / 59.8% | 99.5 / 98.1 / 91.0 / 73.6% | 98.6 / 93.5 / 69.1 / 34.6% | 97.7 / 93.0 / 74.9 / 36.9% | 99.6 / 94.6 / 69.6 / 26.2% | 99.3 / 93.2 / 66.3 / 20.4% |
| 11 sets, not finished | 9.1% | 5.3% | 4.9% | 5.3% | 2.7% | 1.3% |
| Payer rate | 40.1% | 42.2% | 30.3% | 34.2% | 31.7% | 30.6% |
| Album-window spend | $22.17M | $26.80M | $14.70M | $14.85M | $44.82M | $39.39M |
| Spend per player | $41.31 | $51.93 | $29.07 | $38.52 | $34.79 | $34.96 |
| Finishers' share of spend | 31.3% | 34.4% | 33.6% | 27.1% | 23.3% | 25.5% |
| Active days, avg | 30.7 | 37.1 | 33.7 | 42.4 | 37.4 | 37.7 |
| Median day first set | 9 | 8 | 7 | 8 | 5 | 3 |
| Median day first Royal/Super | 5 | 3 | 9 | 11 | 7 | 10 |
| Got ≥1 Royal/Super | 99.6% | 99.8% | 96.1% | 96.2% | 95.1% | 93.6% |
| Median Royals/Supers at end | 9 of 12 | 10 of 12 | 4 of 8 | 4 of 9 | 4 of 7 | 3 of 7 |
| Median finish day | 34 | 41 | 39 | 49 | 42 | 42 |

## Scorecard — payers (PU)
| Metric | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| Payers | 215,299 | 217,956 | 153,259 | 131,864 | 408,921 | 345,264 |
| Completion | 11.6% | 13.6% | 7.3% | 6.2% | 5.8% | 5.9% |
| Avg / median sets | 9.28 / 10 | 9.58 / 10 | 8.57 / 9 | 8.60 / 9 | 8.0 / 8 | 7.8 / 8 |
| ≥1 / ≥3 / ≥6 / ≥9 sets | 99.9 / 99.7 / 95.4 / 73.3% | 99.97 / 99.6 / 96.0 / 83.0% | 99.9 / 98.9 / 88.3 / 60.7% | 99.8 / 98.7 / 90.5 / 58.5% | 99.99 / 98.8 / 86.8 / 44.9% | 99.96 / 98.5 / 84.2 / 40.7% |
| 11 sets, not finished | 10.7% | 7.7% | 10.6% | 9.9% | 5.9% | 3.5% |
| Spend per payer (avg / median) | $102.97 / $28.37 | $122.98 / $33.05 | $95.93 / $24.65 | $112.59 / $26.97 | $109.61 / $29.91 | $114.08 / $29.21 |
| Finishers' share of spend | 31.3% | 34.4% | 33.6% | 27.1% | 23.3% | 25.5% |
| Active days, avg | 31.1 | 37.5 | 34.5 | 43.1 | 38.1 | 38.4 |
| Median day first set | 8 | 7 | 6 | 7 | 4 | 2 |
| Median day first Royal/Super | 4 | 3 | 8 | 8 | 7 | 9 |
| Got ≥1 Royal/Super | 99.9% | 99.98% | 99.2% | 98.8% | 98.1% | 97.1% |
| Median Royals/Supers at end | 9 | 10 | 6 | 6 | 5 | 4 |
| Median finish day | 34 | 41 | 38 | 49 | 42 | 42 |

## Last 7 days — all engaged
| Metric | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| Share of album spend | 20.1% | 16.8% | 17.5% | 13.7% | 14.9% | 15.0% |
| Finishers who finished in those 7 days | 83.0% | 83.4% | 79.1% | 72.1% | 71.6% | 78.4% |
| Avg daily actives / share of players | 452,659 / 84.4% | 434,521 / 84.2% | 410,552 / 81.2% | 310,217 / 80.5% | 1,083,500 / 84.1% | 951,944 / 84.5% |
| Missing 1–3 entering | 4,910 | 3,517 | 3,361 | 1,782 | 18,772 | 26,591 |
| …got them (finished) | 47.3% | 41.4% | 51.1% | 55.1% | 25.5% | 23.4% |
| …paid in last 7 days | 81.9% | 77.4% | 67.0% | 82.3% | 75.0% | 70.9% |

## Last 7 days — payers (PU)
| Metric | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| Share of album spend | 20.1% | 16.8% | 17.5% | 13.7% | 14.9% | 15.0% |
| Finishers who finished in those 7 days | 82.4% | 83.5% | 82.1% | 75.1% | 72.5% | 78.1% |
| Avg daily active payers / share of payers | 186,008 / 86.4% | 186,309 / 85.5% | 128,953 / 84.1% | 109,138 / 82.8% | 354,378 / 86.7% | 301,208 / 87.2% |
| Missing 1–3 entering | 4,772 | 3,371 | 2,641 | 1,618 | 17,684 | 24,746 |
| …got them (finished) | 47.2% | 42.6% | 53.2% | 54.3% | 26.6% | 24.8% |
| …paid in last 7 days | 84.2% | 80.8% | 85.3% | 90.6% | 79.6% | 76.2% |

## End state (all engaged: share of players / share of spend)
| End state | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| Finished | 4.9 / 31.3% | 5.8 / 34.4% | 2.7 / 33.6% | 3.1 / 27.1% | 2.0 / 23.3% | 1.9 / 25.5% |
| 1 left | 1.3 / 5.1% | 1.3 / 5.3% | 1.0 / 5.3% | 1.2 / 5.3% | 1.1 / 6.9% | 0.7 / 6.3% |
| 2–3 left | 23.5 / 34.5% | 46.4 / 42.9% | 6.1 / 20.4% | 5.7 / 20.5% | 7.8 / 28.9% | 5.0 / 27.8% |
| 11 sets, >3 short | 0.0 / 0.0% | 0.0 / 0.0% | 0.6 / 1.6% | 0.2 / 0.4% | 0.1 / 0.4% | 0.05 / 0.3% |
| Farther back | 70.3 / 29.1% | 46.5 / 17.4% | 89.7 / 39.2% | 89.9 / 46.7% | 88.9 / 40.6% | 92.4 / 40.1% |

End state — payers (share of payers / spend per payer)
| End state | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| Finished | 11.6% / $278.81 | 13.6% / $311.37 | 7.3% / $442.67 | 6.2% / $489.70 | 5.8% / $440.75 | 5.9% / $494.12 |
| 1 left | 2.6% / $198.78 | 2.8% / $231.16 | 2.1% / $241.67 | 2.0% / $290.16 | 2.6% / $287.21 | 2.0% / $361.44 |
| 2–3 left | 30.1% / $118.13 | 49.0% / $107.80 | 12.3% / $158.97 | 10.4% / $221.51 | 15.7% / $200.97 | 12.7% / $250.70 |
| 11 sets, >3 short | 0.03% / $77.10 | 0.0% / $81.44 | 1.3% / $115.62 | 0.3% / $152.81 | 0.2% / $242.79 | 0.1% / $248.14 |
| Farther back | 55.7% / $53.78 | 34.6% / $61.87 | 77.1% / $48.84 | 81.0% / $64.90 | 75.7% / $58.86 | 79.3% / $57.62 |

## Where players stop — sets (all engaged: share / spend share)
| Progress | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| 0–25% (<3) | 1.8 / 0.1% | 1.9 / 0.0% | 6.5 / 0.1% | 7.0 / 0.2% | 5.4 / 0.2% | 6.8 / 0.2% |
| 25–50% (3–5) | 9.0 / 1.1% | 7.1 / 1.3% | 24.4 / 1.7% | 18.1 / 1.7% | 25.0 / 2.1% | 26.9 / 3.2% |
| 50–75% (6–8) | 29.4 / 8.7% | 17.4 / 5.6% | 34.5 / 8.6% | 38.0 / 13.6% | 43.5 / 20.8% | 45.9 / 17.4% |
| 75–99% (9–11) | 55.1 / 58.9% | 67.9 / 58.7% | 32.0 / 56.0% | 33.9 / 57.5% | 24.2 / 53.7% | 18.5 / 53.6% |
| Finished | 4.9 / 31.3% | 5.8 / 34.4% | 2.7 / 33.6% | 3.1 / 27.1% | 2.0 / 23.3% | 1.9 / 25.5% |

Sets — payers (share of payers / spend per payer)
| Progress | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| 0–25% (<3) | 0.3% / $16.13 | 0.4% / $11.83 | 1.1% / $9.12 | 1.4% / $16.54 | 1.2% / $13.67 | 1.5% / $17.58 |
| 25–50% (3–5) | 4.2% / $26.67 | 3.7% / $43.23 | 10.7% / $15.07 | 8.2% / $22.91 | 12.0% / $19.50 | 14.3% / $25.48 |
| 50–75% (6–8) | 22.0% / $40.86 | 12.9% / $53.86 | 27.6% / $30.04 | 32.0% / $47.71 | 41.9% / $54.28 | 43.5% / $45.63 |
| 75–99% (9–11) | 61.9% / $97.83 | 69.5% / $103.74 | 53.4% / $100.57 | 52.2% / $123.83 | 39.1% / $150.48 | 34.8% / $175.96 |
| Finished | 11.6% / $278.81 | 13.6% / $311.37 | 7.3% / $442.67 | 6.2% / $489.70 | 5.8% / $440.75 | 5.9% / $494.12 |

## Where players stop — sticker bins (all engaged: share / spend share)
| Stickers | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| 1–36 | 0.2 / 0.0% | 0.1 / 0.0% | 0.5 / 0.0% | 0.8 / 0.0% | 0.1 / 0.0% | 0.2 / 0.0% |
| 37–72 | 1.9 / 0.0% | 1.3 / 0.0% | 3.0 / 0.0% | 1.8 / 0.0% | 0.6 / 0.0% | 1.6 / 0.0% |
| 73–108 | 6.2 / 0.8% | 5.0 / 0.5% | 13.4 / 0.7% | 8.6 / 0.6% | 4.4 / 0.2% | 10.6 / 0.9% |
| 109–132 | 12.9 / 3.8% | 12.3 / 3.5% | 43.7 / 7.6% | 37.3 / 8.9% | 28.8 / 4.1% | 34.1 / 6.6% |
| 133–141 | 67.0 / 47.4% | 66.3 / 43.6% | 33.5 / 43.9% | 44.9 / 48.2% | 60.8 / 55.5% | 49.8 / 53.0% |
| 142 | 6.4 / 14.9% | 8.7 / 15.9% | 2.4 / 9.1% | 2.5 / 10.2% | 2.3 / 10.9% | 1.3 / 8.9% |
| 143 | 1.8 / 8.1% | 1.9 / 8.5% | 1.1 / 5.8% | 1.3 / 6.0% | 1.2 / 7.9% | 0.8 / 7.5% |
| 144 | 3.7 / 25.0% | 4.4 / 28.1% | 2.6 / 32.9% | 2.9 / 26.1% | 1.8 / 21.3% | 1.7 / 23.0% |

Sticker bins — payers (share of payers / spend per payer; spend share = same as all engaged)
| Stickers | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| 1–36 | 0.0% / $6.12 | 0.0% / $3.40 | 0.0% / $6.66 | 0.0% / $4.05 | 0.0% / $32.96 | 0.0% / $25.69 |
| 37–72 | 0.3% / $10.52 | 0.2% / $11.17 | 0.3% / $8.32 | 0.2% / $16.70 | 0.1% / $24.43 | 0.2% / $20.32 |
| 73–108 | 3.2% / $25.42 | 2.4% / $25.30 | 4.5% / $15.66 | 2.9% / $22.14 | 1.0% / $22.86 | 3.8% / $26.38 |
| 109–132 | 8.8% / $44.60 | 8.8% / $48.39 | 29.3% / $24.82 | 23.8% / $42.22 | 15.2% / $29.66 | 22.2% / $34.07 |
| 133–141 | 65.5% / $74.40 | 62.8% / $85.43 | 51.8% / $81.30 | 60.5% / $89.66 | 70.6% / $86.27 | 62.9% / $96.17 |
| 142 | 9.8% / $156.53 | 11.3% / $172.83 | 4.9% / $179.23 | 4.5% / $255.79 | 5.0% / $237.37 | 3.4% / $294.65 |
| 143 | 3.7% / $223.56 | 4.2% / $250.18 | 2.3% / $249.31 | 2.3% / $300.82 | 2.9% / $301.31 | 2.3% / $376.14 |
| 144 | 8.7% / $296.36 | 10.4% / $332.14 | 7.1% / $446.18 | 5.9% / $496.63 | 5.2% / $445.86 | 5.3% / $498.04 |

## Data notes
- Dice: 6,332 / 7,067 finishers end < 144 non-pixie stickers (finish via album_completed event / wilds) → 144-bin share < completion.
- Domino: finishers' payer rate only 70–83% (finish without album spend). Domino user_daily_album.album_spent_today description says "coins" but values are USD price points → flag to BI.
- Disney: ~10% of finishers < 144 stickers.
- Dice album 63: 46% of engaged players end 2–3 stickers short (vs 5–8% in Domino/Disney) — design-driven (Super/pixie gating?), worth checking.

## Key findings
1. Disney's near-miss funnel is the biggest gap: 18–25K payers enter the last week 1–3 stickers short (5–7× Dice/Domino) and only ~25% finish vs 43–54% elsewhere, though ~78% of them pay that week.
2. Rare-tier pacing: Dice gives the first Super on day 3–5 and players end with 9–10 of 12; Domino/Disney first Royal day 7–11 and players end with ~half of the Royals.
3. Mid-album gap: ≥9 sets — Dice payers 73–83%, Domino 59–61%, Disney 41–45%.
4. Last-week monetization: Dice 17–20% of album spend in last 7 days vs 14–17% Domino and 15% Disney.
5. Spend per payer is similar ($96–123 avg, $25–33 median) → the difference is in how many payers reach the high-value 142–144 bins, not what each payer spends.

