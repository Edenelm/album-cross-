# Open checks from the story review (2026-10-24)

SQL: `claude/open_checks_2026-10-24.sql`. A1 Domino 82 GB, A2 Disney 78 GB, B Disney 67 GB, C Dice 94 GB.

## A. First-album flag in Domino and Disney (topic 0 follow-up)
Standard-population payers. Two ways to mark a player as past the first album are compared: the field `user_album_count > 1`, and "has a row in an earlier album" in the daily album table.

| Album | Both say returning | Both say first album | Disagree |
|---|---|---|---|
| Domino 19 | 119,201 (91%, 93% of revenue) | 11,575 (9%) | 0 |
| Domino 20 | 106,761 (93%, 94%) | 8,102 (7%) | 1 payer |
| Disney 14 | 371,049 (90%, 91%) | 40,464 (10%) | 0 |
| Disney 15 | 325,842 (94%, 94%) | 21,200 (6%) | 0 |

- **Fact:** in Domino and Disney the field agrees with the album history, so the Dice problem (hidden returning payers) does not exist there. No rerun needed.

## B. Disney ARPDAU albums 10–15 with the tenure mix held fixed (topic 1 follow-up)
All players who got the album, active days, close day excluded, exclusions removed. Groups = albums seen (1 / 2–3 / 4–6 / 7+).
Mix-fixed = each album's ARPDAU per group, weighted by album 10's share of active days.

| Album | ARPDAU | vs album 10 | Mix-fixed ARPDAU | vs album 10 | Share of active days 1 / 2–3 / 4–6 / 7+ |
|---|---|---|---|---|---|
| 10 | $1.11 | – | $1.11 | – | 29 / 36 / 16 / 19% |
| 11 | $1.12 | +1% | $1.16 | +5% | 14 / 52 / 13 / 21% |
| 12 | $0.97 | −13% | $1.04 | −7% | 15 / 40 / 22 / 24% |
| 13 (21-day mini) | $1.01 | −9% | $1.15 | +3% | 6 / 33 / 33 / 28% |
| 14 | $0.91 | −19% | $1.03 | −8% | 9 / 24 / 36 / 31% |
| 15 | $0.91 | −19% | $1.11 | −1% | 6 / 17 / 34 / 44% |

ARPDAU by group stayed about the same: first album $1.24–1.50, 2–3 $1.02–1.19, 4–6 $0.87–1.01, 7+ $0.72–0.81.
- **Fact:** most of Disney's −19% ARPDAU from album 10 to 15 is the player mix. First-album players fell from 29% to 6% of active days, and players on their 7th+ album rose from 19% to 44%. Each group's own ARPDAU barely moved. With album 10's mix, album 15 is −1% and album 14 is −8%.
- **Meaning:** the "Disney level is falling" line in the story is mostly fewer new players plus long-tenure players who spend less per day. It is not the album getting weaker. The same-player cohort result (−34% from album 1 to 7) fits this picture: each player spends less as they age, and there are fewer new players to replace them.

## C. Dice 63 vs 65: daily album spend per payer by days to close (Dice 65 follow-up)
Standard-population payers by spend level (topic-5 tiers). Average $ per payer per day:

| Level | Album | Days 21–12 before close | Days 11–5 | Last 4 days (Thu–Sun) | Last 4 vs days 11–5 |
|---|---|---|---|---|---|
| $2–5 | 63 | $3.36 | $3.29 | $3.87 | +18% |
| $2–5 | 65 | $3.52 | $3.43 | $3.28 | −4% |
| $5–20 | 63 | $9.53 | $8.78 | $9.55 | +9% |
| $5–20 | 65 | $9.91 | $9.32 | $8.25 | −11% |
| >$20 | 63 | $41.48 | $33.83 | $35.46 | +5% |
| >$20 | 65 | $42.15 | $38.07 | $31.54 | −17% |

- **Fact:** in 63 spend rose again on the final weekend (Fri–Sun) at every level ($5–20: $9.81 / $10.56 / $9.56, above days 11–5; the highest days were 17–15 days before close). In 65 the final weekend was among the lowest days ($8.45 / $7.94 / $8.11). The weekend before it was higher (Sat–Sun 9–8 days before close: $10.13 / $10.51).
- **Fact:** the drop also hits $2–5 payers, and most of them had not finished (only 4% had 144 at close−4). So early finishing by strong payers explains only part of it.
- **Reading (hypothesis):** Dice 65's final weekend had no pull. Spend was as high or higher earlier in the album, but the last weekend did not lift. That points to the end's design or calendar (which events, offers or rewards ran in the last weekend), not to payers being far. Question for the Dice team: what ran in the final weekend of 65 vs 63.
