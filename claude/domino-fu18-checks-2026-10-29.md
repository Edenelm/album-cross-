# FU18 follow-up checks (2026-10-29)
Questions (Eden): (1) is the ~4% drop after album 18 a few days or spread? (2) does Hard show it? (3) "$15.43 vs $15.60 before the test" looks like ARPPU — show ARPDAU and normalised total revenue.
SQL: `claude/domino_fu18_checks_2026-10-29.sql` (q31, q32a, q33), `domino-dreams-dbt`, 7–8 GB each. Test = MOD(server_user_id,997) < 498 (3 locked).

## 1. Daily Easy gap, Jul 7–20 (A/B definition, in-app $ per player per day, 3 vs 5 locked)
Jul 7 −7.9% · 8 −5.4% · 9 −3.2% · 10 −8.2% · 11 −0.3% · 12 −6.7% · 13 −4.7% · 14 −4.8% · 15 −3.4% · 16 −7.3% · 17 −5.4% · 18 −6.4% · 19 −7.0% · 20 −3.3%. Then Jul 21–27: −5.1, −4.8, −4.6, −2.2, −6.5, −2.0, −2.3%.
Test window Jun 28 – Jul 6 for comparison: −6.1, −1.0, −3.8, +0.1, +0.7, +0.4, −1.8, −2.4, −4.9%.
Payers per day equal every day (e.g. Jul 7 1.377% vs 1.379%).
**Fact:** the drop is spread over 13 of 14 days (−3% to −8%), not a spike on one or two days, and it fades slowly into album 19. Same number of payers each day; each payer spends a bit less. A one-day bug or event does not fit this shape.

## 2. Hard (A/B definition; Hard was in the test too: finished 29.9% vs 19.6%)
| Window | 3 locked | 5 locked | Gap |
|---|---|---|---|
| Players | 5,756 | 5,640 | |
| 14 days before (Jun 14–27) | $102.85 | $107.26 | −4.1% |
| 2 weeks after album 18 | $83.97 | $80.64 | **+4.1%** (+8.6% after the before gap) |
| 72 days (Jun 28 – Sep 7) | $407.44 | $406.58 | +0.2% (+4.5% after the before gap) |
**Fact:** Hard shows no drop after album 18 (it is up). Small group (≈5.7K a side), so the Hard numbers are noisy; Easy is where the drop is.

## 3. Slide-2 population (Easy level 35+, ≈336K a side), album spend
| | 3 locked | 5 locked | Gap |
|---|---|---|---|
| Before (May 11 – Jun 27, 48 days): $ per player (all players, incl. non-payers) | $15.43 | $15.60 | −1.1% |
| ARPDAU (revenue ÷ active player-days) | $0.568 | $0.574 | −1.1% |
| Total revenue, normalised to the 5-locked group size | $5,197,724 | $5,256,060 | −1.1% |
| Payers / ARPPU | 24.2% / $63.80 | 23.4% / $66.53 | +0.7 points / −4.1% |
| Test window (Jun 28 – Jul 5): ARPDAU | $0.766 | $0.771 | −0.8% |
| Test window: total revenue normalised | $1,341,180 | $1,353,996 | −0.9% |
| Test window: payers | 14.26% | 14.06% | +0.2 points |
$15.43 is $ per player over 48 days (≈ $0.32 per player per day), not ARPPU; ARPPU is ≈ $64. Every normalisation gives the same −1% gap before and during the test.

## 4. Slide-2 numbers with the 14-day before period (Eden 2026-10-29: the pre period is always the 14 days before the test)
Before = Jun 14–27; same Easy level-35+ population (336,223 vs 336,942).
| | 3 locked | 5 locked | Gap |
|---|---|---|---|
| Before: ARPDAU | $0.610 | $0.615 | −0.8% |
| Before: $ per player (14 days) | $5.20 | $5.25 | −0.9% [−4.1, +2.2] |
| Before: total revenue normalised to 5-locked size | $1,750,859 | $1,767,352 | −0.9% |
| Before: payers / ARPPU | 15.43% / $33.69 | 15.18% / $34.56 | +0.3 points / −2.5% |
| Test: ARPDAU | $0.766 | $0.771 | −0.8% |
| Test: total revenue normalised | $1,341,178 | $1,353,996 | −0.9% |
| **Test after removing the 14-day before gap** | | | **ARPDAU +0.1% · $ per player 0.0%** |
A/B-definition usual gap with the 14-day pre (all Easy, in-app $, Jun 14–27): −1.2% (q30), vs −5.4% in the 2 weeks after album 18.

## 5. Who makes up the final gap (14-day pre, $ per player, contributions add up)
| Window | Raw gap | After each state's 14-day before gap | At FU (1.3%) | 6–10 (4.5%) | 11+ (94%) |
|---|---|---|---|---|---|
| 72 days | −$0.29 | −$0.11 | **−$0.16** | +$0.06 | −$0.01 |
| 2 weeks after album 18 | −$0.12 | −$0.08 | −$0.03 | −$0.02 | −$0.03 |
| Album 19 | −$0.12 | −$0.04 | **−$0.09** | +$0.05 | $0.00 |
Over 72 days the whole remaining gap comes from the players already at FU before the test; the far players (94%) add ≈ 0 once their own before gap is removed. The 2-week dip right after album 18 is shared by all three groups.

## 6. What happened to the players at FU before the test (end of album 18, Jul 6)
| Group (8,046 / 8,076 at FU on Jun 27) | Finished | 1–2 missing | Still 3–5 missing |
|---|---|---|---|
| 3 locked | 2,104 (26%) | 2,391 (30%) | 3,551 (44%) |
| 5 locked | 1,188 (15%) | 1,374 (17%) | 5,514 (68%) |
Same for 6–10 before: finished 14% vs 5%, 1–2 short 28% vs 10%. 11+: finished 1.2% vs 0.4%.
Reading: under 3 locked, 1 in 4 of the at-FU players finished (vs 1 in 7) and 3 in 10 were left 1–2 short (vs 1 in 6). Their group spent −8.5% over 72 days; the split by end state inside the group is descriptive only (end state is a result of the test), so we cannot say which of them (finishers or 1–2 short) spent less.
SQL: q34 in claude/domino_fu18_checks_2026-10-29.sql.

## 7. Who mainly made the 72-day gap: state on Jun 27 × spend level in the 14 days before (Jun 14–27, in-app $ a day) — q35
Contribution = cell's test $ ÷ all test players − cell's control $ ÷ all control players; "net" also removes the cell's own 14-day before gap. Total raw gap of these cells −$0.27 per player (the rest = the few players with <3 missing on Jun 27).
| State · spend level before | Players (both groups) | % of players | % of 72-day revenue | 72-day gap [±95%] | Net contribution |
|---|---|---|---|---|---|
| **At FU · $5–20 a day** | 2,305 | 0.2% | 7.3% | −11.4% (±9.6) | **−$0.098** |
| **At FU · >$20 a day** | 545 | 0.04% | 4.6% | −20.8% (±15.7; before −8.6%) | **−$0.067** |
| At FU · ≤$2 | 3,379 | 0.3% | 1.9% | −12.9% (±10.8) | −$0.026 |
| At FU · $2–5 | 1,952 | 0.2% | 2.8% | +7.7% | +$0.020 |
| 11+ · ≤$2 | 55,111 | 4.4% | 17.7% | −4.2% (±4.1; before −1.5%) | −$0.052 |
| 11+ · $0 | 1,119,498 | 89.2% | 22.6% | −1.3% (±4.9) | −$0.038 |
| 11+ · $2–5 / $5–20 | 8,301 | 0.7% | 10.4% | −4.6% / −9.5% (wide) | −$0.059 |
| 6–10 (all levels) | 56,124 | 4.5% | 31.6% | −3.6% … +2.8% | +$0.028 |
Summary: at-FU players who paid $5+ a day before the test (2,850 players, 0.2% of players, 12% of 72-day revenue) make −$0.165 of the net gap — the main source. The rest is small and spread over far low payers, each cell within its noise.

## 8. Did the at-FU heavy payers finish album 18? (q36: end state on Jul 6 by 14-day spend level, at FU on Jun 27)
| Spend level before (Jun 14–27) | Group | Players | Finished | 1–2 missing | Still 3–5 |
|---|---|---|---|---|---|
| >$20 a day | 3 locked | 276 | 52% | 26% | 21% |
| | 5 locked | 269 | 47% | 20% | 33% |
| $5–20 a day | 3 locked | 1,161 | 39% | 32% | 30% |
| | 5 locked | 1,144 | 26% | 20% | 55% |
| under $5 | 3 locked | 6,609 | 23% | 30% | 48% |
| | 5 locked | 6,663 | 12% | 16% | 72% |
Reading: the >$20 players finished about as often in both groups (about half), so 3 locked barely changed their album; their 72-day gap (−21%, already −9% before the test, ±16) is mostly a pre-existing gap plus noise in 545 players, not a test effect. The group where the test changed finishing AND spend fell is $5–20 a day at FU: finished 39% vs 26%, 72-day spend −11% (±10). Corrects section 7's "2,850 players": the test-linked drop sits in ≈2,300 players ($5–20 at FU).

## 9. Who the FU rule touches (from q28, end state Jul 5, A/B definition)
Players with ≤5 stickers missing at the end of album 18: 67,006 (10.7%) of 5-locked Easy players; 81,613 (13.0%) under 3 locked. They bring 86% / 89% of Easy in-app revenue in the test window and 72% / 76% over the 72 days. At-risk group: at FU on Jun 27 and $5–20 a day before, 2,305 players (0.2%), 7% of 72-day revenue, −11%.
Case slide (fucase_slide, after fu3): claude/slide_fu18_case_2026-10-29.py.
