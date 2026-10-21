# Dice closing week: where the Wilds come from, day by day (2026-10-21)

Question (Eden, deck review item 4): on `closing-week` the Dice gameplay-Wild line appears, drops to about zero, then rises again. What changed?
Scope: all players, albums 61 and 63; players per day whose new sticker (first receipt) was filled by a Wild; d = days before close; close day excluded. Same scope as the slide.
SQL: `claude/dice_wild_sources_closing_week.sql` (dice-dreams-dbt, 30_intermediate.fact_user_album_stickers + 50_reporting.user_daily_album, 12.6 GB).

## Players per day, by source (album 63; album 61 in brackets)
| Source | d−8 | d−7 | d−6 | d−5 | d−4 | d−3 | d−2 | d−1 |
|---|---|---|---|---|---|---|---|---|
| Paid Wild (Pricing pack) | – | 4,659 (4,271) | 8,683 (6,303) | 6,985 (5,803) | 9,808 (8,560) | 13,427 (12,006) | 14,569 (12,879) | 14,745 (13,110) |
| Bonus Wheel (Crazy Wheel pack) | 47,977 | 17,619 | 117* | (2,771) | – | – | – | – |
| Trail final reward | – | – | – | – | – | 9,684 (8,012) | 20,221 (38,264) | 18,500 (36,594) |
| Blast grand prize | – | – | – | – | – | (811) | (2,772) | (1,874) |
| Merge collection / pending Trail | – | – | – | – | – | 233 (137) | 721 (750) | 1,340 (744) |
*pending Bonus Wheel rewards; groups under 50 players not shown.

## Facts
- The paid line never drops: bought Wilds rise every day of the last week (album 63: 4,659 → 14,745 players a day).
- The gameplay line is two events, not one stream: the Bonus Wheel gives Wilds 8–7 days before close (album 63) or 5 days before (album 61), and the Trail final reward from 3 days before close. Between them (days 6–4 in album 63) no event gives a Wild, so the gameplay line falls to ~0.
- Not a data issue: the totals reproduce the slide's counts (d−7 gameplay 18,498 = Bonus Wheel 17,619 + pending 870 + others; d−8 49,314).
- What the chart measures: the day a Wild filled a new sticker, not the day the Wild was received.

## Not checked
- Event calendar from the config (dates inferred from when rewards were collected). Who is eligible for the Trail final reward (players who finish the Trail) was not measured.

## Reading
- Interpretation: in Dice's last week the paid Wild is the only tool that is always available; free Wilds arrive in two event bursts. On days 6–4 a player who needs a Wild can only buy one.
