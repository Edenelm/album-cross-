START HERE (updated 2026-10-15): this prompt is superseded as an entry point. Read claude/INDEX.md first, then claude/album-analysis-v4-2026-10-15.md, claude/decisions-definitions-register.md and claude/claims-register.md. The notes below (2026-10-14/15) are kept for history; where they conflict with the registers, the registers win (e.g. presentation rule changed from "average of two albums" to whole numbers with ranges; Domino gate is by level: hard 2 Royals + Golden, easy 2 Royals + 3 Goldens; Eden confirmed no scheduled Royal source in Disney days 14–8).

--- Original prompt (kept for history) ---
Continue the ALBUM SEGMENTATION / END-OF-ALBUM thread (Eden, Superplay cross-studio, for the CRO).

Read first from the project (newest first):
- claude/middle-payers-stall-2026-10-15.md (LATEST: where the money ending far sits — middle payers P50–95; Wild timing; last-14-days windows EndWin; SQL inside)
- claude/weak-stall-supply-demand-2026-10-15.md (weak players: stall day, by sticker type, Dice comparison)
- claude/end-state-by-tier-cross-game-2026-10-15.md (end state by tier + RELATIVE percentile definition check)
- claude/segmentation-recommendations-2026-10-15.md (recommendation per game; 5-group structure 0 / ≤2 / 2–5 / 5–20 / >20)
- claude/dice-q4-tier-evidence-2026-10-15.md, claude/two-vs-three-missing-disney-2026-10-15.md, claude/royal-sources-layer-mapping-2026-10-15.md (background)

Where we are (2026-10-15):
- Relative groups (percentile of spend so far at last-quarter start among payers: weak P0–50, middle P50–95, strong P95+) land on nearly the same $/day in all 3 games (weak ≤ ~$0.8/day, strong ≥ ~$11/day).
- Share of ALBUM revenue held by players ending at 4+ missing: Disney ~43%, Domino ~35%, Dice ~24%; the middle group holds most of it (Disney ~28%, Domino ~22%, Dice ~15%). Weak only 2.5–5%.
- Far-off players (4+) behave alike in all games: ~11 missing, keep collecting into the last quarter, mostly active, low spend at the end.
- Wild (Eden): sold from ~7 days before close in Dice/Domino, only ~3–4 days in Disney. Far-off players barely use Wild in any game (2–9 Wild stickers per 100 players in last 4 days); near-finishers (1–3) do (Disney 23, Domino 92, Dice 40 per 100). → Earlier Wild in Disney is a near-finisher test, not a lever for the 4+ pool.
- Disney-specific dip in new Royals 10–8 days before close (15 per 100 middle 4+ players vs ~40 in Domino/Dice).
- Missing: paid vs free Royal split — mtx campaign name is on almost all gate stickers, not usable as paid flag.

Open / possible next steps (none approved yet):
- Lever for the 4+ middle pool before the last week (mid-album pace, Disney Royal dip 10–8 days) — define what to test.
- Disney Wild-earlier A/B design (near-finishers; does it add spend or shift timing).
- Find a real paid/free flag for sticker sources.
- Disney goal option (A uniform +10 / B ladder 30-45-60-80 / C goals only 5–20 and >20); Domino team answers (easy/hard, −9999); Disney revenue currency check.

Standing rules:
- Presentation: show the AVERAGE of the two albums in tables (one number per cell); flag in text only when albums differ a lot. Revenue share, not player share. [superseded 2026-10-15: whole numbers, ranges when albums differ]
- Bifrost BigQuery, multi-project lock dice-dreams-dbt / domino-dreams-dbt / solitaire-dreams-411507; pass project= on every call (re-lock this set if the lock drops). Disney: solitaire-dreams-411507.bi_prod.user_daily_album (excluded from bi_prod.user_profile; activity active_flag; stickers bi_entity_prod.dim_user_album_stickers). Domino: domino-dreams-dbt.prod_40_mart.user_daily_album (cheaters from prod_40_mart.user_daily_metrics; stickers prod_30_intermediate.int_user_album_stickers). Dice: dice-dreams-dbt.50_reporting.user_daily_album (is_excluded, is_active; stickers 30_intermediate.fact_user_album_stickers). Albums: Disney 14/15, Domino 19/20, Dice 61/63.
- Default: show query + tables/filters and get approval before running; dry-run first. Eden may say "just run" for a specific step — then run and show the query in the doc.
- Population: not-first-album, login ratio ≥ 0.5 on last row before close, close day excluded.
- Label Known / Needs Validation / Missing / Hypothesis. No causal claims → propose A/B.
- Thresholds, tier cuts and goals are a management decision — present options, never force.
- Answer in concise Hebrew WITHOUT English words in the prose; code blocks fine. Use "רויאל" for Royal.

