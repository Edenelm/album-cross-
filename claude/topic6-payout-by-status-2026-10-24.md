# Payout after close by close status, next to the week-after return (2026-10-24)

Eden (2026-10-24): run the Part 1 slide 36 check (median player payout in days 1–3 of the next album vs mid-album) by album close status, because slide 36 showed something in Domino and Disney.
SQL: `claude/topic6_payout_by_status_2026-10-24.sql` (Disney 127 GB, Domino 42 GB, Dice 209 GB). Slide: **t6h_slide** (ALBUM END; it landed after s6d and before t6g, after Eden's reordering). Generator `claude/slide_t6_finisher_prize_2026-10-24.py` (`h`); image `claude/slides/t6h.png`.

## Definitions
- Payout per player = slide 36 definition (`payout_mixpanel_def_queries.sql`, per-player section): own payout days +1..+3 after close ÷ own payout close−18..−5, album prizes left out. Median across players who played in both windows. Dice: the 1.2M-balance cohort is left out of the payout.
- Status on the day before close, as in topic 6 (s6c/s6d): finished / 1–2 / 3 / 4+ short. Slide 36 used status at the end of the close day and only finished / 1 / 2 short.
- Week after = spend close+1..close+7 vs own album pace (as topic 6). Latest album: Dice 63, Domino 20, Disney 15. All paying players; $2–20 a day also checked.
- Check: finishers reproduce slide 36: Dice 1.05 (1.04), Domino 0.82 (0.81), Disney 0.89 (0.87).

## Results (all paying players)
| Status | Dice 63: payout · week after | Domino 20 | Disney 15 | Players (Dice / Domino / Disney) |
|---|---|---|---|---|
| Finished | +5% · 103% | −18% · 124% | −11% · 107% | 19,688 / 8,071 / 12,613 |
| 1–2 short | +5% · 87% | −12% · 104% | −5% · 98% | 29,743 / 13,687 / 17,183 |
| 3 short | +4% · 75% | −8% · 92% | +1% · 77% | 76,491 / 24,642 / 29,956 |
| 4+ short | +6% · 55% | −4% · 62% | +4% · 66% | 65,898 / 53,515 / 245,055 |
Share of players whose payout fell: Domino 82 / 73 / 66 / 57%, Disney 72 / 60 / 48 / 41%, Dice 38 / 36 / 36 / 36%.
$2–20 a day: same pattern (Domino −18 / −12 / −7 / −5%, Disney −12 / −5 / +1 / +7%, Dice +5% in every group).

## Reading
- **Fact:** in Domino and Disney the payout drop after close is a staircase: biggest for finishers, smaller with each sticker missing, none (Disney) or small (Domino) for 4+ short. Dice: no drop in any group.
- **Fact:** the groups with the biggest payout drop come back the best (finishers 107–124% of pace); the groups with no drop come back the worst (4+ short 55–66%).
- **Interpretation:** ~~the drop reflects a richer end of album~~ (my first reading, corrected by the payout-level check below: mid-album the groups were close, so the drop is real). The drop does not slow finishers, who spend the most. The weak return of players far from 144 started before close (s6d), with no payout drop after it.
- **Answer:** the "weaker game after close" in Domino and Disney hits the players who come back best; it does not explain who comes back low. Together with the within-game split (`topic6-short-payers-2026-10-24.md`) the payout after close is not a lever for the return.
- **Recommendation:** soft landing after close as a revenue lever: **do not adopt**. If the team still wants to try it (Part 1 slide 36 action), **test** it on Disney/Domino finishers with next-album spend as the measure; this data gives no reason to expect a lift.

## Payout level after close (Eden asked 2026-10-24: the overall payout of each group after the album, not the ratio)
SQL: `claude/topic6_payout_level_2026-10-24.sql` (same runs: Disney 127 GB, Domino 42 GB, Dice 209 GB). Slide: **t6i_slide** (after t6h).
Definition: whole group, days 1–3 after close: everything won from the game ÷ everything spent on play (Mixpanel definitions as slide 36, all sources; album prizes are almost zero in those days). Players who played in those days.

| Status | Dice 63 | Domino 20 | Disney 15 |
|---|---|---|---|
| Finished | 77% | 64% | 59% |
| 1–2 short | 83% | 68% | 65% |
| 3 short | 88% | 71% | 72% |
| 4+ short | 88% | 73% | 78% |
| All | 84% | 70% | 73% |
| Mid-album, same groups (finished → 4+) | 84 / 86 / 89 / 89% | 76 / 78 / 78 / 79% | 68 / 71 / 73 / 76% |
Median player after close: Dice 88 / 89 / 90 / 90% (flat), Domino 59 / 62 / 65 / 66%, Disney 61 / 67 / 74 / 74%. $2–20 a day: same order. Levels are not comparable across games (different formulas).

### Reading
- **Fact:** after close the finishers get the lowest payout of all groups in all three games (in Dice only at group level; the median Dice player is flat). In Domino the groups were about equal mid-album (76–79%) and the gap opens after close (64% vs 73%); in Disney finishers were a little lower mid-album and the gap widens (59% vs 78%).
- **Fact:** the same finishers spend the most in the week after (t6h: 103% / 124% / 107% of own pace).
- **Correction:** my earlier reading on t6h ("the drop reflects a richer end of album") is wrong: mid-album levels were close, so finishers really get a stingier game after close.
- **Hypothesis (not tested):** finishers play differently at the start of the new album (bigger stakes, more boosters), which lowers the payout per coin.
- **Recommendation:** unchanged: soft landing as a revenue lever: **do not adopt** (the stingier game does not stop finishers from spending). If the team wants it for player experience, **test** it with next-album spend and retention as measures.

## Story slide t6j (Eden 2026-10-24): Dice finishers come back slowest + the payout story
Slide **t6j_slide** (after t6i). Finishers $2–20 a day: payout change days 1–3 vs own mid-album (median player): Dice +5%, Domino −18%, Disney −12%; week after (s6c): 110% / 140% / 128%. Under each panel: payout level after close, finishers vs all players of the same game (77 vs 84 / 64 vs 70 / 59 vs 73%).
- The change is comparable across games (each player vs himself); the levels are not (different formulas), so the slide compares levels only inside a game.
- Same direction for payers 1–2 short: payout +5% / −12% / −5%, week after ($2–20) 90% / 103% / 108%.
- **Hypothesis:** Dice keeps paying out a lot after close, so the roll stock lasts and the next purchase waits; Domino and Disney tighten the start of the new album. **Caveat:** inside each game, players whose payout fell did not spend more (payout split), so this is a lead, not proof.
- **Recommendation: TEST** in Dice: tighter payout in days 1–3 of the new album for finishers and players 1–2 short, Control = today; measure buying and spend vs own pace in days 1–7; guardrails next-album spend (14 days), finish rate, churn.
