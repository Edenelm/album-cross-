# Revenue share within 3 stickers, last 7 days before close, per game (2026-10-25)

Eden (2026-10-25): per game, how much revenue share is within 3 stickers of 144, by days before the album closes. 7 days.
SQL: `claude/near_share_last7_2026-10-25.sql` (Dice 91 GB, Domino 4.6 GB, Disney 10.7 GB).

## Definitions
- Albums: latest per game (Dice 63, Domino 20, Disney 15).
- Population: standard-population payers (not first album, not excluded / cheater, login ratio ≥ 0.5 on the last row before close, row on close−1, paid incl. the close day).
- Within 3 = 141–144 unique set stickers on that day (finished included). Stickers on day close−k = last known count up to that day.
- Revenue = each payer's album spend from album start to close−1. The denominator is fixed for all 7 days (my choice, so the days compare).
- Check: payers and revenue match earlier runs exactly (Dice 63 203,118 / $24,623,460; Domino 20 106,762 / $12,824,543; Disney 15 325,842 / $36,513,467). The close−4 point matches `stand-close4-2026-10-18.md` (near revenue 53% / 55% / 43% there, 54% / 55% / 44% here).

## Results: % of album revenue from payers within 3 stickers (% of payers)
| Days before close | 7 | 6 | 5 | 4 | 3 | 2 | 1 |
|---|---|---|---|---|---|---|---|
| Dice 63 | 12% (3%) | 19% (6%) | 39% (18%) | 54% (30%) | 71% (50%) | 78% (60%) | 82% (66%) |
| Domino 20 | 5% (1%) | 12% (2%) | 30% (9%) | 55% (23%) | 69% (34%) | 75% (41%) | 78% (46%) |
| Disney 15 | 35% (8%) | 37% (9%) | 40% (10%) | 44% (12%) | 48% (14%) | 52% (16%) | 57% (19%) |
| Domino 19 (added 2026-10-28) | 20% (2%) | 24% (3%) | 27% (4%) | 31% (5%) | 38% (8%) | 44% (12%) | 52% (17%) |

Domino 19 row: `claude/near_share_last7_domino19_2026-10-28.sql` (domino-dreams-dbt, 5.6 GB), same definitions; 119,201 payers, $13.55M album revenue. Matches the n19 slide values (built 10-27 without a saved query).

## Reading
- **Fact:** Dice and Domino start low a week out (5–12%) and jump in the last 5 days, to 78–82% of revenue on the day before close.
- **Fact:** Disney starts higher a week out (35%) but climbs slowly, to 57% on the day before close. From close−4 on, Disney is below the other two every day.
- **Interpretation:** Dice and Domino bring most of the money close in the last days; in Disney about 4 in 10 revenue dollars are still 4+ away on the day before close.
- One album per game; the shape can change by album (Domino 19 was far below Domino 20 at close−4: 31% vs 55% in `stand-close4-2026-10-18.md`).
