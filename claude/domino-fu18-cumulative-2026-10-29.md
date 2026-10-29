# FU18 test: cumulative check + who dropped (2026-10-29)

Question (Eden): over the whole period after the test started, did 3 locked cost money? And who dropped (the report says the players left 1–2 short)?
SQL: `claude/domino_fu18_cumulative_2026-10-29.sql` (q28 = by end state on 07-05; q29 = by state on 06-27, before the test). `domino-dreams-dbt`, 8.6 GB each. Raw sums: `claude/results/domino_fu18_cumulative_2026-10-29.json`, `claude/results/domino_fu18_prestate_2026-10-29.json`.
Population = q27 (the A/B board definition, see `domino-fu18-ab-test-2026-10-29.md`): all Easy album-18 players, 3 locked 626,792 / 5 locked 628,564. Revenue = gross in-app $ on days at level 35+. $ per player = group sum ÷ group size. CI = normal approximation on per-player sums (95%).
Windows: before 05-12..06-27 · test 06-28..07-06 · 2 weeks after album 18 07-07..07-20 · album 19 07-21..08-24 · 2 weeks after album 19 08-25..09-07 · cumulative 06-28..09-07 (72 days).

## 1. All Easy players (3 locked vs 5 locked, $ per player)
| Window | 3 locked | 5 locked | Gap [95% CI] |
|---|---|---|---|
| Before the test | $7.70 | $7.80 | −1.2% [−3.6, +1.2] |
| Test | $1.87 | $1.91 | −1.9% [−5.2, +1.4] |
| 2 weeks after album 18 | $2.14 | $2.26 | −5.4% [−8.8, −1.9] |
| Album 19 | $4.57 | $4.69 | −2.6% [−5.9, +0.7] |
| 2 weeks after album 19 | $1.76 | $1.77 | −0.6% [−4.4, +3.1] |
| **Cumulative 06-28..09-07** | **$10.33** | **$10.63** | **−2.7% [−5.6, +0.1]** |
After removing the before-test gap (−1.2%): cumulative **−1.6%** (point estimate; the CI of the gap alone is ±2.4 points, so the net is not distinguishable from 0, and a loss of ~4% cannot be ruled out either).
Check: test-window and after-album-18 gaps reproduce q27 (−1.93%, −5.36%).

## 2. Who dropped: state fixed BEFORE the test (missing on 06-27; cannot be moved by the treatment)
Before the test Set 11 could not be completed, so nobody was at 1–2 missing (36 vs 37 players, left out). "At FU" = 3–5 missing = everything except the 5 end-locked stickers.
| State on 06-27 | Players per group | % of players | % of before-test $ | Cumulative gap [CI] | Net of before-test gap | Album 19 gap [CI] |
|---|---|---|---|---|---|---|
| **At FU (3–5 missing)** | 8,046 / 8,076 | 1.3% | **16%** | **−9.5% [−17.8, −1.1]** | **−9.0%** | **−12.8% [−22.6, −3.1]** |
| 6–10 missing | 28,497 / 27,627 | 4.5% | 32% | −1.6% [−6.3, +3.0] | +2.0% | +0.1% |
| 11+ missing | 590,208 / 592,824 | 94.2% | 52% | −2.7% [−5.8, +0.5] | −1.2% | −2.3% |
At FU, the two groups were equal before the test ($95.74 vs $96.25, 57.0% payers in both). Under 3 locked these players could finish in the last 8 days; they spent −3.8% in the test window, −7.6% in the 2 weeks after, **−12.8% during album 19**, −10.9% in the 2 weeks after album 19.

## 3. By end state on 07-05 (q28; descriptive only)
End state is an outcome of the test (3 locked moved the strongest players from 3–5 missing to finished / 1–2), so test vs control inside an end state compares different players: every state shows the 3-locked group lower (finished −45%, 1–2 −41%, 3–5 −34%, 6+ −15% cumulative), which is the mix shift, not an effect. Use §2 for "who dropped".

## Reading
- **Fact:** over 72 days from the test start, all Easy players: −2.7% [−5.6, +0.1] per player; −1.6% after the before-test gap. No clear loss, no clear gain.
- **Fact:** the drop sits in the players who were already at FU before the test (1.3% of players, 16% of before-test revenue): −9% over the period, and it grows in album 19, when both groups were back on the same rules.
- **Fact:** the far players (6+ missing, 99% of players, 84% of revenue) show no lasting difference after the first 2 weeks.
- **Hypothesis (not tested):** players who finished album 18 thanks to 3 locked spent less in the next album (they had less to chase, or got the grand prize / satisfaction early). This fits Eden's note that the drop is in the players who were close (1–2 short); with a pre-test split we can only say "at FU before the test".
- **Meaning:** 3 locked does not cost Easy revenue overall, but it is not free for the near group. The recommendation "back to 3 locked" stays, with a guardrail on the next album's spend of players at FU, and a mechanic for the near group (the report's 1–2-short offer) should be measured on the next album too.

## 4. Who made up the gap, in $ per player (Eden 2026-10-29: "who caused the drop?")
Contribution of a state = (state's test $ ÷ all test players) − (state's control $ ÷ all control players); the states add up to the total gap.
| Window | Total gap per player | At FU (1.3% of players) | 6–10 missing (4.5%) | 11+ missing (94%) |
|---|---|---|---|---|
| Before the test | −$0.09 | −$0.01 | −$0.01 | −$0.06 |
| 2 weeks after album 18 | −$0.12 | −$0.03 (25%) | −$0.02 (16%) | −$0.06 (52%) |
| Album 19 | −$0.12 | −$0.10 (82%) | +$0.05 | −$0.06 |
| Cumulative 72 days | −$0.29 | −$0.18 | +$0.06 | −$0.15 |
| **Cumulative, after each state's before-test gap** | **−$0.17** | **−$0.17** | **+$0.06** | **−$0.07** |
Reading: the far players (11+) carry half of the short dip right after album 18 and part of the before-test gap; after removing the gap that was there before, almost all of the remaining 72-day gap comes from the players already at FU.
Normalisation: every number is $ per player = group revenue ÷ group size (3 locked 626,792 vs 5 locked 628,564; the groups differ by one bucket of 997), same windows for both groups, and the before-test gap is removed as (1 + gap in the window) ÷ (1 + gap before the test) − 1.

## 5. Same check with a 14-day before-test baseline (Eden 2026-10-29; q30, pre = 06-14..06-27)
| State on 06-27 | Before (14 days) 3 vs 5 locked | 72 days | After removing the 14-day gap |
|---|---|---|---|
| All Easy | $2.34 vs $2.36, −1.2% (±3.3) | −2.7% | **−1.5%** |
| At FU (3–5 missing) | $46.19 vs $46.70, −1.1% (±8.6) | −9.5% | **−8.5%** |
| 6–10 missing | $21.06 vs $21.77, −3.3% | −1.6% | +1.7% |
| 11+ missing | $0.82 vs $0.84, −2.4% | −2.7% | −0.2% |
Same story as the long baseline (−1.6% / −9.0% / +2.0% / −1.2%): no clear overall loss; the lasting drop sits in the players already at FU.

## 6. The ~4% drop in the 2 weeks after album 18 (Jul 7–20), by state before the test (14-day pre)
| State on 06-27 | Gap Jul 7–20 [95% CI] | Before (14 days) | After removing it | $ per player of the total gap (net) |
|---|---|---|---|---|
| All Easy | −5.4% [−8.8, −1.9] | −1.2% | −4.2% | −$0.093 of −$0.121 raw |
| At FU (1.3%) | −7.6% [−17.9, +2.7] | −1.1% | −6.6% | −$0.026 |
| 6–10 (4.5%) | −6.0% [−11.4, −0.6] | −3.3% | −2.9% | −$0.020 |
| 11+ (94%) | −5.4% [−9.6, −1.2] | −2.4% | −3.0% | −$0.033 |
Reading: the drop is spread over all states, including players far from the FU (11+ missing), whom 3 vs 5 locked barely touched. So the 2-week drop is not explained by the FU mechanic alone; part may be chance (one 14-day window; the same window after album 17 was −0.9%) or another difference between the groups (report caveat C11: a duplicate-bar bug "primarily affected the test group", not visible in marts). Only the near group's drop lasts into album 19.
