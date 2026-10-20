Note: claude-sonnet-5[1m] (the safety classifier) was unavailable (timed out) when reviewing this subagent's work. Please carefully verify the subagent's actions and output before acting on them.

# Dice Dreams: how not-first payers finish albums 61 and 63 in the last week

Project `dice-dreams-dbt`. All six queries ran (123.4 GB in total, largest 26.65 GB). Nothing failed. The F-early group is empty in both albums.

**Population and definitions**
- **Population:** not-first-album PU.
  - `user_past_album_count` > 0.
  - `spent_in_album_today` > 0 before close.
  - `is_excluded` = FALSE.
  - Login ratio on the last row before close ≥ 0.5.
  - The close day is excluded.
- **Day index:** d = date − close date. Album 61 closes 2026-07-27 and album 63 closes 2026-09-07, both at 12:00 UTC, so d = −1 is a full day.
- **Sticker terms:**
  - Rare = Super.
  - Wild fill = `collected_from_wild` = TRUE.
  - New = the player's first receipt of that sticker_id.

**Groups.** Finishing is defined as 144 unique set stickers, not the game flag.

| Group | Album 61 | Album 63 |
|---|---|---|
| Population (not-first PU) | 176,332 | 180,849 |
| F = finishers (144 before close) | 14,345 (8.1%) | 18,915 (10.5%) |
| — F-late (finished d = −7…−1) | 14,345 | 18,915 |
| — F-early (finished before d = −7) | **0** | **0** |
| N1 (exactly 1 short at end of d = −1) | 6,422 | 7,553 |
| N2-3 (2–3 short) | 56,519 | 93,754 |
| Other PU (4+ short, reference only) | 99,046 | 60,627 |

The finish rates match the critic's re-run (8.1% / 10.5%). Because no finisher completed before d = −7, F means F-late everywhere below.

## 1. Five headline findings

1. **Every finisher completed in the final 7 days; 88% / 84% completed in the last 3 days.** The finishing sticker was a Super for 81% / 70% of them, and it arrived via a Wild for 90% / 87%.
   - Label: Known. Population: F. n = 14,345 / 18,915.
2. **The closing run starts at d = −4 to −3, and it is driven by Wilds, not Goldens.**
   - The share of finishers with ≥1 Wild fill per day rises from 0.5% in the baseline week to 33–45% on d = −3…−2.
   - Their median first Wild fill is at d = −3.
   - New Supers per active day rise from 0.28 to 1.24 (61) and from 0.29 to 0.89 (63).
   - Goldens arrive in a single population-wide drop on d = −4 (61) / d = −5 (63) and then decline.
   - Label: Known. Population: F. n = 14,345 / 18,915.
3. **Finishers' paying rises with the Wild run; N2-3 payers' does not.**
   - Finishers' pay rate roughly doubles, from 25–26% in the baseline week to 52–53% on d = −1.
   - Their PU ARPDAU rises 2.4×, from $7.7–7.8 to $18.2–18.9.
   - N2-3 stay flat (19% → 20% in 61; 17% → 13% in 63), and their ARPDAU falls ($3.78 → $2.91; $2.98 → $1.72).
   - Label: Known (descriptive, not causal). Population: F and N2-3. n = 14,345 / 18,915 and 56,519 / 93,754.
4. **New Supers arrive within 10 minutes after a purchase far more often than new Commons do.**
   - For finishers' new Supers in the last week: 55% (61) / 59% (63).
   - Control, their new Commons in the same window: 11% / 14%.
   - Placebo, the same window shifted 24 h earlier: ≤ 0.9%.
   - Wild Supers that come from `Pricing_*` packs are 99.8% purchase-linked.
   - Label: Known for the timing. Needs Validation that the purchase delivered the sticker, because no ID links a purchase to a sticker. Population: F. n = 66,611 / 73,535 new Supers.
5. **Near-finishers are stuck on one fixed set of three stickers (2 Supers + 1 Golden).** Called "the gate trio" below.
   - Album 61: Super 143, Super 120, Golden 142. Album 63: Super 132, Super 143, Golden 129.
   - 59% / 76% of N2-3 are missing exactly these three (pattern "SSG").
   - 97% / 95% of N2-3 are missing the top gate Super (61: S143; 63: S132).
   - Only 7.5% / 11% of the whole population held that Super by d = −2.
   - On d = −2 and −1, 99.8%+ of its new holders got it via a Wild.
   - Label: Known for the numbers; Hypothesis that these stickers are locked by release date or config. Population: N1 + N2-3. n = 62,941 / 101,307.

## 2. Tables

### T1: Daily acquisition profile

Shares are of the whole group. The baseline-week row is the average day of d = −14…−8.
- Active = `is_active`.
- Paid = `spent_in_album_today` > 0.
- PU ARPDAU = revenue ÷ active player-days.

**Date-alignment check:** 0% of player-days with a new sticker fell on an inactive or missing `user_daily_album` row. Sticker dates (UTC) therefore line up with `date_dim`.

**Album 61, F (all finishers are F-late), n = 14,345**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 94% | 57% | 19% | 0.5% | 1.34 | 0.28 | 0.01 | 25% | $7.78 | $29.53 |
| -7 | 95% | 51% | 17% | 5.9% | 1.36 | 0.27 | 0.09 | 27% | $9.00 | $31.62 |
| -6 | 95% | 29% | 23% | 7.9% | 0.65 | 0.38 | 0.12 | 28% | $8.98 | $31.12 |
| -5 | 96% | 20% | 22% | 9.0% | 0.34 | 0.37 | 0.13 | 31% | $10.11 | $31.51 |
| -4 | 96% | 57% | 34% | 16% | 0.79 | 0.72 | 0.23 | 34% | $12.48 | $35.26 |
| -3 | 96% | 29% | 42% | 33% | 0.41 | 1.05 | 0.55 | 46% | $18.53 | $39.02 |
| -2 | 97% | 28% | 49% | 45% | 0.35 | 1.24 | 0.84 | 53% | $19.89 | $36.49 |
| -1 | 97% | 21% | 37% | 38% | 0.24 | 0.81 | 0.80 | 52% | $18.94 | $35.58 |

**Album 61, N1, n = 6,422**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 94% | 57% | 18% | 0.5% | 1.33 | 0.26 | 0.01 | 23% | $5.91 | $23.92 |
| -7 | 95% | 50% | 15% | 3.2% | 1.36 | 0.22 | 0.04 | 24% | $6.38 | $24.97 |
| -6 | 95% | 28% | 20% | 4.7% | 0.64 | 0.32 | 0.06 | 25% | $6.28 | $24.21 |
| -5 | 95% | 19% | 19% | 5.8% | 0.34 | 0.31 | 0.07 | 28% | $6.43 | $22.01 |
| -4 | 96% | 59% | 33% | 10% | 0.80 | 0.67 | 0.13 | 31% | $8.00 | $24.75 |
| -3 | 96% | 24% | 37% | 23% | 0.34 | 0.84 | 0.31 | 37% | $10.17 | $26.80 |
| -2 | 96% | 23% | 46% | 39% | 0.28 | 1.06 | 0.59 | 43% | $11.65 | $26.05 |
| -1 | 97% | 25% | 38% | 39% | 0.28 | 0.78 | 0.61 | 49% | $13.95 | $27.66 |

**Album 61, N2-3, n = 56,519**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 94% | 58% | 19% | 0.4% | 1.33 | 0.27 | 0.00 | 19% | $3.78 | $18.50 |
| -7 | 95% | 53% | 13% | 1.5% | 1.42 | 0.18 | 0.02 | 18% | $3.26 | $16.68 |
| -6 | 95% | 29% | 18% | 2.1% | 0.65 | 0.27 | 0.02 | 19% | $2.94 | $14.69 |
| -5 | 95% | 16% | 17% | 2.5% | 0.29 | 0.26 | 0.03 | 21% | $3.24 | $14.71 |
| -4 | 95% | 62% | 30% | 2.7% | 0.79 | 0.59 | 0.03 | 19% | $3.08 | $15.02 |
| -3 | 94% | 18% | 22% | 4.7% | 0.25 | 0.43 | 0.05 | 17% | $2.74 | $14.89 |
| -2 | 94% | 6.4% | 34% | 14% | 0.10 | 0.69 | 0.16 | 18% | $2.64 | $14.07 |
| -1 | 96% | 7.0% | 29% | 15% | 0.09 | 0.58 | 0.17 | 20% | $2.91 | $14.13 |

**Album 61, Other PU (reference), n = 99,046.** Pay rate per day: baseline week 11%; d = −3 / −2 / −1 at 8.0% / 7.8% / 7.6%. PU ARPDAU: $1.66 in the baseline week, $0.82 on d = −1. Wild fills stay at 0.9–2.4% per day.

**Album 63, F, n = 18,915**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 94% | 60% | 21% | 0.5% | 1.49 | 0.29 | 0.01 | 26% | $7.72 | $27.56 |
| -7 | 95% | 28% | 20% | 7.1% | 0.65 | 0.31 | 0.11 | 29% | $8.87 | $29.39 |
| -6 | 95% | 22% | 27% | 12% | 0.48 | 0.49 | 0.20 | 27% | $8.69 | $30.09 |
| -5 | 95% | 53% | 24% | 11% | 0.78 | 0.44 | 0.17 | 32% | $9.56 | $27.96 |
| -4 | 95% | 32% | 31% | 19% | 0.49 | 0.56 | 0.29 | 35% | $12.39 | $33.36 |
| -3 | 96% | 24% | 48% | 32% | 0.37 | 0.89 | 0.51 | 46% | $17.06 | $35.69 |
| -2 | 96% | 25% | 40% | 38% | 0.34 | 0.75 | 0.63 | 51% | $18.83 | $35.49 |
| -1 | 97% | 25% | 36% | 37% | 0.29 | 0.64 | 0.76 | 53% | $18.20 | $33.29 |

**Album 63, N1, n = 7,553**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 93% | 60% | 21% | 0.5% | 1.49 | 0.28 | 0.01 | 24% | $5.79 | $22.69 |
| -7 | 94% | 28% | 19% | 5.2% | 0.65 | 0.27 | 0.07 | 26% | $6.33 | $22.71 |
| -6 | 94% | 22% | 26% | 9.7% | 0.46 | 0.45 | 0.14 | 25% | $6.16 | $23.40 |
| -5 | 94% | 53% | 24% | 7.4% | 0.80 | 0.42 | 0.10 | 29% | $6.57 | $21.43 |
| -4 | 95% | 34% | 27% | 12% | 0.54 | 0.46 | 0.14 | 31% | $7.92 | $24.39 |
| -3 | 94% | 19% | 44% | 21% | 0.33 | 0.74 | 0.27 | 36% | $10.07 | $26.25 |
| -2 | 94% | 21% | 37% | 32% | 0.30 | 0.62 | 0.43 | 43% | $12.28 | $26.73 |
| -1 | 96% | 20% | 37% | 38% | 0.26 | 0.62 | 0.63 | 48% | $13.07 | $26.12 |

**Album 63, N2-3, n = 93,754**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 94% | 62% | 21% | 0.7% | 1.50 | 0.28 | 0.01 | 17% | $2.98 | $16.60 |
| -7 | 95% | 31% | 16% | 2.5% | 0.73 | 0.21 | 0.03 | 17% | $2.83 | $15.75 |
| -6 | 94% | 21% | 22% | 2.7% | 0.47 | 0.33 | 0.03 | 14% | $1.96 | $13.08 |
| -5 | 94% | 55% | 20% | 1.9% | 0.78 | 0.32 | 0.02 | 16% | $1.96 | $11.69 |
| -4 | 94% | 32% | 24% | 1.9% | 0.48 | 0.35 | 0.02 | 13% | $1.86 | $13.09 |
| -3 | 93% | 12% | 42% | 4.2% | 0.22 | 0.63 | 0.05 | 13% | $1.87 | $13.08 |
| -2 | 93% | 4.7% | 21% | 5.4% | 0.10 | 0.33 | 0.06 | 13% | $1.88 | $12.99 |
| -1 | 93% | 3.1% | 11% | 4.7% | 0.06 | 0.18 | 0.06 | 13% | $1.72 | $12.61 |

**Album 63, Other PU (reference), n = 60,627.** Pay rate per day: baseline week 9.2%; d = −3…−1 at 5.3–5.5%. PU ARPDAU: $1.52 in the baseline week, $0.82 on d = −1.

**What T1 shows (Known, descriptive):**
- The Golden curve does not rise toward the close.
- Goldens come in one drop for the whole population (d = −4 in 61, d = −5 in 63). On that day 53–62% of every group, Other PU included, get a new Golden; inflow then declines.
- Supers and Wild fills rise over the last 3–4 days. Wild fills rise only in F and N1.

### T2: When do players start? (share of group by day d; "≤ −8" = already in the baseline week)

| Album | Group (n) | Metric | none in −14…−1 | ≤ −8 | −7 | −6 | −5 | −4 | −3 | −2 | −1 | median d |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 61 | F (14,345) | first new Golden | 0.0% | 99.7% | 0.1% | 0.1% | 0.0% | 0.0% | 0.0% | 0.0% | 0.0% | −13 |
| 61 | F | first new Super | 0.0% | 82.8% | 4.0% | 3.0% | 2.6% | 3.1% | 2.5% | 1.7% | 0.3% | −12 |
| 61 | F | **first Wild fill** | 0.0% | 3.6% | 5.7% | 6.3% | 6.3% | 10.6% | 24.5% | 27.3% | 15.8% | **−3** |
| 61 | F | first paying day | 1.0% | 69.2% | 3.4% | 2.9% | 2.8% | 3.2% | 6.0% | 6.4% | 5.1% | −11 |
| 61 | F | last new Golden | 0.0% | 4.4% | 3.4% | 4.2% | 5.3% | 15.6% | 20.2% | 25.9% | 21.2% | −3 |
| 61 | F | last new Super | 0.0% | 0.0% | 1.0% | 2.0% | 2.8% | 7.4% | 17.3% | 32.6% | 36.9% | −2 |
| 61 | F | last paying day | 1.0% | 0.5% | 0.4% | 0.6% | 1.1% | 3.3% | 12.3% | 29.0% | 51.9% | −1 |
| 61 | N1 (6,422) | first Wild fill | 3.5% | 3.8% | 3.1% | 4.1% | 4.5% | 8.3% | 19.5% | 28.5% | 24.7% | −2 |
| 61 | N1 | last new Super | 0.0% | 0.1% | 0.3% | 1.6% | 2.9% | 8.9% | 17.2% | 30.9% | 38.1% | −2 |
| 61 | N1 | last paying day | 3.5% | 1.8% | 0.7% | 1.1% | 1.8% | 5.0% | 12.2% | 25.2% | 48.8% | −1 |
| 61 | N2-3 (56,519) | first Wild fill | **59.2%** | 2.7% | 1.4% | 1.9% | 2.3% | 2.3% | 4.2% | 12.7% | 13.3% | −2 |
| 61 | N2-3 | last new Golden | 0.0% | 13.6% | 3.1% | 2.0% | 2.2% | 51.7% | 14.8% | 5.6% | 7.0% | −4 |
| 61 | N2-3 | last paying day | 17.0% | 16.8% | 4.1% | 4.8% | 7.3% | 8.7% | 9.4% | 12.3% | 19.7% | −4 |
| 63 | F (18,915) | first new Golden | 0.0% | 99.8% | 0.1% | 0.0% | 0.0% | 0.0% | 0.0% | 0.0% | 0.0% | −14 |
| 63 | F | first new Super | 0.0% | 88.7% | 3.1% | 2.2% | 1.9% | 1.5% | 1.8% | 0.7% | 0.2% | −11 |
| 63 | F | **first Wild fill** | 0.1% | 3.3% | 6.9% | 10.0% | 7.7% | 12.7% | 21.1% | 21.8% | 16.4% | **−3** |
| 63 | F | first paying day | 0.2% | 72.3% | 3.5% | 3.6% | 3.2% | 3.1% | 4.5% | 4.8% | 4.8% | −12 |
| 63 | F | last new Golden | 0.0% | 2.5% | 2.7% | 4.5% | 10.4% | 13.2% | 18.4% | 23.6% | 24.8% | −3 |
| 63 | F | last new Super | 0.0% | 0.0% | 0.8% | 3.1% | 3.7% | 10.5% | 19.1% | 27.2% | 35.6% | −2 |
| 63 | F | last paying day | 0.2% | 0.1% | 0.2% | 0.7% | 1.5% | 4.6% | 13.1% | 26.9% | 52.9% | −1 |
| 63 | N1 (7,553) | first Wild fill | 3.8% | 3.5% | 5.1% | 8.5% | 5.4% | 8.7% | 16.1% | 23.3% | 25.7% | −2 |
| 63 | N1 | last paying day | 1.3% | 0.7% | 0.5% | 1.5% | 3.1% | 5.5% | 13.2% | 26.4% | 47.9% | −2 |
| 63 | N2-3 (93,754) | first Wild fill | **74.1%** | 4.9% | 2.4% | 2.5% | 1.7% | 1.7% | 3.7% | 4.9% | 4.1% | −4 |
| 63 | N2-3 | last new Golden | 0.0% | 5.5% | 2.6% | 2.2% | 44.0% | 28.3% | 10.1% | 4.1% | 3.1% | −5 |
| 63 | N2-3 | last paying day | 22.8% | 21.6% | 5.9% | 4.8% | 7.1% | 6.9% | 8.1% | 10.1% | 12.7% | −5 |

"First new Golden" tells us nothing, because 99.7%+ of every group already gets Goldens in the baseline week. In Dice there is no last-week start for Goldens. The useful start markers are the first Wild fill and the last new Super / Golden.

**Finishing sticker (F)**

| | Album 61 (n = 14,345) | Album 63 (n = 18,915) |
|---|---|---|
| Type: Super / Golden / Common | 81.3% / 18.2% / 0.6% | 70.4% / 28.9% / 0.6% |
| Super via Wild (share of all finishers) | 78.7% | 67.9% |
| Golden via Wild (share of all finishers) | 11.1% | 18.6% |
| Channel: Wild, paid offer (`Pricing_*` pack) | 58.0% | 69.4% |
| Channel: Wild, event reward (Trail Final Reward, blast grand prize, wheel…) | 31.8% | 17.1% |
| Channel: paid offer, not a Wild (`Pricing_*` "specific" packs) | 6.5% | 9.7% |
| Channel: Trail / other events / steady progression / dup exchange | 1.3% / 1.9% / 0.4% / 0.03% | 1.4% / 1.9% / 0.4% / 0.1% |
| Finishing day: d = −1 / −2 / −3 / −4 / −5…−7 | 38.9% / 32.3% / 16.6% / 6.9% / 5.4% | 37.9% / 27.6% / 18.5% / 9.8% / 6.2% |

### T3: Channel of new Supers and new Goldens, d = −7…−1 (share of new stickers of that type)

**New Supers**

| Channel | 61 F | 61 N1 | 61 N2-3 | 61 Other | 63 F | 63 N1 | 63 N2-3 | 63 Other |
|---|---|---|---|---|---|---|---|---|
| Wild, paid offer | 37.9% | 24.1% | 6.0% | 2.5% | 47.4% | 33.9% | 5.8% | 3.1% |
| Wild, event reward | 13.6% | 15.1% | 9.5% | 2.3% | 6.6% | 8.3% | 3.9% | 1.6% |
| Paid offer, not a Wild | 0.0% | 0.0% | 0.0% | 0.0% | 0.1% | 0.1% | 0.0% | 0.1% |
| Dup exchange | 6.0% | 7.8% | 12.7% | 15.4% | 1.6% | 1.7% | 3.2% | 2.0% |
| Trail (recurring MTX event) | 14.5% | 18.6% | 24.3% | 25.4% | 13.9% | 18.6% | 27.9% | 24.9% |
| Steady progression | 2.3% | 3.0% | 5.2% | 8.5% | 3.2% | 4.2% | 9.0% | 9.4% |
| Other events | 25.6% | 31.2% | 42.2% | 45.7% | 27.2% | 33.2% | 50.0% | 58.8% |
| Unknown / other | 0.1% | 0.1% | 0.1% | 0.2% | 0.1% | 0.1% | 0.2% | 0.2% |
| n new Supers | 66,611 | 25,864 | 160,046 | 179,739 | 73,535 | 25,655 | 206,856 | 86,284 |

**New Goldens**

| Channel | 61 F | 61 N1 | 61 N2-3 | 61 Other | 63 F | 63 N1 | 63 N2-3 | 63 Other |
|---|---|---|---|---|---|---|---|---|
| Wild, paid offer | 4.7% | 2.3% | 0.3% | 0.1% | 12.6% | 6.3% | 0.8% | 0.2% |
| Wild, event reward | 2.1% | 2.0% | 0.3% | 0.0% | 1.4% | 1.7% | 0.5% | 0.2% |
| Paid offer, not a Wild | 28.6% | 27.0% | 17.0% | 11.8% | 32.3% | 30.6% | 15.9% | 10.5% |
| Dup exchange | 0.0% | 0.0% | 0.0% | 0.0% | 2.0% | 2.6% | 3.0% | 1.8% |
| Trail | 3.8% | 4.0% | 4.8% | 6.4% | 6.9% | 7.8% | 10.8% | 9.7% |
| Steady progression | 34.9% | 37.5% | 45.3% | 45.7% | 21.9% | 24.6% | 34.7% | 37.0% |
| Other events | 25.6% | 26.8% | 31.8% | 35.5% | 22.6% | 26.1% | 34.1% | 39.9% |
| Unknown / other | 0.3% | 0.4% | 0.4% | 0.6% | 0.2% | 0.3% | 0.4% | 0.6% |
| n new Goldens | 56,896 | 24,797 | 192,928 | 457,719 | 61,150 | 23,758 | 250,008 | 213,274 |

**How raw sources map to channels.** Rules are applied in this order. They come from the source inventory (Q0) and extend the Topic-5 mapping (v2).
1. **Wild, paid offer:** `collected_from_wild` AND `sticker_pack_key LIKE 'Pricing%'`.
   - Sources seen: DP_Big_Chest_WithStamp, Decoy_BuyAll, Decoy_Upgrade, OnePlusSixteen, OnePlusTwelve_V4, 1PlusX, BuildYourBundle, Big_Chest_Animated_v2/v3, 1To2_BigChest_Animated, Scrolling_Offer_WithoutClass(_V2), plus Pending Rewards and CustomerSupportReward when they carry a Pricing pack.
   - 99.5–100% of these stickers arrive ≤ 10 min after a purchase, so "paid" is Known for this channel.
2. **Wild, event reward:** `collected_from_wild` with a pack key that is not Pricing.
   - Sources: Trail - Final Reward (GP_Trail_01), blast grand prize, Reward_Bonus_Wheel_v2, (null) source with a GP_Merge_Collection pack, Pending Rewards with a GP_Trail pack.
   - 23–26% of finishers' stickers in this channel arrive ≤ 10 min after a purchase.
3. **Dup exchange:** `Duplication exchange`.
4. **Paid offer, not a Wild:** `sticker_pack_key LIKE 'Pricing%'`, or `Dream Pass` with a Premium pack.
   - Examples: OnePlusThree, OnePlusTwo_V3, 1Plus1_V3, ScrollingOffer_*, 6Boxes_V3, Limited_Stock; the Journey events (EnchantedJourney, USAThemeJourney_Night, DeepDiveJourney) when they carry Pricing_DDJ/CP packs; Generic_Reward_NoCloseButton when it carries a Pricing pack.
5. **Trail:** source `Trail%` or pack key `%Trail%`. This includes Generic_Reward_NoCloseButton with an HGP_Trail_01 pack.
6. **Steady progression:** Progress Bar V2, RewardCalendar, WeeklyGoals, Pets Feature, Pets. This is the closest Dice equivalent of a "regular pull".
7. **Unknown / other:** (null) source without a Collection pack, Pending Rewards, CustomerSupportReward (non-Pricing packs).
8. **Other events:** everything else. Examples: PropChase_Hunt, parallel roads/quest, VerticalQuest, 3ToWin, TileTwister_v2, Duel, Tournament*, Royal_Fortune, Dynamic_Path_v3, Puzzle/Merge Collection, Frankys_*, blast small reward, new kingdom, ColoringBook, Market_With_PB_v3.

**What T3 shows:**
- Dice has essentially no paid route to a Super that is not a Wild (≤ 0.1%). A paid Super is always a Wild fill.
- Paid Goldens come as "specific" packs that are not Wilds (27–32% of finishers' new Goldens).

### T4: Purchase linkage of new stickers, d = −7…−1

Purchase timestamps come from `20_core.purchase_completed_vw`, deduplicated on user × timestamp × external_order_id, with amount > 0.
- Control: the same group's new Commons in the same window.
- Placebo: the same 10-minute window shifted 24 h earlier.

| Album | Group | Sticker | n new | On a paying day | ≤ 10 min after a purchase | Placebo (−24 h) |
|---|---|---|---|---|---|---|
| 61 | F | Super (all) | 66,611 | 82.4% | 54.9% | 0.7% |
| 61 | F | Super, Wild | 34,307 | 95.0% | 80.2% | 0.8% |
| 61 | F | Super, not Wild | 32,304 | 69.1% | 28.0% | 0.5% |
| 61 | F | Golden (all) | 56,896 | 50.1% | 31.8% | 0.4% |
| 61 | F | Golden, Wild | 3,867 | 90.3% | 76.2% | 0.9% |
| 61 | F | **Common (control)** | 46,893 | 35.3% | **10.7%** | 0.2% |
| 61 | N1 | Super / Golden / Common | 25,864 / 24,797 / 20,683 | 72.2% / 44.8% / 31.0% | 41.2% / 27.3% / 9.0% | 0.4% / 0.3% / 0.2% |
| 61 | N2-3 | Super / Golden / Common | 160,046 / 192,928 / 180,608 | 39.3% / 27.6% / 23.2% | 17.1% / 13.0% / 6.5% | 0.3% / 0.2% / 0.2% |
| 61 | Other | Super / Golden / Common | 179,739 / 457,719 / 661,565 | 24.4% / 18.2% / 18.6% | 9.6% / 7.0% / 6.0% | ≤ 0.2% |
| 63 | F | Super (all) | 73,535 | 82.8% | 59.3% | 0.7% |
| 63 | F | Super, Wild | 39,701 | 98.2% | 90.4% | 0.8% |
| 63 | F | Super, not Wild | 33,834 | 64.7% | 22.8% | 0.5% |
| 63 | F | Golden (all) | 61,150 | 61.7% | 43.7% | 0.5% |
| 63 | F | Golden, Wild | 8,558 | 98.7% | 92.3% | 0.8% |
| 63 | F | **Common (control)** | 22,745 | 38.3% | **14.4%** | 0.2% |
| 63 | N1 | Super / Golden / Common | 25,655 / 23,758 / 9,346 | 74.4% / 53.2% / 32.5% | 46.6% / 35.0% / 11.2% | 0.5% / 0.4% / 0.1% |
| 63 | N2-3 | Super / Golden / Common | 206,856 / 250,008 / 117,159 | 32.2% / 24.2% / 20.6% | 13.7% / 11.4% / 7.4% | ≤ 0.3% |
| 63 | Other | Super / Golden / Common | 86,284 / 213,274 / 249,381 | 21.6% / 17.8% / 17.1% | 8.7% / 8.2% / 7.2% | ≤ 0.2% |

**What T4 shows (Known, timing only):**
- For finishers, new Supers are 5.1× (61) and 4.1× (63) as likely as their new Commons to land ≤ 10 min after a purchase.
- Even Supers that are not Wilds (28% / 23%) are 2–3× the Common control.
- This applies the critic's control (the player's own Commons, same window) in place of yesterday's ±24 h placebo. Whether the purchase "bought" the sticker stays Needs Validation, because nothing links a purchase to a specific sticker.

### T5: Sequences and what near-finishers are missing

**Finishers' last 5 new stickers, oldest → newest** (S = Super, G = Golden, w = Wild fill). Top 5 by type only:

| Album 61 (n = 14,345) | Share | Album 63 (n = 18,915) | Share |
|---|---|---|---|
| S>S>S>G>S | 11.4% | G>S>S>G>S | 12.6% |
| S>S>G>S>S | 10.3% | S>S>S>G>S | 12.1% |
| S>G>S>S>S | 10.1% | S>S>S>S>G | 9.8% |
| S>S>S>S>G | 9.6% | S>G>S>G>S | 8.7% |
| S>S>S>S>S | 8.1% | G>S>S>S>G | 7.2% |

Top 5 with the Wild marker (patterns are more scattered):

| Album 61 | Share | Album 63 | Share |
|---|---|---|---|
| G>S>Sw>G>Sw | 3.4% | G>S>Sw>G>Sw | 7.5% |
| S>S>Sw>G>Sw | 3.2% | S>S>Sw>G>Sw | 5.6% |
| G>G>S>Sw>Sw | 2.9% | S>G>Sw>G>Sw | 4.9% |
| G>S>S>Sw>Sw | 2.8% | G>G>S>Sw>Sw | 3.4% |
| Sw>G>S>Sw>Sw | 2.8% | G>S>Sw>Sw>Gw | 3.3% |

The last five are almost never Commons. A typical finish is 3–4 Supers mixed with 1–2 Goldens, and the last two Supers are Wild fills.

**What near-finishers are missing at the end of d = −1:**

| Album | Group | Missing mix (S = Super, G = Golden, C = Common) |
|---|---|---|
| 61 | N1 (6,422) | S 73.1% · G 17.2% · C 9.7% |
| 61 | N2-3 (56,519) | SSG 58.8% · SS 15.2% · SG 14.4% · SSS 8.8% |
| 63 | N1 (7,553) | S 62.6% · G 27.8% · C 9.6% |
| 63 | N2-3 (93,754) | SSG 75.8% · SG 14.1% · SS 7.4% |

**Most-missing stickers and whether anyone could get them.** "First d" = first time anyone in the population received it. "Pop hold by −2" = share of the population holding it by the end of d = −2.

| Album | Sticker | Missing in N1 | Missing in N2-3 | First d | Pop hold by −2 | F holders by −2 |
|---|---|---|---|---|---|---|
| 61 | S143 | 55.8% | 96.6% | −20 | 7.5% | 9,573 / 14,345 |
| 61 | G142 | 14.5% | 73.7% | −26 | 17.2% | 11,327 |
| 61 | S120 | 10.2% | 67.8% | −21 | 15.3% | 11,289 |
| 61 | S144 | 3.8% | 22.3% | −35 | 42.3% | 13,067 |
| 63 | S132 | 42.7% | 94.7% | −28 | 11.3% | 12,874 / 18,915 |
| 63 | G129 | 24.3% | 90.8% | −26 | 14.8% | 14,245 |
| 63 | S143 | 17.6% | 87.7% | −28 | 15.3% | 14,777 |

Every missing sticker had at least one holder in the population before d = −1. So all are "obtainable" in the strict sense, but few players held the gate trio.

**Gate trio, new holders per day** (all not-first PU; % of population)

| Sticker | ≤ −8 | −7 | −6 | −5 | −4 | −3 | −2 | −1 | Wild share on −2 / −1 | Main channel when not a Wild |
|---|---|---|---|---|---|---|---|---|---|---|
| 61 S143 | 0.36% | 0.32% | 0.69% | 0.49% | 0.75% | 1.75% | 3.13% | 3.51% | 99.9% / 99.8% | — |
| 61 S120 | 0.05% | 0.39% | 0.63% | 0.71% | 2.09% | 3.92% | 7.51% | 7.36% | 99.9% / 99.9% | — |
| 61 G142 | 1.57% | 1.34% | 1.69% | 2.56% | 2.80% | 3.26% | 4.02% | 4.82% | 24% / 31% | Paid "specific" pack, not a Wild (69–95%) |
| 63 S132 | 0.19% | 0.47% | 1.30% | 1.32% | 2.02% | 2.64% | 3.32% | 4.58% | 99.8% / 99.8% | — |
| 63 S143 | 0.15% | 0.29% | 0.74% | 1.03% | 2.26% | 4.80% | 6.05% | 5.53% | 100% / 100% | — |
| 63 G129 | 0.80% | 0.74% | 1.10% | 1.92% | 2.87% | 3.39% | 3.93% | 4.16% | 31% / 62% | Paid "specific" pack (36–79%), dup exchange (2–8%) |

## 3. Story of the last week in Dice

- **Nobody finishes early.** Every not-first PU finisher completes in d = −7…−1, and 84–88% complete in the last 3 days.
- **Goldens are not where the late-week action is.**
  - Players already get about 1.3–1.5 new Goldens per active day in the baseline week.
  - One drop for the whole population comes on d = −4 (61) / d = −5 (63).
  - After that, Golden inflow for finishers falls to 0.2–0.4 per active day.
- **The closing run starts on d = −4/−3 and is driven by Wilds.**
  - The finishers' daily Wild-fill share jumps from 0.5% to 33–45%.
  - New Supers per active day rise 3–4×.
  - The pay rate doubles to about 52%.
  - Median markers: first Wild fill d = −3, last Golden d = −3, last Super d = −2, last paying day d = −1.
- **The gate is a fixed trio of 2 Supers + 1 Golden.**
  - In the last two days the gate Supers come almost only from Wilds (99.8%+): about 2/3 from paid `Pricing_*` Wild offers and about 1/3 from event Wilds (mostly Trail Final Reward).
  - The gate Golden comes mainly from a paid "specific" pack. In album 63 it increasingly comes via Wild on d = −1.
- **Purchases come right before these stickers.** 80–90% of finishers' Wild Supers in the last week arrive ≤ 10 min after a purchase. The comparison figures are 11–14% for their new Commons and under 1% for the 24-hour-shifted placebo.
- **N1 look like finishers who ran out of time.**
  - Their Wild-fill and pay curves follow F about one day behind (48–49% paid on d = −1, against 52–53% for F).
  - 63–73% are still missing one Super, usually the top gate Super.
- **N2-3 get stuck before the run starts.**
  - 59% / 74% never get a single Wild fill in the 14-day window, and their pay rate stays at baseline.
  - 59% / 76% end missing exactly the trio.
  - Duplicate exchange and events keep giving them other Supers (dup exchange is 13% of N2-3's new Supers in album 61), but not the gate stickers.
- **Album 63 compared with 61:**
  - More finishes come through paid Wilds (69% vs 58%).
  - Fewer come through event Wilds (17% vs 32%).
  - Duplicate exchange almost disappears (1.6% vs 6.0% of finishers' new Supers).
  - More N2-3 are missing exactly the trio (76% vs 59%).
  - This compares two albums with different setups, so it is not causal.

## 4. Caveats and definition gaps

- **Joker vs Wild.** Dice has no Joker. "Joker/Wild" here means `collected_from_wild` (from `is_wild` on the sticker-received event): the player chose the sticker through a Wild, whatever the source. The Joker flag in Domino and Disney is a different mechanic, and the Domino definition is still disputed.
- **Paid vs free is inferred from the pack key** (`sticker_pack_key LIKE 'Pricing%'`).
  - Known for Wilds (≥ 99.5% arrive right after a purchase).
  - Needs Validation for non-Wild paid offers (79–84% purchase-linked among finishers).
  - Trail Final Reward Wilds are counted as event rewards, but 23–26% follow a purchase within 10 minutes. Whether the Trail has a paid track is still open from Topic 5.
- **"Pack / regular pull" has no clean Dice equivalent.** Every source is a feature, so steady progression (Progress Bar, daily calendar, weekly goals, pets) stands in for it. The channel rules extend the Topic-5 v2 lists with pack-key rules, so shares are not exactly comparable to Topic 5.
- **Purchase linkage is timing only.** No order ID connects a purchase to a sticker. The Commons control and the 24-hour placebo rule out "payers simply collect more of everything after paying", but they do not prove causation.
- **"First new Golden"** is uninformative, because everyone already collects Goldens on d = −14.
- **"Obtainable"** is shown two ways:
  - Strict test: at least one population holder before d = −1. True for 100% of missing stickers.
  - Practical view: only 7.5–17% of the population held each gate-trio sticker by d = −2.
  - Release dates are not in the curated tables, so "locked until late" stays a Hypothesis until the studio confirms the calendar.
- **Data handling.**
  - `fact_user_album_stickers` was deduplicated to each player's first receipt of each sticker.
  - Revenue = `spent_in_album_today`.
  - ARPDAU is computed on `is_active` days.
  - F-early is empty in both albums.

## 5. SQL appendix

All queries ran in `dice-dreams-dbt`. Each was dry-run first with identical SQL, read-only, with partition filters, on curated layers 50/30/20 only.
- Total scanned: 123.4 GB over 6 queries; the largest was 26.65 GB.
- The full runnable SQL is saved at `/tmp/claude-0/-home-claude/5629d190-2f4d-5652-8298-2143c958a9b2/scratchpad/dice_lastweek/all_queries.sql` (each query is also its own `q*.sql` file in that folder).

| Query | Purpose | Scanned |
|---|---|---|
| Q0 | Source inventory for new Goldens / Supers on d = −7…−1 (basis for the channel mapping) | 24.55 GB |
| Q1 | T1 daily profile | 16.96 GB |
| Q2 | T2 first/last days and finishing sticker | 24.55 GB |
| Q3 | T3 channels and T4 purchase linkage (Commons control, 24 h placebo) | 26.65 GB |
| Q5 | T5 last-5 sequences and missing stickers | 16.89 GB |
| Q6 | Gate trio: new holders per day and channel | 13.79 GB |

**Shared prefix (identical in every query)**
```sql
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.a_end, a.album_login_ratio AS lr, IFNULL(a.user_past_album_count, 0) AS past,
    IFNULL(a.spent_in_album_today, 0) AS sp, IFNULL(a.is_active, FALSE) AS act,
    IFNULL(a.unique_common_stickers_lt, 0) + IFNULL(a.unique_golden_stickers_lt, 0) + IFNULL(a.unique_super_stickers_lt, 0) AS u
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(u) AS u_pre, MIN(IF(u >= 144, date_dim, NULL)) AS fin_d
  FROM r GROUP BY 1, 2
  HAVING SUM(sp) > 0 AND MAX(past) > 0 AND ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
grp AS (
  SELECT album_id, user_id, a_end, fin_d, 144 - u_pre AS short,
    CASE WHEN u_pre >= 144 AND fin_d >= DATE_SUB(a_end, INTERVAL 7 DAY) THEN 'F_late'
         WHEN u_pre >= 144 THEN 'F_early'
         WHEN u_pre = 143 THEN 'N1'
         WHEN u_pre >= 141 THEN 'N2_3'
         ELSE 'Other_PU' END AS g
  FROM pop),
st AS (
  SELECT g.album_id, g.user_id, g.g, g.a_end, s.sticker_id, s.sticker_type AS t, s.sticker_collected_ts AS ts,
    DATE_DIFF(s.sticker_collected_date, g.a_end, DAY) AS d, IFNULL(s.collected_from_wild, FALSE) AS w,
    IFNULL(NULLIF(s.sticker_source, ''), '(null)') AS src, s.sticker_pack_key AS pk
  FROM grp g JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = g.album_id AND s.user_id = g.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63)
    AND s.is_sticker_collected AND s.sticker_type IN ('common', 'golden', 'super') AND s.sticker_collected_date < g.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1)
```

**Channel expression (`bucket`), used in Q2, Q3 and Q6**
```sql
CASE
  WHEN w AND pk LIKE 'Pricing%' THEN 'Wild - paid offer'
  WHEN w THEN 'Wild - event reward'
  WHEN src = 'Duplication exchange' THEN 'Dup exchange'
  WHEN pk LIKE 'Pricing%' OR (src = 'Dream Pass' AND pk LIKE '%Premium%') THEN 'Paid offer (non-Wild)'
  WHEN src LIKE 'Trail%' OR pk LIKE '%Trail%' THEN 'Trail (recurring MTX event)'
  WHEN src IN ('Progress Bar V2', 'RewardCalendar', 'WeeklyGoals', 'Pets Feature', 'Pets') THEN 'Steady progression (PB/Daily/Weekly/Pets)'
  WHEN src IN ('(null)', 'Pending Rewards', 'CustomerSupportReward') AND IFNULL(pk, '') NOT LIKE '%Collection%' THEN 'Unknown/other'
  ELSE 'Other events' END
```

**Q0: source inventory (24.55 GB).** Shared prefix, then:
```sql
SELECT album_id, t, src, w, COUNT(*) AS n, COUNTIF(g IN ('F_late','N1','N2_3')) AS n_target, ANY_VALUE(pk) AS ex_pack_key
FROM st WHERE d BETWEEN -7 AND -1 AND t IN ('golden','super')
GROUP BY 1, 2, 3, 4 HAVING COUNT(*) >= 50 ORDER BY 1, 2, 5 DESC
```

**Q1: T1 daily profile (16.96 GB).** Shared prefix, then:
```sql
, sd AS (
  SELECT album_id, user_id, d, COUNTIF(t = 'golden') AS ng, COUNTIF(t = 'super') AS nr, COUNTIF(w) AS nw, COUNTIF(t = 'common') AS nc
  FROM st WHERE d BETWEEN -14 AND -1 GROUP BY 1, 2, 3),
ud AS (
  SELECT r.album_id, r.user_id, DATE_DIFF(r.date_dim, r.a_end, DAY) AS d, r.act, r.sp
  FROM r JOIN grp USING (album_id, user_id) WHERE r.date_dim >= DATE_SUB(r.a_end, INTERVAL 14 DAY)),
x AS (
  SELECT COALESCE(ud.album_id, sd.album_id) AS album_id, COALESCE(ud.user_id, sd.user_id) AS user_id, COALESCE(ud.d, sd.d) AS d,
    IFNULL(ud.act, FALSE) AS act, IFNULL(ud.sp, 0) AS sp, ud.user_id IS NULL AS no_row,
    IFNULL(sd.ng, 0) AS ng, IFNULL(sd.nr, 0) AS nr, IFNULL(sd.nw, 0) AS nw, IFNULL(sd.nc, 0) AS nc
  FROM ud FULL OUTER JOIN sd ON sd.album_id = ud.album_id AND sd.user_id = ud.user_id AND sd.d = ud.d),
gl AS (
  SELECT album_id, user_id, gg FROM grp,
    UNNEST(ARRAY_CONCAT([g], IF(g IN ('N1','N2_3'), ['N_all'], []), IF(g LIKE 'F_%', ['F_all'], []))) AS gg),
gn AS (SELECT album_id, gg, COUNT(*) AS n FROM gl GROUP BY 1, 2),
y AS (
  SELECT gl.album_id, gl.gg, IF(x.d <= -8, 'base(-14..-8)', CAST(x.d AS STRING)) AS dd, IF(x.d <= -8, 7, 1) AS ndays,
    x.act, x.sp, x.ng, x.nr, x.nw, x.nc, x.no_row
  FROM x JOIN gl USING (album_id, user_id))
SELECT y.album_id, y.gg AS grp, y.dd, ANY_VALUE(gn.n) AS n_players,
  ROUND(COUNTIF(act) / (ANY_VALUE(gn.n) * ANY_VALUE(ndays)), 4) AS pct_active,
  ROUND(COUNTIF(ng > 0) / (ANY_VALUE(gn.n) * ANY_VALUE(ndays)), 4) AS pct_new_golden,
  ROUND(COUNTIF(nr > 0) / (ANY_VALUE(gn.n) * ANY_VALUE(ndays)), 4) AS pct_new_super,
  ROUND(COUNTIF(nw > 0) / (ANY_VALUE(gn.n) * ANY_VALUE(ndays)), 4) AS pct_new_wild,
  ROUND(SUM(ng) / NULLIF(COUNTIF(act), 0), 3) AS new_golden_per_active,
  ROUND(SUM(nr) / NULLIF(COUNTIF(act), 0), 3) AS new_super_per_active,
  ROUND(SUM(nw) / NULLIF(COUNTIF(act), 0), 3) AS new_wild_per_active,
  ROUND(COUNTIF(sp > 0) / (ANY_VALUE(gn.n) * ANY_VALUE(ndays)), 4) AS pct_paid,
  ROUND(SUM(sp) / NULLIF(COUNTIF(act), 0), 2) AS pu_arpdau,
  ROUND(SUM(sp) / NULLIF(COUNTIF(sp > 0), 0), 2) AS rev_per_paying_day,
  ROUND(COUNTIF((ng + nr + nc) > 0 AND (no_row OR NOT act)) / NULLIF(COUNTIF((ng + nr + nc) > 0), 0), 4) AS qa_sticker_days_not_active
FROM y JOIN gn ON gn.album_id = y.album_id AND gn.gg = y.gg
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
```

**Q2: T2 timing and finishing sticker (24.55 GB).** Shared prefix, then:
```sql
, stb AS (SELECT album_id, user_id, g, d, t, w, ts, <bucket expression> AS bucket FROM st),
fe AS (
  SELECT album_id, user_id, ANY_VALUE(g) AS g,
    MIN(IF(t = 'golden' AND d >= -14, d, NULL)) AS f_golden, MIN(IF(t = 'super' AND d >= -14, d, NULL)) AS f_super,
    MIN(IF(w AND d >= -14, d, NULL)) AS f_wild,
    MAX(IF(t = 'golden', d, NULL)) AS l_golden, MAX(IF(t = 'super', d, NULL)) AS l_super, MAX(IF(w, d, NULL)) AS l_wild,
    ARRAY_AGG(STRUCT(d, t, w, bucket) ORDER BY ts DESC LIMIT 1)[OFFSET(0)] AS fin
  FROM stb GROUP BY 1, 2),
fp AS (
  SELECT album_id, user_id, MIN(IF(sp > 0, DATE_DIFF(date_dim, a_end, DAY), NULL)) AS f_pay, MAX(IF(sp > 0, DATE_DIFF(date_dim, a_end, DAY), NULL)) AS l_pay
  FROM r WHERE date_dim >= DATE_SUB(a_end, INTERVAL 14 DAY) GROUP BY 1, 2),
u AS (
  SELECT g.album_id, g.user_id, gg, fe.f_golden, fe.f_super, fe.f_wild, fp.f_pay, fe.l_golden, fe.l_super, fe.l_wild, fp.l_pay, fe.fin
  FROM grp g LEFT JOIN fe USING (album_id, user_id) LEFT JOIN fp USING (album_id, user_id),
    UNNEST(ARRAY_CONCAT([g.g], IF(g.g IN ('N1','N2_3'), ['N_all'], []))) AS gg),
m AS (
  SELECT album_id, gg, metric, v FROM u,
    UNNEST([STRUCT('first_new_golden' AS metric, f_golden AS v), ('first_new_super', f_super), ('first_wild_fill', f_wild), ('first_purchase_day', f_pay),
            ('last_new_golden', l_golden), ('last_new_super', l_super), ('last_wild_fill', l_wild), ('last_purchase_day', l_pay)]))
SELECT album_id, gg AS grp, metric, CAST(NULL AS STRING) AS cat, COUNT(*) AS n,
  ROUND(COUNTIF(v IS NULL) / COUNT(*), 4) AS sh_none, ROUND(COUNTIF(v <= -8) / COUNT(*), 4) AS sh_le_m8,
  ROUND(COUNTIF(v = -7) / COUNT(*), 4) AS sh_m7, ROUND(COUNTIF(v = -6) / COUNT(*), 4) AS sh_m6, ROUND(COUNTIF(v = -5) / COUNT(*), 4) AS sh_m5,
  ROUND(COUNTIF(v = -4) / COUNT(*), 4) AS sh_m4, ROUND(COUNTIF(v = -3) / COUNT(*), 4) AS sh_m3, ROUND(COUNTIF(v = -2) / COUNT(*), 4) AS sh_m2,
  ROUND(COUNTIF(v = -1) / COUNT(*), 4) AS sh_m1, APPROX_QUANTILES(v, 2)[OFFSET(1)] AS p50_d
FROM m WHERE gg IN ('F_late', 'N1', 'N2_3', 'N_all') GROUP BY 1, 2, 3
UNION ALL
SELECT album_id, gg, CONCAT('finishing_sticker_', k), c AS cat2, COUNT(*), ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, gg, k), 4),
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM u, UNNEST([STRUCT('type' AS k, fin.t AS c), ('channel', fin.bucket), ('type_x_wild', CONCAT(fin.t, IF(fin.w, '+wild', ''))), ('day', CAST(fin.d AS STRING))])
WHERE gg IN ('F_late', 'F_early') GROUP BY album_id, gg, k, c
ORDER BY 1, 2, 3, 4
```
The first dry-run failed (the two halves of the UNION ALL had different column counts). The version above, with 9 NULLs, is the one that ran.

**Q3: T3 channels and T4 purchase linkage (26.65 GB).** Shared prefix, then:
```sql
, w7 AS (SELECT album_id, user_id, sticker_id, g, d, t, w, ts, <bucket expression> AS bucket FROM st WHERE d BETWEEN -7 AND -1),
payday AS (SELECT album_id, user_id, DATE_DIFF(date_dim, a_end, DAY) AS d FROM r WHERE sp > 0 AND date_dim >= DATE_SUB(a_end, INTERVAL 8 DAY)),
pur AS (
  SELECT v.user_id, v.timestamp AS pts
  FROM `dice-dreams-dbt.20_core.purchase_completed_vw` v
  WHERE v.pdate BETWEEN DATE '2026-07-17' AND DATE '2026-09-06' AND v.purchase_amount > 0
  QUALIFY ROW_NUMBER() OVER (PARTITION BY v.user_id, v.timestamp, v.external_order_id ORDER BY v.timestamp) = 1),
k AS (
  SELECT w7.album_id, w7.user_id, w7.sticker_id, w7.g, w7.t, w7.w, w7.bucket, w7.ts, pd.d IS NOT NULL AS paid_day,
    LOGICAL_OR(p.pts BETWEEN TIMESTAMP_SUB(w7.ts, INTERVAL 10 MINUTE) AND w7.ts) AS p10,
    LOGICAL_OR(p.pts BETWEEN TIMESTAMP_SUB(w7.ts, INTERVAL 1450 MINUTE) AND TIMESTAMP_SUB(w7.ts, INTERVAL 1440 MINUTE)) AS p10_shift24h
  FROM w7 LEFT JOIN payday pd ON pd.album_id = w7.album_id AND pd.user_id = w7.user_id AND pd.d = w7.d
  LEFT JOIN pur p ON p.user_id = w7.user_id AND p.pts BETWEEN TIMESTAMP_SUB(w7.ts, INTERVAL 1450 MINUTE) AND w7.ts
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9)
SELECT album_id, g AS grp, t, bucket, COUNT(*) AS n_new, COUNT(DISTINCT user_id) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, g, t), 4) AS share_of_type,
  COUNTIF(paid_day) AS n_paid_day, COUNTIF(IFNULL(p10, FALSE)) AS n_p10, COUNTIF(IFNULL(p10_shift24h, FALSE)) AS n_p10_shift24h
FROM k WHERE g IN ('F_late', 'N1', 'N2_3', 'Other_PU')
GROUP BY 1, 2, 3, 4 ORDER BY 1, 2, 3, 5 DESC
```

**Q5: T5 sequences and missing stickers (16.89 GB).** Shared prefix, then:
```sql
, seq AS (
  SELECT album_id, user_id, ARRAY_AGG(STRUCT(UPPER(SUBSTR(t, 1, 1)) AS ty, w) ORDER BY ts DESC, sticker_id DESC LIMIT 5) AS l5
  FROM st WHERE g = 'F_late' GROUP BY 1, 2),
pat AS (
  SELECT album_id,
    (SELECT STRING_AGG(CONCAT(x.ty, IF(x.w, 'w', '')), '>' ORDER BY o DESC) FROM UNNEST(l5) x WITH OFFSET o) AS p_wild,
    (SELECT STRING_AGG(x.ty, '>' ORDER BY o DESC) FROM UNNEST(l5) x WITH OFFSET o) AS p_type
  FROM seq),
p1 AS (SELECT 'T5a_pattern_type_wild' AS section, album_id, 'F_late' AS grp, p_wild AS k, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS share
  FROM pat GROUP BY album_id, p_wild QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) <= 8),
p2 AS (SELECT 'T5b_pattern_type' AS section, album_id, 'F_late' AS grp, p_type AS k, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS share
  FROM pat GROUP BY album_id, p_type QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) <= 8),
stk AS (
  SELECT album_id, sticker_id, ANY_VALUE(t) AS t, MIN(d) AS first_d_pop,
    COUNTIF(d <= -2) AS holders_by_m2, COUNTIF(g = 'F_late' AND d <= -2) AS f_holders_by_m2
  FROM st GROUP BY 1, 2),
npop AS (SELECT album_id, COUNT(*) AS n_pop FROM grp GROUP BY 1),
nu AS (SELECT album_id, user_id, g FROM grp WHERE g IN ('N1', 'N2_3')),
miss AS (
  SELECT nu.album_id, nu.user_id, nu.g, k.sticker_id, k.t, k.first_d_pop, k.holders_by_m2, k.f_holders_by_m2
  FROM nu JOIN stk k ON k.album_id = nu.album_id
  LEFT JOIN st s ON s.album_id = nu.album_id AND s.user_id = nu.user_id AND s.sticker_id = k.sticker_id
  WHERE s.user_id IS NULL),
mu AS (SELECT album_id, user_id, g, COUNTIF(t = 'super') AS ms, COUNTIF(t = 'golden') AS mg, COUNTIF(t = 'common') AS mc, COUNT(*) AS m_all
  FROM miss GROUP BY 1, 2, 3),
p3 AS (SELECT 'T5c_missing_mix' AS section, album_id, g AS grp, CONCAT(REPEAT('S', ms), REPEAT('G', mg), REPEAT('C', mc)) AS k, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, g), 4) AS share
  FROM mu GROUP BY album_id, g, k),
p4 AS (SELECT 'T5d_missing_sticker' AS section, m.album_id, m.g AS grp,
    CONCAT(CAST(m.sticker_id AS STRING), ':', m.t, ' firstd=', CAST(ANY_VALUE(m.first_d_pop) AS STRING),
      ' pop_hold_by_m2=', CAST(ROUND(ANY_VALUE(m.holders_by_m2) / ANY_VALUE(np.n_pop), 3) AS STRING),
      ' Flate_hold_by_m2=', CAST(ANY_VALUE(m.f_holders_by_m2) AS STRING)) AS k,
    COUNT(*) AS n, ROUND(COUNT(*) / ANY_VALUE(gc.n_g), 4) AS share
  FROM miss m JOIN npop np USING (album_id)
  JOIN (SELECT album_id, g, COUNT(*) AS n_g FROM nu GROUP BY 1, 2) gc ON gc.album_id = m.album_id AND gc.g = m.g
  GROUP BY m.album_id, m.g, m.sticker_id, m.t
  QUALIFY ROW_NUMBER() OVER (PARTITION BY m.album_id, m.g ORDER BY COUNT(*) DESC) <= 8),
p5 AS (SELECT 'T5e_missing_obtainable' AS section, album_id, g AS grp,
    CONCAT(t, IF(holders_by_m2 > 0, ' obtainable_by_m2', ' NOT_obtainable_by_m2')) AS k, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, g), 4) AS share
  FROM miss GROUP BY album_id, g, k)
SELECT section, album_id, grp, k, n, share FROM p1 UNION ALL
SELECT section, album_id, grp, k, n, share FROM p2 UNION ALL
SELECT section, album_id, grp, k, n, share FROM p3 WHERE share >= 0.01 UNION ALL
SELECT section, album_id, grp, k, n, share FROM p4 UNION ALL
SELECT section, album_id, grp, k, n, share FROM p5
ORDER BY 1, 2, 3, 5 DESC
```

**Q6: gate trio by day and channel (13.79 GB).** Shared prefix, then:
```sql
, tr AS (
  SELECT album_id, sticker_id, t, IF(d <= -8, -8, d) AS dd, w, <bucket expression> AS bucket
  FROM st WHERE (album_id = 61 AND sticker_id IN (143, 142, 120)) OR (album_id = 63 AND sticker_id IN (132, 129, 143))),
npop AS (SELECT album_id, COUNT(*) AS n_pop FROM grp GROUP BY 1)
SELECT tr.album_id, sticker_id, ANY_VALUE(t) AS t, dd, COUNT(*) AS new_holders,
  ROUND(COUNT(*) / ANY_VALUE(np.n_pop), 4) AS share_of_pop, ROUND(COUNTIF(w) / COUNT(*), 3) AS wild_share,
  ROUND(COUNTIF(bucket = 'Wild - paid offer') / COUNT(*), 3) AS wild_paid_share,
  ROUND(COUNTIF(bucket = 'Wild - event reward') / COUNT(*), 3) AS wild_event_share,
  ROUND(COUNTIF(bucket = 'Dup exchange') / COUNT(*), 3) AS dup_share,
  ROUND(COUNTIF(bucket = 'Paid offer (non-Wild)') / COUNT(*), 3) AS paid_nonwild_share
FROM tr JOIN npop np USING (album_id)
GROUP BY 1, 2, 4 ORDER BY 1, 2, 4
```

**Worth saving to memory (Dice):**
- **Gate trio:** album 61 = S143, S120, G142; album 63 = S132, S143, G129.
- **Wild channel:** gate Supers on d = −2/−1 arrive about 100% via Wild. A `Pricing_*` pack key marks paid offers (≥ 99.5% purchase-linked for Wilds).
- **No early finishers:** zero not-first PU finish before close−7.
- **Commons control:** finishers' new Supers in the last week are 55–59% purchase-linked within 10 minutes, against 11–14% for their new Commons. Use this as the standard placebo.

The full deliverable is also saved as `/tmp/claude-0/-home-claude/5629d190-2f4d-5652-8298-2143c958a9b2/scratchpad/dice_lastweek/final.md`, and the raw results are next to it in `t1.json` and `t34.json`.
