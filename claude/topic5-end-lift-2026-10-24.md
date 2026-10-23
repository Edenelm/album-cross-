# Topic 5: album to album — more payers close at close-4, stronger end? (2026-10-24)

Eden: show the change Dice 61→63, Domino 19→20, Disney 14→15; the end was stronger in revenue; bringing payers close to finish goes with a stronger end; Dice 61 and Domino 19 also had a problem, not only Disney.
SQL: `claude/topic5_end_lift_2026-10-24.sql` (Disney 24 GB `solitaire-dreams-411507.bi_prod.user_daily_album`, Domino 10 GB `domino-dreams-dbt.prod_40_mart.user_daily_album`, Dice 105 GB `dice-dreams-dbt.50_reporting.user_daily_album`).

## Definitions
- Population: standard-population payers, exactly as `topic5-tiers-2026-10-23.md` (same player counts per album).
- Close at close-4 = ≤3 stickers missing on the last row on or before close-4. Revenue share = their revenue up to close-4 ÷ all these payers' revenue up to close-4 (the topic-5 goal metric, all tiers together).
- End lift = ARPDAU of the last 4 days (close-4 … close-1) ÷ ARPDAU of the whole album − 1. Active days only, close day left out (as the topic-1 end-lift docs).
- Last-4-days revenue from close players = their share of the population's revenue on close-4 … close-1.

## Results
| Album | Payers | Close at close-4: players / revenue | End lift (all payers) | End lift: close / not close | Last-4-days revenue from close players |
|---|---|---|---|---|---|
| Dice 61 | 196K | 16% / 39% | +9% | +28% / −6% | 49% |
| Dice 63 | 203K | 30% / 54% | +16% | +29% / −6% | 64% |
| Domino 19 | 119K | 5% / 31% | +13% | +34% / 0% | 40% |
| Domino 20 | 107K | 23% / 55% | +17% | +34% / −13% | 67% |
| Disney 14 | 371K | 16% / 44% | −5% | +11% / −21% | 54% |
| Disney 15 | 326K | 12% / 43% | +1% | +13% / −12% | 51% |

## Reading
- **Fact:** Dice 61→63: payers close at close-4 went from 16% to 30% (39% → 54% of revenue); end lift from +9% to +16%.
- **Fact:** Domino 19→20: close payers from 5% to 23% (31% → 55% of revenue); end lift from +13% to +17%.
- **Fact:** Disney 14→15: close payers did not grow (16% → 12%; revenue 44% → 43%); end lift stayed flat (−5% → +1%).
- **Fact:** in every album the close payers lift at the end and the rest do not (−21% to 0%). In Dice and Domino the close payers lift +28% to +34%; in Disney only +11% to +13%.
- **Fact:** Dice 61 (16%) and Domino 19 (5%) had as few close payers as Disney 15 (12%) — the problem was not only in Disney; Dice and Domino fixed it in the next album.
- **Interpretation:** the end is carried by the payers who are close; when more payers are close, the end is stronger. Disney has two gaps: fewer close payers, and close payers who lift less at the end.
- **Not causal:** 6 albums, and other things changed between albums (album design, events, prizes). Across games the link is not a straight line (Domino 19 lifts +13% with 5% close). To prove it: a controlled test that brings a random half of the far payers close by close-4 (topic 8).
