============================================================

Memory

Album Sticker Analytics
Delete
Last updated
Oct 15, 2026
Summary

Eden's cross-studio album analysis project — comparing album performance across Dice Dreams, Domino and Disney for the CRO

Details
Building a cross-studio album comparison analysis (Dice Dreams album as the base) to help the CRO grow revenue
For any Dice Dreams album question, always go to the dbt tables, and grill her (grill-me style) before proceeding
"Superplay HQ" = BigQuery project headquarters-dbt; Dice Dreams album dbt data is found under it in dice-dreams-dbt
The dice-dreams BI prod BigQuery project isn't reachable via MCP — for that project, Claude writes the queries and she runs them herself
In album report tables (scorecard, last 7 days, sticker bins), always show a payers (PU) view alongside all players
Cross-game benchmark (13-topic framework; full results in project doc claude/cross-game-comparison-framework.md)
Working rules: one topic at a time; ask one question at a time and get approval before running; state tables + filters; show PU next to all players; label Known / Needs Validation / Missing / Hypothesis; no causal claims (propose A/B test); recs = Adopt / Test / Do Not Adopt Yet
Don't connect between topics now; think about cross-topic dependencies only after all topics are done
Benchmark albums: Dice 61/63, Domino 17/19 (18 excluded, 168 stickers), Disney 14/15
ARPDAU = total album revenue ÷ active player-days from a daily table; daily-average ARPDAU is QA only; ARPPU = revenue ÷ distinct payers; use "revenue per paying day" not ARPPU for daily
Album-end metric: "ARPDAU during the last four full album days versus whole-album ARPDAU" — end = close−4…close−1, close date excluded (partial) in all games; close-inclusive only as QA; compare same calendar album × same cohort
Rare-sticker progression belongs to Topic 4, not Topic 3; metric name "Equivalent album-days per unique rare collected" is a summary ratio, never say "a new rare every X days"
Rare collection % = unique rares ÷ total rares in album (not all stickers); album size = set stickers only (144 in all three games; 144 unique = album complete; Dice Pixie and Disney Magic excluded)
Topic 4 view: show only PU + login ratio ≥ 0.5 + median (P50)
asked to remember: session of 2026-10-07 covered Topics 1, 2 (+album-end ARPDAU follow-up) and Topic 4 rare totals/progression; Topic 3 not started — session log in project doc claude/session-log-2026-10-07.md
Cohort rule for album-experience cohorts (1, 2–3, 4–6, 7+): must be based on the player's true first album, and only over the last ~18 months (installs from 2025-04-01) in all three games, for a fair comparison; players installed earlier are excluded, not placed in a cohort
Working on Dice Dreams album Supers: goal is to show whether adding more Supers to the album has business impact (cross-game comparison alone isn't causal proof; needs Dice mechanism evidence, then an A/B test)
Game-feature glossary (as Eden defines them)
Disney Magical Friend ("mf") = like Pets in Dice; Pets / Pixie / Magical Friend are not permanent — they are longer-running features (seasons)
Momentum (Disney & Domino) = central layer that recurs every day, hard to complete, meant to push heavy timed play toward the top tier; few players finish it
Dice "2Day_Trail" = recurring MTX campaign event, not daily (like Dice's 2–3 day Blast)
Domino pixie_reward = from the Pixie feature (likely a Royal given for completing the Pixie)
Disney Market / marketplace = central end-of-album event that gives the Wild
Source classification rule: anything not bought with money = "gameplay", anything bought = "purchase"; the Market is gameplay (tokens are earned by playing or bought, the Royal itself isn't bought); event rewards like the Dice Trail are gameplay even when hard
Disney Sugar Rush (source 'enough DR') = on-top monetization event, runs once to a few times a week — not always-on like Dice Trail
Momentum: the Royal, when present, is in the last tier; Momentum runs most days but not every day includes a Royal
Domino end-of-album locked gate depends on difficulty: Hard = 2 Royals + 1 Golden; Easy = 2 Royals + 3 Goldens
Dice blank sticker_source ('' not NULL, no campaign) = Puzzle Collection / Merge Collection; identify via sticker_pack_key prefix: HGP_* = high tiers, GP_* = last tier
Status (asked to save, 2026-10-13)
asked to remember: Topic 5 (rare sources by album quarter) is nearly done — mapping v2 + cross-game chart built; full state, open items and next steps in project doc claude/session-log-2026-10-13.md; continue in next chat
Domino 'First_Royal_Gift' = first-album gift → "Daily / free gift"; cross-game populations exclude players in their first album
Event groups: Promo / Mini game / PB / MTX challenge / Quest / Other; Disney fully mapped, Dice PropChase_Hunt (Parallel Quest) = Quest — detail in project doc claude/topic5-5e-other-events-2026-10-13.md (5f/5g)
asked to remember: she will ask the Domino team how to classify the unmapped Domino sources (Puzzle, PiñataParty/Pinata, StepByStamp, Event, Empty, RoadToGlory, Battleship*, toxiclove*, Duel/Pet/OceanTreasure/Twister/Wheel) and confirm proposals (Challenge→PB, Blast→MTX challenge, Minicollection→Mini game, conveyor_belt→Other, Quest→Quest) — list in 5e doc section 5g
Benchmark deck is for all three studios (not only the CRO): each studio gets its own findings and recommendations — sometimes a fact only, no recommendation; she wants minimal text, many charts, focused conclusions
Deck design: use the SuperPlay Design System in Claude Design (claude.ai/design project e8071672-e410-4b5a-9f6b-505c10193d89)
Wants to adopt the Dice player-segmentation method (difficulty + live spend-pace tier → end-of-album revenue-share targets) for Domino and Disney, which have no such segmentation today (they do end-of-album injections, but with no defined method); validation of the Dice method in project doc claude/dice-segmentation-validation-2026-10-14.md; starting with Disney; pre-album level based on spend only; thresholds are a practical management decision, not a copy of Dice's distribution (Disney build in claude/disney-segmentation-build-2026-10-14.md)


============================================================

Memory

Album Tracking Assets
Delete
Last updated
Oct 7, 2026
Summary

Standard per-album tracking assets — Looker dashboards (pace, sets, potion, magic set), Mixpanel boards, agenda deck and injection sheet

Details

Example links are filtered to Album ID=15; change Album ID / date / campaign filters per album.

Looker (superplay.cloud.looker.com/dashboards/<id>)
1862 — main album pace tracking (filters: Album ID, Special User Flag=No, Login Ratio 0.5–1, Is Finisher Yes/No, date from album start)
1847 — set progression tracking (filters: Album ID, date=yesterday, Sticker Count for FU, Login Ratio 0.5–1, Special User Flag=No)
2259 — potion tracking (filters: Album ID, Special User Flag=No, date from potion start)
2158 — Magic Set tracking, filtered by MTX campaign name (format e.g. t_Album|st_MagicSets|n_MagicSet(BacktoSchool)|ds_20260831|de_20260907)
Mixpanel
Whole-album monitoring: https://mixpanel.com/s/16TSdt
Magic Set: https://mixpanel.com/s/3ku9xM
Potion: https://mixpanel.com/s/1QGaZS
Legendary Set (extra 12-sticker set that runs at album end for finishers): https://mixpanel.com/s/2lU5eq
Blocked-stickers leak check (mainly Eden's own board): per each album's blocked-stickers table, monitored during the album until the blocked stickers open, to confirm no leaks: https://mixpanel.com/s/hQ5NM
Per-album documents (made fresh for every album)
Agenda deck per album — latest example: https://docs.google.com/presentation/d/1hCSY1zSmlrn02ket4CL25EBwECy1cF-FW_zrHunMWLI
Injection tracking sheet per album (when and which sets are injected) — latest example: https://docs.google.com/spreadsheets/d/16tx3o1VVdY-NAGk-HA7ADajo99pjIG6WFvBuFYPZXTk


============================================================

Memory

Preferences
Delete
Last updated
Oct 17, 2026
Summary

How Eden wants results presented in the cross-studio album analysis project

Details
In the album analysis, show the average of the two compared albums throughout (one number), instead of listing each album separately
For the album analysis presentation, keep the breadth: build it as several chapters by domain (question, finding, interpretation, meaning), not limited to three insights or one forced story; connect findings only where supported
Open the analysis with a baseline-facts chapter (player tenure, album length, first album exposure, etc.) to align everyone before the findings
Don't drop findings to shorten the presentation; before removing a finding, say what you propose to remove and why
Call the end-of-album pick mechanic "Joker" or "Wild" (not a generic word like "בחירה")
Before any new check or information request in the album project, look first in the project index (claude/INDEX.md) and existing materials, and reuse prior work
When running the album analysis, use more charts; keep the chart data saved (or the charts themselves) so they can be rebuilt


============================================================

Memory

Dice Album Segmentation
Delete
Last updated
Oct 14, 2026
Summary

How Dice Dreams album users are segmented — album segment (difficulty), album reward tier, live super segment; thresholds, formulas, known issues. Read for any Dice album segment/reward/super-segment question.

Details
Dice Dreams album user segmentation (asked to remember, 2026-10-07; full doc in project: reference/dice_album_user_segmentation.md)
Every Dice album user has 3 labels: album segment (difficulty, set once at album start), album reward (completion prize tier, set once at start), super segment (live spend pace, recalculated daily).
Album segment: last album PLAYED (≥1 sticker, not necessarily previous album) spend normalized to 70 days = total_spent_in_album × 70 / (album_number_of_days − 1). 1 Easy < $100; 2 Medium $100–<400; 3 Hard $400–<1,000; 4 Extreme ≥ $1,000. No album history → Easy.
Album reward 1–7 (25K/40K/65K/100K/125K/150K/200K rolls). Ladder starts from highest reward code ever; moves up 1 step if last album finished OR adjusted spend ≥ bar (1→$75, 2→$150, 3–6→$700; 7 = top). Floor from max rolls received (fact_user_max_rolls_recieved): ≥150K→7, ≥125K→6, ≥100K→5, ≥65K→4, ≥40K→3, ≥25K→2, else 1. Final = higher of ladder and floor. Rewards only ratchet up (inflate over time).
Super segment codes 0,1,2,3,5 (no 4): current-album spend vs expected pace. x = days_since_album_start × 77/42; per-segment spend curve (Easy/Medium quartic, Hard=Extreme cubic, ≈1.0 at x=77); threshold = curve(x) × budget × 42/77. Budgets SS0/SS1/SS2/SS3: Easy 100/300/600/1000; Medium 200/400/700/1200; Hard 400/700/1000/2000; Extreme 700/1500/2500/6000. Thresholds rise daily, so non-spenders drift down. album_super_segment_code stored once per day (can lag).
Known issues: three length bases (70 / 77 / 42 days) not aligned; hardcoded start date and 42 in super-segment query; current_album = max album_id (breaks if next album preloaded); model_output_ss5 is really SS3 ceiling; no is_excluded filter; total_spent_in_album vs total_spent_in_album_until_this_date can disagree; CURRENT_DATE is UTC (use yesterday); segment/reward query scans full ~1 TB table (use 30_intermediate.album_pop); rolls table lives in dice-dreams.ba_prod (outside dice-dreams-dbt).
The super-segment query is used in the last quarter of each album; its start date and album length are updated every album (not left at 42; e.g. album 61 = 35, 63 = 42). The team uses the query's output for the tier, not the stored album_super_segment_code column.
Purpose of the super segment: end-of-album targets — bring players to ≤3 missing stickers (e.g. 10 Supers by close−4), with a different target share per difficulty × tier (low for Easy tier 0, high for Extreme tier 5; exact numbers not given). Target shares are measured as revenue share (revenue from album start to the measurement day), not share of players.
Between-albums checklist: refresh fact_user_max_rolls_recieved; set album_id <= ended album in segment/reward query; update album start date and day count in super-segment query.
Tables: dice-dreams-dbt.50_reporting.user_daily_album, 20_core.dim_album_season, 30_intermediate.album_pop, dice-dreams.ba_prod.fact_user_max_rolls_recieved. Key columns: album_segment_code, album_super_segment_code, album_reward_code, total_spent_in_album(_until_this_date), is_album_finisher, album_number_of_days, is_excluded.


