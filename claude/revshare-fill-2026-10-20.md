# Revenue share for every population in the deck (2026-10-20)

Eden (2026-10-20): every population on a slide shows its share of album revenue, so the room can see whether the group is worth the investment or is noise.
SQL: `claude/revshare_fill_queries_2026-10-20.sql` (Dice 23.7 GB, Domino 35.4 GB, Disney 73.6 GB) and the Domino groups query in `claude/finisher_recount_queries.sql` (19.4 GB).
Population: standard (not first album, not excluded, login ratio ≥ 0.5 on the last row before close, row on close−1). Payer = album-table spend > 0, start..close−1 (the rule used when these slides were built; the close-day payer rule adds 0.2–0.4% of payers). Share = the group's album revenue (album-table spend, start..close−1) ÷ revenue of the whole standard population. Group sizes reproduce the deck exactly.
Deck: version 69 (half-completions, same-spend, routes, domino-easier, tests, domino-3albums, open-checks; album-effect note).

## Share of album revenue (album A / album B)
| Group | Dice 61 / 63 | Domino 17 / 19 | Disney 14 / 15 |
|---|---|---|---|
| Payers 2–3 missing 8 days before close | 7.2% / 4.7% (2,204 / 1,950) | 9.1% / 12.0% (2,196 / 1,533) | 22.3% / 32.7% (16,033 / 23,367) |
| Payers 4–6 missing | 39.3% / 58.4% (29,610 / 61,917) | 30.5% / 39.4% (14,535 / 22,685) | 41.0% / 29.6% (88,868 / 50,610) |
| Payers 7–10 missing | 17.1% / 17.6% (28,218 / 40,740) | 34.6% / 22.4% (37,637 / 27,344) | 24.6% / 13.7% (129,677 / 52,243) |
| Payers 2–6 missing (Disney test 1) | 46.5% / 63.2% | 39.6% / 51.4% | **63.3% / 62.3%** (104,901 / 73,977) |
| 4–6 missing, $5–15 per active day in days 14–8 (same-spend) | 11.4% / 15.6% (8,019 / 12,356) | 8.9% / 12.6% (4,792 / 5,932) | 13.9% / 10.5% (18,220 / 13,234) |
| 4–6 missing, bought a Wild / Joker in the last week | 16.6% / 29.7% | 9.1% / 6.0% | 3.9% / 4.1% |
| 4–6 missing, gameplay Wild / Joker only | 3.1% / 2.9% | 6.3% / 18.8% | 5.9% / 4.9% |
| 4–6 missing, no Wild / Joker | 19.6% / 25.8% | 15.1% / 14.5% | 31.2% / 20.7% |
| Payer finishers (144 by end of close day) | 26.2% / 31.3% | **32.1%** / 26.2% | 20.7% / 22.1% |

Domino 19 / 20 spend groups ($ per active day in the previous album; all eligible players; daily-metrics revenue): $0 5.9% / 5.5%, up to $2 20.3% / 20.8%, $2–5 17.8% / 18.7%, $5–20 33.2% / 33.0%, $20+ 22.7% / 22.0%.

## Reading
- Fact: Disney's test-1 group (payers 2–6 short 8 days before close) is 23–28% of payers but 62–63% of album revenue. The test that targets it touches most of Disney's album money.
- Fact: in Disney, payers 2–3 short a week out already hold 22–33% of album revenue, and finish 24–26% of the time (Dice 42%, Domino 51%).
- Fact: in Disney, 4–6-short payers with no Wild / Joker in the last week hold 21–31% of album revenue; in Dice 20–26%.
- Fact: in Dice the 4–6-short group alone is 39% / 58% of album revenue; most of the Dice money sits 4–6 short a week out.
- Not measured: album-effect cells (needs the segmentation queries).
