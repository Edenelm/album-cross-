# VIP at album end: review of the handoff, steps 1–2 (2026-10-24)

Source under review: Eden's `vip_album_end_analysis_handoff.md` (Downloads). SQL: `claude/vip_status_recount_2026-10-24.sql`.

## Step 1: did the Dice "Exclusive VIP Gift" run in albums 63 and 65?
Campaign names from `dice-dreams-dbt.20_core.dim_campaign`: the gift is the **"VIP FU album treatment"**. Production runs: 190326 (End_of_Album_treatment, Starter Kit), 270426, 170626, 190726, 010926, 131026 (QA / test copies left out).
Recipients in `dice-dreams-dbt.40_mart.fact_dynamic_resource_given` (48.9 GB):

| Campaign | Days given | Album running | Users | Reward keys |
|---|---|---|---|---|
| 010926_VIP_VipFualbumtreatment_GM | Sep 1–2 | 63 (day 37–38 of 43; close Sep 7) | 2,928 | hidden_economy, blue_diamond_v2 |
| 131026_VIP_VipFualbumtreatment13Or10Or26_GM | Oct 8–14 | 65 (day 32–38 of 43; close Oct 19) | 3,974 | hidden_economy (+ bwf_token for 444) |
| 190726_VIP_VipFualbumtreatment_GM | none found Jul 15 – Oct 24 | 61 | – | – |

- **Fact:** the gift ran in albums 63 and 65, about one week before the album closed, to about 3–4K players.
- **Fact:** it is given in the album AFTER the one the player missed. Players who missed album 63 by 1–3 got it Oct 8–14, i.e. 31–37 days after album 63 closed.
- **Consequence:** the handoff's 28-day window after album 63 (Sep 8 – Oct 5) ends BEFORE these players got the gift. "Dice has the gift and the near-missers still spend 18% less" does not measure the gift. The claim is not valid.
- Open: the gift's sticker does not appear as a resource here (keys are counters / currencies); the sticker itself is likely logged in the sticker table. Who exactly got it (VIP? missed by exactly 3?) is not checked.

## Step 2: end-of-album status by LTV tier, deck definitions
Population: standard population (not first album, not excluded / cheater, login ratio ≥ 0.5 on the last row before close, row on close−1), payer = spend > 0 incl. close day. Finisher = 144 unique set stickers by the END of the close day (Dice from `30_intermediate.fact_user_album_stickers`). Tier = LTV at album start (Dice `ltv_until_album_start`, Domino / Disney `ltv_on_album_start`). Revenue = album-table spend start..close−1; % = of all standard-population payers.

| Game / album | VIP payers | % of payers | % of album revenue | Finished | 1–3 missing | 4+ missing | 1–3 among non-finishers | VIP 1–3: % of album revenue | Finish rate $1K–5K / <$1K |
|---|---|---|---|---|---|---|---|---|---|
| Dice 63 | 12,262 | 6.0% | 26.4% | 29% | 50% | 21% | 70% | 12.2% | 19% / 9% |
| Dice 65 | 12,798 | 6.6% | 29.1% | 30% | 42% | 28% | 60% | 10.9% | 19% / 8% |
| Domino 19 | 2,668 | 2.2% | 17.8% | 31% | 27% | 42% | 39% | 4.5% | 11% / 4% |
| Domino 20 | 2,847 | 2.7% | 19.7% | 40% | 38% | 22% | 64% | 5.4% | 17% / 7% |
| Disney 14 | 3,831 | 1.0% | 8.8% | 29% | 40% | 30% | 57% | 3.6% | 14% / 4% |
| Disney 15 | 4,402 | 1.4% | 12.2% | 31% | 35% | 33% | 51% | 4.6% | 14% / 4% |

Average album spend per VIP payer (finished / 1–3 / 4+): Dice 63 $786 / $487 / $290 · Dice 65 $869 / $474 / $251 · Domino 19 $1,592 / $849 / $423 · Domino 20 $1,349 / $647 / $436 · Disney 14 $1,371 / $934 / $500 · Disney 15 $1,486 / $1,068 / $501.

Against the handoff:
- VIP counts match within 0–4% (Dice 65 12,798 vs 12,799; Domino 20 2,847 vs 2,855; Disney 15 4,402 vs 4,581).
- Finish rates are 0–4 points LOWER with the 144-sticker count than with the game's finisher flag (Dice 65 30% vs 32.8%; Disney 15 31% vs 35.2%; Domino 20 40% vs 40.8%). The flag counts some players with fewer than 144 by our sum (seen before: Disney ~7–8%, Domino 1–4%).
- My concern that close-day finishers sat in the Dice "1–3" group was overstated: the handoff used the game flag, which already counts more finishers. The groups hold.
- New: Domino 19 has many more far VIP (42%) than Domino 20 (22%); the near share swings by album.

## Reading
- **Fact:** VIP are 1–7% of payers and 9–29% of album revenue. About 30–40% finish; most non-finishers end 1–3 short (except Domino 19).
- **Fact:** VIP 1–3 short are 4–12% of album revenue, the most in Dice.
- **Not shown:** that the Dice gift fails. Its timing is outside the measured window.
- Next (not run): post-close spend of VIP 1–3 short vs their own normal week (calendar check, step 3); third album (step 4); who got the Dice gift and their spend vs similar players who did not (natural comparison, not a test).

## Step 3: spend after close vs the same players' normal week, and churn (run 2026-10-24)
SQL: `claude/vip_normal_week_churn_2026-10-24.sql` (Domino 8.3 GB, Disney 20.6 GB, Dice 111.7 GB). Albums with 28 days after close: Dice 63, Domino 19, Disney 14.
Usual pace = $ a day in album days 0–20. Normal week = album days 21–27 (no close). After = close+1..+7 and +1..+28 (next album table). Churn = no active day in close+15..+28.
All % below are of the usual pace; "vs normal" = after ÷ normal week − 1.

| Game | Tier | Status | Players | Normal week | 28 days after | vs normal week | Churn d15–28 |
|---|---|---|---|---|---|---|---|
| Dice 63 | VIP | finished | 3,509 | 111% | 107% | −4% | 1.6% |
| Dice 63 | VIP | 1–3 short | 6,152 | 108% | 91% | **−15%** | 1.7% |
| Dice 63 | VIP | 4+ short | 2,601 | 107% | 76% | −29% | 7.2% |
| Domino 19 | VIP | finished | 832 | 104% | 96% | −8% | 3.1% |
| Domino 19 | VIP | 1–3 short | 720 | 100% | 84% | **−16%** | 3.3% |
| Domino 19 | VIP | 4+ short | 1,116 | 93% | 53% | −42% | 10.8% |
| Disney 14 | VIP | finished | 1,127 | 97% | 104% | +7% | 2.4% |
| Disney 14 | VIP | 1–3 short | 1,549 | 94% | 87% | **−7%** | **6.1%** |
| Disney 14 | VIP | 4+ short | 1,155 | 76% | 50% | −35% | **14.9%** |

$1K–5K, same order (finished / 1–3 / 4+), vs normal week: Dice −4 / −19 / −35%; Domino −4 / −15 / −32%; Disney −9 / −18 / −32%. Churn: Dice 2.4 / 2.1 / 8.7%; Domino 4.0 / 3.1 / 8.2%; Disney 4.1 / 4.5 / 10.3%.

Reading:
- **Fact:** the drop of VIP 1–3 short holds against their own normal week: −15% Dice, −16% Domino, −7% Disney over 28 days. Finishers in the same weeks: −4%, −8%, +7%. So the gap to finishers (same calendar) is about 8–14 points in every game. The calendar does not explain it.
- **Fact:** 4+ short were already slowing before close (normal week 76–107%, lowest in Disney) and drop 29–42% after. This is the earlier, separate problem.
- **Churn:** far payers churn in all three games (VIP 7–15%, $1K–5K 8–10%), most in Disney (15%). VIP 1–3 short churn about like finishers in Dice and Domino (2–3%), but **2.5× more in Disney (6.1% vs 2.4%)**. So "churn like in Disney" = far payers everywhere; near-missers only in Disney.
- Ceiling (not a forecast): VIP 1–3 short spend vs their normal-week pace over 28 days, gap a day: Dice $11,524, Domino $2,071, Disney $2,333.
- Caveats: one album per game; Dice's next-album table only lists players with at least one sticker, so a VIP who plays without collecting would count as churned (unlikely). Dice 63's after-window is the weak Labor Day week, but finishers share it.

## Step 4: third album (run 2026-10-24)
SQL: `claude/vip_third_album_2026-10-24.sql` (Domino 10.5 GB, Disney 24.0 GB, Dice 109.3 GB). Dice 61 (next 63), Domino 17 (next 18), Disney 12 (next 13 = 21-day mini album, then 14; one value per user-day).

| Game | VIP status | Players | Normal week | 28 days after | vs normal week | Churn d15–28 |
|---|---|---|---|---|---|---|
| Dice 61 | finished / 1–3 / 4+ | 2,538 / 4,694 / 4,572 | 112 / 106 / 77% | 100 / 88 / 79% | −11 / **−17** / +3% | 1.8 / 1.5 / 4.9% |
| Domino 17 | finished / 1–3 / 4+ | 832 / 576 / 760 | 106 / 103 / 79% | 97 / 83 / 67% | −8 / **−19** / −16% | 4.2 / 3.6 / 6.3% |
| Disney 12 | finished / 1–3 / 4+ | 932 / 1,180 / 645 | 95 / 88 / 62% | 87 / 72 / 38% | −9 / **−18** / −38% | 2.8 / **4.5** / **18.8%** |

$1K–5K 1–3 short vs normal week: Dice −20%, Domino −17%, Disney −17%.
- **Fact:** in 6 of 6 albums VIP 1–3 short fall 7–19% below their own normal week over 28 days, 6–14 points more than finishers in the same weeks.
- **Fact:** Disney VIP 1–3 short churn more than Disney finishers in both albums (4.5% vs 2.8%; 6.1% vs 2.4%); in Dice and Domino they churn like finishers. Far VIP churn most in Disney (15–19%) vs Dice 5–7%, Domino 6–11%.
- Dice 61 far VIP were already at 77% in the normal week and did not fall further.

## Step 5: who got the Dice gift (Sep 1–2) vs similar players (run 2026-10-24)
SQL: `claude/vip_gift_recipients_2026-10-24.sql` (115.2 GB). Population: album 63 standard-population payers, LTV ≥ $1K, with a row on Aug 31.
- Recipients in this population: 2,052 VIP and 138 $1K–5K (of 2,928 recipients in all). The gift is VIP-only in practice.
- **All recipients had 4+ missing in album 63 on Aug 31** (6 days before close). None had finished album 61.
- **The "missed the last album by 3" rule does not hold:** among VIP recipients, album 61 missed 1: 88, missed 2: 184, missed 3: 328, missed 4+: 1,438. Most recipients were far in album 61, not near.
- Most similar VIP (album 61 not finished, album 63 4+ on Aug 31) did NOT get it: 2,038 got it vs 7,011 did not. Recipients spend much less (usual pace $5.5 vs $10.5 a day per player), so the two groups differ (selection rule unknown).

| VIP, album 61 not finished, album 63 4+ on Aug 31 | Players | Usual pace / player | Finished album 63 | Last 6 days vs usual pace | 28 days after close vs usual pace |
|---|---|---|---|---|---|
| Got the gift | 2,038 | $5.5 | 14% | 103% | 98% |
| Did not | 7,011 | $10.5 | 26% | 112% | 99% |
Same direction inside every album-61 cell (finish 13–19% with the gift vs 24–29% without).
- **Reading (not causal):** the gift goes to VIP who are already 4+ away a week before close; 86% of them still do not finish. It does not reach the group this analysis is about (VIP 1–3 short at close), and there is no sign it lifts finishing or spend. Recipients are weaker spenders, so this is not proof it does nothing.
- For the recommendation: do not copy the gift as is. The gap is VIP (and $1K–5K) who end 1–3 short; help has to reach them in the last days, before close.

## Slides (2026-10-24)
Generator: `claude/slide_vip_album_end_2026-10-24.py`. Added to ALBUM END right after a6s9v, notes written.
- **vipa_slide** — VIP spend after close vs normal week, finished vs 1–3 short, 2 albums per game (6 of 6 albums: 1–3 short −7% to −19%; finishers drop less). Cards: 4–12% of album revenue; $1K–5K 1–3 short −15% to −20%; Disney churn 1.6–2.5× finishers.
- **vipt_slide** — TEST in Disney first: help in the last 4 days before close, 3 groups (Control / Dice-style gift timed and targeted / offer on the missing stickers). Main KPI revenue per player 28 days after close vs own normal week; guardrails finish rate, churn d15–28, album revenue, cost. Dice gift as is: do not copy.
- Note: on the live vipa slide a hidden legend square (vipa_slide_lg2, filled with the card colour) is left from the first build; the generator no longer makes it.
- Correction to Eden's brief: "7–19%" is the VIP range; $1K–5K who end 1–3 short drop 15–20%.
