# Dice Dreams — Pet feature segments (2026-11-02)
SQL: `claude/dice_pet_segments_2026-11-02.sql` (Q1–Q4). Project `dice-dreams-dbt`. Companion to `claude/disney-pet-mf-segments-2026-11-02.md`.
Seasons: Skunk 09-14..10-11 (main), GoldenDog 08-24..09-13 (in brackets). HalloweenCat ended 11-01, left out (data still landing).
Included: everyone with a pet event in the season (`50_reporting.user_daily_pet`), excluded users out. Finish = adoption (`finish_level_9_timestamp`).
Revenue = gross purchases in the whole game on season days (`user_daily_metrics_agg.revenues_sum`). Game totals: Skunk $19.24M / 270,854 payers; GoldenDog $14.94M / 236,052.
Note: `season_ltv` ("pet revenue") ≈ 95% of all spend in the season, so it is not feature-only revenue either.

## Segments (fact)
`pet_segment_key` = seg_<pet>_<control|test>_<1–7>. Labels (`seg_pet`): 1–2 Easy, 3–4 Medium, 5–6 Hard, 7 seg_default.
Every season since at least Aug runs a control/test split inside each segment; test finishes more (Skunk seg 1: 3.6% vs 2.6%). Numbers below = both arms.
Meaning: ordered by recent spend (median 28-day pre-season spend about $0 / $5 / $54 / $114 / $195 / $296 for 1–6; seg 7 ≈ $0), but the bands overlap — no clean cut-off found. Definition not documented in Confluence.

## Table — Skunk (GoldenDog)
| Seg | % players | Payer rate | Share of game revenue | Finish % all | Finish % payers | Finishers' share of segment revenue | Revenue per finisher ÷ segment ARPPU |
|---|---|---|---|---|---|---|---|
| 1 Easy | 60% (52%) | 24% (20%) | 22% (18%) | 3% (2%) | 11% (10%) | 31% (28%) | 2.9 (2.9) |
| 2 Easy | 10% (10%) | 49% (42%) | 15% (12%) | 9% (7%) | 16% (14%) | 33% (29%) | 2.1 (2.1) |
| 3 Medium | 4% (3%) | 71% (69%) | 14% (10%) | 18% (16%) | 24% (21%) | 39% (37%) | 1.6 (1.8) |
| 4 Medium | 2% (1%) | 85% (84%) | 13% (9%) | 27% (23%) | 30% (25%) | 45% (43%) | 1.5 (1.7) |
| 5 Hard | 1% (1%) | 92% (91%) | 13% (8%) | 34% (32%) | 35% (33%) | 51% (51%) | 1.4 (1.5) |
| 6 Hard | 0.5% (0.3%) | 86% (82%) | 12% (7%) | 39% (44%) | 38% (41%) | 57% (60%) | 1.5 (1.5) |
| 7 default | 24% (33%) | 23% (28%) | 11% (36%) | 4% (6%) | 17% (17%) | 64% (47%) | 3.9 (2.7) |
| All | 100% | 30% (28%) | 99% (100%) | 5% (5%) | 16% (15%) | 44% (41%) | – |

Fact: in Dice both finish % and finishers' revenue share rise steeply with segment. The "revenue per finisher ÷ ARPPU" ratio falls (2.9 → 1.5) because in the top segments most payers finish.
seg 7 is not a level: it swings between seasons (36% → 11% of revenue).

## Inside the top segment (Q4, payers, season spend) — % of payers / % of segment revenue / finish %
| Band | Seg 6 Skunk | Seg 6 GoldenDog | Seg 5 Skunk |
|---|---|---|---|
| <$100 | 21% / 1% / 20% | 23% / 2% / 23% | 33% / 5% / 19% |
| $100–500 | 43% / 17% / 35% | 43% / 20% / 36% | 48% / 36% / 40% |
| $500–1,500 | 25% / 32% / 45% | 27% / 39% / 57% | 16% / 39% / 52% |
| $1,500+ | 11% / 50% / 66% | 8% / 39% / 74% | 3% / 20% / 68% |
Calibration rule (whole segment vs a sub-range): not documented; ask Dice economy.

## Difficulty
Not pulled in this pass (cookie requirement per level by segment). Open.
