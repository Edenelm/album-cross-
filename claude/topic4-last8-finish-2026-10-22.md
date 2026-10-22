# Topic 4: who reaches the last stickers in the last 8 days, and how many finish (2026-10-22)

**Question (Eden):** payers who got within 1–3 / 4–6 / 7–10 stickers at ANY point in the last 8 days (not only the close−8 cohort) — how many finish? Replaces the base of v82 #26 "half-completions" (close−8 cohort, Domino 17/19, old Dice population).

SQL: `claude/topic4_last8_finish_2026-10-22.sql` (Dice 125.9 GB, Domino 10.9 GB, Disney 22.0 GB).

**Definitions**
- Population: standard (not first album, not excluded, login ratio ≥ 0.5 on the last row before close, row on close−1). Dice "not first album" = a row in an earlier album (fixed rule). Payer = album-table spend > 0 on any album day, close day included.
- Albums: Dice 61/63 (`dice-dreams-dbt`), Domino 19/20 (`domino-dreams-dbt`), Disney 14/15 (`solitaire-dreams-411507`).
- Status on day k before close (k = 8…1) = unique set stickers on the latest daily row on or before that day.
- Band: the player was 1–3 (or 4–6, 7–10) missing on at least one of days 8…1. **Bands overlap** (7 → 5 → 2 counts in all three), so band shares do not add up.
- Entry day = first of days 8…1 in the band; "8" = already there 8 days out or earlier.
- Finisher = 144 by the end of the close day (Dice close day from the sticker table).
- Revenue share = album-table spend start..close−1 ÷ total game purchase revenue during the album (deck denominator).

**Checks (R3):** all-payer finish rates 10 / 12% (Dice), 6 / 10% (Domino), 5 / 5% (Disney) and payer revenue shares 78 / 82%, 77 / 79%, 78 / 81% match the register. Entry-day-8 rate of the 1–3 band (42 / 42%, 53 / 63%, 26 / 24%) reproduces the old close−8 "2–3 missing" numbers (now with 1 missing included).

## Band totals (album A / album B)
| Reached in last 8 days | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 |
|---|---|---|---|
| **1–3 missing** — players | 80,726 / 129,428 | 18,618 / 46,529 | 81,006 / 58,571 |
| share of payers | 41% / 63% | 16% / 44% | 22% / 18% |
| share of game revenue | 50% / 64% | 37% / 58% | 43% / 45% |
| finish rate | **17% / 16%** | **25% / 17%** | **17% / 20%** |
| **4–6 missing** — players | 134,754 / 155,333 | 53,644 / 66,527 | 189,938 / 126,294 |
| share of game revenue | 60% / 68% | 48% / 65% | 47% / 38% |
| finish rate | 11% / 14% | 10% / 12% | 7% / 7% |
| **7–10 missing** — players | 110,411 / 87,612 | 54,067 / 53,776 | 188,087 / 137,416 |
| share of game revenue | 28% / 21% | 25% / 25% | 24% / 20% |
| finish rate | 8% / 9% | 4% / 7% | 3% / 3% |

## 1–3 band: finish rate by when the player got there
| Entered 1–3 | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 |
|---|---|---|---|
| 8+ days out | 42% / 42% | 53% / 63% (204 players in 20) | 26% / 24% |
| 7–5 days out | 36% / 27% | 39% / 31% | 13% / 19% |
| 4–3 days out | 20% / 13% | 27% / 16% | 18% / 20% |
| 2–1 days out | 8% / 7% | 15% / 8% | 13% / 15% |
Per-day rows (entry 1…8) in the query output; sizes: Dice 63 entry 5 = 23,531, Domino 19 entries 4–7 = 738–1,172 (small).

## What it means
- **Fact:** counted this way, about 1 in 6 payers who get within 1–3 stickers finish, in all three games (16–25%). The Disney gap of the old slide (25% vs 42–51%) came from comparing only those already close 8 days out.
- **Fact:** in Dice and Domino, the earlier a payer gets close, the more often they finish: 42–63% from 8+ days out, 27–39% from 7–5, 7–15% from the last 2 days. In Disney the line is almost flat: 13–20% whether they got close 7 or 2 days out; only those close 8+ days out do better (24–26%).
- **Fact:** the near group is large in revenue: payers who got within 1–3 hold 37–64% of game revenue (Disney 43–45%).
- **Interpretation:** in Disney, getting close early does not buy time, which fits the gate and the Joker opening only about 3 days before close (all near payers wait for the same day). Not separated in data (tangled); test 1 arms would separate it.
- **Caveat:** descriptive, no comparison group. Bands overlap. Domino 20 is the easier end (many near players, 58% of game revenue in the 1–3 band).

## Follow-up (Eden): in Disney, did finishers who got close early lift their spend more than those who got close late?
Population: Disney finishers (144 by end of close day) who were 3 or fewer missing on one of days 8…1; entry = first such day. Lift = own $ per active day in the last 4 days before close (close−4..close−1, close day left out) ÷ own $ per active day in days 14–9 (usual week, before the 8-day window). Daily metrics (`solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`). Average per player first, then across players. 33 of 13,504 (album 14) dropped for no activity in a window. SQL: last block of `topic4_last8_finish_2026-10-22.sql` (23.5 GB).

| Got to 3 or fewer | Finishers 14 / 15 | $/active day, usual week | $/active day, last 4 days | Lift (median player) | Finished on the close day |
|---|---|---|---|---|---|
| 8+ days out | 4,161 / 5,649 | $28 / $27 | $34 / $32 | ×1.2 / ×1.2 (1.2 / 1.2) | 20% / 18% |
| 7–5 days out | 4,443 / 1,673 | $8 / $8 | $18 / $23 | ×2.3 / ×2.9 (1.9 / 2.4) | 28% / 24% |
| 4–3 days out | 2,803 / 2,332 | $6 / $6 | $19 / $22 | ×3.1 / ×3.6 (2.8 / 3.1) | 20% / 16% |
| 2–1 days out | 2,064 / 2,154 | $5 / $5 | $11 / $11 | ×2.3 / ×2.3 (2.0 / 2.0) | 59% / 44% |

- **Fact:** no — the early ones lift least (×1.2); those who got close 7–3 days out lift ×2.3–3.6.
- **Fact:** the early ones are a different player: they already spend $27–28 a day in the usual week (×3–5 the others) and still spend the most at the end ($32–34).
- **Interpretation:** early closers got there by spending all along; later closers make a big end push.
- **Caveat:** the usual week (days 14–9) may already include the early group's push to get close, which would understate their lift. A check with an earlier base (e.g. days 21–15) would show it. Descriptive, no comparison group.

### Check with an earlier base (days 21–15 before close), Eden 2026-10-22
Same population and end window; players need activity in all three windows (≤ 8 dropped per row). SQL: "follow-up 2" block (25.8 GB).

| Got to 3 or fewer | $/active day, days 21–15 | days 14–9 | last 4 days | Lift vs 21–15 (median player) | Lift vs 14–9 |
|---|---|---|---|---|---|
| 8+ days out | $24 / $22 | $28 / $27 | $34 / $32 | **×1.4 / ×1.4** (1.4 / 1.6) | ×1.2 / ×1.2 |
| 7–5 days out | $10 / $10 | $8 / $8 | $18 / $23 | ×1.9 / ×2.3 (1.7 / 2.0) | ×2.3 / ×2.9 |
| 4–3 days out | $8 / $8 | $6 / $6 | $19 / $22 | **×2.3 / ×2.9** (2.1 / 2.8) | ×3.1 / ×3.6 |
| 2–1 days out | $6 / $5 | $5 / $5 | $11 / $11 | ×1.8 / ×2.1 (1.7 / 2.0) | ×2.3 / ×2.3 |
(album 14 / album 15)

- **Fact:** the caveat was real in both directions: the early group already raised spend in days 14–9 ($22–24 → $27–28), and the later groups lowered it ($8–10 → $6–8). With the earlier base the gap narrows.
- **Fact:** the answer stays the same: early closers lift least (×1.4); those who got close 4–3 days out lift most (×2.3–2.9).

### When did they finish? (Disney, Eden 2026-10-22)
Same finishers; finish day = first daily row with 144. SQL: "follow-up 3" block (22.0 GB). Album 14 / 15.

| Got to 3 or fewer | Finishers | Finished 7–4 days out | 3 days out | 2 days out | 1 day out | Close day |
|---|---|---|---|---|---|---|
| 8+ days out | 4,162 / 5,651 | 1% / 1% | 8% / 9% | 25% / 29% | 47% / 43% | 20% / 18% |
| 7–5 days out | 4,451 / 1,679 | 0% / 2% | 4% / 9% | 16% / 21% | 52% / 44% | 28% / 24% |
| 4–3 days out | 2,819 / 2,345 | — | 11% / 9% | 34% / 36% | 35% / 40% | 20% / 16% |
| 2–1 days out | 2,072 / 2,164 | — | — | — | 41% / 56% | 59% / 44% |

- **Fact:** players who got to 3 or fewer 8+ days out almost never finished early: 99% finished in the last 3 days or on the close day, like everyone else. They waited about a week with 1–3 missing.
- **Interpretation:** fits the gate (and the Joker) opening about 3 days before close: being close early does not let a Disney player finish early. Whether it is the gate, the Joker or both is not separated in the data.

### Same for Dice and Domino (Eden 2026-10-22)
Same definitions as the Disney follow-ups; SQL: "follow-up 4" blocks (Domino 12.5 GB, Dice 128.1 GB). Finisher counts match the band totals above (e.g. Dice 61: 13,822). Album A / album B.

**When they finished — share of finishers who got to 3 or fewer 8+ days out**
| Finished | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 |
|---|---|---|---|
| 7–4 days out | **37% / 23%** | **18% / 50%** (128 players in 20) | **1% / 1%** |
| 3 days out | 17% / 24% | 17% / 24% | 8% / 9% |
| 2 days out | 20% / 21% | 26% / 14% | 25% / 29% |
| 1 day out | 18% / 23% | 30% / 7% | 47% / 43% |
| close day | 8% / 9% | 9% / 5% | 20% / 18% |
Got there 7–5 days out, finished 7–4 days out: Dice 25% / 20%, Domino 12% / 24%, Disney 0% / 2%.

**Lift vs self (finishers; $ per active day, last 4 days ÷ days 21–15)**
| Got to 3 or fewer | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 |
|---|---|---|---|
| 8+ days out | ×1.5 / ×1.8 ($22 / $19 → $32 / $33) | ×1.4 / ×1.7 ($31 / $23 → $44 / $38) | ×1.4 / ×1.4 ($24 / $22 → $34 / $32) |
| 7–5 days out | ×2.0 / ×2.0 | ×1.7 / ×1.8 | ×1.9 / ×2.3 |
| 4–3 days out | ×2.8 / ×2.6 | ×2.7 / ×2.4 | ×2.3 / ×2.9 |
| 2–1 days out | ×2.3 / ×2.2 | ×2.3 / ×2.0 | ×1.8 / ×2.1 |
Median player gives the same order. Days 14–9 base: early groups ×1.1–1.2 in all games (Domino 20: ×0.8), because their spend already rose in days 14–9.

- **Fact:** in Dice and Domino, players who got close 8+ days out often finish early (Dice 23–37%, Domino 18–50% finished 7–4 days out). In Disney almost none do (1%).
- **Fact:** the spend pattern is the same in all three games: early closers are heavy payers ($19–31 a day before) and lift least (×1.4–1.8); players who got close 4–3 days out lift most (×2.3–2.9).
- **Interpretation:** what differs in Disney is not how players spend but when they can finish: being close early does not let a Disney player finish early.
- **Caveat:** in Dice and Domino part of the early group finished before the last 4 days, so their "last 4 days" spend is partly after finishing. Descriptive, no comparison group.

## v5 (Eden 2026-10-22): aligned bins + end spend only up to the finish day — supersedes the lift numbers above
Changes: entry bins = finish bins (8+ / 7–4 / 3 / 2 / 1 days before close; finish adds close day). End $ per active day = the 4 days ending on the player's own finish day (finish day included; close day included for close-day finishers), so no post-finish days count. Base = days 21–15 (main) and 14–9. SQL: "follow-up 5" blocks (Domino 12.5 GB, Disney 25.8 GB, Dice 128.1 GB). Finisher totals unchanged.

**1–3 band finish rate by entry bin (all who got there; from the first run)**
| Got to 3 or fewer | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 |
|---|---|---|---|
| 8+ days out | 42% / 42% | 53% / 63% (204 in 20) | 26% / 24% |
| 7–4 days out | 24% / 22% | 37% / 23% | 14% / 18% |
| 3 days out | 22% / 12% | 26% / 13% | 24% / 23% |
| 2 days out | 11% / 9% | 19% / 9% | 16% / 21% |
| 1 day out | 4% / 4% | 11% / 5% | 10% / 9% |

**When finishers finished, by entry bin (share of the bin's finishers)**
| Game · got there | Finishers | 7–4 days out | 3 | 2 | 1 | close day |
|---|---|---|---|---|---|---|
| Dice · 8+ | 1,305 / 1,100 | 37% / 23% | 17% / 24% | 20% / 21% | 18% / 23% | 8% / 9% |
| Dice · 7–4 | 6,824 / 12,732 | 12% / 14% | 19% / 20% | 23% / 23% | 31% / 30% | 15% / 14% |
| Domino · 8+ | 854 / 128 | 18% / 50% | 17% / 24% | 26% / 14% | 30% / 7% | 9% / 5% |
| Domino · 7–4 | 1,391 / 5,476 | 9% / 12% | 18% / 29% | 23% / 24% | 34% / 23% | 17% / 13% |
| Disney · 8+ | 4,162 / 5,651 | 1% / 1% | 8% / 9% | 25% / 29% | 47% / 43% | 20% / 18% |
| Disney · 7–4 | 6,069 / 2,721 | 0% / 1% | 8% / 13% | 18% / 23% | 47% / 42% | 27% / 21% |
Entered 3 / 2 / 1 days out: finish only on the following days (e.g. entered 2 days out: 64–82% finish 1 day out, rest on the close day).

**Lift vs self: $ per active day, 4 days ending on the finish day ÷ days 21–15**
| Got to 3 or fewer | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 |
|---|---|---|---|
| 8+ days out | ×1.8 / ×1.8 ($22 / $19 → $40 / $35) | ×1.5 / ×1.7 ($30 / $31 → $45 / $52) | ×1.5 / ×1.5 ($24 / $22 → $35 / $33) |
| 7–4 days out | ×2.7 / ×2.5 | ×2.0 / ×2.1 | ×2.1 / ×2.7 |
| 3 days out | ×2.9 / ×2.7 | ×2.9 / ×2.4 | ×2.4 / ×2.5 |
| 2 days out | ×3.1 / ×3.0 | ×2.8 / ×2.6 | ×2.1 / ×2.4 |
| 1 day out | ×3.5 / ×3.2 | ×2.5 / ×2.5 | ×2.1 / ×2.3 |
Median player: same order (early ×1.5–2.3, later ×1.8–3.7). Vs days 14–9: early ×1.2–1.4 (Domino 20 ×0.9).

- **Fact:** early closers (8+ days out) lift least in every game (×1.5–1.8); Disney's (×1.5) is among the lowest, with Domino 19.
- **Fact:** players who got close in the last 3 days lift ×2.1–3.5; in Disney the later groups lift less than in Dice (×2.1–2.5 vs ×2.7–3.5).
- **Fact:** with the corrected window the "4–3 days out lift most" line no longer holds as such: in Dice the latest closers lift most (×3.2–3.5); in Domino the 3-day group (×2.4–2.9); in Disney the 7–4 / 3-day groups (×2.1–2.7).

## v6 (Eden 2026-10-22): each payer counted ONCE, by status on a fixed day — supersedes the overlapping-band table for slide 1
Eden: overlapping bands are misleading (a player who passes through counts in several groups). Groups = missing stickers on the latest daily row on or before close−8 (and close−7). Same population and finisher rule. SQL: "follow-up 6" blocks (Domino 10.9 GB, Disney 22.0 GB, Dice 125.9 GB). Check: group revenue shares add up to the payer total (Domino 19: 77%).

**8 days before close** (album A / album B) — finish rate · share of payers · share of game revenue
| Missing on close−8 | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 |
|---|---|---|---|
| 1–3 | **42% / 42%** · 2% / 1% · 7% / 5% | **53% / 63%** · 1% / 0.2% · 10% / 2% | **26% / 24%** · 4% / 7% · 17% / 27% |
| 4–6 | **17% / 19%** · 19% / 35% · 32% / 48% | **14% / 19%** · 19% / 28% · 30% / 46% | **10% / 11%** · 24% / 16% · 32% / 24% |
| 7–10 | **11% / 11%** · 16% / 22% · 13% / 14% | **6% / 8%** · 23% / 34% · 17% / 20% | **4% / 4%** · 35% / 16% · 19% / 11% |
| 11+ | **7% / 7%** · 64% / 41% · 26% / 15% | **2% / 3%** · 57% / 38% · 19% / 11% | **1% / 2%** · 37% / 61% · 10% / 20% |
Already finished on close−8: Dice 2 players, Domino 8 / 1, Disney 0.

**7 days before close**
| Missing on close−7 | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 |
|---|---|---|---|
| 1–3 | **42% / 42%** · 2% / 3% · 10% / 9% | **48% / 58%** · 2% / 1% · 15% / 4% | **21% / 24%** · 7% / 8% · 22% / 28% |
| 4–6 | **15% / 17%** · 28% / 45% · 38% / 50% | **12% / 19%** · 25% / 30% · 31% / 46% | **8% / 9%** · 29% / 19% · 32% / 26% |
| 7–10 | **9% / 9%** · 25% / 21% · 13% / 11% | **5% / 8%** · 24% / 34% · 15% / 19% | **3% / 4%** · 32% / 17% · 16% / 10% |
| 11+ | **5% / 5%** · 44% / 32% · 16% / 11% | **1% / 3%** · 49% / 35% · 15% / 10% | **1% / 2%** · 31% / 55% · 8% / 17% |
Already finished on close−7: Dice 155 / 145, Domino 14 / 2, Disney 0.

- **Fact:** counted once, from the same distance Disney payers finish about half as often as Dice at every distance (1–3: 24–26% vs 42%; 4–6: 10–11% vs 17–19%; 7–10: 4% vs 11%). Domino is between, with a higher rate for the few who are 1–3 short.
- **Fact:** in Disney far more revenue sits in the near group 8 days out: payers 1–3 short hold 17–27% of game revenue (Dice 5–7%, Domino 2–10%).
- The overlapping-band table above made the 1–3 group look alike in all games because late arrivals (who rarely finish) dominate it in Dice and Domino; do not use it for slide 1.

## v7 (Eden 2026-10-22): last status in days 8–4 before close → chance to finish in the last 4 days — the base for slide 1
Status = missing stickers on the latest daily row on or before close−4 (the player's last state in days 8–4); each payer counted once. Finish = 144 by the end of the close day, i.e. within close−3 .. close day for everyone not already finished. SQL: "follow-up 7" blocks (Domino 10.9 GB, Disney 22.0 GB, Dice 125.9 GB). Group revenue shares add up to the payer totals (78 / 82%, 77 / 79%, 78 / 81%).

Finish rate · share of payers · share of game revenue (album A / album B)
| Status on close−4 | Dice 61 / 63 | Domino 19 / 20 | Disney 14 / 15 |
|---|---|---|---|
| already finished | 1% / 2% of payers · 4% / 5% | 0.3% / 1% · 4% / 7% | 0.03% / 0.04% · 0.2% / 0.2% |
| 1–3 missing | **23% / 20%** · 15% / 28% · 27% / 39% | **39% / 21%** · 4% / 22% · 20% / 37% | **17% / 22%** · 16% / 12% · 35% / 35% |
| 4–6 | **9% / 9%** · 41% / 42% · 32% / 28% | **9% / 8%** · 33% / 33% · 31% / 24% | **6% / 7%** · 33% / 26% · 27% / 26% |
| 7–10 | **5% / 6%** · 21% / 10% · 7% / 4% | **3% / 4%** · 25% / 20% · 11% / 6% | **2% / 2%** · 27% / 22% · 11% / 10% |
| 11+ | **2% / 2%** · 22% / 18% · 7% / 6% | **1% / 1%** · 37% / 24% · 11% / 6% | **0.3% / 1%** · 23% / 40% · 6% / 11% |
Players: Dice 1–3 = 29,851 / 58,208; Domino 5,083 / 23,454; Disney 59,997 / 38,065.

- **Fact:** 4 days before close, from the same status Disney converts a bit less than Dice and Domino: 1–3 missing 17–22% vs 20–23% (Dice) and 21–39% (Domino); 4–6 missing 6–7% vs 8–9%; 7–10 missing 2% vs 3–6%.
- **Fact:** Disney's near group 4 days out is worth the most: 1–3 missing = 35% of game revenue in both albums (Dice 27–39%, Domino 20–37%).
- **Fact:** almost no Disney payer has finished 4 days out (0.03–0.04% of payers), vs 1–2% in Dice and 0.3–1% in Domino.
- **Caveat:** "status 4 days out" is the last state inside the 8–4 window (Eden's definition); descriptive, no comparison group.

## v8 (Eden 2026-10-22): slides 20–21 on the slide-19 definition
Finishers grouped by status on close−4 (last state in days 8–4); already finished by close−4 left out. SQL: "follow-up 8" blocks (Domino 12.5 GB, Disney 25.8 GB, Dice 128.1 GB). Finisher counts match v7 (e.g. Dice 61 1–3: 6,863 = 23% of 29,851).

**Slide 20 — finish day of finishers who were 1–3 short on close−4** (3 / 2 / 1 days before close / close day; album A · album B)
| | Dice 61 · 63 | Domino 19 · 20 | Disney 14 · 15 |
|---|---|---|---|
| 3 days | 22% · 23% | 20% · 33% | 8% · 11% |
| 2 days | 27% · 27% | 27% · 27% | 21% · 27% |
| 1 day | 35% · 34% | 37% · 26% | 47% · 43% |
| close day | 17% · 16% | 16% · 14% | 24% · 19% |
| finishers | 6,863 · 11,853 | 1,961 · 4,868 | 10,189 · 8,295 |

**Slide 21 — lift vs own days 21–15, finishers by status on close−4** (album A · album B; average)
| | Dice | Domino | Disney |
|---|---|---|---|
| 1–3 | ×2.4 · 2.3 (×2.3) | ×1.8 · 2.1 (×1.9) | ×1.7 · 1.7 (×1.7) |
| 4–6 | ×2.7 · 2.7 (×2.7) | ×2.5 · 2.2 (×2.4) | ×1.8 · 1.9 (×1.9) |
| 7–10 | ×5.9 · 4.8 (×5.3) | ×2.8 · 4.8 (×3.8) | ×3.8 · 4.1 (×3.9) |
Usual-week $/day: 1–3 $9–19, 4–6 $5–7, 7–10 $1–3 (7–10 ratios inflated by the low base; median player 7–10: Dice ×4.4 / 3.7, Domino ×2.1 / 3.0, Disney ×2.9 / 3.1).

- **Fact:** from the same status 4 days out, Dice and Domino near payers often finish 3 days before close (22–27%); in Disney 9% do and 67% finish on the last day or the close day.
- **Fact:** Disney finishers lift the least in the 1–3 and 4–6 groups (×1.7 / ×1.9 vs Dice ×2.3 / ×2.7, Domino ×1.9 / ×2.4); in 7–10 Disney ≈ Domino (×3.9 / ×3.8), Dice highest.
