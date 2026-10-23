# Topic 7: Dice finishers and the grand prize — who, how big the prize is for them, what happens after (2026-10-25)

Eden (2026-10-24 handoff): continue alone — who are the Dice finishers who come back slowly, what happens to the 200K players, how to improve the prize and for whom (a test proposal). Little text, visual, add slides to ALBUM END.
SQL: `claude/topic7_dice_prize_2026-10-25.sql` (`dice-dreams-dbt`, 130 GB: `50_reporting.user_daily_album` + `30_intermediate.user_daily_rolls_in_out`).
Slides: t7a_slide, t7b_slide, t7c_slide (after s6b_slide). Generator: `claude/slide_t7_dice_prize_2026-10-25.py`. Thumbnails: `claude/slides/t7a.png`, `t7b.png`, `t7c.png`.

## Definitions
- Population, spend level, finished and the after-week: exactly as topic 6 (`topic6-after-album-2026-10-24.md`). Standard-population payers; spend level = album $ a day before the last quarter (own pace); finished = 144 on close−1 (Dice daily table); after-week = 7 days after the close day (next album days 2–8).
- Prize = `album_reward_value` (rolls) on the last row before close; code = `album_reward_code` (1–7; 7 = 200K).
- Prize in days of own play = prize ÷ the player's own rolls played per day over the album (start to close−1). **My choice** (reason: the prize is paid in rolls, so its weight for a player is how many days of that player's play it covers).
- Buckets <2 / 2–4 / 4–8 / 8+ days: my choice (round numbers; the earlier memo talked about "4–8 days").
- Revenue share = share of all standard-population paying players' album revenue.

## Results — Dice 63 (Dice 61 in brackets)
### Who has the 200K prize (payer finishers, code 7)
| Spend level | Players | % of album revenue | Prize in days of own play (median) |
|---|---|---|---|
| ≤$2 | 1,599 | 0.5% | 4.9 (5.3) |
| $2–5 | 1,401 | 1.1% | 3.6 (3.8) |
| $5–20 | 1,789 | 3.7% | 2.4 (2.5) |
| >$20 | 843 | 7.5% | 1.2 (1.2) |
| All | 5,632 of 19,688 payer finishers (29%) | 12.8% | |

### Bought in the 7 days after close, by prize in days of own play
| Spend level | <2 days | 2–4 days | 4+ days |
|---|---|---|---|
| ≤$2 | 55% (58%) · 2,655 | 51% (52%) · 3,429 | 42% (46%) · 2,568 |
| $2–5 | 70% (72%) · 2,178 | 70% (71%) · 1,954 | 65% (61%) · 875 |
| $5–20 | 80% (80%) · 2,864 | 79% (77%) · 1,429 | 75% (79%) · 279 |
| >$20 | 87% (88%) · 1,385 | 85% (87%) · 72 | — |

### After-week spend vs own album pace (same cells)
| Spend level | <2 days | 2–4 days | 4+ days |
|---|---|---|---|
| ≤$2 | 243% (302%) | 198% (253%) | 157% (211%) |
| $2–5 | 135% (158%) | 119% (152%) | 104% (133%) |
| $5–20 | 110% (119%) | 98% (126%) | 90% (123%) |
| >$20 | 85% (103%) | 81% (89%) | — |

### Money (gap to own pace in the after-week, $)
- ≤$2–$20 finishers spend **above** their own album pace in the after-week in almost every cell, so there is no $ gap to own pace there; the cost of a big prize shows as fewer buyers.
- >$20 finishers, album 63: 85% of own pace, $69,752 short in one week (<2-day prize). Album 61: 103%, no gap. Disney 15 >$20 finishers are at 86% too (topic 6), so this is not a Dice-prize effect; noisy between albums. Not used on a slide.

## Reading
- **Fact:** the same 200K prize is 5 days of play for a ≤$2-a-day payer and 1 day for a >$20 payer (both albums). 28% of 200K payer finishers spend ≤$2 a day.
- **Fact:** in ≤$2 and $2–5 payers, the bigger the prize vs own play, the fewer buy in the next week (≤$2: 55% → 42%; $2–5: 70% → 65%), in both albums. $5–20: small, not in album 61.
- **Interpretation:** for light payers with a big prize (the prize code never goes down) the prize is a stock of free play that delays the next purchase. Fits the 2026-10-19 findings (stock, later out-of-rolls).
- **Bias:** a long prize in days also means a player who plays less than their code suggests (spent more in the past); they may be slowing down anyway. Only a test settles cause.
- **Not a big money issue in light payers:** they still spend at or above their album pace in that week. Payers with a 4+ day prize: 3,722 players, 1.6% of album revenue.
- **Other games:** no test needed now; Domino / Disney $2–20 finishers start the next album at 140% / 128% of own pace vs Dice 110% (s6b).

## Recommendation — TEST
Prize sized to the player's own play (about 2–3 days of own rolls), Control = today's ladder. Less for the 3,722 payers with a 4+ day prize (1.6% of revenue), more for the 1,457 >$20 payer finishers (12% of revenue; = the earlier 250K / 350K proposal). Main measure: % who buy in the 7 days after close; also week-1 spend vs own pace, next-album revenue per payer, rolls given. Guardrail: album revenue and finish rate must not drop. If the prize cannot go down ("never less"), run only the top-payer arm. Days, floor and cap = management options.

## Open
- Dice 65 → 67 after-week is not complete yet (67 day 8 = 2026-10-27); re-run with albums 63/65 after that.
- Is the >$20 album-63 drop (85% of pace) repeated in Dice 65? If yes, it is a bigger $ question than the light-payer prize.
