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
- **Fact:** compare the rares (`rare-timeline-2026-10-20.md`): longest wait 14% Dice vs 26–30% Domino and 28–35% Disney. The long dry stretch in Domino and Disney is a rare (Royal) issue. **Updated 2026-10-23 (Eden):** Disney is behind on Goldens too — normal pace, but payers end 16–18% short (Dice 6–7%); see `disney-stalls-missing-2026-10-23.md`.
- **Fact:** at close the median payer holds 83–96% of the Goldens; Disney is lowest (83–88%).
- Method note: the rare doc counted the dry stretch slightly differently (album length without the close day); the gap between games is far larger than that difference.

## Domino by segment: easy vs hard (Eden, 2026-10-23)
Eden: to compare like with like, look at Domino hard players (easy players need 3 Goldens + 2 Royals at the gate, hard 1 Golden + 2 Royals). Segment = `album_segment` on the player's first row. Same query with the segment split (`claude/golden_timeline_2026-10-23.sql`, Domino section, 19 GB). Assumes 28 Goldens in both segments.

| Domino | Payers | Goldens at close: average | median | Hold all 28 | Longest wait (median line) |
|---|---|---|---|---|---|
| 19 easy | 107,776 | 83% | 25 | 7% | 4 days (8%) |
| 19 hard | 11,425 | 90% | 27 | 34% | 4 days (8%) |
| 20 easy | 97,937 | 89% | 27 | 18% | 6 days (12%) |
| 20 hard | 8,825 | 94% | 27 | 48% | 7 days (14%) |

- **Fact:** the "83%" for Domino on the goldens slide matches album 19 easy (= almost all payers, 90% are easy). Hard players end at 90% (19) / 94% (20), the same level as Dice (94%).
- **Fact:** the pace is the same in both segments (longest wait 8–14%).
- **Reading:** Domino's Golden shortfall at the end comes from the easy segment, whose gate holds 3 Goldens; on like-for-like players Domino looks like Dice. Disney stays the only game ending clearly short (83%; median 20 of 24).

## All 144 stickers, median paying player (Eden, 2026-10-23)
Same query with all set stickers (Dice common / golden / super; Domino and Disney common / golden / royal). Domino split by segment. Scans: Dice 101 GB, Domino 19 GB, Disney 58 GB.

| Album | Payers | Median gap between new stickers | Held at 70% of the album | Held at close | Longest wait (median line) |
|---|---|---|---|---|---|
| Dice 61 | 194,603 | 1 day | 117 (81%) | 140 (97%) | 2 days |
| Dice 63 | 204,893 | 1 day | 118 (82%) | 141 (98%) | 2 days |
| Domino 19 hard | 11,425 | 1 day | 129 (90%) | 141 (98%) | 3 days |
| Domino 20 hard | 8,825 | 1 day | 131 (91%) | 142 (99%) | 4 days |
| Domino 20 easy (reference) | 97,937 | 1 day | 126 (88%) | 140 (97%) | 2 days |
| Disney 14 | 371,049 | 1 day | 129 (90%) | 139 (97%) | 3 days |
| Disney 15 | 325,842 | 1 day | 111 (77%) | 138 (96%) | 2 days (flat days 10–13: 55 → 57) |

- **Fact:** on all 144 stickers the median payer gets something new almost every day in all three games (median gap 1 day, longest wait 2–4 days) and ends 2–6 stickers short.
- **Fact:** Dice keeps more for the end (82% at 70% of the album vs ~90% in Domino hard and Disney 14), so its last 30% has more new stickers to give.
- **Reading (updated 2026-10-23, Eden):** Dice and Domino flow steadily; Disney 15 comes in waves with two 4–6 day lulls when events pause (`disney-stalls-missing-2026-10-23.md`). The end gap is in rares and, for Disney, Goldens.

## All 144 stickers, Domino 20 ALL payers (Eden, 2026-10-23, later)
Eden: on the all-144 step chart, Domino = album 20, median paying player (paid on any album day), all players (no easy/hard split).
SQL: `claude/all144_steps_2026-10-23.sql` (Domino 9 GB; Dice 63 and Disney 15 reran with the same logic, 96 GB / 27 GB, to get the daily series).
Mockup: `claude/slides/all144-steps-mockup-2026-10-23.html` (not in the deck yet).

| Album | Payers | Held at 70% of the album | Held at close | Longest wait (median line) |
|---|---|---|---|---|
| Dice 63 | 204,893 | 118 on day 30 of 43 (82%) | 141 (98%) | 2 days (5%) |
| Domino 20 all | 106,762 | 127 on day 35 of 50 (88%) | 140 (97%) | 3 days, days 40–43 (6%) |
| Disney 15 | 325,842 | 110 on day 30 of 43 (76%) | 138 (96%) | 2 days (5%) |

Daily median held (day:held): Dice 63 `1:15 … 30:118 … 43:141`; Domino 20 `1:8 2:20 3:30 4:36 5:40 6:42 7:45 8:49 9:53 10:57 11:60 12:62 13:65 14:69 15:73 16:76 17:79 18:82 19:85 20:87 21:88 22:91 23:94 24:99 25:104 26:107 27:110 28:114 29:115 30:117 31:119 32:122 33:124 34:125 35:127 36:129 37:132 38:134 39:134 40:135 41:135 42:135 43:136 44:136 45:137 46:138 47:139 48:140 49:140 50:140`; full Dice / Disney series in the mockup file.
- **Fact:** with all Domino payers the picture is the same as with hard players: something new almost every day, longest wait 3 days, 4 stickers short at close.
