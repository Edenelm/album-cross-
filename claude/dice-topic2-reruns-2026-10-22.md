# Dice topic-2 reruns on the fixed standard population (2026-10-22, Eden approved)

**Why:** findings B, C, D of topic 2 (`data-story-review-2026-10-21.md`) were built on the old Dice population, which used `user_past_album_count > 0` and left out 19–22K returning payers (`first-album-finish-rate-2026-10-21.md`).
**Only change:** "not first album" = the player has a row in an earlier album of `user_daily_album` (history from 2023-11-01). Everything else is the original query.
**SQL:** `claude/dice_topic2_reruns_2026-10-22.sql`. Project `dice-dreams-dbt`; tables `50_reporting.user_daily_album`, `30_intermediate.fact_user_album_stickers`, `50_reporting.user_daily_metrics_agg`, `20_core.dim_excluded_users`. Scans: B 104 GB, C 99 GB, D 129 GB.
**Raw results:** `claude/results/dice_stand_close3_fixed_2026-10-22.csv`, `dice_endwin_fixed_2026-10-22.csv`, `dice_strength_percentile_fixed_2026-10-22.csv`.
**Game revenue (denominator):** 61 $25,341,918 · 63 $30,302,561 (from `first-album-finish-rate-2026-10-21.md`).

## B. Where payers stand 3 days before close (original: `stand_close3_queries.sql`)
Far = 4+ missing of 144 at close−3. Revenue = album-table spend from album start to close−3.
| | 61 old → new | 63 old → new |
|---|---|---|
| Payers | 173,593 → 192,202 | 178,836 → 200,479 |
| Far share of payer revenue (to close−3) | 52.4% → **51.1%** | 29.6% → **29.6%** |
| Payers far | 77% → 76% | 49% → 50% |
| Far revenue ÷ game revenue (whole album), new only | 37% | 23% |

By group, % of the group's revenue that is far (2-album average): ≤$2 64% → 64%; $2–5 51% → 52%; $5–20 40% → 40%; $20+ 23% → 24%. Group shares of payer revenue unchanged (14 / 18 / 37 / 31%).
- Fact: the fix does not move B. The far share is a ratio inside the population, and the added players look like the rest.
- Flag: the old line "the $5–20 group carries ~20% of all revenue far" was on the old base (standard-population revenue, close−4). On game revenue, Dice $5–20 far = 14% (61) / 8% (63). The denominator mixes revenue to close−3 with whole-album game revenue, so this is a floor, not a like-for-like share.

## C. Who the Wild reaches, last 14 days (original: EndWin Dice, `middle-payers-stall-2026-10-15.md`)
Middle payers (P50–95 of spend before the last quarter). End state = missing stickers on the last row before close (daily table, the original rule). Average of 61/63.
| Metric | Far 4+ old → new | Near 1–3 old → new |
|---|---|---|
| Wild-filled stickers per 100, days 4–1 | 7 → **6** | 40 → **39** |
| Wild-filled stickers per 100, days 7–5 | 4 → 4 | 11 → 11 |
| New Supers per 100, days 10–8 | 45 → 45 | 73 → 73 |
| New Supers per 100, days 7–5 | 36 → 35 | 76 → 75 |
| Active rate, days 14–11 → 4–1 | was 86% → 75%; now 85% → 72% | ~95% both |
| Payers in days 4–1 | 29% → 27% | 58% → 58% |
| Share of group revenue in the last 7 days | 9% → 8% | 18% → 18% |
- Fact: the message holds: the Wild reaches the near (39 per 100) and barely the far (6 per 100).
- New, game-revenue base: far middle payers hold 15% (61) / 8% (63) of game revenue (group revenue = whole album to close−1).

## D. Finish rate by payer strength (original: `strength_percentile_queries.sql`)
| | 61 old → new | 63 old → new |
|---|---|---|
| Payers | 175,794 → 193,977 | 182,700 → 204,437 |
| Finish rate | 10% → 10% | 12% → 12% |
| Payers' share of game revenue | 67% → **78%** | 69% → **82%** |
| Finishers' share of game revenue | 18% → **21%** | 21% → **26%** |
| p95 threshold ($ a day before the last quarter) | 12.86 → 13.64 | 12.53 → 13.42 |
| Above p95: finish rate · share of game revenue · finishers' share | 25% · 28% · 10% → **25% · 33% · 12%** | 31% · 29% · 12% → **31% · 35% · 14%** |
| Below p95 (no zero bucket): finish rate · share · finishers' share | 9% · 38% · 7% → **9% · 44% · 9%** | 11% · 39% · 10% → **11% · 46% · 11%** |
Deciles 5–9 finish rate (2-album average): 9 / 11 / 13 / 16 / 18% → 9 / 11 / 13 / 16 / 19%. p99+: 38% → 38%.
- Fact: finish rates by bucket are unchanged; revenue shares rise by about ×1.16–1.19, as expected from the fix.
- Fact: the Disney vs Dice comparison (Disney lower in every bucket; deciles 5–9 Disney 3–10% vs Dice 9–19%) holds.
- Check: payer and finisher totals match the fixed population (78% / 82% of game revenue; finishers 21% / 26%) in `first-album-finish-rate-2026-10-21.md`.
- Not rerun: the "what it takes to reach 10%" rows (Dice 61 is at 9.9%, so ×1.01 stands).

## What changes in the decks
- Dice revenue shares from D (above / below p95, finishers' shares) must use the new numbers.
- B and C numbers stay; only add the Dice far-middle share of game revenue (8–15%) where a slide quotes "far middle payers, x% of game revenue".
