# Revenue share by number of albums seen — October 2026 (Oct 1–24), 2026-10-25

Question (Eden): the same slide as "Revenue Share of September 2026, by Number Of Albums the Player Has Been" (deck slide 11), for October.

Population and definitions: unchanged from `albums-all-players-2026-10-21.md` (Sept). Players active ≥1 day in the window with ≥1 album started by the window end; excluded users removed (Dice `is_excluded`; Domino `special_user_flag` + `suspected_cheater_flag`; Disney `exclude_reason` + `special_user_flag`). Revenue = all in-game purchases in the window (Dice `revenues_sum`; Domino in-app + Stripe; Disney `gross_revenues`). Albums seen: Dice/Domino = distinct albums in the album-table history (Dice from 2023-11, Domino from 2024-06, so 13+ is a floor); Disney = lifetime counter `user_album_count`.
Window: Oct 1–24 2026 (last full day; October is not over). SQL: `albums-seen-october-2026-10-25.sql`.

| Albums seen | Dice: % players / % revenue | Domino | Disney |
|---|---|---|---|
| 1 | 15% / 3% | 18% / 4% | 15% / 14% |
| 2–3 | 25% / 26% | 24% / 23% | 20% / 22% |
| 4–6 | 10% / 14% | 16% / 18% | 23% / 20% |
| 7–12 | 11% / 13% | 21% / 27% | 32% / 33% |
| 13+ | 39% / 44% | 21% / 28% | 11% / 11% |
| *Disney 7+ (Sept slide grouping)* | | | 42% / 44% |
| Total | 1,000,611 players · $17,302,457 | 781,843 · $8,841,466 | 2,128,473 · $25,734,622 |

Raw counts:
- Dice (`dice-dreams-dbt`): 1 = 145,407 / $519,928; 2–3 = 245,250 / $4,526,041; 4–6 = 104,061 / $2,376,223; 7–12 = 113,949 / $2,276,441; 13+ = 391,944 / $7,603,824 (max 22 albums).
- Domino (`domino-dreams-dbt`): 1 = 143,238 / $312,764; 2–3 = 187,618 / $2,020,434; 4–6 = 127,521 / $1,567,606; 7–12 = 163,043 / $2,425,163; 13+ = 160,423 / $2,515,499 (max 16).
- Disney (`solitaire-dreams-411507`): 1 = 319,860 / $3,496,964; 2–3 = 416,682 / $5,601,667; 4–6 = 489,716 / $5,202,729; 7–12 = 672,438 / $8,558,355; 13+ = 229,777 / $2,874,907 (max 14).

vs September (slide 11, revenue share): Dice 4/24/15/12/45 → 3/26/14/13/44; Domino 12/18/21/27/23 → 4/23/18/27/28; Disney 12/19/32/37(7+) → 14/22/20/44(7+).

Notes:
- Fact: Domino "1 album" falls from 12% to 4% of revenue. Interpretation (not checked): which album players count as their first depends on where the month falls in the album cycle; a new album that opened recently has few first-timers yet. Same logic can move the 2–3 group.
- Disney now reaches 13+ albums (max 14), so the 7+ bar can be split into 7–12 and 13+ for all three games; Sept slide kept 7+.
- October is partial (24 days); shares, not totals, are compared.
