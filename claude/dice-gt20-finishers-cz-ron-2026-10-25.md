# Dice finishers over $20: what changes in the week after close? (2026-10-25)

Eden (2026-10-25, slide 79 a6s8f): Dice finishers over $20 a day spend 15–19% less in the week after close than in their normal week in albums 59 and 63 (not 61). Quick check: did their comfort_ron / comfort zone go up, or the payout go down?
SQL: `claude/dice_gt20_finishers_cz_ron_2026-10-25.sql` (dice-dreams-dbt, 109 GB).

## Definitions
- Population: as `topic6_normal_week_check_2026-10-24.sql` (Dice part). Standard population, status on close−1, spend level from album days 0–20, level >$20 a day. Groups: finishers (144) and 1–2 short.
- Windows: normal week = album days 21–27; week after = close+1..+7.
- Source: `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`. Players with a row in the window (active). Per player first, then the average across players.
- comfort_ron = `comfort_ron_start_day` (smart segments, "rate of need"). comfort_zone = `comfort_zone_start_day` (source `cz_old`).
- Spend = `revenues_sum` ÷ (7 × own pace). Check: it gives 105 / 98 / 96% (normal) and 86 / 100 / 82% (after) for finishers, close to the slide (104 / 98 / 96 and 84 / 98 / 82; the slide also counts inactive players).

## Results: finishers over $20 (normal week → week after)
| | Album 59 (drop) | Album 61 (no drop) | Album 63 (drop) |
|---|---|---|---|
| Players | 961 | 1,097 | 1,427 |
| Spend vs own pace | 105% → 86% | 98% → 100% | 96% → 82% |
| Buyers | 93% → 88% | 93% → 89% | 93% → 87% |
| Purchases per buyer | 9.3 → 7.4 (−20%) | 9.1 → 8.6 (−5%) | 9.2 → 8.3 (−10%) |
| $ per purchase | $42 → $45 (+8%) | $41 → $46 (+11%) | $36 → $37 (+2%) |
| comfort_ron (average) | 64 → 72 (+11%) | 60 → 72 (+19%) | 54 → 55 (+1%) |
| Median bet multiplier | 679 → 642 | 713 → 671 | 594 → 651 |
| Rolls spent per player | −19% | −18% | −1% |

Players 1–2 short over $20, same pattern: purchases per buyer 8.4 → 6.6 / 7.9 → 7.7 / 8.0 → 7.1; $ per purchase about flat ($35 / $35 / $33 → $35 / $34 / $31).

## Reading
- **Fact:** the drop comes from fewer purchases per buyer (−20% in 59, −10% in 63), not from cheaper purchases. $ per purchase stays the same or rises in all three albums.
- **Fact:** a few % fewer buyers in all three albums (−4 to −6 points), including album 61 without a drop.
- **Fact:** comfort_ron does not follow the drop. It rose most in album 61 (+19%), where spend did not drop, and barely moved in album 63 (+1%), where it dropped.
- **Fact:** the payout (earlier result, `topic6-payout-3albums-2026-10-24.md`) does not follow it either: +1 / −12 / −2% in 59 / 61 / 63.
- **Data issue:** `comfort_zone_start_day` is 0 for every player in these windows, so the comfort zone could not be checked from this table.
- **Answer:** comfort_ron and the payout do not explain the drop. The finishers buy less often in the week after close, at the same price.
- **Hypothesis (not checked):** fewer purchase triggers in the first week of the new album (offers, events, out-of-rolls moments) than in the album's normal week. Out-of-rolls per player is similar in both weeks (7.5 → 7.2, 6.9 → 6.1, 7.9 → 7.1), so it is not a lack of need.
