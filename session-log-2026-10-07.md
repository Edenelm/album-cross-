# Session log — cross-game album benchmark (2026-10-07)

Full definitions, tables and results live in `claude/cross-game-comparison-framework.md`. This log records what was done, the decisions Eden made, and what is open.

## Working rules (Eden)
- dbt / BigQuery only; every query call passes the project (dice-dreams-dbt, domino-dreams-dbt, solitaire-dreams-411507).
- One topic at a time, one question at a time, approval before running.
- Always state tables + filters; always show PU next to all players.
- Labels: Known / Needs Validation / Missing / Hypothesis. No causal claims — propose an A/B test. Recommendations: Adopt / Test / Do Not Adopt Yet.
- Do not connect topics now; dependencies only after all 13 topics.

## Data conventions
- Dice `50_reporting.user_daily_album`: is_active, is_excluded, spent_in_album_today, album_start_date / album_end_date, album_login_ratio, unique_super_stickers_lt.
- Domino `prod_40_mart.user_daily_album`, Disney `bi_prod.user_daily_album`: active_flag, special_user_flag, album_spent_today, album_open_date / album_close_date, login_ratio (recalculated daily), unique_royal_stickers_tl, user_album_count.
- Exclusions: Dice is_excluded; Domino special users + suspected_cheater_flag (`user_daily_metrics`); Disney special users + `user_profile.exclude_reason`.
- Close date and open date are partial days in all games. Close date: normal DAU, ~35–40% of normal revenue. Open date: DAU 70–84%, revenue 46–60% of next day.
- Cohorts: Disney user_album_count (validated vs ROW_NUMBER 99.7–100%); Dice/Domino ROW_NUMBER from history (Dice from album 22, Nov 2023; Domino from album 6, Jun 2024) — pre-history players with <7 counted albums = "unidentified".
- Sticker totals: Dice `external_sources.album_stickers_profile`; Domino `prod_50_reporting.album_sticker_progression`; Disney `bi_entity_prod.album_sticker_progression`.

## Topic 1 — Time to first album exposure (done)
- Payers-before n: Dice 142,592 / Domino 63,459 / Disney 505,374. Active days P50/P75: 3/6, 1/2, 3/5.

## Topic 2 — Population by albums experienced, Sept 2026 (done)
- 7+ album revenue share: Dice 57%, Domino 50%, Disney 37%.
- Follow-up: ARPDAU during the last four full album days vs whole-album ARPDAU (close−4…close−1), same album × same cohort. Medians by cohort 1→7+: Dice 1.08→1.22, Domino 1.13→1.18, Disney 1.01→1.06. Close-inclusive QA ~0.10–0.12 lower; open-date exclusion not material.
- Files: album_end_ratio_heatmaps.png, album_end_ratio_by_album_cohort.csv.

## Topic 3 — Album duration & timing (not started)
- Rare progression was moved out of Topic 3 into Topic 4 (Eden).

## Topic 4 — Rare stickers (in progress)
- Totals: Dice 12 Supers (61, 63); Domino 8 (17) / 9 (19) Royals; Disney 7 Royals (14, 15). Album = 144 set stickers in all games. Rare share: Dice 8.3%, Domino 5.6% / 6.3%, Disney 4.9%.
- Corrected progression (PU, last-row login ratio ≥ 0.5, median): end-of-album rare collection % Dice 75 / 83%, Domino 75 / 67%, Disney 71 / 57%. First new-rare day Dice 5 / 3, Domino 8 / 8, Disney 7 / 10. Gap between new-rare days 4–5 (Dice), 6–7 (Domino, Disney). 2+ rares on a new-rare day: 22–27% Dice/Domino, 12% Disney.
- Corrections made: metric renamed "Equivalent album-days per unique rare collected" (summary ratio only); earlier "first rare" was the day cumulative P50 reached 1 — now player-level; odd/even row fluctuation traced to daily login_ratio — fixed with a fixed per-player population.
- Queries: t4_dice / t4_domino / t4_disney _rare_progression_pu.sql.

## Open items
- Topic 3 (duration, gaps between albums, launch frequency, ending period, ending-weekend ARPDAU vs previous 14 days) — after Eden says continue.
- Hypothesis to check: Disney first Royal looks release-gated (narrow P50–P75 window).
- Needs Validation: Dice album 61 album_login_ratio varies within user-album for 305K of 1.12M players.
- Older: Dice album_pop history / is_excluded gap; data issues to report to BI.

