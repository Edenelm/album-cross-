# Disney 15: does the economy act differently in sticker lulls and bursts? (2026-10-23)

Eden's question: in lull days or burst days, is there an anomaly in the economy, e.g. high payout on days many stickers are released? And where can the lulls be a problem?
SQL: `claude/lull_economy_disney15_2026-10-23.sql` (solitaire-dreams-411507, 306 GB). Daily album table + Mixpanel coins in / out views.

## Definitions
- Population: Disney 15 standard-population payers (paid on any album day incl. close), all players; per album day (close day left out).
- New stickers = mean per payer, day-to-day change of unique set stickers (the slide uses the median, so values differ a little).
- Payout = Mixpanel "Total RTP": (gameplay coins won − boosters) ÷ level-start stake, allowance units, same filters as `payout_mixpanel_def_queries.sql`. "Without album prizes" takes out album / set / duplicates coins.
- Spend = album-table spend per active payer; paying share = payers with spend > 0 ÷ active payers. Balance = median end-of-day coin balance (allowance units).
- Windows (from the stall check): lull 1 = days 10–13, burst 1 = days 16–19, middle = days 20–25, lull 2 = days 27–31, burst 2 = days 32–35.

## Results (average of the days in each window)
| Window | New stickers | Payout | Payout without album prizes | Median balance | $ per active payer | Paying share |
|---|---|---|---|---|---|---|
| Lull 1 (10–13) | 1.1 | 53% | 51% | 3.3 | $2.91 | 17% |
| Burst 1 (16–19) | 5.4 | 63% | 58% | 4.2 | $2.59 | 16% |
| Middle (20–25) | 2.9 | 60% | 55% | 3.8 | $2.82 | 16% |
| Lull 2 (27–31) | 1.8 | 55% | 50% | 3.5 | $3.17 | 17% |
| Burst 2 (32–35) | 3.3 | 57% | 52% | 3.3 | $3.18 | 17% |

Across days 8–38 (31 days): balance vs spend r = −0.67; payout vs spend r = −0.46; new stickers vs payout r = +0.41; new stickers vs spend r = −0.19.

## Reading
- **Fact:** burst 1 is a "rich" stretch: payout 63% vs 53% in lull 1 (+19%), and not only from album prizes (without them 58% vs 51%, +14%); median balance +24%; spend per active payer −11% ($2.59 vs $2.91).
- **Fact:** burst 2 is not rich (payout 57%, balance 3.3) and spend stays up ($3.18). So "many stickers" does not always mean high payout; it does when the event wave also pays many coins.
- **Fact:** in the lulls payout and balance are lower and spend is the same or higher (lull 2: $3.17, paying share up to 18% on days 28–29).
- **Fact:** day 7 is the exception: payout 67% and the highest spend of the album ($4.20; sets 11–12 open that day).
- **Interpretation:** there is no anomaly in the lulls. The anomaly is in burst 1: stickers and coins come together, and on those days payers spend less. Days with a higher balance have lower spend.
- **Where the lulls can hurt:** progress, not spend. The payer goes into the end further behind (Disney 15 at day 30: 76% held vs 82% Dice, 88% Domino) and misses more at close. The risk grows the later the lull is (lull 2 is at 63–72% of the album).
- **Hypothesis (not tested):** the release calendar is a design choice; the question is whether it serves the goal. Splitting the coins of a burst over the lulls (same total) would keep spend and raise progress.
- Correlation only, one album; Disney 14 not checked.

Recommendation: **test**, do not change yet. Test idea: in a lull, a small steady sticker source without extra coins vs control; measure spend in the lull and the next burst, stickers missing at close, finish rate.
