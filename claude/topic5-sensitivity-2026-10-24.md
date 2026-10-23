# Topic 5: is "≤3 missing at close−4" the right cut? Sensitivity check (2026-10-24)

Eden: before building the "why adopt this measure" story, check whether 3 stickers / 4 days is the best cut or whether another one is better.
Context (Eden): every game locks the last 3 stickers until about 4 days before close; Dice sets daily revenue-share targets per group over the last 14 days and wants every group at 3 missing by close−4 (weaker groups get a lower target than stronger ones).
SQL: `claude/topic5_sensitivity_2026-10-24.sql` (Disney 24 GB `solitaire-dreams-411507.bi_prod.user_daily_album`, Domino 10 GB `domino-dreams-dbt.prod_40_mart.user_daily_album`, Dice 105 GB `dice-dreams-dbt.50_reporting.user_daily_album`).

## Definitions
- Population: standard-population payers, as `topic5-end-lift-2026-10-24.md`. Check: Domino 19 / 20 at ≤3, close−4 = 5% / 23% of payers, 31% / 55% of revenue, the same as that doc.
- Grid: measure day close−2 … close−7 × threshold ≤0 / 1 / 2 / 3 / 5 / 8 missing (status = last row on or before that day).
- End window = from the measure day to close−1 (close day left out).
- **How well a cut points to the end money (my choice of score):** the close group's share of revenue in the end window compared with its share of revenue before. A good cut picks a group that is big *and* spends more at the end, so its share jumps. A tiny group (≤0–1) can lift a lot but barely moves the total; a huge group (≤8) is almost everyone, so its share can't jump.

## Result 1: the threshold, measured at close−4
Close group's share of revenue: before → end window.

| Album | ≤1 missing | ≤2 | **≤3** | ≤5 | ≤8 |
|---|---|---|---|---|---|
| Dice 61 | 9% → 14% | 20% → 29% | **39% → 49%** | 74% → 77% | 88% → 90% |
| Dice 63 | 11% → 18% | 28% → 39% | **54% → 64%** | 83% → 88% | 92% → 95% |
| Domino 19 | 9% → 13% | 20% → 26% | **31% → 40%** | 64% → 74% | 80% → 89% |
| Domino 20 | 15% → 23% | 29% → 41% | **55% → 68%** | 79% → 87% | 90% → 95% |
| Disney 14 | 3% → 5% | 13% → 21% | **44% → 54%** | 71% → 78% | 89% → 92% |
| Disney 15 | 2% → 5% | 10% → 17% | **43% → 51%** | 68% → 74% | 83% → 88% |

- **Fact:** ≤3 gives the biggest jump in 4 of 6 albums. In Dice 63 ≤2 is slightly bigger (28% → 39% vs 54% → 64%); in Domino 19, where only 5% of payers were at ≤3, ≤5 is bigger (64% → 74%).
- **Fact:** below 3 the group is small at close−4: ≤2 missing = 2–9% of payers, ≤1 = 0–3%. This fits the lock: before it opens, 3 missing is as far as a player can get.

## Result 2: the day, at ≤3 missing
Close group's share of revenue: before → end window. Share of payers at ≤3 in brackets.

| Album | close−7 | close−6 | close−5 | **close−4** | close−3 | close−2 |
|---|---|---|---|---|---|---|
| Dice 61 | 13% → 15% (3%) | 19% → 22% (4%) | 24% → 29% (6%) | **39% → 49% (16%)** | 49% → 61% (23%) | 60% → 74% (34%) |
| Dice 63 | 11% → 15% (3%) | 19% → 26% (6%) | 39% → 48% (18%) | **54% → 64% (30%)** | 70% → 80% (50%) | 78% → 88% (60%) |
| Domino 19 | 19% → 24% (2%) | 23% → 29% (3%) | 27% → 34% (4%) | **31% → 40% (5%)** | 37% → 51% (8%) | 44% → 64% (12%) |
| Domino 20 | 5% → 7% (1%) | 12% → 17% (2%) | 30% → 39% (9%) | **55% → 68% (23%)** | 69% → 82% (34%) | 75% → 88% (41%) |
| Disney 14 | 28% → 33% (8%) | 33% → 39% (10%) | 39% → 47% (13%) | **44% → 54% (16%)** | 48% → 59% (18%) | 52% → 67% (20%) |
| Disney 15 | 35% → 37% (8%) | 37% → 39% (9%) | 40% → 44% (10%) | **43% → 51% (12%)** | 47% → 57% (14%) | 52% → 65% (16%) |

- **Fact:** a later day always points to the end money a bit better (less time left), but it leaves less time to act.
- **Fact:** in the albums with the strong end (Dice 63, Domino 20), close−4 already gives the full jump of close−3 / close−2 (Dice 63: 54% → 64% at close−4, 70% → 80% at close−3; Domino 20: 55% → 68% and 69% → 82%). Earlier (close−5 and before) the jump shrinks.
- **Fact:** in Dice 63 and Domino 20 the share of payers at ≤3 jumps between close−6 and close−4 (Dice 63: 6% → 30%; Domino 20: 2% → 23%). That is the lock opening, and the players are ready. In Disney it hardly moves (Disney 15: 9% → 12%); in Domino 19 too (3% → 5%).

## Reading
- **Interpretation:** 3 stickers at close−4 is not an arbitrary cut. It matches how the games are built (the last 3 are locked), it is the cut that best points to the end money in 4 of 6 albums and close to best in a fifth, and it is the latest day that still leaves 4 days to act without losing signal in the strong albums.
- **Interpretation:** the measure also shows *why* an end is weak. In Disney 14/15 and Domino 19 the payers do not reach 3 missing when the lock opens, so the end has no one to lift.
- **Limits:** 6 albums; the score is my choice (shown above); the measure is a correlation with end revenue, not proof that moving players to ≤3 adds revenue. A player who pays at the end also collects stickers, so part of the link runs both ways. Proof needs a controlled test.
