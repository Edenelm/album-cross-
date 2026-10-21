# Handoff prompt — album cross-studio analysis (2026-10-21)

Continue the cross-studio album analysis (Dice Dreams, Domino Dreams, Disney Solitaire). Chat in Hebrew, deck text in simple English. Read `CLAUDE.md` first, then this file.

## Where things stand
- Live deck: https://claude.ai/artifact/6UUb91x2vHULkaM4g73uQr, version 82, 96 slides. Read and publish it with the Artifact tool (`project/deck.json` + `project/slides/<id>.html`). Re-read it before every publish.
- Code: branch `claude/album-analysis-payout-692f62`, pushed. PR https://github.com/Edenelm/album-cross-/pull/2 is open against `main` and not merged yet.
- Storyline v4 (`claude/storyline-v4-2026-10-20.md`):
  - Opening: summary, chapter map, how to read.
  - Ch1: the three games side by side (structure, revenue mix by album experience, end ARPDAU by experience, end growth).
  - Ch2: who is where at the end, by daily spend.
  - Ch3: where rares come from.
  - Ch4: how the album gets closed (incl. Domino RV).
  - Ch5: those left behind.
  - Ch6: after the album.
  - Ch7: three game cases.
  - Ch8: what each game should do (rec-disney / rec-domino / rec-dice, tests, targets).
  - Then the method section (now "Targets per Spend Group: Not Decided"), the appendix and the rejected questions.
- Every analytical slide ends with three lines: **Finding / Why it matters / Action**. Descriptive slides have no Action line. The title is the takeaway. Earlier lines are kept in the slide notes. Per-slide lines are in `claude/deck-review-actions-2026-10-21.md`.

## Decisions made 2026-10-20/21 (also in `decisions-definitions-register.md`)
- **Revenue-share denominator for the whole deck:** total game purchase revenue during the album. Window: start..close−1, all players, cheaters / test excluded. RV revenue is shown separately. Factors from the old standard-population basis: Dice 0.67–0.69, Domino 0.77–0.79, Disney 0.78–0.81 (`claude/opening-facts-2026-10-20.md`).
- **Finisher revenue goal, restated on this basis:** 20% (Dice), 23% (Domino), 24% (Disney) = 30% on the old basis. Today: 19 / 23 / 17%.
- **Album experience buckets:** 1 / 2–3 / 4–6 / 7+, counted as the player's own album number, not the album ID.
- **Seasons:** show 2–3 seasons only when the difference matters. Otherwise use the average or the latest album, and label which.
- **End gate:** all three games lock 3 stickers to the end by design, as Dice does (Eden).
- **Finish targets per payment group are NOT decided.** The method slides are options only: weighting by revenue, one multiplier per game.
- **Overlaps:** 9 slides moved to the appendix, `groups` moved to the method section, and tenure / payout / per-game deleted (`claude/deck-overlaps-2026-10-20.md`). `next-album` is also in the appendix now.

## Open — start here
1. Eden is reviewing v82. Wait for her comments before changing slides.
2. **Per-group finish targets.** What a decision would need: evidence that a higher finish rate in a group adds revenue. Today we only have "finishing does not use up a payer" (no control). Show options; do not set targets.
3. **Disney test 1 precondition.** Can a Joker pick Royal 131 before it is released? Owner: the Disney team.
4. **Other open checks** (`open-checks` slide):
   - Are Disney Market tokens bought or earned?
   - Paid vs free for most rare sources.
   - Possible automated RV viewing in Domino (~93 views a day).
   - The Dice event calendar and who is eligible for the Trail final reward (`claude/dice-wild-sources-2026-10-21.md`).
5. **Exact rebases on game revenue: DONE 2026-10-21** (`claude/game-revenue-rebase-2026-10-21.md`): weighting 4 / 14 / 14 / 26 / 18% (3-game average), staircase finished 19 / 22 / 17% and 1 / 2 missing 5 / 5 / 6% and 10 / 8 / 8%, heavy-missers unchanged. The slide notes (weighting, groups, staircase, heavy-missers) are NOT yet updated: apply after Eden's v82 review.
6. `INDEX.md` is not yet updated with the docs from 2026-10-20/21.
7. `seg-return` shows differences in "pts". Eden's rule is to give differences in %. Fix it if she asks.

## End of the 2026-10-21 Claude Code session (evening) — START HERE in the next session
Eden stopped the session: the new decision deck is NOT good yet. Facts:
- New decision deck (separate from v82): https://claude.ai/artifact/F1nbGMJptGsz2LW96TQ2jf (version 6, 22 slides, Slides artifact type; files `project/deck.json` + `project/slides/<id>.html`; design system record SuperPlay Design Language + the three game logos copied from v82 under `project/ds/superplay/assets/games/`). Local copy of every slide file: this worktree's scratchpad `newdeck/project/` (may be gone; re-read from the artifact).
- Slide order: cover, story, money, targets, disney-diag, disney-what, disney-test1, disney-dont, domino-diag, domino-what, domino-rv, domino-dont, dice-diag, dice-what, dice-prize, dice-dont, groups-curve, tests, measure, open, closing, appendix. Content = `claude/final-deck-bottom-lines-2026-10-21.md` (approved) + the Domino easy-gate result + the VIP idea (open slide).
- **Eden's verdict: too much text; she wants far more visuals.** Three slides were redone as a visual direction (money = stacked bars by end status; disney-what = levers on an album timeline; groups-curve = line chart by strength decile). Two of them shipped with overlapping pinned text (fixed in v5/v6), and Eden still said 'not good'. The other 19 slides are still text tables / cards.
- Lessons for the rebuild: (1) one visual per slide, title + one line, everything else in the notes; (2) prefer flow layout (flex rows/columns) over position:absolute; when pinning, compute boxes and keep labels in separate bands; (3) the built-in browser is not signed in to claude.ai, so rendering cannot be screenshot-checked from Claude Code — ask Eden to look, or build fewer slides per round; (4) the dataviz skill was loaded; node is not installed, so the palette validator did not run (colours: Dice #6FA3FF, Domino #F5A04A, Disney #3CC8B4, gold #FFDF85, red #FF0B47, blue #4285F4).
- Data work done this session, all documented: game-revenue rebase (exact), strength-percentile curve, open checks (RV / Trail / paid-vs-free), Domino easy-gate end status (`claude/domino-easy-gate-end-2026-10-21.md` + `domino_easy_gate_end.sql`, NOT yet committed), final-deck bottom lines (approved).
- Uncommitted in this worktree when the session ended: `claude/domino-easy-gate-end-2026-10-21.md`, `claude/domino_easy_gate_end.sql`, this handoff update. Commit with Eden's OK (branch `claude/album-analysis-continue-084dc7`, PR #3 open).
- Open for Eden: finish targets per group (not decided); the Domino team question (easy gate in album 20); the Disney team questions (Joker vs Royal 131; Market tokens); commit approval.

## Progress, second session 2026-10-21 (Claude Code)
- Item 2 (per-group targets): options and the missing evidence written in `claude/group-targets-options-2026-10-21.md` (options A–E; what a decision needs = revenue per player by spend group, proposed as a per-group readout of test 1). No targets set. Deck not touched (item 1: Eden is reviewing v82).
- Item 6: `INDEX.md` updated with every doc from 2026-10-20/21, deck v82, the game-revenue denominator and the open checks.
- Item 5 (exact rebases): DONE later the same day. `claude/game_revenue_rebase_queries.sql` + `claude/game-revenue-rebase-2026-10-21.md` + raw CSVs in `claude/results/`. Dice was run by Eden in the BigQuery console while the BIFROST server was down; Domino and Disney ran through the MCP once it came back. All checks against opening-facts and finisher-recount passed. Domino 17 game purchase revenue = $17,388,298 (new).
- Item 4 (data checks: automated RV viewing in Domino, Dice event calendar, paid vs free rare sources): NOT run (server outage for most of the session).
- Item 2 (per-group targets), second pass 2026-10-21: finish rate by payer strength percentile (`claude/strength-percentile-2026-10-21.md`): p95 ≈ $12–13 a day in all three games; above p95 finish 25–42%, below 4–11%; the 10% goal is a goal for the 95% below p95; curve is smooth. Still not decided.
- Item 4 (open checks): DONE where data can answer (`claude/open-checks-2026-10-21.md`): Domino RV = manual ad farming, no impossible cadence; Dice Trail = 39 back-to-back campaigns, Wild given below the top tier (tier = config, Dice team); paid vs free = question list for the studios; Disney Market tokens still with the Disney team.
- Final deck: bottom lines approved by Eden 2026-10-21 (`claude/final-deck-bottom-lines-2026-10-21.md`); a NEW deck, separate from v82, is being built.
- Eden's new questions 2026-10-21: (a) Domino easy segment must collect 3 goldens + 2 royals at the gate vs hard 2 royals + 1 golden; her claim: bringing an easy player to 5 missing is a weak 'near the end' feeling; wants data on revenue share left far behind in albums 19/20 by segment. (b) Dice has a VIP population, Disney has none: idea to differentiate Disney top payers (different art) — last priority.
- The handoff commit 3698e2c sits on `claude/album-analysis-payout-692f62` (after the PR #2 merge); it was copied into this worktree as uncommitted changes (CLAUDE.md pointer + this file). Merge or cherry-pick it with Eden's OK.

## Docs from 2026-10-20/21 (`claude/`)
- `payout-mixpanel-def-2026-10-20.md` + `payout_mixpanel_def_queries.sql`
- `opening-facts-2026-10-20.md` + `opening_facts_queries.sql`
- `domino-rv-rewards-2026-10-20.md` + `domino_rv_rewards_queries.sql`
- `storyline-v4-2026-10-20.md`
- `deck-overlaps-2026-10-20.md`
- `deck-review-actions-2026-10-21.md`
- `dice-wild-sources-2026-10-21.md` + `dice_wild_sources_closing_week.sql`

## Working rules (unchanged)
- **BigQuery:** dice-dreams-dbt / domino-dreams-dbt / solitaire-dreams-411507, tables written fully qualified. Dry-run first. Save every query in `claude/*.sql` next to a results doc.
- **Definitions:** finisher = 144 by the end of the close day. Payer = paid on any album day, close day included. Standard population.
- **Reporting:** separate fact / interpretation / hypothesis. Whole numbers. Every population shows its size and its share of game revenue.
- **Ask Eden first:** heavy queries and raw / staging datasets. Staging was approved for this analysis.
- **Git:** commit as Edenelm <117096871+Edenelm@users.noreply.github.com>. Commit and push only with Eden's OK.
