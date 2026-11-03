# Topic 1: First-album experience, focused plan (v2, 2026-11-03)
Status: definitions agreed with Eden (`DECISIONS.md` D-005); data sources checked (S1 done). Next: S2 base table.

## 1. Business question
What does a Dice player experience in their first album, especially when entering late, and what happens in their next album? Decision it feeds: does the first album need its own design (start path, catch-up level, early goal), or is the current one working, and for whom?

**Earlier inputs (re-checked, not reused as-is):** first-album players = 19–22% of players, 10–15% of album revenue; those starting in the first third finish least (6–8% of payers) and 28–32% of their payers pay next album; last-third joiners get strong catch-up; at every first-7-days spend level first-album players stop 2–4x more than veterans (`claude/dice-entry-dups-rolls-2026-11-02.md`, albums 59/61/63).

## 2. Population (Eden, D-005)
- **First-album player** = a player whose first album is this one: no record in any earlier album (`30_intermediate.album_pop`, history from 2023-11; all 2026 albums are far above the floor). No split by install date.
- **Entry** = `user_album_start_ts` in `album_pop` (first album event: started, sticker or pack). `user_daily_album` keeps only players with at least one sticker. *Claude's choice:* base = `album_pop` (does not lose players who opened and left), with a flag for "got a sticker". S2 reports how many lack a sticker.
- **Reference group** = veterans (record in the previous album, id − 2), same entry band and early spend.
- Excluded users removed (`is_excluded`). No login-ratio or close−1 filter.
- **Albums:** focus first albums **57, 59, 61, 63, 65** (all started in 2026; 55, started 2026-02-02, as extra context if needed). Next album = 59, 61, 63, 65, **67**. Album 67 is open until 11-30, so next-album outcomes use a **fixed window from the next album's start** (first 14 days, available for all cohorts) plus the full album where it has closed. Album 65 is a regular cohort like the others (D-006: only its end was lower).

| Album | Dates | Days (incl. close day) |
|---|---|---|
| 57 | 03-23..05-04 | 43 |
| 59 | 05-04..06-22 | 50 |
| 61 | 06-22..07-27 | 36 |
| 63 | 07-27..09-07 | 43 |
| 65 | 09-07..10-19 | 43 |
| 67 | 10-19..11-30 (open) | 43 |
Source: `20_core.dim_album_season` (queried 2026-11-03).

## 3. Entry timing and exposure
- **Entry band A (album period):** first / second / final third by share of album days at entry.
- **Entry band B (Eden):** started in the **last 14 days before close** vs earlier.
- **Days left** = album end date − entry date. Reported in every table.
- **Equal windows:** per active day, and fixed windows from entry (first 3 and 7 days, capped at close−1). Whole-album totals only within the same entry band.
- **Unit:** player × first album; player × day for trajectories.

## 4. Measures and sources (`dice-dreams-dbt`, checked 2026-11-03)
| Measure | Source | Notes |
|---|---|---|
| Population, entry ts, segment, reward code, LTV before album, album spend | `30_intermediate.album_pop` | user × album; `user_past_album_count` not used (login ≥ 0.15 rule) |
| Daily activity, gross spend, new / total stickers (→ duplicates), stickers by type, sets, Wild received, kingdom, packs count, finish | `50_reporting.user_daily_album` | partition `date_dim`; rows from first sticker; close-day stickers not updated |
| Packs by source and type, new vs duplicate per pack, Wild in pack | `10_staging.stg_album_pack_received_vw` (Eden OK) | `source` (e.g. "Trail - Chest", "new kingdom", "Dream Pass"), `pack_key`, `total_stickers_in_pack`, `number_of_new_stickers` (+ common/golden/super), `is_wild`, `mtx_campaign_id`; partition `pdate`; event doc marks some fields "Investigate", so check against the daily table |
| Rolls in by source: album vs rest of game, bought vs free | `30_intermediate.user_daily_rolls_by_source` | `source_rolls_group = 'album'` = set completed (± Pixie), album completed, Pixies, duplication exchange (checked on 09-01..07); `source_purchase_group` for bought rolls; rolls out = `roll_type = 'rolls_out'` |
| Roll balance | `30_intermediate.user_daily_rolls_in_out` (`rolls_balance`) | identity check in S2 |
| First Super / first Wild fill, sticker sources | `30_intermediate.fact_user_album_stickers` | new stickers only |
| Game activity and gross revenue outside the album (retention, next purchase) | `50_reporting.user_daily_metrics_agg`, `20_core.purchase_completed_vw` | |
| Denominator: game revenue during the album | as in `decisions-definitions-register.md` | |

## 5. Next-album outcomes (Eden: retention, gross revenue, engagement)
- **Retention:** active in the game on days 1–14 of the next album; entered the next album; active in the game 7 / 14 / 30 days after first-album close (only where the window has passed).
- **Gross revenue:** next album, first 14 days and full album (closed albums only); payer rate; revenue per player and per payer.
- **Engagement:** active days, rolls out per active day, new stickers and sets by day 14, finish (closed albums).
- **Time to next purchase:** from first-album close, survival curve with censoring at the data end date.

## 6. Competing explanations and the evidence for each
| Explanation | Supporting pattern | Against it |
|---|---|---|
| H1 Generous rewards delay buying | late joiners (more catch-up) hold larger roll balances and buy later or less in album 1 at the same activity, then catch up in album 2 (spend moved, not lost) | same time to first purchase and same album-2 revenue whatever the catch-up |
| H2 Too little progress discourages | players who stop had fewer new stickers / more duplicates before stopping than similar players at the same sticker count and day who stayed | no difference before stopping (11-03 first look: none in new-sticker pace) |
| H3 Generous early rewards build value | more progress in a fixed early window, at the same entry band and early spend, goes with more retention and revenue in album 2 (dose-response) | no gradient, or it disappears once early spend and activity are held fixed |
| H4 General newcomer drop-off | drop-off by days since first entry is the same whatever the album phase at entry | first-album players entering at different album phases diverge at the same days since entry |
| H5 Artefacts | results move when the entry rule, window or base table changes | stable across these checks |

All of these are observational. A pattern that fits an explanation gives a test hypothesis, not proof.

## 7. Checks before any conclusion
- One row per user × album (album_pop) and per user × album × day (daily); no fan-out on joins (row counts before/after).
- Entry ts vs first sticker vs first pack; entry after close = data issue.
- Packs: sum of `total_stickers_in_pack` vs daily `total_stickers_today` for the same player-days.
- Rolls: balance(t) ≈ balance(t−1) + in − out; impossible values flagged.
- Revenue: reconcile album revenue with known totals (59 / 61 / 63 = $24.2M / $19.8M / $24.6M) and first-album shares with the 11-02 table.
- Close day: stickers from the sticker table; revenue start..close−1.
- Small cells flagged (late entrants by spend level).

## 8. Steps
| Step | What | Output |
|---|---|---|
| S1 | Sources and schemas | done (this file §4) |
| S2 | Base table per first album 57–65: entry band A/B, days left, sticker flag; sizes with players, % of players, % of game revenue; reconcile | `queries/t1_s2_base.sql`, `results/`, `findings.md` |
| S3 | First-album experience by entry band: active days, packs per active day by source/type, new vs duplicate, sets, speed, first Super / Wild, rolls in (album / other / bought), out, balance, spend, finish | `queries/t1_s3_*.sql` |
| S4 | Next album: retention, gross revenue, engagement; time to next purchase | `queries/t1_s4_*.sql` |
| S5 | Test H1–H5 (stoppers vs stayers at the same state; entry-phase comparison) | `queries/t1_s5_*.sql` |
| S6 | Findings: observed (N, %, revenue share) / meaning / supported vs uncertain / recommendation or next check | `findings.md` |

Large results stay in BigQuery or the session scratchpad; the repo keeps the query, a pointer and the aggregated CSV. No player IDs in the repo.

## 9. Questions for the Dice team (not blocking)
The exact catch-up rule for late joiners; the pack catalogue (which packs are album rewards); whether first-album players get anything special (starter packs, onboarding gifts).
