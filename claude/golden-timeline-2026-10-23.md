# Golden timeline for the median paying player (2026-10-23)

**Question (Eden):** the "Dice Never Leaves Players Waiting Long for a Rare" step chart, for new Goldens.
**SQL:** `claude/golden_timeline_2026-10-23.sql` (same as `rare_timeline_queries.sql`, Golden instead of the rare; Dice uses the fixed first-album rule). Scans: Dice 100 GB, Domino 18 GB, Disney 58 GB.
**Population:** standard population, payers (spent on any album day incl. close day): Dice 194,603 / 204,893, Domino 119,201 / 106,762, Disney 371,049 / 325,842 (match earlier runs).
**Goldens per album:** Dice 28, Domino 28, Disney 24. Step line = median Goldens held at the end of each day (the median player on a day is not the same player every day).
**Longest wait** = longest number of days between two increases of the median line, as % of album days (close day included in the album length).

| Album | Days | Median gap between new Goldens | Gaps ≤ 4 days | Goldens held at close (median) | Longest wait (median line) |
|---|---|---|---|---|---|
| Dice 61 | 36 | 2 | 91% | 27 of 28 (96%) | 3 days (8%) |
| Dice 63 | 43 | 2 | 84% | 27 of 28 (96%) | 5 days, days 13–18 (12%) |
| Domino 19 | 50 | 3 | 71% | 25 of 28 (89%) | 5 days, days 36–41 (10%) |
| Domino 20 | 50 | 2 | 73% | 27 of 28 (96%) | 6 days, days 4–10 (12%) |
| Disney 14 | 43 | 2 | 77% | 21 of 24 (88%) | 4 days, days 6–10 (9%) |
| Disney 15 | 43 | 2 | 79% | 20 of 24 (83%) | 6 days, days 7–13 (14%) |

Daily series (day:median held:share getting a new Golden) are in the query output; kept in this doc's SQL run, not repeated here.

## Reading
- **Fact:** Goldens arrive steadily in all three games: a new Golden every 2–3 days for the median payer, the longest wait 3–6 days (8–14% of the album).
- **Fact:** compare the rares (`rare-timeline-2026-10-20.md`): longest wait 14% Dice vs 26–30% Domino and 28–35% Disney. The long dry stretch in Domino and Disney is a rare (Royal) issue, not a Golden issue.
- **Fact:** at close the median payer holds 83–96% of the Goldens; Disney is lowest (83–88%).
- Method note: the rare doc counted the dry stretch slightly differently (album length without the close day); the gap between games is far larger than that difference.
