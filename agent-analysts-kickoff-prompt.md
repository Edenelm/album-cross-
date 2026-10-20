# Kickoff prompt — Multi-agent album analysts (paste into a NEW chat in this project)

Use a workflow with sub-agents. The sub-agents are the analysts: each one reads the project, takes the tables, decides its own analysis, finds differences between the games, insights, and what could be improved in each album. You (the main chat) are the lead: you brief them, collect results, challenge them, and give me one synthesis.

## Context to read first (every agent)
Project docs: claude/session-log-2026-10-13.md, claude/album-benchmark-deck-content-pack-2026-10-13.md (all findings so far), claude/cross-game-comparison-framework.md (13-topic plan + Topics 1, 2, 4), claude/album-analysis-pack-2026-10-08.md, claude/dice-supers-mechanism-onepager-2026-10-12.md, claude/topic5-conclusions-2026-10-13.md, claude/topic5-5e-other-events-2026-10-13.md, plus the game references: reference/dice_album_knowledge_base.md, domino album onboarding.md, claude/disney-album-context.md, album_knowledge_base (2).md. SQL that already works: claude/album_benchmark_queries.sql, claude/topic5_rare_sources_queries.sql, claude/dice_supers_mechanism_queries.sql.
Do not redo what is already done unless you find it wrong — build on it.

## Data access (BigQuery via Bifrost MCP)
- Multi-project lock: dice-dreams-dbt, domino-dreams-dbt, solitaire-dreams-411507. Pass project= on every call.
- Key tables — Dice: 50_reporting.user_daily_album, 30_intermediate.fact_user_album_stickers, 30_intermediate.fact_user_daily_set_progression, 20_core.purchase_completed_vw. Domino: prod_40_mart.user_daily_album, prod_40_mart.user_daily_metrics, prod_30_intermediate.int_user_album_stickers. Disney: bi_prod.user_daily_album, bi_prod.user_profile, bi_entity_prod.dim_user_album_stickers (dedupe per user × sticker — album 14 has duplicates).
- Curated layers only (50→40→30→20). Ask me before any 10_staging / raw dataset.
- Every query: dry_run first; read-only; partition filter; ≤ 100 GB per query without asking me (assumption — change if you want stricter). Keep every SQL you run in the agent's output.

## Standing rules (all agents)
- Benchmark albums: Dice 61/63 (12 Supers), Domino 17/19 (8/9 Royals), Disney 14/15 (7 Royals). 144 set stickers each. Rare = Super / Royal.
- Population default: payers (PU) next to all players; login ratio (last row before close) ≥ 0.5; close day excluded (partial); rare work = players NOT in their first album (Dice user_past_album_count > 0; Domino/Disney user_album_count > 1). Cohort work: installs since 2025-04-01.
- ARPDAU = total revenue ÷ active player-days (summed, then divided). Revenue = game revenue on album days.
- Label every claim: Known / Needs Validation / Missing / Hypothesis. No causal claims — a lever = proposed A/B test (primary metric + guardrails).
- Statuses per item: Adopt / Test / Do Not Adopt Yet / Fact only.
- Event groups (Eden): Promo / Mini game / PB / MTX challenge / Quest / Other; Trail stays separate in Dice and Domino; Domino grouping partly pending (see 5g).

## Agents
1. **Dice analyst** — owns Dice 61/63. Goal: what limits payers and monetization in the Dice album; what to improve.
2. **Domino analyst** — owns Domino 17/19. Same goal. Open: are Royals the final completion gate (as Supers in Dice)?
3. **Disney analyst** — owns Disney 14/15. Same goal. Open: why the album-end lift is flat; are Royals release-gated.
4. **Cross-game analyst** — compares the three on the same metrics (pace, gates, end-of-album, sources, finishers, near-finishers, duplicates, rewards); finds the 3–5 biggest structural differences and what each game could borrow.
5. **Critic / validator** (runs after 1–4) — checks every claim: right population, right denominator, close day excluded, no causal wording, sample size, confounders (album pace, economy, tenure). Re-runs the 3 most important numbers. Downgrades labels where needed.

Each analyst chooses its own analyses (suggested areas, not limits: near-finishers and what blocks them, time spent stuck, duplicates and dup-exchange value, finishers' last stickers, early finishers' spend after finishing, packs per payer-day, release timing of rares/locked stickers, end-of-album behaviour, segment differences).

## Output per analyst (max 1 page each)
- Top 5 insights (one line each, with the number, label, population).
- What to improve in this album: 3 items, each = mechanic → evidence → proposed A/B (primary + guardrails) or "Fact only".
- 1–2 charts (data table + chart type) for the deck.
- Open questions for the studio team.
- SQL used (appendix).

## Lead synthesis (to me, in Hebrew, concise)
1. Per studio: findings, recommendations / tests / facts.
2. Cross-game: biggest differences + what each studio can learn.
3. What the critic changed or rejected.
4. Save to the project: claude/agent-analysis-<date>.md (full) and update claude/session-log-<date>.md.

