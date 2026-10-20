# End-of-album state by last-quarter tier — Disney / Domino / Dice (2026-10-15)

Question (Eden): do weak players end the album mostly at 3 missing (a pushable cluster) or already at 2 (nothing to push)? Compared to strong players.
Tier = projected $/day at the last-quarter start (5 groups: 0 / ≤2 / 2–5 / 5–20 / >20). State = missing stickers (of 144) on the last day before close. Share = share of the tier's album revenue (close day excluded). Populations: standing rules per game (not first album, login ratio ≥ 0.5 on last row, exclusions).
Queries: Dis7 (Disney 14/15, 51.9 GB), Dom7 (Domino 19/20, 37.9 GB; level curve from other album), DiceEnd (Dice 61/63, 4.8 GB; one pooled curve). All shown and approved in chat.

## Revenue share of the tier by end state (album A / album B)
| Game | Tier | Finished | 1 | 2 | 3 | 4+ | 3 ÷ 2 |
|---|---|---|---|---|---|---|---|
| Disney 14/15 | ≤2 | 4 / 5 | 3 / 2 | 6 / 4 | 12 / 10 | 75 / 80 | 2.3 / 2.8 |
| | 2–5 | 8 / 9 | 5 / 4 | 9 / 7 | 19 / 18 | 59 / 62 | 2.1 / 2.6 |
| | 5–20 | 15 / 17 | 9 / 8 | 13 / 11 | 24 / 26 | 40 / 39 | 1.8 / 2.3 |
| | >20 | 33 / 35 | 13 / 13 | 14 / 12 | 20 / 23 | 21 / 17 | 1.4 / 1.9 |
| Domino 19/20 | ≤2 | 5 / 10 | 3 / 5 | 5 / 13 | 7 / 30 | 80 / 43 | 1.4 / 2.3 |
| | 2–5 | 9 / 15 | 4 / 6 | 8 / 17 | 12 / 37 | 68 / 24 | 1.4 / 2.2 |
| | 5–20 | 19 / 30 | 7 / 8 | 14 / 18 | 14 / 28 | 45 / 17 | 1.0 / 1.6 |
| | >20 | 46 / 57 | 10 / 8 | 12 / 10 | 9 / 12 | 22 / 13 | 0.8 / 1.2 |
| Dice 61/63 | ≤2 | 14 / 18 | 5 / 6 | 11 / 12 | 22 / 37 | 49 / 27 | 2.0 / 3.0 |
| | 2–5 | 16 / 22 | 6 / 7 | 13 / 15 | 24 / 35 | 41 / 22 | 1.8 / 2.4 |
| | 5–20 | 20 / 25 | 8 / 9 | 15 / 17 | 25 / 32 | 32 / 16 | 1.7 / 1.8 |
| | >20 | 36 / 41 | 10 / 10 | 16 / 16 | 21 / 22 | 18 / 11 | 1.35 / 1.3 |

What is missing at 3 / at 2:
- Disney: 3 = 1 Royal + 2 Goldens (locked trio); 2 = 1 Royal + 1 Golden (14) / ~0.65 R + 1.3 G (15). Push 3 → 2 = one Golden.
- Domino 20: 3 = 2 Royals + 1 Golden; 2 = ~1.8 Royals + 0.2 Golden. Push 3 → 2 = mostly the Golden, then 2 Royals remain. Domino 19: 3 = 1.7 R + 1.2 G.
- Dice: 3 = ~10 of 12 Supers held (2 Supers + 1 other missing); 2 = ~10.6–10.8 Supers.

## Reading (Known)
- In every game, weak tiers end with more revenue at 3 than at 2 (ratio 1.4–3.0) — weak players DO get stuck one step before 2. Strong tiers have a smaller ratio (0.8–1.9) and many more finishers.
- Size of the weak-tier cluster at 3 differs by game/album:
  - Disney 14/15 and Domino 19: small (7–19%); most weak revenue ends far (4+ missing: 59–80%) → lever = 4+ → 3, not 3 → 2.
  - Domino 20 and Dice 63: large (30–37% of weak-tier revenue at 3) → a real pushable 3 → 2 cluster.
  - Dice 61: in between (22–24%).
- Finished share of weak tiers: Dice 14–22% vs Disney 4–9% vs Domino 5–15%.
- Album design dominates (Domino 19 vs 20, Dice 61 vs 63) — the same tier lands very differently by album.
- Not causal. Any push → A/B.

## Relative definition check (RelDis / RelDom / RelDice, 2026-10-15)
Why: the dollar cuts are the same in all games, but a dollar cut can mean a different relative position per game. Re-cut by percentile of spend so far at the last-quarter start, among players who paid so far, per album: P0–50 (weak) / P50–80 / P80–95 / P95+ (strong); group "0" = no spend yet. Same populations as above. Dry-run 20.24 / 8.79 / 4.24 GB. Approved and run.

Resulting $/day ranges (spend so far ÷ checkpoint day) — nearly identical across games:
| Game | Weak P0–50 | P50–80 | P80–95 | Strong P95+ |
|---|---|---|---|---|
| Disney | up to 0.81 | 0.81–3.4 | 3.4–11.9 | 11.9+ |
| Domino | up to 0.65–0.71 | 0.7–3.0 | 2.8–10.4 | 10.3+ |
| Dice | up to 0.81–0.85 | 0.8–3.5 | 3.3–11.6 | 11.3+ |
Group share of album revenue, all games: weak ~6%, P50–80 ~19%, P80–95 ~32%, strong ~43%, none ~0.5%.

Revenue share of the group by end state — AVERAGE of the two albums (%):
| Game | Group | Finished | 1 | 2 | 3 | 4+ |
|---|---|---|---|---|---|---|
| Disney | Weak | 3 | 2 | 3 | 8 | 83 |
| | Strong | 29 | 12 | 13 | 23 | 23 |
| Domino | Weak | 7 | 3 | 6 | 13 | 71 |
| | Strong | 43 | 9 | 13 | 14 | 20 |
| Dice | Weak | 14 | 5 | 11 | 29 | 41 |
| | Strong | 34 | 9 | 16 | 23 | 17 |
Albums differ a lot on weak 4+: Domino 83 (19) vs 59 (20); Dice 52 (61) vs 30 (63). Disney stable (80 / 85).

Reading (Known):
- Eden's conclusion holds under the relative definition: weak players' revenue is stuck far (4+ missing) in Disney (83%) and Domino (71%) vs Dice (41%).
- The relative cuts land on almost the same dollars in all three games, so the earlier dollar comparison was not distorted by different price levels (Disney currency still Needs Validation, but the shape matches).
- Relative weak (≤ ~$0.8/day) is a narrower, weaker group than dollar weak (≤ $2/day); strong (≥ ~$11/day) is broader than > $20.
- Not causal. Supply vs demand stall check (when weak players stall, were they still active/paying) is the proposed next step.

