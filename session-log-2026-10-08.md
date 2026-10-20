# Session log — cross-game album benchmark (2026-10-08)

Continues `claude_session-log-2026-10-07.md`. Results and tables: `claude_album-analysis-pack-2026-10-08.md`. SQL: `album_benchmark_queries.sql`.

## Working rules (unchanged from 2026-10-07)
- dbt / BigQuery via Bifrost MCP; project= on every call (dice-dreams-dbt, domino-dreams-dbt, solitaire-dreams-411507). The session lock was lost once and had to be re-confirmed by Eden.
- One topic at a time, one question at a time, approval before running. State tables + filters; PU alongside all players; labels Known / Needs Validation / Missing / Hypothesis; no causal claims — propose an A/B test; no linking topics until all 13 are done.

## Decisions made today (Eden)
- Cohort fairness: players are counted by their true first album, only for the last ~18 months. Final rule: eligible = installed on or after 2025-04-01 in all three games (counter-based rules rejected because Dice/Domino history starts late).
- Album-end ARPDAU rule stays: last four full days (close−4…close−1) vs whole album; close date excluded. ARPDAU = total money ÷ total active player-days (a player active two days counts twice).
- Results to be shown in the pooled format "last 4 days $ / whole album $ (ratio×)" by game and album number.
- Everything done so far is to be saved for the final deck build (this log + analysis pack + CSVs + SQL).

## Done today
- Participant validation, all three games (eligible share Dice 30–50%, Domino 57–74%, Disney 96–99%).
- Album-end ARPDAU rerun for eligible players: medians by cohort, PU alongside, pooled table.
- Front-loading check (Hypothesis 1): not supported.

## Check done after Eden questioned Dice first-album ARPDAU ($1.32)
- Dice album 63: no duplicate rows; `spent_in_album_today` equals total game revenue on the same player-days within ~1% (so it is game spend while the album is open, not album-only). $1.32 is in line with Dice's overall ARPDAU. Label revenue as "game revenue on album days" in the deck. Domino/Disney revenue columns not yet checked the same way.

## Open items
- Topic 3 (album duration & timing) not started — step 3a (album calendar) awaiting Eden's approval.
- Topic 2 population table (Sept 2026) still uses the old cohort definition; not rerun.
- Needs Validation: Dice album 51 opens one day before album 49 closes; Disney albums 11 (35 days) and 13 (21 days) are short; meaning of the "7+ players" row in the requested table (assumed avg daily players, whole album → last 4 days).
- Older: Disney first Royal looks release-gated (Hypothesis); Dice album 61 login-ratio variation; Dice `album_pop` history / `is_excluded` gap; data issues to report to BI.
- Note: project files are read-only copies; these files must be uploaded to the project knowledge to persist across chats.

## Chart (published)
- Interactive chart of the pooled table, lines (not bars): https://claude.ai/artifact/CBFJkswUqJRfh5AHAqzCj8 (lift view + dollars view). Source file: `album_end_arpdau_chart.html`.
- Read from the dollars view: Dice flat across album numbers; Domino rises to album 6 then dips at 7+; Disney falls steadily (whole album $1.36 -> $0.77) and the two lines almost overlap. Hypothesis (not tested): cohorts are different players, not the same players over time; a same-player view would test it.

## Where we stopped
- Topics 1 and 2 done (Topic 2 album-end ARPDAU rerun under the eligible-player rule; Topic 2 population table NOT rerun). Topic 4 partly done (rare totals + PU rare progression). Topic 3 not started: step 3a (album calendar) was proposed three times and is still awaiting Eden's approval.

## Next session — order proposed
1. Run the same revenue + duplicate check on Domino (`album_spent_today`) and Disney (`album_spent_today`) as done for Dice album 63.
2. Topic 3 step 3a: album calendar (weekday of open/close, full days = span − 1, gap to next album, albums per 12 months, median/min/max, distinct open/close dates). Dates and spans already pulled (see analysis pack section 2).
3. Then 3b content availability, 3c ending period, 3d ending-weekend ARPDAU vs previous 14 days.
4. Rerun the Topic 2 population table (Sept 2026) under the eligible-player rule when convenient.
- Eden's pending choice: look at the decline across album numbers (Disney) or at the end-of-album lift gap.
- Start of next chat: read this log, the analysis pack, `claude_cross-game-comparison-framework.md`, `claude_benchmark-queries.md`; re-lock the three BigQuery projects (the server may ask for confirmation).

