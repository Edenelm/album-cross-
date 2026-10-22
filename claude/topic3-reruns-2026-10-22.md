# Topic 3 reruns (2026-10-22, Eden approved)

SQL: `claude/topic3_reruns_2026-10-22.sql`. Message approved (Eden 2026-10-22): **"the difference is the long wait, not the pace"**.

## A. Dice rare timeline on the fixed population (`dice-dreams-dbt`, 98 GB)
Only change vs `rare_timeline_queries.sql`: not first album = a row in an earlier album (fixed rule). Payers 194,603 (61) / 204,893 (63), = the fixed standard population.

| | Old (2026-10-20) | New |
|---|---|---|
| Median gap between new Supers | 4 days | 4 days |
| Gaps of 4 days or less | 54% / 53% | 55% / 53% |
| Median day of the 1st Super | 4 / 3 | 4 / 3 |
| Supers held by the median payer at close | 9 / 10 of 12 | 9 / 10 of 12 |
| Longest stretch without a new Super (median payer) | 6 days (63, days 5–10) | 6 days (63, days 5–10, also 11–16 and 17–22); 61: 5 days (days 7–11) |

- Fact: nothing changes. The added returning payers collect Supers at the same pace.

## B. Domino rare sources by quarter on albums 19/20 (`domino-dreams-dbt`, 27 GB)
Same query as topic5 5d v4 (PU, not first album, First Royal gift line), albums 19/20 instead of 17/19. Share of new Royals per quarter, album 19 / 20:

| Source | Q1 | Q2 | Q3 | Q4 |
|---|---|---|---|---|
| One-off events ("Other events") | 42 / 46% | 59 / 52% | 48 / 47% | 46 / 47% |
| Trail event | 9 / 3% | 13 / 24% | 10 / 20% | 12 / 7% |
| Momentum | 9 / 6% | 14 / 8% | 24 / 19% | 7 / 3% |
| Daily | 19 / 22% | 11 / 8% | 7 / 3% | 3 / 2% |
| First Royal gift | 19 / 23% | 0 / 0% | 0 / 0% | 0 / 0% |
| Duplicate exchange | 0 / 0% | 0 / 0% | 11 / 8% | 23 / 37% |
| Paid offer | 2 / 0% | 1 / 0% | 0 / 2% | 10 / 4% |
| Unknown | 0 / 0% | 0 / 8% | 0 / 1% | 0 / 0% |

- Fact: the topic-5 picture holds on 19/20: about half of new Royals in every quarter come from rotating one-off events; the last quarter adds the duplicate exchange (23% / 37%). No Market source in 19/20 (Market was album 17).
- Fact: the First Royal gift reaches returning payers in both albums (about a fifth of Q1 Royals), not only first-album players.
- Check: album 20 Q4 dup exchange 37% and Trail 7% match `domino-album20-royal-sources-2026-10-17.md`.
