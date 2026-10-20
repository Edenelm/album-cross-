# Daily payout by album end status — Mixpanel definitions (2026-10-20)

SQL: `claude/payout_mixpanel_def_queries.sql` (ran: Dice 255 GB `dice-dreams-dbt`, Domino 96 GB `domino-dreams-dbt`, Disney 311 GB `solitaire-dreams-411507`). Staging approved by Eden on 2026-10-20.

## Definitions
- **Population:** standard population payers (paid on any album day incl. close day). End status at the end of the close day: finished (144) / 1 missing / 2–3 missing / 4+ missing.
- **Payout:** the exact Mixpanel formula, as a group total (sum of the numerator over all players in the group ÷ sum of the denominator):
  - **Dice** — tile "Payout" (board 10105792): (rolls in without RV / Roll Timer / Daily Gift / Invite / Deep Links / Pending / DDJ − purchased rolls) ÷ rolls bet (bet_mult + prime_cost). Players above a 1.2M balance are left out.
  - **Domino** — "Total Game Payout" (88122971): (gameplay coins in + level completed) ÷ (level start + wild / undo / extra tiles), in coin-allowance units.
  - **Disney** — "Total RTP": (gameplay coins in − boosters) ÷ level start, in coin-allowance units.
- **Periods:** mid album = close−18..close−5 (pooled). "After" = average of days +1..+3; "week" = average of days +4..+7. Change in % vs mid album.
- **Checks:** all group sizes match `payer-close-day-2026-10-20.md` exactly (payers Dice 175,794 / 182,700; Domino 119,201 / 106,762; Disney 371,049 / 325,842; finishers 17,466 / 22,818 / 7,039 / 10,148 / 19,376 / 16,855).

## Gaps vs Mixpanel (the real definitions, not my choices)
- Dice: `stg_rolls_in_vw` has no `purchase_sku` → one purchase rule (Bundle SKU + Store source) is skipped.
- Disney: the views have no MTX campaign name → the "campaign not offer / store" filter on coins won cannot be applied. Coins from offers in sources like `scrolling` / `gamified_8box` may count as won.
- My choices: a missing source = "" (in Dice → Pending Reward, excluded); 1.2M cohort = balance above 1.2M on any day in the window; Domino Israel/Romania by the event's country code.

## Results (payout %; days close−3 → close+7)

| Game | Album | Group | Players | % of payers | % of album revenue | Mid | Peak −3..−1 | After +1..+3 | Change | Week +4..+7 | Change |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Dice | 61 | Finished | 17,466 | 10% | 26% | 83 | 99 | 68 | −18% | 75 | −9% |
| Dice | 61 | 1 missing | 6,507 | 4% | 7% | 84 | 90 | 76 | −10% | 79 | −6% |
| Dice | 61 | 2–3 missing | 58,664 | 33% | 37% | 87 | 92 | 80 | −8% | 82 | −5% |
| Dice | 61 | 4+ missing | 93,157 | 53% | 30% | 88 | 94 | 81 | −7% | 84 | −4% |
| Dice | 63 | Finished | 22,818 | 12% | 31% | 85 | 98 | 74 | −12% | 76 | −11% |
| Dice | 63 | 1 missing | 7,290 | 4% | 8% | 86 | 92 | 83 | −4% | 80 | −7% |
| Dice | 63 | 2–3 missing | 93,811 | 51% | 44% | 89 | 91 | 88 | −1% | 85 | −5% |
| Dice | 63 | 4+ missing | 58,781 | 32% | 17% | 90 | 93 | 88 | −2% | 85 | −5% |
| Domino | 19 | Finished | 7,039 | 6% | 26% | 77 | 88 | 70 | −9% | 73 | −5% |
| Domino | 19 | 1 missing | 2,776 | 2% | 6% | 78 | 85 | 74 | −5% | 77 | −2% |
| Domino | 19 | 2–3 missing | 12,742 | 11% | 21% | 79 | 82 | 77 | −2% | 77 | −2% |
| Domino | 19 | 4+ missing | 96,644 | 81% | 47% | 80 | 77 | 80 | +1% | 79 | −1% |
| Domino | 20 | Finished | 10,148 | 10% | 34% | 76 | 89 | 63 | −17% | 71 | −7% |
| Domino | 20 | 1 missing | 3,711 | 3% | 6% | 78 | 83 | 69 | −11% | 73 | −7% |
| Domino | 20 | 2–3 missing | 36,540 | 34% | 39% | 79 | 79 | 71 | −9% | 73 | −7% |
| Domino | 20 | 4+ missing | 56,363 | 53% | 21% | 79 | 77 | 73 | −7% | 74 | −6% |
| Disney | 14 | Finished | 19,376 | 5% | 21% | 26 | 76 | 4 | −85% | 21 | −18% |
| Disney | 14 | 1 missing | 10,824 | 3% | 8% | 37 | 56 | 26 | −30% | 36 | −2% |
| Disney | 14 | 2–3 missing | 60,631 | 16% | 30% | 49 | 52 | 48 | −2% | 51 | +4% |
| Disney | 14 | 4+ missing | 280,218 | 76% | 42% | 60 | 54 | 59 | −1% | 63 | +5% |
| Disney | 15 | Finished | 16,855 | 5% | 22% | 36 | 60 | 9 | −73% | 22 | −37% |
| Disney | 15 | 1 missing | 7,406 | 2% | 8% | 43 | 50 | 29 | −32% | 34 | −21% |
| Disney | 15 | 2–3 missing | 42,127 | 13% | 29% | 53 | 55 | 51 | −4% | 50 | −6% |
| Disney | 15 | 4+ missing | 259,454 | 80% | 42% | 63 | 64 | 66 | +5% | 63 | +1% |

Daily series (−3 … +7):
- Dice 61 finished: 93 99 92 84 74 62 68 75 72 76 79 · 4+: 88 94 92 87 86 78 80 85 81 85 86
- Dice 63 finished: 92 98 98 86 79 69 74 76 73 76 79 · 4+: 92 92 93 92 92 86 86 85 84 85 85
- Domino 19 finished: 81 85 88 82 63 68 79 76 70 74 74 · 4+: 75 74 77 74 73 78 90 83 74 80 80
- Domino 20 finished: 89 85 84 80 62 65 62 69 73 73 70 · 4+: 77 73 73 73 74 76 70 70 74 78 74
- Disney 14 finished: 34 54 76 41 −6 4 13 10 8 35 30 · 4+: 49 54 54 64 61 59 58 56 55 76 64
- Disney 15 finished: 37 58 60 32 2 14 13 18 15 29 26 · 4+: 62 64 63 64 68 69 62 64 60 64 65

## Fact
- In all three games, finishers' payout peaks in the last 3 days (Dice 98–99, Domino 88–89, Disney 60–76): the album prizes land then.
- In the 3 days after close, finishers get the lowest payout of all groups: Dice −12% to −18%, Domino −9% to −17%, Disney −73% to −85% vs their own mid album. Finishers = 21–34% of album revenue.
- The closer a player was to finishing, the bigger the drop after close: in 5 of 6 albums the order is finished > 1 missing > 2–3 missing > 4+ missing (Dice 63: 2–3 and 4+ about equal, −1% / −2%).
- Players missing 4+ stay close to their mid-album level (−7% to +5%).
- Recovery: by days +4..+7 finishers are still below mid album (Dice −9% / −11%, Domino −5% / −7%, Disney −18% / −37%).
- Days 1–3 in Dice: every group drops (−1% to −18%); finishers drop most.

## Interpretation (not tested)
- Finishers' mid-album payout is not the "normal" level either: in Disney it is low (26–36 vs 60–63 for 4+). Their gameplay coins go into boosters (B) that the formula subtracts. So their low post-close payout is partly their style of play, not only the new album.
- The drop after close looks like the end of the album/set prizes (which raise payout before close), and in Dice also a drop for everyone at the new album start. A day-by-day breakdown of what is missing from B by source would show which.

## Hypothesis → test
- "Finishers lose a lot of payout in the first days of the new album, and this hurts their spend." Earlier Dice spend check (`dryness-last-week-2026-10-20.md`): finishers and near-missers spent ×0.79–0.90 on days 1–3, far players ×1.0 — same direction. Not causal. Test: give finishers (or 1-missing players) a payout boost on days 1–3 of the new album vs control; measure spend days 1–14 (DiD).

## Not done
- Payout by source after close (which part of B goes missing).
- Disney with the campaign filter (column not in BigQuery).
- The levels are not comparable between games (different formulas); compare the shape only.

## Diagnostics (Eden 2026-10-20: daily axis, peak vs after, why Disney −73..−85%, biases)
SQL: last three sections of `claude/payout_mixpanel_def_queries.sql` (Disney 331 GB, Domino 112 GB, Dice 327 GB). Same population and Mixpanel filters.

### Payout by day — finished vs 4+ missing (payout %; "no prize" = album / set / duplicate prizes taken out of the wins)
| Game · album | Group | Mid | −3 | −2 | −1 | Close | +1 | +2 | +3 | Mid no prize | +1 no prize | +2 no prize | +3 no prize |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Dice 61 | Finished | 83 | 93 | 99 | 93 | 84 | 74 | 62 | 68 | 76 | 74 | 62 | 68 |
| Dice 61 | 4+ | 88 | 88 | 94 | 92 | 87 | 87 | 78 | 80 | 80 | 86 | 78 | 79 |
| Dice 63 | Finished | 85 | 92 | 98 | 98 | 87 | 79 | 69 | 74 | 80 | 79 | 69 | 74 |
| Dice 63 | 4+ | 90 | 92 | 92 | 93 | 92 | 92 | 87 | 86 | 83 | 91 | 86 | 86 |
| Domino 19 | Finished | 77 | 81 | 85 | 88 | 82 | 63 | 68 | 79 | 74 | 63 | 68 | 79 |
| Domino 19 | 4+ | 80 | 75 | 75 | 77 | 74 | 73 | 78 | 90 | 74 | 73 | 78 | 90 |
| Domino 20 | Finished | 76 | 89 | 85 | 84 | 80 | 62 | 65 | 62 | 74 | 62 | 65 | 62 |
| Domino 20 | 4+ | 79 | 77 | 73 | 73 | 73 | 74 | 76 | 70 | 73 | 74 | 76 | 70 |
| Disney 14 | Finished | 26 | 34 | 54 | 76 | 41 | −6 | 5 | 13 | 21 | −7 | 4 | 13 |
| Disney 14 | 4+ | 60 | 49 | 54 | 54 | 64 | 61 | 59 | 58 | 53 | 59 | 58 | 57 |
| Disney 15 | Finished | 36 | 37 | 58 | 60 | 32 | 2 | 14 | 13 | 32 | 1 | 14 | 12 |
| Disney 15 | 4+ | 63 | 62 | 64 | 63 | 64 | 68 | 69 | 62 | 57 | 68 | 68 | 62 |

### What the "peak" is
- The peak before close is the album prize: without prizes, finishers' payout on days −3..−1 is BELOW their mid album (Dice 65–71 vs 76–80; Domino 68–73 vs 74; Disney 17–28 vs 21–32).
- Fair comparison = no-prize mid vs days +1..+3. Finishers: Dice −11% / −8%, Domino −5% / −15%, Disney 21 → 3 and 32 → 9 (levels). 4+ missing: +1% / +6%, +8% / 0%, +9% / +16%.

### Why Disney shows −73..−85%
- Total RTP = (coins won − boosters) ÷ level-start stake: a small difference of two big numbers. Disney 14 finisher, per playing player: mid stake 73, boosters 95, won 113 → (113 − 95) ÷ 73 = 26%. Day +1: stake 86, boosters 110, won 105 → −6% (boosters > wins).
- Boosters per stake stay the same (1.29 → 1.28); wins per stake fall 1.54 → 1.22 (−21%). The large % is the small base, not a data error.

### Where the drop comes from (finishers)
- Dice: free rolls per roll staked 0.83 → 0.62 on day +2; stake per player −26% (61) / −16% (63) vs mid.
- Domino: wins from levels per stake unchanged (1.00 → 0.96 in 19; 0.97 → 0.91 in 20); wins from other features (events) fall from 0.44 → 0.25 (19) and 0.40 → 0.23 (20) of stake. 4+ missing: 0.40 → 0.32 and 0.38 → 0.36.
- Disney: wins per stake −21% (14) / −11% (15); boosters per stake flat (14) or +18% (15).

### Balance (Eden: "finishers have a big balance and still drop")
- Median end-of-day balance of finishers spikes on day −1 (prize) and is spent within 1–2 days: Dice 61: 30 mid → 170 (−1) → 73 (+1) → 30 (+2); Dice 63: 45 → 571 → 142 → 48 rolls. Domino: 1.9–2.6 → 10.5–12.3 → 2.9–3.0 → 2.3–2.5. Disney: 4.9–5.3 → 44–69 → 8–9.5 → 6.5–7.5 (allowance units).
- From day +2 finishers are back at their mid-album balance. Payout is a flow (in ÷ out), so it does not depend on balance.

### Bias checks
- Disney balance filter (0..5,000): drops 0.2–1.9% of finishers' stake and wins on any day → not a bias.
- Domino amount filter (0..1,000): drops 0.0% → not a bias.
- Dice 1.2M-balance cohort: ~120 finishers per day (<1%) left out. With them, finishers' payout is 5–8 points lower on every day (75 vs 83 mid; 69 vs 74 on +1 in 61) → level lower, shape the same.
- Who plays: finishers playing per day falls 3–6% by day +3 → the drop is not a change of who is in the group.
- Group totals weight heavy players more (Mixpanel style). A per-player median check was NOT run.

## Check 2 (Eden 2026-10-20): Disney levels look wrong; compare finishers vs 1 and 2 missing (not 3, not 4+)

### Disney RTP port vs Mixpanel (2026-08-12, all players)
- BigQuery = Mixpanel within 0.2%: level start 35,757,869 vs 35,701,132; level completed 32,402,201 vs 32,347,581; extra tiles 14,336,804 vs 14,317,410; purchase 4,017,876 vs 4,013,849.
- The "MTX campaign name not offer / store" filter changes nothing in Mixpanel (coins in 61,013,709 with and without) → the missing column is not a gap.
- Mixpanel Total RTP for all players that day ≈ 62% (C 46.6M − B 24.4M) ÷ A 35.7M.
- Why finishers are low: they buy coins and spend them on boosters. The formula subtracts all boosters but counts only gameplay wins (purchase, harvest, daily_reward are not in C). Mid album 14, per playing player: finished — stake 65, boosters 79, wins 94, bought coins 36 → RTP 23%; 4+ — 33 / 24 / 43 / 5 → 58%. Wins ÷ (stake + boosters): 66% vs 75%.

### Finished vs 1 missing vs 2 missing (payout without album prizes; Disney = level, others % change vs own mid)
| Game · album | Finished: mid → avg +1..+3 | 1 missing | 2 missing | Players / % payers / % album revenue (fin · 1 · 2) |
|---|---|---|---|---|
| Dice 61 | 76 → 68 (−11%) | 78 → 75 (−3%) | 79 → 78 (−2%) | 17,466 / 10% / 26% · 6,507 / 4% / 7% · 18,019 / 10% / 14% |
| Dice 63 | 80 → 74 (−8%) | 82 → 82 (0%) | 82 → 86 (+5%) | 22,818 / 12% / 31% · 7,290 / 4% / 8% · 21,042 / 12% / 15% |
| Domino 19 | 74 → 70 (−5%) | 75 → 74 (−2%) | 75 → 76 (+1%) | 7,039 / 6% / 26% · 2,776 / 2% / 6% · 5,460 / 5% / 10% |
| Domino 20 | 74 → 63 (−15%) | 74 → 69 (−7%) | 75 → 70 (−6%) | 10,148 / 10% / 34% · 3,711 / 3% / 6% · 10,533 / 10% / 14% |
| Disney 14 (RTP level) | 21 → 3 | 32 → 25 | 40 → 39 | 19,376 / 5% / 21% · 10,824 / 3% / 8% · 19,197 / 5% / 11% |
| Disney 15 (RTP level) | 32 → 9 | 39 → 29 | 47 → 41 | 16,855 / 5% / 22% · 7,406 / 2% / 8% · 11,284 / 3% / 9% |
| Disney 14 wins ÷ all spent | 65 → 57 (−12%) | 68 → 62 (−9%) | 70 → 67 (−4%) | |
| Disney 15 wins ÷ all spent | 67 → 58 (−13%) | 69 → 64 (−7%) | 71 → 68 (−4%) | |

Daily no-prize series (mid, −3..+3), finished / 1 / 2:
- Dice 61: 76 70 71 64 61 74 62 68 / 78 75 74 73 73 81 71 74 / 79 79 78 79 79 84 73 76
- Dice 63: 80 69 72 71 67 79 69 74 / 82 77 77 78 77 88 78 81 / 82 83 81 85 85 90 83 84
- Domino 19: 74 73 73 71 66 63 68 79 / 75 77 80 76 70 65 72 84 / 75 76 77 75 69 67 74 87
- Domino 20: 74 72 69 68 64 62 65 62 / 74 75 71 68 68 68 72 67 / 75 72 68 67 69 71 72 68
- Disney 14 RTP: 21 20 25 28 7 −7 4 13 / 32 27 37 42 33 22 24 30 / 40 27 36 42 44 38 39 41
- Disney 15 RTP: 32 23 27 17 2 1 14 12 / 39 28 35 33 19 24 34 28 / 47 34 42 41 35 41 44 39

Fact: in all 6 albums finishers drop more after close than players 1 or 2 short. Players 1 short drop a little (0% to −9%); 2 short are flat (−6% to +5%).

## Check 3 (Eden 2026-10-20): per-player median; Disney metric = wins ÷ total spend
SQL: "PER-PLAYER MEDIAN CHECK" section of `claude/payout_mixpanel_def_queries.sql` (Disney 311 GB, Domino 82 GB, Dice 222 GB).
Per player: own no-prize payout mid album (close−18..−5) and days +1..+3; players who played in both periods. Ratio = days +1..+3 ÷ mid (1.00 = no change).
Disney metric (Eden's choice 2026-10-20): gameplay wins without album prizes ÷ (level-start stake + boosters).

| Game · album | Group | Players | Median mid | Median +1..+3 | Ratio p25 | Ratio median | Ratio p75 | % players lower |
|---|---|---|---|---|---|---|---|---|
| Dice 61 | Finished | 17,060 | 80 | 83 | 0.82 | 1.03 | 1.14 | 45% |
| Dice 61 | 1 missing | 6,360 | 81 | 84 | 0.91 | 1.03 | 1.13 | 42% |
| Dice 61 | 2 missing | 17,655 | 81 | 82 | 0.89 | 1.02 | 1.11 | 45% |
| Dice 63 | Finished | 22,270 | 84 | 87 | 0.83 | 1.04 | 1.12 | 42% |
| Dice 63 | 1 missing | 7,063 | 84 | 89 | 0.95 | 1.05 | 1.12 | 34% |
| Dice 63 | 2 missing | 20,468 | 84 | 89 | 0.95 | 1.05 | 1.12 | 35% |
| Domino 19 | Finished | 6,842 | 75 | 64 | 0.72 | 0.88 | 1.04 | 69% |
| Domino 19 | 1 missing | 2,702 | 74 | 67 | 0.78 | 0.93 | 1.09 | 62% |
| Domino 19 | 2 missing | 5,241 | 73 | 69 | 0.81 | 0.96 | 1.12 | 56% |
| Domino 20 | Finished | 9,778 | 73 | 58 | 0.67 | 0.81 | 0.94 | 83% |
| Domino 20 | 1 missing | 3,573 | 72 | 63 | 0.75 | 0.88 | 1.01 | 74% |
| Domino 20 | 2 missing | 10,184 | 72 | 62 | 0.75 | 0.89 | 1.01 | 72% |
| Disney 14 | Finished | 18,902 | 72 | 56 | 0.67 | 0.81 | 0.96 | 81% |
| Disney 14 | 1 missing | 10,472 | 74 | 63 | 0.74 | 0.88 | 1.02 | 71% |
| Disney 14 | 2 missing | 18,412 | 75 | 66 | 0.76 | 0.91 | 1.04 | 67% |
| Disney 15 | Finished | 16,480 | 71 | 60 | 0.74 | 0.87 | 1.00 | 74% |
| Disney 15 | 1 missing | 7,213 | 72 | 66 | 0.80 | 0.94 | 1.08 | 61% |
| Disney 15 | 2 missing | 10,994 | 73 | 69 | 0.84 | 0.97 | 1.10 | 56% |

### Fact
- Disney and Domino: the typical finisher gets 12–19% less payout in days +1..+3 than in their own mid album; 69–83% of finishers are lower. Players 1 or 2 short drop less (3–12%), in the same order every album.
- Dice: the typical finisher does NOT drop (×1.03 / ×1.04; 42–45% lower = half). The group-total drop in Dice (−8% / −11%) comes from heavy players; only the lowest quarter of finishers drops (p25 0.82–0.83 vs 0.89–0.95 for near-missers).
- Domino 20: players 1–2 short drop almost as much as finishers (×0.88–0.89 vs ×0.81) → part of the drop is a new-album effect for everyone near the end.

### Bottom line
- Disney: clear and robust — finishers get a weaker game in the first days of the new album (wins per coin spent −13% to −19% per player). Finishers = 21–22% of album revenue.
- Domino: same direction, a bit weaker; in album 20 it also hits near-missers. The missing part is event rewards (levels pay the same).
- Dice: no effect for the typical finisher → no action on payout.

### Recommendation (adopt / test / not yet)
- Disney — TEST: a "soft landing" for finishers (and 1-missing) in days 1–3 of the new album (e.g. higher coin rewards or cheaper boosters) vs control. Measure spend and active days in days 1–14 (DiD, per-user 14-day pre-period). Size of the boost = management decision.
- Domino — TEST, second priority: a starter tier / head start in the first event of the new album for players who were near the end (finished + 1–2 short), since the drop is in event rewards. Same KPIs.
- Dice — DO NOT ADOPT YET: the typical finisher is not affected; if anything, look only at heavy finishers (top quarter) and first check whether their spend drops.
- Not causal: a lower payout after close does not prove lower spend. Spend link was checked only in Dice (days 1–3 ×0.79–0.90 for finishers and near-missers) — that is why the next step is a test, not a change.
