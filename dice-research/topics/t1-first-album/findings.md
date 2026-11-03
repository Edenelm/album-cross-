# Topic 1: First-album experience, findings (2026-11-03)
Albums 57, 59, 61, 63, 65 (first album); next album 59–67. Project `dice-dreams-dbt`. Ranges = the five albums.
Population: players whose first album is this one (no earlier album record), with at least one sticker, excluded users removed. Reference = veterans (in the previous album) who entered in the first third.
Entry bands: **L14** = started in the last 14 days before close; otherwise T1 / T2 / T3 by share of album days. In 43- and 36-day albums the final third ≈ L14; only album 59 (50 days) has a separate T3.
Revenue = game gross revenue; revenue share = of all game revenue on album days start..close−1 (excluded users removed).
SQL: `queries/t1_s2_s4_core.sql`, `queries/t1_s3b_rolls_7d.sql`, `queries/t1_s5_composition.sql`; journey (2026-11-03, second pass): `queries/t1_j1_daily_journey.sql`, `t1_j2_close_status_types.sql`, `t1_j3` (packs; SQL text in this doc's appendix), `t1_j4_early_vs_later.sql`. Results: `results/*.csv` (J4 CSV holds the key cells; rerun the query for every cell).
The journey section (J1–J4) comes first; the earlier baseline findings F1–F6 follow it.

# Part I. What first-album players experience (journey, J1–J4)
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
