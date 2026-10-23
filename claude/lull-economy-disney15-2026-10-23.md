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
- **Fact:** burst 1 is a "rich" stretch: payout 63% vs 53% in lull 1 (+20%), and not only from album prizes (without them 58% vs 51%, +14%); median balance +24%; spend per active payer −11% ($2.59 vs $2.91).
- **Fact:** burst 2 is not rich (payout 57%, balance 3.3) and spend stays up ($3.18). So "many stickers" does not always mean high payout; it does when the event wave also pays many coins.
- **Fact:** in the lulls payout and balance are lower and spend is the same or higher (lull 2: $3.17, paying share up to 18% on days 28–29).
- **Fact:** day 7 is the exception: payout 67% and the highest spend of the album ($4.20; sets 11–12 open that day).
- **Interpretation:** there is no anomaly in the lulls. The anomaly is in burst 1: stickers and coins come together, and on those days payers spend less. Days with a higher balance have lower spend.
- **Where the lulls can hurt:** progress, not spend. The payer goes into the end further behind (Disney 15 at day 30: 76% held vs 82% Dice, 88% Domino) and misses more at close. The risk grows the later the lull is (lull 2 is at 63–72% of the album).
- **Hypothesis (not tested):** the release calendar is a design choice; the question is whether it serves the goal. Splitting the coins of a burst over the lulls (same total) would keep spend and raise progress.
- Correlation only, one album; Disney 14 not checked.

Recommendation: **test**, do not change yet. Test idea: in a lull, a small steady sticker source without extra coins vs control; measure spend in the lull and the next burst, stickers missing at close, finish rate.

## Follow-up (Eden 2026-10-23): fewer buyers or less per buyer? Who falls behind and what are they worth?
SQL: `claude/lull_revenue_disney15_2026-10-23.sql` (11.8 GB, daily album table only). Same payers; album revenue = days 1–42 (close day left out) = $36,513,464.
ARPDAU = revenue ÷ active payers that day; ARPPU = revenue ÷ buyers (spend > 0) that day; conversion = buyers ÷ active.

| Window | Active payers / day | Buyers / day | Conversion | ARPPU | ARPDAU | Revenue / day | Window revenue | Share of album revenue |
|---|---|---|---|---|---|---|---|---|
| Lull 1 (10–13) | 300,421 | 50,334 | 16.8% | $17.35 | $2.91 | $873,249 | $3,492,995 | 10% |
| Burst 1 (16–19) | 301,944 | 47,615 | 15.8% | $16.41 | $2.59 | $781,517 | $3,126,068 | 9% |
| Middle (20–25) | 299,882 | 49,066 | 16.4% | $17.24 | $2.82 | $845,784 | $5,074,707 | 14% |
| Lull 2 (27–31) | 294,678 | 50,748 | 17.2% | $18.41 | $3.17 | $934,196 | $4,670,982 | 13% |
| Burst 2 (32–35) | 289,214 | 48,286 | 16.7% | $19.05 | $3.18 | $919,932 | $3,679,727 | 10% |

- **Fact (burst 1 vs lull 1):** same active payers (+1%), revenue per day −11% (−$91,732 a day, about −$366,900 over the 4 days). The drop is half fewer buyers (−5%, 2,719 fewer a day) and half less per buyer (ARPPU −5%). Not more buyers.
- Same burst vs the middle days (20–25): revenue per day −8%, buyers −3%, ARPPU −5%.
- In burst 1 the economy is richer at the same time: payout 63% vs 53% (+20%), median balance 4.2 vs 3.3 (+24%, Mixpanel "coins in allowance" units).
- Burst 2 does not show this (revenue per day $919,932, close to lull 2), and its payout is not high (57%).

### Who falls behind and what they are worth (end status on close−1)
| End status | Players | % of payers | Album revenue | % of album revenue | Held day 9 | Day 13 | Day 26 | Day 31 |
|---|---|---|---|---|---|---|---|---|
| Finished | 13,185 | 4% | $6,754,161 | 18% | 61 | 67 | 117 | 127 |
| 1 missing | 7,146 | 2% | $2,835,778 | 8% | 60 | 66 | 116 | 125 |
| 2–3 missing | 42,347 | 13% | $11,172,092 | 31% | 59 | 64 | 115 | 126 |
| 4+ missing | 263,164 | 81% | $15,751,437 | 43% | 51 | 55 | 100 | 109 |

- **Fact:** the payers who end 4+ away are 81% of payers and 43% of album revenue ($15,751,437).
- **Fact:** their gap to finishers: 10 stickers on day 9, 12 on day 13, 17 on day 26, 18 on day 31. The gap grows +1 in lull 1, +5 in days 14–26 (burst 1 and the middle), +1 in lull 2.
- **Interpretation:** in the lulls nobody gets much, so the gap stays; it opens when the flow comes back — the more active players take more of the wave. "Not keeping up" happens in the bursts, and the lulls leave less time to catch up before the end.
- Correlation only; one album; event mix in the windows is not the same.
