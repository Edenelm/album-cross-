# Total game revenue after the album closes vs the last month, three games (2026-10-24)

Eden (2026-10-24): before checking purchase mix, check what happens to each game's revenue after the album ends. The claim to check is that Dice has the best revenue after close relative to the last month. If so, maybe cheaper offers or a higher payout work better. Also: slides 61–64 tell a payout story that the checks do not seem to support.
SQL: `claude/topic6_game_revenue_after_close_2026-10-24.sql` (Dice 3 GB, Domino 4 GB, Disney 11 GB).

## Definitions
- Game revenue is the deck-wide definition (`game_revenue_rebase_queries.sql`): all players' purchase revenue from daily metrics, with excluded, cheater and test users taken out.
- Base = average revenue a day over close−30..close−1. The close day is left out because it is a half day.
- Compared windows: last week (close−7..−1), close day, days 1–3, days 1–7 after close. All are shown as % of the base.
- Albums: two per game. Dice 61 (close 2026-07-27) and 63 (2026-09-07); Domino 19 (08-24) and 20 (10-12); Disney 14 (08-24) and 15 (10-05).

## Results (% of the last-30-day average)
| Game · album | Last week | Close day | Days 1–3 | Days 1–7 |
|---|---|---|---|---|
| Dice 61 | 105% | 107% | 99% | **112%** |
| Dice 63 | 107% | 94% | 85% | **92%** |
| Domino 19 | 98% | 85% | 85% | 95% |
| Domino 20 | 108% | 103% | 94% | 110% |
| Disney 14 | 91% | 82% | 80% | 96% |
| Disney 15 | 96% | 96% | 96% | 103% |
Two-album average, days 1–7: Dice 102%, Domino 102%, Disney 99%.
Base $ a day: Dice $732K / $707K, Domino $358K / $328K, Disney $1.21M / $1.06M.

## Same split for paying finishers ($2–20 a day, week after vs own pace; `topic6-before-after-2026-10-24.md`)
| | Dice | Domino | Disney |
|---|---|---|---|
| Previous album (61 / 19 / 14) | 129% | 134% | 135% |
| Latest album (63 / 20 / 15) | **110%** | 140% | 128% |

## Reading
- **Fact:** Dice is not always the best after close. With album 61 it was the best of all six closes (112% in the week after). With album 63 it was the worst (92%). Averaged over the two albums, the three games are about equal (99–102%).
- **Fact:** the finishers show the same pattern. In the previous albums Dice finishers came back almost like the others (129% vs 134–135%). The big Dice gap (110%) exists only in album 63.
- **Fact:** every finisher analysis behind slides 61–64 (s6c, t6e, t6j, t6f) and the checks of 2026-10-24 (stock, free inflow, buyers × spend) uses Dice 63, the weak close.
- **Interpretation:** the Dice gap is much bigger in album 63. ~~The payout cannot explain the swing~~ (corrected later the same day). Dice 61 finishers' payout dropped more after close (−18% vs −12% in 63) and they came back better. That fits the payout lead (`topic6-payout-prizes-by-level-2026-10-24.md`).
- **Hypothesis (not tested):** album 63 closed on Monday 2026-09-07, which is US Labor Day, so its days after are the post-holiday week. Other live events in that week may also play a part.
- **Answer to "cheaper offers or a higher payout work better":** the data does not support a higher payout. Where the payout cut after close was bigger (Dice 61, Domino, Disney), the return was better. Cheaper offers were not tested.

## Payout measure note
- The "+5% payout for Dice finishers" on t6j is the slide 36 measure: median player, album prizes left out.
- The group payout with album prizes (`payout-mixpanel-def-2026-10-20.md`) gives Dice finishers −18% (album 61) and −12% (album 63) after close, close to Domino (−9% / −17%).
- So "Dice gives more back after close" holds only without album prizes. Correction: with prizes, on the slide cut (status on close−1), Dice still has the smallest drop (−8% vs −16% / −14%; t6j, t6k, t6l).

## Recommendation
- Payout or offer change after close as a revenue lever: **do not adopt**.
- t6j test (tighter Dice payout days 1–3): **TEST** (corrected later the same day, see `topic6-payout-prizes-by-level-2026-10-24.md`). Re-check with Dice 65 after 2026-10-27 before starting.
- Slides: applied 2026-10-24. New slide tg1 before s6c; s6c message now covers both albums.

## Calendar check (Eden 2026-10-24: Domino 19 and Disney 14 look like Dice 63, is it the same case?)
SQL: `claude/topic6_calendar_check_2026-10-24.sql` (Dice 2 GB, Domino 2 GB, Disney 7 GB). Same measure as tg1: days 1–7 after a date ÷ average day of the 30 days before. It is taken at every game's close date, in all three games. * = that game's own album close.

| Date | Dice | Domino | Disney |
|---|---|---|---|
| 2026-07-27 | **112%*** (61) | 94% | 93% |
| 2026-08-24 | 101% | **95%*** (19) | **96%*** (14) |
| 2026-09-07 | **92%*** (63) | 90% | 85% |
| 2026-10-05 | 109% | 112% | **103%*** (15) |
| 2026-10-12 | 103% | **110%*** (20) | 99% |

- **Fact:** the week after 2026-09-07 was weak in all three games. Domino (90%) and Disney (85%) had no album close that week, and they dropped as much as Dice 63 (92%) or more.
- **Fact:** Domino 19 and Disney 14 (95% / 96%) are in their usual summer range. Their weeks without an album close in summer were 94% / 93%.
- **Fact:** the October weeks were strong in all games, with or without a close (99–112%).
- **Answer:** yes, it is the same case, and the case is the calendar, not the album end.
  - The Dice 63 dip is the week of 2026-09-07 (US Labor Day, back to school), which hit every game.
  - Against the other games in the same week, the Dice close was not weak: 92% vs 90% / 85%.
- **Consequence for the latest-album comparisons (s6c, t6j, t6k, t6l):**
  - The Dice 63 week after falls in a weak calendar week.
  - The Domino 20 and Disney 15 weeks after fall in strong October weeks.
  - Part of the "Dice comes back slowest" gap is the calendar.
- **Rough check, my choice, two different measures so only a pointer:** finishers' week after ($2–20, vs own pace) divided by the whole game's week after (vs last 30 days).
  - Latest album: Dice 110/92 = 1.20, Domino 140/110 = 1.27, Disney 128/103 = 1.24.
  - Previous album: Dice 129/112 = 1.15, Domino 134/95 = 1.41, Disney 135/96 = 1.41.
  - After this adjustment Dice finishers are still the lowest in both albums. The gap to Domino and Disney is smaller in album 63 than the raw numbers show, and larger in album 61.
- **tg1 message "Dice was the best close in 61 and the worst in 63" is misleading:** the swing is the calendar. Proposed new message (not applied):
  > The week after close follows the calendar: early September was weak in all three games, October strong. Album ends add little on top.
