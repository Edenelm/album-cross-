# Finisher recount: 144 by end of close day (2026-10-19, Eden approved)

## Decision (Eden, 2026-10-19)
- **Finisher = 144 unique set stickers by the END of the close day** (close day included). Not the game flag.
- The close day is left out **only for daily averages** (ARPDAU / revenue per active day at the end of the album), because it is a half day.
- Unchanged: standard population (not first album, login ratio >= 0.5 on the last row before close, exclusions, has a row on close−1); album revenue = album-table spend from album start to close−1 (numerator and denominator); payer = paid during the album.

## Data note
- Dice: `50_reporting.user_daily_album` has a close-day row for everyone, but sticker counts do not move on it (0 players reach 144 on the close-day row). Close-day finishers are counted from `30_intermediate.fact_user_album_stickers` (distinct common/golden/super stickers with collected date <= close date). For finishes before close, the two tables match 1:1 in every album.
- Domino / Disney: the close-day row exists and its counts match the game flag (flag-only finishers with < 144 left out, as before).
- The 2026-10-19 "recovery" runs used "144 OR game flag"; that over-counts Dice (61: 19,087 payer finishers vs 17,347 by 144 only). Numbers below are 144 only.

SQL: claude/finisher_recount_queries.sql. Scans: Dice 10.2 + 27.7 + 23.5 GB, Domino 16.5 + 19.4 GB, Disney 39.6 + 34.1 GB.

## 1. Finishers per album (standard population)
Old rule reproduces the deck exactly (Dice 61 14,249, Domino 17/19/20 7,783 / 5,319 / 8,548, Disney 14/15 14,037 / 13,184).
| Album | Payers | Payer finishers old → new | Payer finish rate old → new | Finishers' share of album revenue old → new | All finishers old → new | Non-paying share of finishers old → new | Close-day finishers (payers / all) | Close-day finishers' rev share |
|---|---|---|---|---|---|---|---|---|
| Dice 59 | 195,194 | 17,600 → 21,876 | 9.0% → 11.2% | 25.2% → 29.2% | 18,869 → 23,347 | 6.7% → 6.3% | 4,276 / 4,478 | 4.0% |
| Dice 61 | 175,216 | 14,249 → 17,347 | 8.1% → 9.9% | 23.0% → 26.2% | 15,203 → 18,454 | 6.3% → 6.0% | 3,098 / 3,251 | 3.2% |
| Dice 63 | 182,280 | 18,939 → 22,690 | 10.4% → 12.4% | 27.7% → 31.3% | 19,173 → 23,121 | 1.2% → 1.9% | 3,751 / 3,948 | 3.6% |
| Domino 17 | 135,609 | 7,783 → 9,328 | 5.7% → 6.9% | 29.2% → 32.1% | 9,011 → 11,232 | 13.6% → 17.0% | 1,545 / 2,221 | 2.9% |
| Domino 19 | 118,955 | 5,319 → 6,980 | 4.5% → 5.9% | 22.5% → 26.2% | 7,270 → 9,992 | 26.8% → 30.1% | 1,661 / 2,722 | 3.7% |
| Domino 20 | 106,520 | 8,548 → 10,078 | 8.0% → 9.5% | 30.7% → 34.4% | 15,091 → 17,665 | 43.4% → 42.9% | 1,530 / 2,574 | 3.7% |
| Disney 12 | 381,637 | 22,575 → 29,327 | 5.9% → 7.7% | 18.2% → 22.6% | 26,262 → 34,944 | 14.0% → 16.1% | 6,752 / 8,682 | 4.4% |
| Disney 14 | 370,293 | 14,037 → 19,258 | 3.8% → 5.2% | 16.6% → 20.7% | 15,083 → 21,101 | 6.9% → 8.7% | 5,221 / 6,018 | 4.1% |
| Disney 15 | 325,155 | 13,184 → 16,780 | 4.1% → 5.2% | 18.5% → 22.1% | 13,924 → 17,726 | 5.3% → 5.3% | 3,596 / 3,802 | 3.6% |

Deck averages (two albums: Dice 61/63, Domino 19/20, Disney 14/15), old → new:
- Payer finish rate: Dice 9.3% → 11.2%; Domino 6.3% → 7.7%; Disney 4.0% → 5.2%.
- Finishers' revenue share: Dice 26% → 29%; Domino 26% → 30%; Disney 18% → 21%.
- Revenue share ÷ finisher share: Dice ~2.7 → ~2.6; Domino ~4.3 → ~4.0; Disney ~4.5 → ~4.1.
- Multiplier to 10% payers finishing: Domino ×1.6 → ×1.3; Disney ×2.6 → ×1.9; Dice already above 10% (×0.9).
- Game flag vs 144 (payers, by end of close day): Dice flag 10.9% / 13.6% vs 9.9% / 12.4% (flag over-counts by ~10%); Domino flag ≈ 144 (+0.3–0.5K flag-only players); Disney flag-only 2.1–3.9K payers (~10% of flagged).

## 2. When payer finishers finish (share of payer finishers)
| Album | Close day | Day before close | 2–3 days before | 4+ days before | Close day + last 3 days |
|---|---|---|---|---|---|
| Dice 61 / 63 | 17.9% / 16.5% | 32.0% / 31.6% | 40.1% / 38.5% | 10.0% / 13.4% | 90% / 87% |
| Domino 17 | 16.6% | 32.2% | 20.2% | 31.0% | 69% |
| Domino 19 / 20 | 23.8% / 15.2% | 43.2% / 25.9% | 27.9% / 46.4% | 5.2% / 12.5% | 95% / 88% |
| Disney 14 / 15 | 27.1% / 21.4% | 47.1% / 46.2% | 25.1% / 31.7% | 0.6% / 0.7% | 99% / 99% |
Finished by 4 days before close (Domino 17 / 19 / 20): 31% / 5% / 13% (old rule 37% / 7% / 15%).
Cumulative share already finished, by days before close (Domino 17 / 19 / 20): 8 days 1% / 0% / 0%; 7: 8% / 0% / 0%; 6: 16% / 0% / 0%; 5: 24% / 2% / 2%; 4: 31% / 5% / 13%; 3: 40% / 14% / 35%; 2: 51% / 33% / 59%; 1: 83% / 76% / 85%; close day 100%.

## 3. Finish rate by spend group ($ a day in the previous album), payers
Revenue here = daily metrics revenue (as in finisher_targets_queries.sql). Averages of two albums, old → new.
| Group | Dice 61/63 | Domino 19/20 | Disney 14/15 |
|---|---|---|---|
| $0 (no spend in previous album) | 6.1% → 7.1% | 4.1% → 5.0% | 1.9% → 2.5% |
| ≤ $2 | 6.5% → 8.0% | 3.7% → 4.7% | 2.0% → 2.8% |
| $2–5 | 13.3% → 16.2% | 7.4% → 9.3% | 4.8% → 6.5% |
| $5–20 | 16.6% → 19.8% | 16.0% → 19.1% | 9.7% → 12.6% |
| $20+ | 26.3% → 30.1% | 35.1% → 39.4% | 20.7% → 25.4% |
By album (new): Dice 7.0/7.2, 7.2/8.8, 13.7/18.7, 16.9/22.6, 26.6/33.7; Domino 4.0/6.1, 3.4/6.0, 6.4/12.2, 15.3/22.8, 34.8/44.0; Disney 2.6/2.4, 2.9/2.6, 6.4/6.7, 12.0/13.3, 23.9/27.0.
$20+ vs ≤ $2: Dice 3.8×, Domino 8.4×, Disney 9.1× (old 4–10×).

## 4. Domino 19 → 20 by previous-album $ a day (all eligible players)
| Group | Finish rate old → new (19 → 20) | Revenue per finisher, new (19 → 20) |
|---|---|---|
| $0 / did not pay | 1.1% → 3.5% became 1.6% → 4.0% | $46 → $23 |
| ≤ $2 | 1.9% → 4.0% became 2.7% → 4.9% | $108 → $109 |
| $2–5 | 4.4% → 10.0% became 6.2% → 11.8% | $270 → $278 |
| $5–20 | 12.0% → 19.5% became 14.9% → 22.2% | $635 → $623 |
| $20+ | 30.1% → 39.3% became 34.4% → 43.4% | $1,886 → $1,826 |
| All | 2.1% → 4.8% became 2.8% → 5.6% | $358 → $252 |
Finishers 9,992 → 17,665 (old 7,270 → 15,091). Revenue per finisher is daily-metrics revenue (old slide used album-table spend: $419 → $261); revenue per player is unchanged by the finisher rule.

## Facts / interpretation
- Fact: counting close-day finishers adds 16–27% of payer finishers and 3–4% of album revenue in every game.
- Fact: with the new rule Dice is above the 10% finisher goal (11.2% average; 63 meets both goals: 12.4% / 31.3%); Domino meets the 30% revenue goal on average (30%) but not the 10% finisher goal (7.7%); Disney meets neither (5.2% / 21%).
- Fact: the order of games and of spend groups does not change.
- Interpretation: close-day finishers are lighter payers (lower revenue share than their count share), so the revenue-to-finisher ratio drops a little in every game.


## 5. After completion (wave 2; same population, payers; daily-metrics revenue)
Usual = album start .. close−5 (ARPDAU). Window 1 = days 1–7 after the player's own completion day (close day left out of averages). Window 2 = days 1–7 after the close day. Old and new rule run in the same query, so the change is the definition only. (Some old deck values came from a slightly different population; replace them with this set.)
SQL: claude/finisher_recount_queries.sql (WAVE 2). Scans: Dice 20.1 GB, Domino 18.3 GB, Disney 25.7 GB.

| Album | Payer finishers old → new | Spend d1–7 vs usual old → new | In next album day 1 / day 3 (new) | Share of d1–7 days still in old album old → new |
|---|---|---|---|---|
| Dice 61 | 14,249 → 17,347 | 1.12 → 1.09 | 50% / 90% | 16% → 13% |
| Dice 63 | 18,939 → 22,690 | 1.01 → 0.98 | 48% / 87% | 18% → 15% |
| Domino 17 | 7,783 → 9,328 | 1.11 → 1.08 | 49% / 69% | 29% → 25% |
| Domino 19 | 5,319 → 6,980 | 1.19 → 1.15 | 67% / 95% | 10% → 8% |
| Domino 20 | 8,548 → 10,078 | 1.21 → 1.18 | 41% / 88% | 18% → 16% |
| Disney 14 | 14,037 → 19,258 | 1.20 → 1.16 | 74% / 99% | 7% → 5% |
| Disney 15 | 13,184 → 16,780 | 1.13 → 1.11 | 68% / 99% | 7% → 6% |

Spend in days 1–3 vs usual, by finish timing (new rule):
| Album | Close day | Day before close | 2–3 days before | 4+ days before |
|---|---|---|---|---|
| Dice 61 / 63 | 0.77 / 0.65 | 0.92 / 0.76 | 0.98 / 0.99 | 1.16 / 1.13 |
| Domino 17 / 19 / 20 | 0.80 / 0.87 / 0.95 | 0.93 / 0.96 / 0.88 | 1.09 / 1.30 / 1.20 | 1.12 / 1.20 / 1.37 |
| Disney 14 / 15 | 0.88 / 0.99 | 0.97 / 1.04 | 1.16 / 1.20 | small n |
Close-day finishers share of payer finishers: Dice 18% / 17%, Domino 17% / 24% / 15%, Disney 27% / 21%; day before: Dice 32% / 32%, Domino 32% / 43% / 26%, Disney 47% / 46%.

Window 2 (from close), spend d1–7 vs usual by status at END of close day (new) — average of two albums (Dice 61/63, Domino 17/19, Disney 14/15):
| Status | Dice | Domino | Disney |
|---|---|---|---|
| Finished | 1.07 | 1.07 | 1.12 |
| 1 missing | 1.01 | 0.98 | 1.04 |
| 2 missing | 0.98 | 0.96 | 0.97 |
| 3 missing | 0.90 | 0.92 | 0.80 |
| 4+ missing | 0.93 | 0.80 | 0.77 |
Old rule (status at close−1) gave 1.09 / 0.98 / 0.97 / 0.90 (Dice), 1.08 / 0.96 / 0.95 / 0.93 (Domino), 1.13 / 1.03 / 0.98 / 0.82 (Disney). Domino 20: 1.13 / 0.99 / 0.95 / 0.88.
Shares (payers / album revenue), new status: finished Dice 11% / 29%, Domino 6% / 29%, Disney 5% / 21%; 1 missing 4% / 7%, 2% / 6%, 3% / 8%; 2 missing 11% / 15%, 5% / 10%, 4% / 10%; 3 missing 32% / 26% (Dice 63 alone 40%), 7% / 11%, 10% / 19%.
Check (not about the definition): last-4-days spend vs usual for "3 missing" = Dice 0.56 / 0.43, Disney 0.62 / 0.63, but Domino 17 / 19 = 1.00 / 1.02. The deck line "already cut spend to ×0.4–0.6 before close" holds for Dice and Disney only.

## 6. Finish rates inside groups (wave 3; payers, standard population)
Old rule reproduces the deck exactly (group sizes, 2–3 / 4–6 / 7–10 rates, same-spend, $20+ missers and their week-after gap).
Finish rate by stickers missing 8 days before close, average of two albums (old → new):
| Missing 8 days out | Dice 61/63 | Domino 17/19 | Disney 14/15 |
|---|---|---|---|
| 2–3 | 39% → 42% | 47% → 51% | 20% → 25% |
| 4–6 | 16% → 19% | 15% → 18% | 8% → 10% |
| 7–10 | 9% → 11% | 5% → 7% | 3% → 4% |
By album (new): Dice 42.6 / 41.7, 17.8 / 19.4, 11.2 / 10.9; Domino 49.3 / 52.0, 21.6 / 14.2, 8.5 / 6.0; Disney 26.0 / 24.2, 10.1 / 10.7, 3.7 / 4.4.
Same-spend (4–6 missing 8 days out, $5–15 per active day in days 14–8): finish Dice 18% / 23% → 22% / 27%; Domino 19% / 13% → 22% / 17%; Disney 11% / 10% → 15% / 14%.
Disney finishers at Dice rates (Dice new rates per group × Disney payers 2–6 missing 8 days out − actual): +10.2K (14), +8.2K (15), average +9.2K = +51% of today's Disney payer finishers (old: +9.2K = +67%).
$20+ payers ending 2–3 missing (status at end of close day): Dice 1,504 / 1,594 (10.5% / 10.6% of album revenue), Domino 545 / 506 (4.5% / 5.6%), Disney 3,005 / 2,572 (9.3% / 9.4%). Week after close minus usual week: Dice −$76K / −$138K, Domino −$39K / −$38K, Disney −$236K / −$254K. Upper bound if they spent like $20+ finishers in the week after: Dice ~$90–95K, Domino ~$30–40K (new; was missing), Disney ~$200–265K. 5–11% of the old "2–3 missing" heavy group finished on the close day and moved to finishers.
Revenue share basis here = standard-population album revenue (the old slide used a game-wide total, so its shares were lower: 7.4–7.8% Dice, 8.1–8.6% Disney).
Not recounted: routes slide (finish rate by Wild/Joker route; original query not saved), disney-finishers rows "spend on last day" and "pay rate last 3 days", puzzle-joker two-Puzzle closers (3,223 is old rule).
