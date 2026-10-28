# ALBUM END deck map (Google Slides 1vtwRvOAocgcZfrxl8uBfpOzIt7wkGbkCtxEBgFB4FvM)
Columns: # = last known position (it shifts) · Code = objectId or short code · Card = index/topic-*.md · Status: live / replaced / proposed / Eden-decides / skipped (Eden hid it) / unverified. Script paths are in `claude/`. PNG = `claude/slides/`. "unv" = **unverified, check live deck**.

## A. Opening and topics 0–3 (built in "Copy of ALBUM END" 1rUG…, 10-22)
| # | Code | Title / message | Key numbers | Card | Source doc | SQL | Script | PNG | Status |
|---|---|---|---|---|---|---|---|---|---|
| 5–9 | dz5–dz9 (copies) | Opening and structure. Originals of 5–9 disappeared after a design-agent run; "Eden handled" | – | – | c/next-session-prompt-2026-10-24.md | – | – | – | unv |
| 6 / 7 | – | "Same 144 Stickers, Built Three Different Ways" / "Album End" (gate + closing tool) | – | t4 | data-story-review §Topic 0 | – | – | – | unv |
| 11 | – | Most Revenue Comes From Players Past Their First Album (revenue share by albums seen 1/2–3/4–6/7–12/13+) | Dice first album 4% of revenue | tenure | c/albums-all-players-2026-10-21.md | c/albums-all-players-2026-10-21.sql | – | – | live (10-22) |
| 10 | – | Older revenue-by-experience slide, left as is: Dice first-album 8% should be 4%, legend labels wrong | – | tenure | data-story-review line 35 | – | – | – | live, known error |
| 13 | – | Every Album Ends Higher, Except Disney in 2026 and Dice 65 (Eden's title) | Dice 65 flat | t1 | c/end-lift-by-experience-2026-10-22.md; c/dice-end-lift-65-7plus-2026-10-22.md | c/dice_end_lift_65_7plus.sql | – | – | live |
| 14 | – | Same players, album 1→7 (kept as is) | – | tenure | c/cohort-end-lift-2026-10-22.md | c/cohort_end_lift_album1_to_7.sql | – | – | live |
| 15 | – | In Disney, a Third of Revenue Comes From Payers Who End Far | Disney 4+ 36/36% | t2 | c/topic2-followups-2026-10-22.md | c/topic2_followups_2026-10-22.sql | – | – | live |
| 16 | – | The Wild / Joker Reaches the Near, Almost Never the Far | 30 vs 5, 54 vs 7, 19 vs 2 | t2 | c/topic2-followups-2026-10-22.md | same | – | – | live |
| 17 | – | Domino and Disney Payers Wait Up to a Third of the Album for a Rare | longest wait 14% / 30% / 35% of album | t3 | c/rare-timeline-2026-10-20.md | c/rare_timeline_queries.sql | – | – | live (unv #) |
| 18 | – | Dice Always Has a Way to a Super; Domino and Disney Wait for Events | mechanism from product teams | t3 | data-story-review §Topic 3 | – | – | – | live |
| 19 | – | Finish rate and finishers' share (avg of last 2 albums) | – | t0 | c/finisher-recount-2026-10-19.md | – | – | – | unv |

## B. Topic 4: how the album closes (10-23)
| # | Code | Title / message | Key numbers | Card | Source doc | SQL | Script | PNG | Status |
|---|---|---|---|---|---|---|---|---|---|
| 28 | a144 | All 144 stickers, step chart, median payer | close 141/142/138 | t4 | c/golden-timeline-2026-10-23.md | c/all144_steps_2026-10-23.sql | – | album-end-all144-steps-2026-10-23.png | live |
| 29 | m144 | What payers miss at close | – | t4 | c/disney-stalls-missing-2026-10-23.md | c/disney_stalls_missing_2026-10-23.sql | – | album-end-missing-at-close-2026-10-23.png | live |
| 30 | h32_* | Share of active payers buying a new Golden per day, last 10 days, offers marked | 0–8% scale | t3 | c/golden-purchase-revenue-2026-10-22.md; c/golden-offers-by-day-2026-10-23.md | c/golden_purchase_revenue_2026-10-22.sql | – | album-end-slide30-2026-10-23.png | live |
| 32 | – | Rare step chart, median payer | longest wait 14/30/35% | t3 | c/rare-timeline-2026-10-20.md | c/rare_timeline_queries.sql | – | – | live (labels slightly off) |
| 33 | g32_* | Goldens Held by the Median Paying Player | longest wait 12/12/14% | t3 | c/golden-timeline-2026-10-23.md | c/golden_timeline_2026-10-23.sql | – | album-end-slide33-golden-steps-2026-10-23.png | live |
| – | – | Goldens Split After 70% of the Album (Domino hard; Easy line computed 10-26: ends 82% vs Hard 90%, Easy line on slide **unv**) | – | t3 | c/golden-timeline-2026-10-23.md; c/domino-easy-goldens-progression-2026-10-26.md | c/domino_easy_goldens_progression_2026-10-26.sql | – | album-end-goldens-split-hard-2026-10-23.png | live |
| 34 | – | Subtitle: far middle payers 8–15% / 17% / 22% | – | t4 | data-story-review §Topic 3 | – | – | – | unv |
| 38 | case_slide | One Far Payer's Last 14 Days: Dice vs Disney | illustration from averages | t4 | c/far-rare-gate-gap-2026-10-23.md | c/far_rare_gate_gap_2026-10-23.sql | – | album-end-case-far-payer-2026-10-23.png | live |
| 39 | …_2345 | Day of the Last New Rare (rebuilt in place) | 10–13 vs 3–5 days | t4 | c/far-rare-gate-gap-2026-10-23.md | same | – | album-end-last-rare-far-2026-10-23.png | live |
| 40 | tst_slide | Test Idea: A Steady Royal Source in Disney's Last 14 Days | – | targets | c/far-rare-gate-gap-2026-10-23.md | – | – | album-end-test-royal-source-2026-10-23.png | proposed |
| – | grid_slide | What the Average Paying Player Still Misses at Close | 5/7/10 missing | t4 | c/disney-stalls-missing-2026-10-23.md | same | – | album-end-missing-grid-2026-10-23.png | live |
| – | gcase_slide | One Payer's Goldens: Dice vs Disney | – | t3 | c/golden-timeline-2026-10-23.md | – | – | album-end-golden-case-2026-10-23.png | live |
| – | gtest_slide | Test Idea: Pick Your Golden, Every Day of Disney's Last 10 Days | – | targets | – | – | – | album-end-golden-test-2026-10-23.png | proposed |
| – | w144_slide | New Stickers per Day, Median Paying Player (Disney 15 lulls) | jumps +7/+6 | t4 | c/disney-stalls-missing-2026-10-23.md | same | – | album-end-daily-new-stickers-2026-10-23.png | live |
| – | v144_slide | Burst Days vs Lull Days, and Payers Who End Behind | rev/day −11%, payout +20% | t4 | c/lull-economy-disney15-2026-10-23.md | (in doc) | – | album-end-burst-vs-lull-2026-10-23.png | live |
| – | v144a/b/c | Disney 15 revenue quiet vs release days · stickers behind finishers (Disney; 3 games) | about −10% total revenue | t4 | c/disney15-windows-game-revenue-2026-10-24.md; c/gap-by-day-3games-2026-10-24.md | c/disney15_windows_game_revenue_2026-10-24.sql; c/gap_by_day_3games_2026-10-24.sql | slide_t6_story | – | live (unv) |
| end | gl1_slide | Stickers Held by Album Day: Finishers vs Payers Who End 4+ Away | Disney gap 10 at 20% of album | t4 | c/gap-by-day-3games-2026-10-24.md | c/gap_by_day_3games_2026-10-24.sql | slide_gap_lines_2026-10-24.py | – | live |
| – | – | all144 mockup (Domino 20 all payers, "p5") | – | t4 | data-story-review §Topic 4 | c/all144_steps_2026-10-23.sql | – | all144-steps-mockup-2026-10-23.html | proposed, not in deck |

## C. Topic 5: left behind (order 10-24: n0, t5b, t5a, t5c, t5d, n1, n2, n6, n5, n4, n3; r1/r2 after t5b)
All rows below: Card t5. Script slide_t5_story_2026-10-24.py (t5d also slide_t5d_end_lift.py). PNGs: album-end-<code>-2026-10-2x.png.
| Code | Title / message | Key numbers | Source doc | SQL | Status |
|---|---|---|---|---|---|
| n0_slide | Paying Players and Album Revenue by Spend Level, All Games | ~2 in 3 payers ≤$2/day (15–17% of revenue); $5+ 12–14% of payers, 63–67% of revenue | c/topic5-tiers-2026-10-23.md | c/topic5_tiers_2026-10-23.sql | live |
| h621288aadfa9fec0_0_3035 | Eden's copy of n0 (purple on 3 middle levels) | – | same | same | live |
| t5b_slide | Revenue Within 3 Stickers 4 Days Before Close, by Spend Tier | – | c/topic5-tiers-2026-10-23.md | same | live |
| t5a_slide | End Status of Payers by Spend Tier, Latest Album → requested 10-26 as Domino 19 / Domino 20 / Dice 63 (no Disney) | 4+: 90/74/53% → 64/29/21% | c/end-status-d19-d20-dice63-2026-10-26.md | c/end_status_d19_d20_dice63_2026-10-26.sql | live; rebuilt version **unv** |
| r1_slide | End Goal per Spend Level: Revenue Within 3 at Close−4 (goal = Dice 63 level) | goal = Dice 63 level per spend level | c/topic5-sensitivity-2026-10-24.md | c/topic5_sensitivity_2026-10-24.sql | live, proposal |
| r2_slide | What to Do at the End of the Album: Domino (ADOPT) and Disney (TEST) | – | same | – | live, proposal |
| t5c_slide | Direction: One End Goal per Spend Tier (revenue only) | – | c/topic5-tiers-2026-10-23.md | – | skipped |
| t5d_slide | Revenue Within 3 at Close−4 and End Lift, by Album | +9→+16%, +13→+17%, −5→+1% | c/topic5-end-lift-2026-10-24.md | c/topic5_end_lift_2026-10-24.sql | skipped |
| n1/n2/n6/n5/n4 | Within 3 vs last-4-days revenue · 6 vs 4 days · all vs by level (54/43…) · middle payers 4+ away · recommendation | – | c/topic5-sensitivity-2026-10-24.md | same | skipped |
| n3_slide | Revenue share by cut (appendix) | – | same | same | skipped, appendix |

## D. Topic 6: after the album
Card t6 unless marked. Status "live" means added; which slides Eden has skipped is **unv**.
| # | Code | Title / message | Key numbers | Source doc | SQL | Script | PNG | Status |
|---|---|---|---|---|---|---|---|---|
| 59 | s6a_slide | Spend per Day in the Week After Close vs Own Album Pace, $2–20 | 110/52, 140/49, 128/59 | c/topic6-after-album-2026-10-24.md | c/topic6_after_album_2026-10-24.sql | slide_t5_story | album-end-s6a-2026-10-24.png | **Eden-decides** (misleading) |
| 60 | s6c_slide | Finishers ~2× pace in last week, then above it; Dice lowest | 229→110, 217→140, 188→128 | c/topic6-before-after-2026-10-24.md | c/topic6_before_after_2026-10-24.sql | slide_s6_before_after | s6c.png | live |
| 61 | s6d_slide | 4+ away already at ¼–½ pace in last week; after close higher | 24–44% → 49–59% | same | same | same | s6d.png | live |
| – | s6b_slide | After the Album: One Gap per Game | 52/49/59% | c/topic6-after-album-2026-10-24.md | same | slide_t5_story | album-end-s6b-2026-10-24.png | replaced in meaning by s6c/d (unv) |
| – | t6e / t6f | Prize in days of own play (Dice ½ get 2+ days) · small-prize finishers still lowest | 1 in 4, 1 in 7 | c/topic6-finisher-prize-2026-10-24.md | c/topic6_finisher_prize_2026-10-24.sql | slide_t6_finisher_prize | t6e/t6f.png | live |
| – | t6g | >$20 1–2 short slow further in Dice/Disney | 8% (Dice) / 7% (Disney) of album revenue | c/topic6-short-payers-2026-10-24.md | c/topic6_short_payers_2026-10-24.sql | same | t6g.png | live |
| – | t6h / t6i / t6j | Payout after close and week after, by status / finishers | – | c/topic6-payout-by-status-2026-10-24.md; c/topic6-payout-prizes-by-level-2026-10-24.md | c/topic6_payout_by_status_2026-10-24.sql | slide_t6_finisher_prize; t6j_edit in slide_t6_prizes | t6h–t6j.png | live; t6j text "Dice cuts least" holds for album 63 only (C13) |
| – | t6k / t6l | Payout with prizes by spend level (finishers / 1–2 short) | −8% vs −16/−14% | c/topic6-payout-prizes-by-level-2026-10-24.md | c/topic6_payout_prizes_by_level_2026-10-24.sql | slide_t6_prizes | t6k/t6l.png | live (see C13) |
| – | tg1 | Total Game Revenue in Week After Close vs Last 30 Days | 99–102% avg | c/topic6-game-revenue-after-close-2026-10-24.md | c/topic6_game_revenue_after_close_2026-10-24.sql | slide_t6_prizes | tg1.png | live |
| – | a6s1 / a6s2 / a6s7 | Game revenue after each close · 3-album return (Dice lowest 121% vs 131/132%) · payout change by level | – | c/topic6-calendar-neutral-return-2026-10-24.md; c/topic6-payout-3albums-2026-10-24.md | c/topic6_calendar_neutral_return_2026-10-24.sql | slide_t6_story | a6s1/a6s2/a6s7.png | live (sample) |
| – | a6s3–a6s6s, a6s8f/s, a6s9, a6s10 | Prize in days of play · week-after vs usual pace by level · >$20 normal week vs after · problem/size/recommendation · 1–2 short payout | 69–76% (>$20 1–2 short) | c/topic6-normal-week-check-2026-10-24.md; c/topic6-prize-vs-spend-2026-10-24.md | c/topic6_normal_week_check_2026-10-24.sql | slide_t6_story | – | live (unv) |
| 79 | a6s8f | Finishers Over $20: Normal Week vs Week After Close | 15–19% less (59, 63; not 61) | c/dice-gt20-finishers-cz-ron-2026-10-25.md | c/dice_gt20_finishers_cz_ron_2026-10-25.sql | slide_t6_story | – | live |
| – | a6s9v | Missing 1–2, Over $20: After Close vs Normal Week; card "0.1–0.3% of album revenue" | 0.1–0.3% | c/a6s9v-gap-pct-2026-10-25.md | c/a6s9v_gap_pct_2026-10-25.sql | slide_t6_story | – | live |
| – | vipa / vipt | VIP after close (−7 to −19%) · Test in Disney: help near-finish VIP last 4 days | – | c/vip-review-2026-10-24.md (card vip) | c/vip_*_2026-10-24.sql | slide_vip_album_end | – | live / proposed |
| – | d20r1–d20r5 | Non-paying finishers 3 albums · RV views · purchases before/after · problem/size/rec · RV one view vs album | – | c/domino-rv-3albums-2026-10-24.md (card nonpayers-rv) | c/domino_rv_3albums_2026-10-24.sql | slide_t6_story | – | live |
| – | ev1 / ev2 | Post-album collection event test for Dice · evidence: Disney T113, Domino Deluxe | Dice 63 early finishers 19.3% rev | c/early-finishers-event-2026-10-24.md; c/post-album-events-2026-10-19.md | c/early_finishers_event_2026-10-24.sql | slide_early_finishers_event; slide_event_evidence | – | proposed |

## E. Topic 7: Dice prize (not reviewed)
| Code | Title / message | Key numbers | Source doc | SQL | Script | PNG | Status |
|---|---|---|---|---|---|---|---|
| t7a_slide | Same 200K prize = 5 days of play for ≤$2, 1 day for top payer | 28% ≤$2 | c/topic7-dice-prize-2026-10-25.md | c/topic7_dice_prize_2026-10-25.sql | slide_t7_dice_prize_2026-10-25.py | t7a.png | live (labels rewritten 10-24) |
| t7b_slide | Bigger prize vs own play → fewer buy next week | 55%→42% | same | same | same | t7b.png | live |
| t7c_slide | Size the prize to the player (test) | – | same | same | same | t7c.png | proposed |
| t7d / t7e / t7h | Test: 2-Day Grand Prize / 250K or 300K / Bigger Grand Prize for $2K+ | 400K–540K rolls | c/topic7-top-payers-2day-prize-2026-10-24.md | c/topic7_top_payers_2day_prize_2026-10-24.sql | slide_t6_story | – | proposed (3 variants: Eden picks) |
| t7f / t7g | 591 $2K+ 200K players followed to 59/61 · 200K tier spend vs prize | $2,000–2,800 | c/topic7-fixed-prize-spend-2026-10-24.md | c/topic7_fixed_prize_spend_v2_2026-10-24.sql | slide_t6_story | – | live |

## F. Checks and tests (10-24/25)
| Code | Title / message | Card | Source doc | SQL | Script | Status |
|---|---|---|---|---|---|---|
| d65_slide | Dice spend per payer per day, last 4 days vs days 11–5, 63 vs 65 | t1 | c/dice65-end-2026-10-24.md | c/dice65_end_2026-10-24.sql | slide_story_checks_2026-10-25.py | live |
| d65t_slide | Dice: share of active players getting Trail Chest stickers, 63 vs 65 | t1 | c/dice65-pu-trail-2026-10-25.md | c/dice65_pu_trail_2026-10-25.sql | same | live. Final weekend 65: about 11% fewer payers a day than its days 11–5. A newer copy of the doc (adds Q5) is only in worktree recursing-villani (D-W2) |
| dmix_slide | Disney ARPDAU: actual vs album 10's new/veteran share | t1/tenure | c/mix-fixed-arpdau-2026-10-25.md; c/open-checks-2026-10-24.md §B | c/mix_fixed_arpdau_2026-10-25.sql | same | live |
| dj1_slide | Disney Joker in the Last 7 Days: Today vs Two Tests | targets | c/closing-week-pct-payers-2026-10-24.md | c/closing_week_pct_payers_2026-10-24.sql | slide_t6_story | proposed |
| test_slide ×6 | Locked End Stickers (Disney) · Goldens (Disney) · Royals and the Joker (Disney) · End Goal per Spend Level · RV Limits (Domino) · Post-Album Collection Event (Dice) | targets | c/topic9-disney-test-sizes-2026-10-24.md | c/topic9_disney_test_sizes_2026-10-24.sql | slide_topic_tests_2026-10-24.py | proposed |
| t9_slide | Order: evidence from a real test first, then size; Disney end tests share players, so run them one after another | targets | same | – | same | proposed |
| – | "Avg Arpdau Whole Album" / "Avg Arpdau Last 4 Days" fixed for mix | t1 | c/mix-fixed-arpdau-2026-10-25.md | same | – | unv |

## G. Pending: merged to main (PR #28) (branch claude/albums-seen-october, 10-25) — all **unv** in the live deck
| Code / # | Change | Source doc | SQL |
|---|---|---|---|
| 11 (October copy, "slide 12") | Revenue share by albums seen, Oct 1–24 | c/albums-seen-october-2026-10-25.md | c/albums-seen-october-2026-10-25.sql |
| 16 | Arpdau lift of 7-album stayers: vs rest of album, groups pooled | c/cohort-end-lift-pooled-2026-10-25.md | c/cohort_end_lift_pooled_vs_rest_2026-10-25.sql |
| 23 / grid_slide | "What the P50 Paying Player Still Misses at Close": real median 3/4/6 | c/median-missing-at-close-2026-10-25.md | c/median_missing_at_close_2026-10-25.sql |
| 30 (h32_*) | Golden buy share rerun on Dice 65 / Domino 20 / Disney 15 | c/golden-buy-share-d65-d20-s15-2026-10-25.md | c/golden_buy_share_d65_d20_s15_2026-10-25.sql |
| d65t_slide | PU/PAU Q5: 63 +7%, 65 −8% | c/dice65-pu-trail-2026-10-25.md (branch copy) | c/dice65_pu_trail_2026-10-25.sql (branch copy) |
Also merged 10-26 for topic 6 slides a6s8s / a6s10 / vipa: Domino 19/20 >$20 and VIP after close (c/domino-after-close-20plus-vip-2026-10-26.md); whether a slide uses it is **unv**.

## H. Domino 19 copies under cross-game slides (10-27/28, Eden: "add, don't delete; Domino 19 alone under the relevant slide") — live deck 1bVGI1Sb…
| # | Code | Title / message | Key numbers | Card | Source doc | SQL | Script | PNG | Status |
|---|---|---|---|---|---|---|---|---|---|
| 23 | g19_slide (under grid) | What the average payer still misses, Domino 19 | – | domino-dx | c/domino-end-rares-jokers-19v20-2026-10-27.md | – | c/slide_domino19_copies_2026-10-27.py | – | live |
| 31 | a19c_slide (under a144) | Stickers collected, Domino 19; gold box day 31→close "+17, ~1 a day" | 121 by day 30 (~4/day); bottom "After day 30 the pace drops to a quarter" | domino-dx | c/domino-19v20-daily-pauses-2026-10-28.md | c/domino_19v20_daily_pauses_2026-10-26.sql | c/slide_domino19_copies_2026-10-27.py | – | live |
| 32 | m19_slide | Stickers Still Missing, Album 19 vs 20 (day 20→close) | even to day 33; day 38: 16 vs 10; close 6 vs 4 | domino-dx | c/domino-19v20-daily-pauses-2026-10-28.md | c/domino_19v20_daily_pauses_2026-10-26.sql | c/slide_domino19_missing_2026-10-28.py | – | live |
| 34 | w19_slide (under w144) | New stickers per day, Domino 19 (median of the day → 0 from day 31; see m19) | – | domino-dx | c/domino-19v20-daily-pauses-2026-10-26.md | same | c/slide_domino19_copies_2026-10-27.py | – | live |
| 36 | gl19_slide (under gl1) | Finishers vs 4+ away, Domino 19 | finishers 4%, 4+ away 83% | domino-dx | – | – | c/slide_domino19_copies_2026-10-27.py | – | live |
| 40 | g19s_slide (under g32) | Goldens collected, Domino 19 | median missing 6 (3 G + 3 R) | domino-dx | c/golden-timeline-2026-10-23.md | – | c/slide_domino19_copies_2026-10-27.py | – | live |
| 42 | sg1_slide (under …_2399) | % of Goldens by % of album time, single albums Dice 63 / Domino 20 / Disney 15 | close 93% / Hard 94%, Easy 89% / 83%; original's 82% = Easy avg 17/19/20 | t3 | c/domino-19-golden-buy-2026-10-28.md | c/goldens_decile_d63_s15_2026-10-28.sql | c/slide_goldens_single_albums_2026-10-28.py | – | live |
| 43 | ge19_slide | Goldens Easy/Hard, Domino 19 | Easy 83% vs Hard 89% | domino-dx | c/domino-easy-goldens-progression-2026-10-26.md | c/domino_easy_goldens_progression_2026-10-26.sql | c/slide_domino19_copies_2026-10-27.py | – | live |
| 46 | gb19_slide (under …_2520) | Share of active payers who bought a new Golden, Domino 19 | peaks d−8 5.4%, d−3 6.3%; last day 2.3% | domino-dx | c/domino-19-golden-buy-2026-10-28.md | c/golden_buy_share_d65_d20_s15_2026-10-25.sql (album 19) | c/slide_domino19_goldbuy_2026-10-28.py | – | live |
| – | r19s_slide (under …_2005) | Rare step, Domino 19 | longest wait all 4% / Goldens 10% / Royals 26% | domino-dx | c/rare-timeline-2026-10-20.md | – | c/slide_domino19_copies_2026-10-27.py | – | live |
| – | wh19_slide (under …_2189) | When did payers finish, Domino 19 | 1–3 at c−4: 39% finished; 20/27/37/16% | domino-dx | – | – | c/slide_domino19_copies_2026-10-27.py | – | live |
| – | n19_slide (under near7) | Revenue share within 3, Domino 19 | 20% d−7 → 52% d−1 | domino-dx | – | – | c/slide_domino19_copies_2026-10-27.py | – | live |
| ~123 | dlw_slide (after Eden's slide_ne9t… weekday slide) | Revenue per Active Payer vs a Normal Weekday, Last 14 Days: Domino 17–20 | last 4 days +20% (18) / +11% (20) / +4% (17, 19); 18 = July 4 sale | domino-dx | c/domino-end-arpdau-weekday-17-20-2026-10-28.md | c/domino_end_arpdau_weekday_17_20_2026-10-28.sql | c/slide_domino_end_lift_weekday_2026-10-28.py | – | live |
| ~124 | nfu_slide (after dlw_slide) | Payers Missing 1–3 Stickers 4 Days Before Close: Domino 17–20 | % payers / % album rev: 17 11/28, 19 4/26, 18 20/37, 20 22/46 | domino-dx | c/domino-near-fu-c4-17-20-2026-10-28.md | c/domino_near_fu_c4_17_20_2026-10-28.sql | c/slide_domino_near_fu_17_20_2026-10-28.py | – | live |
| ~121 | gw_slide (after dxgold) | Players Who Got a New Golden per Day, Any Source, Last 10 Days: Domino 19 vs 20 | peak 19: 48% d−7; 20: 44% d−4; last 4 days 34% vs 27% a day | domino-dx | c/domino-19v20-golden-sources-by-day-2026-10-28.md | (queries in the doc) | c/slide_domino_golden_wave_19v20_2026-10-28.py | – | live |
| ~122 | gsrc_slide (after gw_slide) | Where New Goldens Came From, per Day, Last 10 Days: Domino 19 vs 20 | 20: Kiosk 11–24% (d−7..−5), ColoringBook 13–36% (d−6..−3); paid 2–6% both | domino-dx | c/domino-19v20-golden-sources-by-day-2026-10-28.md | (query in doc) | c/slide_domino_golden_sources_19v20_2026-10-28.py | – | live |
| ~120 | wv_slide (before gw_slide) | New Stickers per Active Payer per Day, Last 20 Days: Domino 19 vs 20 | wave 1 d−15..−12 +5 a payer; wave 2 d−6..−4 +2 | domino-dx | c/domino-sources-d20-d11-19v20-2026-10-28.md | c/domino_sources_d20_d11_19v20_2026-10-28.sql | c/slide_domino_two_waves_19v20_2026-10-28.py | – | live |
