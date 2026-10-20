# Dice — album segmentation validation (started 2026-10-14)

Question (Eden): the Dice album segment (difficulty, set before the album) and the daily super segment were defined ~a year ago. Are they still right, or should players be segmented differently / earlier?
Context: per-album start date and album length ARE updated in the super-segment query (Known). The super segment is used in the last quarter of each album.
Definitions: reference/dice_album_user_segmentation.md. Project `dice-dreams-dbt`, albums 61 (35 days) / 63 (42 days).

Plan (one step at a time):
1. Assigned difficulty vs actual spend in the album — DONE (below).
2. Spend curve vs actual cumulative spend share by difficulty — DONE (below).
3. Super segment at the last-quarter start: original vs corrected curve — DONE (below); open: reconstruction does not match the stored column in album 61.
4. Goal attainment by difficulty × tier (revenue share) — DONE (below).

## Step 1 — assigned difficulty vs actual spend (run 2026-10-14)
Table `50_reporting.user_daily_album`. Filters: not excluded, login ratio (last row) ≥ 0.5, close day excluded, not first album (`user_past_album_count > 0`).
Assigned = `album_segment_code` on the player's first album day. Actual = album spend × 70 / album days (35 / 42), bucketed with the same thresholds (<$100 Easy, $100–400 Medium, $400–1,000 Hard, ≥$1,000 Extreme).

Payers — share of assigned level that lands on each actual level (61 / 63):
| Assigned | Payers 61 / 63 | Moved down | Same level | Moved up | P50 spend on same level |
|---|---:|---:|---:|---:|---|
| Easy | 115,911 / 119,347 | – | 84.5% / 84.4% | 15.5% / 15.6% | $19 / $18 |
| Medium | 42,576 / 42,135 | 31.1% / 31.0% | 54.9% / 55.6% | 14.0% / 13.5% | $195 / $192 |
| Hard | 13,163 / 13,796 | 42.6% / 45.2% | 43.4% / 42.7% | 14.0% / 12.1% | $611 / $597 |
| Extreme | 5,319 / 6,029 | 39.7% / 42.4% | 60.2% / 57.6% | – | $1,863 / $1,816 |

Upward movers in absolute numbers: Easy → Medium or higher ≈ 17.9K (61) / 18.7K (63) payers; Easy → Hard/Extreme ≈ 1.9K / 2.1K.
Non-payers assigned Medium–Extreme (paid before, not in this album): 1,720 (61) / 1,346 (63).

Reading:
- Known: identical picture in both albums.
- Known: the pre-album label is right for most Easy payers (84%), but only 43–60% for Medium/Hard/Extreme. Hard is wrong more often than right.
- Known: misses lean downward for the upper levels (31–45% spend below their level, 12–14% above).
- Known: ~15% of Easy payers (~18K per album) spend like Medium or higher; the pre-album label misses them (the daily super segment is meant to catch these).
- Hypothesis: one album of history is noisy (regression to the mean). An average of the last 2–3 albums may assign better. Testable from data.
- Not causal: the difficulty itself may change spend (a harder album may push or discourage spend).

## Step 2 — expected spend curve vs actual pace (run 2026-10-14)
Same table/filters as step 1, payers only with album spend > 0. Actual = cumulative album spend through the last full day at each % of album time ÷ the player's album total (pooled, spend-weighted). Curve = same polynomials as the super-segment query, x = (day+1) × 77 / album days (35 / 42). Measured at end of day; the live query runs mid-day (≈ half-day offset).

Share of album spend reached (actual vs curve), 61 / 63:
| Difficulty | 10% | 25% | 50% | 75% (last-quarter start) | 90% |
|---|---|---|---|---|---|
| Easy | 7–9% vs 3% | 21–23% vs 10% | 43–47% vs 28–29% | 72–73% vs 59–60% | 88–89% vs 83–85% |
| Medium | 9–11% vs 9–10% | 24–27% vs 21–22% | 48–51% vs 42–44% | 74–77% vs 69–70% | 89–90% vs 87–88% |
| Hard | 9–12% vs 12% | 25–28% vs 26% | 49–53% vs 48–50% | 75–78% vs 75–76% | 90–91% vs 91–92% |
| Extreme | 10–12% vs 12% | 25–28% vs 26% | 50–53% vs 48–50% | 77–78% vs 75–76% | 90% vs 91–92% |
Curve value at 100% = 1.02–1.03 (sanity OK). Median Easy payer has spent 88–92% of their album total by 75% of the album (Medium–Extreme 78–82%).

Reading:
- Known: Hard and Extreme curves still fit (within ~3 points at every checkpoint, both albums).
- Known: Easy curve is badly off — it assumes back-loaded spend; real Easy spend is close to linear. At the last-quarter start, Easy payers have spent 72–73% vs 59–60% expected.
- Known: Medium is slightly ahead of the curve (+5–8 points mid-album, +5–7 at 75%).
- Implication (Hypothesis, to verify in step 3): at the last-quarter start, an Easy payer on pace for exactly the tier budget looks ~20% ahead (0.73 / 0.60 ≈ 1.2×); Medium ~1.08×. Easy (and part of Medium) payers are likely placed one tier too high in the last quarter.
- Possible fix (Hypothesis): refit the Easy (and Medium) curves on recent albums. Any change to targeting/injections → A/B.

## Step 3 — super segment at the last-quarter start (run 2026-10-14)
Checkpoint = day CEIL(0.75 × n): 61 day 27 (2026-07-19), 63 day 32 (2026-08-28). Filters: not excluded, not first album, row on checkpoint day, login ratio ON THE CHECKPOINT DAY ≥ 0.5 (Eden approved; reflects what is known at that moment).
Original tier = live-query formula (x = d × 77 / n, threshold = curve × budget × n / 77, n = 35 / 42), spend = cumulative through end of previous day. Corrected tier = same, curve value replaced by the measured pace at 75% from the OTHER album (step 2).

Reconstruction vs stored `album_super_segment_code` on that day (all players incl. non-payers):
| Difficulty | 61 | 63 |
|---|---:|---:|
| Easy | 93.5% | 96.3% |
| Medium | 53.3% | 79.9% |
| Hard | 38.6% | 75.4% |
| Extreme | 23.6% | 79.1% |
Spend through end of checkpoint day instead of previous day: no better (within 2 points). → Needs Validation: the stored column is NOT computed the way the shared query computes it, especially in 61 (Easy match is inflated by non-payers at tier 0).

Tier distribution among players who paid so far (original → corrected), 61 / 63:
| Difficulty | Payers so far | Tier 0 | Tier 1 | Tier 2 | Tier 3 | Tier 5 | Moved down one+ tier |
|---|---|---|---|---|---|---|---|
| Easy | 105K / 110K | 76% → 80–81% | 19% → 15–16% | 4% → 3% | 1% → 0.7% | 0.6% → 0.4% | 6,424 / 8,304 (6% / 8%) |
| Medium | 42K / 41K | 51–53% → 53–58% | 28–29% → 27–28% | 13–14% → 11–13% | 4–5% → 3–4% | 1.7% → 1.3–1.5% | 2,413 / 4,137 (6% / 10%) |
| Hard | 13K / 14K | 37–41% → 37–42% | 28% | 15–17% | 13–15% → 12–16% | 3% | 0 / 752 (0% / 5%) |
| Extreme | 5.3K / 6.0K | 22–24% → 22–25% | 32–33% → 32–34% | 22–23% → 21–23% | 17–19% → 16–18% | 4–5% | 78 / 330 (1% / 6%) |

Reading:
- Resolved (Eden, 2026-10-14): the team uses the OUTPUT OF THE SHARED QUERY in the last quarter, not the stored column → the reconstruction is the relevant tier; step 3 results stand. Original note: the reconstruction matches the stored tier for most players in 63 (75–80% for Medium–Extreme) but not in 61 (24–53%). Either 61 was run with different parameters, or the stored column uses a different logic than the shared query.
- Known (on the reconstruction): the Easy-curve bias moves 6–8% of Easy payers one tier down at the last-quarter start; Medium 6–10%; Hard/Extreme 0–6%. Smaller than the ~20% pace gap suggested, because ~3/4 of Easy payers sit far below the tier-1 bar anyway.
- Known: at the last-quarter start most payers are in tier 0 — Easy 76%, Medium ~52%, Hard ~39%, Extreme ~23% — consistent with step 1 (upper levels often spend below their level).
- Needs Validation (side issue): the stored `album_super_segment_code` in `user_daily_album` does not match the query the team uses (24–53% agreement for Medium–Extreme in 61). Any dashboard/tracker that splits by the stored column may not show the tiers used for targeting.

## Step 4 — goal attainment by difficulty × tier at the last-quarter start (run 2026-10-14)
Goal logic (Eden): bring players near completion (≤3 stickers missing) by the end; checkpoint example = 10 Supers at close−4. Target share differs by type (example only: Easy tier 0 ≈ 20%, Extreme tier 5 ≈ 80%). Targets are measured as REVENUE SHARE: revenue (album start → measurement day) of players who reached the state ÷ revenue of the group.
Tier = reconstructed live-query tier at the last-quarter start (step 3, original curve). Same filters as step 3. Close−4 = 2026-07-23 (61) / 2026-09-03 (63). Every player had a row on close−4.

Revenue share at close−4 holding ≥10 Supers (61 / 63):
| Difficulty | Tier 0 | Tier 1 | Tier 2 | Tier 3 | Tier 5 |
|---|---|---|---|---|---|
| Easy | 15% / 34% | 23% / 41% | 33% / 49% | 39% / 59% | 56% / 70% |
| Medium | 19% / 41% | 24% / 45% | 29% / 50% | 37% / 55% | 51% / 64% |
| Hard | 24% / 46% | 28% / 52% | 32% / 56% | 38% / 60% | 52% / 71% |
| Extreme | 28% / 54% | 34% / 60% | 43% / 65% | 49% / 73% | 72% / 76% |
Revenue share ≤3 missing at close−4 is within ~3 points of the 10-Supers share in every cell. Revenue share ≤3 missing at close−1: 48–89% (61), 70–90% (63). Q4 ARPDAU rises steeply by tier (e.g., Extreme $10 → $110–123; Easy $0.16 → $20–23).
Group sizes: Easy tier 0 ≈ 356–372K players (≈80K paid so far); Extreme tier 5 = 241–260 players.

Reading:
- Known: attainment rises with tier in every difficulty, both albums — the tier separates progression as intended.
- Known: the tier drives more separation than the difficulty. Within Easy, tier 0 → 5 spans 15% → 56% (61); across difficulties at tier 0 the span is 15% → 28%.
- Known: album 63 sits 15–25 points higher than 61 in almost every cell (only Extreme tier 5 is close: 72% vs 76%). Album-level design/injections dominate. Hypothesis: 63 was more generous and/or the 42-day length gave more time.
- Known: revenue share > player share in every cell — heavier spenders inside a group progress further.
- Not causal: paying buys stickers, so higher tiers progress more even without targeted injections.
- Missing: the actual per-cell targets for 61/63 — needed to say which cells hit or missed.

### Step 4b — album 63 vs the team's goal table (Eden, 2026-10-14)
Goal table (album 63, days-to-end 4 = 2026-09-03 = our close−4): count targets 141 stickers (= ≤3 missing), 10 Supers, 27 Goldens, 104 Commons, 10 sets. Revenue-share goals exist only for: Easy tiers 1/3/5, Medium 1/3/5, Hard 1/3/5, Extreme 0/1/3/5.
Actual = step 4 (tier fixed at last-quarter start, filters login ≥ 0.5 at checkpoint + not first album).

| Cell | Goal | ≥10 Supers actual | Gap | ≤3 missing actual | Gap |
|---|---:|---:|---:|---:|---:|
| Easy 1 | 35% | 41% | +6 | 37% | +2 |
| Easy 3 | 50% | 59% | +9 | 56% | +6 |
| Easy 5 | 65% | 70% | +5 | 64% | −1 |
| Medium 1 | 45% | 45% | 0 | 43% | −2 |
| Medium 3 | 55% | 55% | 0 | 52% | −3 |
| Medium 5 | 75% | 64% | −11 | 61% | −14 |
| Hard 1 | 55% | 52% | −3 | 50% | −5 |
| Hard 3 | 70% | 60% | −10 | 58% | −12 |
| Hard 5 | 80% | 71% | −9 | 65% | −16 |
| Extreme 0 | 30% | 54% | +24 | 52% | +22 |
| Extreme 1 | 60% | 60% | 0 | 58% | −2 |
| Extreme 3 | 75% | 73% | −2 | 71% | −5 |
| Extreme 5 | 90% | 76% | −14 | 75% | −16 |

Reading:
- Known (on this definition): Easy cells and tier-1 cells are at or above goal; top cells miss by 9–16 points (Medium 5, Hard 3, Hard 5, Extreme 5); Extreme tier 0 overshoots by ~22–24 points.
- Hypothesis: real progression is flatter across tiers than the plan — low tiers get closer than intended, high tiers less close.
- Needs Validation (definition match): (1) the tracker likely uses the tier ON the measurement day, not the tier fixed at the last-quarter start; (2) the tracker likely has no login-ratio / first-album filters; (3) how the tracker treats tiers 0/2 for Easy–Hard (no goal columns). Gaps may shift once aligned.

### Step 4c — album 63, tracker-aligned (run 2026-10-14)
Definition aligned to the team's tracker (Eden approved): tier computed ON 2026-09-03 (days-to-end 4) with the live-query logic (x = 38 × 77 / 42, spend through end of 09-02); population = all album-63 players with a row on 09-03, not excluded; NO login-ratio / first-album filters (missing difficulty → Easy). Revenue share = revenue album start → 09-03 of players at/above the count target ÷ group revenue. SQL: Seg4b in `claude/dice_segmentation_validation_queries.sql`.

| Cell | Players | Goal | ≥10 Supers | Gap | 141 stickers (≤3 missing) | Gap | Goldens 27 | Commons 104 | Sets 10 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Easy 0 | 934,980 | – | 23% | | 21% | | 49% | 58% | 33% |
| Easy 1 | 28,562 | 35% | 42% | +7 | 39% | +4 | 67% | 76% | 54% |
| Easy 2 | 6,774 | – | 58% | | 55% | | 74% | 84% | 65% |
| Easy 3 | 2,426 | 50% | 69% | +19 | 64% | +14 | 77% | 88% | 74% |
| Easy 5 | 2,145 | 65% | 78% | +13 | 72% | +7 | 81% | 94% | 80% |
| Medium 0 | 36,897 | – | 31% | | 29% | | 65% | 72% | 45% |
| Medium 1 | 13,365 | 45% | 43% | −2 | 41% | −4 | 76% | 83% | 58% |
| Medium 2 | 5,761 | – | 50% | | 47% | | 79% | 86% | 65% |
| Medium 3 | 2,080 | 55% | 56% | +1 | 54% | −2 | 79% | 87% | 70% |
| Medium 5 | 968 | 75% | 67% | −8 | 64% | −11 | 81% | 90% | 74% |
| Hard 0 | 9,500 | – | 35% | | 32% | | 64% | 69% | 47% |
| Hard 1 | 4,664 | 55% | 47% | −8 | 45% | −10 | 80% | 83% | 62% |
| Hard 2 | 2,315 | – | 55% | | 53% | | 83% | 88% | 71% |
| Hard 3 | 2,082 | 70% | 61% | −9 | 59% | −11 | 84% | 88% | 73% |
| Hard 5 | 470 | 80% | 68% | −12 | 63% | −17 | 81% | 88% | 77% |
| Extreme 0 | 2,959 | 30% | 37% | +7 | 35% | +5 | 60% | 65% | 49% |
| Extreme 1 | 2,422 | 60% | 53% | −7 | 51% | −10 | 78% | 82% | 64% |
| Extreme 2 | 1,535 | – | 63% | | 62% | | 84% | 86% | 76% |
| Extreme 3 | 1,184 | 75% | 71% | −5 | 69% | −6 | 86% | 91% | 82% |
| Extreme 5 | 289 | 90% | 75% | −15 | 75% | −15 | 89% | 89% | 81% |

Reading:
- Known: Easy is above goal in every goal cell (Supers +7 to +19); Medium is on goal at tiers 1/3 and under at tier 5; Hard and Extreme are under goal in almost every cell (−5 to −17), worst at tier 5 (Hard −12/−17, Extreme −15).
- Known: the Extreme-0 overshoot from step 4b (+24) shrinks to +5/+7 once the tier is taken on the measurement day and filters are removed — the definition matters.
- Known: Easy tier 0 (no goal) is at 21–23% — close to the example "~20%".
- Known: Goldens and Commons are far above every goal (49–94%); the binding targets are Supers and full stickers (and sets).
- Hypothesis: Easy over-attainment is partly a misassignment effect — ~15% of Easy payers spend like Medium+ (step 1) and progress like higher levels; Easy tier 3/5 is where they land.
- Hypothesis: top tiers close their last Supers inside the last 4 days through Wild offers (Dice one-pager §4–6), so a 75–90% goal at days-to-end 4 may be ahead of how they actually convert. Any change to injections → A/B.

