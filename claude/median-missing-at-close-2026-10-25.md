# Median paying player: stickers missing at close, by type (2026-10-25)

Question (Eden): slide "What the P50 Paying Player Still Misses at Close" showed averages; try the real median.
Population and rules: same as `disney-stalls-missing-2026-10-23.md` (B): standard population payers (paid on any album day incl. close; not first album; login ratio >= 0.5; row on close−1; exclusions), stickers held by the end of the close day (sticker tables). SQL: `median_missing_at_close_2026-10-25.sql` (Dice 84 GB, Domino 9 GB, Disney 29 GB).
"Median payer" = payers whose total missing equals the median total; the type split = their average per type (rounded).

| Album | Payers | Average missing | **Median missing** | Median payer's split: common / Golden / rare | Payers exactly at the median |
|---|---|---|---|---|---|
| Dice 63 (`dice-dreams-dbt`) | 204,893 | 5.7 | **3** | 0 / 1 (0.99) / 2 Supers (1.99) | 26,888 (13%) |
| Domino 20 (`domino-dreams-dbt`) | 106,762 | 7.0 | **4** | 0 / 1 (1.41) / 3 Royals (2.54) | 3,540 (3%) |
| Disney 15 (`solitaire-dreams-411507`) | 325,842 | 10.1 | **6** | 0 / 4 (3.61) / 2 Royals (2.37) | 11,686 (4%) |

Per-type medians (each type alone): Dice 0 / 1 / 2; Domino 0 / 1 / 2; Disney 0 / 4 / 2.

- Fact: the median payer misses about half of the average (3 / 4 / 6 vs 5.7 / 7.0 / 10.1): a minority of payers ends far away and pulls the average up.
- Fact: the order holds — Disney's median payer ends furthest (6), mostly Goldens (4 of 24); Dice's mostly Supers.
- Fact: the median payer is missing no commons in any game; commons on the average slide come from the far tail.
