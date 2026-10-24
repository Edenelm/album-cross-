# Stock at the end of the close day, by close status (2026-10-24)

Eden (2026-10-24, approved): for every paying player, the balance at the end of the close day in days of the player's own play (÷ own play per day close−18..−5), by close status (finished / 1–2 / 3 / 4+ short), Dice 63 / Domino 20 / Disney 15.
Hypothesis to check: Dice finishers and players 1–2 short carry more days of stock than in Domino and Disney, which would explain why they come back slowest even though their payout goes up 5% (t6j).
SQL: `claude/topic6_stock_by_status_2026-10-24.sql` (Dice 121 GB, Domino 6 GB, Disney 48 GB).

## Definitions
- Population, status (on close−1) and levels (all paying, $2–20 a day): the same as `topic6-payout-by-status-2026-10-24.md`. Status counts match that doc (Dice 19,688 / 29,743 / 76,491 / 65,898; Domino 8,071 / 13,687 / 24,642 / 53,515; Disney 12,613 / 17,183 / 29,956 / 245,055).
- **Days of stock** = balance at the end of the close day ÷ (own play close−18..−5 ÷ 14). **My choice:** calendar days (as point 1). An active-days version (÷ play per day the player played) gives almost the same medians, shown in the SQL output.
- Balance = last value on the close day; for players with no event that day, the last value on close−3..close.
- Sources:
  - Dice: play = `30_intermediate.user_daily_rolls_in_out.rolls_out_sum`. That table has no end-of-day balance (only the day's max and min), so the balance = `rolls_balance` of the player's last event on the close day in `20_core.rolls_in_out_vw` (its source layer). The 1.2M-balance cohort is left out, as in the payout check (97 / 54 / 20 / 65 players).
  - Domino: `prod_30_intermediate.int_rv_user_daily_coins_balance.coins_balance_in_allowance_end_day` ÷ play from `int_rv_user_daily_coins_spent.spent_in_allowance` (all coins out). Both are in allowance units.
  - Disney: balance = `bi_prod.solitaire_user_daily_metrics_agg_df.coins_allowance_enday`; play = `mp_raw_prod_vw.mp_coins_out_vw` level start + extra tiles / undo / wild / trade in allowance units (filters as the payout check).
- **Mistake caught:** in Disney, `coins_allowance_enday` is already the balance in allowance units. Its median on 2026-10-05 is 3.4, and Mixpanel `coins_balance_in_allowance` is 3.6. My first run divided `enday_coins_balance` by it, which gave 178 days of stock. Fixed and re-run.
- **Dice check:** for all players active on the close day (2026-09-07), the end balance has a median of 76 rolls. The balance at the start of the next mtx day (`40_mart.user_daily_mtx_brut_rolls`, after the overnight refill) has a median of 745, and play that day has a median of 8,850 rolls. On either reading the stock is under 0.1 day.

## Results
### Median days of stock at the end of the close day (all paying · $2–20 a day)
| Status | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| Finished | 0.0 · 0.0 | 0.1 · 0.0 | 0.1 · 0.1 |
| 1–2 short | 0.0 · 0.0 | 0.0 · 0.0 | 0.0 · 0.0 |
| 3 short | 0.0 · 0.0 | 0.0 · 0.0 | 0.0 · 0.0 |
| 4+ short | 0.1 · 0.1 | 0.1 · 0.2 | 0.1 · 0.1 |
Three in four players have less than 1 day: the 75th percentile for finishers is 0.4 / 0.5 / 0.8 days and for 1–2 short 0.1 / 0.2 / 0.3 days.

### Share of players with 2+ days of stock (all paying · $2–20)
| Status | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| Finished | 13% · 11% | 13% · 13% | 13% · 12% |
| 1–2 short | 4% · 5% | 6% · 7% | 7% · 6% |
| 3 short | 1% · 1% | 4% · 6% | 3% · 3% |
| 4+ short | 13% · 13% | 13% · 16% | 8% · 8% |
4+ days: finishers 7% / 7% / 6%, 1–2 short 2% / 3% / 3%.
Player share and album revenue share by group: see `topic6-payout-by-status-2026-10-24.md` (same groups). Dice: finishers are 10% of payers and 28% of album revenue; 1–2 short are 15% and 24%.

## Reading
- **Fact:** in all three games the typical paying player ends the close day almost empty: the median is under 0.1 day of own play, in every status group.
- **Fact:** Dice finishers and players 1–2 short do not carry more stock than in Domino and Disney. The share with 2+ days is the same for finishers (13% in all three) and lowest in Dice for 1–2 short (4% vs 6–7%).
- **Answer:** the hypothesis is **not supported**. Stock at close does not explain why Dice finishers and players 1–2 short come back slowest.
- **What is left (hypothesis, not tested):** Dice pays back more on the rolls used in the days after close (t6j: +5%). This is a flow during play, not a stock at close. It may still stretch each purchase over more days. The within-game payout split (`topic6-short-payers-2026-10-24.md`) gave no support for this either.
- The finisher prize is paid at completion (`finisher_prize_burn_queries.sql`), and most finishers complete before the close day, so by the end of the close day most of the prize has already been played. A big prize (point 1) does not show up as stock at close.

## Recommendation
- Stock-based fixes (for example, removing stock or ending the album with an empty balance): **do not adopt**. The stock is already near zero.
- t6j test (tighter Dice payout in days 1–3 for finishers and 1–2 short): still **test**, with a lower expected effect. The stock route is ruled out, so the test checks only the payout flow.
