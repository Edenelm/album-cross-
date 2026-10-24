# Album Analysis Across Three Games: Final Analysis Specification

SuperPlay · Dice Dreams, Domino Dreams, Disney Solitaire · October 2026 · prepared for the product teams and the CRO.
Author: Eden Elmaliach (analysis), with Claude. Status: final for the decision deck; evidence deck v82 is the appendix.

## 1. Purpose
Compare the sticker album in the three games end to end (structure, who pays, how the album gets closed, who is left behind, what happens after), and give each game a bottom line: what to test, what not to change, and which targets to track. Every number is measured in data unless marked Hypothesis or Needs a test. No money figure is based on an assumed lift; "scope" always means the current revenue of the group in question.

## 2. Scope and data
| Item | Dice Dreams | Domino Dreams | Disney Solitaire |
|---|---|---|---|
| Albums compared | 61 / 63 (previous 59 / 61) | 19 / 20 (17 where noted) | 14 / 15 (previous 13 / 14) |
| BigQuery project | dice-dreams-dbt | domino-dreams-dbt | solitaire-dreams-411507 |
| Daily album table | 50_reporting.user_daily_album | prod_40_mart.user_daily_album | bi_prod.user_daily_album |
| Sticker table | 30_intermediate.fact_user_album_stickers | prod_30_intermediate.int_user_album_stickers | bi_entity_prod.dim_user_album_stickers |
| Daily metrics (game revenue) | 50_reporting.user_daily_metrics_agg | prod_40_mart.user_daily_metrics | bi_prod.solitaire_user_daily_metrics_agg_df |
| Exclusions | is_excluded, dim_excluded_users | special_user_flag, suspected_cheater_flag | special_user_flag, exclude_reason |
| Album size | 144 set stickers (12 sets); Pixie outside | 144 (12 sets) | 144 (12 sets); Magic outside |
| Rare stickers | 12 Supers | 8–9 Royals | 7 Royals |
| End gate (locked to the end) | 3 stickers (2 Supers + 1 Golden) | 3 stickers (hard: 2 Royals + 1 Golden; easy: 2 Royals + 3 Goldens = 5) | 3 stickers (Royal 131 + 2 Goldens) |
| Closing tool | Wild, mostly paid, sold through the last week | Joker, paid from about 7 days out; free Puzzle Jokers in album 20 | Joker, mostly from the Market, only 3–4 days out |

Album-event payout and rare-source checks used the Mixpanel staging views (approved by Eden). Dice daily table does not update stickers on the close day; close-day finishers come from the sticker table.

## 3. Definitions (source of truth: decisions-definitions-register.md)
- **Standard population:** not in the player's first album; login ratio at least 0.5 on the last row before close; a row on the day before close; test, special and cheater users removed.
- **Finisher:** 144 unique set stickers by the end of the close day (close day included), not the in-game flag (the flag overstates finishers by 10–20%).
- **Payer:** paid on any album day, close day included. Close-day spend is not added to album revenue (half day).
- **Album revenue:** the album table's daily spend column = all in-game spend on album days, gross USD, album start to the day before close. It is not revenue caused by the album.
- **Revenue share (deck-wide denominator):** share of total game purchase revenue during the album (all players, album start to the day before close, cheaters and test users excluded). RV (ad) revenue is reported separately. Older docs used the standard population's album revenue; factors to the new basis: Dice 0.67–0.69, Domino 0.76–0.79, Disney 0.78–0.81.
- **End lift:** revenue per day in the last 4 full days (close−4 to close−1) ÷ the whole album, same players.
- **Spend groups:** $ per active day in the previous album: 0 / up to 2 / 2–5 / 5–20 / over 20. **Strength percentile:** $ per active day until the start of the last quarter of the album (p50 ≈ $1, p90 ≈ $7, p95 ≈ $12–13 a day in all three games).
- **Easy (Eden's definition, 2026-10-21):** paid below the previous album's median payer spend ($18–24 per album) and did not finish it, or returning after a gap. Not the game's own segment field.
- **Checkpoints:** close−4 and close−3 = 4 and 3 days before the close day; "missing" = 144 minus unique stickers on that day.
- **Seasons rule:** show two albums only when the difference carries the message; otherwise the average or the latest album, labelled.

## 4. The story in eight chapters (evidence deck, 96 slides)
| # | Chapter | Finding (Dice / Domino / Disney) | Status |
|---|---|---|---|
| 1 | The three games side by side | Same 144 stickers, three builds. Players past their first album bring 96 / 88 / 88% of September revenue. The album earns most at the end in Dice and Domino (+13–20% / +8–20% in the last 4 days); Disney's end is flat (−2 to +4%). | Measured |
| 2 | Who is where at the end | Few payers finish (11 / 8 / 5%) and bring 19 / 22 / 17% of game revenue. 4+ stickers missing at the end hold 16 / 33 / 33% of game revenue; 1–3 missing hold 33 / 22 / 29%. | Measured |
| 3 | Where rare stickers come from | Median gap between new rares 4 / 7 / 7 days; longest dry run 6 / 13–15 / 12–15 days. Dice drips Supers from one always-on Trail (39 campaigns in 68 days); Domino pulses via events then duplicate exchange; Disney spreads 7 Royals over rotating events. | Measured |
| 4 | How the album gets closed | The close happens in the last 3–4 days through the Wild / Joker, which fills 23–92 stickers per 100 near payers but 2–9 per 100 far ones. Disney goes dry a week out (1% of near payers get a free sticker a day, 0% buy). In Domino 20, 43% of finishers never paid: a free RV path (median 2,873 rewarded views, 90 a day, manual ad farming). | Measured; the cause of Disney's gap is a hypothesis |
| 5 | Those left behind | Payers 2–3 short 8 days out finish 42 / 51 / 25%; same spend, half the finish in Disney. $20+ payers ending 2–3 short (7 / 3–4 / 7–8% of game revenue) cut spend to about 61–63% of usual in the last 4 days. | Measured |
| 6 | After the album | Finishing does not use up a payer (−2% to +18% spend after finishing, no control). The next album opens weak in Domino and Disney: finishers' payout −12 to −19% in days 1–3 (Dice ×1.03–1.04). | Measured, no control group |
| 7 | Three game cases | Domino 20's easier end: payer finishers +44%, revenue per player +3%. Dice's prize: the 200K tier returns 13% of rolls to $2K+ payers vs 24% to $150–699 payers. Disney's late gate: Royal 131 and the paid Joker both open only 3–4 days out. | Measured, no control group |
| 8 | What each game should do | One plan per game, every change as a test (section 5). | Needs a test |

## 5. Bottom lines and tests per game (decision deck, 22 slides; approved 2026-10-21)
**Disney: the gap is completion, not spend.** Near payers (2–3 short 8 days out) finish 25% vs 42–51% elsewhere and hold 22% of game revenue.
1. Test 1: sell the Joker from 7 days out, two arms (Joker only / Joker + earlier Royal 131). Scope: payers 2–6 short 8 days out = 74–105K players, 49–50% of game revenue. Judge by revenue per player (album + days 1–14 of the next), finish rate, read by spend group. Precondition for the Disney team: can a Joker pick Royal 131 before its release?
2. Test 2: Royals / Goldens 14–8 days out for $5–20-a-day payers (28% of game revenue; 54% of it still 4+ away 4 days out).
3. Soft landing for finishers in days 1–3 of the next album (finishers = 16–18% of game revenue; payout −13 to −19%).
4. Test 3: completion offer for $20+ payers 2–3 short before the last 4 days (2.6–3.0K players, 7–8%).
Do not: compensate missers after close; make it harder for non-payers (5–15% of finishers).

**Domino: at the revenue goal, not at the finish goal.** The easier end of album 20 worked; 43% of its finishers never paid.
1. Keep album 20's end. Test the easy gate of 3 vs 5 stickers (or release two gate Goldens earlier): in album 19, 25% of easy-segment payers ended exactly at the 5-sticker gate (26,418 players, 13% of game revenue, 98% missing only Goldens and Royals).
2. RV: daily view cap and an RV reward table without packs and Puzzle pieces in the last third (ad revenue at risk $45,084 = 0.28% of game revenue; a cap of 60 a day touches 42% of free finishers).
3. Test 2 as in Disney ($5–20 payers = 26% of game revenue).
4. Stronger start of the next album for finishers (20–27% of game revenue; payout −12 to −19%).
5. One vs two Puzzle Jokers, low priority (520 strong closers, 2.3% of game revenue).
Do not: use a bigger grand prize as a revenue lever (natural experiment: ×0.88 vs ×1.01 next-album spend around the $300 line).

**Dice: the engine works; the money is in the prize and the restart.** Finish rate 11.2% (at goal), finishers 19% of game revenue (goal 20%).
1. Test 5: grand prize fitted to spend, 250K / 350K rolls for stable $1K+ / $2K+ payers (1,863 players, 11% of game revenue), 25K → 100K for new $700+ payers (2,361, 7%). A/B only: in Domino a bigger prize did not raise spend.
2. Test 3: completion offer for $20+ payers 2–3 short (1.5–1.6K players, 7%).
3. Test 4: next-album opener for late finishers (8.7–10.9K players, half of payer finishers, 7–8%; days 1–3 at ×0.65–0.92). Measure first: no-prize payers also fell to ×0.78 in album 63.
Keep: the Super gate and the paid Wild (95–96% of last Supers come through a Wild); no payout change after close. Do not: raise the prize for light / mid payers (they buy 7–11 points less in week 1 with the 200K prize).

## 6. Targets
- Game level (Eden): about 10% of payers finish; finishers bring 20% (Dice) / 23% (Domino) / 24% (Disney) of game revenue (= 30% of the old basis). Today: 11.2 / 7.7 / 5.2% finish; 19 / 23 / 17% of revenue.
- Finish rate rises smoothly with payer strength (decile 1 to top 1%: ×17 / ×24 / ×48); above p95 finish 25–42%, below 4–11%. The 10% goal is in practice a goal for the 95% of payers below $12–13 a day.
- Targets per spend group: not decided. Options shown (one multiplier for all; top unchanged, the rest raised; a "3 or fewer missing 4 days out" target per group). The missing evidence, that a higher finish rate in a group adds revenue per player, comes from test 1's per-group readout.
- Measurement that starts now without a test: finisher = 144 by the end of the close day; one 5-group structure by $ a day; every population reported with its share of game revenue; data fixes (Dice stored segment column, Domino −9999 daily segment, Dice Easy spend curve).

## 7. Test plan (order by money in scope; every test vs a control group inside one album; Eden's AB method: per-user 14-day pre period, normalise by group size, difference-in-differences in %)
| # | Test | Game | Share of game revenue in scope | Judge by |
|---|---|---|---|---|
| 1 | Joker on sale from 7 days out, two arms | Disney | 49–50% | Revenue per player (album + next 14 days), finish rate, by spend group |
| 2 | Royals / Goldens 14–8 days out for middle payers | Disney, Domino | 26–28% | Stickers missing at close, revenue per player |
| 3 | Easy gate of 3 instead of 5 | Domino | 13% parked at the gate (album 19) | Easy finish rate, revenue per player; revenue per finisher as guardrail |
| 4 | Completion offer for $20+ payers 2–3 short | Dice, Disney | 7% / 7–8% | Spend in the last 4 days and the week after |
| 5 | Soft landing / next-album opener for finishers | Disney, Domino, Dice | 16–27% | Spend in days 1–14 of the next album |
| 6 | Grand prize fitted to spend | Dice | 11% + 7% | Revenue per player in this album and the next |
| 7 | RV cap and reward table · one vs two Puzzle Jokers | Domino | 0.28% at risk · 2.3% | Payer conversion, retention, ad revenue · paying finishers |

## 8. Checks added on 2026-10-21 (after the decks)
- **Gate distance:** payers exactly 5 stickers short 4 days before close finish 6–9% in all three games (easy segment: Domino 7–8%, Dice 6–7%; Eden's easy definition: Domino 10 / 6%, Dice 5 / 4%, Disney 4 / 4%); from 3 short they finish 13–27%. Domino 19 piled its payers at 5 (19,832 players, 14% of game revenue), Dice and Disney pile at 3. 91% of Domino 19's pile at 5 were payers above the previous album's median. "Too far" is supported as distance, not as player weakness. Doc: gate-distance-finish-2026-10-21.md.
- **Payout by source, last 4 days:** on one definition (album-source wins ÷ coins or rolls spent) the album gives back 15–18 points in Dice, 7–12 in Domino, 10–11 in Disney in the last 4 days (×1.5–3 the mid-album level). Domino is not more generous at the end; the gap in the Mixpanel "album payout" file (23.7 / 13.4 / 9.6%) is a per-game metric definition. Items (packs, Jokers, kiosk tokens) are not coins and do not enter any payout. Doc: payout-by-source-last4-2026-10-21.md.

## 9. Open questions for the teams
| Team | Question | Why it matters |
|---|---|---|
| Disney | Can a Joker pick Royal 131 before its release? | Precondition for test 1's arm A |
| Disney | Are Market tokens bought or earned? | Whether the end tool is paid or free; 67–80% of Royal 131 comes from the Market |
| Disney | What changed in the album end since album 9? | End lift went from +35% to −1% to +8% |
| Domino | What was the easy gate in album 20: 3 stickers, or two gate Goldens released early? | Album 20 easy players behaved as if the gate were 3; decides test 3's design |
| Domino | Which RV cap level, and which rewards leave the RV badge? | Management decision; 60 a day touches 42% of free finishers |
| Dice | Which Trail tier gives the Wild, and who is eligible? | About 48K got a Wild in the last 3 days of album 63, more than reached the top tier |
| All studios + BI | Paid or free, source by source (Promo Wheel spins, MTX event rewards, Market tokens, Trail boosters) | The data sees only purchase events |
| Management | Finish targets per spend group | Not decided; test 1's per-group readout is the first evidence |

## 10. Deliverables
- Decision deck (22 slides): https://claude.ai/artifact/F1nbGMJptGsz2LW96TQ2jf · Google Slides: https://docs.google.com/presentation/d/1706frcGaYkX013j2sxSpPaGvCDgMLtfLJqvIKKaA4TY/edit
- Evidence deck v82 (96 slides): https://claude.ai/artifact/6UUb91x2vHULkaM4g73uQr · Google Slides in two parts: Part 1 (opening to chapter 7) https://docs.google.com/presentation/d/1WS07a_8A_IDJ1HndTBG34qHD5-sJx8WNDzhVAkv3zwQ/edit · Part 2 (chapter 8, method, appendix) https://docs.google.com/presentation/d/1CQVnRMrtzWG_j6MQebUKuErP5TDUYmQJaFG_FUvwJBg/edit
- Repository: https://github.com/Edenelm/album-cross- (branch main). INDEX.md maps every result doc and SQL file by topic; decisions-definitions-register.md holds the definitions; claude/storyline-v4-2026-10-20.md is the chapter plan; claude/final-deck-bottom-lines-2026-10-21.md the approved bottom lines; raw query results under claude/results/.

## 11. Limitations
- All findings are observational (two albums per game, self-chosen groups); no causal claim is made, every lever is a test.
- Population filters use the login ratio on the last row before close, which favours players who stayed.
- Disney has no album segment field; Dice's stored segment column disagrees with the team's query for part of the upper levels; Domino's daily segment is −9999 on about 26% of rows.
- Payout formulas differ per game (Mixpanel definitions); levels are not comparable, only shapes and the album's share.
- Paid vs free cannot be read from the data for most rare sources (MTX events); listed as questions for the studios.
