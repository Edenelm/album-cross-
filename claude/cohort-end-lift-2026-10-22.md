# Same players from their 1st to their 7th album: end lift and ARPDAU (2026-10-22)

Eden's option B. SQL: `claude/cohort_end_lift_album1_to_7.sql` (Dice 81 GB, Domino 84 GB, Disney 67 GB).
Cohort = players whose first album with rows in `user_daily_album` is album A; panel = those with rows in all 7 albums from A on (Dice A..A+12 by 2, Domino / Disney A..A+6), so every point is the same players. Album k = k-th album since joining (calendar albums, the panel played all of them). Active days, close day excluded, exclusions. Lift = last-4-days ARPDAU ÷ whole-album ARPDAU − 1. Slide = simple average of the two cohorts.

Panels: Dice 49 → 10,394 players, 51 → 7,437; Domino 13 → 21,833, 14 → 14,477; Disney 8 → 50,866, 9 → 166,270.

| Album since joining | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| Dice lift (49 / 51 → avg) | +13 / +40 → **+26%** | +28 / +27 → **+27%** | +29 / +12 → **+21%** | +10 / +21 → **+16%** | +21 / +19 → **+20%** | +10 / +20 → **+15%** | +1 / +24 → **+13%** |
| Dice ARPDAU avg | $1.31 | $1.69 | $1.75 | $1.73 | $1.63 | $1.56 | $1.56 |
| Domino lift (13 / 14 → avg) | +24 / +17 → **+21%** | +25 / +17 → **+21%** | +10 / +1 → **+5%** | +1 / +8 → **+4%** | +6 / +27 → **+16%** | +28 / +17 → **+22%** | +14 / +20 → **+17%** |
| Domino ARPDAU avg | $1.05 | $1.25 | $1.22 | $1.13 | $1.09 | $1.05 | $1.00 |
| Disney lift (8 / 9 → avg) | +24 / +2 → **+13%** | −2 / 0 → **−1%** | +7 / 0 → **+4%** | +4 / 0 → **+2%** | +5 / 0 → **+2%** | +2 / +2 → **+2%** | +3 / +2 → **+2%** |
| Disney ARPDAU avg | $1.31 | $1.27 | $1.16 | $1.02 | $0.95 | $0.93 | $0.87 |

Album behind each point: Dice 49 cohort k1..7 = 49..61, 51 cohort = 51..63; Domino 13 cohort = 13..19, 14 cohort = 14..20; Disney 8 cohort = 8..14, 9 cohort = 9..15.

## Reading
- Fact: the same Disney players lift only in their first album, and that +13% is album 8 (closed right after New Year, +24%); the album-9 cohort's first album lifted +2%. From album 2 to 7 the same players stay at −1% to +4%.
- Fact: the same Dice and Domino players keep lifting (Dice +13% to +27%, Domino +4% to +22%); Domino's dip at k3–4 is albums 15–17, the weak ends of that period (calendar, not tenure).
- Fact: the same Disney players spend less per day every album: $1.31 → $0.87 (−34%) from album 1 to 7. Dice rises then holds ($1.31 → $1.56, +19%); Domino peaks in album 2 and ends −5%.
- Interpretation: each point mixes tenure with the calendar album, so single steps (Domino k3–4, Disney k1) are album effects. The flat Disney end holds for every album after the first, for the same players.
- This weakens the "player mix" explanation of Disney's lower revenue per day (`album-curves` footnote): the same players also spend less per day as they get older (survivors only, no control).

## Check: is $1.31 first-album ARPDAU in Dice real? (Eden asked, 2026-10-22)
Same cohorts, split by install date (`50_reporting.user_daily_metrics_agg.install_date`) vs the first album's start; album-1 ARPDAU = album spend ÷ active days in that album. 96 GB. SQL at the end of `cohort_end_lift_album1_to_7.sql`.
| Dice | Group | Players | Installed ≤60 days before | 61–365 days | >1 year | Album-1 ARPDAU: ≤60d / >1y | Payers in album 1 (≤60d) |
|---|---|---|---|---|---|---|---|
| Cohort 49 | panel (all 7 albums) | 10,394 | 8,922 (86%) | 440 | 1,032 (10%) | $1.40 / $1.50 | 32% |
| | everyone who started in 49 | 247,083 | 200,787 (81%) | 10,092 | 36,195 | $1.10 / $0.81 | 22% |
| Cohort 51 | panel | 7,437 | 6,391 (86%) | 343 | 703 (9%) | $1.28 / $1.03 | 31% |
| | everyone who started in 51 | 173,801 | 143,686 (83%) | 7,669 | 22,436 | $1.11 / $0.77 | 22% |
(The "everyone" rows exclude the panel players; whole-album ARPDAU of all players: album 49 $0.97, 51 $0.98.)
- Fact: 86% of the panel installed in the 60 days before its first album; returners from before the table history are 9–10% and do not explain the level.
- Fact: even all new first-album Dice players spend $1.10 per active day in their first album, above the album average ($0.97–0.98). The panel (players who stayed 7 albums) spends more: $1.28–1.40, 31–32% of them pay in album 1 vs 22%.
- Interpretation: the $1.31 is real; it is high because the panel is the most engaged survivors, and because new Dice players already spend above average in their first album (hypothesis: early offers and the Kingdom 8 unlock that filters to engaged players — not checked).
- Why it looked odd: the Sept slide shows "1 album seen" = 4% of Dice revenue, but that group is mostly players who started in Sept or stopped after one album; it is not the same population.
