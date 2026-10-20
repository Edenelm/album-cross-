# Endgame S1–S4: Disney 14/15 vs Dice 61/63 vs Domino 17/19 — sale window, payer state, outcomes, potential (2026-10-15)

Continues `claude/endgame-last-week-2026-10-14.md`. Same population (not-first PU, spend>0 before close, login ratio ≥0.5 on last row, close day excluded, finish = 144 from the daily table). d = date − close. Revenue = gross USD (`album_spent_today` / `spent_in_album_today`). Domino not run.

## UPDATE 2026-10-15 (round 2): Eden's classification rule + Domino
- **Rule (Eden, Known):** anything not bought with money = **gameplay**; anything bought = **purchase**. Market tokens are earned by playing (or bought), but the Market itself is **gameplay**. Same for event Wilds/Jokers (e.g. Dice Trail Final Reward = gameplay even though it is hard).
- **Disney under the rule:** purchase-Joker sale opens d−2 (album 14: 0 → 4,360) / d−3 (album 15: 4,198). Market Joker (gameplay) opens d−3 (14) / d−2 (15). Among payers 2–3 short at d−8, purchase pick 9% / 13%, Market (gameplay) pick 15% / 8%.
- **Domino purchase flag:** campaign `t_Offer` (excl. SeasonPass/DreamPass/Info, excl. rewarded-video `ecn_Rewa`), `t_Store`, source `purchase` or `1+*`, `ActivePassToGetJoker`. Validation: flagged Joker groups are 99.8–100% ≤10 min after a purchase; Market Joker 12%, Puzzle Joker 28%, PuzzleBlitz joker 31%, Missions 24% → gameplay.

### Domino S1 (all users, distinct players/day)
| d | 17 Joker purchase | 17 Joker Market | 17 Joker gameplay (all) | 19 Joker purchase | 19 Joker gameplay (all) |
|---|---|---|---|---|---|
| −14…−11 | 20–38 | 0 | 2.3–3.6K | 10–19 | 0.2–0.5K |
| −10…−8 | 419–964 | 0–1 | 5.2–12.7K | 21–28 | 0.6–7.4K |
| −7 | **1,989** | 3,456 | 9,516 | 26 | 8,945 |
| −6 | 1,046 | 8,801 | 9,345 | 613 | 5,933 |
| −5 | 2,982 | 3,653 | 7,846 | **1,440** | 3,894 |
| −4 | 3,353 | 0 | 4,337 | 1,659 | 3,644 |
| −3 | 3,245 | 0 | 1,588 | 1,768 | 9,455 |
| −2 | 2,268 | 0 | 3,142 | 772 | 19,584 |
| −1 | 1,706 | 0 | 4,567 | 961 | 35,628 |
Purchase sale opens d−7 (17) / d−5 (19), but at much smaller scale than Dice (peak 3.4K / 1.8K vs Dice 13–15K). Album 19 closes mostly through gameplay Jokers (Puzzle Blitz, Trail, Temple, Wheel, Missions: 35.6K on d−1). Album 17 Market (AlbumBonusKiosk) ran d−7…−5 only.

### Domino S2/S3 (per d−8 bucket; 0–1 short merged into 2–3)
| Bucket | Metric | Domino 17 | Domino 19 |
|---|---|---|---|
| finished by d−8 | n | 131 | 8 |
| 1 / 2–3 short | n | 154 / 2,196 | 68 / 1,533 |
| 2–3 | finish / purchase pick / gameplay pick / lift | 47% / 21% / 24% / 0.81 | 47% / 20% / 66% / 0.84 |
| 4–6 | n / finish / purchase pick / gameplay pick / lift | 14,536 / 19% / 15% / 21% / 0.77 | 22,685 / 11% / 6% / 42% / 0.77 |
| 7–10 | finish / lift | 6.7% / 0.93 | 4.3% / 1.04 |
| 11–20 | finish / lift | 2.2% / 1.55 | 1.8% / 1.98 |
| 21+ | finish / lift | 0.6% / 2.24 | 0.2% / 2.63 |
| All | population lift | 0.93 | 0.95 |
State at d−5 (finished / 1 short / 2–3 short): 17 = 2,206 / 1,561 / 12,032; 19 = 118 / 291 / 3,884. Top gate missing at d−8: G106 (17) 85–99.9%, R107 (19) 86–99.9% except the 0–1 buckets.

### Three-game read (Known unless marked)
| | Dice 61/63 | Domino 17/19 | Disney 14/15 |
|---|---|---|---|
| Purchase pick sale opens | d−7 / d−7 | d−7 / d−5 (small) | d−2 / d−3 |
| Finish rate, 2–3 short at d−8 | 39% / 39% | 47% / 47% | 21% / 20% |
| Finish rate, 4–6 short | 15% / 16% | 19% / 11% | 7% / 8% |
| Main closing route | purchase Wild | 17 mixed; 19 gameplay Joker | purchase + Market Joker in last 3 days |
| Lift 4–6 short | 0.79 / 0.85 | 0.77 / 0.77 | 0.87 / 0.82 |
- Disney is lowest on completion in every bucket; lifts are similar across all three.
- Disney potential with Domino rates (Hypothesis): +7.3K–14.2K (14) / +7.7K–11.6K (15) finishers among payers ≤6 short; revenue range −$0.40M…−$0.04M (14) / +$0.63M…+$1.16M (15) → still not robust.
- Domino shows a completion route that is mostly gameplay (album 19) and still finishes the most near-finishers → the lever for Disney may be an earlier pick window (purchase or gameplay), not only a paid offer. Hypothesis.

## Bottom line (round 1, Disney vs Dice)
- **Eden's premise holds (Known).** Dice opens the paid pick sale (Wild via `Pricing_*` pack) on **d−7** in both albums; Disney opens the Joker sale at scale on **d−3**. Disney window ≈ 3 days vs Dice 7.
- **At d−8 both games look the same (Known):** almost nobody is ≤1 short; 98–99.9% of every bucket still lacks the top gate sticker. The difference is what happens in the last week.
- **Per d−8 bucket, Dice finishes ~2× (2-3 short) to ~3–9× (7+ short) as many payers as Disney (Known).** Paid-pick uptake among 2-3 short: Dice 48% vs Disney 9–13% (paid) / 19–22% (paid or Market).
- **Revenue lift vs baseline within each bucket is about the same in both games** (e.g. 4-6 short: Dice 0.79/0.85, Disney 0.87/0.82). Revenue upside from "Dice-like lift" is not robust: −$0.46M…+$0.13M (album 14), +$0.30M…+$0.86M (album 15). **Hypothesis, not decision-grade.**
- **The robust gap is completions:** with Dice finish rates per bucket, Disney would have had **+9.4K–11.0K (14) / +7.6K–8.7K (15)** extra finishers among payers ≤6 short at d−8 (+54–79% vs 14,037 / 13,184). Hypothesis (different gate design). Value of a completion (next-album retention/ARPDAU) is not measured here.

## S1 — Sale open day (all users; distinct players per day)
Open = first day ≥3× baseline and ≥1,000 buyers.

| d | Dice 61 paid Wild | Dice 63 paid Wild | Disney 14 Joker paid / Market | Disney 15 Joker paid / Market |
|---|---|---|---|---|
| −14…−8 | 0–1 | 0 | 0–371 / ≤7 | 0–904 / ≤2 |
| −7 | **4,271** | **4,659** | 1 / 4 | 584 / 2 |
| −6 | 6,303 | 8,683 | 0 / 2 | 512 / 1 |
| −5 | 5,803 | 6,985 | 0 / 3 | 532 / 2 |
| −4 | 8,560 | 9,808 | 3 / 248 | 201 / 0 |
| −3 | 12,006 | 13,427 | 0 / **3,364** | **4,198** / 180 |
| −2 | 12,879 | 14,569 | 4,360 / 8,909 | 4,709 / 8,845 |
| −1 | 13,110 | 14,745 | 8,825 / 23,402 | 8,810 / 18,610 |

- Dice paid "specific" Golden packs also jump on d−7 (61: 13–20K/day → 70.8K; 63: 12–35K → 43.8K).
- Disney Joker offers in the last 4 days: 1+15 BlackFriday, 2PO BTA Royal, 1+9 JokerOffer, Riches (14); 1+12 Cinderella, 1+9 JokerOffer, BuildYourBundle, 1+15 NewYear's (15). Market Jokers: AlbumTwister (withGP), 4thofJuly Market (14); Potion Market (15).
- Album 15 had a small paid-Joker trickle d−8…−5 (~500–900/day), ~1/10 of Dice's d−7 size.
- Caveat: Disney counts new stickers only (table is first-collection); Dice counts all receipts (Wild fills are new by design).

## S2 — Payer state at end of d−8 (n; share missing top gate sticker)
| Bucket (missing) | Dice 61 | Dice 63 | Disney 14 | Disney 15 |
|---|---|---|---|---|
| 0–1 | 7 | 3 | 0 | 1 |
| 2–3 | 2,216 (84%) | 1,946 (98%) | 16,033 (98%) | 23,367 (88%) |
| 4–6 | 29,645 (99%) | 61,868 (99.6%) | 88,868 (99.7%) | 50,610 (97%) |
| 7–10 | 28,256 | 40,670 | 129,677 | 52,243 |
| 11–20 | 58,946 | 47,890 | 92,732 | 75,866 |
| 21+ | 57,262 | 28,472 | 42,983 | 123,068 |
| Total | 176,332 | 180,849 | 370,293 | 325,155 |
Top gate = S143 (61), S132 (63), R131 (Disney). Avg gate-trio stickers missing ≥2.9 in every bucket except Dice 2–3 (2.2/2.4).

**At end of d−5** (finished / 1 short / 2–3 short): Dice 61 770 / 544 / 8,624; Dice 63 1,174 / 1,513 / 28,309; Disney 14 6 / 1,009 / 48,238; Disney 15 6 / 171 / 32,026. Dice's run has started by d−5; Disney's has not.

## S3 — Outcomes per d−8 bucket
| Bucket | Metric | Dice 61 | Dice 63 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|
| 2–3 | finish rate | 39% | 39% | 21% | 20% |
| | bought paid pick (d−7…−1) | 48% | 48% | 9% (any incl. Market 22%) | 13% (19%) |
| | rev/player/day base → last wk (lift) | $23.5→16.2 (0.69) | $19.8→14.0 (0.71) | $18.0→12.7 (0.71) | $17.1→11.2 (0.65) |
| 4–6 | finish | 15% | 16% | 7.3% | 8.3% |
| | paid pick | 26% | 30% | 4% (11%) | 7% (13%) |
| | lift | 0.79 | 0.85 | 0.87 | 0.82 |
| 7–10 | finish / lift | 9.4% / 1.10 | 9.0% / 1.33 | 2.5% / 1.18 | 3.4% / 0.96 |
| 11–20 | finish / lift | 7.5% / 1.42 | 7.5% / 1.80 | 0.8% / 1.67 | 2.1% / 1.22 |
| 21+ | finish / lift | 3.5% / 1.96 | 2.8% / 2.02 | 0.3% / 2.69 | 0.8% / 1.86 |
| All | population lift | 1.03 | 1.01 | 0.93 | 0.85 |

d−7…−5 vs base (per day), 4–6 bucket: Dice 0.73/0.74, Disney 0.85/0.74 — no early dip specific to Disney.
Lift <1 in the top buckets in both games is mostly selection (players who reached 2–3 short spent heavily in the baseline week), so compare across games, not to 1.0.

## S4 — Potential (Hypothesis)
- **Revenue:** Σ n × base rev × 7 × (Dice lift − Disney lift), low/high across Dice 61/63: album 14 **−$456K…+$132K** (last-week revenue $5.90M); album 15 **+$298K…+$862K** ($5.40M). Album 15 baseline is inflated by Sugar Rush (R131 at d−10/−11), which depresses its lift. Not robust → Do Not Adopt Yet as a revenue case.
- **Completions:** payers ≤6 short at d−8 who did not finish: Disney 95,030 / 65,136; Dice 26,624 / 52,913. At Dice finish rates: +9.4K–11.0K (14), +7.6K–8.7K (15) Disney finishers.
- **Proposed Test (Disney A):** open a Joker / R131 offer from d−7 for payers ≤6 short at d−8. Primary: finish rate and PU revenue per player d−7…−1 (co-primary). Guardrails: d−3…−1 Joker revenue (cannibalization), finishers' post-finish revenue, next-album d1–14 ARPDAU and retention. Status: **Test**.

## Labels
- Known: S1 timings, S2 states, S3 rates and lifts (descriptive).
- Needs Validation: whether Disney Market Jokers cost real money; Disney release calendar for R131 (locked vs just scarce).
- Hypothesis: revenue and completion upside; that an earlier window causes more completions.

## SQL (all dry-run first; total ≈ 110 GB; largest 60.2 GB)
Saved at `/tmp/claude-0/-home-claude/11de6d96-6a2f-53c0-919c-078ec1a82f1f/scratchpad/` (`disney_s23.sql`, `s4.py`). S1 Disney: `dim_user_album_stickers`, new stickers with `new_sticker_source` in purchase/purchase_gift (paid) or marketplace × `collected_by_joker_flag`, distinct users per d. S1 Dice: `fact_user_album_stickers`, `collected_from_wild` AND `sticker_pack_key LIKE 'Pricing%'`. S2/S3: daily table u at ≤ c−8 / ≤ c−5; revenue windows c−14…c−8, c−7…c−5, c−4…c−1; pick buyers from the sticker tables in c−7…c−1; gate ownership by first-collection date ≤ c−8. Dice 0–1 bucket merged into 2–3 for S4 math.

## Round 3 (2026-10-15): why Domino's last-week/baseline revenue ratio is low
Domino 17/19, same population; bucket = stickers missing at end of d−8; route = Joker in d−7…−1 (purchase / gameplay only / none). Query: `/home/claude/domino_rev_check.sql` (14.8 GB).

| Bucket | Route | n 17 / 19 | Finish 17 / 19 | Pay rate base→last 17 / 19 | $/pay day base→last 17 / 19 | Lift 17 / 19 |
|---|---|---|---|---|---|---|
| 4–6 | all | 14,536 / 22,685 | 19% / 11% | 41→31% / 36→25% | $23.4→24.0 / $18.6→20.4 | 0.77 / 0.77 |
| 4–6 | purchase Joker | 2,191 / 1,278 | 60% / 56% | 49→51% / 46→50% | $34→39 / $33→45 | 1.17 / 1.48 |
| 4–6 | gameplay Joker only | 2,173 / 8,536 | 45% / 20% | 44→41% / 40→36% | $26→29 / $20→21 | 1.05 / 0.99 |
| 4–6 | no Joker | 10,172 / 12,871 | 4% / 0% | 38→24% / 32→15% | $20→15 / $16→11 | **0.49 / 0.34** |
| 0–3 | all | 2,481 / 1,609 | 52% / 49% | 53→42% / 59→48% | $43.7→43.6 / $50.9→51.7 | 0.79 / 0.83 |
| 0–3 | no Joker | 1,546 / 498 | 32% / 2% | 51→36% / 51→27% | | 0.66 / 0.32 |
| 7–10 | all / purchase / gameplay / none | 37,637 / 27,345 | 6.7% / 4.3% | | | 0.93 / 1.04; 1.94 / 2.65; 1.50 / 1.63; 0.58 / 0.50 |

Read (Known, descriptive):
- The drop is in **pay rate**, not in $ per paying day (flat or up in every bucket).
- It comes from the **no-Joker group** — 57–70% of the 4–6 bucket — whose pay rate halves and who almost never finish. Purchase-Joker players rise (1.17–1.48); gameplay-only players hold flat (0.99–1.05).
- Round-2 hypothesis "gameplay Jokers replace payment" is **not supported**: gameplay-only players do not drop. Hypothesis "Joker already in baseline" is **rejected**: 70% (17) vs 21% (19) had a Joker in the baseline week, yet both lifts are 0.77.
- Gap vs Dice is small in 4–6 (0.77 vs 0.79/0.85); larger in 7–10 (0.93/1.04 vs 1.10/1.33).
- Hypothesis: low ratio = **disengagement of players who do not get a pick at all**. Route groups are self-selected (engaged players pick), so route lifts are not causal. Same cut not yet run for Dice/Disney.

## Round 4 (2026-10-15): bias reduction — matched within game + cross-game at same stratum
Strata = stickers missing at d−8 × baseline spend tier ($/day in d−14…−8: 0, <2, 2–5, 5–15, 15+). Route = pick in d−7…−1 (purchase / gameplay only / none). "std" = directly standardized to the bucket's tier mix. SQL: `/home/claude/matched/{domino,dice,disney}.sql` (13.1 + 6.8 + 21.6 GB).

### 1. Within game, 4–6 short at d−8, standardized ($/player/day)
| Game/album | Purchase: base → last (ratio) / finish | Gameplay only | None |
|---|---|---|---|
| Dice 61 | $8.3→11.9 (1.43) / 52% | $8.8→8.0 (0.91) / 10% | $7.6→3.1 (0.41) / 0% |
| Dice 63 | $6.0→9.5 (1.58) / 53% | $5.9→5.7 (0.95) / 4% | $5.4→2.0 (0.36) / 0% |
| Domino 17 | $10.6→14.5 (1.37) / 55% | $9.7→10.6 (1.10) / 43% | $8.9→4.2 (0.47) / 4% |
| Domino 19 | $7.7→14.5 (1.89) / 51% | $6.6→6.7 (1.02) / 20% | $6.3→2.0 (0.32) / 0% |
| Disney 14 | $5.0→10.1 (2.03) / 64% | $4.7→8.1 (1.71) / 59% | $4.4→3.0 (0.69) / 0% |
| Disney 15 | $6.0→11.3 (1.89) / 54% | $5.8→9.3 (1.61) / 45% | $5.4→3.2 (0.59) / 0% |
- Matching on baseline spend closes most of the baseline gap (was $16.8 / $11.6 / $7.5 raw in Domino 17), but last-week gaps stay large → spend level alone does not explain them; residual bias (engagement, intent) remains. Not causal.
- **Finish by route is largely mechanical:** without a pick in the last week, finishing is ~0% in all three games (gate stickers come almost only via Wild/Joker). Compare finish only purchase vs gameplay.
- Gameplay-only pick: revenue flat in Dice/Domino (0.91–1.10) but **up 1.6–1.7× in Disney** (Market Joker; Market tokens can be bought or played for — Needs Validation whether that spend is token purchases).
- No pick: revenue falls to 0.32–0.69 of baseline in every game.

### 2. Cross-game at the same stratum (all routes), finish rate / last÷base revenue
| Stratum | Dice 61 / 63 | Domino 17 / 19 | Disney 14 / 15 |
|---|---|---|---|
| 4–6 short, $2–5/day | 15% / 19% · 0.91 / 0.96 | 12% / 8% · 0.92 / 0.90 | 8% / 8% · 0.95 / 0.93 |
| 4–6 short, $5–15/day | 18% / 23% · 0.79 / 0.78 | 20% / 13% · 0.80 / 0.75 | 11% / 10% · 0.79 / 0.75 |
| 4–6 short, $15+/day | 25% / 31% · 0.71 / 0.70 | 39% / 26% · 0.70 / 0.70 | 16% / 14% · 0.70 / 0.66 |
| 7–10 short, $5–15/day | 13% / 14% · 0.85 / 0.84 | 11% / 7% · 0.76 / 0.79 | 4.5% / 4.6% · 0.75 / 0.72 |
| 7–10 short, <$2/day | 8% / 8% · 1.62 / 1.70 | 4% / 3% · 1.39 / 1.27 | 2% / 2% · 1.18 / 1.14 |
- **For comparable players, the revenue ratio is almost identical across the three structures** (4–6 short: ~0.70–0.96 by tier in all games). Differences appear only among low spenders 7–10 short (Dice higher).
- **Finish rate differs:** Disney is lowest in every stratum (~half of Dice). Dice ≥ Domino except Domino 17 high spenders.
- Read (Hypothesis): the sale-window structure relates to **completions**, not to revenue per comparable payer. Album/game design differences remain a confound; only an A/B test settles it.

