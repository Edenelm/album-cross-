# Excel data files for the album analysis (2026-10-21)

Chart-ready tables for Dice Dreams, Domino Dreams and Disney Solitaire. Every number is copied from the repo's result docs and raw result files (`claude/*.md`, `claude/results/*.csv`); nothing was re-queried or estimated.

How each sheet is laid out: row 1 = title (what, game, albums), row 2 = definitions, population and units, row 3 = source doc (and SQL), table from row 5 with one header row. Game is its own column (long format). Percentages are stored as numbers with % format; money with $ format. Ranges in the source (for example 24–77%) are split into low / high columns. Per-day dollar values (ARPDAU) and ratios keep the decimals the source shows. Each workbook starts with an About sheet that lists its sheets.

Revenue bases: 'share of game revenue' = share of total game purchase revenue during the album (deck-wide denominator since 2026-10-20). 'Old base' = share of the standard population's album revenue; columns on the old base are labelled. Some sheets use files that exist only in worktree `continue-2026-10-21-f81bfe` (not yet merged into this branch); their source line says so.

## 01_games_side_by_side.xlsx — Chapter 1: the three games side by side

| Sheet | What it shows | Source |
|---|---|---|
| Structure | Album structure: length, sticker mix, rares, gate, end tool | claude/opening-facts-2026-10-20.md; SQL claude/opening_facts_queries.sql |
| Revenue_base | The deck-wide revenue denominator per album and the factor from the old base | claude/opening-facts-2026-10-20.md; SQL claude/opening_facts_queries.sql; factors to 3 decimals and Domino 17 from claude/game-revenue-rebase-2026-10-21.md |
| Exp_Sept | Share of players and Sept revenue by albums experienced (old split with a grey 'installed before Apr 2025' bucket) | claude/opening-facts-2026-10-20.md; SQL claude/opening_facts_queries.sql (section B; reuses claude/tenure-population-rerun-2026-10-17.md and cross-game-comparison-framework.md Topic 2) |
| Albums_all | NEW split: all players by albums seen over the full history (replaces the grey bucket), Dice and Domino | claude/albums-all-players-2026-10-21.md; SQL claude/albums-all-players-2026-10-21.sql |
| End_lift_exp | Last-4-day ARPDAU and end lift by album experience | claude/opening-facts-2026-10-20.md; SQL claude/opening_facts_queries.sql (section C) |
| End_lift_album | End lift per album since April 2025 (all players and login 0.5+), with album length | claude/album-length-end-arpdau-2026-10-18.md; SQL claude/album_length_end_arpdau_queries.sql |
| Disney_lift_album | Disney end lift per album with dates and player counts (album 14 = only negative) | claude/disney-end-lift-by-album-2026-10-21.md; SQL claude/disney_end_lift_by_album.sql (file is in worktree continue-2026-10-21-f81bfe, not yet merged into this branch) |
| Disney_daily_14_15 | Disney 14 vs 15 daily ARPDAU by weekend and last-week window | claude/disney-end-lift-by-album-2026-10-21.md (section 2) (file is in worktree continue-2026-10-21-f81bfe, not yet merged into this branch) |

## 02_end_status.xlsx — Chapter 2: who is where at the end

| Sheet | What it shows | Source |
|---|---|---|
| End_status | Payers by end status (finished / 1 / 2 / 3 / 4+ missing): players, share of payers, share of game revenue | claude/results/{dice,domino,disney}_game_revenue_rebase_2026-10-21.csv; doc claude/game-revenue-rebase-2026-10-21.md; SQL claude/game_revenue_rebase_queries.sql |
| Spend_groups | Payers by spend group: players, share of payers, share of game revenue | claude/results/{dice,domino,disney}_game_revenue_rebase_2026-10-21.csv; doc claude/game-revenue-rebase-2026-10-21.md; SQL claude/game_revenue_rebase_queries.sql |
| Heavy_missers | $20+ payers ending 2–3 short: players and share of game revenue | claude/results/{dice,domino,disney}_game_revenue_rebase_2026-10-21.csv; doc claude/game-revenue-rebase-2026-10-21.md; SQL claude/game_revenue_rebase_queries.sql |
| Finishers_album | Finishers per album (old vs new rule), finish rate, non-paying share, close-day finishers | claude/finisher-recount-2026-10-19.md (section 1; SQL claude/finisher_recount_queries.sql) and claude/payer-close-day-2026-10-20.md (SQL claude/payer_close_day_queries.sql) |
| Finish_timing | Finish day of payer finishers (close day, day before, 2–3, 4+) | claude/finisher-recount-2026-10-19.md (section 2) |
| Domino_cum_finish | Domino cumulative finish curve, 8 days out to close | claude/finisher-recount-2026-10-19.md (section 2) |

## 03_rare_sources.xlsx — Chapter 3: where rare stickers come from

| Sheet | What it shows | Source |
|---|---|---|
| Rare_timeline | Median payer's rare gaps, first rare day, rares at close, longest dry run | claude/rare-timeline-2026-10-20.md; SQL claude/rare_timeline_queries.sql |
| Rare_normalised | Rare pace normalised by rare count; longest wait as % of album | claude/rare-timeline-2026-10-20.md (section 'after normalising') |
| Rare_mix_quarter | Rare source mix by quarter (5d v4, non-first-album payers) | topic5-5d-v3-domino-first-royal-gift-2026-10-13.md (table 5d v4, at repo root); SQL topic5_rare_sources_queries.sql |
| Progression_p50 | Median payer's cumulative stickers and new stickers per day | claude/sticker-progression-p50-payers-2026-10-18.md; SQL claude/sticker_progression_queries.sql |
| Progression_type | Commons / Goldens / Rares held over album time, per game | claude/sticker-progression-p50-payers-2026-10-18.md (by-type section) |

## 04_closing.xlsx — Chapter 4: how the album gets closed

| Sheet | What it shows | Source |
|---|---|---|
| Last_sticker | Last sticker via Wild/Joker (all and paid), old vs new finisher rule | claude/remaining-recounts-2026-10-20.md (section 1); SQL claude/remaining_recounts_queries.sql |
| Tool_reach | Wild-filled and gate stickers per 100 middle payers, near vs far | middle-payers-stall-2026-10-15.md (section 'Last 14 days by window (EndWin)', repo root); query not saved in the repo |
| Tool_reach_activity | Middle payers near vs far: payers in last 4 days, revenue share of last week | middle-payers-stall-2026-10-15.md (EndWin section, repo root) |
| Routes | Finish rate and group size by Wild/Joker route (bought / gameplay / none) | claude/remaining-recounts-2026-10-20.md (section 3); SQL claude/remaining_recounts_queries.sql |
| Dryness | Free vs bought new stickers per day a week out, near vs far payers | claude/dryness-last-week-2026-10-20.md; SQL claude/dryness_last_week_queries.sql |
| Finisher_end_spend | Finishers' last-day spend and pay-rate lift | claude/remaining-recounts-2026-10-20.md (section 2) |
| Dice_wild_sources | Dice Wild fills per day in the last 8 days, by source (paid, Bonus Wheel, Trail...) | claude/dice-wild-sources-2026-10-21.md; SQL claude/dice_wild_sources_closing_week.sql |
| Dice_trail_close | Dice Trail campaigns at the close: players and top-tier reach | claude/open-checks-2026-10-21.md (section 2); SQL claude/dice_trail_calendar_check.sql |
| RV_finishers | Domino 20 RV per finisher: views, days, packs, Puzzle pieces, ad revenue | claude/domino-rv-rewards-2026-10-20.md; SQL claude/domino_rv_rewards_queries.sql |
| RV_automation | Domino 20 RV automation signals (gaps, views per hour, hours) | claude/open-checks-2026-10-21.md (section 1); SQL claude/domino_rv_automation_check.sql |
| Puzzle_closers | Domino 20 two-Puzzle closers: count, paid / not paid, strong group | claude/remaining-recounts-2026-10-20.md (section 4) |

## 05_left_behind.xlsx — Chapter 5: those left behind

| Sheet | What it shows | Source |
|---|---|---|
| Finish_8d_out | Finish rate by distance 8 days out (2–3 / 4–6 / 7–10 missing) | claude/finisher-recount-2026-10-19.md (section 6); SQL claude/finisher_recount_queries.sql |
| Same_spend | Finish rate at the same distance and spend, per game | claude/finisher-recount-2026-10-19.md (section 6) |
| Groups_revshare_old | Players and old-base revenue share of the deck's near / far / route groups | claude/revshare-fill-2026-10-20.md; SQL claude/revshare_fill_queries_2026-10-20.sql |
| Heavy_missers_week | $20+ payers 2–3 short: share and week-after spend gap | claude/finisher-recount-2026-10-19.md (section 6) and claude/game-revenue-rebase-2026-10-21.md (section 3, game-revenue share) |
| Disney_at_Dice_rates | Extra Disney finishers at Dice finish rates | claude/finisher-recount-2026-10-19.md (section 6) |

## 06_after_album.xlsx — Chapter 6: after the album

| Sheet | What it shows | Source |
|---|---|---|
| After_finish_7d | Finishers' spend after finishing and entry into the next album | claude/finisher-recount-2026-10-19.md (section 5); SQL claude/finisher_recount_queries.sql (WAVE 2) |
| Spend_by_finish_day | Days 1–3 spend ratio by finish timing (close-day finishers start slowest) | claude/finisher-recount-2026-10-19.md (section 5) |
| Week_after_close | Week-after-close spend by end status (the 'staircase') | claude/finisher-recount-2026-10-19.md (section 5, window 2) |
| Payout_next_album | Next-album payout ratio per player (Domino and Disney finishers drop) | claude/payout-mixpanel-def-2026-10-20.md (Check 3); SQL claude/payout_mixpanel_def_queries.sql (PER-PLAYER MEDIAN CHECK) |
| Dice_roll_return | Dice roll return around the close by end status | claude/dryness-last-week-2026-10-20.md (section 'overall return by end status') |
| Dice_spend_after_close | Dice spend and free rolls after the close by end status | claude/dryness-last-week-2026-10-20.md (follow-up section, Dice 61 / 63) |

## 07_game_cases.xlsx — Chapter 7: three game cases

| Sheet | What it shows | Source |
|---|---|---|
| Domino_19_20_groups | Domino 19 vs 20: finish rate and revenue per finisher by spend group | claude/finisher-recount-2026-10-19.md (section 4); earlier version claude/domino-19-vs-20-strength-mix-2026-10-18.md |
| Domino_3_albums | Domino 18/19/20 total revenue, players, revenue per player | claude/domino-album-total-rev-2026-10-18.md; SQL claude/domino_album_total_rev_queries.sql |
| Domino_rev_per_player | Domino 19 vs 20 revenue per player by spend group | claude/domino-album-total-rev-2026-10-18.md (section B) |
| Domino_easy_gate_end | Domino easy vs hard payers' end status (the easy gate pile) | claude/domino-easy-gate-end-2026-10-21.md; SQL claude/domino_easy_gate_end.sql |
| Dice_prize_code | Dice prize code vs prize stock and return to buying | claude/post-album-events-2026-10-19.md (section 'Prize burn ...', table by reward code); SQL claude/finisher_prize_burn_queries.sql |
| Dice_seg7_top | Dice segment 7 by spend tier: size, revenue, prize duration, return to buying | claude/seg7-top-payers-2026-10-20.md; SQL claude/seg7_top_payers_dice.sql |
| Dice_prize_groups | Dice prize proposal groups (sizes and revenue share) | claude/deck-review-2026-10-20.md (section 2, from the grand-prize docs in dice_dreams_ba, not copied into the repo) |

## 08_strength_targets.xlsx — Strength percentile curve and targets

| Sheet | What it shows | Source |
|---|---|---|
| Strength_curve | Finish rate and revenue share by strength bucket (deciles, p90–95, p95–99, p99+) | claude/results/{dice,domino,disney}_strength_percentile_2026-10-21.csv; doc claude/strength-percentile-2026-10-21.md; SQL claude/strength_percentile_queries.sql |
| Thresholds | Strength percentile thresholds per album | claude/strength-percentile-2026-10-21.md (section 1) |
| Above_below_p95 | Above vs below p95: finish rate and revenue share | claude/strength-percentile-2026-10-21.md (section 3) |
| Path_to_10pct | Two paths to the 10% finish goal | claude/strength-percentile-2026-10-21.md (section 3) |
| Finish_by_group | Finish rate by spend group, per album and average | claude/finisher-recount-2026-10-19.md (section 3); SQL claude/finisher_recount_queries.sql |
| Targets_today | Each game against the finish and revenue goals | claude/group-targets-options-2026-10-21.md (section 1) |
| Target_options | Per-group target options A and B (not decided) | claude/group-targets-options-2026-10-21.md (section 2) |

## 09_test_plan.xlsx — Test plan and what not to change

| Sheet | What it shows | Source |
|---|---|---|
| Tests | Each test x game with players and revenue share in scope | claude/final-analysis-spec-2026-10-21.md (sections 5 and 7) (file is in worktree continue-2026-10-21-f81bfe, not yet merged into this branch); claude/final-deck-bottom-lines-2026-10-21.md (sections 2–4, 6) |
| Keep_do_not | Keep / do-not list per game | claude/final-analysis-spec-2026-10-21.md (section 5) (file is in worktree continue-2026-10-21-f81bfe, not yet merged into this branch) |

## 10_checks_2026-10-21.xlsx — Checks added on 2026-10-21

| Sheet | What it shows | Source |
|---|---|---|
| Gate_distance | Gate distance: finish rate from 3 / 4 / 5 missing at close-4 and close-3 | claude/results/{dice,domino,disney}_gate_distance_finish_2026-10-21.csv; doc claude/gate-distance-finish-2026-10-21.md; SQL claude/gate_distance_finish_queries.sql (file is in worktree continue-2026-10-21-f81bfe, not yet merged into this branch) |
| Gate_distance_easy | Gate distance by Eden's easy definition | claude/results/{dice,domino,disney}_gate_distance_finish_easy_def_2026-10-21.csv; doc claude/gate-distance-finish-2026-10-21.md (section 5); SQL claude/gate_distance_finish_easy_def_queries.sql (file is in worktree continue-2026-10-21-f81bfe, not yet merged into this branch) |
| Payout_summary | Payout and album points by period, per game | claude/payout-by-source-last4-2026-10-21.md (section 1); SQL claude/payout_by_source_last4_queries.sql (file is in worktree continue-2026-10-21-f81bfe, not yet merged into this branch) |
| Payout_by_source | Payout points by source and period (raw file) | claude/results/{dice,domino,disney}_payout_by_source_last4_2026-10-21.csv; doc claude/payout-by-source-last4-2026-10-21.md (file is in worktree continue-2026-10-21-f81bfe, not yet merged into this branch) |

## Generator

Built with a Python script (openpyxl) kept outside the repo, in the session scratchpad. To rebuild, ask Claude to regenerate from the same docs.
