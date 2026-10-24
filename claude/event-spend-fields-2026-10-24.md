# What the post-album event spend fields count (2026-10-24)

Question (Eden): do `deluxe_album_spent_today` (Domino) and `magic_spent_today` (Disney) count purchases made in the event, or all purchases?
Docs: no description on these columns in BigQuery; the Confluence Deluxe pages ("Album (Deluxe) Recompletion", "[Album] - Album RC Event (Deluxe)") describe the feature as free for album completers ("extending progression and monetization opportunities") and say nothing about the field. Deluxe has no entry price.
SQL: `claude/event_spend_fields_2026-10-24.sql`. Compared with the full in-game spend that day (`album_spent_today` in the album table, one value per user-day).

## Domino (`domino-dreams-dbt`, Deluxe, album 20)
| Day | Days with Deluxe spend | Equal to full spend | Below | Deluxe spend | Full spend |
|---|---|---|---|---|---|
| Deluxe start day | 2,364 | 349 | 2,015 | $72,668 | $157,984 |
| Other days | 5,838 | 5,838 | 0 | $273,414 | $273,414 |
| Close day or later | 1,874 | 1,571 | 303 | $53,416 | $62,847 |
Inside the Deluxe table, Deluxe spend = the table's album spend on every row (albums 19 and 20), and `deluxe_purchase_flag` is true on every spend day.

## Disney (`solitaire-dreams-411507`, Legendary 43560 / 50303)
| Event / day | Days with event spend | Equal | Below | Above | Event spend | Full spend |
|---|---|---|---|---|---|---|
| 43560 start day | 3,673 | 347 | 3,318 | 8 | $118,406 | $266,536 |
| 43560 other days | 5,354 | 4,764 | 504 | 86 | $242,598 | $258,437 |
| 50303 start day | 4,343 | 403 | 3,892 | 48 | $145,189 | $321,758 |
| 50303 other days | 6,830 | 5,545 | 375 | 910 | $312,253 | $297,204 |

## Reading
- **Fact:** the event spend field = all the player's in-game purchases while they are in the event, not purchases of event items. On the start day it holds only part of the day (most likely the purchases after the event started). Domino matches exactly on all other days; Disney matches on 81–89% of other days, totals within ±6%.
- **Consequence for `post-album-events-2026-10-19.md`:**
  - "Event share of d1–7 revenue" (Domino 23–31%, Disney 11–15%) = share of revenue spent while in the event, NOT revenue the event made.
  - "Excl. event" columns removed all purchases on event days → they understate the players' spend; do not use.
  - "~15% of Deluxe spend looks added" divides by all spend during Deluxe → not a valid size.
  - Still valid: the Deluxe before/after DiD itself (+4.2 pts buyers in days 1–7, +0.06 spend vs habit, early vs late finishers) — it does not use the field. Disney T113 (test) is unaffected.
- Open: whether the events have offers of their own and how much they sell can only come from purchase events with an offer/placement field, or from the teams.
