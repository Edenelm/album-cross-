# Topic 4: gates rerun — Domino 19/20 and Dice on the fixed population (2026-10-22)

**Question (Eden):** rerun the v82 'gates' slide measures on Domino 19/20 (was 17/19) and Dice 61/63 on the fixed first-album rule.
SQL: `claude/topic4_gates_2026-10-22.sql` (Domino 19.2 GB, Dice 88.6 GB; gate-identification queries 9.5 GB each, in this doc).

**Definitions**
- Population: standard (not first album — Dice: no row in an earlier album; not excluded; login ratio ≥ 0.5 on the last row before close; row on close−1). Payer = album-table spend > 0 on any album day, close day included.
- Gate stickers (3 per album, locked to the end): Dice 61 S143 / S120 / G142, Dice 63 S132 / S143 / G129, Domino 19 R107 / R108 / G101 (from the old slide). **Domino 20 R119 / R120 / G139 — new, identified from data:** the two scarcest Royals (32K holders each vs 126K+ for every other Royal; first reached 200 holders 4–8 days before close) and the last Golden released; Domino 19's known gate shows the same pattern (R107 / R108 at 25–27K holders, G101 released last). Top gate sticker = first listed.
- (a) share of payers holding the top gate sticker by the end of close−2; (b) near-finishers = 1–3 missing at the end of the close day; share of them missing at least one gate sticker.
- Revenue share = album-table spend start..close−1 ÷ total game purchase revenue during the album.

**Checks:** payers and finishers match the earlier topic-4 runs (Dice 194,603 / 204,893 payers, 19,426 / 25,230 finishers; Domino 119,201 / 106,762). Domino 19 reproduces the old 5.6%; Dice 7.5% / 11.1% vs old 7.5% / 11.3%.

| | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 (not rerun, old slide) |
|---|---|---|---|
| Payers | 194,603 / 204,893 | 119,201 / 106,762 | — |
| (a) hold the top gate sticker by close−2 | **7.5% / 11.1%** | **5.6% / 9.3%** | 2% / 5.5% |
| their share of game revenue | 20% / 22% | 18% / 24% | not measured |
| Near-finishers (1–3 missing at the end) | 72,325 / 112,224 | 15,518 / 40,251 | — |
| their share of game revenue | 35% / 42% | 21% / 35% | — |
| (b) near-finishers missing ≥1 gate sticker | **97% / 98%** | **95% / 100%** | 97% / 86% (old definition) |

## What it means
- **Fact:** the picture holds on the new populations: 6–11% of payers hold the top gate sticker two days before close, and almost every payer who ends 1–3 short is missing a gate sticker (95–100%).
- **Fact:** the payers who do hold the top gate sticker early are heavy payers: 6–11% of payers with 18–24% of game revenue.
- **Change vs the old slide:** Domino now 19/20 (9.3% in album 20, the easier end); Dice near-finisher measure is now the same as Domino's (97–98%) instead of "92–95% of payers one sticker from a set missing a Super".
- **Caveat:** Disney not rerun (its albums did not change); its near-finisher number used the old end status (close−1), so it is not strictly the same definition. Descriptive.
