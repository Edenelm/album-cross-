# Dice album research — DECISIONS
Newest first. Each entry: decision, who, when, why, what it changes. Open conflicts stay listed until resolved.

## Decisions
| ID | Date | Decision | By | Why / effect |
|---|---|---|---|---|
| D-007 | 2026-11-03 | **Working rules (Eden):** depth with focus and speed. Stay in the active question; side questions go to the backlog. Each check must name the bias or alternative explanation it guards against; prioritise what could change the decision; reuse validated results; stop checking once data, comparison and main reading hold; report each insight as finding → validation → business meaning → limitation. | Eden | Applies to every topic |
| D-006 | 2026-11-03 | **Album 65 is a regular album.** Only its end was lower than other albums; overall it is fine. In Topic 1 it is a full cohort like 57–63 (first album 65, next album 67). The "65 = case" rule (D-003) applies only to end-of-album measures (final days, end lift). | Eden | Narrows D-003 |
| D-005 | 2026-11-03 | **Topic 1 definitions (Eden):** (1) population = players who start their **first album** (no earlier album row); no "new to the game" split. (2) Albums that started in 2026, focus on **57, 59, 61, 63, 65**. (3) Next-album outcomes widened: retention, gross revenue, engagement in the next album. (4) Staging pack events allowed; also search the Dice dbt album tables. (5) Late entry read both ways: final third of the album period **and** entry in the last 14 days before close. | Eden | Replaces PLAN §2 groups A/B; C-002 closes as "not split by install" |
| D-001 | 2026-11-03 | **Decided (Eden, 2026-11-03): push to the public `Edenelm/album-cross-` repo.** Context at the time: `Edenelm/album-cross-` is **public** (checked with `gh api`); `superplay-ab-data` is public too. Superplay revenue and player-behaviour numbers should not go to a public repo. Options: (a) make `album-cross-` private, (b) new private repo for Dice research. Only aggregated results, no player IDs. | Eden | Pushes go to `album-cross-` |
| D-002 | 2026-11-03 | Research lives in `dice-research/` inside the album repo; earlier Dice files stay in `claude/` and are linked, not moved. | Claude (structure choice) | Keeps the repo's index conventions and the history of earlier docs |
| D-003 | 2026-11-02 | Typical albums 59/61/63 are the base; 65 is shown only as a case. | Eden | 65 is the only flat end since April 2025. **Narrowed by D-006:** applies to end-of-album measures only |
| D-004 | 2026-10-21 | First album = no row in any earlier album (not `user_past_album_count`). | Eden | The column marks returning payers as first-album |

## Open conflicts and cautions
| ID | Conflict | Status |
|---|---|---|
| C-001 | Earlier "first album" numbers disagree: `claude/first-album-finish-rate-2026-10-21.md` uses `user_past_album_count` (Dice 61: 40,274 first-album payers, 19% of payers); the fixed rule gives 21,465 (61) / 16,989 (63) payers in the standard population. | Resolved by D-004 for Dice; old numbers not reused |
| C-002 | "New" in `claude/dice-entry-dups-rolls-2026-11-02.md` = first album (no earlier row). It mixes players new to the game with older installs. | Closed 2026-11-03: Eden chose first album only (D-005); the earlier definition matches. Base table differs (that doc used `user_daily_album`, Topic 1 uses `album_pop`), so numbers are re-run, not reused |
| C-003 | Research map (11-02) said first-album players do not look worse (finish 12–15%, standard population); the 11-03 entry-third work found first-third new players finish least and stop 2–4x more. Different populations: the standard population drops early leavers. | Open — Topic 1 uses all players with a row, no login filter |
| C-004 | Completion-path "bought" numbers used the superseded `Pricing%` pack rule. | Open — rerun before reuse in Topic 2 |
| C-005 | `30_intermediate.album_pop.user_album_start_date` is overwritten to the close day for 25–31% of players in albums 63 / 65 (rows rebuilt after close). | Worked around: entry from `user_daily_album`. Not fixed at source; report to the data team |
| C-006 | Docs say the album opens at Kingdom 8; first-album players' median kingdom at entry is 5–6 (`kingdom_id_start_day`). | Open (backlog B-6); does not change Topic 1 findings |
