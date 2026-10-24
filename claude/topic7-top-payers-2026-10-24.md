# Topic 7b: Dice >$20 a day finishers — is the after-album drop real? (2026-10-24)

Question (Eden): keep checking the drop of >$20 payers in Dice. In topic 7, album 63 >$20 finishers spent 85% of their own pace in the week after close (album 61: 103%).
SQL: `claude/topic7_top_payers_2026-10-24.sql` (`dice-dreams-dbt.50_reporting.user_daily_album`, 107 GB).

## Definitions
- Population, spend level, finished status: as topic 6 / topic 7 (standard-population payers; level = album $ a day before the last quarter; finished = 144 on close−1).
- **After window = first 4 days after the close day** (close+1 … close+4 = next album days 2–5). Reason: album 65 closed 2026-10-19 and the data runs to 2026-10-24, so only 4 full days exist for it; the same 4 days are used for all three albums so they compare. 7-day numbers are given for 61 / 63 only.
- After vs own pace = group spend per day in the window ÷ group album pace per day. Bought = any purchase in the 4 days.
- >$20 split into $20–50 / $50–100 / >$100 a day: my cut (round numbers), to see whether a few big payers drive the drop.
- Gap = pace × 4 − spend in the 4 days (gap to own pace, not a forecast).

## Results — finishers, first 4 days after close (album 61 / 63 / 65)
| Spend level | Players | % of album revenue | After vs own pace | Bought in 4 days | Gap in 4 days |
|---|---|---|---|---|---|
| $2–5 | 3,488 / 5,007 / 5,044 | 3% / 4% / 4% | 132% / 112% / 126% | 55% / 55% / 64% | none |
| $5–20 | 3,476 / 4,572 / 5,422 | 7% / 9% / 11% | 111% / 100% / 108% | 66% / 69% / 75% | none |
| $20–50 | 837 / 1,092 / 1,288 | 5% / 6% / 7% | 107% / 88% / 93% | 78% / 80% / 83% | none / $15,650 / $10,349 |
| $50–100 | 212 / 267 / 306 | 3% / 3% / 4% | 88% / 89% / 108% | 78% / 85% / 86% | $7,082 / $8,080 / none |
| >$100 | 104 / 98 / 130 | 3% / 3% / 4% | 86% / 71% / 85% | 89% / 85% / 89% | $9,549 / $18,262 / $13,040 |
| **All >$20** | 1,153 / 1,457 / 1,724 | 11% / 12% / 15% | **96% / 84% / 95%** | 79% / 81% / 84% | $9,904 / $41,992 / $17,042 |

(The 7-day after-week for album 63 >$20 finishers: 84%; album 61: 103% — same picture as topic 7.)

## Reading
- **Fact:** the >$20 drop is one album. Album 65's >$20 finishers start album 67 at 95% of their own pace, the same as album 61 (96%). Album 63: 84%.
- **Fact:** in album 63, finishers at every level started the next album lower than in 61 and 65 ($2–5: 112% vs 132% / 126%; $5–20: 100% vs 111% / 108%; >$20: 84% vs 96% / 95%). So the dip is about the start of album 65 (the album after 63), not something special about top payers.
- **Fact:** the share who buy stays the same (79–84% of >$20 finishers in all three albums); the dip was in how much they spent.
- **Fact:** >$100 a day is 98–130 players; 71% in album 63 vs 85–86% is noise-sized (a few players move it).
- **Hypothesis (not checked):** something in album 65's first days (offers, events, album design) was weaker for paying finishers. Check the album 65 day 2–5 calendar if it matters.
- **Side fact:** >$20 payers who do **not** finish are the big steady gap in the same 4 days: about $192,000–$233,000 short of their own pace in every album ($20–50 alone $103,250 / $130,048 / $115,266). That is the topic 6 message (far payers start the next album slowly), not a new one.

## What this changes
- No new slide (the result is "no lasting problem"; one-line note added to t7c speaker notes).
- t7c top-payer arm: rests on the prize being small for them (about 1 day of play), not on a proven spend drop.

## Event calendar at the start of album 65 (checked 2026-10-24, Eden asked)
Source: `dice-dreams-dbt.20_core.dim_campaign` (only campaign id + name; launch date read from the name prefix DDMMYY — my assumption). Window: 2 days before to 4 days after the album start. All 420 rows read.
- Same volume and the same types in all three starts: 133 (album 63 start) / 143 (album 65 start) / 144 (album 67 start) campaigns — offers, Dream Pass, quests, tournaments, trail challenges, RV offers, new-album reveal and starter pack.
- Album 65 start had holiday sales (Labor Day, Patriot Day) and no missing campaign type that the other starts had.
- One difference: the album 63 start (= the week after album 61) had a "1 week Hot Summer Sale" strategy test. That could make album 61's after-week look high, rather than album 63's look low. Hypothesis only.
- **Conclusion:** names alone do not explain the album-63 dip. Explaining it would need revenue by campaign — not done; the dip is one album and is not part of the story.
