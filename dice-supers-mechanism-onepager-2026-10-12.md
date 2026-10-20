# Dice Dreams — Supers mechanism one-pager (albums 61 vs 63)

Run 2026-10-12 (section 5a added 2026-10-14). Project `dice-dreams-dbt`. SQL: `dice_supers_mechanism_queries.sql` (Q1–Q5b) + `dice_supers_placebo_q5c.sql` (5a).
Population: PU (`is_album_pu`), `is_excluded = FALSE`, `album_login_ratio` on the player's last row before close ≥ 0.5. End state = close−1 (close date is partial). Revenue = `spent_in_album_today` (game revenue on album days, not album-only).
PU: 219,418 (61) / 220,287 (63). PU ARPDAU $3.34 / $3.30. PU finish rate 11.5% / 13.5%.

## Claim (proposed for lock)
- **Known (mechanism):** In Dice, Supers are the final completion gate for payers.
- **Hypothesis (to test):** Adding Super slots to the album (12 → N) raises payer album ARPDAU without lowering payer finish rate. Primary = PU ARPDAU; guardrail = PU finish rate. Not provable from 61 vs 63 → A/B.

## 1. End-of-album unique Supers (PU, close−1) — spend by bin is correlation, not effect
| Unique Supers | 61: % PU | 61: % rev | 61: ARPDAU | 61: finish | 63: % PU | 63: % rev | 63: ARPDAU | 63: finish |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 0–6 | 20.0% | 5.5% | $1.08 | 0.2% | 10.1% | 2.9% | $1.13 | 0.1% |
| 7 | 6.3% | 2.7% | $1.56 | 0.7% | 4.5% | 2.1% | $1.76 | 0.5% |
| 8 | 8.6% | 4.7% | $1.86 | 0.9% | 6.4% | 3.5% | $2.00 | 0.8% |
| 9 | 22.4% | 17.6% | $2.51 | 1.1% | 9.9% | 6.3% | $2.16 | 1.1% |
| 10 | 25.2% | 30.1% | $3.75 | 3.0% | 46.5% | 39.5% | $2.68 | 1.8% |
| 11 | 7.7% | 11.5% | $4.66 | 11.6% | 10.6% | 14.3% | $4.29 | 11.0% |
| 12 | 9.8% | 27.9% | $9.19 | 95.7% | 12.1% | 31.4% | $8.29 | 93.8% |

## 2. FU-1 / FU-2 blocked on a missing Super (PU, close−1)
| | 61 | 63 |
|---|---:|---:|
| PU with ≥1 set one sticker short (FU-1) | 173,546 (79%) | 174,108 (79%) |
| …of them, ≥1 FU-1 set missing its Super | 95.1% | 92.3% |
| FU-1 sets whose missing sticker is the Super | 91.2% | 84.2% |
| PU with ≥1 FU-2 set: ≥1 missing a Super | 97.1% | 96.3% |
| PU with FU-1 or FU-2: ≥1 blocked by a Super | 96.3% | 94.9% |
| Album near-finishers (missing 1 of 144): missing a Super | 74.2% (8,116 PU) | 64.4% (9,099 PU) |
| Near-finishers missing 1: ARPDAU | $6.91 | $6.44 |

## 3. Finishers' last 3 stickers (baseline: Supers = 12/144 = 8.3%)
| | 61 | 63 |
|---|---:|---:|
| PU finishers | 25,224 | 29,782 |
| Last sticker is a Super | 81.8% | 69.3% |
| Last 3 stickers that are Supers (pooled) | 77.2% | 68.1% |
| Finishers with ≥1 Super in last 3 | 99.8% | 99.6% |
| Supers in last 3 obtained via a Wild | ~78% | ~84% |
| Top Wild sources | DP_Big_Chest_WithStamp, Trail Final Reward, 1To2_BigChest, Decoy_BuyAll / Upgrade, OnePlusSixteen | DP_Big_Chest_WithStamp, BuildYourBundle, OnePlusSixteen, Trail Final Reward, Decoy_Upgrade / BuyAll |

## Reading
- Known: Supers are the last gate. ~92–95% of PU one sticker short of a set are short a Super; ~68–77% of finishers' last 3 stickers are Supers (8–9× the 8.3% baseline).
- Known: holding all 12 Supers ≈ finishing (94–96% finish); 10–11 Supers finish at 2–12%.
- Known: the final Supers come mostly through Wilds (~78–84%).
- Hypothesis: most top Wild sources are offers (Big Chest, Decoy, Bundle, OnePlusX) → the end-of-album Super gate is where payers convert. Needs Validation: which sources are paid.
- Not inferable: bins with more Supers spend more, but spending also buys Supers (reverse direction). No causal claim.
- Needs Validation: part of the "blocked by Super" share may be by design (late Super release / locked Supers, Topic 8). Release calendar not checked.
- 61 vs 63 direction is consistent; magnitudes differ (63 has more Golden gates: last-3 Golden 31% vs 22%).

## Recommendation
- **Drop "Disney has 7" as the main argument** — cross-game count is context only.
- **Use the Dice mechanism as the argument, and Test** (+Super slots) with a guardrail: more Super slots = more gates where payers convert, but also more players stuck below 12 (finish rate risk).
- A/B: control 12 Supers vs test N Supers (or a 2-arm design with an extra arm on Wild/Super availability). Primary: PU album ARPDAU (close−1). Guardrails: PU finish rate, share of PU ending with all Supers, next-album retention.

| Mechanic | Source | Target | Evidence | Risk | Required validation | Action |
|---|---|---|---|---|---|---|
| More Super slots per album | Mechanism in Dice (Super = final gate, converted via Wilds) | Dice | Descriptive only (61/63) | Finish rate drop, frustration | A/B, ARPDAU primary + finish guardrail | Test |
| "Fewer rares in Disney" as rationale | Disney 7 vs Dice 12 | — | Cross-game, confounded | Misleading | — | Do Not Adopt Yet |

## 4. Missing 1–2 stickers entering the last 4 full days: Super vs Golden (run 2026-10-12)
Hypothesis tested (Eden): Goldens are sold along the way (new-golden offers); a missing Super pushes the player to a pricier Wild/Joker offer at the end.
State = end of close−5; outcomes in close−4…close−1 vs the player's own pre-window ARPDAU. Population: not excluded, login ratio (last row) ≥ 0.5. Almost all are pre-window payers (shown: all players). SQL: q4 in `dice_supers_mechanism_queries.sql`.

| Album | Missing | Players | Pre ARPDAU | End ARPDAU | End ÷ pre | Paid in last 4 days | Payer-day rate | Rev per paying day | Finished by close−1 |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 61 | 1: Super | 840 | $18.28 | $20.83 | 1.14 | 84% | 0.47 | $44.82 | 68% |
| 61 | 1: Golden | 106 | $12.76 | $17.45 | 1.37 | 68% | 0.36 | $48.34 | 67% |
| 63 | 1: Super | 1,481 | $12.16 | $14.99 | 1.23 | 82% | 0.43 | $35.06 | 69% |
| 63 | 1: Golden | 468 | $8.67 | $9.89 | 1.14 | 68% | 0.30 | $32.58 | 60% |
| 61 | 2: Super+Super | 2,913 | $13.31 | $16.54 | 1.24 | 78% | 0.43 | $38.14 | 39% |
| 61 | 2: Super+Golden | 1,049 | $11.31 | $13.42 | 1.19 | 72% | 0.36 | $37.20 | 48% |
| 61 | 2: Golden+Golden | 22 | $7.54 | $8.43 | 1.12 | 68% | 0.24 | $34.99 | 50% |
| 63 | 2: Super+Super | 4,511 | $13.22 | $17.71 | 1.34 | 76% | 0.43 | $41.61 | 40% |
| 63 | 2: Super+Golden | 4,829 | $6.14 | $7.68 | 1.25 | 52% | 0.24 | $31.92 | 30% |
| 63 | 2: Golden+Golden | 104 | $6.39 | $7.66 | 1.20 | 58% | 0.25 | $31.31 | 34% |

Reading:
- Known: when the missing sticker is a Super, more players pay in the last 4 days (82–84% vs 68%) and on more days (payer-day rate 0.43–0.47 vs 0.30–0.36). Same direction in both albums.
- Known: missing-2 lift orders Super+Super > Super+Golden > Golden+Golden in both albums (61: 1.24 / 1.19 / 1.12; 63: 1.34 / 1.25 / 1.20).
- Not supported: a higher ticket. Revenue per paying day is similar (61: $45 Super vs $48 Golden; 63: $35 vs $33). Day-level spend is not per-transaction price — transaction price check (cut 2) not run.
- Bias: Super-missers already spent more before the window (pre ARPDAU higher in both albums) → selection; 61 Golden group is small (106). Not causal.
- Revised hypothesis: a missing Super raises how many payers convert at the end (frequency), not the ticket size.

## 5. Did Golden-missers already pay for their Supers? (run 2026-10-12)
Same population/timing as section 4: missing exactly 1 album sticker at end of close−5; window = before close−4 (00:00 UTC); album start 12:00 UTC.
Tables: `50_reporting.user_daily_album`, `30_intermediate.fact_user_album_stickers`, `20_core.purchase_completed_vw` (deduped on user + timestamp + external_order_id).
**Link quality: there is no shared ID between a purchase and a sticker receipt.** Everything below that ties a purchase to a sticker is timing (≤10 / ≤60 min) or offer-name match (`purchase.source` = `sticker_source`). "Spend while holding 11 Supers" uses the Super count recorded on the purchase event itself (Needs Validation: pre- or post-purchase state).
QA (Known): purchase-table spend before the window matches `spent_in_album_today` within <1% in every group.

| Measure | 61 Golden | 61 Super | 63 Golden | 63 Super |
|---|---:|---:|---:|---:|
| Players | 106 | 840 | 468 | 1,481 |
| Supers held at close−5 | 12 | 11 | 12 | 11 |
| Purchased before window | 95% | 99% | 96% | 99% |
| Spend before window, avg / P50 | $335 / $155 | $471 / $199 | $294 / $109 | $413 / $191 |
| Purchases before window, P50 | 19 | 25 | 15 | 22 |
| Last Super collected (12th for Golden, 11th for Super), P50 days before window | 0.8 | 0.9 | 0.8 | 1.1 |
| Last Super via Wild | 66% | 56% | 46% | 44% |
| Purchase ≤10 min before last Super (timing) | 70% | 70% | 63% | 66% |
| Purchase ≤60 min before last Super (timing) | 81% | 83% | 82% | 84% |
| …same offer name as the Super's source (≤60 min) | 55% | 49% | 44% | 41% |
| Spend after last Super, before window: avg / P50 | $9 / $0 | $37 / $2 | $4 / $0 | $33 / $13 |
| Paid while holding 11 Supers (purchase-event state) | 75% | 52% | 55% | 74% |

Purchases before the window by what was first-collected within 10 minutes after (timing only):
| Group | Share of spend followed by a new Super | P50 purchase: new Super / new Golden / Common only / nothing |
|---|---:|---|
| 61 Golden | 25% | $9.63 / $6.18 / $4.99 / $6.99 |
| 61 Super | 15% | $9.26 / $6.99 / $5.50 / $6.99 |
| 63 Golden | 22% | $9.73 / $7.74 / $6.69 / $7.99 |
| 63 Super | 14% | $9.61 / $8.67 / $5.99 / $7.60 |
~40–50% of purchases are not followed by any new sticker within 10 minutes.

Reading:
- Known: Golden-missers had already paid (95–96%) and held all 12 Supers; their 12th Super came a median of ~0.8 days before the window, and after it they almost stopped spending (median $0 until the window).
- Known: Golden-missers are lower spenders overall than Super-missers (P50 $109–155 vs $191–199 before the window).
- Timing only: the last Super usually follows a purchase within 10 minutes (63–70% in both groups), often from the same offer name (41–55%). Purchases followed by a new Super have a higher median price (~$9.3–9.7) than those followed by a Golden (~$6–9) or Commons only (~$5–7). No event-level link; **placebo base rate now computed — see 5a (passed).**
- Hypothesis: the last-4-days gap between Super-missers and Golden-missers is partly timing — Golden-missers' Super purchase falls just before the window, Super-missers' falls inside it — plus a lower-spender selection in the Golden group. Not causal.

### 5a. Placebo: is the purchase → last Super timing real? (run 2026-10-14, Q5c)
Same population as section 5 **plus not-first-album** (`user_past_album_count > 0`) — n is smaller than the table above.
Anchor = last Super first-collected before close−4 00:00 UTC. Placebo = same player, same clock time, 24h and 48h earlier (no Super at that moment). All placebo windows fall after album start (eligible = 100%).
Share of players with ≥1 purchase in the window before the anchor:

| Group | n | ≤10 min: real | −24h | −48h | ≤60 min: real | −24h | −48h |
|---|---:|---:|---:|---:|---:|---:|---:|
| 61 Golden | 70 | 71% | 1.4% | 0.0% | 83% | 10.0% | 1.4% |
| 61 Super | 453 | 69% | 3.3% | 1.8% | 83% | 9.5% | 6.6% |
| 63 Golden | 367 | 62% | 0.5% | 0.5% | 84% | 5.2% | 1.9% |
| 63 Super | 1,143 | 64% | 2.0% | 1.0% | 83% | 6.1% | 3.7% |

Reading:
- Known: the ≤10 min share before the last Super (62–71%) is ~20–60× the same player's base rate at the same clock time on a normal day (0–3%). ≤60 min: 83–84% vs 2–10%. Same in both albums and both groups.
- Known: the "purchase right before the last Super" pattern is not explained by heavy payers buying all the time. The timing link is real (still timing only — no shared ID).
- Limitation (Hypothesis): placebo does not condition on the player being in session at the placebo moment, so the base rate may be understated. Even a 5–10× understatement leaves a large gap.
- Not causal: a purchase right before the Super is consistent with "bought to get the Super", but also with offers that bundle a Super/Wild by design. Direction (purchase → Super) is shown by order in time only.
- Status update: section 5 "timing base rate not computed — Needs Validation" → **Known (timing), placebo passed**. Supports the Dice A/B (Super slots); no change to the recommendation (Test).
- Small n: 61 Golden = 70.

## 6. Linking the mechanism to how rares are received over time (Eden, 2026-10-12)
Sources: Topic 4c/4d (`claude/cross-game-comparison-framework.md`, 4d results in session 2026-10-12) and the locked Dice line (`super_sticker_comparison_handoff.md`). Payers, login ratio ≥ 0.5, median.

The story in Dice, in order:
1. Steady accrual. Dice PU get their first new Super on day 3–5 and a new one every 4–5 days. Locked P50 line: 3 by 25% of the album, 4 by 50%, 7 by 75%, 9 by 90%, 10 by 100% (of 12).
2. Plateau below the cap. At close−1 the median PU holds 9–10 of 12 (61: 9, 63: 10). 63: 47% of PU end on exactly 10; only 10–12% reach 12.
3. Late receipts turn into duplicates. In the last quarter Dice PU receive more Supers (P50 6 vs 3 per quarter) but fewer are new (new-rare rate 43–46% vs 51–68% earlier). Duplicates are ~half of all Supers received (43–49%).
4. The missing 2–3 Supers become the completion gate (92–95% of FU-1 PU blocked on a Super; 68–77% of finishers' last 3 stickers are Supers).
5. The gate is closed mostly through Wilds (78–84% of final Supers), usually right after a purchase (timing; placebo passed — 62–71% vs 0–3% base rate, 5a), at a higher median ticket (~$9.5 vs $6–9 for Golden).
Reading (Hypothesis): Dice's pace gets payers to ~80% of Supers for free/cheaply, then the last ~20% are hard to get from random drops (more duplicates), which pushes payers to Wild offers at the end.

Cross-game context (descriptive only):
| | Dice | Domino | Disney |
|---|---|---|---|
| Rares in album | 12 | 8 / 9 | 7 |
| First new rare (PU, P50 day) | 3–5 | 8 | 7–10 |
| Gap between new rares (days) | 4–5 | 6–7 | 6–7 |
| Rares received, P50 (incl. duplicates) | 14–18 | 7 | 5–6 |
| Collected at end (P50, % of rares) | 75–83% | 67–75% | 57–71% |
| Last-quarter new-rare rate (pooled) | 43–46% | 48% / 60% | 39% / 68% |
| Rare = final completion gate? | Known (this doc) | Missing | Missing |
Missing: whether Royals are the end gate and are converted via paid offers in Domino/Disney. Disney 15 has a mid-album spike in new Royals (92% new at 50–75%) — consistent with release-gated Royals (Hypothesis).

Implication for the A/B (Hypothesis):
- More Super slots with the same pace → the plateau stays at a similar count, so more Supers stay missing at the end → more conversion points, but fewer finishers. Primary ARPDAU, guardrail finish rate.
- Possible second arm: keep 12 Supers but change the late-album new-rate (e.g., duplicate protection in the last quarter) — tests whether the gate's difficulty, not the count, drives conversion.
Needs Validation: Super release calendar (part of the late gate may be by design), pity/duplicate rules, which Wild sources are paid.
Suggested slide: "Dice payers reach ~10 of 12 Supers at a steady pace; the last 2–3 become duplicates-heavy and are closed through Wild offers — the end-of-album conversion point."

