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

## Payers only (Q7, added 2026-11-02)
Payer = paid at least once on season days (S5 08-31..09-21, S6 09-22..10-11). S5 = both A/B arms together (arms differ by ≤1 pt).
| Season | Segment | Payers | % of all game payers | Share of total game revenue | Finish % (payers) | Finishers' share of segment revenue |
|---|---|---|---|---|---|---|
| S6 | 0_30 | 166,798 | 50% | 33% | 14% | 40% |
| S6 | 30_60 | 72,030 | 22% | 21% | 15% | 39% |
| S6 | 60_plus | 47,164 | 14% | 42% | 18% | 49% |
| S6 | All | 285,992 | 87% | 96% | 15% | 44% |
| S5 | 0_30 | 179,978 | 53% | 33% | 13% | 40% |
| S5 | 30_60 | 70,306 | 21% | 21% | 14% | 39% |
| S5 | 60_plus | 56,255 | 17% | 44% | 17% | 51% |
| S5 | All | 306,539 | 90% | 97% | 14% | 45% |
Game totals: S5 $23.15M / 340,919 payers; S6 $20.87M / 330,436 payers.

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

## Follow-up for Natie (2026-11-02): finish %, payer %, finisher revshare by segment
Context: Disney economists want a finisher-revshare target that rises with segment difficulty; Natie expected the reverse for finish %.
S6 (S5 in brackets). All players: finish 3 / 4 / 8% (3 / 4 / 9%); payer rate 17 / 24 / 43%.
Payers: finish 14 / 15 / 18% (13 / 14 / 17%); finishers' share of segment revenue 40 / 39 / 49% (40 / 39 / 51%).
Revenue per finisher vs share of payers: about 2.7–2.9x in every segment → the top segment's higher finisher revshare comes from more finishers, not from finishers paying relatively more.

Segment meaning (Q8): higher segment = more Charms collected per active day in the previous season (median about 50 / 108 / 145), but no clean 30/60 cut; 14% of 0_30 had no previous season. Definition still needed from BO.

Inside each segment, S6 payers by season spend (Q9) — % of segment payers / % of segment revenue / finish %:
| Band | 0_30 | 30_60 | 60_plus |
|---|---|---|---|
| <$20 | 57% / 11% / 4% | 45% / 6% / 3% | 23% / 1% / 1% |
| $20–100 | 33% / 38% / 19% | 37% / 30% / 14% | 34% / 10% / 7% |
| $100–500 | 9% / 43% / 50% | 17% / 54% / 42% | 34% / 42% / 28% |
| $500+ | 0.4% / 9% / 87% | 1% / 10% / 79% | 9% / 47% / 67% |
In 60_plus, 9% of payers ($500+) bring 47% of the segment revenue and 67% of them finish; the $100–500 band finishes 28%.
Calibration rule (whole segment vs a capped sub-range like "240–300"): not documented in any source available. Only the economy team / config sheet can answer.

## Update from the Disney team (Eden, 2026-11-02)
- Segment metric = **gross wins** ("bw"), 3 bands (0–30 / 30–60 / 60+). Next season they add 3 more segments (6 in total).
- Difficulty = a multiplier per segment, from 0.8 to 2 relative to segment 0_30. (Our data, S6: 30_60 ≈ 1.3x and 60_plus ≈ 1.6x the 0_30 Charm ladder — consistent with that range.)
- Eden's position: for more segments (current ones too wide); add finish % per segment, not only finisher revshare; against a finisher-revshare target (the extremes cannot be controlled, as Natie said).
- New segments for next season (gross wins, from Eden 2026-11-02): 0–20 / 20–30 / 30–60 / 60–150 / 150–240 / 240+. Today's 0_30 splits in two, 60_plus splits in three; 240+ is the new open-ended top (Natie's "240+" question).
