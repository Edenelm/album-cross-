# Topic 1 — First-album experience: focused plan (2026-11-03)
Status: plan only. No queries run. Open definitions in §8 need Eden's answer before step S2.

## 1. Business question
What does a Dice player experience in their first album, especially when entering in its final third, and what happens in their next album? The decision it feeds: does the first album need its own design (start path, catch-up level, early goal), or is the current one working, and for whom?

**What we already have (to re-check, not to reuse as-is):** first-album players are 19–22% of players and 10–15% of album revenue; players new to album history who start in the first third finish least (6–8% of payers) and only 28–32% of their payers pay in the next album; last-third joiners get strong catch-up (10–11 new stickers per active day) and 1,171 of them finished album 63 in about 7 days; at every first-7-days spend level these "new" players stop 2–4x more than veterans (`claude/dice-entry-dups-rolls-2026-11-02.md`). "New" there means first album, not new to the game (`DECISIONS.md` C-002).

## 2. Populations
| Group | Rule | Why |
|---|---|---|
| **A. New to the game, first album** | no row in an earlier album **and** install date ≤ N days before album entry (N proposed 14; options 7 / 14 / 30, §8) | the experience of a real newcomer |
| **B. First album, not new** | no row in an earlier album **and** installed > N days before entry | slow progress to Kingdom 8 or long-dormant players: a different story |
| **C. Veterans (reference)** | row in the previous album (id − 2) | own-game comparison at the same entry timing and early spend |
| Excluded from A/B | install before 2023-11-07 (history floor: we cannot know their album past) | avoids false "first album" |

All players with at least one row in the album, `is_excluded` = false. **No login-ratio or close−1 filter**: the standard population drops players who joined and left, which is the group in question.
**Albums:** first album = 59, 61, 63. Next album = 61, 63, 65. Note: 65 is the atypical flat-end album, so the 63 → 65 transition is shown separately and the main read rests on 59 → 61 and 61 → 63. Not 65 or 67 as first albums (67 is open; 65's next album is not finished).
**Unit:** player × first album; player × day for trajectories.

## 3. Time and exposure
- **Entry day** = `user_album_start_date` (first sticker). Check against the first sticker timestamp and the install date (§6).
- **Days left** = close − entry. Entry third by share of album length; final third also as days-left bands (e.g. ≤7 / 8–14 days), because albums differ in length (35–49 days).
- **Equal windows:** per active day, and fixed windows from entry (first 3 and 7 days, capped at close−1). Whole-album totals only within the same days-left band.
- **Next album:** present (any row), active days, payer, spend in the first 14 days and the whole album (start..close−1), finisher.
- **Time to next purchase:** from the first-album close, survival curve with censoring at the data end date; never "share who bought" over unequal follow-up.

## 4. Measures and sources (`dice-dreams-dbt`)
| Measure | Source | Status |
|---|---|---|
| Install date | `50_reporting.user_daily_metrics_agg.install_date` | used before (cohort work); check one value per user |
| Entry, activity, spend, stickers (unique / total → new vs duplicate), sets, packs count, Wild received, kingdom | `50_reporting.user_daily_album` | known |
| Pack types and sources | `10_staging.stg_album_pack_received_vw` | staging layer: needs Eden's OK; fallback = `sticker_pack_key` / `sticker_source` on new stickers only (no duplicates) |
| Sticker sources, first Super, first Wild fill | `30_intermediate.fact_user_album_stickers` | known (new stickers only) |
| Rolls in by source (album vs rest of game), rolls out, balance | `30_intermediate.user_daily_rolls_by_source`, `user_daily_rolls_in_out` | used before; album-source mapping to verify in S1 |
| Purchases, time to next purchase | `20_core.purchase_completed_vw` | known |
| Game revenue (denominator) | as in `decisions-definitions-register.md` | known |

## 5. What would support each explanation
| Explanation | Supporting pattern | Against it |
|---|---|---|
| H1 Generous rewards delay buying | late joiners (high catch-up) hold larger roll balances, buy later or less in album 1 **at the same activity**, and catch up in album 2 (spend moved, not lost) | same time-to-first-purchase and same album-2 spend regardless of catch-up |
| H2 Too little progress discourages | players who stop had fewer new stickers / more duplicates in the days before stopping than similar players at the same sticker count and day who stayed | no difference in progress before stopping (11-03 first look found none in new-sticker pace) |
| H3 Generous early rewards build value | more progress in a fixed early window, at the same entry timing and early spend, goes with more return and spend in album 2 (dose-response) | no gradient, or the gradient disappears once early spend and activity are held fixed |
| H4 General newcomer drop-off | drop-off by days since install is the same whatever the album phase at install | newcomers who install at different album phases (start vs final third) diverge at the same days since install |
| H5 Artefacts | results move when the entry rule, history floor or window changes | results stable across these checks |

**Strongest available comparison (H4 vs album effect):** install date is close to random relative to the album calendar. Newcomers who install in an album's first third vs its last third meet different album states at the same days since install. Comparing them at equal days since install separates album effects from general drop-off. Check first that install volume and UA mix do not shift across the album (calendar / campaign confound). Still observational: it gives a test hypothesis, not proof.

## 6. Checks before any conclusion
- One row per user × album × day; one install date per user; no fan-out when joining rolls and purchases (row counts before/after each join).
- Entry date vs first sticker timestamp vs install date (entry before install = data issue).
- Close day: stickers from the sticker table; spend start..close−1 for revenue.
- Rolls: balance(t) ≈ balance(t−1) + in − out; impossible values (negative balance, rolls far above the known max) flagged.
- Reconcile: album revenue $24.2M / $19.8M / $24.6M (59/61/63); first-album share of players 19–22% and revenue 10–15% from the 11-02 entry-third table.
- Small cells flagged (final-third newcomers by spend level may be small).

## 7. Steps
| Step | What | Output |
|---|---|---|
| S0 | Eden answers §8 | `DECISIONS.md` |
| S1 | Schema check of the 5 sources (describe + dry runs, no heavy runs): rolls-by-source labels, pack event fields, install date | `CONTEXT.md` §3 updated |
| S2 | One base table per first album: group A/B/C, entry, days left, install age; sizes with players, % of players, % of game revenue; reconcile | `queries/t1_s2_base.sql`, `results/`, `findings.md` |
| S3 | First-album experience by entry band: active days, packs per active day (types/sources), new vs duplicate, sets, speed, first Super / first Wild, rolls in (album vs other) / out / balance, spend, finish | `queries/t1_s3_*.sql` |
| S4 | Next album and time to next purchase (survival, censored) | `queries/t1_s4_*.sql` |
| S5 | Test the explanations (§5), incl. install-phase comparison and stoppers vs stayers at the same state | `queries/t1_s5_*.sql` |
| S6 | Findings: observed (N, %, revenue share) / meaning / supported vs uncertain / recommendation or next check | `findings.md` |

Large results stay in BigQuery or in the session scratchpad; the repo keeps the query plus a pointer and the aggregated CSV. No player IDs in the repo.

## 8. Open questions for Eden (needed before S2)
1. **"New to the game"**: installed at most 7 / 14 / 30 days before entering the album? (proposed 14: covers the time most payers need to reach Kingdom 8; Claude's choice, to confirm)
2. **Albums**: first albums 59/61/63, next albums 61/63/65, with 63 → 65 shown separately because 65 is atypical. OK?
3. **"Returned for the second album"**: any row in the next album, or at least N active days, or paid?
4. **Staging pack events** (`10_staging.stg_album_pack_received_vw`) for pack types and sources: may I use it?
5. **Final third**: by share of album length, or by days left (e.g. ≤14 days)? Proposed: both.

## 9. Questions for the Dice team (would change what we can claim)
Catch-up rule for late joiners (what exactly is boosted, and when); pack type catalogue and which are album rewards; roll sources that count as "from the album"; whether first-album players get anything special (starter packs, onboarding gifts).
