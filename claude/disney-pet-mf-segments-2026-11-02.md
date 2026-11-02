# Disney Solitaire — PET feature (Magical Friends) segments (2026-11-02)
SQL: `claude/disney_pet_mf_segments_2026-11-02.sql` (Q1–Q6). Project `solitaire-dreams-411507`.
Disney's PET = **Magical Friends** ("mf"): Confluence DS "Magical Friends – One-Pager for roadmap" titles it "Magical Friends (Pet)", built on Domino's Pet.

## Feature and finish (fact)
- About 3-week season, 10 stages (tiers). Players earn Charms (DR) and spend them to fill each stage; each stage has a timer, and if it runs out the stage progress resets (PRD "Magical Friends", Ido Slutsky space; CS page DSC "Magical Friends").
- **Finish** = completed all 10 tiers (`tiers_completed_lt >= 10` in `bi_prod.magical_friend_user_profile`). The BI flag `is_finisher` gives the same number within ±1%.

## Segments (fact, from data)
`mtx_segment_key` in `bi_entity_prod.mf_activation_season_ids`. Since Season 6 there are 3:
`def_mf_0_30_bw_no_resets`, `def_mf_30_60_bw_no_resets`, `def_mf_60_plus_bw_no_resets`.
Seasons 2–5 (Jun 8 – Sep 21) also had an A/B split `_resets` / `_no_resets` for each band; it stops at Season 6.

**The metric behind "0_30 / 30_60 / 60_plus … bw" is not documented anywhere available to us.** Tested (S6) and rejected:
gross $ spend in the 14 or 30 days before start (median $0 in all 3 segments; 13K players in 0_30 spent $60+),
`ltv_on_mf_start`, and previous-season tiers completed. None gives a clean cut. Source needed: the BO Segmentation definition of these segments (Disney MTX / ops).

## Table — Season 6 Pooh (campaign 13785, 2026-09-22 to 2026-10-11)
Included: every player activated in the season (`mf_activation_season_ids`), special users out, internal QA campaign 13651 out.
Revenue = gross purchases (`bi_entity_prod.fact_user_daily_purchase`) on days 09-22..10-11. Game total 09-22..10-11 = $20.87M (all players).

| Segment | Players | % players | Finish % | Payers % (in seg) | % of payers | Share of revenue in season (participants = 100%) | Share of total game revenue |
|---|---|---|---|---|---|---|---|
| 0_30 | 1,007,508 | 71% | 3% (27,862) | 17% | 58% | 34% | 33% |
| 30_60 | 297,281 | 21% | 4% (11,622) | 24% | 25% | 22% | 21% |
| 60_plus | 109,871 | 8% | 8% (8,828) | 43% | 16% | 44% | 42% |
| All | 1,414,660 | 100% | 3% (48,312) | 20% | 100% | 100% | 96% |

Season 5 Simba (13075, no-reset arm only): finish 3% / 4% / 9% — same order.

## Feature revenue — NOT available (fact)
No column attributes purchases to the feature. `mf_spent_lt` (profile) and `mf_spent_lt_mtx` (cumulative) are ≈ all spend while the season is live (S6: $17.9M and $19.5M vs $19.9M purchases), not purchases of Magical Friends offers. Shares by `mf_spent_lt`: 32% / 23% / 45% — same picture as the column above. Need: offer/SKU → feature mapping (purchase events carry only `purchase_sku`).

## Difficulty (fact)
`dr_requirement` per tier in `bi_prod.magical_friend_tier` (S6). Each segment has its own ladder; higher band = more Charms per stage:
| Tier | 0_30 | 30_60 | 60_plus |
|---|---|---|---|
| 1 | 20 | 30 | 30 |
| 3 (median) | 150 | 200 | 220 |
| 5 (median) | 340 | 440 | 530 |
| 10 (min) | 1,560 | 2,030 | 2,500 |
So 30_60 ≈ 1.3x and 60_plus ≈ 1.6x the 0_30 ladder.
Inside each segment there are 4–5 fixed levels per tier (e.g. 60_plus tier 3: 190 / 220 / 240 / 360). Players with LTV $1K+ get slightly higher levels on average (60_plus tier 3: 273 vs 242 for LTV $0), but most of the spread is not explained by LTV. Retries use the same levels.

## Open-ended top segment (60_plus)
- Fact: one ladder for the whole 60_plus segment; no separate band above it.
- Not available: how the ladder was calibrated (all 60+ players or a sub-range such as a percentile cap). No calibration doc found in Confluence (DS / DSC spaces), and the 4–5 inner levels have no documented rule. Ask the Disney economy / feature owner for the config sheet (PRD links "Configuration" Google Sheet, Stages tab: requirement per milestone, cap per stage, cost multiplier).
- Hypothesis (not tested): the inner levels are the "CC" (custom config on Charm requirements and caps) the PRD mentions.

## Sources
BQ: `bi_entity_prod.mf_activation_season_ids`, `bi_prod.magical_friend_user_profile`, `bi_entity_prod.magical_friend_metrics_cumulative`, `bi_prod.magical_friend_tier`, `bi_entity_prod.fact_user_daily_purchase`.
Confluence: DS "Magical Friends – One-Pager for roadmap" (4038983681); "Magical Friends" PRD (4410277889); DSC "Magical Friends" (5266800643).
