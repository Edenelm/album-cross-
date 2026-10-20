# Dice Dreams Album — Data Setup (approved by Eden, 2026-10-05)

Rule: every Dice album question goes to the dbt tables below, and each step is grilled/approved before running. Always state which table and filters are used.
Related docs: claude/dice-album-dbt-knowledge.md (model notes) · reference/dice_album_knowledge_base.md (team KB) · reference/album_cross_game_benchmark_plan.md (benchmark plan)

## Project
- BigQuery: `dice-dreams-dbt` (under `headquarters-dbt`; HQ itself has no album models)
- `dice-dreams` BI prod project is NOT reachable via MCP → Claude writes those queries, Eden runs them.

## Approved tables
| Layer | Table | Grain |
|---|---|---|
| 20_core | dim_album_season | album (start/end dates, days_in_album; album 63 end hardcoded 2026-09-07) |
| 20_core | dim_album_reward | album_reward_code |
| 20_core | dim_album_pixie_season | album |
| 30_intermediate | album_pop | user × album |
| 30_intermediate | fact_user_album_stickers | user × album × set × sticker |
| 30_intermediate | fact_user_daily_set_progression | user × album × set × day |
| 40_mart | fact_user_set_progression | user × album × set (latest) |
| 50_reporting | user_daily_metrics_agg | user × day |
| 50_reporting | user_daily_album | user × album × day (only users with ≥1 sticker; partition date_dim) |

## Benchmark albums (from dim_album_season, queried 2026-10-05)
| album_id | Name | Start | End | days_in_album |
|---|---|---|---|---|
| 61 | Album World Champeons | 2026-06-22 | 2026-07-27 | 36 |
| 63 | Peon's origin | 2026-07-27 | 2026-09-07 | 43 |
- Album ids 60, 62, 64 do not exist in dim_album_season → 61 and 63 are consecutive main albums. 12 sets each.
- Changeover day 2026-07-27 = album 61 end day = album 63 day 1.
- Lengths differ (36 vs 43 days) → revenue compared per day / per user.
- Album 61 ran during the World Cup period (World Champions theme) — possible external factor for 61 vs 63 variance.

## POPULATION (final, Eden Q14 — 2026-10-05)
Source: `dice-dreams-dbt.50_reporting.user_daily_album`, date_dim 2026-06-22..2026-09-07, album_id IN (61,63), is_excluded = FALSE.
- Engaged (base) = per user-album: COUNT(DISTINCT date_dim WHERE is_active) ÷ album_number_of_days ≥ 0.5. (Do NOT use the album_login_ratio column — it varies across rows.)
- Payers = engaged + LOGICAL_OR(is_album_pu).
| Album | Users with ≥1 sticker | Engaged (LR ≥ 0.5) | Payers | %PU of engaged |
|---|---|---|---|---|
| 61 | 1,122,820 | 536,601 | 215,299 | 40.1% |
| 63 | 1,087,876 | 516,218 | 217,956 | 42.2% |

## Time windows (Eden, 2026-10-05 — supersedes "window ends end−1")
- Album KPIs use the FULL album (start → album_end_date, incl. last days). Do not drop the last days.
- "Final ARPDAU" = last 3 days EXCLUDING the end day (e.g. end 31/08 → 28/08, 29/08, 30/08).
- Last-N-days analyses = N days before the end day, end day excluded.

## Results log
### 4. Full ARPDAU, final ARPDAU, payer finishers — 2026-10-05
Source: user_daily_album, engaged users. ARPDAU = SUM(spent_in_album_today) ÷ active user-days.
| KPI | Album 61 | Album 63 |
|---|---|---|
| Revenue full album | $22.17M | $26.80M |
| ARPDAU full album | $1.346 | $1.401 |
| Final ARPDAU (last 3 days excl. end) | $1.584 (+18% vs full) | $1.741 (+24% vs full) |
| Payers | 215,299 | 217,956 |
| Payer finishers | 24,882 | 29,603 |
| % of payers who finished | 11.6% | 13.6% |
| % of finishers who paid | 95.6% | 98.8% |

### 5. Last 3 / 4 days (excl. end day) by stickers missing at window entry — 2026-10-05
Bucket = total non-pixie stickers − unique_stickers_lt at end of the day before the window. Shares among engaged users ACTIVE in the window; payer = revenue > 0 in window; revenue = spent_in_album_today in window.
Missing 1–3 stickers combined:
| Album | Window | Users (share) | Payer share | Revenue share |
|---|---|---|---|---|
| 61 | last 3 | 47,229 (9.4%) | 24.1% | 39.2% |
| 61 | last 4 | 14,994 (3.0%) | 12.5% | 26.2% |
| 63 | last 3 | 103,653 (21.7%) | 40.4% | 53.7% |
| 63 | last 4 | 53,824 (11.1%) | 26.4% | 42.3% |
Full buckets, last 3 days:
| Bucket | 61 users / payer / rev share | 63 users / payer / rev share |
|---|---|---|
| Finished | 0.6% / 2.4% / 6.6% | 0.8% / 3.1% / 5.9% |
| Missing 1 | 0.5% / 2.3% / 5.3% | 0.8% / 3.7% / 6.6% |
| Missing 2 | 2.1% / 7.6% / 14.2% | 3.5% / 11.2% / 19.8% |
| Missing 3 | 6.9% / 14.2% / 19.6% | 17.4% / 25.5% / 27.3% |
| Missing 4–10 | 59.0% / 60.0% / 46.8% | 54.0% / 47.5% / 35.8% |
| Missing 11+ | 31.0% / 13.4% / 7.4% | 23.5% / 9.1% / 4.6% |
Read:
- In the final 3 days, users 1–3 stickers away are ~9–22% of active users but ~40–54% of revenue.
- %PU inside buckets: missing 1 ≈ 73–74%, missing 2 ≈ 49–55%, missing 3 ≈ 22–31%.
- Only ~2.9K (61) / 3.7K (63) users were finished entering the last 3 days vs 26K / 30K total finishers → most finishing happens in the last days / end day.
- Album 63 has a much larger "missing 3" pool (17% vs 7%) → possibly last stickers held/released late; check sticker release schedule.

### 3. KPI scorecard — window start → end−1 (earlier version) — 2026-10-05
| KPI | Album 61 (35d) | Album 63 (42d) |
|---|---|---|
| ARPDAU | $1.364 | $1.416 |
| ARPPU (season) | $102.1 | $122.1 (per day flat $2.92 vs $2.91) |
| Finishers | 26,027 (4.85%) | 29,967 (5.81%) |
| %PU of finishers | 95.6% | 98.8% |
| Finishers' revenue share | 30.8% | 34.0% |
| Avg / P50 sets completed (of 12) | 8.53 / 9 | 8.94 / 10 |
- Per-day monetization stable → average 61+63; completion differs (+20% rel) → report separately.

### 1. Population sizing via album_pop — SUPERSEDED (album_pop undercounts active days)
### 2. Login-ratio cross-check
| Source | Album 61 | Album 63 |
|---|---|---|
| album_pop.album_login_ratio ≥ 0.5 | 297,907 | 296,608 |
| UDM distinct active days ÷ days_in_album ≥ 0.5 | 549,936 | 523,882 |
| user_daily_album distinct is_active days ≥ half album | 536,601 | 516,218 |
- album_pop.active_days_in_album undercounts for ~300K users per album; user_daily_album.album_login_ratio varies across rows. To report to BI/dbt owners.

## Decisions
- Population = user_daily_album engaged users. No Kingdom filter (everyone in album tables is K ≥ 8).
- Participation (Q13): default B — funnel starts at "collected a sticker" for Dice.
- Two populations: Base = engaged; Payers = engaged + is_album_pu.
- Progression compared by `day_in_album` (Eden, Q12).
- Revenue across albums of different length: per-day / per-user metrics.
- Album revenue = `spent_in_album_today` (Eden, Q7). IAP only.
- User-level total revenue = `revenues_sum + ad_revenues`.
- Payer = `is_album_pu`. Finisher = `is_album_finisher`.
- Wilds exist in Dice: `wild_received_today` / `wild_received_lt`.

## From team KB (relevant to benchmark)
- Pixie eligibility: Kingdom ≥ 60 per KB (dbt `is_pixie_user` uses ≥ 30 — discrepancy).
- Team standard filters: Login Ratio ≥ 0.5 + Album PU = Yes.
- End-of-season template: overview KPIs, ARPDAU by phase (Start / Pixie / End), final 9 days, finishers, source of last 3 stickers, duplications.

## Benchmark scope (Eden, 2026-10-05)
- Base plan: reference/album_cross_game_benchmark_plan.md.
- 2 recent completed albums per game. Dice: 61 and 63.

## Next analyses (order)
1. ✅ KPI scorecard (+ full / final ARPDAU)
2. Progression funnel
3. Progression over time (day_in_album)
4. ✅ Final stretch (last 3/4 days, missing-sticker buckets) — partially; add pre-final period
5. Revenue by progression bucket
6. End-of-album dynamics
7. Engagement (UDM)
8. Album structure

## Open questions
- Same filters for Domino / Disney?

## Dice Looker dashboards
- Album Report (daily) — https://superplay.cloud.looker.com/dashboards/2143
- Albums comparison — https://superplay.cloud.looker.com/dashboards/2128
- Album FU: sets and stickers — https://superplay.cloud.looker.com/dashboards/2091

