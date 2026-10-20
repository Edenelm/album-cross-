# Disney — building an album segmentation from the Dice method (started 2026-10-14)

Goal (Eden): adopt the Dice method (pre-album difficulty + daily tier → end-of-album revenue-share goals) in Disney, where no definition exists. Disney has injections but nothing defined. Thresholds = a practical management decision, NOT a copy of the Dice distribution. Level = spend only (Eden).
Project `solitaire-dreams-411507`, table `bi_prod.user_daily_album` (+ `bi_prod.user_profile` for excluded). SQL: `claude/disney_segmentation_queries.sql`.

## Step D1 — history daily spend → decision table (run 2026-10-14)
History = up to 3 most recent albums played among 11..(target−1); daily spend = album spend (close day excluded) ÷ (close − open) days. Targets: albums 14, 15. Population: not special, not excluded, user_album_count > 1, login ratio (last row before close) ≥ 0.5. Avg history albums per player 2.6–2.75.

| History $/day | Players % (14 / 15) | Revenue % (14 / 15) | $/day now | Same bin now | Within 1 bin | Lower now | Finish rate | P50 Royals end |
|---|---|---|---|---|---|---|---|---|
| 0 | 61.5 / 60.9 | 4.7 / 3.3 | 0.04–0.06 | 93–94% | 97–98% | – | 0.2–0.3% | 3 |
| ≤0.25 | 13.7 / 14.5 | 3.9 / 3.9 | 0.21–0.23 | 24% | 90% | 57–59% | 0.6–0.7% | 3–4 |
| 0.25–0.5 | 5.1 / 5.1 | 3.7 / 3.6 | 0.55–0.57 | 16% | 54% | 56% | 1.3–1.4% | 4 |
| 0.5–1 | 5.3 / 5.4 | 6.3 / 6.3 | 0.93–0.94 | 19–20% | 50% | 54% | 1.9–2.0% | 4 |
| 1–2 | 5.0 / 5.1 | 10.1 / 10.3 | 1.59–1.63 | 23% | 59–60% | 52–53% | 3.1–3.4% | 4–5 |
| 2–5 | 5.1 / 5.1 | 20.0 / 20.0 | 3.12 | 32–33% | 65–66% | 49–50% | 5.4–5.9% | 5 |
| 5–10 | 2.4 / 2.3 | 17.8 / 18.0 | 5.99–6.23 | 28–29% | 71–72% | 53–56% | 9.1–10.3% | 5–6 |
| 10–20 | 1.2 / 1.1 | 16.2 / 16.4 | 10.96–11.71 | 29–31% | 69–71% | 54–58% | 14.1–16.5% | 6 |
| >20 | 0.6 / 0.5 | 17.4 / 18.4 | 23.96–27.92 | 46–52% | 73–75% | 48–54% | 22.7–26.8% | 6 |
Players: 1.20M (14) / 1.09M (15); payers in album 370K / 325K.

Overall accuracy (same bin / within 1 bin): history of up to 3 albums 66–67% / 87%; LAST album only 71% / 87–88%.

Reading:
- Known: the existing `album_segment` column is "def_default" for every bin → no segmentation in use in the data.
- Known: revenue is concentrated: players >$5/day = ~4% of players, ~51–53% of revenue; $1–5/day = ~10% / ~30%; ≤$1/day = ~86% / ~17–19%.
- Known: finish rate and Royals at end rise steadily with history spend (0.2% → 23–27%; 3 → 6 Royals).
- Known: half of players in every paying bin spend LESS now than their history (48–58% lower) — regression to the mean / decline. Fine bins are unstable (16–33% exact); wider levels will be more stable.
- Known: averaging up to 3 albums did NOT beat the last album alone (exact bin 66–67% vs 71%). The Dice hypothesis (multi-album average assigns better) is not supported in Disney on this cut. Needs Validation on payers-only and on final level cuts.
- Not causal.

Threshold options proposed (to decide with management; stability per option still to compute):
| Option | Levels ($/day) | Players % | Revenue % |
|---|---|---|---|
| A — 3 levels | ≤1 / 1–5 / >5 | 86 / 10 / 4 | 17–19 / 30 / 51–53 |
| B — 4 levels | ≤0.5 / 0.5–2 / 2–10 / >10 | 80 / 10 / 7.5 / 1.7–1.8 | 11–12 / 16–17 / 38 / 34–35 |
| C — Dice dollars (≈$1.4 / $5.7 / $14.3 per day) | ≤2 / 2–5 / 5–20 / >20 | 90–91 / 5 / 3.4–3.6 / 0.5–0.6 | 28–29 / 20 / 34 / 17–18 |

## Decision (Eden, 2026-10-14)
- Disagreed with "don't copy Dice": the goal is to bring each population to ≤3 stickers missing (of 144) — handling each population correctly brings more players to that state. Goal checkpoint: 4 or 3 days to end. Recommendation revised → build the full segmentation in Disney and Test vs current injections.

## Step D2 — reach of ≤3 missing by history spend bin (run 2026-10-14)
Same population/bins as D1. Missing = 144 − (unique common + golden + royal). Revenue share = revenue (album start → day) of players at ≤3 missing ÷ bin revenue. Close−4 / −3 / −1: album 14 = 08-20 / 08-21 / 08-23; album 15 = 10-01 / 10-02 / 10-04.

| History $/day | Rev share ≤3 at close−4 (14 / 15) | close−3 | close−1 | Players ≤3 at close−4 | Exactly 3 of the 1–3 short | Paid last 3 days: reached / far | $ per active day last 3 days: reached / far |
|---|---|---|---|---|---|---|---|
| 0 | 35 / 33 | 38 / 36 | 46 / 45 | 3.5% / 0.8% | 78 / 91% | 6–16% / 1% | 0.98–2.91 / 0.04–0.05 |
| ≤0.25 | 23 / 19 | 26 / 21 | 32 / 29 | 6.0 / 2.0% | 76 / 87% | 15–26% / 6% | 1.17–2.75 / 0.21–0.22 |
| 0.25–0.5 | 25 / 20 | 27 / 23 | 34 / 31 | 8.1 / 3.8% | 74 / 86% | 27–35% / 12–13% | 2.32–3.98 / 0.49–0.53 |
| 0.5–1 | 26 / 23 | 28 / 26 | 36 / 33 | 10.4 / 5.9% | 74 / 85% | 34–41% / 18–19% | 2.84–4.30 / 0.80–0.86 |
| 1–2 | 30 / 27 | 32 / 30 | 41 / 39 | 13.8 / 9.4% | 73 / 83% | 44–49% / 24–27% | 4.04–5.38 / 1.35–1.47 |
| 2–5 | 37 / 34 | 40 / 38 | 50 / 49 | 20.2 / 16.2% | 73 / 82% | 54–58% / 32–34% | 6.43–7.71 / 2.42–2.67 |
| 5–10 | 45 / 45 | 49 / 49 | 60 / 60 | 28.5 / 26.3% | 73 / 81% | 65–66% / 39–41% | 10.67–12.35 / 4.44–4.88 |
| 10–20 | 55 / 55 | 59 / 60 | 69 / 71 | 38.4 / 37.0% | 72 / 81% | 72–74% / 43–44% | 17.52–19.74 / 7.49–8.53 |
| >20 | 67 / 69 | 71 / 73 | 79 / 81 | 49.7 / 49.4% | 69 / 77% | 79–80% / 43–45% | 35.14–41.57 / 13.84–16.11 |
Median point in the album when ≤3 missing is first reached: 81–98% of album time (later in album 15).

By threshold option (rev share ≤3 at close−4 / close−3; album 14 ; 15):
| Option | Level 1 | Level 2 | Level 3 | Level 4 |
|---|---|---|---|---|
| A (≤1 / 1–5 / >5) | 27/30 ; 23/26 | 35/38 ; 31/35 | 56/60 ; 57/61 | – |
| B (≤0.5 / 0.5–2 / 2–10 / >10) | 28/31 ; 23/26 | 28/31 ; 25/28 | 41/44 ; 39/43 | 61/65 ; 63/67 |
| C (≤2 / 2–5 / 5–20 / >20) | 28/31 ; 24/28 | 37/40 ; 34/38 | 50/54 ; 50/54 | 67/71 ; 69/73 |

Reading:
- Known: reach rises steadily with history spend (rev share 19–26% at low bins → 67–69% at >$20/day). Bin 0 looks high (33–35%) only because its little revenue comes from the few who paid and progressed.
- Known: close−4 vs close−3 differ by only 2–4 points; close−1 adds another 8–12 → no single-day jump at close−3; reaching happens late (81–98% of album).
- Known: 69–91% of players 1–3 short are exactly 3 short (the locked trio) — "≤3 missing" in Disney ≈ "everything except the trio".
- Known: players at ≤3 missing at close−4 pay more in the last 3 days than those far (paid 6–80% vs 1–45%; $/active day 2.5–20×). Selection, not causal.
- Option C separates levels most cleanly (~25% → ~36% → 50% → ~68%); in option B the two lower levels are identical (28/28 ; 23/25) → no separation.
- Known: Disney's top level (>$20/day) at close−4 = 67–69%, vs Dice 63 goals 75–90% for top cells.

## Decision (Eden, 2026-10-14): go with option C (≤2 / 2–5 / 5–20 / >20 $/day).

## Step D3 — stability of option C levels (run 2026-10-14)
Level from history vs level by the album's own daily spend. Same population as D1. h3 = up to 3 recent albums; h1 = last album.

| Level (history) | Players 14 / 15 (h3) | Revenue share | Same level now (h3 ; h1) | Lower | Higher | Revenue of the level from players who stayed (h3 ; h1) |
|---|---|---|---|---|---|---|
| 1: ≤$2 | 1.09M / 0.99M | 27–29% | 97% ; 97% | – | 3% | 43% ; 43% |
| 2: $2–5 | 61.8K / 55.7K | 20% | 32–33% ; 34–35% | 49–50% | 18% | 33–34% ; 36–37% |
| 3: $5–20 | 42.7K / 37.2K | 34% | 46–48% ; 47–50% | 45–47% | 7% | 59% ; 62–63% |
| 4: >$20 | 7.0K / 5.7K | 17–18% | 46–52% ; 46–54% | 48–54% | – | 78–84% ; 76–83% |

Reading:
- Known: level 1 keeps 97% of players, but only ~43% of its revenue comes from players who stayed — ~57% comes from the 3% who moved up during the album. The pre-album level misses exactly the players worth targeting → a daily tier (as in Dice) is required.
- Known: levels 2–4 keep only 32–54% of players; about half spend below their level (same pattern as Dice: Medium 55%, Hard 43%, Extreme 58–60% same).
- Known: last-album-only (h1) is as good as or slightly better than the 3-album average (≤3 points). Simpler rule (h1) is acceptable.
- Known: in levels 3–4 most of the revenue still comes from players who stayed (59–84%) → the pre-album level is a usable starting point for the high levels.

## Step D4 — spend pace curve by option-C level (run 2026-10-14)
Payers with album spend > 0, same population as D1; level from the LAST album played (h1, simpler rule, equal accuracy in D3). n = 42 days (14, 15). Pooled share of album spend reached by end of the checkpoint day.

| Level | Payers 14 / 15 | 10% | 25% | 50% | 60% | 75% | 85% | 90% | 95% | Median player at 50% / 75% |
|---|---|---|---|---|---|---|---|---|---|---|
| 1: ≤$2 | 264K / 236K | 9% | 22–24% | 47% | 59% | 75% | 86% | 90–91% | 95% | 50–52% / 100% |
| 2: $2–5 | 54K / 48K | 11% | 26–27% | 51–52% | 63–64% | 78% | 87% | 91% | 95–96% | 54–55% / 83–84% |
| 3: $5–20 | 43K / 35K | 11–12% | 28% | 52–54% | 64–65% | 78–79% | 88% | 91–92% | 95–96% | 54–56% / 82–83% |
| 4: >$20 | 8.7K / 6.1K | 12–14% | 29–30% | 54–57% | 65–68% | 80% | 88–89% | 92% | 96% | 55–58% / 82–83% |

Reading:
- Known: Disney spend is close to linear in time for every level (share ≈ time, higher levels a few points ahead). Albums 14 and 15 agree within 1–3 points → a stable curve.
- Known: no late acceleration (consistent with the flat end-of-album lift).
- Known: similar to Dice's ACTUAL pace (Dice Easy 72–73% / Hard 75–78% at 75%), not to the Dice formula curve.
- Known: the median level-1 payer has already spent 100% of their album total by 75% of the album (one-off buyers); levels 2–4 ≈ 82–84%.
- Proposal: use the measured table (average of the last two albums, per level) as the Disney curve; refresh every album. A plain linear curve would be within ~5 points.

