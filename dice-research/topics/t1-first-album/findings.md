# Topic 1: First-album experience, findings (2026-11-03)
Albums 57, 59, 61, 63, 65 (first album); next album 59–67. Project `dice-dreams-dbt`. Ranges = the five albums.
Population: players whose first album is this one (no earlier album record), with at least one sticker, excluded users removed. Reference = veterans (in the previous album) who entered in the first third.
Entry bands: **L14** = started in the last 14 days before close; otherwise T1 / T2 / T3 by share of album days. In 43- and 36-day albums the final third ≈ L14; only album 59 (50 days) has a separate T3.
Revenue = game gross revenue; revenue share = of all game revenue on album days start..close−1 (excluded users removed).
SQL: `queries/t1_s2_s4_core.sql`, `queries/t1_s3b_rolls_7d.sql`, `queries/t1_s5_composition.sql`; journey (2026-11-03, second pass): `queries/t1_j1_daily_journey.sql`, `t1_j2_close_status_types.sql`, `t1_j3` (packs; SQL text in this doc's appendix), `t1_j4_early_vs_later.sql`. Results: `results/*.csv` (J4 CSV holds the key cells; rerun the query for every cell).
The journey section (J1–J4) comes first; the earlier baseline findings F1–F6 follow it.

# Part 0. Core answer: eligible first-album entrants (v3, 2026-11-03)
**This part replaces Part I for every core claim.** Part I mixed albums: for entrants with fewer than 7 days left, its "first 7 days" included second-album days (checked: J2/J3/J4 used rows of any album; S2–S4 did not).

**Population (D-009).** First-album players (no earlier album record, at least one sticker, not excluded) with entry date E ≤ close date C − 7. Days 0–6 (E..E+6) therefore all fall before the close day, entirely inside the first album. This is an opportunity-to-observe rule; players who stop playing during the week stay in.
- **LATE** = entered in the final third of the album (by share of album days) and eligible: **235,686 players**, 7–16 days left (10.4 on average), **1.5% of game revenue** (album days start..close−1, pooled over albums 57–65).
- **EARLY** = entered in the first third: **401,974 players**, 35.5 days left on average, **5.9% of game revenue**.
- Left out of the core: the 200,658 final-third / last-14-day entrants with 0–6 days left (0.5% of game revenue). Their earlier results stay in Part I, labelled.
SQL: `queries/t1_e1_eligible_core.sql` (week 1, close, album 2, days 0–29, types, distributions), `t1_e2_packs_equal_collection.sql`, `t1_e3_rapid_purchase_timing.sql`, `t1_e4_milestones.sql`. Results: `results/t1_e1..e4_*_2026-11-03.csv`.

Windows used below:
- **Week 1** = days 0–6, first album only.
- **Close** = entry to C−1, first album. Close-day stickers are not updated in the Dice daily table.
- **Album 2** = the next album's first 14 calendar days. Game activity and revenue are in that window; stickers and sets come from album A+2 rows.
- **Days 0–29** = since entry, game level. Stickers and sets are split by album.

## 0-A. Late entrants: week 1 and the first album
| | LATE | EARLY |
|---|---|---|
| Active days in week 1 | 4.75 of 7 | 4.63 of 7 |
| Packs received (receipt only; opening is not logged) | 42 | 36 |
| New stickers (mean · median) | 55 · 49 | 39 · 36 |
| Duplicate share of stickers received | 45% | 50% |
| Sets completed (mean) · at least one set | 1.8 · 43% | 0.6 · 26% |
| Album rolls (set/album rewards): any · p90 | 43% · 3,300 | 27% · 950 |
| Album rolls as share of non-wager rolls received | 6.3% | 1.6% |
| Other rolls in · rolls spent (medians) | 3,348 · 3,942 | 2,854 · 3,362 |
| Roll balance end of week (median) | 16 | 15 |
| Revenue per player · payers | $6.05 · 23.5% | $5.54 · 22.5% |
| Purchases per payer | 5.4 | 5.3 |
| First purchase day, payers through day 29 (quartiles) | 0 / 0 / 1 / 4 | 0 / 0 / 1 / 5 |
| **At close** | | |
| Active days to close | 6.4 of 10.4 | 13.9 of 35.5 |
| Sets · stickers missing (mean) · median stickers | 2.7 · 77 · 65 | 3.5 · 71 · 70 |
| Finished the album | 2.6% | 2.0% |
| First set (median day) · days between sets | day 4 · 0.7 | day 7 · 2.6 |
| Album rolls by close: share of all rolls · p90 | 5.6% · 5,800 | 4.2% · 19,550 |
| Roll balance at close (median) | 22 | 51 |
| Active in the last 3 days before close | 61% | 31% |
| Revenue entry→close per player · payers | $8.88 · 25% | $20.91 · 28% |

- **Fact:** inside the first album, with a full week to play, late entrants get 30% more stickers than early entrants (≈99 vs ≈76), at a slightly lower duplicate rate. They complete about 3x as many sets, and they spend the same.
- **Check (one album or all?):** late > early in new stickers in every album: 47–61 vs 35–43. Sets per late entrant range 1.3–2.1 across albums; for early entrants, album 61 (36 days) is the highest at 1.2.

## 0-B. Why late entrants get more new stickers (pack check, first album, week 1)
- **Fact:** the gap is not about pack source or pack size. At the same collection size and the same source, a late entrant's pack holds about twice as many new stickers, with the same number of stickers per pack (~3.0). Examples:
  - new-kingdom packs at 25–49 stickers held: 1.57 vs 0.80 new;
  - Trail chest at 25–49: 2.05 vs 1.15;
  - all packs at 50–74: 0.95 vs 0.49.
- **Fact:** the pack event carries a field `progression_balance_factor_value_golden/super`. At equal collection size it is much lower for late entrants (25–49 stickers: 0.30 vs 1.15 golden; 50–74: 0.76 vs 2.21). The pity counter never fired (0%).
- **Hypothesis (not documented):** a progression-balancing rule that gives players who are behind the album's calendar more new stickers per pack. The repo has no documentation of a catch-up mechanic, and the field's meaning is marked "Investigate" in the event doc. **Ask the Dice team** before calling it a catch-up.

## 0-C. Different experiences in week 1 (mutually exclusive types, D-008 kept)
Boundaries (days 0–6, first album):
- **Barely**: fewer than 20 new stickers.
- **Collector**: 20+ new stickers and 0 sets.
- **Steady**: 1–3 sets.
- **Rapid**: 4+ sets.

They are kept because they separate players cleanly: each type differs in activity, payer rate and album rolls. Barely = the bottom quarter, almost all with 1–3 active days. Rapid = where album rolls reach the thousands.
Revenue shares:
- **% of cohort** = the type's revenue from entry to close / the group's revenue in the same window.
- **% of game** = the type's revenue on album days start..close−1 / all game revenue on those days (pooled over albums 57–65).

| Type | LATE: players (%) · % of cohort · % of game | EARLY: players (%) · % of cohort · % of game |
|---|---|---|
| Barely | 54,397 (23%) · 1% · 0.02% | 112,417 (28%) · 1% · 0.08% |
| Collector | 79,595 (34%) · 4% · 0.07% | 183,730 (46%) · 11% · 0.67% |
| Steady | 55,424 (24%) · 11% · 0.17% | 92,746 (23%) · 51% · 2.97% |
| Rapid | 46,270 (20%) · **84%** · 1.23% | 13,081 (3%) · **37%** · 2.18% |

| Week 1, LATE / EARLY | Barely | Collector | Steady | Rapid |
|---|---|---|---|---|
| Packs | 3 / 4 | 18 / 25 | 56 / 81 | 114 / 157 |
| New stickers | 8 / 9 | 39 / 38 | 77 / 69 | 111 / 91 |
| Sets | 0 / 0 | 0 / 0 | 2.4 / 2.1 | 6.0 / 4.7 |
| Album rolls (median; rapid p90) | 0 / 0 | 0 / 0 | 800 / 550 | 3,300 / 2,050 (p90 9,800 / 3,460) |
| Balance (median) | 24 / 28 | 11 / 13 | 19 / 15 | 14 / 25 |
| Payers in week 1 | 6% / 6% | 13% / 17% | 30% / 46% | 55% / 74% |
| Active on days 14–27 | 25% / 25% | 54% / 59% | 71% / 76% | 79% / 84% |
| Revenue days 7–29 per player | $0.40 / $0.35 | $1.95 / $3.00 | $7.85 / $28.79 | $57.30 / $156.87 |
| Finished the first album | 0.0% / 0.1% | 0.1% / 0.9% | 0.7% / 4.8% | 12.1% / 13.7% |
- **Rapid without paying in week 1:** LATE 21,017 (45% of late rapid, 9% of eligible late entrants), EARLY 3,429 (26% of early rapid). Late rapid non-payers: 77% active on days 14–27; $5.67 revenue on days 7–29.
- **A small group holds the money.**
  - *Late entrants:* 8+ sets in week 1 = 9,127 players (3.9%), 57% of late cohort revenue, p90 album rolls 39,300, 76% payers. 5,000+ album rolls in week 1 = 11,157 (4.7%), 62% of late cohort revenue.
  - *Early entrants:* only 400 reach 5,000+ album rolls.
- **Concentration check:** the top 1% of spenders hold 47% of each cohort's revenue (entry to close). Revenue shares by type are therefore driven by a few large spenders; payer rates and activity are not.

## 0-D. Rapid progress and purchase timing (reward event = 4th set completed in week 1)
| | LATE rapid (46,270) | EARLY rapid (13,081) |
|---|---|---|
| Paid before the reward event | 23,213 (50%) | 9,478 (72%) |
| Paid only after it (in week 1) | 2,040 (4%) | 174 (1%) |
| No payment in week 1 | 21,017 (45%) | 3,429 (26%) |
| Before the reward, payers: purchases · median $ | 5.0 · $11 | 11.1 · $29 |
| Last purchase → reward (median) | 7 hours | 30 minutes |
| What they bought before (top by $) | Dream Pass, Big Chest (DP), Decoy BuyAll, scrolling offers | Big Chest (DP), Decoy BuyAll, Dream Pass, scrolling offers, 6 Boxes |
| New stickers bought directly (validated purchase→sticker rule), payers | 6.6% | 7.9% |
| Day of the reward event (median) | day 4 | day 5 |
| Album rolls up to the reward day (median) | 2,300 | 1,700 |
| Paid before: buy again within 7 days · median hours to next purchase | 77% · 14 h | 86% · 7 h |
| Paid before: spend in the 7 days after (mean · median of payers) | $54 · $23 | $102 · $47 |
| No pay in week 1: buy within 7 days after the reward · active 5+ of the next 7 days | 9% · 77% | 9% · 81% |
- **Fact:** about half of late rapid players and a quarter of early rapid players reach 4+ sets without paying. Among payers, only 7–8% of new stickers came directly from a purchase. The rest came from gameplay sources, which purchases may also have fuelled (bought rolls, passes). This cannot be separated.
- **Fact:** after the reward, payers keep buying soon (median 7–14 hours). Non-payers stay active but rarely start paying (9% within 7 days).
- **Meaning (descriptive):** no sign that the reward replaced the next purchase for payers. Nor does the reward turn non-payers into payers within a week. Neither reading is causal.

## 0-E. Days 7, 14 and 30 (day 6, 13, 29 = last day of each window), all eligible entrants
Exact day = active on that day; window = active on any of day N−1..N+1. Denominator = all eligible entrants whose day N+1 has happened; LATE day 29: 164,803 of 235,686 (album 65 entrants lack the follow-up).
| LATE / EARLY | Day 6 | Day 13 | Day 29 |
|---|---|---|---|
| Active that exact day | 54% / 52% | 41% / 39% | 25% / 26% |
| Active in the 3-day window | 67% / 65% | 51% / 49% | 32% / 33% |
| Cumulative active days | 4.8 / 4.6 | 7.9 / 7.7 | 12.7 / 12.6 |
| Day falls in album 2 | 0% / 0% | 86% / 0% | 100% / 14% |
| New stickers album 1 (median) · album 2 (mean) | 50 · 0 / 35 · 0 | 62 · 17 / 53 · 0 | 59 · 39 / 68 · 1 |
| Sets album 1 · album 2 | 1.8 · 0 / 0.6 · 0 | 2.7 · 0.2 / 1.5 · 0 | 2.8 · 1.3 / 3.1 · 0.0 |
| Album rolls p90 (cumulative) | 3,150 / 950 | 6,050 / 2,800 | 9,750 / 12,950 |
| Other rolls in · spent (medians) | 3,314 · 3,947 / 2,791 · 3,197 | 9,813 · 11,756 / 6,961 · 7,736 | 16,063 · 19,554 / 13,302 · 16,241 |
| Roll balance (median) | 17 / 15 | 30 / 31 | 50 / 50 |
| Revenue per player (cumulative) | $6.05 / $5.54 | $11.51 / $10.22 | $19.75 / $18.76 |
| Paid at least once · on 2+ days | 24% · 12% / 23% · 12% | 27% · 16% / 25% · 15% | 28% · 19% / 28% · 18% |

**Survivor profiles** (players active in the 3-day window around the milestone; descriptive, not the main result):
| LATE / EARLY | Around day 6 | Around day 13 | Around day 29 |
|---|---|---|---|
| Players | 158,209 / 262,151 | 120,249 / 198,314 | 53,227 / 132,868 |
| New stickers album 1 (median) + album 2 (mean) | 70 / 47 | 99 + 32 / 80 | 100 + 84 / 124 + 4 |
| Sets album 1 + album 2 | 2.5 / 0.9 | 4.3 + 0.4 / 2.6 | 4.8 + 3.5 / 6.7 + 0.0 |
| Revenue to date · paid | $8.23 · 29% / $7.66 · 28% | $19.33 · 36% / $17.43 · 34% | $44.92 · 43% / $42.32 · 42% |
- **Fact:** at equal time since entry, activity, balance, payer share and revenue are the same for late and early entrants through day 29. Late entrants' day 13 and day 29 fall in the second album, early entrants' in the first.

## 0-F. Second album (first 14 days of the next album)
- **Late / early:** 60% / 33% entered album 2; 62% / 35% active in the game in that window; $9.14 / $4.48 revenue per player; 14% / 7.5% paid.
- **Why the gap is timing:** a late entrant reaches the next album about 10 days after entering, an early entrant about 36 days after. At equal time since entry there is no gap (0-E). Days 0–29: active days 12.7 vs 12.6; revenue $19.75 vs $18.76; active on days 14–27 54% vs 54%.

## 0-G. What changes from the earlier reading
| Earlier statement | Now |
|---|---|
| "Late entry is not a problem" | **Kept for eligible late entrants** (7+ days left): faster progress, same week-1 spend, same activity and revenue to day 29. For entrants with fewer than 7 days left there is no core evidence; Part I numbers for them mix albums and are only descriptive. |
| "Progress is bought" (Part I) | **Withdrawn.** 26–45% of rapid players pay nothing in week 1. Among payers, 7–8% of new stickers came directly from purchases. Payers progress more, but how much comes through bought rolls cannot be measured. |
| "Keep the catch-up" | **Reworded.** Late entrants do get more new stickers per pack at the same collection size, but the mechanic is not documented (field `progression_balance_factor_*`, meaning unknown). Keeping it does no visible harm to spend or activity. Confirm the rule with the Dice team before recommending anything about it. |
| Rapid = 16% of late joiners (Part I) | **20% of eligible late entrants** on first-album days only (Part I's 16% included next-album days and entrants with <7 days left). |
| Progress → later play only among the most active | Unchanged in direction. Active days 14–27 rise from 25% to 79–84% from barely to rapid, but activity, payment and progress move together. Not causal. |

## 0-H. Limits
- Album rolls cannot be attributed to an album by source; after the first close, all album rolls are counted as second album.
- Receipt vs opening of packs is not measurable (no open event).
- The reward event uses set completion; the exact album-roll amount per set is not in the daily table.
- Album 65 late entrants lack day-29 follow-up.
- A few spenders drive revenue shares (top 1% = 47%).

---
# Part I. What first-album players experience (journey, J1–J4) — SUPERSEDED for core claims by Part 0 (album mixing for entrants with <7 days left); kept for the 0–6-days-left group and history
Pooled over first albums 57–65. **Late joiners (L14) = 446,913 players**, split by days left at entry: 0–2 (73,618), 3–6 (127,040), 7–10 (124,441), 11–14 (121,814). **First-third joiners (T1) = 401,974.**
Day d = days since first exposure (entry). A player counts on day d only if that date had happened by 2026-11-02 (follow-up available); no survivor filter.
"Active" = a game activity row that day. Revenue = game gross revenue from entry.

## J-A. Late joiners: from entry to close
| Days left at entry | Players · % of game revenue¹ | Active days to close | Stickers at close (median) | ≥1 set at close | Finished | Album rolls received (any / p90) | Balance at close (median) | Active in last 3 days | Revenue from entry per player |
|---|---|---|---|---|---|---|---|---|---|
| 0–2 | 73,618 · 0.1% | 1.2 of 1.3 | 6 | 6% | 57 | 9% / 0 | 3 | 97% | $1.55 |
| 3–6 | 127,040 · 0.4% | 3.4 of 4.5 | 33 | 28% | 1,200 | 31% / 2,050 | 7 | 85% | $4.24 |
| 7–10 | 124,441 · 0.7% | 5.4 of 8.4 | 56 | 50% | 2,660 | 52% / 4,300 | 18 | 65% | $7.35 |
| 11–14 | 121,814 · 0.9% | 7.3 of 12.5 | 74 | 57% | 3,672 | 58% / 8,050 | 29 | 56% | $10.61 |
| *T1 (first third), for reference* | 401,974 · 5.9% | 13.9 of 35.5 | 70 | 55% | 8,001 | 56% / 19,550 | 50 | 31% | $20.91 |
¹ Pooled share of all game revenue on the five albums' days (start..close−1); includes the player's revenue before entry.

- **Fact:** time left shapes the first album. A player who joins with 0–2 days left barely starts it (median 6 stickers) and moves into the next album within 1–2 days (37% by day 1, 67% by day 2). With 11–14 days left, a late joiner ends the first album where a first-third joiner ends: median 74 vs 70 stickers, 57% vs 55% with at least one set.
- **Fact:** first purchase, for those who pay, is on the entry day (median day 0) in every group.
- **Album rolls are a small part of the roll economy:** 2–6% of all rolls received by close, in every group.

## J-B. First-third joiners: same structure
- Active 13.9 of 35.5 days left; median 70 stickers at close (71 missing on average); 55% with ≥1 set; 8,001 finishers (2.0%); 31% still active in the last 3 days before close; roll balance at close 50 (median).
- Week 1: 38 new stickers (median) and 0.8 sets on average; only 31% complete a set in the first 7 days (late joiners with 7–14 days left: 47–49%).

## J-C. Packs (first 7 days from entry; received events, opening is not logged)
- About 42 packs per late joiner and 36 per first-third joiner. Largest source: **"new kingdom" (28–30% of packs)**, then progress bar (11–12%), Trail chest (10–11%), home makeover (7%), pets (5–6%).
- The catch-up shows in pack **content**, not pack count. New stickers per pack, late vs first-third: new kingdom 0.96 vs 0.63, progress bar 1.51 vs 1.13, Trail chest 1.64 vs 1.29. Home-makeover packs are mostly new stickers for both (2.3–2.5 new of ~2.9).
- Wild in a pack: rare (≈68K packs over 447K late joiners, from "other" sources and the bonus wheel; T1 almost none).

## J-D. First 7, 14 and 30 days at equal time since entry
| | Day 7 | Day 14 | Day 29 |
|---|---|---|---|
| Active that day (T1 / L14 groups) | 49% / 51–52% | 38% / 39–40% | 26% / 25–27% |
| Cumulative active days | 5.1 / 5.2–5.3 | 8.1 / 8.3–8.4 | 12.6 / 12.6–12.8 |
| New stickers (median, cumulative) | 38 / 48–58 | 54 / 68–85 | 67 / 81–99 |
| Sets (average, cumulative) | 0.8 / 0.8–2.2 | 1.6 / 1.6–3.3 | 3.1 / 2.7–4.5 |
| Rolls received (median, cumulative) | 3,856 / 4,500–5,100 | 10,344 / 13,600–15,100 | 17,783 / 19,700–21,400 |
| Roll balance (median) | 18 / 19–21 | 32 / 32–34 | 50 / 50 |
| Revenue per player (cumulative) | $6.25 / $6.92–7.87 | $10.86 / $12.38–13.87 | $18.76 / $19.98–23.07 |
| Paid at least once since entry | 23% / 24–26% | 26% / 27–28% | 28% / 28–30% |
| In the next album | 0% / 0–82% (by days left) | 0% / 44–83% | 4% / 55–84% |
Source: `results/t1_j1_daily_journey_2026-11-03.csv` (daily rows for days 0–7, then 10, 13, 14, 17, 21, 25, 29).

- **Fact:** activity unfolds the same way in every group: about 75% return on day 1, half are active on day 7, a quarter on day 29. In 30 days the average first-album player is active 12–13 days.
- **Fact:** new stickers per active day peak on day 1 (11–16) and fall to 3–4 by day 14, while duplicates climb from 16–19% on day 0 to 81–84% by day 14. **Entering a new album resets this:** late joiners get 11–12 new stickers per active day again on the days they cross into the next album.
- **Fact:** revenue by day 29 is the same or slightly higher for late joiners ($19.98–23.07 vs $18.76); the highest is for those who joined with 0–2 days left and were in a fresh album within two days.

### Players still active around days 7, 14 and 30 (active on any of days 6–8 / 13–15 / 27–29; denominator = players with that follow-up)
| | Still active | Their new stickers · sets by then | Album rolls by then (median) | Revenue by then per player | Paid by then | In next album by then |
|---|---|---|---|---|---|---|
| Day 7 — T1 / L14 | 62% / 64% | 50 · 0.9 / 73 · 2.1 | 0 / 250 | $7.82 / $8.75 | 28% / 30% | 0% / 48% |
| Day 14 — T1 / L14 | 48% / 49% | 76 · 2.6 / 118 · 4.1 | 950 / 1,050 | $17.63 / $20.42 | 35% / 37% | 0% / 95% |
| Day 30 — T1 / L14 | 34% / 33% | 121 · 6.7 / 163 · 7.3 | 8,450 / 4,150 | $42.19 / $47.74 | 42% / 44% | 11% / 100% |
- **Fact:** the share still active is the same for both groups at each horizon, though late joiners who stay have collected 1.4–1.6x more stickers. Being inactive around day 14 does not mean permanent churn; return later is not measured here.

## J-E. Different experiences in the first 7 days (types defined from the J2 distribution)
Definitions (same for both groups, days 0–6 since entry): **Barely** = fewer than 20 new stickers; **Collector** = 20+ new stickers, no set; **Steady** = 1–3 sets; **Rapid** = 4+ sets. Thresholds: Claude's choice from the observed distribution (fewer than 20 new stickers = the bottom quarter, almost all with 1–3 active days; 4+ sets = where album rolls become sizeable).
| Type | T1: players (% of T1) · % of game revenue | L14: players (% of L14) · % of game revenue | Album rolls week 1 (median) | Revenue week 1 per player (T1 / L14) |
|---|---|---|---|---|
| Barely | 112,417 (28%) · 0.07% | 102,723 (23%) · 0.04% | 0 | $0.34 / $0.35 |
| Collector | 183,730 (46%) · 0.62% | 175,079 (39%) · 0.14% | 0 | $1.16 / $0.89 |
| Steady | 92,746 (23%) · 2.81% | 97,113 (22%) · 0.25% | 550–600 | $11.03 / $4.70 |
| Rapid | 13,081 (3%) · 2.14% | 71,998 (16%) · 1.65% | 2,050–3,300 | $72.84 / $29.77 |
- **Fact:** the median of zero album rolls hides a group that gets real rewards. The "rapid" players get 2,000–3,300 album rolls in week 1 (p90 by day 29 up to 13,000) and hold most of the money: T1 rapid = 3% of T1 players and 38% of T1 revenue; L14 rapid = 16% of L14 players and 79% of L14 revenue.
- **Fact:** for first-third joiners, rapid progress is mostly bought (week-1 revenue $72.84 per player). For late joiners the catch-up makes rapid progress five times more common and much cheaper ($29.77).

## J-F. Early experience vs later outcome (measured after the early window, within strata fixed in week 1)
Strata: active days in days 0–6 (1–2 / 3–4 / 5–7) and payer in days 0–6. Outcome: active on any of days 14–27. For T1 this is still inside the first album; for L14 it is after the next album starts.
| Non-payers in week 1 | Barely | Collector | Steady | Rapid |
|---|---|---|---|---|
| 3–4 active days — T1 | 36% | 41% | 41% | 29% (n=85) |
| 3–4 active days — L14 | 35% | 39% | 42% | 34% |
| 5–7 active days — T1 | 59% | 72% | 79% | 83% |
| 5–7 active days — L14 | 59% | 70% | 77% | 79% |
- **Fact:** among moderately active players (3–4 days), more album progress in week 1 does **not** go with more play on days 14–27 (35–42% in every type). Among the most active (5–7 days) it does (59% → 79–83%), but in that band activity also rises with the type (5.5 → 6.9 days on average), so part or all of the gap is engagement, not progress.
- **Fact:** revenue on days 7–29 follows early spending. Week-1 payers with 5–7 active days spend $14–15 (collector), $39–61 (steady) and $117–212 (rapid). Their progress was largely bought (week-1 spend $5–99). The direction runs at least partly from spend to progress, so this cannot show that rewards create value.
- **Fact:** for the same type, activity band and payer status, late and early joiners have almost the same outcomes, although the outcome falls inside the first album for one group and in the next album for the other.
- **Meaning:** no evidence that more album progress or more album rolls in week 1, by itself, keeps more new players. Similar outcomes do not prove that generosity has no effect: only a randomised change to first-album progress can measure that.

## Journey summary: packs → new stickers → sets → rolls → play and spend
- **Packs → new stickers:** most early packs come from "new kingdom", progress bar and Trail chest. By day 14, 4 of 5 stickers are duplicates unless a new album starts.
- **New stickers → sets:** one in three first-third joiners completes a set in week 1. Late joiners with a week or more left complete one half the time.
- **Sets → rolls:** album rolls are 2–6% of all rolls received. Only the rapid 3–16% get a meaningful amount (thousands in week 1).
- **Rolls → play and spend:** balances stay near empty (median 18–50 over 30 days). Within the same activity level, progress and album rolls do not go with more later play (except in the most active band, where engagement is confounded). Spending continues where it started.

---
# Part II. Baseline findings (first pass)

## Data correction before any result (C-005)
`30_intermediate.album_pop.user_album_start_date` is overwritten to the close day for 25–31% of players in albums 63 and 65 (270,736 / 338,528 players; rows rebuilt after close). The first S2 run put ~250K veterans "entering at close" with 41–49% of revenue. Fix: entry = first row in `user_daily_album` (it equals that table's own start date for every player checked). Album 57 was not affected. `t1_s2_base.sql` is superseded.

## F1. Size
- **Observed:** first-album players = 201,022–270,286 per album = **18–23% of album players** and **10–15% of game revenue** during the album; 58,086–83,007 payers.
- **Validation:** matches the 11-02 table (19–22% / 10–15%, other base table); game-revenue denominator matches earlier docs (album 61 $25,341,831 vs $25,341,918; album 63 $30,302,513 vs $30,302,561).
- **Meaning:** a large group in players, mid-sized in money. Who they are: ~70% installed within 7 days before entry (median 3–5 days), 6–10% paid before. The first album is in practice the player's first week in the game.
- **Limit:** players with an album record but no sticker (1–4%) are not in the base.

## F2. A third of first-album players are gone by their second week; veterans lose 13–16%
- **Observed:** active in the game on days 7–13 after entry: **first-album 63–69%** (every entry band) vs **veterans 84–87%**. First-album players who start in the first third: 58–65% have no activity in the album's last 7 days (veterans 23–31%).
- **Validation:** same rate in all five albums and all entry bands; measured on game activity (not album activity), so it does not depend on the album being open.
- **Meaning:** early loss is the main first-album issue: it touches every first-album player, and it is about twice the veteran rate.
- **Limit:** the data cannot say how much of this loss the album causes. It looks like general new-player drop-off (see F4).

## F3. Late joiners progress fast and spend the same in their first week
- **Observed (L14 vs T1):**
  - L14 = 26–51% of first-album players, 1.3–3.1% of game revenue.
  - New stickers per active day: 10–12 vs 4.8–6.1.
  - Duplicates: 45–51% vs 70–76%.
  - Paying late joiners finish at 5–9% within about 7 days, vs 6–8% for first-third joiners over about 36 days.
  - First 7 days from entry: revenue per player $5.2–6.7 vs $4.9–6.7; payer rate 19–26% vs 20–26%; active days 4.5–4.9 vs 4.6–4.7.
- **Validation:** equal 7-day window for both groups. The groups look the same before entry: install age, prior payers (6–10%), kingdom 5–6 at entry.
- **Meaning:** the catch-up gives late joiners much faster progress. In week 1 they buy neither less nor more (H1 not supported).
- **Limit:** the catch-up rule is not documented; the week-1 window is short.

## F4. Same 2-week retention despite twice the progress
- **Observed:** active on days 7–13 after entry: L14 64–69% vs T1 64–66%, though L14 get about twice the new stickers per active day.
- **Validation:** same comparison in all five albums. Entry bands are similar before entry, so the comparison is fair.
- **Meaning:** faster album progress in the first days does not keep more new players at two weeks. This argues against "too little progress drives them away" (H2) and against "generous early rewards build engagement" (H3), at least over two weeks. It fits general new-player drop-off (H4).
- **Limit:** observational; covers two weeks, not long-term value. Album phase is not random (UA timing), but the composition check shows no difference.

## F5. "Late joiners retain better in the next album" is an elapsed-time artefact
- **Observed:** active in the game during the next album's first 14 days: L14 68–73% vs T1 33–39% (veterans 70–77%). Payers who pay again in those 14 days: 45–49% vs 21–25% (veterans 50–56%). Next-album revenue per player in those 14 days: L14 $7.2–11.0 vs T1 $3.7–6.0.
- **Validation:** the next album starts about 7 days after an L14 joiner enters, but about 36 days after a T1 joiner. At equal time since entry (F4) there is no gap.
- **Meaning:** do not compare entry groups with next-album metrics. Use time since entry. Late joiners are not "better players"; they are measured earlier in their life.
- **Limit:** the long-term revenue comparison at equal time since entry (days 0–60) is not done yet (backlog B-1).

## F6. Rolls: the album gives first-album players almost no rolls; their balance runs near empty
- **Observed (first 7 days, medians):**
  - Rolls from album rewards: 0 (album share of rolls received 0.3–3.5%).
  - Free rolls in: 2,053–4,197; rolls out: 2,734–6,033; balance at the end of the window: 9–26.
  - Veterans: free in 10,132–33,565, out 18,948–49,948, balance 60–85.
  - Late and early joiners do not differ in rolls.
- **Validation:** medians, because means are distorted by a few extreme players. The "purchase group" sources reach 95–99% of players, non-payers included, so they cannot mark paid rolls; that split is dropped.
- **Meaning:** first-album players do not have "generous rolls". The album's generosity to newcomers is in stickers (catch-up), not in rolls. H1 through rolls is not supported.
- **Limit:** the album gives rolls mainly for set and album completion, which newcomers rarely reach in week 1.

## Explanations: status
| Explanation | Status | Evidence |
|---|---|---|
| H1 Generous rewards delay buying | **Not supported** (week 1) | Fast catch-up, same week-1 payer rate and revenue (F3); rolls are not generous (F6) |
| H2 Too little progress drives players away | **Not supported** (2 weeks) | Twice the progress, same 2-week retention (F4); no "wall" before stopping (11-02 §6); within the same week-1 activity, the barely-progressing do no worse than collectors at 3–4 active days (J-F) |
| H3 Generous early rewards build engagement / value | **Not supported as an effect**; undecided | Within the same activity band, progress and album rolls go with later play only among the most active, where engagement is confounded; revenue follows early spending, and progress was partly bought (J-F). Only a randomised change can measure it |
| H4 General new-player drop-off | **Fits best**, not proven | Same loss in every entry band; ~70% installed within 7 days; double the veteran rate (F2, F4) |
| H5 Artefacts | **Found and fixed** | album_pop start date (C-005); elapsed-time artefact in next-album metrics (F5) |

## Business meaning and next step
- **Keep the catch-up:** late joiners progress fast and do not spend less (Fact).
- **Do not expect album pace to fix early loss:** twice the progress did not change 2-week retention (Fact). Making the first album more generous is unlikely, by itself, to lift early retention (Hypothesis).
- **The lever is the first two weeks of every new player, not late entry.** Any change for first-album players is a **controlled test** (first-album players only, randomised). Main metric: active on days 7–13 after entry. Guardrail: revenue days 0–28 after entry.
- **Measurement rule:** compare entry groups by time since entry, never by next-album metrics.
- **Very late joiners (0–2 days left, 73,618 players, 0.1% of revenue):** the first album is effectively skipped. Within two days they are in a fresh album, and by day 29 they spend the most of any group ($23.07 per player). No sign this needs fixing (Fact); why they spend more is not known (Hypothesis: a fresh album start).
- **Where to look next, within Topic 1 only if Eden wants:** the rapid group (3% of first-third joiners, 38% of their revenue; 16% of late joiners, 79% of theirs) is where first-album money sits. A test of first-album progress should report results separately for players who would be rapid anyway.
- **Data fix:** report the album_pop start-date overwrite to the data team (C-005).

## Backlog (adjacent, not done)
- B-1 Days 30–60 at equal time since entry (J1 covers days 0–29), and time to next purchase as a survival curve.
- B-2 Done for the first 7 days (J-C). Open: packs over the whole first album, duplicates by sticker type.
- B-3 Returning players (earlier album, not the previous one): 9–10% of players.
- B-4 Within-band dose-response: new stickers in the first 3 days vs 2-week retention at the same early spend.
- B-5 Spike of late first-album joiners in album 65 (127,844 = 12% of album players): UA campaign?
- B-6 Kingdom at entry is 5–6, while the docs say the album opens at Kingdom 8 (C-006).
- B-7 Return after inactivity: how many players inactive on days 14–27 come back later (inactive ≠ churned).
- B-8 Within the 5–7 active-day band, separate engagement from progress (sessions, rolls spent) before reading the progress gradient.

## Appendix: J3 packs query (first 7 days, by source)
Same population CTEs as `t1_j4_early_vs_later.sql` (groups T1 / L14). Packs from `dice-dreams-dbt.10_staging.stg_album_pack_received_vw`
(pdate 2026-03-23..2026-10-25, album_id 57–67), joined on user and pdate within entry..entry+6; top 12 sources per group, rest = "other".
Measures: packs, packs per player, share of packs, share of new stickers, stickers per pack (`total_stickers_in_pack`), new per pack
(`number_of_new_stickers`), Wild packs (`is_wild`). Scan ≈68 GB. Result: `results/t1_j3_packs_7d_2026-11-03.csv`.
