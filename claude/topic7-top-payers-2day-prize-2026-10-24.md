# Dice 200K test arm: $2K+ payers only, prize = 2 days of own play (2026-10-24)

Eden's decision (2026-10-24): the test arm is only $2K+ payers in the 200K tier, and the prize is 2 days of the player's own play.
SQL: `claude/topic7_top_payers_2day_prize_2026-10-24.sql` (11 GB) plus a reconciliation count (2 GB, album 63).

## Definitions
- **Group:** `album_reward_code` 7 (200K) on the last row before close, album spend (album start..close−1) ≥ $2,000, not excluded.
- **Own play a day:** rolls bet from album start to close−1, divided by the album's days.
- **Finishers:** 144 stickers on close−1. The Dice daily table does not update on the close day, so close-day finishers are missing.
- **Revenue share:** out of album revenue of all non-excluded players.

## Results
| Album | Players | Finished | % of album revenue (all / finishers) | Median album spend | Median rolls a day | Today's prize in days (median) | 2-day prize (p25 / median / p75) | Extra rolls for finishers |
|---|---|---|---|---|---|---|---|---|
| 59 | 634 | 305 | 7.7% / 4.1% | $2,955 | 198,091 | 1.0 | 313K / 398K / 573K | 108,721,940 |
| 61 | 415 | 214 | 6.0% / 3.3% | $2,825 | 268,867 | 0.74 | 422K / 539K / 723K | 107,658,667 |
| 63 | 591 | 296 | 7.1% / 3.8% | $2,805 | 252,691 | 0.79 | 381K / 505K / 661K | 128,683,126 |

## Reading
- **Fact:** for these players the 200K prize is about one day of their own play or less (0.74–1.0). A 2-day prize means about 400K–540K rolls for the median player, which is 2.0–2.7 times today's prize.
- **Fact:** about half of the group finishes (296 of 591 in album 63), so the prize reaches about 300 players per album.
- **Cost:** about 108M–129M extra rolls per album. That is about 1.3–1.4 days of these finishers' own play. The rolls are not converted to $, because there is no agreed price per roll.

## Count does not match the earlier slide
The 200K tier size matches the earlier slide: 27,772 players in album 63 (27,297 not excluded) against 27,034 on the slide.
The spend bands do not match:

| Band | Album spend (this run) | Earlier slide |
|---|---|---|
| $2K+ | 591 | 1,484 (or 1,409 on the return slide) |
| Under $150 | 14,721 | 11,080 |

The earlier numbers come from the external grand-prize analysis (`dice_dreams_ba/.../album_grand_prize/`, not in this repo). It used a different spend window: the proposal there has "$2K+ normalized over the last 3 albums = 549 players".
**Open question for Eden:** which $2K+ definition does the test use?

## Update (Eden 2026-10-24): not 500K; test 250K or 300K
Prize in days of own play, albums 59 / 61 / 63:

| Prize | Album 59 | Album 61 | Album 63 |
|---|---|---|---|
| 200K (today) | 1.0 | 0.74 | 0.79 |
| 250K | 1.26 | 0.93 | 0.99 |
| 300K | 1.51 | 1.12 | 1.19 |

Extra rolls per album, for finishers only, at today's finish rate:

| Prize | Album 59 | Album 61 | Album 63 |
|---|---|---|---|
| 250K | 15.3M | 10.7M | 14.8M |
| 300K | 30.5M | 21.4M | 29.6M |

- **Test size:** about 300 finishers per album. With two arms plus Control, each arm gets about 100 finishers per album, so run the test over 2–3 albums or pick one size.
- **Slide:** t7e replaces t7d. t7d moved to the bottom of the deck.
