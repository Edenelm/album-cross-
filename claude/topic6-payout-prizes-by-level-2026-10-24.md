# Payout after close WITH album prizes, finishers and 1–2 short by spend level (2026-10-24)

Eden (2026-10-24):
- Album prizes must count. They are rolls or coins the player gets from the game.
- Show finishers by spend level, and players 1–2 short by spend level (1 and 2 short together, not split).
- Update t6j and the other ALBUM END slides.

SQL: `claude/topic6_payout_prizes_by_level_2026-10-24.sql` (Disney 127 GB, Domino 42 GB, Dice 209 GB).
Slides:
- **t6j** updated in place.
- **New: t6k** (finishers by level), **t6l** (1–2 short by level), **tg1** (total game revenue).
- **s6c and t6f:** messages updated.

Generator: `claude/slide_t6_prizes_2026-10-24.py`. Images: `claude/slides/t6k.png`, `t6j.png`, `t6l.png`, `tg1.png`, `s6c.png`, `t6f.png`.

## Definitions
- **Payout:** days 1–3 of the next album vs mid-album (close−18..−5). **Album prizes are included.** It is measured on the whole group: sum won ÷ sum spent on play, Mixpanel style, so heavy players weigh more.
  - Formulas are those of `topic6_payout_by_status_2026-10-24.sql`, with the album part kept in.
  - Dice: rolls in without RV / timer / gifts / invites / deep links / pending, minus bought rolls, ÷ rolls bet. The 1.2M cohort is left out.
  - Domino: coins won ÷ level start + boosters.
  - Disney: coins won ÷ level start + boosters.
- **Population:** paying players in the standard population. Status is taken on close−1: finished (144), and 1–2 short (142–143) as one group.
- **Spend level:** own pace = album $ a day before the last quarter.
- **Week after:** spend on close+1..+7 vs own pace.
- **Albums:** latest only (Dice 63, Domino 20, Disney 15).

## Results: payout change · week after (% of own pace)
### Finishers
| Level | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| ≤$2 | −14% · 201% | −18% · 279% | −22% · 334% |
| $2–5 | −10% · 123% | −19% · 167% | −20% · 172% |
| $5–20 | −5% · 105% | −16% · 134% | −14% · 119% |
| >$20 | −2% · 85% | −12% · 101% | −8% · 86% |
| All | −8% · 103% | −16% · 124% | −14% · 107% |

### 1–2 short
| Level | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| ≤$2 | −6% · 146% | −13% · 180% | −14% · 238% |
| $2–5 | −5% · 100% | −13% · 119% | −11% · 138% |
| $5–20 | −2% · 86% | −11% · 96% | −9% · 100% |
| >$20 | +2% · 68% | −9% · 71% | −5% · 76% |
| All | −3% · 87% | −12% · 104% | −9% · 98% |

Player counts and revenue shares are in the t6k / t6l notes. Largest cells by album revenue share:
- Dice finishers >$20: 12%.
- Domino finishers >$20: 15%.

## Reading
- **Fact:** with prizes included, finishers get less back after close in every game, at every spend level.
- **Fact:** Dice has the smallest drop at every spend level, for finishers and for 1–2 short. It also has the lowest week after at every level.
- **Fact:** inside each game, heavier payers have a smaller drop and also come back less. These are different players, so this is not cause and effect.
- **Fact (two albums):** Dice 61 finishers dropped more and came back better than Dice 63.
  - Dice 61: −18%, came back at 129%.
  - Dice 63: −12%, came back at 110%.
  - These figures use status at the end of the close day (`payout-mixpanel-def-2026-10-20.md`).
  - Total game revenue in the week after close: Dice 61 112% vs Dice 63 92% (`topic6-game-revenue-after-close-2026-10-24.md`).
- **Interpretation:** everything across games, and Dice 61 vs Dice 63, points the same way: a smaller payout cut after close goes with a slower return. Inside each game, the player-level split found no link (`topic6-short-payers-2026-10-24.md`). Stock, free inflow and the share who buy are the same across games.
- **Answer:** the payout story is a lead worth a test. It is not proof.

## Corrections to my answers to Eden earlier today (in chat)
1. **"With prizes Dice is not different" was wrong.**
   - The −12% / −18% I quoted came from a different cut: status at the end of the close day, all payers.
   - On the slide cut (status on close−1), Dice drops −8%, about half of Domino (−16%) and Disney (−14%).
   - The +5% is gone, but Dice still cuts the least.
2. **"Dice 61 vs 63 contradicts the payout story" was wrong.**
   - In Dice 61 the drop was bigger and the return was better.
   - That fits the story.

## Recommendation
- **TEST** a tighter Dice payout in days 1–3 of the new album for finishers and players 1–2 short. Control = today.
  - Main measure: spend vs own pace in days 1–7.
  - Guardrails: next-album spend over 14 days, finish rate, churn.
- Before starting, re-check with Dice 65 (after 2026-10-27).
- Do not adopt without the test.

## Correction (2026-10-24, later): 3-album check
Over the 3-album set (`topic6-payout-3albums-2026-10-24.md`), Dice does not cut the payout the least.
- All finishers: Dice −10%, Domino −11%, Disney −16%.
- Domino 19 cut only −6% and came back well.
- The "smaller cut → slower return" link came from Dice 63 alone.
- The TEST recommendation above is withdrawn. New status: **do not adopt; do not test now**.
