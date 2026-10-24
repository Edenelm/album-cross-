# Why Dice comes back slowest when the stock is ~0 everywhere: free inflow and out-of-stock after close (2026-10-24)

Eden (2026-10-24, approved a+b): the stock check showed that all players end the close day almost empty in all three games (`topic6-stock-by-status-2026-10-24.md`). So why does Dice come back slowest? We checked two leads for days 1–3 after close vs the same player mid-album (close−18..−5):
(a) does Dice give more free coins/rolls after close; (b) do Dice players run out of stock less often.
SQL: `claude/topic6_free_inflow_oos_2026-10-24.sql` (Dice 105 GB, Domino 21 GB, Disney 115 GB; I estimated 10–50 GB per game when asking. Dice and Disney were about 2× that).

## Definitions
- Population, status (on close−1), levels: as `topic6-payout-by-status-2026-10-24.md`. Players who played mid-album. Dice 63 / Domino 20 / Disney 15.
- **Free inflow** = all coins/rolls received except purchases. It includes play winnings (level completed, board), daily gifts, timers, events and ads. **The source list is my choice:**
  - Dice: `rolls_in_sum − rolls_amount_from_purchase` (`30_intermediate.user_daily_rolls_in_out`). Checked that `rolls_in_sum` includes bought rolls (33,479 of 33,483 purchase days). The 1.2M cohort is left out.
  - Domino (`prod_10_staging.stg_coins_in_vw`): all sources except purchase, 1plus1, 1_plus_6, dream pass premium, progress_offer, scrolling, vault, store bundle gift, google play points, compensation, debug and '' (unknown source, 6% of coins in).
  - Disney (`mp_coins_in_vw`): all sources except purchase, purchase_gift, scrolling, journey-panel, raining_gift_premium, play points, free, compensation, level start and ''.
- Free per day ÷ own play per day mid-album = days of play the game gives free each day (median player). Free share = free ÷ play in the same days (whole group).
- **Out of stock** day: Dice `not_enough_rolls_count > 0` (Eden's choice 2026-10-19); Domino `ooc_today_flag`; Disney `out_of_coins_counter > 0`. The definitions differ, so compare only days 1–3 vs mid-album inside each game. Rate = out-of-stock days ÷ days played.
- Bought in days 1–3 = next-album spend > 0 on close+1..+3 (album table).
- Levels of free inflow are not comparable across games (different sources); the change vs mid-album is.

## Results: paying players $2–20 a day (all paying: same pattern)
### (a) Free inflow: days of own play given free each day, mid-album → days 1–3
| Status | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| Finished | 0.96 → 0.62 (−35%) | 1.18 → 0.78 (−34%) | 0.81 → 0.57 (−30%) |
| 1–2 short | 0.96 → 0.58 (−40%) | 1.18 → 0.93 (−21%) | 0.82 → 0.57 (−30%) |
Free share of play, mid → days 1–3: finishers Dice 94 → 86% (−9%), Domino 127 → 109% (−14%), Disney 79 → 66% (−16%); 1–2 short 94 → 90% / 126 → 114% / 80 → 72%.

### (b) Out of stock: share of days played, mid-album → days 1–3
| Status | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| Finished | 83% → 78% | 72% → 67% | 51% → 44% |
| 1–2 short | 84% → 83% | 72% → 70% | 54% → 50% |

### Bought in days 1–3
| Status | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| Finished | 55% | 57% | 59% |
| 1–2 short | 55% | 58% | 63% |
Players ($2–20): finishers 9,561 / 4,024 / 7,489; 1–2 short 11,736 / 5,747 / 10,181.

## Reading
- **Fact (a):** free inflow falls after close in all three games by about a third for finishers (Dice −35%, Domino −34%, Disney −30%). Dice does not give more for free after close. For 1–2 short, Dice falls the most (−40%).
- **Fact:** as a share of what they play, Dice players get a little less of a drop (finishers −9% vs −14% / −16%). This matches the payout result (t6j), but the gap is small.
- **Fact (b):** after close players run out of stock a little less often in every game (−2 to −7 points). Dice is not different. In Dice the measure fires on most days (83%), so it is a weak signal there.
- **Fact:** the share who buy in days 1–3 is close across games: finishers 55% Dice vs 57–59%.
- **Answer:** neither lead explains the slow Dice return. Dice does not refill players more for free, and they do not get stuck less. They start buying at almost the same rate.
- **What is left (hypotheses, not tested):** (1) the gap is in how much each buyer spends, or in days 4–7, not in whether they buy. (2) Album 63 was weak at every level (topic 7; album 61 came back better in point 1).

## Next (not run; for Eden to decide)
- Split the week-after return (s6c) into % who buy × spend per buyer × days 1–3 vs 4–7, three games, finishers and 1–2 short. About the same cost as the payout-by-status run.
- Re-run Dice with album 65 after 2026-10-27 (already open).
