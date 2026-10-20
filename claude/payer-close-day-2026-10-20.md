# Payer includes the close day (2026-10-20, Eden: "לספור אותם כמשלמים")

Decision: a player who paid on any album day, close day included, is a payer. Close-day spend is NOT added to album revenue (half day; revenue stays start..close−1). Trigger: in Dice 63, 26% of "non-paying" finishers bought a Wild on the close day.
SQL: claude/payer_close_day_queries.sql (Dice 22.1 GB, Domino 16.4 GB, Disney 39.3 GB, Domino 20 puzzle 17.1 GB). Standard population; finisher = 144 by end of close day.

| Album | Payers before → with close day | Close-day-only payers ($ on close day) | Payer finishers | Payer finish rate | Non-paying share of finishers |
|---|---|---|---|---|---|
| Dice 59 | 195,194 → 195,628 (+0.22%) | 434 ($2.6K) | 21,876 → 21,992 | 11.21 → 11.24% | 6.3 → 5.8% |
| Dice 61 | 175,216 → 175,794 (+0.33%) | 578 ($3.5K) | 17,347 → 17,466 | 9.90 → 9.94% | 6.0 → 5.4% |
| Dice 63 | 182,280 → 182,700 (+0.23%) | 420 ($3.0K) | 22,690 → 22,818 | 12.45 → 12.49% | 1.9 → 1.3% |
| Domino 17 | 135,609 → 135,879 (+0.20%) | 270 ($1.7K) | 9,328 → 9,367 | 6.88 → 6.89% | 17.0 → 16.6% |
| Domino 19 | 118,955 → 119,201 (+0.21%) | 246 ($1.1K) | 6,980 → 7,039 | 5.87 → 5.91% | 30.1 → 29.6% |
| Domino 20 | 106,520 → 106,762 (+0.23%) | 242 ($1.4K) | 10,078 → 10,148 | 9.46 → 9.51% | 42.9 → 42.6% |
| Disney 12 | 381,637 → 383,095 (+0.38%) | 1,458 ($10.9K) | 29,327 → 29,786 | 7.68 → 7.78% | 16.1 → 14.8% |
| Disney 14 | 370,293 → 371,049 (+0.20%) | 756 ($4.8K) | 19,258 → 19,376 | 5.20 → 5.22% | 8.7 → 8.2% |
| Disney 15 | 325,155 → 325,842 (+0.21%) | 687 ($4.7K) | 16,780 → 16,855 | 5.16 → 5.17% | 5.3 → 4.9% |

- Deck averages unchanged: payer finish rate 11.2% / 7.7% / 5.2%; finishers' revenue share unchanged (close-day-only payers have $0 album revenue).
- Domino 20 two-Puzzle closers: 1,490 → 1,508 paid, 2,501 → 2,483 did not pay (3,991 total; strong 520 unchanged).
- Deck version 67: read (definition), nonpayer-share (bars Dice 6 / 5 / 1%, Disney 15 / 8 / 5%, Domino unchanged; 7,587 → 7,517), disney-finishers (20.1K / 8.2K / 18.1K), puzzle-joker, jokers, domino-3albums notes, last3days notes.
- Not changed: payer counts written in other slide notes and older docs (counted to close−1); differences ≤0.4% and no shown rate or share moves. The read slide says so.
