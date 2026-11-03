# Dice album research — DECISIONS
Newest first. Each entry: decision, who, when, why, what it changes. Open conflicts stay listed until resolved.

## Decisions
| ID | Date | Decision | By | Why / effect |
|---|---|---|---|---|
| D-001 | 2026-11-03 | **Open:** where to push. `Edenelm/album-cross-` is **public** (checked with `gh api`); `superplay-ab-data` is public too. Superplay revenue and player-behaviour numbers should not go to a public repo. Options: (a) make `album-cross-` private, (b) new private repo for Dice research. Until decided, work is committed locally only. | Eden to decide | Blocks every push |
| D-002 | 2026-11-03 | Research lives in `dice-research/` inside the album repo; earlier Dice files stay in `claude/` and are linked, not moved. | Claude (structure choice) | Keeps the repo's index conventions and the history of earlier docs |
| D-003 | 2026-11-02 | Typical albums 59/61/63 are the base; 65 is shown only as a case. | Eden | 65 is the only flat end since April 2025 |
| D-004 | 2026-10-21 | First album = no row in any earlier album (not `user_past_album_count`). | Eden | The column marks returning payers as first-album |

## Open conflicts and cautions
| ID | Conflict | Status |
|---|---|---|
| C-001 | Earlier "first album" numbers disagree: `claude/first-album-finish-rate-2026-10-21.md` uses `user_past_album_count` (Dice 61: 40,274 first-album payers, 19% of payers); the fixed rule gives 21,465 (61) / 16,989 (63) payers in the standard population. | Resolved by D-004 for Dice; old numbers not reused |
| C-002 | "New" in `claude/dice-entry-dups-rolls-2026-11-02.md` = first album (no earlier row), so it mixes players new to the game with older installs reaching their first album. Its findings (first-third new players finish 6–8% of payers, 28–32% pay next album) must be re-split before reuse in Topic 1. | Open — Topic 1 step S2 |
| C-003 | Research map (11-02) said first-album players do not look worse (finish 12–15%, standard population); the 11-03 entry-third work found first-third new players finish least and stop 2–4x more. Different populations: the standard population drops early leavers. | Open — Topic 1 uses all players with a row, no login filter |
| C-004 | Completion-path "bought" numbers used the superseded `Pricing%` pack rule. | Open — rerun before reuse in Topic 2 |
