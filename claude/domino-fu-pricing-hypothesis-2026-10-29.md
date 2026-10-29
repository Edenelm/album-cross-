# Domino album 20, last week: does a higher Joker-offer price at FU raise revenue, or move players to a cheaper route? (2026-10-29)

Eden's hypothesis: near the end, players at FU see album offers at a higher price. They may buy a cheaper offer with puzzle pieces, finish the puzzle, and get the missing stickers from its Jokers instead of buying the expensive Joker offer.
SQL: `claude/domino_fu_pricing_mechanism_2026-10-29.sql` (Q1–Q5, mechanism) and `claude/domino_fu_pricing_test_2026-10-29.sql` (Q1 arms, Q2 noise + route). Project `domino-dreams-dbt`. Staging views used with Eden's OK (2026-10-29): `prod_10_staging.stg_mtx_event_triggered_vw`, `stg_purchase_completed_vw`. Calendar: Domino MTX Calendar 2026 (Google Sheet 1HHBQjUp…, tab "Calendar", 5–12.10.2026). Album 20 closed 12.10.2026.

## 1. Mechanism (verified)
- **Prices are set by the player's price anchor (CZ).** Each offer has price steps by CZ band, in the segment key (`Czmin_…__Czmax_…__ExpectedPrice_…`).
- **At FU the CZ bands are narrower, so the same player lands on a higher price step.** It applies to 4 Joker offers only:

| Offer (calendar day) | Not FU: $7.99 step up to CZ | FU Control | FU Test |
|---|---|---|---|
| 1+9 Album, Joker card in big resource (9–10.10) | 400 | 320 (bands 20% narrower) | 360 (10% narrower) |
| 1+12 (4th of July theme) Joker card (10–11.10) | 400 | 320 | 360 |
| Buy Them All+ (8–9.10) | 439 | 320 | 360 |
| 1PO Joker (5–6.10, $4.99 step) | 334 | 274 | 274 (same as Control) |
- Puzzle offers (Joker Puzzle 1PO, 1PO Joker Puzzle 1.6CZ, 1PO Golden Puzzle 1.6CZ, Sunny Deal 1.6CZ Puzzle), 1+2 Album, Dream Pass: **no FU price**. Paid at about 1.7× CZ at any distance.
- **Price paid (fact):** Joker offers about 2.3–2.4× CZ for buyers 1–3 missing vs 1.8–2.2× for 4+ missing; puzzle offers 1.7× for everyone.
- **Content:** the segment changes the price step only; the offer is the same campaign. The calendar lists content (e.g. 1+9 Album: Joker card as big resource + batteries, merge, puzzle). Number of Jokers per offer is not in the data.
- **Test 1591 "FU Joker Offers Pricing" (analyst's launch note, pasted by Eden 2026-10-29):** Joker offers are raised at the album end for FU players, and earlier tests showed the raise pushes more players to cheaper offers. The test lowers the raise: **Control = the usual raise (e.g. 1PO Joker at 2.0× CZ), Test = a smaller raise (1.8× CZ).** Goal: more players buy the expensive Joker offers instead of the cheap ones, and total spend goes up. Day 1 (1PO Joker only) had a segment bug: everyone saw the Test price; fixed the same day. This matches the data (1PO Joker has the same CZ bands in both arms), so 1PO Joker is not a real price difference.
- **It was a randomised test:** assignment campaign `FU Pricing Joker Test`, 5–11.10, arms `Joker_Pricing_FU_Control` / `FU_Test` / `Not_FU`. **Control = the higher FU price, Test = a smaller FU raise.** This is not "raise vs no raise".
- **Who is "FU" (not verified):** the rule is not in the data. 72% of FU-arm players had 4–6 stickers missing at the end of the day before entry, 16% 1–3, 12% 7+. Ask the Domino team.
- **Exposure log:** 99.8% of assigned players were shown at least one of the 4 Joker offers (triggered event). No price on the exposure row; price = CZ band of the segment.
- **The puzzle route:** SummerFeverPuzzle (Double Joker Puzzle, 8–11.10) gave Jokers; players used them mostly on the gate Royals (18,407 Royal fills, 13,089 players). The "two Royals" = two Jokers.

## 2. Test result (ITT, every assigned FU player, window = entry day .. 11.10)
Players: Control 68,155, Test 69,515 = 137,670 = **15% of album-20 players active 5–11.10 (892,727)** and **73% of album-20 revenue** (their whole-album spend ÷ album revenue, cheaters excluded).

| Per assigned player | Control (higher price) | Test (smaller raise) | Test vs Control |
|---|---|---|---|
| Avg price paid, FU-priced Joker offers | $29.44 | $27.85 | −5% |
| Bought an FU-priced Joker offer | 2.88% | 3.39% | +0.51 points [+0.33, +0.69], +18% |
| $ on those offers | $1.05 | $1.16 | +10% |
| Bought a puzzle offer | 2.81% | 2.64% | −0.17 points [−0.34, 0.00], −6% |
| $ on puzzle offers | $0.75 | $0.70 | −7% |
| Album $ in the window | $11.22 | $10.94 | −2.5% [−7%, +2%] |
| Album $ in the 14 days before entry | $27.24 | $26.84 | −1.5% (gap before the test) |
| Window vs before (DiD) | | | **about −1%, inside noise (±6%)** |
| Paid in the window | 28.3% | 28.1% | same |
| Bought nothing in the window | 71.3% | 71.7% | same (±0.5 points) |
| Finished album 20 | 14.19% | 14.18% | same (±0.4 points) |
| Last sticker = SummerFever Joker | 6.9% | 6.8% | same |
| Last sticker = FU-priced Joker offer | 0.59% | 0.77% | +0.18 points |
| Album 21, first 7 days, $ | $12.69 | $11.89 | −6% [−11%, −2%]; −5% after the before gap |
| Album 21, active days of 7 | 6.61 | 6.61 | same |

**Route, player level (Q2):** shown an FU Joker offer → bought a puzzle offer after it → a puzzle Joker filled a new sticker after that buy → finished.
- Control: 2,290 → 1,478 → **1,034 (1.52% of the arm)**. Test: 2,214 → 1,350 → **955 (1.37%)**.
- Difference: +0.14 points in Control [about ±0.13], about 100 players per 68,000.

**1–2 missing at entry** (2,874 vs 2,871 players, 4% of album revenue per arm): Joker-offer buyers 6.3% → 9.3% in Test; puzzle-offer buyers 6.6% → 5.9%; window $ −4.6% after the before gap (small group, wide noise); finished 31.4% vs 32.1%.

## 3. Reading
- **Against the test's goal:** the smaller raise (Test) did move buyers from puzzle offers to Joker offers (+18% Joker buyers, −6% puzzle buyers), but total spend did not go up (about −1%, ±6%).
- **Fact (randomised):** a higher FU price on the Joker offers made fewer players buy them, and did not raise the money from those offers. Control buyers paid 6% more, but there were 15% fewer of them. Money on these offers was 10% lower per player.
- **Fact (randomised):** a small move to the puzzle offers under the higher price (+0.17 points of players, +7% puzzle $). The full puzzle route to finishing was a little more common (+0.14 points, about 100 players per 68,000).
- **Fact (randomised):** total album spend in the window, the share who bought nothing and the finish rate did not differ in a measurable way. A difference up to about ±6% in spend cannot be ruled out.
- **Fact, to check:** album 21's first week was 6% lower in the Test arm (smaller raise). Activity was the same. This is a single week with heavy-tailed spend, so it may be noise. It needs the full first 14 days of album 21.
- **Cannot say from this test:** the effect of the FU raise itself (both arms had it), or the effect of a bigger raise.

## 4. Meaning
- **The FU price raise on Joker offers does not bring more money** within the tested range: about the same total, fewer Joker buyers, a small shift to puzzle offers. Not a reason to raise it further.
- **The puzzle route exists but is small:** about 1.5% of FU players finished through it, with a 0.14-point difference between arms.
- **Next (focused check):**
  1. Done 2026-10-29, see §5.
  2. Ask the Domino team: the FU rule, which arm is the current default, Jokers per offer.
- Decision: **do not adopt a higher FU price yet.** If the team wants to know the value of the FU raise itself, test FU raise vs no raise.

## 5. Album 21, days 1–14 (12–25.10), by arm (Q3, same ITT players)
| Per assigned player | Control (usual raise) | Test (smaller raise) | Test vs Control |
|---|---|---|---|
| $ days 1–7 | $12.69 | $11.89 | −6% |
| $ days 8–14 | $13.39 | $12.87 | −4% [−8%, 0%] |
| $ days 1–14 | $26.08 | $24.76 | −5% [−9%, −1%] |
| Days 1–14 vs own 14 days before entry (DiD) | −$1.17 | −$2.08 | **−$0.91 per player, about −3.5% [−6.6%, −0.4%]** |
| $ days 1–14, capped at $500 a player | $23.59 | $22.69 | −4% (not driven by a few whales) |
| Paid in days 1–14 | 40.4% | 40.3% | same |
| Active days of 14 | 13.46 | 13.46 | same |
| Not active at all | 1.9% | 1.9% | same |
- **Fact (randomised):** the smaller raise did not lift the next album. Test players spent about 3.5% less in album 21's first 14 days. The range just misses 0. Same payers, same activity: less money per payer.
- **Cause unknown.** Album 20 itself showed no difference (−1%, ±6%). Album 20 window + album 21 days 1–14 together: Test is not higher in any measure.
- **Meaning for test 1591:** a smaller FU raise does not bring more money, and may bring a little less over album 21's first two weeks. **Keep the usual raise (Control).**

## 6. What could explain the album-21 drop (checks 1, 2, 4; Q4–Q6 in the test SQL, 2026-10-29)
- **1. Test still running in album 21? Refuted.** Test segments appear only on 12.10 (album 20 close day, 1+9 Summer offer, about 7,900 players per arm). None from 13.10 on.
- **2. Lower CZ → cheaper offers in album 21? Refuted.**
  - How CZ was read: `cz_c` inside `smart_segments` (JSON) on each event. CZ at entry = first offer event 5–11.10; CZ in album 21 = first offer event 13–25.10. Price ÷ CZ = `usd_amount` ÷ `cz_c` on the purchase.
  - Check that `cz_c` is the pricing CZ: "1.6CZ" offers were paid at 1.7× `cz_c` at every distance.
  - Result: CZ rose the same in both arms (+0.26 vs +0.28; median 2.8 → 3.0 vs 2.72 → 2.9). Price ÷ CZ the same (0.80). Price per purchase −1.7% (the before gap). **The gap = fewer purchases per payer: 6.29 vs 6.48 (−3%)**, same share of payers (40%).
- **4. Who makes the gap (tiers fixed before the test, $ a day in the 14 days before entry):**

| $ a day before | Players per arm | % of the arms' album-21 revenue (d1–14) | Change vs own before, Control → Test | Test − Control |
|---|---|---|---|---|
| none | 38–39K | 5% | +$2.11 → +$2.15 | 0 |
| ≤$2 | 16–17K | 17% | +$7.33 → +$7.07 | −$0.26 (±0.7) |
| $2–5 | 6.6–6.8K | 18% | +$2.51 → +$1.86 | −$0.65 (±2.1) |
| $5–20 | 5.5K | 35% | −$19.34 → −$23.30 | −$3.95 (±4.8) |
| >$20 | 1.1–1.2K | 24–26% | −$159.72 → −$201.49 | **−$41.8 (±33.5)** |
- Most of the gap per player (about 2/3 or more) comes from the >$20 group (1.7% of players). It is the only tier where the gap is outside noise, and only just. That tier had a higher before-spend in Test (+3%), so part may be a pull back to normal after a high pre period.
- Descriptive only (after the treatment): Joker-offer buyers 1,967 (Control) vs 2,357 (Test). Control buyers spent +$15 vs their before in album 21, Test buyers −$5. The cheaper price brought in more buyers who were less committed.
- **Reading:** no mechanism found. The drop is concentrated in a small, heavy-spending group with wide noise. Fact: no lift; possible small loss among >$20 payers. Not proven.

## Open
- FU definition in the price segments; offer contents (Jokers per offer).
- SummerFever progress per player is not in the puzzle tables, so "progress before the buy" could not be measured. The route uses a Joker fill after the buy instead.
