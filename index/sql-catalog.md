# SQL catalog (generated 2026-10-26 from file headers; `c/` = `claude/`)
Game: Di = Dice (`dice-dreams-dbt`), Do = Domino (`domino-dreams-dbt`), Sn = Disney Solitaire (`solitaire-dreams-411507`). Tables = most-used `dataset.table` names in the file. Feeds = results docs that name the file. Root `.sql` = old pack (10-07..10-17), history only.
Rule (CLAUDE.md): dry-run, then run; save every new query in `claude/<topic>_<date>.sql` next to `claude/<topic>-<date>.md`, and add a line here.

## Core tables per game (CLAUDE.md / decisions-definitions-register.md)
| | Dice | Domino | Disney |
|---|---|---|---|
| Daily album | 50_reporting.user_daily_album (close-day sticker count NOT updated) | prod_40_mart.user_daily_album | bi_prod.user_daily_album |
| Stickers | 30_intermediate.fact_user_album_stickers (use for close-day finishers) | prod_30_intermediate.int_user_album_stickers | bi_entity_prod.dim_user_album_stickers |
| Daily metrics | 50_reporting.user_daily_metrics_agg | prod_40_mart.user_daily_metrics | bi_prod.solitaire_user_daily_metrics_agg_df |
| Exclusions | is_excluded | special_user_flag + suspected_cheater_flag | special_user_flag + exclude_reason |
| Other | 30_intermediate.user_daily_rolls_in_out (prize/rolls), 20_core.dim_campaign, 40_mart.fact_dynamic_resource_given (VIP gift) | prod_30_intermediate.int_user_daily_rv, prod_20_core.core_ad_watch_completed (RV); CZ = smart_segments.cz_c in prod_10_staging.stg_purchase_completed_vw (staging, approval only) | – |
MCP guardrail: no `SELECT *`; flatten STRUCT fields in a separate CTE (`a.struct.field` is read as a table).

## Topic 0 definitions / denominator → index/topic-t0-definitions.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/album_table_rerun_queries_2026-10-18.sql | DiDoSn | user_daily_album, user_daily_metrics_agg, user_daily_metrics | v2 (2026-10-18): revenue/payer from the album table spend column (per decisions register). Resu | claims-register; nonpayer-finishers-2026-10-18 | Current |
| c/finisher_recount_queries.sql | DiDoSn | user_daily_album, fact_user_album_stickers, user_daily_metrics | Finisher recount 2026-10-19 (Eden approved). Finisher = 144 unique set stickers by END of close | revshare-fill-2026-10-20; finisher-recount-2026-10-19 | Current |
| c/game_revenue_rebase_queries.sql | DiDoSn | user_daily_album, fact_user_album_stickers, user_daily_metrics_agg | Exact rebase to game purchase revenue (2026-10-21). Results: claude/game-revenue-rebase-2026-10 | game-revenue-rebase-2026-10-21; topic6-game-revenue-after-close-2026-10-24 | Current |
| c/opening_facts_queries.sql | DiDoSn | album_sticker_progression, user_daily_album, album_stickers_profile | Opening facts (Eden 2026-10-20). Results: claude/opening-facts-2026-10-20.md. All RAN. | opening-facts-2026-10-20 | Current |
| c/payer_close_day_queries.sql | DiDoSn | user_daily_album, user_daily_metrics, fact_user_album_stickers | Payer includes the close day (Eden, 2026-10-20). Results: claude/payer-close-day-2026-10-20.md | payer-close-day-2026-10-20 | Current |
| c/remaining_recounts_queries.sql | DiDoSn | user_daily_album, user_daily_metrics, int_user_album_stickers | Remaining recounts 2026-10-20 (Eden: 'ספירות שנשארו'). Finisher new = 144 unique set stickers b | remaining-recounts-2026-10-20 | Current |
| c/revshare_fill_queries_2026-10-20.sql | DiDoSn | user_daily_album, fact_user_album_stickers, user_daily_metrics_agg | Revenue shares for deck populations that had none (Eden 2026-10-20: every population shows its  | revshare-fill-2026-10-20 | Current |

## Topic 1 end lift / ARPDAU → index/topic-t1-end-lift.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/album_length_end_arpdau_queries.sql | DiDoSn | user_daily_album, user_daily_metrics, user_profile | Album length vs last-4-days ARPDAU (2026-10-18). Albums opened >= 2025-04-01, closed <= 2026-10 | album-length-end-arpdau-2026-10-18 | Current |
| c/dice65_end_2026-10-24.sql | Di | user_daily_album, fact_user_album_stickers | Eden 2026-10-24: what happened at the end of Dice 65 (end lift +3%, first flat Dice end). | dice65-end-2026-10-24 | Current |
| c/dice65_pu_trail_2026-10-25.sql | Di | user_daily_album, fact_user_album_stickers | Eden 2026-10-25: Dice 65 vs 63 — (1) were there enough paying users (PU) in the last days? (2)  | dice65-pu-trail-2026-10-25 | Current (main lacks Q5 PU/PAU; newer copy merged to main (PR #28)) |
| c/disney15_windows_game_revenue_2026-10-24.sql | DoSn | solitaire_user_daily_metrics_agg_df, user_daily_metrics | Eden 2026-10-24: v144a used standard-population payers' album spend ($873K/day). Re-run on tota | disney15-windows-game-revenue-2026-10-24 | Current |
| c/disney_end_lift_by_album.sql | Sn | user_daily_album, user_profile | 2026-10-21 (Eden): Disney only, every album since April 2025: ARPDAU of the last 4 full days (c | disney-end-lift-by-album-2026-10-21 | Current |
| c/mix_fixed_arpdau_2026-10-25.sql | DiDoSn | user_daily_album, user_daily_metrics, user_profile | Eden 2026-10-25: the "Avg Arpdau Whole Album" and "Avg Arpdau Last 4 Days" slides — recompute w | mix-fixed-arpdau-2026-10-25 | Current |
| c/open_checks_2026-10-24.sql | DiDoSn | user_daily_album, user_daily_metrics, solitaire_user_daily_metrics_agg_df | Eden 2026-10-24 (story review, item 4 + Dice 65 follow-up): three checks. Results: claude/open- | open-checks-2026-10-24 | Current |

## Topic 2 finishers vs far → index/topic-t2-finishers-far.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/dice_topic2_reruns_2026-10-22.sql | Di | user_daily_album, fact_user_album_stickers, user_daily_metrics_agg | Topic 2 Dice reruns on the fixed standard population (Eden approved 2026-10-22). Results: claud | dice-topic2-reruns-2026-10-22 | Current |
| c/strength_percentile_queries.sql | DiDoSn | user_daily_album, fact_user_album_stickers, user_daily_metrics_agg | Finish rate and revenue share by payer strength percentile (2026-10-21, Eden). Results: claude/ | dice-topic2-reruns-2026-10-22; strength-percentile-2026-10-21 | Current |
| c/topic2_followups_2026-10-22.sql | DiDoSn | user_daily_album, user_daily_metrics, fact_user_album_stickers | Topic 2 follow-ups (Eden 2026-10-22). Results: claude/topic2-followups-2026-10-22.md | topic2-followups-2026-10-22 | Current |

## Topic 3 rare / Golden / Super supply → index/topic-t3-rare-supply.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/golden_buy_share_d20_s15_2026-10-23.sql | DoSn | user_daily_album, int_user_album_stickers, dim_user_album_stickers | Eden 2026-10-23 (option A): rerun slide 'Share of Active Payers Who Bought a New Golden, per Da | data-story-review-2026-10-21 | Current (superseded by golden_buy_share_d65_d20_s15 once branch claude/albums-seen-october is merged) |
| c/golden_purchase_revenue_2026-10-22.sql | DiDoSn | user_daily_album, fact_user_album_stickers, purchase_completed_vw | 2026-10-22 (Eden): revenue in the last 10 days before close (d -10..-1, close day out) from pur | data-story-review-2026-10-21; golden-offers-by-day-2026-10-23 | Current |
| c/golden_timeline_2026-10-23.sql | DiDoSn | user_daily_album, user_daily_metrics, int_user_album_stickers | Golden timeline for the median paying player (Eden, 2026-10-23): same as rare_timeline_queries. | golden-timeline-2026-10-23 | Current |
| c/rare_timeline_queries.sql | DiDoSn | user_daily_album, fact_user_album_stickers, user_daily_metrics | Rare-sticker timeline for the median paying player (Eden, 2026-10-20). Results: claude/rare-tim | rare-timeline-2026-10-20; golden-timeline-2026-10-23 | Current |
| dice_supers_mechanism_queries.sql | Di | user_daily_album, fact_user_album_stickers, fact_user_daily_set_progression | Dice supers mechanism one-pager (2026-10-12). Project: dice-dreams-dbt. Albums 61/63. PU (is_al | agent-analysts-kickoff-prompt; dice-supers-mechanism-onepager-2026-10-12 | History (pre-10-18 pack, root) |
| dice_supers_placebo_q5c.sql | Di | user_daily_album, fact_user_album_stickers, purchase_completed_vw | Q5c (2026-10-14) Placebo base rate for "purchase <=10 / <=60 min before last Super". Project di | dice-supers-mechanism-onepager-2026-10-12 | History (pre-10-18 pack, root) |
| c/domino_rare_sources_split_2026-10-26.sql | Do | user_daily_metrics, user_daily_album, int_user_album_stickers | 10-26: album 20 new Royals by source per quarter, orange "closing tools" split into duplicates / paid / Market (slide rare-sources-mix) | domino-rare-sources-split-2026-10-26 | Current (merged 10-26) |
| c/domino_easy_goldens_progression_2026-10-26.sql | Do | user_daily_album, user_daily_metrics, int_user_album_stickers | 10-26: Goldens held by tenth of album, Easy vs Hard payers, albums 17/19/20 (slide "Goldens Split After 70%") | domino-easy-goldens-progression-2026-10-26 | Current (merged 10-26) |
| c/rares_by_time_median_2026-10-26.sql | DiDoSn | user_daily_album, fact_user_album_stickers, int_user_album_stickers, user_daily_metrics | 10-26: median and avg % of the album's rares held by % of album time; Dice 59/61/63, Domino 17/19/20, Disney 12/14/15 | (results doc missing, C19) | Current, no results doc |
| c/golden_buy_share_d65_d20_s15_2026-10-25.sql | DiDoSn | user_daily_album, fact_user_album_stickers, int_user_album_stickers | 10-25: share of active payers buying a new Golden per day, last 10 days, Dice 65 / Domino 20 / Disney 15 (corrected Dice paid rule) | golden-buy-share-d65-d20-s15-2026-10-25 | merged to main (PR #28) |

## Topic 4 how the album closes → index/topic-t4-album-close.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/all144_steps_2026-10-23.sql | DiDoSn | user_daily_album, user_daily_metrics, int_user_album_stickers | All 144 set stickers held by the median paying player, per album day (Eden, 2026-10-23). | golden-timeline-2026-10-23; disney-stalls-missing-2026-10-23 | Current |
| c/closing_week_pct_payers_2026-10-24.sql | DiDoSn | user_daily_album, fact_user_album_stickers, user_daily_metrics | 2026-10-24 (Eden): fix of the closing-week slide ("Dice Sells Wilds All Week; Domino Gives Joke | closing-week-pct-payers-2026-10-24 | Current |
| c/closing_week_split_golden_queries.sql | DiDoSn | user_daily_album, fact_user_album_stickers, int_user_album_stickers | 2026-10-18: closing week (paid vs gameplay closing tool) + new Goldens per day. RAN after Eden  | closing-week-split-golden-2026-10-18 | Current |
| c/dice_trail_calendar_check.sql | Di | fact_user_campaign_trail | Open check (deck slide open-checks / closing-week): Dice Trail campaigns around the album 61 /  | open-checks-2026-10-21 | Current |
| c/dice_wild_sources_closing_week.sql | Di | user_daily_album, fact_user_album_stickers | 2026-10-21: Dice closing week — which source gives the Wilds each day (Eden's deck review, item | dice-wild-sources-2026-10-21 | Current |
| c/disney_stalls_missing_2026-10-23.sql | DoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, dim_user_album_stickers | Eden 2026-10-23: (A) Disney 15 all-144 stalls (days 10-13, 26-31): new stickers per day by sour | disney-stalls-missing-2026-10-23 | Current |
| c/domino_easy_gate_end.sql | Do | user_daily_album, user_daily_metrics | Domino 19/20: end status by easy / hard segment (2026-10-21, Eden). Results: claude/domino-easy | domino-easy-gate-end-2026-10-21 | Current |
| c/domino_last_sticker_joker_19_20.sql | Do | user_daily_album, user_daily_metrics, int_user_album_stickers | 2026-10-19 (Eden asked to run album 20; ran, 19.04 GB, domino-dreams-dbt). | – | Current |
| c/domino_movie_twister_purchases_2026-10-24.sql | Do | user_daily_album, user_daily_metrics, int_user_album_stickers | 2026-10-24 (Eden): Domino 20 payers who got a Joker from the Movie Twister event (AlbumMomentsT | domino-movie-twister-purchases-2026-10-24 | Current |
| c/dryness_last_week_queries.sql | DiDoSn | user_daily_album, fact_user_album_stickers, solitaire_user_daily_metrics_agg_df | Hypothesis (Eden, 2026-10-20): in Disney's last week free sticker supply does not dry up, so pl | dryness-last-week-2026-10-20 | Current |
| c/far_rare_gate_gap_2026-10-23.sql | DoSn | user_daily_album, user_profile, dim_user_album_stickers | Eden 2026-10-23 (option A): rerun "far payers: days between last new rare and gate open" on Dis | far-rare-gate-gap-2026-10-23 | Current |
| c/gap_by_day_3games_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Eden 2026-10-24: is the Disney 15 pattern (payers who end 4+ away fall behind finishers gradual | gap-by-day-3games-2026-10-24 | Current |
| c/gate_distance_finish_easy_def_queries.sql | DiDoSn | user_daily_album, user_daily_metrics, fact_user_album_stickers | 2026-10-21 (Eden): same check as gate_distance_finish_queries.sql, with Eden's definition of "e | gate-distance-finish-2026-10-21 | Current |
| c/gate_distance_finish_queries.sql | DiDoSn | user_daily_album, user_daily_metrics, fact_user_album_stickers | 2026-10-21 (Eden): payers who were exactly 3 / 4 / 5 stickers short 4 and 3 days before close - | gate-distance-finish-2026-10-21 | Current |
| c/joker_fills_gate_queries.sql | DoSn | user_daily_album, dim_user_album_stickers, int_user_album_stickers | 2026-10-18 (Eden approved): Joker fills per day d-14..-1 by route and sticker type (all players | approved-batch-2026-10-18 | Current |
| c/lull_economy_disney15_2026-10-23.sql | Sn | user_daily_album, solitaire_user_daily_metrics_agg_df, mp_coins_in_vw | Eden 2026-10-23: "in lull days or burst days, is there an anomaly in the economy, e.g. high pay | lull-economy-disney15-2026-10-23 | Current |
| c/lull_revenue_disney15_2026-10-23.sql | Sn | user_daily_album, solitaire_user_daily_metrics_agg_df | Eden 2026-10-23: burst 1 has higher payout and lower spend — more buyers or less revenue? And w | lull-economy-disney15-2026-10-23 | Current |
| c/royal_then_pay_check_2026-10-23.sql | Sn | user_daily_album, user_profile, dim_user_album_stickers | Eden 2026-10-23: "if a far payer who did not pay gets more Royals, will she pay to finish?" Des | royal-then-pay-check-2026-10-23 | Current |
| c/stand_close3_queries.sql | DiDoSn | user_daily_album, user_daily_metrics, user_profile | 2026-10-18: where players stand 3 days before close (Eden asked: same as close-4, at 3 days). R | stand-close4-2026-10-18; dice-topic2-reruns-2026-10-22 | Current |
| c/stand_close4_queries.sql | DiDoSn | user_daily_album, user_daily_metrics, user_profile | 2026-10-18: where players stand 4 days before close (Eden approved). Results: claude/stand-clos | stand-close4-2026-10-18 | Current |
| c/sticker_progression_queries.sql | Di | user_daily_album | Sticker progression, median paying player (2026-10-18). Cumulative unique set stickers (of 144) | storyboard-v2-2026-10-18; sticker-progression-p50-payers-2026-10-18 | Current |
| c/topic4_gates_2026-10-22.sql | DiDo | user_daily_album, user_daily_metrics, int_user_album_stickers | Topic 4 gates rerun (Eden 2026-10-22). Results: claude/topic4-gates-2026-10-22.md | topic4-gates-2026-10-22 | Current |
| c/topic4_last8_finish_2026-10-22.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, fact_user_album_stickers | Topic 4 (2026-10-22, Eden): finish rate of payers who REACHED 1-3 / 4-6 / 7-10 missing at any p | topic4-last8-finish-2026-10-22 | Current |
| c/topic4_market_split_dice.sql | Di | user_daily_album, fact_user_album_stickers, user_daily_metrics_agg | Topic 4 (Eden 2026-10-22): finishers by status on close-4; new stickers close-3..finish day spl | – | Current |
| c/topic4_market_split_disney.sql | Sn | user_daily_album, solitaire_user_daily_metrics_agg_df, dim_user_album_stickers | Topic 4 (Eden 2026-10-22): finishers by status on close-4; new stickers close-3..finish day spl | – | Current |
| c/topic4_market_split_domino.sql | Do | user_daily_album, user_daily_metrics, int_user_album_stickers | Topic 4 (Eden 2026-10-22): finishers by status on close-4; new stickers close-3..finish day spl | – | Current |
| c/topic4_middice_fixed_2026-10-22.sql | Di | user_daily_album | Topic 4 (2026-10-22): MidDice rerun on the fixed Dice population. Only change: 'not first album | topic4-dice-far-rares-fixed-2026-10-22 | Current |
| c/domino_19v20_daily_pauses_2026-10-26.sql | Do | user_daily_album, user_daily_metrics, int_user_album_stickers | 10-26: Domino 19 vs 20 median payer per album day: new set stickers, new Goldens, cumulative held | domino-19v20-daily-pauses-2026-10-26 | Current (merged 10-26) |
| c/median_missing_at_close_2026-10-25.sql | DiDoSn | user_daily_album, fact_user_album_stickers, int_user_album_stickers | 10-25: median paying player's missing stickers at close by type (slide "What the P50 Paying Player Still Misses at Close"); same rules as disney_stalls_missing (B) | median-missing-at-close-2026-10-25 | merged to main (PR #28) |

## Topic 5 left behind → index/topic-t5-left-behind.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/near_share_last7_2026-10-25.sql | DiDoSn | user_daily_album, user_daily_metrics, solitaire_user_daily_metrics_agg_df | 2026-10-25 (Eden): per game, share of album revenue (and of payers) from payers who are <=3 sti | near-share-last7-2026-10-25 | Current |
| c/topic5_end_lift_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Topic 5 end lift on the topic-5 payer population (2026-10-24). Albums Dice 61/63, Domino 19/20, | topic5-end-lift-2026-10-24; data-story-review-2026-10-21 | Current |
| c/topic5_left_behind_2026-10-23.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Topic 5 reruns (Eden 2026-10-23: "run all three"): those left behind, on the fixed populations. | topic5-left-behind-2026-10-23 | Current |
| c/topic5_sensitivity_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Topic 5 sensitivity (2026-10-24): is "<=3 missing at close-4" the best cut? Same payer populati | data-story-review-2026-10-21; topic5-sensitivity-2026-10-24 | Current |
| c/topic5_tiers_2026-10-23.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Topic 5 split (Eden 2026-10-23: split by the 5 tiers, goal = revenue share at <=3 missing at cl | topic5-tiers-2026-10-23 | Current |
| topic5_rare_sources_queries.sql | DiDoSn | user_daily_album, fact_user_album_stickers, user_daily_metrics | Topic 5 (2026-10-12): new rares by source x quarter. Run each in its own project. Deduped per u | agent-analysts-kickoff-prompt; topic5-rare-sources-2026-10-12 | History (pre-10-18 pack, root) |
| c/end_status_d19_d20_dice63_2026-10-26.sql | DiDo | user_daily_album, user_daily_metrics | 10-26: end status of payers by spend level, Domino 19 vs 20 vs Dice 63 (t5a_slide); same SQL as topic5_tiers_2026-10-23 | end-status-d19-d20-dice63-2026-10-26 | Current (merged 10-26) |

## Topic 6 after the album / payout / events → index/topic-t6-after-album.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/a6s9v_gap_pct_2026-10-25.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Eden 2026-10-25: a6s9v card — show the one-week gap as % of album revenue. Album revenue = stan | a6s9v-gap-pct-2026-10-25 | Current |
| c/deluxe_cutoff_domino.sql | Do | user_daily_metrics, user_daily_deluxe_album, user_daily_album | Domino Deluxe eligibility cut-off: finishers just before vs just after the "Deluxe Hour To Albu | post-album-events-2026-10-19 | Current |
| c/deluxe_did_domino.sql | Do | user_daily_metrics, user_daily_album, user_daily_deluxe_album | Deluxe before vs after launch (Eden 2026-10-19: "what can we say about Deluxe that proves it is | post-album-events-2026-10-19 | Current |
| c/dice_gt20_finishers_cz_ron_2026-10-25.sql | Di | user_daily_metrics_agg, user_daily_album | 2026-10-25 (Eden): Dice finishers over $20 a day drop 15-19% in the week after close vs their n | dice-gt20-finishers-cz-ron-2026-10-25 | Current |
| c/domino_easy_end_pays_twice_2026-10-24.sql | Do | user_daily_album, user_daily_metrics | Did Domino album 20's easier end (two Puzzle Jokers) pay a second time at the start of album 21 | domino-easy-end-pays-twice-2026-10-24 | Current |
| c/early_finishers_event_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Eden 2026-10-24: slide proposing a post-album event test for Dice. Who could such an event reac | early-finishers-event-2026-10-24 | Current |
| c/event_effect_disney.sql | Sn | solitaire_user_daily_metrics_agg_df, user_daily_album, user_daily_magic_event | Do the post-album events make finishers come back to buying faster? DISNEY albums 14, 15. Payer | post-album-events-2026-10-19 | Current |
| c/event_effect_domino.sql | Do | user_daily_metrics, user_daily_album, int_rv_user_daily_coins_spent | Do the post-album events make finishers come back to buying faster? DOMINO albums 19, 20. Payer | post-album-events-2026-10-19 | Current |
| c/event_spend_fields_2026-10-24.sql | DoSn | user_daily_deluxe_album, user_daily_album, user_daily_magic_event | Eden 2026-10-24: what do the post-album event spend fields count? Docs (BigQuery column descrip | event-spend-fields-2026-10-24 | Current |
| c/nonpayer_post_album_queries.sql | DiDoSn | user_daily_album, user_daily_metrics_agg, user_daily_metrics | NOT RUN YET (proposed 2026-10-18): did non-paying finishers start paying after the album? Group | nonpayer-rv-week-after-2026-10-18 | Current |
| c/payout_by_source_last4_queries.sql | DiDoSn | user_daily_album, user_daily_metrics, stg_coins_in_vw | 2026-10-21 (Eden): where does the high payout of the last 4 days come from, Domino vs the other | payout-by-source-last4-2026-10-21 | Current |
| c/payout_mixpanel_def_queries.sql | DiDoSn | user_daily_album, fact_user_album_stickers, user_daily_rolls_in_out | Daily payout by album end status, by the exact Mixpanel definitions (Eden 2026-10-20). NOT RUN  | payout-mixpanel-def-2026-10-20; lull-economy-disney15-2026-10-23 | Current |
| c/post_album_events_queries.sql | DiDoSn | solitaire_user_daily_metrics_agg_df, user_daily_album, user_daily_metrics | 2026-10-19 PROPOSED, NOT RUN: post-album events for finishers (completion day -> album close; c | post-album-events-2026-10-19 | Current |
| c/stock_sources_dice.sql | Di | user_daily_album, user_daily_rolls_in_out, user_daily_rolls_by_source | Where does the post-completion roll stock come from? Dice album 63, payer finishers (144 by end | post-album-events-2026-10-19 | Current |
| c/timing_reference_dice.sql | Di | user_daily_metrics_agg, user_daily_album, user_daily_rolls_in_out | Dice reference for the event comparison: same recovery metrics by finish timing (no paid post-a | post-album-events-2026-10-19 | Current |
| c/topic6_after_album_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Topic 6: after the album (2026-10-24). Same payer population and spend levels as claude/topic5_ | data-story-review-2026-10-21; topic6-after-album-2026-10-24 | Current |
| c/topic6_before_after_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | 2026-10-24 (Eden): rebuild of ALBUM END slide 59 (s6a). Same as claude/topic6_after_album_2026- | topic6-before-after-2026-10-24; topic6-calendar-neutral-return-2026-10-24 | Current |
| c/topic6_buyers_spend_d13_2026-10-24.sql | DiDoSn | user_daily_album, user_daily_metrics, solitaire_user_daily_metrics_agg_df | Topic 6 (Eden 2026-10-24): split the return after close into % who buy x spend per buyer, days  | topic6-buyers-spend-d13-2026-10-24 | Current |
| c/topic6_calendar_check_2026-10-24.sql | DiDoSn | dim_excluded_users, user_daily_metrics_agg, user_daily_metrics | Topic 6 (Eden 2026-10-24): Domino 19 and Disney 14 look like Dice 63 on tg1 — same case? Calend | topic6-game-revenue-after-close-2026-10-24 | Current |
| c/topic6_calendar_neutral_return_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Topic 6 (Eden 2026-10-24, option 1): calendar-neutral return after close, 3 albums per game. | topic6-normal-week-check-2026-10-24; topic6-calendar-neutral-return-2026-10-24 | Current |
| c/topic6_finisher_prize_2026-10-24.sql | DiDoSn | user_daily_album, user_daily_metrics, stg_coins_in_vw | Topic 6 point 1 (Eden, 2026-10-24): finishers come back at different levels — prize size or gam | topic6-finisher-prize-2026-10-24 | Current |
| c/topic6_free_inflow_oos_2026-10-24.sql | DiDoSn | user_daily_album, user_daily_metrics, solitaire_user_daily_metrics_agg_df | Topic 6 (Eden approved 2026-10-24): stock is ~0 at close in all games (topic6_stock_by_status), | topic6-free-inflow-oos-2026-10-24 | Current |
| c/topic6_game_revenue_after_close_2026-10-24.sql | DiDoSn | user_daily_album, dim_excluded_users, user_daily_metrics_agg | Topic 6 (Eden 2026-10-24): total game revenue after the album closes vs the last month, three g | topic6-game-revenue-after-close-2026-10-24 | Current |
| c/topic6_normal_week_check_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Topic 6 (Eden 2026-10-24): normal-week check. Is the >$20 payers' drop after close just "return | topic6-normal-week-check-2026-10-24; dice-gt20-finishers-cz-ron-2026-10-25 | Current |
| c/topic6_payout_by_status_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, mp_coins_in_vw | Topic 6 (Eden, 2026-10-24): the Part 1 slide 36 measure for every close status, next to the ret | topic6-payout-by-status-2026-10-24; topic6-payout-prizes-by-level-2026-10-24 | Current |
| c/topic6_payout_level_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, mp_coins_in_vw | Topic 6 (Eden, 2026-10-24): payout LEVEL after close (not the ratio to before), by close status | topic6-payout-by-status-2026-10-24 | Current |
| c/topic6_payout_prizes_3albums_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, mp_coins_in_vw | Topic 6 (Eden 2026-10-24): payout with album prizes for the 3-album set (earlier two albums per | topic6-payout-3albums-2026-10-24 | Current |
| c/topic6_payout_prizes_by_level_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, mp_coins_in_vw | Topic 6 (Eden 2026-10-24): payout WITH album prizes (Eden: prizes are rolls/coins the player ge | topic6-payout-3albums-2026-10-24; topic6-payout-prizes-by-level-2026-10-24 | Current |
| c/topic6_prize_short12_2026-10-24.sql | DiDoSn | user_daily_album, user_daily_metrics, stg_coins_in_vw | Topic 6 / prize (Eden 2026-10-24): show the prize in days of own play for players 1-2 stickers  | topic6-prize-vs-spend-2026-10-24 | Current |
| c/topic6_prize_vs_spend_2026-10-24.sql | DiDoSn | user_daily_album, user_daily_metrics, stg_coins_in_vw | Topic 6 / prize (Eden 2026-10-24): "strong players spend a lot relative to what the prize gives | topic6-prize-vs-spend-2026-10-24 | Current |
| c/topic6_short_payers_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_metrics | Topic 6 point 2 (Eden, 2026-10-24): payers 1-2 stickers short on close-1 — what happened on the | topic6-short-payers-2026-10-24 | Current |
| c/topic6_short_payout_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, mp_coins_in_vw | Topic 6 point 2b (Eden asked 2026-10-24): payers 1-2 short — do the ones whose payout fell more | topic6-short-payers-2026-10-24 | Current |
| c/topic6_stock_by_status_2026-10-24.sql | DiDoSn | user_daily_album, solitaire_user_daily_metrics_agg_df, user_daily_rolls_in_out | Topic 6 stock check (Eden approved 2026-10-24): balance at the end of the close day in days of  | topic6-stock-by-status-2026-10-24; topic6-payout-by-status-2026-10-24 | Current |
| post_completion_queries.sql | DiDoSn | user_daily_album, user_daily_metrics_agg, solitaire_user_daily_metrics_agg_df | Post-completion analysis (2026-10-17). Dice: template with @params (albums 61,63; 2026-06-01..2 | post-completion-2026-10-17; post-completion-chart-data-2026-10-17 | History (pre-10-18 pack, root) |

## Topic 7 Dice prize → index/topic-t7-dice-prize.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/finisher_prize_burn_queries.sql | DiDoSn | solitaire_user_daily_metrics_agg_df, user_daily_album, user_daily_metrics | Finisher prize burn + album segment + not-enough-rolls / OOC timing (proposed 2026-10-19, NOT r | deck-review-2026-10-20; post-album-events-2026-10-19 | Current |
| c/seg7_top_payers_dice.sql | Di | user_daily_metrics_agg, user_daily_album, user_daily_rolls_in_out | Dice segment 7 (album_reward_code = 7, 200K prize): payer finishers split by spend segment and  | deck-review-2026-10-20; seg7-top-payers-2026-10-20 | Current |
| c/topic7_dice_prize_2026-10-25.sql | Di | user_daily_album, user_daily_rolls_in_out | Topic 7 (2026-10-25): Dice payer finishers — who finishes, by spend level x final-prize code, a | topic7-dice-prize-2026-10-25 | Current |
| c/topic7_fixed_prize_spend_2026-10-24.sql | Di | user_daily_album | Topic 7 (Eden 2026-10-24): "these players spend a lot album after album but stay on a fixed pri | topic7-fixed-prize-spend-2026-10-24 | Superseded by _v2 |
| c/topic7_fixed_prize_spend_v2_2026-10-24.sql | Di | user_daily_album | Topic 7 (Eden 2026-10-24): clean rerun of topic7_fixed_prize_spend_2026-10-24.sql for slide t7g | topic7-fixed-prize-spend-2026-10-24 | Current |
| c/topic7_top_payers_2026-10-24.sql | Di | user_daily_album, dim_campaign | Topic 7b (2026-10-24): why did Dice >$20 a day finishers start album 65 at 85% of own pace (alb | topic7-top-payers-2026-10-24 | Current |
| c/topic7_top_payers_2day_prize_2026-10-24.sql | Di | user_daily_album, user_daily_rolls_in_out | Topic 7 (Eden 2026-10-24): test arm = only $2K+ payers in the 200K tier, prize = 2 days of the  | topic7-top-payers-2day-prize-2026-10-24 | Current |

## Domino cases → index/topic-domino-cases.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/domino_19_20_mix_queries.sql | Do | user_daily_album, user_daily_metrics, int_user_album_stickers | DRAFT 2026-10-18: Domino 19 vs 20 — (a) finisher mix by player strength, (b) finishers who clos | day-synthesis-2026-10-18; domino-19-vs-20-strength-mix-2026-10-18 | Draft/not run |
| c/domino_album_total_rev_queries.sql | Do | user_daily_album, user_daily_metrics | 2026-10-18: Domino 18/19/20 — did total album revenue (all players, not only finishers) rise in | domino-album-total-rev-2026-10-18 | Current |
| c/domino_finish_timing_17_19_20.sql | Do | user_daily_album, user_daily_metrics | 2026-10-18 (Eden approved, ran): Domino 17 vs 19 vs 20 finish day. 16.4 GB. Results: claude/app | approved-batch-2026-10-18 | Current |
| c/domino_last_sticker_cost_queries.sql | Do | user_daily_album, user_daily_metrics, int_user_album_stickers | DRAFT 2026-10-18: Domino 19 vs 20 — source of the last new sticker for ALL finishers, and reven | domino-19-vs-20-last-sticker-cost-2026-10-18 | Draft/not run |
| c/domino_strong_closers_price_vs_cz.sql | Do | user_daily_album, user_daily_metrics, int_user_album_stickers | 2026-10-18 (Eden approved staging, cz = smart_segments.cz_c, last 7 days): 393 strong two-puzzl | domino-strong-closers-price-vs-cz-2026-10-18 | Current |
| c/domino_strong_puzzle_closers_end_sources.sql | Do | int_user_album_stickers, user_daily_album, user_daily_metrics | 2026-10-18: Domino 20 — 393 strong (5$+/day prev album) finishers whose last two new stickers w | domino-strong-puzzle-closers-2026-10-18 | Current |
| c/domino_easy_hard_splits_2026-10-26.sql | Do | user_daily_album, user_daily_metrics, int_user_album_stickers | 10-26: Easy vs Hard splits of three slides (Royals held at 90%/close; last new Royal day for far P50–95; revenue near by day). Albums 17/19/20 | domino-easy-hard-splits-2026-10-26 | Current (merged 10-26) |

## Domino dx chapter (merged 10-26, PRs #30/#31) → index/topic-domino-dx.md
- c/domino_easy_gate_stuck_2026-10-27.sql · Domino 20 Easy std payers: reached FU vs finished by spend level → domino-easy-gate-stuck-2026-10-27 / dxfu_slide · current
- c/domino_goldenkiosk_std_2026-10-27.sql · Domino 20 GoldenKiosk rares on std payers, by state at close−8 → domino-goldenkiosk-std-2026-10-27 · current
- c/domino_end_rares_jokers_19v20_2026-10-27.sql · Domino 19 vs 20 std payers: new Golden/Royal (bought/Kiosk/gameplay) + Joker per day, last 10 days → domino-end-rares-jokers-19v20-2026-10-27 · current
- c/domino_golden_fill_rate_19v20_2026-10-27.sql · Domino 19 vs 20 std payers: % of missing Goldens/Royals filled per day, last 10 days → domino-end-rares-jokers-19v20-2026-10-27 (addendum) · current
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/domino_dx_gate_structure_2026-10-25.sql | Do | user_daily_album, int_user_album_stickers | 10-25 dx topic 2: which Goldens/Royals were Joker-only (locked to the end) per album and Easy/Hard; release = first day with 200+ non-Joker collections. Albums 17–20 | domino-dx-map-2026-10-25 | Current (merged 10-26) |
| c/domino_dx_close4_buckets_2026-10-25.sql | Do | user_daily_album, user_daily_metrics | 10-25 dx topic 2: payers at 1/2/3/4–5/6+ missing on close−4 by Easy/Hard, albums 19/20, with revenue shares | domino-dx-map-2026-10-25 | Current (merged 10-26) |
| c/domino_dx_t2_within_level_2026-10-25.sql | Do | user_daily_album, user_daily_metrics | 10-25 dx topic 2: distance on close−4 within the same prior spend level (≤2/2–5/5–20/>20), what is missing (Goldens/Royals). Albums 19/20 | domino-dx-t1-t2-2026-10-25 | Current (merged 10-26) |
| c/domino_dx_gate_joker_source_2026-10-25.sql | Do | int_user_album_stickers | 10-25 dx topics 2/4: source campaign of the gate (Joker-only) stickers by day before close; 19 = R107/R108/G101/G130, 20 = R119/R120/G139 | domino-dx-t1-t2-2026-10-25 | Current (merged 10-26) |
| c/domino_dx_t1_mix_vs_behavior_2026-10-25.sql | Do | user_daily_album, user_daily_metrics, core_purchase | 10-25 dx topic 1: album 19 vs 20 (and 18 vs 19) — player mix vs behaviour within levels set by the PREVIOUS album | domino-dx-t1-t2-2026-10-25 | Current (merged 10-26) |
| c/domino_dx_t4_puzzle_jokers_2026-10-25.sql | Do | int_user_album_stickers, core_mini_collection_tier_completed, user_daily_album | 10-25 dx topic 4: end-of-album puzzle Jokers (campaign, dates, 1 vs 2 used), prize ladder/funnel, who got them. Albums 17–20 (only USED Jokers visible) | domino-dx-t4-2026-10-25 | Current (merged 10-26) |
| c/domino_dx_t2_effort_3_vs_45_2026-10-26.sql | Do | user_daily_album, user_daily_metrics | 10-26 dx topic 2: Easy payers 3 vs 4–5 (vs 1–2, 6–10) missing on close−4, same prior level: revenue/effort in close−3..−1; convergence by close−3. Albums 19/20 | domino-dx-t2-effort-3-vs-45-2026-10-26 | Current (merged 10-26) |
| c/domino_dx_t2_reach3_by_c3_2026-10-26.sql | Do | user_daily_album, user_daily_metrics | 10-26 dx topic 2: album 20 Easy 4–5 at close−4 who reach ≤3 by close−3 vs started at 3: finish/pay | domino-dx-t2-effort-3-vs-45-2026-10-26 | Current (merged 10-26) |
| c/domino_dx_test_population_c7_2026-10-26.sql | Do | user_daily_album, user_daily_metrics | 10-26 dx test slide: Easy test population at close−7, album 20 (3–5 = 9,448; 6–8 = 39,931) and outcomes | domino-dx-t2-effort-3-vs-45-2026-10-26 | Current (merged 10-26) |
| c/domino_dx_end_lift_2026-10-26.sql | Do | user_daily_album, user_daily_metrics | 10-26 dx: album-end lift (last 4 full days vs rest), active players + revenue, game level, albums 18/19/20 (+ Easy/Hard, calibration weeks) | domino-dx-end-lift-2026-10-26 | Current (merged 10-26) |
| c/domino_dx_easy_end_decomp_2026-10-26.sql | Do | user_daily_metrics, core_purchase, int_user_album_stickers, stg_purchase_completed_vw (staging, approved 10-26) | 10-26 dx: Easy end ARPDAU lift = payer-day rate × purchases × $/purchase, albums 17–20; Q6–Q8 = finishers' last 3 sticker sources + Easy far check | domino-dx-easy-end-decomp-2026-10-26; domino-dx-last3-sources-2026-10-26 | Current (merged 10-26) |
| c/domino_dx_t1_story_check_2026-10-26.sql | Do | user_daily_metrics, core_purchase, stg_purchase_completed_vw, user_daily_album | 10-26 dx topic 1 story check: was 20 better than 18/19? revenue/day, DAU, ARPDAU, $/purchase, installs, what they bought. Albums 17–20, whole game | domino-dx-t1-story-check-2026-10-26 | Current (merged 10-26) |

## Non-payers / RV → index/topic-nonpayers-rv.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/domino_rv_3albums_2026-10-24.sql | Do | user_daily_album, user_daily_metrics, stg_ad_watch_completed_vw | Domino albums 17 and 19: the same per-finisher RV summary as domino_rv_rewards_queries.sql Q2 ( | domino-rv-3albums-2026-10-24 | Current |
| c/domino_rv_automation_check.sql | Do | user_daily_album, user_daily_metrics, stg_ad_watch_completed_vw | Open check (deck slide open-checks / rv-path): is the ~93 views a day of Domino 20 non-paying f | open-checks-2026-10-21 | Current |
| c/domino_rv_finishers_queries.sql | Do | int_user_daily_rv, user_daily_album, user_daily_metrics | DRAFT 2026-10-18 (not run): Domino 17/19/20 finishers (payer / nonpayer) — RV during album days | domino-rv-finishers-2026-10-18 | Draft/not run |
| c/domino_rv_rewards_queries.sql | Do | user_daily_album, user_daily_metrics, stg_ad_watch_completed_vw | Domino album 20 — what a rewarded video (RV) gives finishers, and its role in completing the al | domino-rv-3albums-2026-10-24; domino-rv-rewards-2026-10-20 | Current |
| c/nonpayer_finishers_queries.sql | DiDoSn | user_daily_album, user_daily_metrics_agg, fact_user_album_stickers | Non-paying finishers + last new sticker source (2026-10-18). Disney run with albums 12-15 and m | nonpayer-finishers-2026-10-18 | Current |
| c/nonpayer_last2_queries.sql | DiDoSn | user_daily_album, user_daily_metrics_agg, fact_user_album_stickers | Last two new stickers of non-paying finishers (2026-10-18). Non-payer = album-table spend = 0. | nonpayer-finishers-2026-10-18 | Current |
| c/nonpayer_prior_month_queries.sql | DiDoSn | user_daily_album, user_daily_metrics_agg, user_daily_metrics | NOT RUN YET (approved by Eden 2026-10-18): prior-30-day value of finishers, non-payers vs payer | nonpayer-prior-month-2026-10-18 | Current |
| c/nonpayer_rv_week_after_queries.sql | DiDoSn | user_daily_album, user_daily_metrics_agg, user_daily_metrics | RUN 2026-10-18 (Eden narrowed scope): finishers payer/nonpayer — (1) RV (ad revenue, metrics ta | nonpayer-rv-week-after-2026-10-18 | Current |

## Targets & tests (8–9) → index/topic-targets-tests.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/finisher_targets_queries.sql | DiDoSn | user_daily_album, user_daily_metrics_agg, user_daily_metrics | Finisher targets by spend group (2026-10-18). Same body for all games; previous album = previou | finisher-recount-2026-10-19; finisher-targets-by-group-2026-10-18 | Current |
| c/topic9_disney_test_sizes_2026-10-24.sql | Sn | user_daily_album, solitaire_user_daily_metrics_agg_df, dim_user_album_stickers | Eden 2026-10-24 ("תריץ את 1"): sizes for two Disney test populations on the topic-9 test slides | topic9-disney-test-sizes-2026-10-24 | Current |

## VIP → index/topic-vip.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/vip_gift_recipients_2026-10-24.sql | Di | user_daily_album, fact_user_album_stickers, fact_dynamic_resource_given | Eden 2026-10-24: VIP review, step 5. Dice "Exclusive VIP Gift" (campaign 010926_VIP_VipFualbumt | vip-review-2026-10-24 | Current |
| c/vip_normal_week_churn_2026-10-24.sql | DiDoSn | user_daily_album, user_daily_metrics, solitaire_user_daily_metrics_agg_df | Eden 2026-10-24: VIP review, step 3 (normal-week check) + churn after close. | vip-review-2026-10-24 | Current |
| c/vip_status_recount_2026-10-24.sql | DiDoSn | user_daily_album, fact_user_album_stickers, user_daily_metrics | Eden 2026-10-24: review of vip_album_end_analysis_handoff.md, step 2. | vip-review-2026-10-24 | Current |
| c/vip_third_album_2026-10-24.sql | DiDoSn | user_daily_album, user_daily_metrics, solitaire_user_daily_metrics_agg_df | Eden 2026-10-24: VIP review, step 4 = step 3 on a third album per game (agreed set): Dice 61 (n | vip-review-2026-10-24 | Current |
| c/domino_after_close_20plus_vip_2026-10-26.sql | Do | user_daily_metrics, user_daily_album, stg_purchase_completed_vw | 10-26: Domino 19/20 week after close vs normal week: >$20 finished vs 1–2 short (a6s8s), VIP LTV≥$5K by status (vipa) | domino-after-close-20plus-vip-2026-10-26 | Current (merged 10-26) |

## Segmentation → index/topic-segmentation.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/dice_predictor_queries.sql | Di | user_daily_album | 2026-10-18 (Eden approved): Dice history vs current spend predictor (same method as Disney D5b  | approved-batch-2026-10-18 | Current |
| c/prize_within_segment_dice.sql | Di | user_daily_metrics_agg, user_daily_album, user_daily_rolls_in_out | Dice: prize size within the same difficulty segment. Albums 61, 63. Payer finishers (144 by end | deck-review-2026-10-20; post-album-events-2026-10-19 | Current |
| c/profile_easy_medium_dice.sql | Di | user_daily_album | Who are Easy / Medium / Hard / Extreme among Dice payer finishers? Albums 61, 63 (previous albu | post-album-events-2026-10-19 | Current |
| dice_segmentation_validation_queries.sql | Di | user_daily_album | Dice segmentation validation queries (2026-10-14). Project dice-dreams-dbt. Albums 61/63. | dice-segmentation-validation-2026-10-14 | History (pre-10-18 pack, root) |
| disney_segmentation_queries.sql | Sn | user_profile, user_daily_album | Dis1 (2026-10-14) Disney: pre-album spend level from history -> decision table for thresholds.  | disney-segmentation-d5-2026-10-15; disney-segmentation-build-2026-10-14 | History (pre-10-18 pack, root) |
| disney_segmentation_queries_d5.sql | Sn | user_profile, user_daily_album | Dis5 (2026-10-15) Disney: daily tier inside each option-C level at the last-quarter start. Proj | – | History (pre-10-18 pack, root) |

## Tenure / albums seen → index/topic-tenure.md
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/album_timeline_7plus_queries.sql | DiDoSn | user_daily_album, user_daily_metrics, user_profile | 2026-10-19: album timeline (ARPDAU by 10% of album time) + last 4 days vs rest, all players and | album-timeline-7plus-end-2026-10-19 | Current |
| c/albums-all-players-2026-10-21.sql | DiDo | user_daily_album, user_daily_metrics_agg, user_daily_metrics | All Sept-2026 players by number of albums seen, full table history (no "installed before Apr 20 | data-story-review-2026-10-21; albums-all-players-2026-10-21 | Current |
| c/cohort_end_lift_album1_to_7.sql | DiDoSn | user_daily_album, user_daily_metrics, user_profile | Same players from their 1st to their 7th album: end lift and ARPDAU (Eden 2026-10-22, option B) | cohort-end-lift-2026-10-22 | Current |
| c/dice_end_lift_65_7plus.sql | Di | user_daily_album | Dice end lift: add album 65 (closed 2026-10-19) + 7+ group with the fixed album count (Eden app | dice-end-lift-65-7plus-2026-10-22 | Current |
| c/end_lift_by_experience_full_history.sql | DiDoSn | user_daily_album, user_daily_metrics, user_profile | End lift by number of albums experienced, same groups as Eden's revenue slide (1 / 2-3 / 4-6 /  | end-lift-by-experience-2026-10-22 | Current |
| c/first_album_finish_rate_queries.sql | DiDoSn | user_daily_album, fact_user_album_stickers, dim_excluded_users | Finish rate and finisher revenue share WITH vs WITHOUT first-album players (Eden, 2026-10-21).  | first-album-finish-rate-2026-10-21 | Current |
| tenure_population_rerun_queries.sql | DiDo | user_daily_album, user_daily_metrics_agg, user_daily_metrics | Tenure population table rerun (Sept 2026) under the install >= 2025-04-01 rule. Run 2026-10-17. | tenure-population-rerun-2026-10-17 | History (pre-10-18 pack, root) |
| c/albums-seen-october-2026-10-25.sql | DiDoSn | user_daily_metrics_agg, user_daily_album, solitaire_user_daily_metrics_agg_df | 10-25: revenue share by albums seen, Oct 1–24 (slide 11 for October) | albums-seen-october-2026-10-25 | merged to main (PR #28) |
| c/cohort_end_lift_pooled_vs_rest_2026-10-25.sql | DiDoSn | user_daily_album, user_daily_metrics, user_profile | 10-25: same players album 1→7, end lift vs REST of album, join groups pooled (slide 16) | cohort-end-lift-pooled-2026-10-25 | merged to main (PR #28) |
| payer-time-to-first-album-2026-10-21.sql (c/) | DiDoSn | user_daily_album, user_daily_metrics_agg, user_daily_metrics | 10-21 v2: payers, days from install to first album (installs 2025-04..2026-06) | payer-time-to-first-album-2026-10-21 | uncommitted, in worktree paid-player-album-time |

## Benchmarks (old pack)
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| album_benchmark_queries.sql | DiDoSn | user_daily_album, user_profile, user_daily_metrics | Cross-game album benchmark: query pack (2026-10-08). NOTE: spent_in_album_today / album_spent_t | agent-analysts-kickoff-prompt; album-analysis-pack-2026-10-08 | History (pre-10-18 pack, root) |

## Deck checks
| File | Game | Tables | What it computes (header) | Feeds | Status |
|---|---|---|---|---|---|
| c/deck_review_checks_2026-10-20.sql | Di | user_daily_album, fact_user_album_stickers, user_daily_metrics_agg | Deck review checks, 2026-10-20. Results: claude/deck-review-2026-10-20.md | deck-review-2026-10-20 | Current |

## Not-in-main SQL (see files-catalog §Worktrees)
- Branch claude/albums-seen-october (merged 10-27, PR #28): albums-seen-october, cohort_end_lift_pooled_vs_rest, golden_buy_share_d65_d20_s15, median_missing_at_close (rows above), newer dice65_pu_trail (Q5).
- Uncommitted: payer-time-to-first-album-2026-10-21.sql (worktree paid-player-album-time); topic3_reruns_2026-10-22.sql (continue-session-20c65f, D-W4).
- Merged 10-26 (was worktree-only): all domino_dx_* and the other 10-26 Domino SQL, now rows above.
