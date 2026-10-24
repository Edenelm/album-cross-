# Disney 15 quiet vs release days on total game revenue, with a calendar control (2026-10-24)

Eden asked why slide v144a shows $873,249 a day, when Disney's revenue is much higher. That number was the album-table spend of standard-population payers only, about 80% of game revenue.
SQL: `claude/disney15_windows_game_revenue_2026-10-24.sql`. Disney: 2.3 GB, total game revenue as in the deck (daily metrics gross revenue, excluded users out). Domino: 0.2 GB, same dates.

## Results (revenue per day)
| | Days 10–13 (Sep 2–5) | Days 16–19 (Sep 8–11) | Change |
|---|---|---|---|
| Disney, total game revenue | $1,035,476 | $930,837 | −10% |
| Disney, same weekdays only (Wed–Fri) | $1,008,545 | $925,805 | −8% |
| Domino, same dates (no Disney release, Domino mid-album) | $354,849 | $312,489 | **−12%** |

## Reading
- **Fact:** on total game revenue the drop is about −10%, close to the −11% on the slide.
- **Fact:** days 16–19 are Sep 8–11, the week after US Labor Day. In the calendar check, that week was weak in every game.
  - Domino had no Disney release on those days, and it dropped −12% on the same dates.
- **Answer:** the drop on the "release days" is the calendar, not the sticker release. Against Domino, Disney did about the same or slightly better (−10% vs −12%).
- **The v144a message does not hold:** "when the game releases many stickers and pays out more coins, payers spend 11% less" is not supported. The payout difference (53% vs 63%) is still a fact.
- **v144b (the sticker gap grows in days 14–26) is not affected:** it measures stickers, not spend. It is still correlation, from one album.
