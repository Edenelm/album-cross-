# FU18 A/B test: Album FU 3 vs 5 locked (Domino Dreams, album 18): queries + summary

> **Handoff for Claude Code.** Built 2026-10-29 from the box work in `/workspace/dom19/` (queries ran 2026-10-27/28, read-only, BigQuery project `domino-dreams-dbt`).
> Every number below was re-checked against the saved outputs (`recut.json`, `pt.json`, `coinsph.json`, `gpflow.json`, `q26/q27 csv`) or comes straight from canvas section F. Anything not confirmed is marked **[unconfirmed]**.
> Labels: **Test = 3 locked** (FU at 3 missing), **Control = 5 locked** (FU at 5 missing). Segment = **Easy** unless stated.
> Deck: Domino-focused Google Slides `1bVGI1Sb49fJ-a4Cp8AHs5hTOYjrTuQlJbW9vStaJr1o`, FU slides **135–138** (1-based).

---

## 1. TL;DR (final approved numbers)

- **3 locked did not cost album revenue.** Easy $ per player in the test window (06-28..07-05) was −0.95% [−4.05, +2.15], but the test group was already −1.10% [−3.60, +1.39] *before* the test (05-11..06-27). Net of that pre-test gap: **+0.16% (≈ 0)**. The FU deck's −1.75% is inside noise (A/A SD 1.53%; 25% of random 50/50 splits are ≥1.75% apart). Payers in the window +0.19 pp (14.26% vs 14.06%).
- **Finishers 2.6× and money moved to finishing.** Finished album 18 by 07-05: **3.36% vs 1.27%** (+2.09 pp ±0.07). Share of Easy window revenue: finished **42% vs 29%**, 1–2 missing 30% vs 20%, 3–5 missing **17% vs 38%**, 6+ missing 10% vs 13%. Under 5 locked, 38% of Easy revenue was parked at 3–5 missing.
- **The one real cost: a short dip after album 18.** On the A/B-test definition (q27, ~627K per group): 3 locked spent **−5.36%** per player in the 14 days after close (07-07..07-20) vs a usual gap of **−1.28%** (05-12..07-02) → **≈ −4 pts dip**. It fades during album 19 (−2.62%, 07-21..08-24) and is gone by album 19's end (**−0.62%**, 08-25..09-07). Earlier pooled-ratio method (q23/q24, level-35+ proxy): **−4.4% [−8.0, −0.5]**, **net of album 17 placebo −5.2% [−9.6, −0.6]**; album 19 +2.5% [−1.0, +5.9]. Payers per day unchanged (1.28% vs 1.30%), so it is lower spend per payer, not fewer payers.
- **It is not the GP (grand-prize) coins: they explain ~0%.** GP per finisher median 179 vs 176 units; finisher balance at end of 07-06 median 2.9 vs 3.9 units (no stockpile); GP funded 0.9% vs 0.3% of all Easy players' coin spend 07-07..08-04. Phase-matched, net of album 17: **coins bought −0.7% [−4.9, +4.2] vs in-app $ −5.2%**; raw −2.7% [−5.7, +1.0] vs −4.4%.
- **Recommendation:** go back to **3 locked for Easy** (album 19 ran Easy at 5 locked and had the lowest Easy finish rate 0.96% and weakest Easy end lift +7.2% of albums 18–20), add a mechanic for players left 1–2 short (targeted last-sticker offer or Golden pick), and judge future FU tests on the month after the album, not only the test window.

---

## 2. Test definition

| Item | Value |
|---|---|
| Test | "1553- Album Fu (3 Vs 5)"; Monday Domino AB board item 12367261562 (status Deployed) |
| Official board | Mixpanel project 2735821, board **11315328** (read 2026-10-28) |
| Split | `server_user_id % 997` → 997 buckets |
| **BQ mapping used everywhere** | `MOD(server_user_id, 997) < 498` → **Test = 3 locked** (498 buckets); `>= 498` → **Control = 5 locked** (499 buckets) |
| Evidence for the mapping | (1) Players stuck at exactly 3 vs 5 missing line up with this mapping. (2) BQ MOD<498 reproduces Mixpanel "Test Group" counts on Easy active players (345,727 vs 346,602) and completers (13,076 vs 13,601). (3) Group sizes 336,223 (MOD<498) vs 336,942 fit Test having 498 buckets. (4) Finishers: MOD<498 has 11,300 Easy finishers vs 4,292 (3 locked → more finishers). |
| **Label conflict** | The board's formula *text* labels `% 997 < 498` as "Control Group". Behaviour says it got 3 locked. Treat the formula label as wrong. The board's bucket scaling (Test ÷499, Control ÷498) is therefore backwards; per-player figures are used instead. |
| Raw labels in older outputs | `q14_fu_recut.sql` and `recut.json` still use **raw** labels (`MOD<498 = 'Control'`). `recut.py` swaps them on load (`lab={'Control':'Test','Test':'Control'}`), so its printed results are correct. From q18 onward the SQL uses the flipped (correct) labels directly (`IF(MOD(sid,997)<498,'Test','Control')`). **Never reuse recut.json without the swap.** |
| Test dates | Test live **06-28 .. 07-06** (album 18 day −8 to close; board window 06-28 10:00..07-06; board post window 07-06..07-20). Only the test group could start completing Set 11 from 06-28. |
| Album windows (date_dim) | Album 17: 04-02 .. 05-11 · Album 18: 05-11 .. 07-06 (56 days, 168 stickers) · Album 19: 07-06 .. 08-24 (144 stickers). Albums run back to back (close day = next open day). |
| Phase windows (q23–q25) | Rest of album = player's first album day (≥ open+1) .. close−4; last 4 days = close−3 .. close; after = close+1 .. close+14. Album 18: rest 05-12..07-02, last-4 07-03..07-06, after 07-07..07-20. Album 17 after 05-12..05-25. Album 19 after 08-25..09-07. "18pre" = album 18 rest window cut at 06-27 (pre-test only). |
| Population A: **A/B definition** (q27, slide 137 v5) | All album-18 players with an Easy `album_segment` (any activity), `server_user_id` not null, not special and not deactivated on any day 04-03..09-07. 3 locked **626,792**, 5 locked **628,564**. Revenue = gross in-app $ counted only on days with `level_id_end_day >= 35` (board's Level ID ≥ 35 filter, applied per day). No cheater filter (board has none in BQ form). |
| Population B: **level-35+ proxy** (q14–q26, slides 135, 136, 138) | Album 18 players active 06-28..07-05, `special_user_flag = FALSE`, no `suspected_cheater_flag` 05-11..08-04, max `level_id_end_day` in 06-28..07-05 ≥ 35. Easy: Test **336,223**, Control **336,942**. Hard: 4,391 vs 4,325. |
| Revenue fields | Album $ = `user_daily_album.album_spent_today`; in-app $ = `user_daily_metrics.user_daily_inapp_purchase_amount` (gross). |
| End state (album 18) | missing = 168 − `unique_album_stickers_lt` at end of 07-05: fin (0), m12 (1–2), m35 (3–5), m6 (6+). |

---

## 3. Methods

- **Pooled group ratio, not per-player.** After ratio = group Σ$ in the 14 days after close ÷ (14 × N) divided by group Σ$ in rest-of-album ÷ Σ player-days. Test vs control = ratio of the two group ratios − 1. End ratio is the same with the last 4 days. ~78% of Easy players spend $0 mid-album, so per-player ratios are undefined/zero for most (per-player medians are 0); they are reported only as a top-1%-trimmed mean side check (album 18: −4.3% [−5.6, −1.3]).
- **Zero baselines.** Players with no rest-of-album days (`rd = 0`) or $0 mid-album stay in the pooled ratio (they add to numerator and N) but are excluded from per-player ratios (`er/ar = NULL`). Their share of after-window $ is reported (album 18: 9.7% / 8.8%).
- **Bootstrap.** 100-replicate **Poisson bootstrap by player** in SQL: weight w ~ Poisson(1) from `FARM_FINGERPRINT(user_id || '-' || rep)` mapped through the Poisson(1) CDF (0–6). 95% CI = 2.5th/97.5th percentile (`APPROX_QUANTILES(x,40)[1]/[39]`). With 100 reps the CI ends are approximate; a delta-method check for the Easy album 18 net gave [−9.5, −0.8] vs bootstrap [−9.6, −0.6]. Trim cutoffs (p99) are fixed from the full sample.
- **Net of album 17 (placebo).** `(1 + d18) / (1 + d17) − 1` on the **full-sample point estimates** (not bootstrap means): (1 − 0.0441)/(1 + 0.0087) − 1 = **−5.24%**. CI from the same formula per replicate.
- **Window lifts (q14/recut.py, q18/stock.py).** Mean $ per player, lift = mt/mc − 1, normal-approx CI with delta method on per-player sums of squares; "adjusted for pre-test gap" = (1 + lift_window)/(1 + lift_pre) − 1.
- **Daily lines (q26/q27, slide 137).** $ per player per day = group daily revenue ÷ fixed group size; window gaps = Σrev/N ratio. Slide shows a 7-day centred average.
- **A/A (q13).** 200 random 50/50 splits of Easy album 18 players (`FARM_FINGERPRINT(user_id-seed) mod 2`), no treatment.
- **Coins (q20/q25).** Units = `COALESCE(amount, coins) ÷ coins_allowance` from staging coin events; events outside 0–1000 units dropped (< 0.01%). Coins bought = sources `purchase`, `purchase_gift`, `store bundle gift`. GP = source `album completed` 06-28..07-06. In-app $ includes non-coin items, so $/coin unit is not a price.

---

## 4. Results table

| # | Number (Easy, test 3 vs control 5) | Value | Query → output → script | Slide |
|---|---|---|---|---|
| R1 | $/player before test 05-11..06-27 (album $) | $15.43 vs $15.60, **−1.10%** [−3.60, +1.39] | q14 → recut.json → recut.py | 135 |
| R2 | $/player test window 06-28..07-05 (album $) | $3.98 vs $4.02, **−0.95%** [−4.05, +2.15] | q14 → recut.py | 135 |
| R3 | Window net of pre-test gap | **+0.16%** (board window in-app 06-28..07-06: −1.96% raw, −0.87% adj.) | recut.py | 135 |
| R4 | Last 4 days 07-02..07-05 | −0.86% [−4.12, +2.40] | q14 → recut.py | 135 notes |
| R5 | Paid in window | 14.26% vs 14.06%, +0.19 pp [±0.17] | q14 → recut.py | 135 notes |
| R6 | A/A noise SD / share of splits ≥1.75% apart | 1.53% / 25% | q13 → aa.csv | 135 notes |
| R7 | Finished album 18 by 07-05 | **3.36% vs 1.27%** (2.6×), +2.09 pp [±0.07]; Hard 29.92% vs 19.61% | q14 → recut.py | 136 |
| R8 | Share of window revenue by end state (fin / 1–2 / 3–5 / 6+) | **42/30/17/10% vs 29/20/38/13%** | q14 (rfin..rm6) → recut.py | 136 |
| R9 | Share of players by end state | 3.36/7.56/13.34/75.75% vs 1.27/2.51/16.08/80.13% | q14 → recut.py | 136 notes |
| R10 | Daily $/player gap, 14 days after album 18 (A/B def.) | **−5.36%** ($0.1527 vs $0.1614/day); proxy q26 −5.57% | q27 → q27_daily_lines_official.csv → preview_137_v5.py / native_v5.py | **137 (v5)** |
| R11 | Usual gap 05-12..07-02 (A/B def.) | **−1.28%** (proxy −1.23%) | q27 | 137 |
| R12 | During album 19 07-21..08-24 / after album 19 08-25..09-07 | −2.62% / **−0.62%** (proxy −3.18% / −1.59%) | q27 | 137 |
| R13 | After album 17 05-12..05-25 / album 18 end 06-28..07-06 | −0.88% / −1.93% | q27 | 137 notes |
| R14 | Payers per day in the dip window | 1.28% vs 1.30% (proxy 2.34% vs 2.37%) | q27 / q26 | 137 |
| R15 | After ratio 17 / 18 / 19 (pooled) | +0.9% [−2.1, +3.6] / **−4.4% [−8.0, −0.5]** / +2.5% [−1.0, +5.9] | q23 → pt.json (point); q24 → bs.json (CI) | canvas F; 137 v3 (replaced) |
| R16 | After ratio album 18 net of 17 | **−5.2% (−5.24%) [−9.6, −0.6]**; pre-test-only baseline −4.5% (net −5.3%) | q23 + q24 | canvas F; 138 callout |
| R17 | End ratio 17 / 18 / 19 | −0.6% / −0.8% / +1.3% (no end difference) | q23 + q24 | canvas F |
| R18 | Share of album-18 $ (album-18 days only) by end state | fin 26.6/16.3, 1–2 26.8/14.4, 3–5 25.6/42.9, 6+ 21.0/26.4% | q23 → pt.json (s_rest+s_end, v=18) | 137 v3 (replaced); notes |
| R19 | Coins bought after ratio, album 18 / net of 17 | −2.7% [−5.7, +1.0] / **−0.7% [−4.9, +4.2]** | q25 → coinsph.json | 138 |
| R20 | GP per finisher median (p99-trimmed mean) | 179 vs 176 (186 vs 182) units | q20 → gpflow.json | 138 notes |
| R21 | Finisher balance end of 07-06, median | 2.9 vs 3.9 units | q20 (rv_0706) → gpflow.json; validated by q21 | 138 notes |
| R22 | Post coin spend 07-07..08-04 funded by GP (all Easy players) | **0.9% vs 0.3%** (finishers only: 5.0% vs 3.6%) | q20 → gp.py → gp_sum.json | **138** (see caveat C9) |
| R23 | Calendar post-test 07-07..08-04 (superseded) | raw −4.70% [−7.98, −1.42]; pre-adj −3.30% | q18 → stock.json → stock.py | none (replaced) |
| R24 | Album 19 outcomes by group | finished 1.04% vs 1.05%; exactly 5 missing 4.39% vs 4.44% (treatment did not continue) | q18 → stock.py | none |

Dropped numbers that must not reappear: −3.30% (calendar), 4-week weekly gap, $17.93 vs $18.70, "+4.8% coins bought", Mixpanel cross-check −1.40% / +1.41% (scaling backwards; corrected ≈ −1.0% revenue, +1.8% payers).

---

## 5. Queries

All BigQuery Standard SQL, `domino-dreams-dbt`, SELECT-only. Ordered by importance. **[DIAG]** = diagnostic only, not behind a deck number.

### Python scripts (paths only)

| Script | Purpose |
|---|---|
| `/workspace/dom19/recut.py` | Reads `recut.json` (q14), **swaps raw labels**, prints lifts, CIs, P(T>C), payer/finisher rates, revenue share by end state (R1–R9). |
| `/workspace/dom19/stock.py` | Reads `stock.json` (q18): calendar pre/post lifts, weekly gaps, end-state decomposition, album 19 outcomes, balances (R23–R24; superseded). |
| `/workspace/dom19/gp.py` | Reads `gpflow.json` (q20) + `stock.json`: GP units, coin-flow shares, max $ explainable by GP → `gp_sum.json` (R22). |
| `/workspace/slides/fu18/preview_137_v5.py`, `v5/chart_v5.py`, `v5/native_v5.py` | Slide 137 v5 line chart from `q27_daily_lines_official.csv` (7-day centred); native = editable Slides shapes. |
| `/workspace/slides/fu18/fu18_v3.py` | Current v3 builds of slides 135, 136, 138 (and old 137) + notes. `fu18_slides.py` = v1/v2. |
| *(not saved)* | Summaries of `pt.json` / `bs.json` / `coinsph.json` (ratio-of-ratios, net-of-17, CI picking) were done inline; formulas are in §3 and are easy to recompute. |

### 5.1 `q27_daily_lines_official.sql`
**Slide 137 (v5).** Easy daily in-app $ per player, 3 vs 5 locked, on the closest BQ copy of the official A/B board definition.  
In: user_daily_album (album 18 Easy), user_daily_metrics 04-03..09-07. Out: `q27_daily_lines_official.csv` (grp, dd, n, rev, payers, rev_all_lvls, rev_pp, payer_rate).

```sql
-- q27: Easy $ per player per day, 3 locked vs 5 locked, closest BQ copy of the official A/B board
-- (Mixpanel Domino board 11315328 "1553- Album Fu (3 Vs 5)", read 2026-10-28).
-- Board rules -> BQ:
--   Groups property set (server_user_id % 997)          -> server_user_id NOT NULL; MOD(sid,997) < 498 = Test (3 locked),
--                                                          per Page section F verification (matches Mixpanel "Test Group" counts
--                                                          and players stuck at 3 vs 5 missing). NOTE the board formula text says
--                                                          <498 = "Control Group"; see report.
--   Excluded User = false (special / status / deactivated) -> special_user_flag = FALSE AND deactivated_user_flag = FALSE
--   Suspected Fraudulent Purchase = false (event level)    -> NOT reproducible in marts; no cheater filter applied (board has none)
--   Cohort 6106615 "Relevant Users"                        -> NOT reproducible (404, not in cohort list); replaced by:
--                                                          album 18 players with an Easy album_segment (any activity)
--   Level ID >= 35 (event filter on the purchase)          -> revenue counted only on days with level_id_end_day >= 35
--   KPI Sum of Gross Revenue on purchase completed         -> user_daily_inapp_purchase_amount (gross in-app)
-- SELECT only; no writes.
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    LOGICAL_OR(LOWER(a.album_segment) LIKE '%easy%') AS easy, LOGICAL_OR(a.special_user_flag) AS sp
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18
  GROUP BY 1),
d AS (
  SELECT m.user_id, m.date_dim dd, m.user_daily_inapp_purchase_amount amt, m.level_id_end_day lvl,
    m.special_user_flag sp, m.deactivated_user_flag de
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m
  WHERE m.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07'),
ex AS (SELECT user_id FROM d GROUP BY 1 HAVING LOGICAL_OR(IFNULL(sp, FALSE) OR IFNULL(de, FALSE))),
pop AS (
  SELECT a.user_id, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp
  FROM a LEFT JOIN ex USING (user_id)
  WHERE a.sid IS NOT NULL AND a.easy AND NOT IFNULL(a.sp, FALSE) AND ex.user_id IS NULL),
gs AS (SELECT grp, COUNT(*) n FROM pop GROUP BY 1),
day AS (
  SELECT p.grp, d.dd,
    SUM(IF(d.lvl >= 35, d.amt, 0)) rev, COUNT(DISTINCT IF(d.lvl >= 35 AND d.amt > 0, d.user_id, NULL)) payers,
    SUM(d.amt) rev_all_lvls
  FROM d JOIN pop p USING (user_id)
  WHERE d.amt > 0
  GROUP BY 1, 2)
SELECT day.grp, day.dd, gs.n, day.rev, day.payers, day.rev_all_lvls, day.rev / gs.n AS rev_pp, day.payers / gs.n AS payer_rate
FROM day JOIN gs USING (grp)
ORDER BY day.dd, day.grp
```

### 5.2 `q14_fu_recut.sql`
**Slides 135, 136.** Album 18 re-cut by real group (level-35+ proxy): sums/sums of squares for pre, window, last-4, in-app window, post; payers; end states; revenue by end state. ⚠ **Raw labels** (`MOD<498 = 'Control'`); recut.py swaps.  
In: user_daily_album, user_daily_metrics. Out: `recut.json` → `recut.py`.

```sql
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    SUM(IF(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', IFNULL(a.album_spent_today, 0), 0)) AS r_win,
    SUM(IF(a.date_dim BETWEEN DATE '2026-07-02' AND DATE '2026-07-05', IFNULL(a.album_spent_today, 0), 0)) AS r_last,
    SUM(IF(a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-06-27', IFNULL(a.album_spent_today, 0), 0)) AS r_pre,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    MAX(IF(a.date_dim <= DATE '2026-06-27', a.unique_album_stickers_lt, NULL)) AS uniq_pre,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
m AS (
  SELECT m.user_id,
    MAX(IF(m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', m.level_id_end_day, NULL)) AS lvl,
    SUM(IF(m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-06', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS iap_win,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS iap_post
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-08-04'
  GROUP BY 1),
u AS (
  SELECT a.*, m.lvl, IFNULL(m.iap_win, 0) AS iap_win, IFNULL(m.iap_post, 0) AS iap_post,
    IF(MOD(a.sid, 997) < 498, 'Control', 'Test') AS grp,
    168 - IFNULL(a.uniq_end, 0) AS miss
  FROM a LEFT JOIN m USING (user_id)
  WHERE a.sid IS NOT NULL AND IFNULL(m.lvl, 0) >= 35)
SELECT seg, grp, COUNT(*) AS n,
  SUM(r_win) s_win, SUM(r_win*r_win) q_win,
  SUM(r_last) s_last, SUM(r_last*r_last) q_last,
  SUM(r_pre) s_pre, SUM(r_pre*r_pre) q_pre,
  SUM(iap_win) s_iap, SUM(iap_win*iap_win) q_iap,
  SUM(iap_post) s_post, SUM(iap_post*iap_post) q_post,
  COUNTIF(r_win > 0) payers, COUNTIF(iap_win > 0) iap_payers,
  COUNTIF(miss <= 0) fin, COUNTIF(miss BETWEEN 1 AND 2) m12, COUNTIF(miss BETWEEN 3 AND 5) m35, COUNTIF(miss >= 6) m6,
  SUM(IF(miss <= 0, r_win, 0)) rfin, SUM(IF(miss BETWEEN 1 AND 2, r_win, 0)) rm12, SUM(IF(miss BETWEEN 3 AND 5, r_win, 0)) rm35, SUM(IF(miss >= 6, r_win, 0)) rm6,
  COUNTIF(168 - IFNULL(uniq_pre,0) BETWEEN 1 AND 5) pre_m15, COUNTIF(168 - IFNULL(uniq_pre,0) <= 0) pre_fin,
  MIN(miss) min_miss, COUNTIF(sid < 0) neg_sid
FROM u GROUP BY 1, 2 ORDER BY 1, 2
```

### 5.3 `q23_phase_pt.sql`
Phase-matched point estimates: end ratio and after ratio per group × end state × album (17, 18, 18pre, 19), plus zero-baseline counts, medians, trimmed means.  
In: user_daily_album (albums 17–19), user_daily_metrics. Out: `pt.json` (`pt_raw.txt`).

```sql
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
alb AS (
  SELECT a, s, c FROM UNNEST([STRUCT(17 AS a, DATE '2026-04-02' AS s, DATE '2026-05-11' AS c),
    STRUCT(18, DATE '2026-05-11', DATE '2026-07-06'), STRUCT(19, DATE '2026-07-06', DATE '2026-08-24')])),
ua AS (
  SELECT x.user_id, x.album_id a, MIN(x.date_dim) f
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x JOIN pop p ON p.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-24' AND x.album_id IN (17, 18, 19)
  GROUP BY 1, 2),
m AS (
  SELECT d.user_id, d.date_dim dd, d.user_daily_inapp_purchase_amount amt
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` d JOIN pop p ON p.user_id = d.user_id
  WHERE d.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07' AND d.user_daily_inapp_purchase_amount > 0),
pa AS (
  SELECT p.user_id, p.seg, p.grp, p.st, alb.a, alb.c, GREATEST(ua.f, DATE_ADD(alb.s, INTERVAL 1 DAY)) f2
  FROM pop p JOIN ua USING (user_id) JOIN alb ON alb.a = ua.a),
pu0 AS (
  SELECT pa.user_id, ANY_VALUE(pa.seg) seg, ANY_VALUE(pa.grp) grp, ANY_VALUE(pa.st) st, pa.a,
    GREATEST(DATE_DIFF(DATE_SUB(ANY_VALUE(pa.c), INTERVAL 4 DAY), ANY_VALUE(pa.f2), DAY) + 1, 0) rd,
    GREATEST(DATE_DIFF(DATE '2026-06-27', ANY_VALUE(pa.f2), DAY) + 1, 0) rdp,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE_SUB(pa.c, INTERVAL 4 DAY), m.amt, 0)) rest,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE '2026-06-27', m.amt, 0)) restp,
    SUM(IF(m.dd BETWEEN DATE_SUB(pa.c, INTERVAL 3 DAY) AND pa.c, m.amt, 0)) endd,
    SUM(IF(m.dd BETWEEN DATE_ADD(pa.c, INTERVAL 1 DAY) AND DATE_ADD(pa.c, INTERVAL 14 DAY), m.amt, 0)) aft
  FROM pa LEFT JOIN m ON m.user_id = pa.user_id AND m.dd BETWEEN pa.f2 AND DATE_ADD(pa.c, INTERVAL 14 DAY)
  GROUP BY pa.user_id, pa.a),
pv AS (
  SELECT user_id, seg, grp, st, CAST(a AS STRING) v, rd, rest, endd, aft FROM pu0
  UNION ALL
  SELECT user_id, seg, grp, st, '18pre', rdp, restp, endd, aft FROM pu0 WHERE a = 18),
pu AS (
  SELECT user_id, seg, grp, s2 st, v, rd, rest, endd, aft,
    IF(rd > 0 AND rest > 0, (endd / 4) / (rest / rd), NULL) er,
    IF(rd > 0 AND rest > 0, (aft / 14) / (rest / rd), NULL) ar
  FROM pv CROSS JOIN UNNEST([st, 'all']) s2),
cut AS (
  SELECT seg, grp, st, v, APPROX_QUANTILES(er, 100)[OFFSET(99)] ce, APPROX_QUANTILES(ar, 100)[OFFSET(99)] ca
  FROM pu GROUP BY 1, 2, 3, 4)
SELECT pu.seg, pu.grp, pu.st, pu.v, COUNT(*) n, COUNTIF(rd = 0) n_norest, COUNTIF(rd > 0 AND rest = 0) n_zero,
  SUM(rd) s_rd, SUM(rest) s_rest, SUM(endd) s_end, SUM(aft) s_aft,
  SUM(IF(er IS NULL, endd, 0)) s_end_z, SUM(IF(er IS NULL, aft, 0)) s_aft_z,
  SUM(IF(er IS NULL AND rd > 0, endd, 0)) s_end_z0, SUM(IF(er IS NULL AND rd > 0, aft, 0)) s_aft_z0,
  APPROX_QUANTILES(er, 2)[OFFSET(1)] med_er, APPROX_QUANTILES(ar, 2)[OFFSET(1)] med_ar,
  AVG(IF(er <= cut.ce, er, NULL)) tm_er, AVG(IF(ar <= cut.ca, ar, NULL)) tm_ar,
  COUNTIF(er > 0) n_er_pos, COUNTIF(ar > 0) n_ar_pos, COUNTIF(er IS NOT NULL) n_base,
  APPROX_QUANTILES(er, 4)[OFFSET(1)] q1_er, APPROX_QUANTILES(er, 4)[OFFSET(3)] q3_er,
  APPROX_QUANTILES(ar, 4)[OFFSET(1)] q1_ar, APPROX_QUANTILES(ar, 4)[OFFSET(3)] q3_ar
FROM pu JOIN cut USING (seg, grp, st, v)
GROUP BY 1, 2, 3, 4 ORDER BY 1, 3, 4, 2
```

### 5.4 `q24_phase_bs.sql`
Same population/phases as q23 with a 100-rep Poisson bootstrap → 95% CIs for test-vs-control and net-of-17.  
Out: `bs.json` (`bs_raw.txt`).

```sql
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
alb AS (
  SELECT a, s, c FROM UNNEST([STRUCT(17 AS a, DATE '2026-04-02' AS s, DATE '2026-05-11' AS c),
    STRUCT(18, DATE '2026-05-11', DATE '2026-07-06'), STRUCT(19, DATE '2026-07-06', DATE '2026-08-24')])),
ua AS (
  SELECT x.user_id, x.album_id a, MIN(x.date_dim) f
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x JOIN pop p ON p.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-24' AND x.album_id IN (17, 18, 19)
  GROUP BY 1, 2),
m AS (
  SELECT d.user_id, d.date_dim dd, d.user_daily_inapp_purchase_amount amt
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` d JOIN pop p ON p.user_id = d.user_id
  WHERE d.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07' AND d.user_daily_inapp_purchase_amount > 0),
pa AS (
  SELECT p.user_id, p.seg, p.grp, p.st, alb.a, alb.c, GREATEST(ua.f, DATE_ADD(alb.s, INTERVAL 1 DAY)) f2
  FROM pop p JOIN ua USING (user_id) JOIN alb ON alb.a = ua.a),
pu0 AS (
  SELECT pa.user_id, ANY_VALUE(pa.seg) seg, ANY_VALUE(pa.grp) grp, ANY_VALUE(pa.st) st, pa.a,
    GREATEST(DATE_DIFF(DATE_SUB(ANY_VALUE(pa.c), INTERVAL 4 DAY), ANY_VALUE(pa.f2), DAY) + 1, 0) rd,
    GREATEST(DATE_DIFF(DATE '2026-06-27', ANY_VALUE(pa.f2), DAY) + 1, 0) rdp,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE_SUB(pa.c, INTERVAL 4 DAY), m.amt, 0)) rest,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE '2026-06-27', m.amt, 0)) restp,
    SUM(IF(m.dd BETWEEN DATE_SUB(pa.c, INTERVAL 3 DAY) AND pa.c, m.amt, 0)) endd,
    SUM(IF(m.dd BETWEEN DATE_ADD(pa.c, INTERVAL 1 DAY) AND DATE_ADD(pa.c, INTERVAL 14 DAY), m.amt, 0)) aft
  FROM pa LEFT JOIN m ON m.user_id = pa.user_id AND m.dd BETWEEN pa.f2 AND DATE_ADD(pa.c, INTERVAL 14 DAY)
  GROUP BY pa.user_id, pa.a),
pv AS (
  SELECT user_id, seg, grp, st, CAST(a AS STRING) v, rd, rest, endd, aft FROM pu0
  UNION ALL
  SELECT user_id, seg, grp, st, '18pre', rdp, restp, endd, aft FROM pu0 WHERE a = 18),
pu AS (
  SELECT user_id, seg, grp, s2 st, v, rd, rest, endd, aft,
    IF(rd > 0 AND rest > 0, (endd / 4) / (rest / rd), NULL) er,
    IF(rd > 0 AND rest > 0, (aft / 14) / (rest / rd), NULL) ar
  FROM pv CROSS JOIN UNNEST([st, 'all']) s2),
cut AS (
  SELECT seg, grp, st, v, APPROX_QUANTILES(er, 100)[OFFSET(99)] ce, APPROX_QUANTILES(ar, 100)[OFFSET(99)] ca
  FROM pu GROUP BY 1, 2, 3, 4),
bw AS (
  SELECT seg, grp, st, v, r,
    CASE WHEN u < 0.367879 THEN 0 WHEN u < 0.735759 THEN 1 WHEN u < 0.919699 THEN 2 WHEN u < 0.981012 THEN 3
         WHEN u < 0.996340 THEN 4 WHEN u < 0.999406 THEN 5 ELSE 6 END w,
    rd, rest, endd, aft, ert, art
  FROM (
    SELECT pu.seg, pu.grp, pu.st, pu.v, r, pu.rd, pu.rest, pu.endd, pu.aft,
      IF(pu.er <= cut.ce, pu.er, NULL) ert, IF(pu.ar <= cut.ca, pu.ar, NULL) art,
      MOD(ABS(FARM_FINGERPRINT(CONCAT(CAST(pu.user_id AS STRING), '-', CAST(r AS STRING)))), 1000000) / 1e6 u
    FROM pu JOIN cut USING (seg, grp, st, v), UNNEST(GENERATE_ARRAY(1, 100)) AS r)),
g AS (
  SELECT seg, grp, st, v, r,
    SAFE_DIVIDE(SUM(w * endd) / (4 * SUM(w)), SUM(w * rest) / SUM(w * rd)) ge,
    SAFE_DIVIDE(SUM(w * aft) / (14 * SUM(w)), SUM(w * rest) / SUM(w * rd)) ga,
    SAFE_DIVIDE(SUM(IF(ert IS NOT NULL, w * ert, 0)), SUM(IF(ert IS NOT NULL, w, 0))) te,
    SAFE_DIVIDE(SUM(IF(art IS NOT NULL, w * art, 0)), SUM(IF(art IS NOT NULL, w, 0))) ta
  FROM bw GROUP BY 1, 2, 3, 4, 5),
tc AS (
  SELECT t.seg, t.st, t.v, t.r, t.ge / c.ge - 1 de, t.ga / c.ga - 1 da, t.te / c.te - 1 dte, t.ta / c.ta - 1 dta,
    t.ge, c.ge cge, t.ga, c.ga cga
  FROM g t JOIN g c ON c.seg = t.seg AND c.st = t.st AND c.v = t.v AND c.r = t.r AND t.grp = 'Test' AND c.grp = 'Control'),
did AS (
  SELECT x.seg, x.st, CONCAT(x.v, '_vs_17') v, x.r, (1 + x.de) / (1 + y.de) - 1 de, (1 + x.da) / (1 + y.da) - 1 da,
    (1 + x.dte) / (1 + y.dte) - 1 dte, (1 + x.dta) / (1 + y.dta) - 1 dta, NULL ge, NULL cge, NULL ga, NULL cga
  FROM tc x JOIN tc y ON y.seg = x.seg AND y.st = x.st AND y.r = x.r AND y.v = '17' AND x.v IN ('18', '18pre', '19'))
SELECT seg, st, v, COUNT(*) reps,
  APPROX_QUANTILES(de, 40)[OFFSET(1)] de_lo, APPROX_QUANTILES(de, 40)[OFFSET(39)] de_hi,
  APPROX_QUANTILES(da, 40)[OFFSET(1)] da_lo, APPROX_QUANTILES(da, 40)[OFFSET(39)] da_hi,
  APPROX_QUANTILES(dte, 40)[OFFSET(1)] dte_lo, APPROX_QUANTILES(dte, 40)[OFFSET(39)] dte_hi,
  APPROX_QUANTILES(dta, 40)[OFFSET(1)] dta_lo, APPROX_QUANTILES(dta, 40)[OFFSET(39)] dta_hi,
  AVG(de) de_m, AVG(da) da_m
FROM (SELECT seg, st, v, r, de, da, dte, dta FROM tc UNION ALL SELECT seg, st, v, r, de, da, dte, dta FROM did)
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
```

### 5.5 `q25_coins_phase.sql`
**Slide 138 callout.** Same phase design as q23/q24, but on coins bought (staging coin-in units). Rep 0 = full sample.  
In: + prod_10_staging.stg_coins_in_vw. Out: `coinsph.json` (`coins_raw.txt`).

```sql
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
alb AS (
  SELECT a, s, c FROM UNNEST([STRUCT(17 AS a, DATE '2026-04-02' AS s, DATE '2026-05-11' AS c),
    STRUCT(18, DATE '2026-05-11', DATE '2026-07-06'), STRUCT(19, DATE '2026-07-06', DATE '2026-08-24')])),
ua AS (
  SELECT x.user_id, x.album_id a, MIN(x.date_dim) f
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x JOIN pop p ON p.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-24' AND x.album_id IN (17, 18, 19)
  GROUP BY 1, 2),
m AS (
  SELECT i.user_id, i.pdate dd, SUM(IF(SAFE_DIVIDE(COALESCE(i.amount, i.coins), i.coins_allowance) BETWEEN 0 AND 1000, SAFE_DIVIDE(COALESCE(i.amount, i.coins), i.coins_allowance), 0)) amt
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw` i JOIN pop p ON p.user_id = i.user_id
  WHERE i.pdate BETWEEN DATE '2026-04-03' AND DATE '2026-09-07' AND i.source IN ('purchase', 'purchase_gift', 'store bundle gift')
  GROUP BY 1, 2),
pa AS (
  SELECT p.user_id, p.seg, p.grp, p.st, alb.a, alb.c, GREATEST(ua.f, DATE_ADD(alb.s, INTERVAL 1 DAY)) f2
  FROM pop p JOIN ua USING (user_id) JOIN alb ON alb.a = ua.a),
pu0 AS (
  SELECT pa.user_id, ANY_VALUE(pa.seg) seg, ANY_VALUE(pa.grp) grp, ANY_VALUE(pa.st) st, pa.a,
    GREATEST(DATE_DIFF(DATE_SUB(ANY_VALUE(pa.c), INTERVAL 4 DAY), ANY_VALUE(pa.f2), DAY) + 1, 0) rd,
    GREATEST(DATE_DIFF(DATE '2026-06-27', ANY_VALUE(pa.f2), DAY) + 1, 0) rdp,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE_SUB(pa.c, INTERVAL 4 DAY), m.amt, 0)) rest,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE '2026-06-27', m.amt, 0)) restp,
    SUM(IF(m.dd BETWEEN DATE_SUB(pa.c, INTERVAL 3 DAY) AND pa.c, m.amt, 0)) endd,
    SUM(IF(m.dd BETWEEN DATE_ADD(pa.c, INTERVAL 1 DAY) AND DATE_ADD(pa.c, INTERVAL 14 DAY), m.amt, 0)) aft
  FROM pa LEFT JOIN m ON m.user_id = pa.user_id AND m.dd BETWEEN pa.f2 AND DATE_ADD(pa.c, INTERVAL 14 DAY)
  GROUP BY pa.user_id, pa.a),
pv AS (
  SELECT user_id, seg, grp, st, CAST(a AS STRING) v, rd, rest, endd, aft FROM pu0
  UNION ALL
  SELECT user_id, seg, grp, st, '18pre', rdp, restp, endd, aft FROM pu0 WHERE a = 18),
pu AS (
  SELECT user_id, seg, grp, s2 st, v, rd, rest, endd, aft,
    IF(rd > 0 AND rest > 0, (endd / 4) / (rest / rd), NULL) er,
    IF(rd > 0 AND rest > 0, (aft / 14) / (rest / rd), NULL) ar
  FROM pv CROSS JOIN UNNEST([st, 'all']) s2),
g AS (
  SELECT seg, grp, st, v, r, SUM(w) n,
    SAFE_DIVIDE(SUM(w * endd) / (4 * SUM(w)), SUM(w * rest) / SUM(w * rd)) ge,
    SAFE_DIVIDE(SUM(w * aft) / (14 * SUM(w)), SUM(w * rest) / SUM(w * rd)) ga,
    SUM(w * rest) srest, SUM(w * endd) send, SUM(w * aft) saft, SUM(w * rd) srd
  FROM (
    SELECT seg, grp, st, v, r, rd, rest, endd, aft,
      CASE WHEN u < 0 THEN 1 WHEN u < 0.367879 THEN 0 WHEN u < 0.735759 THEN 1 WHEN u < 0.919699 THEN 2 WHEN u < 0.981012 THEN 3
           WHEN u < 0.996340 THEN 4 WHEN u < 0.999406 THEN 5 ELSE 6 END w
    FROM (
      SELECT pu.seg, pu.grp, pu.st, pu.v, r, pu.rd, pu.rest, pu.endd, pu.aft,
        IF(r = 0, -1, MOD(ABS(FARM_FINGERPRINT(CONCAT(CAST(pu.user_id AS STRING), '-', CAST(r AS STRING)))), 1000000) / 1e6) u
      FROM pu, UNNEST(GENERATE_ARRAY(0, 100)) AS r)
    WHERE st = 'all' OR v != '18pre')
  GROUP BY 1, 2, 3, 4, 5)
SELECT t.seg, t.st, t.v, t.r, t.n tn, c.n cn, t.ge tge, c.ge cge, t.ga tga, c.ga cga, t.srest, c.srest csrest, t.saft, c.saft csaft, t.srd, c.srd csrd
FROM g t JOIN g c ON c.seg = t.seg AND c.st = t.st AND c.v = t.v AND c.r = t.r AND t.grp = 'Test' AND c.grp = 'Control'
WHERE t.r = 0 OR t.st = 'all'
```

### 5.6 `q20_gpflow.sql`
**Slide 138 bars + notes.** GP received, coins bought/earned/spent pre (06-14..06-27) and post (07-07..08-04), configured prize, balances; by group × end state.  
In: stg_coins_in_vw, stg_coins_out_vw, stg_album_completed_vw, int_rv_user_daily_coins_balance. Out: `gpflow.json` → `gp.py` → `gp_sum.json`.

```sql
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
ev AS (
  SELECT i.user_id, i.pdate, 'in' dir, i.source, SAFE_DIVIDE(COALESCE(i.amount, i.coins), i.coins_allowance) u
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw` i JOIN pop p ON p.user_id = i.user_id
  WHERE i.pdate BETWEEN DATE '2026-06-14' AND DATE '2026-08-04'
  UNION ALL
  SELECT o.user_id, o.pdate, 'out', o.source, SAFE_DIVIDE(COALESCE(o.amount, o.coins), o.coins_allowance)
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw` o JOIN pop p ON p.user_id = o.user_id
  WHERE o.pdate BETWEEN DATE '2026-06-14' AND DATE '2026-08-04'),
f AS (
  SELECT user_id,
    SUM(IF(dir='in' AND source='album completed' AND pdate BETWEEN DATE '2026-06-28' AND DATE '2026-07-06', u, 0)) gp18,
    SUM(IF(dir='in' AND source='album completed' AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', u, 0)) gp19,
    SUM(IF(dir='in' AND source IN ('purchase','purchase_gift','store bundle gift') AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', u, 0)) buy_post,
    SUM(IF(dir='in' AND source NOT IN ('purchase','purchase_gift','store bundle gift','album completed') AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', u, 0)) earn_post,
    SUM(IF(dir='out' AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', u, 0)) out_post,
    SUM(IF(dir='out' AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-07-13', u, 0)) out_w1,
    SUM(IF(dir='in' AND source IN ('purchase','purchase_gift','store bundle gift') AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-07-13', u, 0)) buy_w1,
    SUM(IF(dir='in' AND source IN ('purchase','purchase_gift','store bundle gift') AND pdate BETWEEN DATE '2026-06-14' AND DATE '2026-06-27', u, 0)) buy_pre,
    SUM(IF(dir='in' AND source NOT IN ('purchase','purchase_gift','store bundle gift','album completed') AND pdate BETWEEN DATE '2026-06-14' AND DATE '2026-06-27', u, 0)) earn_pre,
    SUM(IF(dir='out' AND pdate BETWEEN DATE '2026-06-14' AND DATE '2026-06-27', u, 0)) out_pre,
    COUNTIF(u_raw < 0 OR u_raw > 1000) clipped
  FROM (SELECT user_id,pdate,dir,source,u AS u_raw, IF(u BETWEEN 0 AND 1000, u, 0) AS u FROM ev) ev
  GROUP BY 1),
ac AS (
  SELECT c.user_id,
    ANY_VALUE(SAFE_DIVIDE(SAFE_CAST(REGEXP_EXTRACT(c.album_grand_prize, r'Coins: (\d+)') AS FLOAT64), c.coins_allowance)) gp_cfg,
    ANY_VALUE(c.coins_balance_in_allowance) bal_ac, ANY_VALUE(SAFE_DIVIDE(c.coins_balance, c.coins_allowance)) bal_ac_calc,
    ANY_VALUE(c.pdate) ac_date
  FROM `domino-dreams-dbt.prod_10_staging.stg_album_completed_vw` c JOIN pop p ON p.user_id = c.user_id
  WHERE c.pdate BETWEEN DATE '2026-06-28' AND DATE '2026-07-06' AND c.album_id = 18
  GROUP BY 1),
rv AS (
  SELECT r.user_id, r.date_dim, r.coins_balance_in_allowance_end_day b
  FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_balance` r JOIN pop p ON p.user_id = r.user_id
  WHERE r.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-06'),
u AS (
  SELECT p.seg, p.grp, p.st, p.user_id,
    IFNULL(f.gp18,0) gp18, IFNULL(f.gp19,0) gp19, IFNULL(f.buy_post,0) buy_post, IFNULL(f.earn_post,0) earn_post, IFNULL(f.out_post,0) out_post,
    IFNULL(f.out_w1,0) out_w1, IFNULL(f.buy_w1,0) buy_w1, IFNULL(f.buy_pre,0) buy_pre, IFNULL(f.earn_pre,0) earn_pre, IFNULL(f.out_pre,0) out_pre,
    IFNULL(f.clipped,0) clipped, ac.gp_cfg, ac.bal_ac, ac.bal_ac_calc, rvac.b rv_ac, rv6.b rv_0706,
    ac.user_id IS NOT NULL has_ac
  FROM pop p LEFT JOIN f USING (user_id) LEFT JOIN ac USING (user_id)
  LEFT JOIN rv rvac ON rvac.user_id = p.user_id AND rvac.date_dim = ac.ac_date
  LEFT JOIN rv rv6 ON rv6.user_id = p.user_id AND rv6.date_dim = DATE '2026-07-06'),
lng AS (
  SELECT seg, grp, st, metric, val FROM u
  UNPIVOT (val FOR metric IN (gp18, gp19, buy_post, earn_post, out_post, out_w1, buy_w1, buy_pre, earn_pre, out_pre, gp_cfg, bal_ac, bal_ac_calc, rv_ac, rv_0706))),
cut AS (SELECT seg, grp, st, metric, APPROX_QUANTILES(val, 100)[OFFSET(99)] p99 FROM lng GROUP BY 1,2,3,4)
SELECT l.seg, l.grp, l.st, l.metric, COUNT(*) n_nonnull, COUNTIF(l.val > 0) n_pos, SUM(l.val) s,
  APPROX_QUANTILES(l.val, 2)[OFFSET(1)] med, APPROX_QUANTILES(IF(l.val > 0, l.val, NULL), 2)[OFFSET(1)] med_pos,
  ANY_VALUE(c.p99) p99, AVG(IF(l.val <= c.p99, l.val, NULL)) tmean
FROM lng l JOIN cut c USING (seg, grp, st, metric)
GROUP BY 1,2,3,4
UNION ALL
SELECT seg, grp, st, 'n_users', COUNT(*), COUNTIF(has_ac), SUM(clipped), NULL, NULL, NULL,
  CORR(bal_ac, rv_ac) FROM u GROUP BY 1,2,3
```

### 5.7 `q21_balval.sql`
Validates `int_rv_user_daily_coins_balance` against the last staging balance of the day (07-06, 08-04). Supports R21.  
Out: `balval.json`.

```sql
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
ev AS (
  SELECT i.user_id, i.pdate, i.timestamp ts, i.coins_balance_in_allowance b, SAFE_DIVIDE(i.coins_balance, i.coins_allowance) bc
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw` i JOIN pop p ON p.user_id = i.user_id
  WHERE i.pdate IN (DATE '2026-07-06', DATE '2026-08-04')
  UNION ALL
  SELECT o.user_id, o.pdate, o.timestamp, o.coins_balance_in_allowance, SAFE_DIVIDE(o.coins_balance, o.coins_allowance)
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw` o JOIN pop p ON p.user_id = o.user_id
  WHERE o.pdate IN (DATE '2026-07-06', DATE '2026-08-04')),
last AS (
  SELECT user_id, pdate, ARRAY_AGG(b ORDER BY ts DESC LIMIT 1)[OFFSET(0)] lb, ARRAY_AGG(bc ORDER BY ts DESC LIMIT 1)[OFFSET(0)] lbc FROM ev GROUP BY 1,2),
rv AS (
  SELECT r.user_id, r.date_dim, r.coins_balance_in_allowance_end_day b
  FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_balance` r JOIN pop p ON p.user_id = r.user_id
  WHERE r.date_dim IN (DATE '2026-07-06', DATE '2026-08-04')),
j AS (
  SELECT p.seg, p.grp, d, l.lb sb, l.lbc sbc, rv.b rb
  FROM pop p CROSS JOIN UNNEST([DATE '2026-07-06', DATE '2026-08-04']) d
  LEFT JOIN last l ON l.user_id = p.user_id AND l.pdate = d
  LEFT JOIN rv ON rv.user_id = p.user_id AND rv.date_dim = d)
SELECT seg, grp, d, COUNT(*) n, COUNTIF(sb IS NOT NULL) n_stg, COUNTIF(rb IS NOT NULL) n_rv,
  COUNTIF(sb IS NOT NULL AND rb IS NOT NULL) n_both, COUNTIF(sb IS NOT NULL AND rb IS NULL) stg_only, COUNTIF(sb IS NULL AND rb IS NOT NULL) rv_only,
  COUNTIF(ABS(sb - rb) <= 0.5) n_match05, COUNTIF(ABS(sb - rb) <= 0.01 * GREATEST(ABS(sb), 1)) n_match1pct,
  COUNTIF(ABS(sb - sbc) <= 0.01) n_stg_internal,
  APPROX_QUANTILES(IF(rb IS NOT NULL, sb, NULL), 2)[OFFSET(1)] med_stg, APPROX_QUANTILES(IF(sb IS NOT NULL, rb, NULL), 2)[OFFSET(1)] med_rv,
  AVG(IF(rb IS NOT NULL, sb, NULL)) mean_stg, AVG(IF(sb IS NOT NULL, rb, NULL)) mean_rv,
  APPROX_QUANTILES(rb, 2)[OFFSET(1)] med_rv_all, AVG(rb) mean_rv_all
FROM j GROUP BY 1,2,3 ORDER BY 1,2,3
```

### 5.8 `q26_daily_lines.sql`
Daily $ per player on the level-35+ proxy population (the comparison for q27).  
Out: `q26_daily_lines.csv`.

```sql
-- q26: Easy $ per player per day, 3 locked (Test, MOD(sid,997)<498) vs 5 locked (Control).
-- Population = exactly q23_phase_pt pop (album 18 players, active 06-28..07-05, level 35+, Easy,
-- no special users, no suspected cheaters 05-11..08-04). Fixed denominator = group size.
-- SELECT only; no writes.
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg = 'Easy'),
gs AS (SELECT grp, COUNT(*) n FROM pop GROUP BY 1),
d AS (
  SELECT p.grp, m.date_dim dd, SUM(m.user_daily_inapp_purchase_amount) rev, COUNT(DISTINCT m.user_id) payers
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN pop p ON p.user_id = m.user_id
  WHERE m.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07' AND m.user_daily_inapp_purchase_amount > 0
  GROUP BY 1, 2)
SELECT d.grp, d.dd, gs.n, d.rev, d.payers, d.rev / gs.n AS rev_pp, d.payers / gs.n AS payer_rate
FROM d JOIN gs USING (grp)
ORDER BY d.dd, d.grp
```

### 5.9 `q18_stock.sql`
Calendar-baseline post-test comparison (superseded by q23–q25), weekly gaps, coin balances, album 19 outcomes by group (R23, R24).  
Out: `stock.json` → `stock.py`.

```sql
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    SUM(IF(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', IFNULL(a.album_spent_today, 0), 0)) AS r_win,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
m AS (
  SELECT m.user_id,
    MAX(IF(m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', m.level_id_end_day, NULL)) AS lvl,
    SUM(IF(m.date_dim BETWEEN DATE '2026-05-31' AND DATE '2026-06-27', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS pre4,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS post,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-07' AND DATE '2026-07-13', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS w1,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-14' AND DATE '2026-07-20', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS w2,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-21' AND DATE '2026-07-27', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS w3,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-28' AND DATE '2026-08-04', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS w4
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-05-31' AND DATE '2026-08-04'
  GROUP BY 1),
cb AS (
  SELECT c.user_id,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-06-27', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0627,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-07-06', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0706,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-07-13', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0713,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-07-20', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0720,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-07-27', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0727,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-08-04', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0804
  FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_balance` c JOIN a USING (user_id)
  WHERE c.date_dim BETWEEN DATE '2026-06-13' AND DATE '2026-08-04'
  GROUP BY 1),
a19 AS (
  SELECT b.user_id,
    MAX(IF(b.date_dim <= DATE '2026-08-23', b.unique_album_stickers_lt, NULL)) uq19,
    SUM(IF(b.date_dim <= DATE '2026-08-23', IFNULL(b.album_spent_today, 0), 0)) r19,
    ANY_VALUE(b.album_segment) seg19
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` b JOIN a USING (user_id)
  WHERE b.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-08-24' AND b.album_id = 19
  GROUP BY 1),
u AS (
  SELECT a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,  -- flipped to match Mixpanel labels
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st,
    a.r_win, IFNULL(m.pre4,0) pre4, IFNULL(m.post,0) post, IFNULL(m.w1,0) w1, IFNULL(m.w2,0) w2, IFNULL(m.w3,0) w3, IFNULL(m.w4,0) w4,
    cb.b0627, cb.b0706, cb.b0713, cb.b0720, cb.b0727, cb.b0804,
    a19.uq19, IFNULL(a19.r19, 0) r19, a19.seg19
  FROM a LEFT JOIN m USING (user_id) LEFT JOIN cb USING (user_id) LEFT JOIN a19 USING (user_id)
  WHERE a.sid IS NOT NULL AND IFNULL(m.lvl, 0) >= 35 AND a.seg IN ('Easy','Hard'))
SELECT seg, grp, st, COUNT(*) n,
  SUM(r_win) s_win, SUM(pre4) s_pre4, SUM(pre4*pre4) q_pre4, SUM(post) s_post, SUM(post*post) q_post,
  SUM(post*pre4) x_pp,
  SUM(w1) s_w1, SUM(w1*w1) q_w1, SUM(w2) s_w2, SUM(w2*w2) q_w2, SUM(w3) s_w3, SUM(w3*w3) q_w3, SUM(w4) s_w4, SUM(w4*w4) q_w4,
  COUNTIF(post > 0) post_payers, COUNTIF(pre4 > 0) pre_payers,
  COUNT(b0706) nb, AVG(b0627) b0627, AVG(b0706) b0706, AVG(b0713) b0713, AVG(b0720) b0720, AVG(b0727) b0727, AVG(b0804) b0804,
  APPROX_QUANTILES(b0706, 2)[OFFSET(1)] med_b0706, APPROX_QUANTILES(b0627, 2)[OFFSET(1)] med_b0627,
  COUNT(uq19) n19, COUNTIF(uq19 >= 144) fin19, COUNTIF(144 - uq19 BETWEEN 1 AND 2) m12_19, COUNTIF(144 - uq19 BETWEEN 3 AND 5) m35_19,
  COUNTIF(144 - uq19 = 3) m3_19, COUNTIF(144 - uq19 = 5) m5_19, SUM(r19) s_r19,
  COUNTIF(LOWER(seg19) LIKE '%easy%') easy19
FROM u GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
```

### 5.10 `q13_aa.sql`
A/A noise check: 200 random 50/50 splits of Easy album 18 players (R6).  
Out: `aa.csv`.

```sql
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
e AS (
  SELECT a.user_id, SUM(IF(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', IFNULL(a.album_spent_today, 0), 0)) AS r_test8,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-06') AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL AND LOWER(a.album_segment) LIKE '%easy%'
  GROUP BY 1 HAVING act),
m AS (
  SELECT m.user_id, SUM(IFNULL(m.user_daily_inapp_purchase_amount, 0)) AS r_long
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN e USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-08-04'
  GROUP BY 1),
u AS (SELECT e.user_id, e.r_test8, IFNULL(m.r_long, 0) AS r_long FROM e LEFT JOIN m USING (user_id)),
s AS (SELECT seed FROM UNNEST(GENERATE_ARRAY(1, 200)) seed),
g AS (
  SELECT seed, MOD(ABS(FARM_FINGERPRINT(CONCAT(CAST(user_id AS STRING), '-', CAST(seed AS STRING)))), 2) AS grp,
    COUNT(*) AS n, SUM(r_test8) AS r8, SUM(r_long) AS rl
  FROM u CROSS JOIN s GROUP BY 1, 2)
SELECT seed, MAX(IF(grp = 0, n, NULL)) AS n0, MAX(IF(grp = 1, n, NULL)) AS n1,
  MAX(IF(grp = 0, r8 / n, NULL)) / MAX(IF(grp = 1, r8 / n, NULL)) - 1 AS d8,
  MAX(IF(grp = 0, rl / n, NULL)) / MAX(IF(grp = 1, rl / n, NULL)) - 1 AS dl,
  SUM(r8) AS r8_tot, SUM(rl) AS rl_tot, SUM(n) AS n_tot
FROM g GROUP BY 1
```

### 5.11 `q16_ids.sql`
[DIAG] Group assignment check: server_user_id vs user_id bucketing, active and finisher counts per bucket side.  
Out: inline.

```sql
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) sid,
    MAX(IF(a.date_dim <= DATE '2026-07-06', a.unique_album_stickers_lt, NULL)) uq,
    MIN(IF(a.unique_album_stickers_lt >= 168, a.date_dim, NULL)) fin_date,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-06' AND a.active_flag) act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18
    AND LOWER(a.album_segment) LIKE '%easy%'
  GROUP BY 1)
SELECT IF(MOD(sid,997)<498,'C_by_sid','T_by_sid') g_sid,
  IF(MOD(SAFE_CAST(user_id AS INT64),997)<498,'C_by_uid','T_by_uid') g_uid,
  COUNTIF(act) active, COUNTIF(fin_date BETWEEN DATE '2026-06-28' AND DATE '2026-07-06') fin_win,
  COUNTIF(SAFE_CAST(user_id AS INT64) IS NULL) uid_not_int, COUNTIF(SAFE_CAST(user_id AS INT64) = sid) uid_eq_sid
FROM a GROUP BY 1,2 ORDER BY 1,2
```

### 5.12 `q15_set11.sql`
[DIAG] Set 11/12 completion by group and date (only Test could complete Set 11 from 06-28).  
Out: inline.

```sql
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%','Easy','Hard') seg,
    LOGICAL_OR(IFNULL(a.is_11th_set_completed_flag,FALSE)) s11,
    LOGICAL_OR(IFNULL(a.is_12th_set_completed_flag,FALSE)) s12,
    MAX(a.sets_completed_lt) sets,
    MIN(IF(a.is_11th_set_completed_flag, a.date_dim, NULL)) s11_date,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
  GROUP BY 1 HAVING act)
SELECT seg, IF(MOD(sid,997)<498,'Control','Test') grp, COUNT(*) n, COUNTIF(s11) s11, COUNTIF(s12) s12,
  COUNTIF(s11_date < DATE '2026-06-28') s11_before, COUNTIF(s11_date >= DATE '2026-06-28') s11_after, AVG(sets) avg_sets
FROM a WHERE sid IS NOT NULL GROUP BY 1,2 ORDER BY 1,2
```

### 5.13 `q22_dates.sql`
[DIAG] Album date ranges 16–21 in user_daily_album.  
Out: inline.

```sql
SELECT album_id, MIN(date_dim) d0, MAX(date_dim) d1, COUNT(DISTINCT date_dim) nd
FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-27' AND album_id BETWEEN 16 AND 21
GROUP BY 1 ORDER BY 1
```

### 5.14 `q12_segs18.sql`
[DIAG] Album 18/19 segment sizes.  
Out: inline.

```sql
SELECT album_id, album_segment, COUNT(DISTINCT user_id) AS users, MIN(date_dim) AS first_d, MAX(date_dim) AS last_d
FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-24' AND album_id IN (18, 19) AND special_user_flag = FALSE
GROUP BY 1, 2 ORDER BY 1, 3 DESC
```

### 5.15 `q19_gp.sql`
[DIAG] Configured grand prize per segment (album_grand_prize, allowance).  
Out: inline.

```sql
SELECT album_grand_prize, album_segment, COUNT(*) ev, COUNT(DISTINCT user_id) users, MIN(pdate) d0, MAX(pdate) d1,
  APPROX_QUANTILES(coins_allowance, 2)[OFFSET(1)] med_allow
FROM `domino-dreams-dbt.prod_10_staging.stg_album_completed_vw`
WHERE pdate BETWEEN DATE '2026-05-11' AND DATE '2026-07-07' AND album_id = 18
GROUP BY 1,2 ORDER BY ev DESC LIMIT 40
```

### 5.16 `q19_src.sql`
[DIAG] Coin-in/out sources on 07-07 (to pick 'album completed' and purchase sources).  
Out: inline.

```sql
SELECT 'in' dir, source, COUNT(*) ev, COUNT(DISTINCT user_id) users,
  SUM(SAFE_DIVIDE(COALESCE(amount, coins), coins_allowance)) units,
  APPROX_QUANTILES(SAFE_DIVIDE(COALESCE(amount, coins), coins_allowance), 2)[OFFSET(1)] med_units
FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw`
WHERE pdate = DATE '2026-07-07'
GROUP BY 1,2
UNION ALL
SELECT 'out', source, COUNT(*), COUNT(DISTINCT user_id),
  SUM(SAFE_DIVIDE(COALESCE(amount, coins), coins_allowance)),
  APPROX_QUANTILES(SAFE_DIVIDE(COALESCE(amount, coins), coins_allowance), 2)[OFFSET(1)]
FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw`
WHERE pdate = DATE '2026-07-07'
GROUP BY 1,2
ORDER BY 1, units DESC
```

### 5.17 `q14_cols.sql`
[DIAG] Schema lookup: level/server/sticker columns.  
Out: inline.

```sql
SELECT table_name, column_name, data_type FROM `domino-dreams-dbt.prod_40_mart.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name IN ('user_daily_metrics','user_daily_album') AND (LOWER(column_name) LIKE '%level%' OR LOWER(column_name) LIKE '%server%' OR LOWER(column_name) LIKE '%golden%' OR LOWER(column_name) LIKE '%dup%' OR LOWER(column_name) LIKE '%complet%' OR LOWER(column_name) LIKE '%sticker%')
```

### 5.18 `q17_cols.sql`
[DIAG] Schema lookup: coin/balance/allowance columns.  
Out: inline.

```sql
SELECT 'mart' ds, table_name, column_name FROM `domino-dreams-dbt.prod_40_mart.INFORMATION_SCHEMA.COLUMNS`
WHERE REGEXP_CONTAINS(LOWER(column_name), r'coin|balance|allowance')
UNION ALL
SELECT 'int', table_name, column_name FROM `domino-dreams-dbt.prod_30_intermediate.INFORMATION_SCHEMA.COLUMNS`
WHERE REGEXP_CONTAINS(LOWER(column_name), r'coin|balance|allowance')
```

### 5.19 `delta.sql` (review recompute)
[DIAG] Independent review recompute of the Easy pooled after ratios 17/18/19 with cross-moments for a delta-method CI (gave −5.24% net and [−9.5, −0.8]).  
Out: `/workspace/dom19_review/delta.json`, `delta_out.txt`.

```sql
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
alb AS (
  SELECT a, s, c FROM UNNEST([STRUCT(17 AS a, DATE '2026-04-02' AS s, DATE '2026-05-11' AS c),
    STRUCT(18, DATE '2026-05-11', DATE '2026-07-06'), STRUCT(19, DATE '2026-07-06', DATE '2026-08-24')])),
ua AS (
  SELECT x.user_id, x.album_id a, MIN(x.date_dim) f
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x JOIN pop p ON p.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-24' AND x.album_id IN (17, 18, 19)
  GROUP BY 1, 2),
m AS (
  SELECT d.user_id, d.date_dim dd, d.user_daily_inapp_purchase_amount amt
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` d JOIN pop p ON p.user_id = d.user_id
  WHERE d.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07' AND d.user_daily_inapp_purchase_amount > 0),
pa AS (
  SELECT p.user_id, p.seg, p.grp, p.st, alb.a, alb.c, GREATEST(ua.f, DATE_ADD(alb.s, INTERVAL 1 DAY)) f2
  FROM pop p JOIN ua USING (user_id) JOIN alb ON alb.a = ua.a),
pu0 AS (
  SELECT pa.user_id, ANY_VALUE(pa.seg) seg, ANY_VALUE(pa.grp) grp, ANY_VALUE(pa.st) st, pa.a,
    GREATEST(DATE_DIFF(DATE_SUB(ANY_VALUE(pa.c), INTERVAL 4 DAY), ANY_VALUE(pa.f2), DAY) + 1, 0) rd,
    GREATEST(DATE_DIFF(DATE '2026-06-27', ANY_VALUE(pa.f2), DAY) + 1, 0) rdp,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE_SUB(pa.c, INTERVAL 4 DAY), m.amt, 0)) rest,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE '2026-06-27', m.amt, 0)) restp,
    SUM(IF(m.dd BETWEEN DATE_SUB(pa.c, INTERVAL 3 DAY) AND pa.c, m.amt, 0)) endd,
    SUM(IF(m.dd BETWEEN DATE_ADD(pa.c, INTERVAL 1 DAY) AND DATE_ADD(pa.c, INTERVAL 14 DAY), m.amt, 0)) aft
  FROM pa LEFT JOIN m ON m.user_id = pa.user_id AND m.dd BETWEEN pa.f2 AND DATE_ADD(pa.c, INTERVAL 14 DAY)
  GROUP BY pa.user_id, pa.a),

pp AS (
  SELECT user_id, ANY_VALUE(grp) grp,
    SUM(IF(a=17,aft,0)) A17, SUM(IF(a=17,rest,0)) R17, SUM(IF(a=17,rd,0)) D17, COUNTIF(a=17) I17,
    SUM(IF(a=18,aft,0)) A18, SUM(IF(a=18,rest,0)) R18, SUM(IF(a=18,rd,0)) D18,
    SUM(IF(a=19,aft,0)) A19, SUM(IF(a=19,rest,0)) R19, SUM(IF(a=19,rd,0)) D19, COUNTIF(a=19) I19
  FROM pu0 WHERE seg='Easy' GROUP BY 1)
SELECT grp, COUNT(*) N, SUM(A17) s_A17, SUM(R17) s_R17, SUM(D17) s_D17, SUM(I17) s_I17, SUM(A18) s_A18, SUM(R18) s_R18, SUM(D18) s_D18, SUM(A19) s_A19, SUM(R19) s_R19, SUM(D19) s_D19, SUM(I19) s_I19, SUM(A17*A17) x_A17_A17, SUM(A17*R17) x_A17_R17, SUM(A17*D17) x_A17_D17, SUM(A17*I17) x_A17_I17, SUM(A17*A18) x_A17_A18, SUM(A17*R18) x_A17_R18, SUM(A17*D18) x_A17_D18, SUM(A17*A19) x_A17_A19, SUM(A17*R19) x_A17_R19, SUM(A17*D19) x_A17_D19, SUM(A17*I19) x_A17_I19, SUM(R17*R17) x_R17_R17, SUM(R17*D17) x_R17_D17, SUM(R17*I17) x_R17_I17, SUM(R17*A18) x_R17_A18, SUM(R17*R18) x_R17_R18, SUM(R17*D18) x_R17_D18, SUM(R17*A19) x_R17_A19, SUM(R17*R19) x_R17_R19, SUM(R17*D19) x_R17_D19, SUM(R17*I19) x_R17_I19, SUM(D17*D17) x_D17_D17, SUM(D17*I17) x_D17_I17, SUM(D17*A18) x_D17_A18, SUM(D17*R18) x_D17_R18, SUM(D17*D18) x_D17_D18, SUM(D17*A19) x_D17_A19, SUM(D17*R19) x_D17_R19, SUM(D17*D19) x_D17_D19, SUM(D17*I19) x_D17_I19, SUM(I17*I17) x_I17_I17, SUM(I17*A18) x_I17_A18, SUM(I17*R18) x_I17_R18, SUM(I17*D18) x_I17_D18, SUM(I17*A19) x_I17_A19, SUM(I17*R19) x_I17_R19, SUM(I17*D19) x_I17_D19, SUM(I17*I19) x_I17_I19, SUM(A18*A18) x_A18_A18, SUM(A18*R18) x_A18_R18, SUM(A18*D18) x_A18_D18, SUM(A18*A19) x_A18_A19, SUM(A18*R19) x_A18_R19, SUM(A18*D19) x_A18_D19, SUM(A18*I19) x_A18_I19, SUM(R18*R18) x_R18_R18, SUM(R18*D18) x_R18_D18, SUM(R18*A19) x_R18_A19, SUM(R18*R19) x_R18_R19, SUM(R18*D19) x_R18_D19, SUM(R18*I19) x_R18_I19, SUM(D18*D18) x_D18_D18, SUM(D18*A19) x_D18_A19, SUM(D18*R19) x_D18_R19, SUM(D18*D19) x_D18_D19, SUM(D18*I19) x_D18_I19, SUM(A19*A19) x_A19_A19, SUM(A19*R19) x_A19_R19, SUM(A19*D19) x_A19_D19, SUM(A19*I19) x_A19_I19, SUM(R19*R19) x_R19_R19, SUM(R19*D19) x_R19_D19, SUM(R19*I19) x_R19_I19, SUM(D19*D19) x_D19_D19, SUM(D19*I19) x_D19_I19, SUM(I19*I19) x_I19_I19
FROM pp GROUP BY 1 ORDER BY 1
```

---

## 6. Review findings & caveats

Independent read-only review (2026-10-28): no high-severity issues; album 19 numbers reproduce. Fixes already applied: slides 137/138 net −5.1% → **−5.2%**; slide 137 share panel → album-18-only values; notes reworded to "pooled group ratio".

| # | Caveat | Impact |
|---|---|---|
| C1 | **Cohort 6106615** ("1553- Album Fu (3 Vs 5) - Relevant Users") returns 404 / not in cohort list → cannot reproduce the board's exact population. q27 uses all Easy album-18 players; q14–q26 use the level-35+ proxy. | Both give the same story (−5.36% vs −5.57%). |
| C2 | **Fraud filter not applied.** The board's event-level "Suspected Fraudulent Purchase = false" has no mart equivalent (would need a staging table not yet approved). | Unknown, likely small. |
| C3 | **Level 35+ measured as max-in-window** (max `level_id_end_day` 06-28..07-05) in the proxy; ~48K per group crossed 35 during the window (balanced). q27 applies it per day instead (−5.36% either way). | Minor. |
| C4 | **Cheater flag uses later data** (flag through 08-04, includes post-test days). | Minor; could condition on outcome. |
| C5 | **Staging views not verified.** `stg_coins_in_vw`, `stg_coins_out_vw`, `stg_album_completed_vw` (approved by Eden) and `int_rv_user_daily_coins_balance` — row counts/completeness not checked (needs Eden's OK). Balance medians match staging vs int_rv; int_rv has rows only on active days (~63% of players on 07-06). | Coin numbers (R19–R22) less curated than $ numbers. |
| C6 | **`unique_royal_stickers_tl`** — real column name in `user_daily_album` (cumulative unique royal stickers; spelled `_tl`, not `_lt`). Used by the album 19 queries (q2/q4/q7/q8/q9/q11) as common_lt + golden_lt + royal_tl; FU18 queries use `unique_album_stickers_lt` (168) instead. Not reconciled row-by-row. | None on FU numbers. |
| C7 | **IL/RO exclusion differs:** album-19 q9 excludes `mp_country_code IN ('IL','RO')`, q20 does not; q10 has no special/cheater filter. | Album 19 prize numbers only. |
| C8 | **Mixpanel 498/499 scaling:** the canvas's earlier cross-check scaled Test by 997/499 — backwards (Test has 498 buckets). Corrected ≈ −1.0% revenue, +1.8% payers (not −1.40% / +1.41%). Not on any slide, but the **slide 135 notes still carry the old text** ("498 control / 499 test", "labels reversed and swapped", −1.40%/+1.41%). | Notes fix needed (see §7). |
| C9 | **Slide 138 label [new, unconfirmed by Eden]:** title says "Easy *finishers'* coin spend paid by GP", but 0.9% vs 0.3% is GP ÷ coin spend over **all** Easy players (gp_sum: 7.63/888.5 vs 2.98/894.3). For finishers only it is **5.0% vs 3.6%** (gpflow.json). Message (~0%) unchanged. | Relabel or switch values. |
| C10 | End states are test outcomes → state-level rows are descriptive, not causal. Album 17 already differs by state. | Interpretation. |
| C11 | Duplicate-bar bug ("primarily affected the test group", FU deck slide 34) not visible in marts; size unknown. Album 18's end includes July 4. | Possible confounder. |
| C12 | Album 19 treatment stop inferred from equal album 19 outcomes, not from a config table. | Low. |

---

## 7. Open items

1. **Slides 135, 136, 138 not yet redone in the plain-$ style** of slide 137 v5 (Eden asked to see 137 first; she approved it). Proposed: plain $ bars/lines per group instead of % gaps; drop jargon like "net" (say "after removing the usual gap").
2. **Slide 135 (FU1):** remove or keep the red "FU deck reported −1.75%" reference — asked, no answer yet (v3 notes say it was removed from the slide; check live). Fix stale notes (C8).
3. **Slide 138:** fix the "finishers" label vs all-player values (C9).
4. Old slide-137 notes said pre-test-only net "−5.2%"; correct value is **−5.3%** (−5.34%). v5 notes replaced them; make sure no deck text still says −5.2% for the pre-test-only variant.
5. Staging-view row-count checks (C5) and fraud filter (C2) — need Eden's approval.
6. Save the inline summary math for pt/bs/coinsph as a script (`fu18_phase_summary.py`).
7. Repo: copy SQL + this doc into the repo and add `index/sql-catalog.md` / `index/topic-domino-dx.md` rows (see §8).

---

## 8. File map

**Box (shared Linux box, not the Mac):**

| Path | What |
|---|---|
| `/workspace/dom19/sql/q12..q27*.sql` | FU18 queries (q2–q11 = album 19 analysis) |
| `/workspace/dom19/{recut,stock,gp}.py` | Summary scripts |
| `/workspace/dom19/recut.json` (raw labels!), `stock.json`, `gpflow.json`, `gp_sum.json`, `balval.json`, `pt.json`, `bs.json`, `coinsph.json`, `aa.csv`, `q26_daily_lines.csv`, `q27_daily_lines_official.csv`, `*_raw.txt` | Outputs |
| `/workspace/dom19_review/` | Review: `delta.sql/json/out`, `canvas.txt` snapshot |
| `/workspace/slides/fu18/` | Slide builders + notes (`fu18_*.notes.txt` = v2, `v3/`, `v5/` = slide 137 current, `live_thumbs/`) |
| Canvas | https://cursor.com/canvas/store-2d3651e8-10fe-409f-9031-f47cb1501abd/f8d1635f-a072-4a1d-a554-4bb1264ddbd9 — section F |

**Repo (`Edenelm/album-cross-`, Mac: `/Users/edenelmaliach/album-cross-`).** Repo convention (`index/sql-catalog.md` rule) is flat files in `claude/`: `claude/<topic>-<date>.md` + `claude/<topic>_<date>.sql`, plus a line in `index/sql-catalog.md`. So instead of a `claude/fu18/` folder, use:

- `claude/domino-fu18-ab-test-2026-10-29.md` ← this file
- `claude/domino_fu18_ab_test_2026-10-29.sql` ← q13, q14, q16, q18, q20, q21, q23–q27 concatenated (each with a `-- qNN: purpose` header)
- optional: `claude/domino_fu18_{recut,stock,gp}_2026-10-29.py`
- index rows: `index/sql-catalog.md` (Domino / topic-domino-dx section) and `index/topic-domino-dx.md` (its "Live deck map: d19 + FU18 slides" table already lists slides 135–138; update 137's script to `v5 native_v5.py`).
