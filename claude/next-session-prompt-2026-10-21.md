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
5. **Approximate rebases still on the old basis:** the `weighting` chart, the 1- and 2-missing shares in the `staircase` notes, and the `heavy-missers` notes. Rerun on game revenue if a slide needs exact numbers.
6. `INDEX.md` is not yet updated with the docs from 2026-10-20/21.
7. `seg-return` shows differences in "pts". Eden's rule is to give differences in %. Fix it if she asks.

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
