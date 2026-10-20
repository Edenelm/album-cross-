# Cross-game album benchmark — analysis pack for the deck (2026-10-08)

Dice Dreams (`dice-dreams-dbt`), Domino Dreams (`domino-dreams-dbt`), Disney Solitaire (`solitaire-dreams-411507`).
Benchmark albums: Dice 61/63, Domino 17/19, Disney 14/15. Close date and open date are partial days.
This file adds everything done after `claude_session-log-2026-10-07.md`. Topics 1 and 4 (and the original Topic 2 tables) stay in `claude_cross-game-comparison-framework.md`; the parts marked SUPERSEDED below replace the old Topic 2 follow-up.
Companion files: `album_benchmark_participants.csv`, `album_benchmark_arpdau_ratio_by_album_cohort.csv`, `album_benchmark_pooled_table.csv`, `album_benchmark_frontloading_by_album_slice.csv`, `album_benchmark_queries.sql`.

## 1. Rule change: eligible players (Eden, 2026-10-08)

- Problem: the old cohort logic numbered albums from history that starts late (Dice album 22 / Nov 2023, Domino album 6 / Jun 2024, Disney table from 2025-04-03). Veterans were counted as cohort 1–2.
- `user_album_count = 1` / `user_past_album_count = 0` does NOT identify a true first album for Dice and Domino (Dice's counter also counts only albums with login ratio >= 0.15).
- New rule, same in all three games: a player is eligible only if installed on or after 2025-04-01 (about 18 months). Cohort = player's album order from the first album (1–6, 7+). Pre-window installers are excluded, not placed in a cohort.
  - Dice: `50_reporting.user_profile.install_date`; Domino: `prod_40_mart.user_daily_metrics.first_seen_date` (+ no `suspected_cheater_flag`); Disney: `bi_prod.user_profile.install_date` (+ `exclude_reason IS NULL`).
- Window 2025-04-01 to 2026-10-06. Albums analysed close 2025-10-01 to 2026-10-07: Dice 49–63 (odd IDs), Domino 13–19, Disney 7–15. Disney album 6 is invalid (two open dates, rows start 2025-08-23 although the album opened 2025-07-27).
- Cells under 5,000 players are left out of medians and pooled results.

## 2. Participant validation (Known)

Eligible share of participants (active before close, not excluded): Dice 30–50%, Domino 57–74%, Disney 96–99%. Cohort groups sum exactly to eligible participants in every album. Per-album numbers: `album_benchmark_participants.csv`.

| Benchmark album | Participants | Eligible | PU eligible | Cohort 1 / 2–3 / 4–6 / 7+ |
|---|---:|---:|---:|---|
| Dice 61 | 1,118,767 | 539,216 (48%) | 148,759 | 224K / 185K / 90K / 40K |
| Dice 63 | 1,085,087 | 522,372 (48%) | 144,607 | 182K / 200K / 95K / 46K |
| Domino 17 | 1,344,325 | 969,002 (72%) | 154,804 | 359K / 472K / 105K / 33K |
| Domino 19 | 994,683 | 697,140 (70%) | 133,864 | 240K / 223K / 165K / 68K |
| Disney 14 | 2,438,368 | 2,403,052 (99%) | 531,465 | 349K / 628K / 840K / 586K |
| Disney 15 | 2,134,210 | 2,100,407 (98%) | 448,330 | 247K / 412K / 718K / 724K |

7+ share of eligible players: Dice 63 8.7%, Domino 19 9.8%, Disney 15 34.4%.
Album calendar facts found on the way (Known unless noted): album spans (close − open) Dice 35–49 days, Domino 39–63, Disney 21–49 (Disney 13 = 21 days, Disney 11 = 35). Dice album 51 opens 9 Nov, one day before album 49 closes (Needs Validation). Disney album 10 opens one day after album 9 closes.
Needs Validation: Dice first-album players with `user_past_album_count > 0` are 0.1–0.3% of cohort 1; Disney `ROW_NUMBER` differs from `user_album_count` for 0.2–0.7% of eligible players in albums 9–15.

## 3. Album-end ARPDAU, last four full album days vs whole album (SUPERSEDES Topic 2 follow-up)

Rule (unchanged): end window = close−4 … close−1; whole album = player's first exposure … close−1; close date excluded; revenue = `spent_in_album_today` / `album_spent_today` on active days (Dice check, album 63: this equals total game revenue on the same player-days within ~1%, so it is NOT album-only revenue; Domino and Disney not yet checked); revenue and active player-days summed first, then divided. PU = revenue on album days > 0 before close (PU definition includes end-window spend, so the PU ratio is biased upward).

Median ratio across albums (all players):

| Game | 1 | 2 | 3 | 4 | 5 | 6 | 7+ |
|---|---:|---:|---:|---:|---:|---:|---:|
| Dice | 1.16 | 1.20 | 1.25 | 1.19 | 1.24 | 1.22 | 1.23 |
| Domino | 1.13 | 1.16 | 1.23 | 1.18 | 1.17 | 1.15 | 1.14 |
| Disney | 1.01 | 0.98 | 1.03 | 1.03 | 1.04 | 1.04 | 1.06 |
| Albums per cell (Dice/Domino/Disney) | 8/7/9 | 8/7/9 | 8/7/9 | 8/7/9 | 8/6/8 | 7/5/7 | 6/4/6 |

PU only (median):

| Game | 1 | 2 | 3 | 4 | 5 | 6 | 7+ |
|---|---:|---:|---:|---:|---:|---:|---:|
| Dice | 1.17 | 1.08 | 1.13 | 1.13 | 1.18 | 1.19 | 1.20 |
| Domino | 1.19 | 1.05 | 1.15 | 1.12 | 1.13 | 1.12 | 1.13 |
| Disney | 1.07 | 0.93 | 0.97 | 0.98 | 1.02 | 1.02 | 1.05 |

Old medians (superseded, old cohort logic): Dice 1.08 / 1.12 / 1.19 / 1.18 / 1.17 / 1.21 / 1.22; Domino 1.13 / 1.16 / 1.22 / 1.17 / 1.16 / 1.16 / 1.18; Disney 1.01 / 0.98 / 1.03 / 1.03 / 1.04 / 1.04 / 1.06.

Known:
- Dice changed most (cohort 1: 1.08 → 1.16, cohort 2: 1.12 → 1.20): veterans had diluted the low cohorts. Domino 1–4 unchanged, 7+ 1.18 → 1.14. Disney unchanged (almost all its players installed after April 2025).
- Same shape in all games (rise from cohort 1 to 3, then level). Order in every cohort: Dice >= Domino > Disney.
- Album-specific spikes: Dice 53 and 57 (up to 1.41), Domino 14 and 18 (up to 1.34), Disney 8 (1.18–1.40, the only strong Disney album).
- First-album payer-day-rate ratio (median of cells): Dice ~1.03, Domino ~1.02, Disney ~0.96.
Needs Validation: 7+ medians rest on 4–6 albums; 7+ in this rule means fast-progressing installers of the last 18 months. Dropped cells: Dice 49 cohort 6 (110 players), Dice 51 cohort 7+ (91), Disney 7 cohort 5 (448), Disney 8 cohort 6 (391), Disney 9 cohort 7+ (332).

### Pooled table (format requested by Eden) — last four full days ARPDAU / whole-album ARPDAU (ratio)
Pooled across the valid albums of each game (sum revenue ÷ sum active days). File: `album_benchmark_pooled_table.csv`.

| Album # (cohort) | Dice | Domino | Disney |
|---|---|---|---|
| 1 | $1.52 / $1.32 (1.15×) | $0.91 / $0.82 (1.12×) | $1.39 / $1.36 (1.02×) |
| 2 | $1.65 / $1.39 (1.19×) | $0.99 / $0.83 (1.20×) | $1.15 / $1.16 (1.00×) |
| 3 | $1.68 / $1.31 (1.28×) | $1.05 / $0.87 (1.21×) | $1.01 / $0.97 (1.04×) |
| 4 | $1.66 / $1.41 (1.18×) | $1.11 / $0.92 (1.20×) | $0.93 / $0.87 (1.07×) |
| 5 | $1.70 / $1.37 (1.24×) | $1.14 / $0.99 (1.15×) | $0.99 / $0.87 (1.14×) |
| 6 | $1.67 / $1.38 (1.21×) | $1.17 / $1.01 (1.16×) | $0.88 / $0.84 (1.04×) |
| 7+ | $1.52 / $1.23 (1.23×) | $1.11 / $0.93 (1.18×) | $0.82 / $0.77 (1.07×) |
| 7+ avg daily players, whole album → last 4 days | 20.3K → 19.4K | 26.8K → 25.4K | 349K → 341K |

PU only (same pooling):

| Album # (cohort) | Dice | Domino | Disney |
|---|---|---|---|
| 1 | $4.48 / $3.78 (1.18×) | $3.56 / $3.03 (1.18×) | $4.37 / $3.99 (1.09×) |
| 2 | $4.00 / $3.77 (1.06×) | $3.05 / $2.80 (1.09×) | $3.42 / $3.54 (0.97×) |
| 3 | $4.16 / $3.56 (1.17×) | $3.21 / $2.87 (1.12×) | $3.28 / $3.33 (0.98×) |
| 4 | $4.17 / $3.71 (1.12×) | $3.28 / $2.85 (1.15×) | $3.27 / $3.11 (1.05×) |
| 5 | $4.21 / $3.56 (1.18×) | $3.39 / $3.01 (1.13×) | $3.37 / $3.01 (1.12×) |
| 6 | $4.24 / $3.58 (1.19×) | $3.51 / $3.07 (1.14×) | $3.03 / $2.96 (1.03×) |
| 7+ | $3.98 / $3.29 (1.21×) | $3.32 / $2.83 (1.17×) | $2.94 / $2.75 (1.07×) |

Notes: pooled ratios weight large albums more than the medians do (for example Dice cohort 3: pooled 1.28 vs median 1.25). The "7+ avg daily players" row is my reading of the last row in Eden's format (average daily active players of the 7+ cohort, whole album window vs last four days) — Needs Validation. Cohorts 1–6 daily players are not shown because they ramp up as new players enter the cohort during the album.

## 4. Is Disney's spend front-loaded? (Hypothesis 1 — not supported)

Index = ARPDAU in a 5% slice of album time ÷ whole-album ARPDAU (eligible players, median across albums: Dice 8, Domino 7, Disney 9). File: `album_benchmark_frontloading_by_album_slice.csv`.

| Game | Slice 0–5% (open day partial) | 5–25% | 25–75% | 75–90% | 90–100% |
|---|---:|---:|---:|---:|---:|
| Dice, all | 0.82 | 0.96 | 0.97 | 1.04 | 1.20 |
| Dice, PU | 0.93 | 1.02 | 0.95 | 1.00 | 1.18 |
| Domino, all | 0.85 | 0.98 | 0.98 | 1.08 | 1.14 |
| Domino, PU | 0.91 | 1.04 | 0.96 | 1.03 | 1.13 |
| Disney, all | 0.78 | 0.98 | 1.01 | 1.04 | 1.08 |
| Disney, PU | 0.83 | 1.03 | 0.99 | 1.00 | 1.06 |

Share of album revenue (sum of slice medians, approximate): first 25%: Dice 23.6%, Domino 23.7%, Disney 24.2%; last 25%: 27.9%, 27.2%, 26.0%; last 10%: 11.1%, 10.6%, 10.5%.
Known: Disney is not front-loaded; its curve is flatter (about 1.0 mid-album, 1.08 at the end) while Dice and Domino dip to ~0.97 mid-album and rise to 1.14–1.20 at the end. The data does not say why.
Needs Validation: late joiners change slice composition; album lengths 21–63 days; revenue shares sum medians; PU definition includes end-window spend.
Open hypotheses (no causal claim): album-specific ending mechanics or events (needs per-album ending calendar, Topic 3); different end-of-album behaviour (link to Topic 4 only after all topics). Test: A/B test on the ending period in Disney.
## 4b. Sanity check on the revenue measure (Dice, album 63, 2026-07-27..2026-09-06)
- No duplicate rows per player per day (0 of 37.9M user-days).
- `spent_in_album_today` vs total game revenue (`50_reporting.user_daily_metrics_agg.revenues_sum`) on the same active player-days: $15.33M vs $15.50M (all players, not eligible), $14.45M vs $14.62M (eligible). ARPDAU eligible $1.668 vs $1.687; non-eligible $1.103 vs $1.115. So the column is effectively total game spend while the album is open.
- No spend on inactive days (spend on all days = spend on active days).
- Dice first-album pooled ARPDAU ($1.32) is in line with Dice's overall album-exposed ARPDAU in September (~$1.29: $20.29M revenue over ~525K average DAU × 30 days).
- The old Topic 2 first-album figure ($0.83) differed because it used the old cohort logic (pre-history veterans counted as first album) and `album_pop`; Domino ($0.80 vs $0.82) and Disney ($1.23 vs $1.36) first-album ARPDAU barely moved. Hypothesis: the Dice old group was diluted by lapsed veterans; also `user_daily_album` only has users with at least one sticker collected (more engaged). Not tested.
- Eligible Dice players (installed since 2025-04-01) have higher ARPDAU in album 63 than non-eligible ($1.67 vs $1.10) — descriptive, not explained.

Context checked: September 2026 total revenue Disney $31.1M, Dice $20.3M, Domino $9.5M; ARPDAU per active day is the lowest in Disney ($0.76–1.23 vs Dice $1.12–1.76, Domino $0.80–0.87).

## 5. Status, open items, deck material

- Done: Topic 1; Topic 2 (population table + album-end ARPDAU rerun under the new rule); Topic 4 partly (rare totals + PU rare progression).
- Topic 3 not started: next step 3a = album calendar (weekday, full days, gap to next album, launch frequency, album IDs, ending period, ending-weekend ARPDAU vs previous 14 days). Dates and spans already pulled (section 2). Awaiting approval.
- Open validation items: Dice album 51 / 49 one-day overlap; Disney albums 11 and 13 short; Disney first Royal looks release-gated (Hypothesis); Dice album 61 `album_login_ratio` varies within user-album for 305K of 1.12M players; Dice `album_pop` history gap; data issues to report to BI.
- Topic 2 and Topic 4 numbers that used the old cohort logic: Topic 4 does not use cohorts (PU, login ratio >= 0.5) and is unaffected; Topic 2 population table (Sept 2026, albums experienced) still uses the old definition and has NOT been rerun under the eligible-player rule.

Suggested slide titles (neutral, no unsupported claim):
- "Album-end ARPDAU lift: median 1.16–1.25× in Dice, 1.13–1.23× in Domino, 0.98–1.06× in Disney (eligible players, last four full days vs whole album)"
- "Disney's spend is not front-loaded: the first 25% of the album carries 24% of revenue, as in Dice and Domino"

Decision table (draft, statuses only Adopt / Test / Do Not Adopt Yet):

| Mechanic | Source game | Target game | Evidence | Risk | Required validation | Recommended action |
|---|---|---|---|---|---|---|
| Earlier first-album gate | Domino (L35) | Dice, Disney | Exposure speed differs, no retention link shown (Topic 1) | Album before core loop learned | A/B on gate level | Do Not Adopt Yet |
| Ending-period lift (end-of-album ARPDAU 1.1–1.25×) | Dice, Domino | Disney | Descriptive only; lift is album-specific (Disney 8 strong), not tied to a mechanic | Confounded by album events, pace, economy | Per-album ending calendar (Topic 3), then A/B on the ending period in Disney | Do Not Adopt Yet |

