# Post-album events for finishers — results (2026-10-19, run approved by Eden)

## Bottom line (Dice, 2026-10-19)
Conclusion: the Dice album grand prize fits the wrong players. For light/mid veterans it is too big (4-8 days of their own play), so they live off the stock and come back to buying slowly. For top payers it is small (1.5-2 days of play), so they burn it fast and come back to buying at their normal pace.
Evidence chain (descriptive, no control group):
1. Dice is the only game where finishers come back to buying below their own habit (bought by day 7 vs habit: Dice -1.6 / -5.1 pts, Domino -0.9 / +3.6, Disney +0.1 / +3.9; album 63 clear, album 61 weak).
2. The slow group = Light + Mid payers with a 100K-200K prize ("veterans with an oversized prize"): 47% of payer finishers, 8.4% of album revenue (album 63). Their prize = 4-8 days of play; bought by day 7 -7 to -12 pts, spend days 1-7 18-33% below habit. Same-spend players with a small prize are near habit.
3. The fast group = High + Top payers: prize = 1.5-2 days of play, buy at habit whatever the prize code (spend in money: album 63 Top code 7 = 0.83 of habit).
Recommendations:
A. Test a bigger prize for stable top payers (grand-prize proposal, tiers 250K / 350K). Size it by the player's own daily rolls, keep it at about 2-3 days of play.
B. (Rejected by Eden 2026-10-19: Split prize / Grand Prize Rush. Not interesting; no replacement chosen yet.)
4. Post-album events (Domino Deluxe, Disney Legendary) do NOT explain why Dice is slower. Dice's gap sits in players who finish on the close day or the day before (~48-50% of Dice payer finishers). In Domino / Disney those players get no event spend and still buy at habit; in Dice they are 3-11 pts below. The events carry the spend of players who finish 2+ days early (Dice players in that group also buy at about habit, without a paid event). See "Do post-album events bring players back faster?" at the end.
Open bias: veterans in Light/Mid may be in a spending decline; the tests will settle it.

Question: after a player completes the album, what happens until the next album opens (close day = next album day 1), and how much of it does the post-album event reach?
Events: Domino = Deluxe (prod_50_reporting.user_deluxe_album_last_state); Dice = finisher Fortune Wheel + Lava Quest (Eden: "Momentum Quest" = Lava Quest; participation = got a resource from the campaign, 40_mart.fact_dynamic_resource_given); Disney = Legendary = 1-set / 12-sticker Magic event (bi_prod.user_magic_event_last_state, ids 43560 / 50303).
Population: standard (not first album, login ratio >= 0.5 on last row before close, not special / excluded / cheater). Finisher = 144 unique set stickers before close (close day excluded).
Denominator for every revenue share = album revenue of the standard population (album-table spend, album start to close-1).
Window spend = album-table spend from the day after completion to close-1. Event spend = Deluxe spend from Deluxe start (Domino) / magic_spent_lt (Disney); none in Dice (no purchases are tagged to the finisher campaigns).
SQL: claude/post_album_events_queries.sql. Scans: Domino 16.4 GB, Dice 18.2 GB, Disney 22.0 GB.

| Game / album | Finishers | % players | % payers | Finishers' rev share | >=1 full day after completion | Avg full days | Event participants (% of finishers) | Participants' rev share | Window spend % album rev | Event spend % album rev |
|---|---|---|---|---|---|---|---|---|---|---|
| Domino 17 | 9,011 | 2.0% | 5.7% | 29.2% | 58% | 1.93 | 5,667 (63%) | 16.1% | 2.61% | 1.64% |
| Domino 19 | 7,270 | 2.1% | 4.5% | 22.5% | 37% | 0.59 | 10,581 (see note) | 27.2% | 0.76% | 1.25% |
| Domino 20 | 15,091 | 4.8% | 8.0% | 30.7% | 65% | 1.09 | 18,083 (see note) | 34.7% | 1.38% | 2.07% |
| Dice 61 | 15,203 | 3.3% | 8.1% | 23.0% | 62% | 1.09 | 15,063 (99%) | 22.8% | 0.91% | – |
| Dice 63 | 19,173 | 4.3% | 10.4% | 27.7% | 61% | 1.21 | 19,116 (100%) | 27.6% | 0.99% | – |
| Disney 14 | 15,083 | 1.3% | 3.8% | 16.6% | 34% | 0.45 | 14,981 (99%) | 16.5% | 0.28% | 0.59% |
| Disney 15 | 13,924 | 1.3% | 4.1% | 18.5% | 41% | 0.51 | 13,878 (100%) | 18.5% | 0.35% | 0.78% |

Dice detail: Fortune Wheel reached 98.5% (61) / 99.6% (63) of finishers. Finisher Lava Quest: album 61 = 92025 220726_LavaQuest_Generic_Lavaquest (11,699 finishers, 77%); album 63 = 93756 030926_TopLayer_SwampSprint_LavaQuest (9,119 finishers of 9,999 in population, ~48% of finishers). 93565 / 93561 / 93520 are general Lava Quests (few finishers; 93520 none after completion). 92120 Vertical Quest (album 61 only) reached 94.6%.
Disney detail: Legendary finishers with >=1 sticker 94% / 97%; completed Legendary 6% / 12%.

## Open (needs check before slides)
- Event entrants who are NOT finishers by the 144 rule: Domino 19 / 20 Deluxe entrants exceed finishers (10,581 vs 7,270; 18,083 vs 15,091); Disney 8,087 / 5,912 Legendary entrants in the population are non-finishers; Dice 5,083 / 6,212 got the finisher Fortune Wheel without being finishers. Hypothesis: they completed on the close day (excluded) or have the game finish flag with < 144 by our sticker sum. Diagnostic queries dry-run: Disney 0.81 GB, Domino 0.55 GB (not run yet).
- Event spend > window spend in Domino 19/20 and Disney: event spend likely includes the completion day and/or the close day, which the window excludes.
- Descriptive only: no comparison group. Causal evidence exists only for Disney (T113: DiD revenue +15.85% during Legendary, +0.91% whole period, -0.2% two weeks after).
- Domino Deluxe has an eligibility cut-off (Deluxe Hour To Album End Eligibility, Confluence): late finishers do not get Deluxe. Possible reason only 63% of album 17 finishers entered (not checked).

## Diagnostic (run 2026-10-19): who are the event entrants that are not "finishers"?
All entrants (not limited to the standard population), status on the last full day and on the close day:
| | Entrants | 144 before close | Game flag finished, < 144 by our sum | Finished ON the close day | Not finished |
|---|---|---|---|---|---|
| Disney 14 Legendary | 26,546 | 17,383 | 1,842 | 7,258 | 63 |
| Disney 15 Legendary | 22,950 | 16,223 | 1,884 | 4,783 | 60 |
| Domino 17 Deluxe | 7,285 | 5,838 | 120 | 1,306 | 21 |
| Domino 19 Deluxe | 12,678 | 8,691 | 445 | 3,499 | 43 |
| Domino 20 Deluxe | 23,342 | 19,585 | 431 | 3,296 | 30 |
Finding: the extra entrants are close-day finishers (Disney 18–27% of entrants, Domino 14–28%) plus game-flag finishers with < 144 by our sticker sum (Disney ~7–8%, Domino 1–4%). Our deck-wide finisher rule (144 before close, close day excluded) leaves out close-day finishers. Decision needed from Eden on the finisher definition.

## Recovery after completion (run 2026-10-19, Eden approved)
Question (Eden): after completion, how fast does the finisher go back to his own habit in play, balance and purchase? Is one game faster? Is there a bias (e.g. Dice players invested more at the end)?
Population: payer finishers (album revenue > 0) in the standard population. Finisher = 144 unique set stickers by END of close day (Eden: "144"); Dice also user_album_finish_ts, Domino / Disney also album_finished_flag. This adds close-day finishers, so counts are higher than the event table above.
Habit = close-18 .. close-5 (14 days, end of album excluded). Day 0 = completion day.
- Play back by day k = share with a day in 1..k with play >= 80% of habit daily play. Play = Dice rolls out; Domino coins spent (allowance); Disney levels played (all modes). Each game vs its own habit.
- Bought by day k = share with a purchase day in 1..k. Expected = average of 1-(1-p)^k, p = habit pay-day rate (14 days).
- Balance back by day k = share with a day in 1..k with balance <= habit average balance.
- Only players observed through day k are counted (numerator and denominator).
SQL: claude/post_album_events_queries.sql (RECOVERY section). Scans: Dice 11.1 GB; Domino 78.1 GB (incl. staging coins-in; estimate before that CTE was 12.9 GB); Disney 29.2 GB (no staging coins-in).

| Game / album | Payer finishers | % players | Album rev share | Play back d1 / d3 / d7 | Bought vs expected d7 | Bought vs expected d14 | Balance back d1 / d3 / d7 | Median balance day 1 vs habit |
|---|---|---|---|---|---|---|---|---|
| Dice 61 | 19,087 | 4.2% | 28.8% | .68 / .87 / .95 | .651 vs .667 | .760 vs .769 | .37 / .71 / .89 | 1.97x |
| Dice 63 | 24,845 | 5.5% | 33.8% | .66 / .87 / .94 | .650 vs .701 | .766 vs .803 | .34 / .68 / .88 | 2.26x |
| Domino 19 | 7,361 | 2.1% | 27.2% | .49 / .69 / .86 | .700 vs .709 | .821 vs .794 | .57 / .84 / .95 | 0.62x |
| Domino 20 | 10,263 | 3.2% | 34.7% | .63 / .84 / .95 | .707 vs .671 | n/a (~7 days data) | .48 / .78 / .93 | 0.97x |
| Disney 14 | 21,343 | 1.8% | 22.7% | .54 / .71 / .91 | .751 vs .750 | .844 vs .838 | .42 / .72 / .89 | 1.32x |
| Disney 15 | 18,839 | 1.7% | 24.6% | .62 / .82 / .95 | .770 vs .731 | .866 vs .818 | .42 / .72 / .89 | 1.35x |
Free inflow on completion day vs habit day: Dice 13.3x / 10.2x (rolls); Domino 6.1x / 8.0x (coins, staging). Disney not measured (staging split = 190 GB, not run).

Bias check — bought minus expected at day 7 (points), same segment across games:
| Segment | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 |
|---|---|---|---|
| All payer finishers | -1.6 / -5.1 | -0.9 / +3.6 | +0.1 / +3.9 |
| Finished on close day | -8.1 / -11.0 | -4.2 / -1.4 | -0.3 / +0.8 |
| $20+ per active day (habit) | -7.4 / -7.9 | -4.0 / -3.8 | -4.9 / -4.8 |
| End lift 3x+ (day 14 for Dice) | d14: -9.5 / -11.6 | -1.7 / +4.8 | +3.8 / +7.1 (d14 -1.4 / +0.7) |
| End lift < 1.5x | not kept | -12.0 / -11.5 | -10.1 / -8.7 |
Segment sizes: Dice close day 17.8% / 16.5% of payer finishers (rev share 3.6% / 3.8%); end lift 3x+ 38.7% / 36.6%; $20+ rev share 13.7% / 15.4%. Domino close day 24.0% / 15.2%; $20+ rev share 16.0% / 18.8%. Disney close day 27.1% / 21.6% (rev share 4.5% / 4.0%); end lift 3x+ 27.6% / 30.2% (rev share 3.7% / 4.3%); $20+ 14.9% / 16.5% (rev share 12.2% / 13.8%).

Facts:
- Play: all three games are back to habit play for ~90-95% of payer finishers by day 7. Dice is fastest on day 1 (.66-.68 vs .49-.63).
- Balance: Dice finishers start the next days with ~2x their habit roll balance; Disney ~1.3x; Domino at or below habit (0.6-1.0x).
- Purchase: Disney and Domino are at or above the habit pace by day 7; Dice is at or below it (-2 to -5 points), and the gap is larger inside comparable segments (close-day finishers, $20+, end lift 3x+).
Interpretation (not causal): the Dice gap is not only a mix effect (more end spenders in Dice), since it appears within the same segments. 
Hypothesis: the large roll stock after completion (2x habit balance) lets Dice finishers play without buying for a few days. Not tested.
Caveats: "expected" uses the player's own 14-day rate, so segments built on habit spend (end lift, tier) carry regression to the mean — compare the same segment across games, not segments within a game. Day 1 after completion is often the new album's first day. Play units differ by game (each vs own habit). Domino 20 has ~7 days of data. Disney is gross revenue from daily metrics, Dice revenues_sum, Domino in-app + stripe.
Not usable: balance-source split (>= 50% bought inflow) — 99%+ of players are "mostly free" in Dice and Domino. Needs a relative cut (e.g. top quartile of bought share).

Dice spend while finisher campaigns were live (Eden: all purchases while the campaign was live for the player; daily grain, includes same-day purchases before completion):
- Finishers before close: 61 = $812,991 = 4.79% of album revenue (avg 3.03 live days); 63 = $1,056,784 = 5.08% (3.17 days).
- FW recipients not in the "before close" group (likely close-day finishers): 61 = 5,126 players, $204,708 = 1.21%; 63 = 6,213 players, $232,931 = 1.12%.

Open: (1) Disney coins-in split (190 GB) — run or skip? (2) bal_source threshold. (3) The deck's finisher slides use "144 before close"; with "144 by end of close day" finisher counts and revenue shares go up (Dice 61: 23.0% -> 28.8% for payers incl. close day) — slides need a recount.

## Prize burn, out-of-rolls / OOC and album segment (run 2026-10-19, Eden approved)
Same population and habit window as the recovery section. SQL: claude/finisher_prize_burn_queries.sql. Scans: Dice 11.9 GB, Domino 14.0 GB, Disney 30.7 GB.
- Burned by day k = balance back at or below the balance before completion (last balance on days -3..-1). Dice = start-of-day rolls (mtx day); Domino / Disney = end-of-day coins.
- OOR/OOC day: Dice not_enough_rolls_count > 0 (Eden's choice); Domino ooc_today_flag; Disney out_of_coins_counter > 0 (not checked against the Avo 'not enough coins' event).
- Expected = from the player's own habit-day rate (14 days). Spend ratio d1-7 = revenue days 1-7 / (habit revenue per day x 7).
- Domino 20: only ~7 days of data; its day-14 and "before burn / after OOC" columns are not usable.

| Game / album | Payer finishers | Rev share | Balance after vs before | Burned d1 / d3 / d7 / d14 | OOC d1 / d3 / d7 (expected d7) | Habit OOC-day rate | Buyers whose 1st buy was on/after 1st OOC day | Buyers who bought before burn | Play pace d1-7 | Bought d7 vs exp | Spend ratio d1-7 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Dice 61 | 19,087 | 28.8% | 2.2x (start day 1) | .35/.62/.79/.87 | .60/.81/.91 (.95) | .77 | .85 | .39 | 1.13 | .651 vs .667 | 1.00 |
| Dice 63 | 24,845 | 33.8% | 2.9x | .32/.58/.79/.88 | .57/.77/.89 (.95) | .75 | .81 | .41 | 1.09 | .650 vs .701 | 0.85 |
| Domino 19 | 7,361 | 27.2% | 5.7x (end day 0) | .42/.67/.82/.90 | .51/.77/.89 (.91) | .63 | .84 | .36 | 0.92 | .700 vs .709 | 1.02 |
| Domino 20 | 10,263 | 34.7% | 7.3x | .39/.65/.82/– | .48/.74/.87 (.90) | .63 | – | – | 1.65 | .707 vs .671 | 1.03 |
| Disney 14 | 21,343 | 22.7% | 6.6x | .36/.61/.79/.88 | .29/.51/.69 (.73) | .44 | .53 | .40 | 0.82 | .751 vs .750 | 1.10 |
| Disney 15 | 18,839 | 24.6% | 4.1x | .40/.65/.82/.90 | .28/.50/.67 (.73) | .45 | .50 | .39 | 1.02 | .770 vs .731 | 1.02 |

Album segment:
| Segment | n (61 / 63) | % payer finishers | Rev share | Bought d7 vs exp (pts) | Spend ratio d1-7 |
|---|---|---|---|---|---|
| Dice Easy | 8,722 / 10,553 | 46% / 42% | 4.4% / 5.3% | -2.1 / -6.8 | 1.06 / 0.88 |
| Dice Medium | 6,424 / 8,661 | 34% / 35% | 6.8% / 8.1% | -2.0 / -5.6 | 0.97 / 0.80 |
| Dice Hard | 2,478 / 3,527 | 13% / 14% | 5.9% / 7.0% | -0.4 / -0.7 | 1.02 / 0.89 |
| Dice Extreme | 1,463 / 2,104 | 8% / 8% | 11.8% / 13.4% | +1.1 / -2.0 | 0.98 / 0.84 |
| Domino easy (19 / 20) | 4,708 / 7,446 | 64% / 73% | 6.8% / 11.9% | -0.9 / +4.0 | 1.16 / 1.09 |
| Domino hard (19 / 20) | 2,653 / 2,817 | 36% / 27% | 20.4% / 22.8% | -0.9 / +2.9 | 0.97 / 1.00 |
| Disney | all rows = 'def_default' | – | – | no segment split available | – |
Domino segment labels in the table: def_album14_easy/hard (album 19), def_album15_easy/hard (album 20).

Dice reward code (prize 25K -> 200K rolls), album 61 / 63:
| Code | % payer finishers | Rev share | OOR by d1 | Burned d1 | Bought d7 vs exp (pts) | Buyers 1st buy on/after OOR |
|---|---|---|---|---|---|---|
| 1 (25K) | 8.8% / 7.8% | 1.0% / 1.2% | .73 / .68 | .39 / .38 | +3.3 / -3.6 | .91 / .90 |
| 3 (65K) | 16.4% / 16.0% | 3.0% / 3.3% | .65 / .62 | .39 / .36 | 0.0 / -2.9 | .87 / .85 |
| 5 (125K) | 11.8% / 12.5% | 2.6% / 3.3% | .60 / .57 | .34 / .33 | -0.7 / -6.9 | .85 / .83 |
| 7 (200K) | 28.3% / 30.4% | 15.3% / 18.1% | .51 / .49 | .31 / .29 | -2.9 / -6.2 | .79 / .75 |
Dice prize in habit days (prize / habit rolls out per day): <3 days 45% / 56% of payer finishers (rev share 21% / 27%), bought d7 -8.4 / -9.6 pts, spend ratio 0.87 / 0.79; 3-7 days -1.5 / -2.7, 1.35 / 1.08; 7-14 days +10.8 / +8.0, 2.59 / 1.95. Caveat: this split is built on habit play, so it carries regression to the mean (low-habit players look like they "recover above habit"). Do not read it as an effect of prize size.

Facts:
- Prize burn speed is about the same in all three games: ~60-65% are back at their pre-completion balance by day 3, ~80% by day 7.
- Day 1 after completion fewer players hit OOR/OOC than on a normal habit day (Dice .57-.60 vs .75-.77 daily habit; Domino .48-.51 vs .63; Disney .28-.29 vs .44). By day 7 it is 2-6 pts below the habit-based expectation in every game.
- About 60% of the buyers in the first 14 days waited until the stock was burned (Dice, Domino 19, Disney alike).
- In Dice the bigger the prize code, the later the first OOR (day-1 OOR .73 -> .51 / .68 -> .49) and the later the burn.
- Dice purchase gap sits in Easy / Medium (about 77-80% of payer finishers, 11-13% of album revenue). Hard / Extreme are at habit in "who bought". In money, album 63 is 11-20% below habit in every segment; album 61 is at habit.
- Domino: no segment is slower. Disney: no segment field.
Interpretation (not causal): the "stock delays OOC" pattern exists in all three games at a similar speed, so stock alone does not explain why only Dice shows a purchase gap. Within Dice, larger prizes go with later OOR and a somewhat larger purchase gap (clearer in album 63).
Hypothesis (not tested): prize inflation (codes only ratchet up) makes the post-completion stock bigger each album, which could explain why 63 is weaker than 61.

Eden (2026-10-19): "album segment" in this question = the Dice final-prize segment (album_reward_code 1-7), not the Easy/Medium/Hard/Extreme difficulty segment.
Dice by reward code, album 61 / 63 (bought d7 vs habit-expected, pts; spend ratio d1-7):
| Code (prize) | % payer finishers | Rev share | Balance day 1 vs before | OOR by d1 | Burned d3 | Bought d7 vs exp | Spend ratio |
|---|---|---|---|---|---|---|---|
| 1 (25K) | 8.8 / 7.8 | 1.0 / 1.2 | 1.5x / 1.7x | .73 / .68 | .65 / .62 | +3.3 / -3.6 | 1.19 / 1.06 |
| 2 (40K) | 11.3 / 9.5 | 1.8 / 2.0 | 1.8x / 2.0x | .67 / .65 | .65 / .61 | -1.8 / -3.1 | 1.06 / 0.90 |
| 3 (65K) | 16.4 / 16.0 | 3.0 / 3.3 | 1.7x / 2.1x | .65 / .62 | .65 / .63 | 0.0 / -2.9 | 1.06 / 0.98 |
| 4 (100K) | 14.5 / 14.9 | 2.8 / 3.5 | 2.5x / 3.2x | .62 / .57 | .63 / .58 | -3.1 / -5.3 | 1.03 / 0.88 |
| 5 (125K) | 11.8 / 12.5 | 2.6 / 3.3 | 2.7x / 3.5x | .60 / .57 | .61 / .58 | -0.7 / -6.9 | 0.99 / 0.82 |
| 6 (150K) | 8.9 / 8.8 | 2.2 / 2.5 | 3.6x / 3.9x | .55 / .54 | .59 / .58 | -3.8 / -5.4 | 0.91 / 0.85 |
| 7 (200K) | 28.3 / 30.4 | 15.3 / 18.1 | 4.0x / 4.9x | .51 / .49 | .58 / .55 | -2.9 / -6.2 | 0.98 / 0.80 |
Album 63: codes 4-7 = 67% of payer finishers, 27.3% of album revenue, -5 to -7 pts and 12-20% less spend in days 1-7; codes 1-3 = 33%, 6.5% of album revenue, about -3 pts. Album 61: no clear step by code (-4 to +3 pts).
Caveat: the reward code is set from spend history (ladder that only goes up), so higher codes are also stronger payers. Expected values are per player, which controls for habit level, but this is still descriptive.

## Dice: prize code inside the same difficulty segment (run 2026-10-19, 11.9 GB; SQL claude/prize_within_segment_dice.sql)
Gap = bought by d7 minus habit-expected (pts). Spend = revenue d1-7 / habit x 7. Habit $/day = median habit revenue per day (strength check). Cells < 300 players left out.
| Album 63 | Code 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| Easy n | 1,938 | 1,517 | 1,888 | 1,639 | 1,178 | 797 | 1,596 |
| Easy habit $/day | 1.21 | 0.93 | 1.17 | 1.04 | 1.17 | 1.28 | 1.43 |
| Easy balance d1 vs before | 1.8x | 2.7x | 2.8x | 3.8x | 4.4x | 5.7x | 7.1x |
| Easy OOR by d1 | .68 | .64 | .59 | .54 | .53 | .52 | .44 |
| Easy gap d7 | -3.6 | -3.0 | -4.8 | -7.3 | -9.6 | -12.0 | -11.0 |
| Easy spend d1-7 | 1.06 | 0.96 | 0.89 | 0.76 | 0.84 | 0.82 | 0.72 |
| Medium n | – | 720 | 1,581 | 1,444 | 1,304 | 937 | 2,675 |
| Medium habit $/day | – | 2.90 | 2.57 | 2.89 | 2.97 | 2.85 | 3.57 |
| Medium balance d1 vs before | – | 1.6x | 2.1x | 3.0x | 3.0x | 4.3x | 6.5x |
| Medium OOR by d1 | – | .67 | .64 | .58 | .58 | .52 | .47 |
| Medium gap d7 | – | -3.0 | -0.9 | -5.4 | -7.9 | -3.4 | -8.8 |
| Medium spend d1-7 | – | 0.90 | 1.02 | 0.82 | 0.77 | 0.83 | 0.67 |
| Hard gap d7 (n) | – | – | -1.2 (432) | +0.6 (489) | +2.0 (456) | +2.9 (325) | -1.9 (1,725) |
| Hard spend d1-7 | – | – | 1.02 | 1.02 | 0.94 | 0.88 | 0.83 |
| Extreme code 7 (1,563) | gap -1.9, spend 0.83; other Extreme codes < 300 | | | | | | |
Album 61: Easy gap by code 1->7: +3.3, -2.1, -1.2, -5.5, -2.1, -3.5, -7.2 (spend 1.19 -> 0.84-0.97); Medium: -1.2, +1.5, -2.1, -1.1, -5.9, -3.3 (codes 2-7); Hard and Extreme code 7: -1.4 / +0.6.
Size: album 63 Easy + Medium with codes 4-7 = 46.6% of payer finishers, 8.4% of album revenue.
Facts: inside Easy and Medium, habit spend per day is about the same across codes (code 7 is even a bit higher), yet a bigger prize goes with a bigger stock, a later OOR, a bigger purchase gap and lower spend in days 1-7. Clear in album 63, weaker but same direction in album 61. Hard / Extreme buy at habit whatever the code (money drops at codes 6-7 in album 63).
Interpretation: this supports "the prize stock delays purchase" for low/medium payers, more than "stronger players behave differently". Still descriptive.
Remaining bias to keep in mind: a high code inside Easy means a player who spent more in the past and now spends less (the code never goes down). These players may be in a downward trend, which alone could slow the return.

## Who are Easy / Medium? (Dice payer finishers, run 2026-10-19, 16.0 GB; SQL claude/profile_easy_medium_dice.sql)
Segment rule (set at album start): spend in the last album played, normalised to 70 days: Easy < $100, Medium $100-400, Hard $400-1K, Extreme $1K+.
"Prev album" below = album id - 2 (59 for 61, 61 for 63); not always the album the segment was set from.
| Album 63 | Payer finishers | % | Rev share | Median spend this album (real $) | Median spend prev album | Spent > 2x prev album | Was in a higher segment prev album | Finished prev album | Median LTV at start | Median past albums |
|---|---|---|---|---|---|---|---|---|---|---|
| Easy, prize 25K-65K | 5,343 | 21.5% | 2.7% | $56 | $11 | 76% | 13% | 4% | $150 | 7 |
| Easy, prize 100K-200K | 5,210 | 21.0% | 2.6% | $61 | $20 | 65% | 32% | 18% | $1,235 | 16 |
| Medium, prize 25K-65K | 2,301 | 9.3% | 2.3% | $131 | $89 | 25% | 7% | 19% | $317 | 4 |
| Medium, prize 100K-200K | 6,360 | 25.6% | 5.8% | $138 | $101 | 22% | 16% | 32% | $2,062 | 15 |
| Hard, prize 100K-200K | 2,995 | 12.1% | 6.0% | $337 | $301 | 11% | 13% | 35% | $3,304 | 14 |
| Extreme, prize 100K-200K | 1,993 | 8.0% | 13.0% | $929 | $846 | 6% | 0% | 51% | $7,282 | 12 |
Album 61 shows the same picture (Easy 100K+: LTV $1,090, 16 albums, 28% higher segment before; Easy small prize: LTV $130, 7 albums).
Facts:
- Easy = light payers (about $50-60 real in the album). Most of them paid more this album than the album before (65-76% spent over 2x), i.e. they stepped up to finish.
- Inside Easy and Medium there are two different groups with the same spend today:
  - newer light/mid payers with a small prize (LTV $150-320, 4-7 albums);
  - veterans who used to pay more (LTV $1.2K-2K, 15-16 albums, 16-32% were in a higher segment the album before) and kept a big prize because the prize never goes down.
- The slow-return group from the previous section = the second group (Easy + Medium with 100K-200K): 46.6% of payer finishers, 8.4% of album revenue in album 63.
Suggested deck labels (simple English): Easy = "Light payers (< $100 last album)", Medium = "Mid payers ($100-400)", Hard = "High payers ($400-1K)", Extreme = "Top payers ($1K+)". Codes 4-7 inside Light/Mid = "Veterans with an oversized prize".

Link to the grand-prize proposal (dice_album_grand_prize_findings.md / _test_proposal.md, Eden 2026-10-19):
- Supports: top payers burn the prize fast (Extreme code 7: prize = 1.6-1.9 days of their own play) and buy at habit after completion (gap -2 to +1 pts). A bigger prize for them (350K vs ~290K rolls/day for $2K+) stays around 1-1.5 days of play.
- Guardrail from this data: where the prize is about 4-8 days of the player's own play (Light/Mid veterans), the return to purchase is slower (-7 to -12 pts, 18-33% less spend in days 1-7). Size any new prize relative to the player's daily rolls, not only spend.
- Caveat: in money, album 63 Extreme code 7 spent 0.83 of habit in days 1-7 (album 61: 0.98), so "top payers recover fully" holds for who buys, not fully for how much in album 63.
- Group 2 of the proposal (25K -> 100K for $700+ spenders): these players would sit in Hard/Extreme next album, where the prize code showed no purchase delay.

## Where the post-completion roll stock comes from (Dice album 63, days 0-2 after completion; run 2026-10-19, 28.6 GB; SQL claude/stock_sources_dice.sql)
Rolls in per player in days 0-2, in days of the group's own habit play (sum rolls in / sum habit rolls out per day):
| Source | Light/Mid, prize 100K-200K (11,570; 37K rolls/day) | Light/Mid, prize 25K-65K (7,644; 27K/day) | High/Top (5,631; 74K/day) |
|---|---|---|---|
| Album grand prize (album_completed + _with_pixies) | 197K = 3.2 days (29% of inflow) | 58K = 1.5 days (14%) | 225K = 2.2 days (23%) |
| Progress bar v2 | 1.4 days | 1.6 days | 1.1 days |
| Core wager (joker, card-rolls, shields payback) | 2.3 days | 2.1 days | 1.9 days |
| Fortune Wheel (finisher) | 0.3 days | 0.35 days | 0.24 days |
| Trail final reward | 0.3 days | 0.3 days | 0.3 days |
| All rolls in, days 0-2 | 691K = 11.4 days | 409K = 10.6 days | 963K = 9.3 days |
Fact: the only source that separates the slow group from the others is the grand prize (+1.7 days of play vs same-spend players with a small prize). Post-album events (Fortune Wheel, Trail) add little.

## Test idea for the slow group — REJECTED by Eden 2026-10-19 (kept for record). Earlier: the "offer at Not Enough Rolls" idea is not interesting; needs a test that makes them burn rolls faster / come back faster
Population: Dice payer finishers, Light/Mid segment (Easy/Medium) with prize code 4-7. Album 63: 47% of payer finishers, 8.4% of album revenue.
Note: play is not the problem (play pace d1-7 is 1.04-1.29 of habit). The gap is purchase: the stock covers days of play, so buying waits.
Arms (randomised at album start, 1/3 each):
- Control: grand prize as today, all at completion.
- A "Split prize": same total prize; 50% at completion, 50% unlocked on day 1 of the next album (claimed in the first 48h). Halves the stock in the gap and gives a reason to open the next album on day 1. Keeps "never less" (same value).
- B "Grand Prize Rush": prize as today + a 72h post-completion event. Rolls spent (weighted by bet multiplier) unlock a head start for the next album (packs / stickers / a joker), not rolls. Turns the stock into next-album progress and rewards higher bets.
Metrics: primary = revenue per player from completion to day 7 of the next album (catches pull-forward). Secondary = days to first Not Enough Rolls, rolls out per day d1-7, bought by d7, next-album day-1 login, next-album spend and finish rate. Cost = rolls / packs given vs control.
Rough size (estimate, not data): this group spends at 0.72-0.83 of habit in days 1-7; closing the gap is worth very roughly $40K-100K per album. The bigger value, if any, is next-album start.
Open: whether a split prize or a head-start reward can be built in the current album tech; whether "never less" is about value or about the number shown.


## Do post-album events bring players back faster? (Eden 2026-10-19; Domino Deluxe / Disney Legendary vs Dice)
Same population and definitions as the recovery section (payer finishers, habit = close-18..close-5, day 0 = completion). "Excl. event" = event spend removed from days 1-7; a purchase day counts only if non-event revenue that day > $0.01.
Event spend: Domino prod_40_mart.user_daily_deluxe_album (deluxe_album_spent_today; joined = deluxe_activity_flag or spend); Disney bi_prod.user_daily_magic_event, ids 43560 / 50303 (magic_spent_today; joined = magic_stickers_today > 0 or spend). Dice has no paid finisher event (Fortune Wheel / Lava give rolls).
SQL: claude/event_effect_domino.sql, claude/event_effect_disney.sql, claude/timing_reference_dice.sql (Dice 8.7 GB).

All payer finishers:
| Game / album | Bought d7 vs exp (pts) | Excl. event | Spend d1-7 vs habit | Excl. event | Event share of d1-7 revenue |
|---|---|---|---|---|---|
| Dice 61 / 63 | -1.6 / -5.1 | (no event) | 1.00 / 0.85 | – | – |
| Domino 19 / 20 | -0.9 / +3.6 | -5.4 / -5.6 | 1.02 / 1.03 | 0.78 / 0.71 | 23.5% / 31.4% |
| Disney 14 / 15 | +0.1 / +3.9 | -1.7 / +0.3 | 1.10 / 1.02 | 0.98 / 0.86 | 10.9% / 15.1% |

By finish timing (bought d7 vs exp, pts; spend d1-7 vs habit). Domino / Disney rows = event joiners (Domino 99-100% of finishers; Disney 91-94%):
| Timing | Dice 61 / 63 | Domino 19 / 20 (total -> excl. event) | Disney 14 / 15 (total -> excl. event) |
|---|---|---|---|
| Close day | -8.1 / -11.0; 0.96 / 0.73 | -4.0 / -1.5; 1.01 / 0.94 (no event spend) | +0.2 / +0.7; 1.07 / 0.98 (no event spend) |
| Day before close | -2.6 / -7.5; 1.05 / 0.80 | -1.1 / +4.4 -> -3.2 / +1.4; 1.02 / 1.10 -> 0.97 / 1.03 | +0.2 / +4.0 -> -0.7 / +2.0; 1.10 / 1.00 -> 1.06 / 0.93 |
| 2-3 days before | +2.0 / -2.6; 1.06 / 0.89 | +2.0 / +5.1 -> -7.6 / -7.2; 1.09 / 1.04 -> 0.77 / 0.70 | +0.8 / +5.9 -> -4.6 / -2.1; 1.14 / 1.06 -> 0.87 / 0.76 |
| 4+ days before | -1.9 / +0.8; 0.86 / 0.89 | +0.2 / +2.9 -> -18.3 / -19.9; 0.89 / 1.00 -> 0.35 / 0.43 | n = 132 / 141 (too small) |
Shares of payer finishers: Dice close day 17.8% / 16.5%, day before 31.9% / 31.5%, 2-3 days 40.4% / 38.6%, 4+ 9.9% / 13.4%. Domino 19 / 20: 23-24% / 15%, 43% / 26%, 28% / 46%, 5% / 13%. Disney 14 / 15 (joiners): 21% / 18%, 44% / 44%, 25% / 32%, <1%.

Facts:
- Event spend sits almost only in players who finish 2+ days before close (24-60% of their days 1-7 revenue). Close-day finishers have none; day-before finishers 4-7%.
- Without event spend, early finishers in Domino / Disney would be below Dice early finishers (spend 0.70-0.87 vs Dice 0.89-1.06).
- Close-day and day-before finishers: Dice is clearly below habit (-3 to -11 pts, spend 0.73-1.05); Domino and Disney are at about habit with no event spend.
Interpretation (not causal): the events capture the spend of early finishers in the gap until the next album. They do not explain the Dice gap, which is in late finishers where the other games have no event either. This fits the earlier finding that the Dice gap is driven by the post-completion roll stock (grand prize).
Causal evidence: only Disney T113 (Legendary): revenue +15.85% during the event, -0.2% in the two weeks after (no payback dip). So at least in Disney the event spend is mostly incremental, not moved from other days.
Caveats: "excl. event" assumes no cannibalisation, so it is the most the event can be worth; true incremental value is lower (T113 suggests most of it is real for Disney). Play units and play pace are not comparable across games. Domino 20 has ~7 days of data.
Hypothesis (not tested): a paid post-album event in Dice would add revenue from early finishers (about half of payer finishers, who already buy at habit), but would not fix the slow return of late finishers with a big prize.

## Deluxe eligibility cut-off as a natural experiment (Eden "כן תריץ", 2026-10-19) — NOT usable
Idea: Deluxe has an ACX cut-off ("Deluxe Hour To Album End Eligibility": finish within X hours of album end = no Deluxe). Compare finishers just before vs just after it.
SQL: claude/deluxe_cutoff_domino.sql (32.5 GB). Domino 17 / 19 / 20, payer finishers, finish time = timestamp of the last first-receipt set sticker, 6-hour buckets from 72 h before to 24 h after 00:00 UTC of the close date. Entered = row in prod_50_reporting.user_deluxe_album_last_state.
Result: there is no step in Deluxe entry by finish time.
- Albums 19 / 20: 99–100% of payer finishers have a Deluxe row in every bucket, including those who finished on the close day. Either the cut-off is 0 or not set, or the table records entry even when there is no time left.
- Album 17: 44–54% in every bucket, flat. The split is not about time. Likely the Pixie / bonus-set rule (Deluxe starts only after those are completed); not confirmed.
- Deluxe share of days 0–7 revenue falls smoothly with finish time (album 20: 39% at 72 h before close → 1% on the close day), the same pattern as the timing table above.
Re-check (after Eden shared the Deluxe Album Economy dashboard; entry = activity in prod_40_mart.user_daily_deluxe_album, the dashboard's source table): same picture with every definition. Albums 19 / 20: deluxe_activity_flag and "got a Deluxe sticker" 97–100% in every bucket up to 6 h after the close date starts (Deluxe stickers come partly from the automatic retro upgrade of duplicates, so they do not prove play). Album 17: 44–54% flat, then 10% active in the last bucket. "Paid in Deluxe" falls smoothly with finish time (album 20: 68% at 72 h before → 4% after close; album 19: 85% → 7%), no step.
Conclusion: no players who were similar but "just missed" Deluxe, so this route cannot prove incrementality. Causal evidence for post-album events remains Disney T113 only. A Domino holdout (Deluxe off for a random share of finishers) would be the clean test.

## Deluxe before vs after launch — difference-in-differences (Eden 2026-10-19: "what can we say about Deluxe that proves it is good?")
SQL: claude/deluxe_did_domino.sql (31.1 GB). Domino payer finishers, standard population. Early = finished 2+ days before close (Deluxe has days to run); late = close day or day before (Deluxe barely reaches them: 2–4% of their days 1–7 revenue). Pre = albums 15, 16 (no Deluxe rows); post = 19, 20 (99–100% have Deluxe); 17 = half of finishers in Deluxe. Gap = bought d1–7 minus habit-expected (pts); spend = revenue d1–7 / habit week.
| Album | Early: n / % payers / rev share | Early gap / spend | Late gap / spend | Early − late: gap / spend | Deluxe share of early d1–7 rev |
|---|---|---|---|---|---|
| 15 (pre) | 10,029 / 8.4% / 34.6% | −11.3 / 0.85 | −9.9 / 0.92 | −1.4 / −0.07 | 0 |
| 16 (pre) | 10,393 / 7.5% / 30.5% | −4.1 / 0.93 | −3.2 / 1.01 | −0.9 / −0.08 | 0 |
| 17 (half) | 4,913 / 3.6% / 23.3% | −7.8 / 0.92 | −9.0 / 0.93 | +1.2 / −0.01 | 32% |
| 19 (post) | 2,435 / 2.1% / 14.6% | +1.6 / 1.01 | −2.1 / 1.02 | +3.7 / −0.01 | 40% |
| 20 (post) | 6,064 / 5.7% / 24.4% | +4.6 / 1.03 | +2.3 / 1.05 | +2.3 / −0.02 | 42% |
DiD (19/20 vs 15/16): buyers in days 1–7 +4.2 pts; spend days 1–7 +0.06 of habit (early finishers went from 7–8% below late finishers to about equal). Days 1–14 (album 20 not yet observable): early − late −0.15 / −0.14 (15/16) vs −0.05 (17, 19) → +0.09, so no payback dip in the second week.
Reading (quasi-experimental, not a test): after Deluxe launched, early finishers' week after completion improved relative to late finishers, and the gain held over 14 days. Size vs Deluxe spend: Deluxe ≈ 0.41 of habit week for early finishers, net gain ≈ 0.06 → roughly 15% of Deluxe spend looks added, the rest likely moved from purchases they would have made anyway (estimate).
Caveats: album 17 shows a similar early−late shift with only half of finishers in Deluxe, so part of the change may be other differences between albums (season, end design, early-finisher mix: 67% of payer finishers in 15/16 vs 33–59% after). Two pre and two post albums. A holdout test is still the only proof.
