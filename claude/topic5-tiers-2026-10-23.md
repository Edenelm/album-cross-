# Topic 5: payers left behind, split by spend tier (2026-10-23)

Eden: split by the 5 tiers (decision 2026-10-15), goal metric = revenue share of players at <=3 missing at close-4; targets as direction only.
SQL: `claude/topic5_tiers_2026-10-23.sql` (Disney 24 GB, Domino 10 GB, Dice 104 GB).

## Definitions
- Population: standard-population payers (same as `topic5-left-behind-2026-10-23.md`).
- Tier = album spend per day so far at the start of the last quarter (days 0 .. ceil(0.75 x album days) - 1); cuts $0 / <=2 / 2-5 / 5-20 / >20. My proxy for the "projected tier" (spend pace is near-linear, segmentation-recommendations-2026-10-15).
- Reach = <=3 missing at close-4 (% of players; and % of the tier's revenue up to close-4 = the goal metric).
- End = status on close-1: finished / 1-3 missing / 4+ missing. Far $ = album revenue of the tier's 4+ players, as % of all payers' album revenue.

## Results — latest album (Dice 63 · Domino 20 · Disney 15); earlier album in brackets
| Tier ($/day) | Game | % of payers | % of revenue | Reach <=3 at close-4 (players / revenue) | Finished | 4+ at close | Far 4+: % of revenue |
|---|---|---|---|---|---|---|---|
| <=2 | Dice | 65% | 15% | 24% / 35% (11 / 19) | 7% | 39% (63) | 4% (7) |
| <=2 | Domino | 68% | 17% | 15% / 30% (1 / 3) | 4% | 64% (90) | 7% (14) |
| <=2 | Disney | 65% | 15% | 5% / 10% (10 / 16) | 2% | 91% (86) | 12% (12) |
| 2-5 | Dice | 16% | 18% | 38% / 43% (23 / 28) | 16% | 26% (46) | 4% (7) |
| 2-5 | Domino | 14% | 19% | 43% / 46% (6 / 8) | 11% | 29% (74) | 5% (12) |
| 2-5 | Disney | 15% | 18% | 18% / 23% (23 / 28) | 6% | 70% (66) | 11% (11) |
| 5-20 | Dice | 11% | 36% | 49% / 54% (33 / 37) | 20% | 21% (37) | 6% (11) |
| 5-20 | Domino | 10% | 37% | 53% / 58% (24 / 31) | 23% | 21% (53) | 6% (16) |
| 5-20 | Disney | 11% | 38% | 39% / 45% (39 / 45) | 13% | 46% (47) | 15% (15) |
| >20 | Dice | 2% | 31% | 62% / 68% (49 / 58) | 32% | 15% (24) | 4% (6) |
| >20 | Domino | 2% | 26% | 67% / 72% (55 / 63) | 49% | 16% (29) | 3% (6) |
| >20 | Disney | 2% | 29% | 64% / 71% (63 / 69) | 27% | 24% (25) | 5% (6) |
Tier $0 (no spend before the last quarter): 6% of payers, under 1% of revenue in all games (no goal, per the 2026-10-15 decision).

## Reading
- **Fact:** the same shape everywhere: about 2 in 3 payers are at <=$2 a day (15-17% of revenue); the 13% at $5+ hold 63-67% of revenue.
- **Fact:** at >$20 a day all three games bring about 2 in 3 players close by close-4 (62-67%).
- **Fact:** below that Disney falls away: at $2-5 a day 18% reach in Disney vs 38-43% in Dice / Domino 20; at <=$2, 5% vs 15-24%.
- **Fact:** far payers in the $2-20 tiers = 26% of album revenue in Disney 15 (11% + 15%) vs 10% in Dice 63 and 11% in Domino 20 (Domino 19: 28%, like Disney).
- **Interpretation:** the end reaches the strongest payers in every game; Dice (and Domino in album 20) also brings the middle tiers close, Disney does not. The money left behind in Disney is in the middle, not at the bottom.
- **Direction (not a target):** a goal per tier — top tier: keep; $5-20 and $2-5: raise reach toward Dice's level; <=$2: a smaller goal (e.g. sets, not 144); $0: no goal. Numbers are a management decision (topic 8).
