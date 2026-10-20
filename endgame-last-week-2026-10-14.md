# Album endgame — last week before close (Dice 61/63, Domino 17/19, Disney 14/15) — 2026-10-14

Critic + cross-game comparison first; per-game analyst outputs (with SQL) follow. Critic corrections take precedence.

---

# Critic review: last-week album closing in Dice 61/63, Domino 17/19 and Disney 14/15

I re-ran one key number per game with my own SQL, and all three reproduce exactly. The three analyses use the same population, groups and day index, so they can be compared. Four things need correcting before the numbers sit side by side:
- **Paid-share denominator:** Disney divides by active days; Dice and Domino divide by group size.
- **Near-finisher group:** each game breaks it down differently.
- **Channel buckets:** each game sorts sticker sources differently.
- **10-minute purchase test:** it does not exist for Disney.

All corrected numbers are in (A) and (C).

## (A) Validation

| Analyst | Item | Verdict | Correction |
|---|---|---|---|
| All | Population: not-first PU, spend > 0 before close, login ratio ≥ 0.5 on the last row, close day excluded, 144 unique stickers from the daily table | **Comparable** | Small differences: Dice uses `MAX(past)>0`, Disney `MAX(uac)>1`, Domino the last row's `uac>1`; exclusion flags are game-specific. My re-runs swapped some of these and got identical group sizes. |
| All | Groups F / F-late / F-early (finished before d = −7) | **Comparable** | The cut-off is the same in all three. F-early: Dice 0/0, Domino 131/8, Disney 0/0. |
| All | Near-finisher groups | **Mismatch** | Domino and Disney report N (1–3 short) and N1. Dice reports N1 and N2-3 but no combined N. In (C) I rebuilt Dice N for rates by weighting N1 and N2-3 (n = 62,941 / 101,307). I compare medians on N1 only, since medians cannot be combined. |
| All | Day index: d = date − close, d = −1 is the last full day, baseline week = d −14…−8 | **Comparable** | – |
| All | ARPDAU = revenue ÷ active player-days | **Comparable** | All three now use active days, so the earlier Domino row-denominator issue is fixed. |
| Disney | T1 shares (% new Golden, % new Royal, % Joker, **% paid**) are per active day; Dice and Domino use per group-day | **Mismatch, small** | Multiply by %active (0.93–0.99). Example: Disney F paid on d = −1 is 0.72 → **0.71** (album 14) and 0.69 → **0.68** (album 15). The corrected figures are in (C). |
| All | T4 purchase linkage | **Not comparable for Disney** | Disney has no curated purchase timestamps, so its 10-minute share cannot be computed. The common measure across games is "new sticker on a paying day vs the Commons control" (used in C). |
| All | T4 Commons control | **Comparable method, different base level** | The Commons base differs by game: within 10 min it is 11–14% in Dice vs 18–25% in Domino; on a paying day 35–38% vs 53–60%, with Disney at 40–51% on that measure. Compare rare ÷ Common ratios, not raw levels. |
| All | T3 channel buckets | **Mismatch** | Dice splits Wild into paid / event, Domino has a single Joker bucket, Disney splits Joker by source. Domino puts `Missions`/`mtx` under paid; Disney puts `mtx challenge` under event. Only the total "pick fill (Wild or Joker)" share is comparable, and (C) uses only that. |
| All | T2 "first new Golden / rare / purchase" medians | **Valid but uninformative** | 70–99% of each group already had these in the baseline week, so the medians land at −11 to −14. Only the first Wild/Joker fill and the last rare carry signal. Medians leave out players who never had the event (Dice N2-3: 59% / 74% none), so always show the "none" share next to them. |
| Dice / Domino / Disney | Calendar day vs sticker date alignment | **Dice checked, others Needs Validation** | Dice confirmed 0% of new-sticker days fall on inactive rows. Domino and Disney did not check, so their "on a paying day" shares are Needs Validation. |
| Disney | 1.7% / 2.4% of N have all 144 stickers in the sticker table | **Confirmed by re-run; Needs Validation** | 1,203 / 1,198 players. F may be under-counted by up to 8.6% / 9.1% relative to the sticker table. The standard stays the daily table, which is the same rule in all three games. This was not checked for Dice or Domino. |
| Dice | "The closing run … is driven by Wilds, not Goldens" | **Reword** | Change to "coincides with the Wild-fill rise". Known, descriptive. |
| Dice | "N1 look like finishers who ran out of time" | **Relabel** | Hypothesis. |
| Dice | "The Commons control and the 24-hour placebo rule out 'payers simply collect more after paying'" | **Overstated** | Change to "make it less likely". Paid packs may contain more rares by design. Who caused what stays Needs Validation. |
| Dice | Wild with a `Pricing%` pack key = paid, Known (99.5–100% within 10 min of a purchase) | **Keep** | – |
| Domino | "Album 19 ends almost entirely through Jokers" (Known) | **Split the label** | The counts are Known. What the Joker flag means after the Royal Tower launch is Needs Validation: the flag matching `number_of_jokers_today` shows the data is consistent, not what the flag means. Same rule as yesterday: no Domino Joker share on a slide until the studio confirms. |
| Domino | "What decides finishing is the last 2–5 gate stickers" | **Reword** | Change to "what separates F from N". |
| Domino | Cross-game note quotes yesterday's Dice 72–82% (a different measure: the last Super only) | **Replace** | Use today's measure: Dice F new Supers 55% / 59% within 10 min. |
| Disney | "Through d = −8 the trio cannot be had" / "almost no payer could get it" | **Reword** | Change to "was held by almost no payer" (Known). "Locked" is a Hypothesis. |
| Disney | Revenue column is USD gross, Known (0.995 ratio) | **Keep** | This closes yesterday's open item. |
| Disney | Day-level linkage labelled Known, causation Needs Validation | **Keep** | – |
| Dice (process) | The safety classifier was unavailable during the Dice analyst's run | **Checked** | Its SQL is read-only SELECTs, and my independent re-run reproduces its numbers. |

## (B) Re-runs (my own SQL, dry-run first)

| Game | Number | Original | Re-run | Verdict |
|---|---|---|---|---|
| Dice 61 / 63 | F = F-late; F-early | 14,345 / 18,915; 0 / 0 | 14,345 / 18,915; 0 / 0 | **Match** |
| | Median first Wild fill (F) | −3 / −3 | −3 / −3; none 0.03% / 0.07% | **Match** |
| | Median first and last new Super (F) | −12 / −11; −2 / −2 | −12 / −11; −2 / −2 | **Match** |
| | Finished on d = −1; in the last 3 days | 38.9% / 37.9%; 88% / 84% | 38.9% / 37.9%; 87.7% / 84.0% | **Match** |
| Domino 17 / 19 | F; F-early | 7,783 / 5,320; 131 / 8 | 7,783 / 5,320; 131 / 8 | **Match** |
| | Median first Joker fill (F-late) | −8 / −5; none 5.4% / 0% | −8 / −5; none 5.41% / 0% | **Match** |
| | Median first and last new Royal (F-late) | −11 / −11; −5 / −1 | −11 / −11; −5 / −1 | **Match** |
| | Finished on d = −1 | 39.3% / 56.8% | 39.3% / 56.8% | **Match** |
| Disney 14 / 15 | F; N | 14,037 / 13,184; 71,272 / 49,456 | Same | **Match** |
| | Median first Joker fill (F; N) | −1 / −2; −1 / −2 | −1 / −2; −1 / −2. Never used a Joker: F 0.8% / 2.1%, N 85.3% / 73.3% | **Match** |
| | Median first new Royal (F) | −4 / −11 | −4 / −11 | **Match** |
| | Finished on d = −1 | 64.6% / 58.7% | 64.6% / 58.7% | **Match** |
| | N with 144 in the sticker table | ~1.7% | 1,203 / 1,198 | **Confirmed**; see (A) |

The re-runs scanned 97.2 GB in total (16.9 + 22.9 + 57.4); each query was under 100 GB. They were billed under `domino-dreams-dbt` because the session is locked there; I did not change the lock.

## (C) Cross-game table

F = finishers (all F-late, except Domino F-early 131 / 8). N1 = exactly one sticker short at the end of d = −1. N = 1–3 short; Dice N is the weighted N1 + N2-3. "Pick" = a Wild fill in Dice, a Joker fill in Domino and Disney.

| Metric | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| F n / N1 n | 14,345 / 6,422 | 18,915 / 7,553 | 7,783 / 3,075 | 5,320 / 2,720 | 14,037 / 10,206 | 13,184 / 7,128 |
| F-early share of F | 0% | 0% | 1.7% | 0.15% | 0% | 0% |
| F median first new Golden, d −14…−1 (saturated) | −13 | −14 | −13 | −13 | −11 | −12 |
| F median first new rare (saturated) | −12 | −11 | −11 | −11 | **−4** | −11 |
| F median first pick fill (share already in baseline week) | **−3** (3.6%) | **−3** (3.3%) | **−8** (52%) | **−5** (28%) | **−1** (0%) | **−2** (1%) |
| N1 median first pick fill (share never) | −2 (3.5%) | −2 (3.8%) | −7 (12%) | −3 (0%) | −1 (47%) | −2 (25%) |
| F median first purchase in the window (saturated) | −11 | −12 | −12 | −12 | −12 | −12 |
| F median last new rare | −2 | −2 | −5 | −1 | −1 | −2 |
| F paid % per day: average of d −3…−1 vs baseline | 50 vs 25 (**2.0×**) | 50 vs 26 (**1.9×**) | 51 vs 37 (**1.4×**) | 56 vs 34 (**1.6×**) | 57 vs 33 (**1.7×**)* | 59 vs 33 (**1.8×**)* |
| N1 paid %, d −3…−1 vs baseline | 1.9× | 1.8× | 1.4× | 1.6× | 1.6×* | 1.6×* |
| N (1–3 short) paid %, d −3…−1 vs baseline | 1.07× | **0.87×** | 1.19× | 1.34× | **0.97×*** | **0.93×*** |
| F PU ARPDAU d = −1 ÷ baseline | 2.4× | 2.4× | 1.6× | 2.1× | 2.4× | 2.2× |
| Share of F's last-week new rares via a pick | 51.5% | 54.0% | 27.5% | 79.4%† | 60.1% | 44.9% |
| Same for N1 | 39.2% | 42.2% | 17.9% | 68.0%† | 25.4% | 25.2% |
| F new rares ≤ 10 min after a purchase vs Commons | 54.9 vs 10.7 (**5.1×**) | 59.3 vs 14.4 (**4.1×**) | 37.0 vs 24.7 (**1.5×**) | 40.5 vs 18.2 (**2.2×**) | n/a | n/a |
| F new rares on a paying day vs Commons | 82 vs 35 (2.3×) | 83 vs 38 (2.2×) | 83 vs 60 (1.4×)‡ | 80 vs 53 (1.5×)‡ | 84 vs 40 (2.1×)‡ | 85 vs 51 (1.7×)‡ |
| Finishing sticker: rare / Golden | 81 / 18 | 70 / 29 | ~14 / ~84 | 51 / 48 | 80 / 20 | 47 / 53 |
| Finishing sticker via a pick | 90% (paid Wild 58%, event Wild 32%) | 87% (paid 69%, event 17%) | 45%† (paid Golden offer, no pick, 19%) | 96%† | 86% (Joker bought in the Market 50%) | 69% |
| Finished on d = −1 / in the last 3 days | 39% / 88% | 38% / 84% | 39% / 64% | 57% / 93% | 65% / 99% | 59% / 99% |
| Gate stickers | S143, S120, G142 | S132, S143, G129 | G106, G104 (+R108) | R107, R108, G101 | R131, G84, G130 | R131, G141, G142 |
| Share of all payers holding the top gate sticker by d = −2 | 7.5% | 11.3% | 6.6% (Golden) | 5.6% | 2.0% | 5.5% |

\* Disney re-based to per group-day (multiplied by %active).
† Domino Joker shares are Needs Validation for slides (meaning of the flag).
‡ Domino and Disney day alignment is not verified.

## (D) Biggest differences between games (descriptive; every lever is a Hypothesis or proposed Test)

1. **When the pick mechanic switches on.**
   - In Dice and Disney, Wild/Joker fills are essentially end-only: Dice median d = −3 with 3–4% in the baseline week; Disney median d = −1/−2 with ~0% in the baseline week.
   - In Domino, Jokers are always on: 52% (album 17) and 28% (album 19) of finishers already used one in the baseline week, median −8 / −5.
   - *Implies (Hypothesis):* in Dice and Disney, the end-of-album pick is the closing product; in Domino it is a regular mechanic.
   - *Test:* in Domino, a pick offer targeted at the missing gate sticker from close−7 (Domino item 2).

2. **How compressed the finish is.**
   - Disney: 99% of finishers finish in the last 3 days and 59–65% on d = −1.
   - Dice: 84–88% in the last 3 days.
   - Domino 17: 64%, with finishes spread over the week. It is the only album with any early finishers.
   - *Implies:* Disney leaves no window to spend after finishing and no time to catch up. The Royal 131 group first reaches thousands of collectors at d = −3.
   - *Test:* Disney A, a Joker or last-Royal offer from close−7. Release-timing levers stay **Do Not Adopt Yet** until each studio confirms its release calendar.

3. **How tightly new rares follow a purchase.**
   - Dice: new rares land within 10 minutes of a purchase 4–5× as often as new Commons, and finishes close through `Pricing_*` Wild offers 58–69% of the time.
   - Domino: only 1.5–2.2×; rares also arrive through events, the Market and duplicate exchange.
   - Disney: day-level only, 1.7–2.1×.
   - *Implies (Hypothesis):* in Dice the closing purchase is a direct "buy the gate" route; in Domino it is diluted.
   - *Needs Validation:* whether the purchase bought the sticker. No purchase-to-sticker ID exists.

4. **Near-finishers two or three short do not ramp in Dice or Disney.**
   - N1 pays 1.4–1.9× its baseline in every game.
   - The wider N group is flat or falling in Dice (1.07× / 0.87×; 59–74% of N2-3 never get a Wild) and in Disney (0.97× / 0.93×; 73–85% never use a Joker). Domino N rises (1.19× / 1.34×).
   - *Implies (Hypothesis):* the closing offer reaches only players one sticker away.
   - *Test:* a gate-pick bundle (2–3 stickers) for N2-3 from close−4. Primary: PU ARPDAU d −4…−1. Guardrails: N1/F Wild revenue (cannibalization), finish rate, next-album ARPDAU.

5. **Where the closing pick comes from.**
   - Dice: paid Wild offers (Known paid).
   - Disney 14: Jokers bought in the Market are 50% of finishing stickers, and it is unknown whether the Market costs real money.
   - Domino 19: Joker origins are about 44% event (Trail, Temple, Wheel).
   - *Implies:* the cross-game "paid closing" story holds only for Dice until Disney's Market currency and Domino's Joker flag are confirmed. Both are open studio questions.

6. **Which rarity the gate is.**
   - Dice: 2 Supers + 1 Golden. Disney: 1 Royal + 2 Goldens. Domino 17: Golden-led. Domino 19: 2 Royals + 1 Golden.
   - The finishing rare share follows the mix (70–81% / 47–80% / 14–51%).
   - *Implies:* "last locked trio or phase = gate" is the unifying frame (Known). Whether a rare-led or a Golden-led gate monetizes better is not identifiable from two albums per game: Do Not Adopt Yet.

## (E) SQL appendix (critic re-runs; read-only, dry-run first with identical SQL, partition-filtered, fully qualified)

**R-Dice: `dice-dreams-dbt` tables, 16.89 GB.** Saved at `/tmp/claude-0/-home-claude/5629d190-2f4d-5652-8298-2143c958a9b2/scratchpad/critic/r_dice.sql`.
```sql
WITH alb AS (SELECT 61 AS album_id, DATE '2026-07-27' AS a_end UNION ALL SELECT 63, DATE '2026-09-07'),
d AS (SELECT a.album_id, a.user_id, a.date_dim, alb.a_end, IFNULL(a.spent_in_album_today,0) AS sp, a.album_login_ratio AS lr,
    IFNULL(a.user_past_album_count,0) AS past,
    IFNULL(a.unique_common_stickers_lt,0)+IFNULL(a.unique_golden_stickers_lt,0)+IFNULL(a.unique_super_stickers_lt,0) AS u
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN '2026-06-22' AND '2026-09-06' AND a.album_id IN (61,63) AND NOT IFNULL(a.is_excluded,FALSE) AND a.date_dim < alb.a_end),
f AS (SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(u>=144, date_dim, NULL)) AS fin_d FROM d GROUP BY 1,2
  HAVING SUM(sp)>0 AND MAX(past)>0 AND MAX_BY(lr, date_dim) >= 0.5 AND MAX(u) >= 144),
s0 AS (SELECT album_id, user_id, sticker_id,
    ARRAY_AGG(STRUCT(sticker_type AS t, IFNULL(collected_from_wild,FALSE) AS w, sticker_collected_date AS dt) ORDER BY sticker_collected_ts LIMIT 1)[OFFSET(0)] AS x
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers`
  WHERE sticker_collected_date BETWEEN '2026-06-22' AND '2026-09-06' AND album_id IN (61,63) AND is_sticker_collected AND sticker_type IN ('common','golden','super')
  GROUP BY 1,2,3),
s AS (SELECT album_id, user_id, sticker_id, x.t AS t, x.w AS w, x.dt AS dt FROM s0),
j AS (SELECT f.album_id, f.user_id, DATE_DIFF(f.fin_d, f.a_end, DAY) AS fin_rel,
    MIN(IF(s.w AND s.dt >= DATE_SUB(f.a_end, INTERVAL 14 DAY), DATE_DIFF(s.dt, f.a_end, DAY), NULL)) AS first_wild,
    MIN(IF(s.t='super' AND s.dt >= DATE_SUB(f.a_end, INTERVAL 14 DAY), DATE_DIFF(s.dt, f.a_end, DAY), NULL)) AS first_rare,
    MAX(IF(s.t='super', DATE_DIFF(s.dt, f.a_end, DAY), NULL)) AS last_rare
  FROM f JOIN s ON s.album_id=f.album_id AND s.user_id=f.user_id AND s.dt < f.a_end GROUP BY 1,2,3)
SELECT album_id, COUNT(*) AS finishers, COUNTIF(fin_rel < -7) AS f_early,
  APPROX_QUANTILES(first_wild,100)[OFFSET(50)] AS med_first_pick, ROUND(COUNTIF(first_wild IS NULL)/COUNT(*),4) AS sh_no_pick,
  APPROX_QUANTILES(first_rare,100)[OFFSET(50)] AS med_first_rare, APPROX_QUANTILES(last_rare,100)[OFFSET(50)] AS med_last_rare,
  ROUND(COUNTIF(fin_rel = -1)/COUNT(*),4) AS sh_fin_dm1, ROUND(COUNTIF(fin_rel >= -3)/COUNT(*),4) AS sh_fin_last3
FROM j GROUP BY 1 ORDER BY 1
```

**R-Domino: `domino-dreams-dbt`, 22.94 GB.**
```sql
WITH ex AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN '2026-04-02' AND '2026-08-23' AND suspected_cheater_flag),
d AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c, IFNULL(a.album_spent_today,0) AS sp, a.login_ratio AS lr, a.user_album_count AS uac,
    IFNULL(a.unique_common_stickers_lt,0)+IFNULL(a.unique_golden_stickers_lt,0)+IFNULL(a.unique_royal_stickers_tl,0) AS u
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN ex ON ex.user_id=a.user_id
  WHERE a.date_dim BETWEEN '2026-04-02' AND '2026-08-23' AND a.album_id IN (17,19)
    AND a.special_user_flag = FALSE AND ex.user_id IS NULL AND a.date_dim < a.album_close_date),
f AS (SELECT album_id, user_id, ANY_VALUE(c) AS c, MIN(IF(u>=144, date_dim, NULL)) AS fin_d FROM d GROUP BY 1,2
  HAVING SUM(sp)>0 AND MAX_BY(uac, date_dim) > 1 AND MAX_BY(lr, date_dim) >= 0.5 AND MAX(u) >= 144),
s AS (SELECT album_id, user_id, sticker_id, MIN(sticker_collected_min_date) AS dt,
    LOGICAL_OR(IFNULL(collected_by_joker_flag,FALSE)) AS jk, ANY_VALUE(LOWER(sticker_type)) AS t
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers`
  WHERE sticker_collected_min_date BETWEEN '2026-04-02' AND '2026-08-23' AND album_id IN (17,19)
    AND user_collected_sticker_flag AND LOWER(sticker_type) IN ('common','golden','royal') GROUP BY 1,2,3),
j AS (SELECT f.album_id, f.user_id, DATE_DIFF(f.fin_d, f.c, DAY) AS fin_rel,
    MIN(IF(s.jk AND s.dt >= DATE_SUB(f.c, INTERVAL 14 DAY), DATE_DIFF(s.dt, f.c, DAY), NULL)) AS first_pick,
    MIN(IF(s.t='royal' AND s.dt >= DATE_SUB(f.c, INTERVAL 14 DAY), DATE_DIFF(s.dt, f.c, DAY), NULL)) AS first_rare,
    MAX(IF(s.t='royal', DATE_DIFF(s.dt, f.c, DAY), NULL)) AS last_rare
  FROM f JOIN s ON s.album_id=f.album_id AND s.user_id=f.user_id AND s.dt < f.c GROUP BY 1,2,3)
SELECT album_id, COUNT(*) AS finishers, COUNTIF(fin_rel < -7) AS f_early,
  APPROX_QUANTILES(IF(fin_rel >= -7, first_pick, NULL),100)[OFFSET(50)] AS med_first_pick_flate,
  ROUND(COUNTIF(fin_rel >= -7 AND first_pick IS NULL)/COUNTIF(fin_rel >= -7),4) AS sh_no_pick_flate,
  APPROX_QUANTILES(IF(fin_rel >= -7, first_rare, NULL),100)[OFFSET(50)] AS med_first_rare_flate,
  APPROX_QUANTILES(IF(fin_rel >= -7, last_rare, NULL),100)[OFFSET(50)] AS med_last_rare_flate,
  ROUND(COUNTIF(fin_rel = -1)/COUNTIF(fin_rel >= -7),4) AS sh_fin_dm1_flate
FROM j GROUP BY 1 ORDER BY 1
```

**R-Disney: `solitaire-dreams-411507`, 57.36 GB.**
```sql
WITH ex AS (SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN '2020-01-01' AND '2026-10-05' AND exclude_reason IS NOT NULL),
d AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c, IFNULL(a.album_spent_today,0) AS sp, a.login_ratio AS lr, a.user_album_count AS uac,
    IFNULL(a.unique_common_stickers_lt,0)+IFNULL(a.unique_golden_stickers_lt,0)+IFNULL(a.unique_royal_stickers_tl,0) AS u
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN ex ON ex.user_id=a.user_id
  WHERE a.date_dim BETWEEN '2026-07-13' AND '2026-10-04' AND a.album_id IN (14,15)
    AND a.special_user_flag = FALSE AND ex.user_id IS NULL AND a.date_dim < a.album_close_date),
p AS (SELECT album_id, user_id, ANY_VALUE(c) AS c, MAX(u) AS u_end, MIN(IF(u>=144, date_dim, NULL)) AS fin_d FROM d GROUP BY 1,2
  HAVING SUM(sp)>0 AND MAX(uac) > 1 AND MAX_BY(lr, date_dim) >= 0.5 AND MAX(u) >= 141),
s AS (SELECT album_id, user_id, sticker_id, MIN(sticker_collected_min_date) AS dt, ANY_VALUE(sticker_type) AS t,
    ARRAY_AGG(IFNULL(collected_by_joker_flag,FALSE) ORDER BY sticker_collected_min_ts LIMIT 1)[OFFSET(0)] AS jk
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers`
  WHERE sticker_collected_min_date BETWEEN '2026-07-13' AND '2026-10-04' AND album_id IN (14,15)
    AND user_collected_sticker_flag AND sticker_type IN ('Common','Golden','Royal') GROUP BY 1,2,3),
j AS (SELECT p.album_id, p.user_id, p.u_end, DATE_DIFF(p.fin_d, p.c, DAY) AS fin_rel, COUNTIF(s.dt < p.c) AS n_stk_table,
    MIN(IF(s.jk AND s.dt >= DATE_SUB(p.c, INTERVAL 14 DAY) AND s.dt < p.c, DATE_DIFF(s.dt, p.c, DAY), NULL)) AS first_pick,
    MIN(IF(s.t='Royal' AND s.dt >= DATE_SUB(p.c, INTERVAL 14 DAY) AND s.dt < p.c, DATE_DIFF(s.dt, p.c, DAY), NULL)) AS first_rare
  FROM p LEFT JOIN s ON s.album_id=p.album_id AND s.user_id=p.user_id GROUP BY 1,2,3,4)
SELECT album_id, IF(u_end >= 144,'F','N') AS grp, COUNT(*) AS n, COUNTIF(fin_rel < -7) AS f_early,
  APPROX_QUANTILES(first_pick,100)[OFFSET(50)] AS med_first_pick, ROUND(COUNTIF(first_pick IS NULL)/COUNT(*),4) AS sh_no_pick,
  APPROX_QUANTILES(first_rare,100)[OFFSET(50)] AS med_first_rare, ROUND(COUNTIF(fin_rel = -1)/COUNT(*),4) AS sh_fin_dm1,
  COUNTIF(n_stk_table >= 144) AS n_144_in_sticker_table, COUNTIF(n_stk_table < 144) AS n_lt144_in_sticker_table
FROM j GROUP BY 1,2 ORDER BY 1,2
```

**Worth saving to memory or the project:**
- **End-of-album comparison standard:** use N1 as the cross-game near-finisher group.
  - Disney T1 shares must be re-based to per group-day.
  - Cross-game purchase linkage uses "on a paying day vs Commons", because Disney has no curated purchase timestamps.
  - Pick timing (median first Wild/Joker fill): Dice −3, Domino −8 / −5, Disney −1 / −2.
- **Disney data gap:** 1.7–2.4% of daily-table near-finishers have all 144 stickers in the sticker table. Disney F may be under-counted by up to ~9% (Needs Validation).
---

Note: claude-sonnet-5[1m] (the safety classifier) was unavailable (timed out) when reviewing this subagent's work. Please carefully verify the subagent's actions and output before acting on them.

# Dice Dreams: how not-first payers finish albums 61 and 63 in the last week

Project `dice-dreams-dbt`. All six queries ran (123.4 GB in total, largest 26.65 GB). Nothing failed. The F-early group is empty in both albums.

**Population and definitions**
- **Population:** not-first-album PU.
  - `user_past_album_count` > 0.
  - `spent_in_album_today` > 0 before close.
  - `is_excluded` = FALSE.
  - Login ratio on the last row before close ≥ 0.5.
  - The close day is excluded.
- **Day index:** d = date − close date. Album 61 closes 2026-07-27 and album 63 closes 2026-09-07, both at 12:00 UTC, so d = −1 is a full day.
- **Sticker terms:**
  - Rare = Super.
  - Wild fill = `collected_from_wild` = TRUE.
  - New = the player's first receipt of that sticker_id.

**Groups.** Finishing is defined as 144 unique set stickers, not the game flag.

| Group | Album 61 | Album 63 |
|---|---|---|
| Population (not-first PU) | 176,332 | 180,849 |
| F = finishers (144 before close) | 14,345 (8.1%) | 18,915 (10.5%) |
| — F-late (finished d = −7…−1) | 14,345 | 18,915 |
| — F-early (finished before d = −7) | **0** | **0** |
| N1 (exactly 1 short at end of d = −1) | 6,422 | 7,553 |
| N2-3 (2–3 short) | 56,519 | 93,754 |
| Other PU (4+ short, reference only) | 99,046 | 60,627 |

The finish rates match the critic's re-run (8.1% / 10.5%). Because no finisher completed before d = −7, F means F-late everywhere below.

## 1. Five headline findings

1. **Every finisher completed in the final 7 days; 88% / 84% completed in the last 3 days.** The finishing sticker was a Super for 81% / 70% of them, and it arrived via a Wild for 90% / 87%.
   - Label: Known. Population: F. n = 14,345 / 18,915.
2. **The closing run starts at d = −4 to −3, and it is driven by Wilds, not Goldens.**
   - The share of finishers with ≥1 Wild fill per day rises from 0.5% in the baseline week to 33–45% on d = −3…−2.
   - Their median first Wild fill is at d = −3.
   - New Supers per active day rise from 0.28 to 1.24 (61) and from 0.29 to 0.89 (63).
   - Goldens arrive in a single population-wide drop on d = −4 (61) / d = −5 (63) and then decline.
   - Label: Known. Population: F. n = 14,345 / 18,915.
3. **Finishers' paying rises with the Wild run; N2-3 payers' does not.**
   - Finishers' pay rate roughly doubles, from 25–26% in the baseline week to 52–53% on d = −1.
   - Their PU ARPDAU rises 2.4×, from $7.7–7.8 to $18.2–18.9.
   - N2-3 stay flat (19% → 20% in 61; 17% → 13% in 63), and their ARPDAU falls ($3.78 → $2.91; $2.98 → $1.72).
   - Label: Known (descriptive, not causal). Population: F and N2-3. n = 14,345 / 18,915 and 56,519 / 93,754.
4. **New Supers arrive within 10 minutes after a purchase far more often than new Commons do.**
   - For finishers' new Supers in the last week: 55% (61) / 59% (63).
   - Control, their new Commons in the same window: 11% / 14%.
   - Placebo, the same window shifted 24 h earlier: ≤ 0.9%.
   - Wild Supers that come from `Pricing_*` packs are 99.8% purchase-linked.
   - Label: Known for the timing. Needs Validation that the purchase delivered the sticker, because no ID links a purchase to a sticker. Population: F. n = 66,611 / 73,535 new Supers.
5. **Near-finishers are stuck on one fixed set of three stickers (2 Supers + 1 Golden).** Called "the gate trio" below.
   - Album 61: Super 143, Super 120, Golden 142. Album 63: Super 132, Super 143, Golden 129.
   - 59% / 76% of N2-3 are missing exactly these three (pattern "SSG").
   - 97% / 95% of N2-3 are missing the top gate Super (61: S143; 63: S132).
   - Only 7.5% / 11% of the whole population held that Super by d = −2.
   - On d = −2 and −1, 99.8%+ of its new holders got it via a Wild.
   - Label: Known for the numbers; Hypothesis that these stickers are locked by release date or config. Population: N1 + N2-3. n = 62,941 / 101,307.

## 2. Tables

### T1: Daily acquisition profile

Shares are of the whole group. The baseline-week row is the average day of d = −14…−8.
- Active = `is_active`.
- Paid = `spent_in_album_today` > 0.
- PU ARPDAU = revenue ÷ active player-days.

**Date-alignment check:** 0% of player-days with a new sticker fell on an inactive or missing `user_daily_album` row. Sticker dates (UTC) therefore line up with `date_dim`.

**Album 61, F (all finishers are F-late), n = 14,345**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 94% | 57% | 19% | 0.5% | 1.34 | 0.28 | 0.01 | 25% | $7.78 | $29.53 |
| -7 | 95% | 51% | 17% | 5.9% | 1.36 | 0.27 | 0.09 | 27% | $9.00 | $31.62 |
| -6 | 95% | 29% | 23% | 7.9% | 0.65 | 0.38 | 0.12 | 28% | $8.98 | $31.12 |
| -5 | 96% | 20% | 22% | 9.0% | 0.34 | 0.37 | 0.13 | 31% | $10.11 | $31.51 |
| -4 | 96% | 57% | 34% | 16% | 0.79 | 0.72 | 0.23 | 34% | $12.48 | $35.26 |
| -3 | 96% | 29% | 42% | 33% | 0.41 | 1.05 | 0.55 | 46% | $18.53 | $39.02 |
| -2 | 97% | 28% | 49% | 45% | 0.35 | 1.24 | 0.84 | 53% | $19.89 | $36.49 |
| -1 | 97% | 21% | 37% | 38% | 0.24 | 0.81 | 0.80 | 52% | $18.94 | $35.58 |

**Album 61, N1, n = 6,422**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 94% | 57% | 18% | 0.5% | 1.33 | 0.26 | 0.01 | 23% | $5.91 | $23.92 |
| -7 | 95% | 50% | 15% | 3.2% | 1.36 | 0.22 | 0.04 | 24% | $6.38 | $24.97 |
| -6 | 95% | 28% | 20% | 4.7% | 0.64 | 0.32 | 0.06 | 25% | $6.28 | $24.21 |
| -5 | 95% | 19% | 19% | 5.8% | 0.34 | 0.31 | 0.07 | 28% | $6.43 | $22.01 |
| -4 | 96% | 59% | 33% | 10% | 0.80 | 0.67 | 0.13 | 31% | $8.00 | $24.75 |
| -3 | 96% | 24% | 37% | 23% | 0.34 | 0.84 | 0.31 | 37% | $10.17 | $26.80 |
| -2 | 96% | 23% | 46% | 39% | 0.28 | 1.06 | 0.59 | 43% | $11.65 | $26.05 |
| -1 | 97% | 25% | 38% | 39% | 0.28 | 0.78 | 0.61 | 49% | $13.95 | $27.66 |

**Album 61, N2-3, n = 56,519**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 94% | 58% | 19% | 0.4% | 1.33 | 0.27 | 0.00 | 19% | $3.78 | $18.50 |
| -7 | 95% | 53% | 13% | 1.5% | 1.42 | 0.18 | 0.02 | 18% | $3.26 | $16.68 |
| -6 | 95% | 29% | 18% | 2.1% | 0.65 | 0.27 | 0.02 | 19% | $2.94 | $14.69 |
| -5 | 95% | 16% | 17% | 2.5% | 0.29 | 0.26 | 0.03 | 21% | $3.24 | $14.71 |
| -4 | 95% | 62% | 30% | 2.7% | 0.79 | 0.59 | 0.03 | 19% | $3.08 | $15.02 |
| -3 | 94% | 18% | 22% | 4.7% | 0.25 | 0.43 | 0.05 | 17% | $2.74 | $14.89 |
| -2 | 94% | 6.4% | 34% | 14% | 0.10 | 0.69 | 0.16 | 18% | $2.64 | $14.07 |
| -1 | 96% | 7.0% | 29% | 15% | 0.09 | 0.58 | 0.17 | 20% | $2.91 | $14.13 |

**Album 61, Other PU (reference), n = 99,046.** Pay rate per day: baseline week 11%; d = −3 / −2 / −1 at 8.0% / 7.8% / 7.6%. PU ARPDAU: $1.66 in the baseline week, $0.82 on d = −1. Wild fills stay at 0.9–2.4% per day.

**Album 63, F, n = 18,915**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 94% | 60% | 21% | 0.5% | 1.49 | 0.29 | 0.01 | 26% | $7.72 | $27.56 |
| -7 | 95% | 28% | 20% | 7.1% | 0.65 | 0.31 | 0.11 | 29% | $8.87 | $29.39 |
| -6 | 95% | 22% | 27% | 12% | 0.48 | 0.49 | 0.20 | 27% | $8.69 | $30.09 |
| -5 | 95% | 53% | 24% | 11% | 0.78 | 0.44 | 0.17 | 32% | $9.56 | $27.96 |
| -4 | 95% | 32% | 31% | 19% | 0.49 | 0.56 | 0.29 | 35% | $12.39 | $33.36 |
| -3 | 96% | 24% | 48% | 32% | 0.37 | 0.89 | 0.51 | 46% | $17.06 | $35.69 |
| -2 | 96% | 25% | 40% | 38% | 0.34 | 0.75 | 0.63 | 51% | $18.83 | $35.49 |
| -1 | 97% | 25% | 36% | 37% | 0.29 | 0.64 | 0.76 | 53% | $18.20 | $33.29 |

**Album 63, N1, n = 7,553**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 93% | 60% | 21% | 0.5% | 1.49 | 0.28 | 0.01 | 24% | $5.79 | $22.69 |
| -7 | 94% | 28% | 19% | 5.2% | 0.65 | 0.27 | 0.07 | 26% | $6.33 | $22.71 |
| -6 | 94% | 22% | 26% | 9.7% | 0.46 | 0.45 | 0.14 | 25% | $6.16 | $23.40 |
| -5 | 94% | 53% | 24% | 7.4% | 0.80 | 0.42 | 0.10 | 29% | $6.57 | $21.43 |
| -4 | 95% | 34% | 27% | 12% | 0.54 | 0.46 | 0.14 | 31% | $7.92 | $24.39 |
| -3 | 94% | 19% | 44% | 21% | 0.33 | 0.74 | 0.27 | 36% | $10.07 | $26.25 |
| -2 | 94% | 21% | 37% | 32% | 0.30 | 0.62 | 0.43 | 43% | $12.28 | $26.73 |
| -1 | 96% | 20% | 37% | 38% | 0.26 | 0.62 | 0.63 | 48% | $13.07 | $26.12 |

**Album 63, N2-3, n = 93,754**

| d | Active | ≥1 new Golden | ≥1 new Super | ≥1 Wild fill | new G / active | new S / active | Wild fills / active | Paid | PU ARPDAU | $ / paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base wk | 94% | 62% | 21% | 0.7% | 1.50 | 0.28 | 0.01 | 17% | $2.98 | $16.60 |
| -7 | 95% | 31% | 16% | 2.5% | 0.73 | 0.21 | 0.03 | 17% | $2.83 | $15.75 |
| -6 | 94% | 21% | 22% | 2.7% | 0.47 | 0.33 | 0.03 | 14% | $1.96 | $13.08 |
| -5 | 94% | 55% | 20% | 1.9% | 0.78 | 0.32 | 0.02 | 16% | $1.96 | $11.69 |
| -4 | 94% | 32% | 24% | 1.9% | 0.48 | 0.35 | 0.02 | 13% | $1.86 | $13.09 |
| -3 | 93% | 12% | 42% | 4.2% | 0.22 | 0.63 | 0.05 | 13% | $1.87 | $13.08 |
| -2 | 93% | 4.7% | 21% | 5.4% | 0.10 | 0.33 | 0.06 | 13% | $1.88 | $12.99 |
| -1 | 93% | 3.1% | 11% | 4.7% | 0.06 | 0.18 | 0.06 | 13% | $1.72 | $12.61 |

**Album 63, Other PU (reference), n = 60,627.** Pay rate per day: baseline week 9.2%; d = −3…−1 at 5.3–5.5%. PU ARPDAU: $1.52 in the baseline week, $0.82 on d = −1.

**What T1 shows (Known, descriptive):**
- The Golden curve does not rise toward the close.
- Goldens come in one drop for the whole population (d = −4 in 61, d = −5 in 63). On that day 53–62% of every group, Other PU included, get a new Golden; inflow then declines.
- Supers and Wild fills rise over the last 3–4 days. Wild fills rise only in F and N1.

### T2: When do players start? (share of group by day d; "≤ −8" = already in the baseline week)

| Album | Group (n) | Metric | none in −14…−1 | ≤ −8 | −7 | −6 | −5 | −4 | −3 | −2 | −1 | median d |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 61 | F (14,345) | first new Golden | 0.0% | 99.7% | 0.1% | 0.1% | 0.0% | 0.0% | 0.0% | 0.0% | 0.0% | −13 |
| 61 | F | first new Super | 0.0% | 82.8% | 4.0% | 3.0% | 2.6% | 3.1% | 2.5% | 1.7% | 0.3% | −12 |
| 61 | F | **first Wild fill** | 0.0% | 3.6% | 5.7% | 6.3% | 6.3% | 10.6% | 24.5% | 27.3% | 15.8% | **−3** |
| 61 | F | first paying day | 1.0% | 69.2% | 3.4% | 2.9% | 2.8% | 3.2% | 6.0% | 6.4% | 5.1% | −11 |
| 61 | F | last new Golden | 0.0% | 4.4% | 3.4% | 4.2% | 5.3% | 15.6% | 20.2% | 25.9% | 21.2% | −3 |
| 61 | F | last new Super | 0.0% | 0.0% | 1.0% | 2.0% | 2.8% | 7.4% | 17.3% | 32.6% | 36.9% | −2 |
| 61 | F | last paying day | 1.0% | 0.5% | 0.4% | 0.6% | 1.1% | 3.3% | 12.3% | 29.0% | 51.9% | −1 |
| 61 | N1 (6,422) | first Wild fill | 3.5% | 3.8% | 3.1% | 4.1% | 4.5% | 8.3% | 19.5% | 28.5% | 24.7% | −2 |
| 61 | N1 | last new Super | 0.0% | 0.1% | 0.3% | 1.6% | 2.9% | 8.9% | 17.2% | 30.9% | 38.1% | −2 |
| 61 | N1 | last paying day | 3.5% | 1.8% | 0.7% | 1.1% | 1.8% | 5.0% | 12.2% | 25.2% | 48.8% | −1 |
| 61 | N2-3 (56,519) | first Wild fill | **59.2%** | 2.7% | 1.4% | 1.9% | 2.3% | 2.3% | 4.2% | 12.7% | 13.3% | −2 |
| 61 | N2-3 | last new Golden | 0.0% | 13.6% | 3.1% | 2.0% | 2.2% | 51.7% | 14.8% | 5.6% | 7.0% | −4 |
| 61 | N2-3 | last paying day | 17.0% | 16.8% | 4.1% | 4.8% | 7.3% | 8.7% | 9.4% | 12.3% | 19.7% | −4 |
| 63 | F (18,915) | first new Golden | 0.0% | 99.8% | 0.1% | 0.0% | 0.0% | 0.0% | 0.0% | 0.0% | 0.0% | −14 |
| 63 | F | first new Super | 0.0% | 88.7% | 3.1% | 2.2% | 1.9% | 1.5% | 1.8% | 0.7% | 0.2% | −11 |
| 63 | F | **first Wild fill** | 0.1% | 3.3% | 6.9% | 10.0% | 7.7% | 12.7% | 21.1% | 21.8% | 16.4% | **−3** |
| 63 | F | first paying day | 0.2% | 72.3% | 3.5% | 3.6% | 3.2% | 3.1% | 4.5% | 4.8% | 4.8% | −12 |
| 63 | F | last new Golden | 0.0% | 2.5% | 2.7% | 4.5% | 10.4% | 13.2% | 18.4% | 23.6% | 24.8% | −3 |
| 63 | F | last new Super | 0.0% | 0.0% | 0.8% | 3.1% | 3.7% | 10.5% | 19.1% | 27.2% | 35.6% | −2 |
| 63 | F | last paying day | 0.2% | 0.1% | 0.2% | 0.7% | 1.5% | 4.6% | 13.1% | 26.9% | 52.9% | −1 |
| 63 | N1 (7,553) | first Wild fill | 3.8% | 3.5% | 5.1% | 8.5% | 5.4% | 8.7% | 16.1% | 23.3% | 25.7% | −2 |
| 63 | N1 | last paying day | 1.3% | 0.7% | 0.5% | 1.5% | 3.1% | 5.5% | 13.2% | 26.4% | 47.9% | −2 |
| 63 | N2-3 (93,754) | first Wild fill | **74.1%** | 4.9% | 2.4% | 2.5% | 1.7% | 1.7% | 3.7% | 4.9% | 4.1% | −4 |
| 63 | N2-3 | last new Golden | 0.0% | 5.5% | 2.6% | 2.2% | 44.0% | 28.3% | 10.1% | 4.1% | 3.1% | −5 |
| 63 | N2-3 | last paying day | 22.8% | 21.6% | 5.9% | 4.8% | 7.1% | 6.9% | 8.1% | 10.1% | 12.7% | −5 |

"First new Golden" tells us nothing, because 99.7%+ of every group already gets Goldens in the baseline week. In Dice there is no last-week start for Goldens. The useful start markers are the first Wild fill and the last new Super / Golden.

**Finishing sticker (F)**

| | Album 61 (n = 14,345) | Album 63 (n = 18,915) |
|---|---|---|
| Type: Super / Golden / Common | 81.3% / 18.2% / 0.6% | 70.4% / 28.9% / 0.6% |
| Super via Wild (share of all finishers) | 78.7% | 67.9% |
| Golden via Wild (share of all finishers) | 11.1% | 18.6% |
| Channel: Wild, paid offer (`Pricing_*` pack) | 58.0% | 69.4% |
| Channel: Wild, event reward (Trail Final Reward, blast grand prize, wheel…) | 31.8% | 17.1% |
| Channel: paid offer, not a Wild (`Pricing_*` "specific" packs) | 6.5% | 9.7% |
| Channel: Trail / other events / steady progression / dup exchange | 1.3% / 1.9% / 0.4% / 0.03% | 1.4% / 1.9% / 0.4% / 0.1% |
| Finishing day: d = −1 / −2 / −3 / −4 / −5…−7 | 38.9% / 32.3% / 16.6% / 6.9% / 5.4% | 37.9% / 27.6% / 18.5% / 9.8% / 6.2% |

### T3: Channel of new Supers and new Goldens, d = −7…−1 (share of new stickers of that type)

**New Supers**

| Channel | 61 F | 61 N1 | 61 N2-3 | 61 Other | 63 F | 63 N1 | 63 N2-3 | 63 Other |
|---|---|---|---|---|---|---|---|---|
| Wild, paid offer | 37.9% | 24.1% | 6.0% | 2.5% | 47.4% | 33.9% | 5.8% | 3.1% |
| Wild, event reward | 13.6% | 15.1% | 9.5% | 2.3% | 6.6% | 8.3% | 3.9% | 1.6% |
| Paid offer, not a Wild | 0.0% | 0.0% | 0.0% | 0.0% | 0.1% | 0.1% | 0.0% | 0.1% |
| Dup exchange | 6.0% | 7.8% | 12.7% | 15.4% | 1.6% | 1.7% | 3.2% | 2.0% |
| Trail (recurring MTX event) | 14.5% | 18.6% | 24.3% | 25.4% | 13.9% | 18.6% | 27.9% | 24.9% |
| Steady progression | 2.3% | 3.0% | 5.2% | 8.5% | 3.2% | 4.2% | 9.0% | 9.4% |
| Other events | 25.6% | 31.2% | 42.2% | 45.7% | 27.2% | 33.2% | 50.0% | 58.8% |
| Unknown / other | 0.1% | 0.1% | 0.1% | 0.2% | 0.1% | 0.1% | 0.2% | 0.2% |
| n new Supers | 66,611 | 25,864 | 160,046 | 179,739 | 73,535 | 25,655 | 206,856 | 86,284 |

**New Goldens**

| Channel | 61 F | 61 N1 | 61 N2-3 | 61 Other | 63 F | 63 N1 | 63 N2-3 | 63 Other |
|---|---|---|---|---|---|---|---|---|
| Wild, paid offer | 4.7% | 2.3% | 0.3% | 0.1% | 12.6% | 6.3% | 0.8% | 0.2% |
| Wild, event reward | 2.1% | 2.0% | 0.3% | 0.0% | 1.4% | 1.7% | 0.5% | 0.2% |
| Paid offer, not a Wild | 28.6% | 27.0% | 17.0% | 11.8% | 32.3% | 30.6% | 15.9% | 10.5% |
| Dup exchange | 0.0% | 0.0% | 0.0% | 0.0% | 2.0% | 2.6% | 3.0% | 1.8% |
| Trail | 3.8% | 4.0% | 4.8% | 6.4% | 6.9% | 7.8% | 10.8% | 9.7% |
| Steady progression | 34.9% | 37.5% | 45.3% | 45.7% | 21.9% | 24.6% | 34.7% | 37.0% |
| Other events | 25.6% | 26.8% | 31.8% | 35.5% | 22.6% | 26.1% | 34.1% | 39.9% |
| Unknown / other | 0.3% | 0.4% | 0.4% | 0.6% | 0.2% | 0.3% | 0.4% | 0.6% |
| n new Goldens | 56,896 | 24,797 | 192,928 | 457,719 | 61,150 | 23,758 | 250,008 | 213,274 |

**How raw sources map to channels.** Rules are applied in this order. They come from the source inventory (Q0) and extend the Topic-5 mapping (v2).
1. **Wild, paid offer:** `collected_from_wild` AND `sticker_pack_key LIKE 'Pricing%'`.
   - Sources seen: DP_Big_Chest_WithStamp, Decoy_BuyAll, Decoy_Upgrade, OnePlusSixteen, OnePlusTwelve_V4, 1PlusX, BuildYourBundle, Big_Chest_Animated_v2/v3, 1To2_BigChest_Animated, Scrolling_Offer_WithoutClass(_V2), plus Pending Rewards and CustomerSupportReward when they carry a Pricing pack.
   - 99.5–100% of these stickers arrive ≤ 10 min after a purchase, so "paid" is Known for this channel.
2. **Wild, event reward:** `collected_from_wild` with a pack key that is not Pricing.
   - Sources: Trail - Final Reward (GP_Trail_01), blast grand prize, Reward_Bonus_Wheel_v2, (null) source with a GP_Merge_Collection pack, Pending Rewards with a GP_Trail pack.
   - 23–26% of finishers' stickers in this channel arrive ≤ 10 min after a purchase.
3. **Dup exchange:** `Duplication exchange`.
4. **Paid offer, not a Wild:** `sticker_pack_key LIKE 'Pricing%'`, or `Dream Pass` with a Premium pack.
   - Examples: OnePlusThree, OnePlusTwo_V3, 1Plus1_V3, ScrollingOffer_*, 6Boxes_V3, Limited_Stock; the Journey events (EnchantedJourney, USAThemeJourney_Night, DeepDiveJourney) when they carry Pricing_DDJ/CP packs; Generic_Reward_NoCloseButton when it carries a Pricing pack.
5. **Trail:** source `Trail%` or pack key `%Trail%`. This includes Generic_Reward_NoCloseButton with an HGP_Trail_01 pack.
6. **Steady progression:** Progress Bar V2, RewardCalendar, WeeklyGoals, Pets Feature, Pets. This is the closest Dice equivalent of a "regular pull".
7. **Unknown / other:** (null) source without a Collection pack, Pending Rewards, CustomerSupportReward (non-Pricing packs).
8. **Other events:** everything else. Examples: PropChase_Hunt, parallel roads/quest, VerticalQuest, 3ToWin, TileTwister_v2, Duel, Tournament*, Royal_Fortune, Dynamic_Path_v3, Puzzle/Merge Collection, Frankys_*, blast small reward, new kingdom, ColoringBook, Market_With_PB_v3.

**What T3 shows:**
- Dice has essentially no paid route to a Super that is not a Wild (≤ 0.1%). A paid Super is always a Wild fill.
- Paid Goldens come as "specific" packs that are not Wilds (27–32% of finishers' new Goldens).

### T4: Purchase linkage of new stickers, d = −7…−1

Purchase timestamps come from `20_core.purchase_completed_vw`, deduplicated on user × timestamp × external_order_id, with amount > 0.
- Control: the same group's new Commons in the same window.
- Placebo: the same 10-minute window shifted 24 h earlier.

| Album | Group | Sticker | n new | On a paying day | ≤ 10 min after a purchase | Placebo (−24 h) |
|---|---|---|---|---|---|---|
| 61 | F | Super (all) | 66,611 | 82.4% | 54.9% | 0.7% |
| 61 | F | Super, Wild | 34,307 | 95.0% | 80.2% | 0.8% |
| 61 | F | Super, not Wild | 32,304 | 69.1% | 28.0% | 0.5% |
| 61 | F | Golden (all) | 56,896 | 50.1% | 31.8% | 0.4% |
| 61 | F | Golden, Wild | 3,867 | 90.3% | 76.2% | 0.9% |
| 61 | F | **Common (control)** | 46,893 | 35.3% | **10.7%** | 0.2% |
| 61 | N1 | Super / Golden / Common | 25,864 / 24,797 / 20,683 | 72.2% / 44.8% / 31.0% | 41.2% / 27.3% / 9.0% | 0.4% / 0.3% / 0.2% |
| 61 | N2-3 | Super / Golden / Common | 160,046 / 192,928 / 180,608 | 39.3% / 27.6% / 23.2% | 17.1% / 13.0% / 6.5% | 0.3% / 0.2% / 0.2% |
| 61 | Other | Super / Golden / Common | 179,739 / 457,719 / 661,565 | 24.4% / 18.2% / 18.6% | 9.6% / 7.0% / 6.0% | ≤ 0.2% |
| 63 | F | Super (all) | 73,535 | 82.8% | 59.3% | 0.7% |
| 63 | F | Super, Wild | 39,701 | 98.2% | 90.4% | 0.8% |
| 63 | F | Super, not Wild | 33,834 | 64.7% | 22.8% | 0.5% |
| 63 | F | Golden (all) | 61,150 | 61.7% | 43.7% | 0.5% |
| 63 | F | Golden, Wild | 8,558 | 98.7% | 92.3% | 0.8% |
| 63 | F | **Common (control)** | 22,745 | 38.3% | **14.4%** | 0.2% |
| 63 | N1 | Super / Golden / Common | 25,655 / 23,758 / 9,346 | 74.4% / 53.2% / 32.5% | 46.6% / 35.0% / 11.2% | 0.5% / 0.4% / 0.1% |
| 63 | N2-3 | Super / Golden / Common | 206,856 / 250,008 / 117,159 | 32.2% / 24.2% / 20.6% | 13.7% / 11.4% / 7.4% | ≤ 0.3% |
| 63 | Other | Super / Golden / Common | 86,284 / 213,274 / 249,381 | 21.6% / 17.8% / 17.1% | 8.7% / 8.2% / 7.2% | ≤ 0.2% |

**What T4 shows (Known, timing only):**
- For finishers, new Supers are 5.1× (61) and 4.1× (63) as likely as their new Commons to land ≤ 10 min after a purchase.
- Even Supers that are not Wilds (28% / 23%) are 2–3× the Common control.
- This applies the critic's control (the player's own Commons, same window) in place of yesterday's ±24 h placebo. Whether the purchase "bought" the sticker stays Needs Validation, because nothing links a purchase to a specific sticker.

### T5: Sequences and what near-finishers are missing

**Finishers' last 5 new stickers, oldest → newest** (S = Super, G = Golden, w = Wild fill). Top 5 by type only:

| Album 61 (n = 14,345) | Share | Album 63 (n = 18,915) | Share |
|---|---|---|---|
| S>S>S>G>S | 11.4% | G>S>S>G>S | 12.6% |
| S>S>G>S>S | 10.3% | S>S>S>G>S | 12.1% |
| S>G>S>S>S | 10.1% | S>S>S>S>G | 9.8% |
| S>S>S>S>G | 9.6% | S>G>S>G>S | 8.7% |
| S>S>S>S>S | 8.1% | G>S>S>S>G | 7.2% |

Top 5 with the Wild marker (patterns are more scattered):

| Album 61 | Share | Album 63 | Share |
|---|---|---|---|
| G>S>Sw>G>Sw | 3.4% | G>S>Sw>G>Sw | 7.5% |
| S>S>Sw>G>Sw | 3.2% | S>S>Sw>G>Sw | 5.6% |
| G>G>S>Sw>Sw | 2.9% | S>G>Sw>G>Sw | 4.9% |
| G>S>S>Sw>Sw | 2.8% | G>G>S>Sw>Sw | 3.4% |
| Sw>G>S>Sw>Sw | 2.8% | G>S>Sw>Sw>Gw | 3.3% |

The last five are almost never Commons. A typical finish is 3–4 Supers mixed with 1–2 Goldens, and the last two Supers are Wild fills.

**What near-finishers are missing at the end of d = −1:**

| Album | Group | Missing mix (S = Super, G = Golden, C = Common) |
|---|---|---|
| 61 | N1 (6,422) | S 73.1% · G 17.2% · C 9.7% |
| 61 | N2-3 (56,519) | SSG 58.8% · SS 15.2% · SG 14.4% · SSS 8.8% |
| 63 | N1 (7,553) | S 62.6% · G 27.8% · C 9.6% |
| 63 | N2-3 (93,754) | SSG 75.8% · SG 14.1% · SS 7.4% |

**Most-missing stickers and whether anyone could get them.** "First d" = first time anyone in the population received it. "Pop hold by −2" = share of the population holding it by the end of d = −2.

| Album | Sticker | Missing in N1 | Missing in N2-3 | First d | Pop hold by −2 | F holders by −2 |
|---|---|---|---|---|---|---|
| 61 | S143 | 55.8% | 96.6% | −20 | 7.5% | 9,573 / 14,345 |
| 61 | G142 | 14.5% | 73.7% | −26 | 17.2% | 11,327 |
| 61 | S120 | 10.2% | 67.8% | −21 | 15.3% | 11,289 |
| 61 | S144 | 3.8% | 22.3% | −35 | 42.3% | 13,067 |
| 63 | S132 | 42.7% | 94.7% | −28 | 11.3% | 12,874 / 18,915 |
| 63 | G129 | 24.3% | 90.8% | −26 | 14.8% | 14,245 |
| 63 | S143 | 17.6% | 87.7% | −28 | 15.3% | 14,777 |

Every missing sticker had at least one holder in the population before d = −1. So all are "obtainable" in the strict sense, but few players held the gate trio.

**Gate trio, new holders per day** (all not-first PU; % of population)

| Sticker | ≤ −8 | −7 | −6 | −5 | −4 | −3 | −2 | −1 | Wild share on −2 / −1 | Main channel when not a Wild |
|---|---|---|---|---|---|---|---|---|---|---|
| 61 S143 | 0.36% | 0.32% | 0.69% | 0.49% | 0.75% | 1.75% | 3.13% | 3.51% | 99.9% / 99.8% | — |
| 61 S120 | 0.05% | 0.39% | 0.63% | 0.71% | 2.09% | 3.92% | 7.51% | 7.36% | 99.9% / 99.9% | — |
| 61 G142 | 1.57% | 1.34% | 1.69% | 2.56% | 2.80% | 3.26% | 4.02% | 4.82% | 24% / 31% | Paid "specific" pack, not a Wild (69–95%) |
| 63 S132 | 0.19% | 0.47% | 1.30% | 1.32% | 2.02% | 2.64% | 3.32% | 4.58% | 99.8% / 99.8% | — |
| 63 S143 | 0.15% | 0.29% | 0.74% | 1.03% | 2.26% | 4.80% | 6.05% | 5.53% | 100% / 100% | — |
| 63 G129 | 0.80% | 0.74% | 1.10% | 1.92% | 2.87% | 3.39% | 3.93% | 4.16% | 31% / 62% | Paid "specific" pack (36–79%), dup exchange (2–8%) |

## 3. Story of the last week in Dice

- **Nobody finishes early.** Every not-first PU finisher completes in d = −7…−1, and 84–88% complete in the last 3 days.
- **Goldens are not where the late-week action is.**
  - Players already get about 1.3–1.5 new Goldens per active day in the baseline week.
  - One drop for the whole population comes on d = −4 (61) / d = −5 (63).
  - After that, Golden inflow for finishers falls to 0.2–0.4 per active day.
- **The closing run starts on d = −4/−3 and is driven by Wilds.**
  - The finishers' daily Wild-fill share jumps from 0.5% to 33–45%.
  - New Supers per active day rise 3–4×.
  - The pay rate doubles to about 52%.
  - Median markers: first Wild fill d = −3, last Golden d = −3, last Super d = −2, last paying day d = −1.
- **The gate is a fixed trio of 2 Supers + 1 Golden.**
  - In the last two days the gate Supers come almost only from Wilds (99.8%+): about 2/3 from paid `Pricing_*` Wild offers and about 1/3 from event Wilds (mostly Trail Final Reward).
  - The gate Golden comes mainly from a paid "specific" pack. In album 63 it increasingly comes via Wild on d = −1.
- **Purchases come right before these stickers.** 80–90% of finishers' Wild Supers in the last week arrive ≤ 10 min after a purchase. The comparison figures are 11–14% for their new Commons and under 1% for the 24-hour-shifted placebo.
- **N1 look like finishers who ran out of time.**
  - Their Wild-fill and pay curves follow F about one day behind (48–49% paid on d = −1, against 52–53% for F).
  - 63–73% are still missing one Super, usually the top gate Super.
- **N2-3 get stuck before the run starts.**
  - 59% / 74% never get a single Wild fill in the 14-day window, and their pay rate stays at baseline.
  - 59% / 76% end missing exactly the trio.
  - Duplicate exchange and events keep giving them other Supers (dup exchange is 13% of N2-3's new Supers in album 61), but not the gate stickers.
- **Album 63 compared with 61:**
  - More finishes come through paid Wilds (69% vs 58%).
  - Fewer come through event Wilds (17% vs 32%).
  - Duplicate exchange almost disappears (1.6% vs 6.0% of finishers' new Supers).
  - More N2-3 are missing exactly the trio (76% vs 59%).
  - This compares two albums with different setups, so it is not causal.

## 4. Caveats and definition gaps

- **Joker vs Wild.** Dice has no Joker. "Joker/Wild" here means `collected_from_wild` (from `is_wild` on the sticker-received event): the player chose the sticker through a Wild, whatever the source. The Joker flag in Domino and Disney is a different mechanic, and the Domino definition is still disputed.
- **Paid vs free is inferred from the pack key** (`sticker_pack_key LIKE 'Pricing%'`).
  - Known for Wilds (≥ 99.5% arrive right after a purchase).
  - Needs Validation for non-Wild paid offers (79–84% purchase-linked among finishers).
  - Trail Final Reward Wilds are counted as event rewards, but 23–26% follow a purchase within 10 minutes. Whether the Trail has a paid track is still open from Topic 5.
- **"Pack / regular pull" has no clean Dice equivalent.** Every source is a feature, so steady progression (Progress Bar, daily calendar, weekly goals, pets) stands in for it. The channel rules extend the Topic-5 v2 lists with pack-key rules, so shares are not exactly comparable to Topic 5.
- **Purchase linkage is timing only.** No order ID connects a purchase to a sticker. The Commons control and the 24-hour placebo rule out "payers simply collect more of everything after paying", but they do not prove causation.
- **"First new Golden"** is uninformative, because everyone already collects Goldens on d = −14.
- **"Obtainable"** is shown two ways:
  - Strict test: at least one population holder before d = −1. True for 100% of missing stickers.
  - Practical view: only 7.5–17% of the population held each gate-trio sticker by d = −2.
  - Release dates are not in the curated tables, so "locked until late" stays a Hypothesis until the studio confirms the calendar.
- **Data handling.**
  - `fact_user_album_stickers` was deduplicated to each player's first receipt of each sticker.
  - Revenue = `spent_in_album_today`.
  - ARPDAU is computed on `is_active` days.
  - F-early is empty in both albums.

## 5. SQL appendix

All queries ran in `dice-dreams-dbt`. Each was dry-run first with identical SQL, read-only, with partition filters, on curated layers 50/30/20 only.
- Total scanned: 123.4 GB over 6 queries; the largest was 26.65 GB.
- The full runnable SQL is saved at `/tmp/claude-0/-home-claude/5629d190-2f4d-5652-8298-2143c958a9b2/scratchpad/dice_lastweek/all_queries.sql` (each query is also its own `q*.sql` file in that folder).

| Query | Purpose | Scanned |
|---|---|---|
| Q0 | Source inventory for new Goldens / Supers on d = −7…−1 (basis for the channel mapping) | 24.55 GB |
| Q1 | T1 daily profile | 16.96 GB |
| Q2 | T2 first/last days and finishing sticker | 24.55 GB |
| Q3 | T3 channels and T4 purchase linkage (Commons control, 24 h placebo) | 26.65 GB |
| Q5 | T5 last-5 sequences and missing stickers | 16.89 GB |
| Q6 | Gate trio: new holders per day and channel | 13.79 GB |

**Shared prefix (identical in every query)**
```sql
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.a_end, a.album_login_ratio AS lr, IFNULL(a.user_past_album_count, 0) AS past,
    IFNULL(a.spent_in_album_today, 0) AS sp, IFNULL(a.is_active, FALSE) AS act,
    IFNULL(a.unique_common_stickers_lt, 0) + IFNULL(a.unique_golden_stickers_lt, 0) + IFNULL(a.unique_super_stickers_lt, 0) AS u
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(u) AS u_pre, MIN(IF(u >= 144, date_dim, NULL)) AS fin_d
  FROM r GROUP BY 1, 2
  HAVING SUM(sp) > 0 AND MAX(past) > 0 AND ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
grp AS (
  SELECT album_id, user_id, a_end, fin_d, 144 - u_pre AS short,
    CASE WHEN u_pre >= 144 AND fin_d >= DATE_SUB(a_end, INTERVAL 7 DAY) THEN 'F_late'
         WHEN u_pre >= 144 THEN 'F_early'
         WHEN u_pre = 143 THEN 'N1'
         WHEN u_pre >= 141 THEN 'N2_3'
         ELSE 'Other_PU' END AS g
  FROM pop),
st AS (
  SELECT g.album_id, g.user_id, g.g, g.a_end, s.sticker_id, s.sticker_type AS t, s.sticker_collected_ts AS ts,
    DATE_DIFF(s.sticker_collected_date, g.a_end, DAY) AS d, IFNULL(s.collected_from_wild, FALSE) AS w,
    IFNULL(NULLIF(s.sticker_source, ''), '(null)') AS src, s.sticker_pack_key AS pk
  FROM grp g JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = g.album_id AND s.user_id = g.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63)
    AND s.is_sticker_collected AND s.sticker_type IN ('common', 'golden', 'super') AND s.sticker_collected_date < g.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1)
```

**Channel expression (`bucket`), used in Q2, Q3 and Q6**
```sql
CASE
  WHEN w AND pk LIKE 'Pricing%' THEN 'Wild - paid offer'
  WHEN w THEN 'Wild - event reward'
  WHEN src = 'Duplication exchange' THEN 'Dup exchange'
  WHEN pk LIKE 'Pricing%' OR (src = 'Dream Pass' AND pk LIKE '%Premium%') THEN 'Paid offer (non-Wild)'
  WHEN src LIKE 'Trail%' OR pk LIKE '%Trail%' THEN 'Trail (recurring MTX event)'
  WHEN src IN ('Progress Bar V2', 'RewardCalendar', 'WeeklyGoals', 'Pets Feature', 'Pets') THEN 'Steady progression (PB/Daily/Weekly/Pets)'
  WHEN src IN ('(null)', 'Pending Rewards', 'CustomerSupportReward') AND IFNULL(pk, '') NOT LIKE '%Collection%' THEN 'Unknown/other'
  ELSE 'Other events' END
```

**Q0: source inventory (24.55 GB).** Shared prefix, then:
```sql
SELECT album_id, t, src, w, COUNT(*) AS n, COUNTIF(g IN ('F_late','N1','N2_3')) AS n_target, ANY_VALUE(pk) AS ex_pack_key
FROM st WHERE d BETWEEN -7 AND -1 AND t IN ('golden','super')
GROUP BY 1, 2, 3, 4 HAVING COUNT(*) >= 50 ORDER BY 1, 2, 5 DESC
```

**Q1: T1 daily profile (16.96 GB).** Shared prefix, then:
```sql
, sd AS (
  SELECT album_id, user_id, d, COUNTIF(t = 'golden') AS ng, COUNTIF(t = 'super') AS nr, COUNTIF(w) AS nw, COUNTIF(t = 'common') AS nc
  FROM st WHERE d BETWEEN -14 AND -1 GROUP BY 1, 2, 3),
ud AS (
  SELECT r.album_id, r.user_id, DATE_DIFF(r.date_dim, r.a_end, DAY) AS d, r.act, r.sp
  FROM r JOIN grp USING (album_id, user_id) WHERE r.date_dim >= DATE_SUB(r.a_end, INTERVAL 14 DAY)),
x AS (
  SELECT COALESCE(ud.album_id, sd.album_id) AS album_id, COALESCE(ud.user_id, sd.user_id) AS user_id, COALESCE(ud.d, sd.d) AS d,
    IFNULL(ud.act, FALSE) AS act, IFNULL(ud.sp, 0) AS sp, ud.user_id IS NULL AS no_row,
    IFNULL(sd.ng, 0) AS ng, IFNULL(sd.nr, 0) AS nr, IFNULL(sd.nw, 0) AS nw, IFNULL(sd.nc, 0) AS nc
  FROM ud FULL OUTER JOIN sd ON sd.album_id = ud.album_id AND sd.user_id = ud.user_id AND sd.d = ud.d),
gl AS (
  SELECT album_id, user_id, gg FROM grp,
    UNNEST(ARRAY_CONCAT([g], IF(g IN ('N1','N2_3'), ['N_all'], []), IF(g LIKE 'F_%', ['F_all'], []))) AS gg),
gn AS (SELECT album_id, gg, COUNT(*) AS n FROM gl GROUP BY 1, 2),
y AS (
  SELECT gl.album_id, gl.gg, IF(x.d <= -8, 'base(-14..-8)', CAST(x.d AS STRING)) AS dd, IF(x.d <= -8, 7, 1) AS ndays,
    x.act, x.sp, x.ng, x.nr, x.nw, x.nc, x.no_row
  FROM x JOIN gl USING (album_id, user_id))
SELECT y.album_id, y.gg AS grp, y.dd, ANY_VALUE(gn.n) AS n_players,
  ROUND(COUNTIF(act) / (ANY_VALUE(gn.n) * ANY_VALUE(ndays)), 4) AS pct_active,
  ROUND(COUNTIF(ng > 0) / (ANY_VALUE(gn.n) * ANY_VALUE(ndays)), 4) AS pct_new_golden,
  ROUND(COUNTIF(nr > 0) / (ANY_VALUE(gn.n) * ANY_VALUE(ndays)), 4) AS pct_new_super,
  ROUND(COUNTIF(nw > 0) / (ANY_VALUE(gn.n) * ANY_VALUE(ndays)), 4) AS pct_new_wild,
  ROUND(SUM(ng) / NULLIF(COUNTIF(act), 0), 3) AS new_golden_per_active,
  ROUND(SUM(nr) / NULLIF(COUNTIF(act), 0), 3) AS new_super_per_active,
  ROUND(SUM(nw) / NULLIF(COUNTIF(act), 0), 3) AS new_wild_per_active,
  ROUND(COUNTIF(sp > 0) / (ANY_VALUE(gn.n) * ANY_VALUE(ndays)), 4) AS pct_paid,
  ROUND(SUM(sp) / NULLIF(COUNTIF(act), 0), 2) AS pu_arpdau,
  ROUND(SUM(sp) / NULLIF(COUNTIF(sp > 0), 0), 2) AS rev_per_paying_day,
  ROUND(COUNTIF((ng + nr + nc) > 0 AND (no_row OR NOT act)) / NULLIF(COUNTIF((ng + nr + nc) > 0), 0), 4) AS qa_sticker_days_not_active
FROM y JOIN gn ON gn.album_id = y.album_id AND gn.gg = y.gg
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
```

**Q2: T2 timing and finishing sticker (24.55 GB).** Shared prefix, then:
```sql
, stb AS (SELECT album_id, user_id, g, d, t, w, ts, <bucket expression> AS bucket FROM st),
fe AS (
  SELECT album_id, user_id, ANY_VALUE(g) AS g,
    MIN(IF(t = 'golden' AND d >= -14, d, NULL)) AS f_golden, MIN(IF(t = 'super' AND d >= -14, d, NULL)) AS f_super,
    MIN(IF(w AND d >= -14, d, NULL)) AS f_wild,
    MAX(IF(t = 'golden', d, NULL)) AS l_golden, MAX(IF(t = 'super', d, NULL)) AS l_super, MAX(IF(w, d, NULL)) AS l_wild,
    ARRAY_AGG(STRUCT(d, t, w, bucket) ORDER BY ts DESC LIMIT 1)[OFFSET(0)] AS fin
  FROM stb GROUP BY 1, 2),
fp AS (
  SELECT album_id, user_id, MIN(IF(sp > 0, DATE_DIFF(date_dim, a_end, DAY), NULL)) AS f_pay, MAX(IF(sp > 0, DATE_DIFF(date_dim, a_end, DAY), NULL)) AS l_pay
  FROM r WHERE date_dim >= DATE_SUB(a_end, INTERVAL 14 DAY) GROUP BY 1, 2),
u AS (
  SELECT g.album_id, g.user_id, gg, fe.f_golden, fe.f_super, fe.f_wild, fp.f_pay, fe.l_golden, fe.l_super, fe.l_wild, fp.l_pay, fe.fin
  FROM grp g LEFT JOIN fe USING (album_id, user_id) LEFT JOIN fp USING (album_id, user_id),
    UNNEST(ARRAY_CONCAT([g.g], IF(g.g IN ('N1','N2_3'), ['N_all'], []))) AS gg),
m AS (
  SELECT album_id, gg, metric, v FROM u,
    UNNEST([STRUCT('first_new_golden' AS metric, f_golden AS v), ('first_new_super', f_super), ('first_wild_fill', f_wild), ('first_purchase_day', f_pay),
            ('last_new_golden', l_golden), ('last_new_super', l_super), ('last_wild_fill', l_wild), ('last_purchase_day', l_pay)]))
SELECT album_id, gg AS grp, metric, CAST(NULL AS STRING) AS cat, COUNT(*) AS n,
  ROUND(COUNTIF(v IS NULL) / COUNT(*), 4) AS sh_none, ROUND(COUNTIF(v <= -8) / COUNT(*), 4) AS sh_le_m8,
  ROUND(COUNTIF(v = -7) / COUNT(*), 4) AS sh_m7, ROUND(COUNTIF(v = -6) / COUNT(*), 4) AS sh_m6, ROUND(COUNTIF(v = -5) / COUNT(*), 4) AS sh_m5,
  ROUND(COUNTIF(v = -4) / COUNT(*), 4) AS sh_m4, ROUND(COUNTIF(v = -3) / COUNT(*), 4) AS sh_m3, ROUND(COUNTIF(v = -2) / COUNT(*), 4) AS sh_m2,
  ROUND(COUNTIF(v = -1) / COUNT(*), 4) AS sh_m1, APPROX_QUANTILES(v, 2)[OFFSET(1)] AS p50_d
FROM m WHERE gg IN ('F_late', 'N1', 'N2_3', 'N_all') GROUP BY 1, 2, 3
UNION ALL
SELECT album_id, gg, CONCAT('finishing_sticker_', k), c AS cat2, COUNT(*), ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, gg, k), 4),
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM u, UNNEST([STRUCT('type' AS k, fin.t AS c), ('channel', fin.bucket), ('type_x_wild', CONCAT(fin.t, IF(fin.w, '+wild', ''))), ('day', CAST(fin.d AS STRING))])
WHERE gg IN ('F_late', 'F_early') GROUP BY album_id, gg, k, c
ORDER BY 1, 2, 3, 4
```
The first dry-run failed (the two halves of the UNION ALL had different column counts). The version above, with 9 NULLs, is the one that ran.

**Q3: T3 channels and T4 purchase linkage (26.65 GB).** Shared prefix, then:
```sql
, w7 AS (SELECT album_id, user_id, sticker_id, g, d, t, w, ts, <bucket expression> AS bucket FROM st WHERE d BETWEEN -7 AND -1),
payday AS (SELECT album_id, user_id, DATE_DIFF(date_dim, a_end, DAY) AS d FROM r WHERE sp > 0 AND date_dim >= DATE_SUB(a_end, INTERVAL 8 DAY)),
pur AS (
  SELECT v.user_id, v.timestamp AS pts
  FROM `dice-dreams-dbt.20_core.purchase_completed_vw` v
  WHERE v.pdate BETWEEN DATE '2026-07-17' AND DATE '2026-09-06' AND v.purchase_amount > 0
  QUALIFY ROW_NUMBER() OVER (PARTITION BY v.user_id, v.timestamp, v.external_order_id ORDER BY v.timestamp) = 1),
k AS (
  SELECT w7.album_id, w7.user_id, w7.sticker_id, w7.g, w7.t, w7.w, w7.bucket, w7.ts, pd.d IS NOT NULL AS paid_day,
    LOGICAL_OR(p.pts BETWEEN TIMESTAMP_SUB(w7.ts, INTERVAL 10 MINUTE) AND w7.ts) AS p10,
    LOGICAL_OR(p.pts BETWEEN TIMESTAMP_SUB(w7.ts, INTERVAL 1450 MINUTE) AND TIMESTAMP_SUB(w7.ts, INTERVAL 1440 MINUTE)) AS p10_shift24h
  FROM w7 LEFT JOIN payday pd ON pd.album_id = w7.album_id AND pd.user_id = w7.user_id AND pd.d = w7.d
  LEFT JOIN pur p ON p.user_id = w7.user_id AND p.pts BETWEEN TIMESTAMP_SUB(w7.ts, INTERVAL 1450 MINUTE) AND w7.ts
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9)
SELECT album_id, g AS grp, t, bucket, COUNT(*) AS n_new, COUNT(DISTINCT user_id) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, g, t), 4) AS share_of_type,
  COUNTIF(paid_day) AS n_paid_day, COUNTIF(IFNULL(p10, FALSE)) AS n_p10, COUNTIF(IFNULL(p10_shift24h, FALSE)) AS n_p10_shift24h
FROM k WHERE g IN ('F_late', 'N1', 'N2_3', 'Other_PU')
GROUP BY 1, 2, 3, 4 ORDER BY 1, 2, 3, 5 DESC
```

**Q5: T5 sequences and missing stickers (16.89 GB).** Shared prefix, then:
```sql
, seq AS (
  SELECT album_id, user_id, ARRAY_AGG(STRUCT(UPPER(SUBSTR(t, 1, 1)) AS ty, w) ORDER BY ts DESC, sticker_id DESC LIMIT 5) AS l5
  FROM st WHERE g = 'F_late' GROUP BY 1, 2),
pat AS (
  SELECT album_id,
    (SELECT STRING_AGG(CONCAT(x.ty, IF(x.w, 'w', '')), '>' ORDER BY o DESC) FROM UNNEST(l5) x WITH OFFSET o) AS p_wild,
    (SELECT STRING_AGG(x.ty, '>' ORDER BY o DESC) FROM UNNEST(l5) x WITH OFFSET o) AS p_type
  FROM seq),
p1 AS (SELECT 'T5a_pattern_type_wild' AS section, album_id, 'F_late' AS grp, p_wild AS k, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS share
  FROM pat GROUP BY album_id, p_wild QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) <= 8),
p2 AS (SELECT 'T5b_pattern_type' AS section, album_id, 'F_late' AS grp, p_type AS k, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS share
  FROM pat GROUP BY album_id, p_type QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) <= 8),
stk AS (
  SELECT album_id, sticker_id, ANY_VALUE(t) AS t, MIN(d) AS first_d_pop,
    COUNTIF(d <= -2) AS holders_by_m2, COUNTIF(g = 'F_late' AND d <= -2) AS f_holders_by_m2
  FROM st GROUP BY 1, 2),
npop AS (SELECT album_id, COUNT(*) AS n_pop FROM grp GROUP BY 1),
nu AS (SELECT album_id, user_id, g FROM grp WHERE g IN ('N1', 'N2_3')),
miss AS (
  SELECT nu.album_id, nu.user_id, nu.g, k.sticker_id, k.t, k.first_d_pop, k.holders_by_m2, k.f_holders_by_m2
  FROM nu JOIN stk k ON k.album_id = nu.album_id
  LEFT JOIN st s ON s.album_id = nu.album_id AND s.user_id = nu.user_id AND s.sticker_id = k.sticker_id
  WHERE s.user_id IS NULL),
mu AS (SELECT album_id, user_id, g, COUNTIF(t = 'super') AS ms, COUNTIF(t = 'golden') AS mg, COUNTIF(t = 'common') AS mc, COUNT(*) AS m_all
  FROM miss GROUP BY 1, 2, 3),
p3 AS (SELECT 'T5c_missing_mix' AS section, album_id, g AS grp, CONCAT(REPEAT('S', ms), REPEAT('G', mg), REPEAT('C', mc)) AS k, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, g), 4) AS share
  FROM mu GROUP BY album_id, g, k),
p4 AS (SELECT 'T5d_missing_sticker' AS section, m.album_id, m.g AS grp,
    CONCAT(CAST(m.sticker_id AS STRING), ':', m.t, ' firstd=', CAST(ANY_VALUE(m.first_d_pop) AS STRING),
      ' pop_hold_by_m2=', CAST(ROUND(ANY_VALUE(m.holders_by_m2) / ANY_VALUE(np.n_pop), 3) AS STRING),
      ' Flate_hold_by_m2=', CAST(ANY_VALUE(m.f_holders_by_m2) AS STRING)) AS k,
    COUNT(*) AS n, ROUND(COUNT(*) / ANY_VALUE(gc.n_g), 4) AS share
  FROM miss m JOIN npop np USING (album_id)
  JOIN (SELECT album_id, g, COUNT(*) AS n_g FROM nu GROUP BY 1, 2) gc ON gc.album_id = m.album_id AND gc.g = m.g
  GROUP BY m.album_id, m.g, m.sticker_id, m.t
  QUALIFY ROW_NUMBER() OVER (PARTITION BY m.album_id, m.g ORDER BY COUNT(*) DESC) <= 8),
p5 AS (SELECT 'T5e_missing_obtainable' AS section, album_id, g AS grp,
    CONCAT(t, IF(holders_by_m2 > 0, ' obtainable_by_m2', ' NOT_obtainable_by_m2')) AS k, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, g), 4) AS share
  FROM miss GROUP BY album_id, g, k)
SELECT section, album_id, grp, k, n, share FROM p1 UNION ALL
SELECT section, album_id, grp, k, n, share FROM p2 UNION ALL
SELECT section, album_id, grp, k, n, share FROM p3 WHERE share >= 0.01 UNION ALL
SELECT section, album_id, grp, k, n, share FROM p4 UNION ALL
SELECT section, album_id, grp, k, n, share FROM p5
ORDER BY 1, 2, 3, 5 DESC
```

**Q6: gate trio by day and channel (13.79 GB).** Shared prefix, then:
```sql
, tr AS (
  SELECT album_id, sticker_id, t, IF(d <= -8, -8, d) AS dd, w, <bucket expression> AS bucket
  FROM st WHERE (album_id = 61 AND sticker_id IN (143, 142, 120)) OR (album_id = 63 AND sticker_id IN (132, 129, 143))),
npop AS (SELECT album_id, COUNT(*) AS n_pop FROM grp GROUP BY 1)
SELECT tr.album_id, sticker_id, ANY_VALUE(t) AS t, dd, COUNT(*) AS new_holders,
  ROUND(COUNT(*) / ANY_VALUE(np.n_pop), 4) AS share_of_pop, ROUND(COUNTIF(w) / COUNT(*), 3) AS wild_share,
  ROUND(COUNTIF(bucket = 'Wild - paid offer') / COUNT(*), 3) AS wild_paid_share,
  ROUND(COUNTIF(bucket = 'Wild - event reward') / COUNT(*), 3) AS wild_event_share,
  ROUND(COUNTIF(bucket = 'Dup exchange') / COUNT(*), 3) AS dup_share,
  ROUND(COUNTIF(bucket = 'Paid offer (non-Wild)') / COUNT(*), 3) AS paid_nonwild_share
FROM tr JOIN npop np USING (album_id)
GROUP BY 1, 2, 4 ORDER BY 1, 2, 4
```

**Worth saving to memory (Dice):**
- **Gate trio:** album 61 = S143, S120, G142; album 63 = S132, S143, G129.
- **Wild channel:** gate Supers on d = −2/−1 arrive about 100% via Wild. A `Pricing_*` pack key marks paid offers (≥ 99.5% purchase-linked for Wilds).
- **No early finishers:** zero not-first PU finish before close−7.
- **Commons control:** finishers' new Supers in the last week are 55–59% purchase-linked within 10 minutes, against 11–14% for their new Commons. Use this as the standard placebo.

The full deliverable is also saved as `/tmp/claude-0/-home-claude/5629d190-2f4d-5652-8298-2143c958a9b2/scratchpad/dice_lastweek/final.md`, and the raw results are next to it in `t1.json` and `t34.json`.
---

# Domino Dreams, albums 17 and 19: how players finish the album in the last week

**Scope.** Project `domino-dreams-dbt`. Population: not-first-album payers (`user_album_count > 1`, album spend > 0 before close), not special users, not suspected cheaters, `login_ratio` ≥ 0.5 on the last row before close. The close day is excluded.

**Groups:**
- **F (finished):** 144 unique set stickers before close. Album 17: 7,783. Album 19: 5,320.
  - **F-late** finished in d=-7…-1: 7,652 / 5,312.
  - **F-early** finished before that: only 131 / 8, so they are left out of most tables.
- **N (near-finishers):** 1–3 stickers short at d=-1: 20,309 / 15,209.
- **N1:** exactly 1 short: 3,075 / 2,720.

**Window.** d=-14…-1, where d=-1 is the last full day.
- Album 17 closes 2026-05-11, so the window is 04-27…05-10.
- Album 19 closes 2026-08-24, so the window is 08-10…08-23.
- "New" means the first-ever collection of that sticker (`sticker_collected_min_date/ts`).
- "Paid day" means `album_spent_today` > 0, which is gross revenue.
- ARPDAU is revenue divided by active days (`active_flag`).

## 1. Five headline findings

1. **Album 19 ends almost entirely through Jokers.** 95.5% of F-late finishers' last sticker was Joker-filled: Royal 50.4%, Golden 45.1%. In album 17 it was 44.5%: Golden 36.3%, Royal 8.2%. The other album-17 finishes came through a paid Golden offer (18.9%) or an event (13.4%). — **Known**, F-late, n=5,312 / 7,652. This matches yesterday's 45% / 96%.
2. **Album 19 finishing happens in the last 3 days. Album 17 finishing is spread over the week.**
   - Album 19 finish day: 56.8% on d=-1, 24.4% on d=-2, 12.2% on d=-3. Only 6.7% finished on d=-7…-4.
   - Album 17 finish day: 39.3% on d=-1. Each of d=-7…-2 holds 8.5–14%.
   - Album 19 F-late daily share with a new Royal: 16.3% in the baseline week, then 10.5%, 22.7%, 34.0% and 50.3% on d=-4…-1. Joker-fill share: 4.8% baseline, 55.9% on d=-1.
   - — **Known**, F-late.
3. **Payment rises toward close.**
   - F-late share paying per day: album 19 33.9% baseline → 64.8% on d=-1; album 17 37.4% → 57.4%.
   - PU ARPDAU: album 19 $13.05 → $27.36; album 17 $13.37 → $21.68.
   - The finishing sticker arrived on a paying day 86.9% (album 19) / 91.1% (album 17) of the time. It arrived within 10 minutes after a purchase 46.4% / 55.9% of the time.
   - — **Known** (timing). Fact only, not causal.
4. **New Royals and Goldens follow a purchase more often than new Commons do (the control).** Share of new stickers in d=-7…-1 that arrived within 10 minutes after a purchase, F-late:
   - Album 17: Royal 37.0%, Golden 44.9%, Commons 24.7%.
   - Album 19: Royal 40.5%, Golden 37.3%, Commons 18.2%.
   - That is about 1.5–2.2 times the Commons rate. — **Needs Validation** for "the purchase delivered the rare". The timing itself is Known. n = 10.7K–44.8K rares and 0.8K–2.3K Commons.
5. **Near-finishers are stuck on the phase-6 gate stickers, which few payers hold.**
   - Album 17 N: 97.3% are missing at least one Golden. Golden 106 is missing for 81.6% of N, and only 6.6% of the population held it by d=-2. Golden 104: 73.4% missing, 8.8% held.
   - Album 19 N: 88.9% are missing at least one Royal. Royal 107: 72.4% missing, 5.6% held. Royal 108: 65.9% missing, 6.9% held. Golden 101: 60.2% missing, 6.7% held.
   - Every missing sticker was held by someone in the population before d=-1, so none was strictly unavailable. The gate stickers were scarce, not absent.
   - — **Known**, N, n=20,309 / 15,209. "Released via Joker only" is a **Hypothesis**.

## 2. Tables

### T1 Daily acquisition profile

How to read the columns:
- "Base" is the average day of d=-14…-8.
- Act, G%, R%, J% and Paid% are the share of the group on that day: active, with ≥1 new Golden, with ≥1 new Royal, with ≥1 new Joker-filled sticker (any type), and with any payment.
- G/a, R/a and J/a are new stickers per active player-day.
- ARPDAU is per active PU day. $/pd is revenue per paying day.

**Album 17, F-late (n=7,652)**

| d | Act | G% | R% | J% | G/a | R/a | J/a | Paid% | ARPDAU | $/pd |
|---|---|---|---|---|---|---|---|---|---|---|
| Base | 95.0 | 35.9 | 14.8 | 9.5 | 0.79 | 0.20 | 0.11 | 37.4 | 13.37 | 34.0 |
| -7 | 96.4 | 54.6 | 18.1 | 23.4 | 1.82 | 0.28 | 0.32 | 45.3 | 16.23 | 34.5 |
| -6 | 96.5 | 40.8 | 15.7 | 17.4 | 1.05 | 0.22 | 0.21 | 46.0 | 16.86 | 35.4 |
| -5 | 96.7 | 28.2 | 11.8 | 19.2 | 0.67 | 0.16 | 0.27 | 42.4 | 16.12 | 36.8 |
| -4 | 96.4 | 20.5 | 12.3 | 14.9 | 0.48 | 0.17 | 0.22 | 44.6 | 18.54 | 40.1 |
| -3 | 95.9 | 20.5 | 10.9 | 11.3 | 0.45 | 0.15 | 0.16 | 44.8 | 18.73 | 40.1 |
| -2 | 95.3 | 25.5 | 11.3 | 12.3 | 0.59 | 0.16 | 0.16 | 51.3 | 21.00 | 39.0 |
| -1 | 96.2 | 37.6 | 19.7 | 19.5 | 1.02 | 0.32 | 0.23 | 57.4 | 21.68 | 36.3 |

**Album 17, N (n=20,309) and N1 (n=3,075)**

| d | N: G% | R% | J% | Paid% | ARPDAU | N1: G% | R% | J% | Paid% | ARPDAU |
|---|---|---|---|---|---|---|---|---|---|---|
| Base | 33.0 | 14.6 | 4.8 | 28.7 | 5.50 | 33.7 | 14.7 | 5.9 | 32.0 | 7.71 |
| -7 | 46.1 | 19.0 | 13.6 | 33.4 | 5.41 | 48.7 | 17.6 | 16.4 | 38.0 | 8.05 |
| -6 | 37.4 | 18.2 | 11.0 | 31.7 | 5.21 | 39.2 | 16.2 | 13.4 | 39.3 | 8.41 |
| -5 | 22.5 | 11.3 | 9.7 | 27.7 | 4.65 | 23.7 | 10.5 | 13.0 | 33.8 | 7.46 |
| -4 | 14.9 | 9.9 | 6.7 | 29.4 | 5.34 | 19.1 | 11.9 | 10.4 | 38.7 | 9.62 |
| -3 | 14.7 | 12.0 | 4.6 | 32.1 | 5.96 | 21.3 | 15.3 | 9.0 | 40.5 | 10.38 |
| -2 | 19.1 | 12.8 | 5.8 | 35.9 | 6.46 | 28.3 | 15.2 | 11.6 | 47.1 | 11.42 |
| -1 | 17.9 | 17.3 | 5.9 | 34.1 | 6.00 | 35.9 | 24.5 | 16.1 | 49.1 | 11.54 |

N active share is 93–96% every day. Per active day, N has 0.36–1.6 new Goldens, 0.15–0.31 new Royals and 0.05–0.15 Joker fills.

**Album 19, F-late (n=5,312)**

| d | Act | G% | R% | J% | G/a | R/a | J/a | Paid% | ARPDAU | $/pd |
|---|---|---|---|---|---|---|---|---|---|---|
| Base | 94.9 | 33.8 | 16.3 | 4.8 | 0.79 | 0.24 | 0.06 | 33.9 | 13.05 | 36.5 |
| -7 | 95.7 | 33.6 | 16.4 | 15.1 | 0.72 | 0.23 | 0.18 | 30.9 | 11.50 | 35.6 |
| -6 | 95.9 | 19.7 | 13.9 | 10.0 | 0.40 | 0.18 | 0.12 | 30.0 | 12.80 | 40.9 |
| -5 | 96.4 | 15.8 | 9.5 | 9.7 | 0.30 | 0.12 | 0.14 | 31.2 | 14.12 | 43.7 |
| -4 | 96.7 | 17.8 | 10.6 | 12.0 | 0.32 | 0.15 | 0.21 | 35.3 | 17.29 | 47.4 |
| -3 | 97.0 | 37.7 | 22.7 | 27.9 | 0.77 | 0.37 | 0.59 | 47.7 | 21.92 | 44.6 |
| -2 | 97.2 | 38.0 | 34.0 | 42.9 | 0.80 | 0.58 | 0.92 | 54.4 | 24.71 | 44.1 |
| -1 | 98.4 | 45.4 | 50.3 | 55.9 | 0.94 | 0.96 | 1.56 | 64.8 | 27.36 | 41.5 |

**Album 19, N (n=15,209) and N1 (n=2,720)**

| d | N: G% | R% | J% | Paid% | ARPDAU | N1: G% | R% | J% | Paid% | ARPDAU |
|---|---|---|---|---|---|---|---|---|---|---|
| Base | 33.2 | 17.1 | 2.0 | 29.6 | 6.17 | 32.8 | 16.4 | 2.1 | 29.7 | 7.31 |
| -7 | 35.2 | 17.8 | 10.5 | 27.1 | 5.55 | 36.1 | 16.8 | 10.7 | 26.6 | 6.53 |
| -6 | 20.9 | 14.7 | 7.0 | 25.8 | 5.20 | 20.6 | 14.6 | 7.6 | 25.9 | 6.23 |
| -5 | 16.3 | 8.2 | 5.7 | 26.8 | 5.64 | 16.5 | 7.6 | 5.7 | 28.3 | 7.64 |
| -4 | 16.0 | 5.9 | 6.0 | 29.3 | 6.12 | 17.4 | 7.1 | 7.2 | 30.0 | 8.52 |
| -3 | 37.0 | 11.8 | 14.5 | 37.7 | 7.41 | 38.1 | 19.4 | 21.3 | 41.9 | 10.88 |
| -2 | 37.0 | 18.8 | 28.5 | 39.8 | 7.54 | 42.4 | 37.5 | 44.6 | 49.2 | 13.35 |
| -1 | 34.8 | 24.0 | 38.7 | 41.4 | 7.37 | 38.1 | 49.1 | 52.2 | 55.1 | 13.73 |

**F-early** (n=131 / 8): no new stickers after finishing. Their ARPDAU stays high, $44–68 (album 17), and they pay on 45–63% of days. The sample is too small to use.

### T2 "When do they start?"

The table shows the first or last day in d=-14…-1 with each event, as a share of players. "Base" means it happened in d=-14…-8.

| Album | Group | Measure | None | Base | -7 | -6 | -5 | -4 | -3 | -2 | -1 | Median d |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 17 | F-late | first new G | 0 | 95.7 | 1.5 | 1.0 | 0.8 | 0.3 | 0.2 | 0.3 | 0.2 | -13 |
| 17 | F-late | first new R | 1.7 | 73.7 | 6.3 | 4.4 | 3.0 | 2.6 | 2.3 | 2.5 | 3.5 | -11 |
| 17 | F-late | first Joker fill | 5.4 | 52.3 | 11.6 | 6.3 | 5.4 | 3.9 | 3.1 | 3.9 | 8.0 | -8 |
| 17 | F-late | first payment | 1.3 | 80.8 | 4.5 | 2.5 | 1.9 | 2.4 | 1.7 | 2.1 | 2.9 | -12 |
| 17 | F-late | **last** new G | 0 | 0.3 | 10.0 | 10.5 | 9.0 | 8.5 | 10.0 | 14.1 | 37.6 | -2 |
| 17 | F-late | **last** new R | 1.7 | 23.9 | 10.2 | 8.8 | 7.4 | 9.9 | 9.3 | 9.1 | 19.7 | -5 |
| 17 | N | first R / Joker / payment | 2.1 / 26.7 / 6.9 | 72.8 / 30.7 / 74.6 | | | | | | | | -11 / -7 / -12 |
| 17 | N1 | first Joker | 12.4 | 36.7 | 12.0 | 8.5 | 6.5 | 4.7 | 4.5 | 6.3 | 8.4 | -7 |
| 19 | F-late | first new G | 0 | 94.2 | 2.9 | 1.1 | 0.5 | 0.5 | 0.4 | 0.2 | 0.2 | -13 |
| 19 | F-late | first new R | 0 | 81.6 | 4.8 | 3.7 | 1.5 | 1.3 | 2.5 | 2.3 | 2.3 | -11 |
| 19 | F-late | first Joker fill | 0 | 28.3 | 11.0 | 7.6 | 4.9 | 4.1 | 12.1 | 15.5 | 16.5 | -5 |
| 19 | F-late | first payment | 3.6 | 73.9 | 2.6 | 2.1 | 1.8 | 1.9 | 3.6 | 4.3 | 6.2 | -12 |
| 19 | F-late | **last** new G | 0 | 1.8 | 2.9 | 1.6 | 2.8 | 6.7 | 14.6 | 24.3 | 45.4 | -2 |
| 19 | F-late | **last** new R | 0 | 1.4 | 1.6 | 0.8 | 2.7 | 5.3 | 13.5 | 24.4 | 50.3 | -1 |
| 19 | N | first Joker | 6.8 | 13.5 | 10.2 | 6.8 | 5.0 | 4.4 | 11.0 | 19.3 | 23.0 | -3 |
| 19 | N1 | first Joker | 0 | 14.6 | 10.1 | 6.9 | 4.8 | 4.2 | 14.5 | 22.2 | 22.6 | -3 |

For the album-17 N row, the first-R, first-Joker and first-payment results are given as triples in each column. Their daily split for d=-7…-1 is in the query output.

Reading T2:
- "First new Golden, Royal or payment" is almost always in the baseline week (median d=-13 to -11). Payers keep collecting and paying throughout, so there is no single "start" day for those.
- The informative measures are the **first Joker fill** and the **last rare**:
  - Album 19 Jokers start late (median d=-5 for F-late, d=-3 for N). The last Royal comes on d=-1 (median).
  - Album 17 has a d=-7 wave and a d=-1 wave.

**Finishing sticker of F-late finishers**

| Album | Type and channel | Share | On a paying day | ≤10 min after a purchase | Median d |
|---|---|---|---|---|---|
| 17 | Golden, Joker | 36.3% | 92.1% | 62.1% | -3 |
| 17 | Golden, paid offer | 18.9% | 94.5% | 75.4% | -2 |
| 17 | Golden, event/MTX | 13.4% | 88.4% | 42.4% | -1 |
| 17 | Golden, unknown | 11.4% | 82.9% | 22.7% | -1 |
| 17 | Royal, Joker | 8.2% | 95.7% | 73.1% | -5 |
| 17 | Royal, event / Golden, Market / Royal, dup / other | 3.8 / 3.5 / 1.9 / 2.6% | — | — | — |
| 17 | **All** (n=7,652) | 100% | 91.1% | 55.9% | -2 |
| 19 | Royal, Joker | 50.4% | 89.3% | 50.4% | -1 |
| 19 | Golden, Joker | 45.1% | 83.9% | 40.9% | -1 |
| 19 | Golden, event / Royal, event / Common / other | 2.8 / 0.8 / 0.7 / 0.3% | — | — | — |
| 19 | **All** (n=5,312) | 100% | 86.9% | 46.4% | -1 |

Finish-day distribution for F-late:

| Album | -7 | -6 | -5 | -4 | -3 | -2 | -1 |
|---|---|---|---|---|---|---|---|
| 17 | 8.5% | 9.7% | 8.9% | 9.0% | 10.5% | 14.2% | 39.3% |
| 19 | 0.1% | 0.2% | 1.8% | 4.6% | 12.2% | 24.4% | 56.8% |

### T3 Channel of new stickers in d=-7…-1

Each sticker goes to one bucket, in this priority order:

| Bucket | Rule (`new_sticker_source` values) |
|---|---|
| **Joker** | `collected_by_joker_flag` = TRUE (checked first) |
| **Dup exchange** | `duplicates` |
| **Market** | `Market` |
| **Paid offer** | `joker`, `progress_offer`, `Missions`, `BuyThemAll`, `SeasonPass`, `OfferLuckyTwister`, `Box`, `mtx`, `1po`, and `1+%` (from the topic5 mapping) |
| **Progression/daily** | `days_milestone`, `area completed`, `pet tier` |
| **Unknown** | `(null)`, `Empty`, `Info`, `Event` |
| **Event/MTX reward** | everything else, e.g. Trail, Momentum, Puzzle, Challenge, Temple, Blast, AdventureWheel, Tournament/Rush, Pinata, RoadToGlory, StepByStamp |

There is no separate "pack pull" label in this column (see caveats).

| Album | Group | Type | n new | Joker | Dup | Market | Paid offer | Prog/daily | Event/MTX | Unknown |
|---|---|---|---|---|---|---|---|---|---|---|
| 17 | F-late | Golden | 44,773 | 19.1 | 0.2 | 13.5 | 16.7 | 0.8 | 42.0 | 7.7 |
| 17 | F-late | Royal | 10,679 | 27.5 | 20.1 | 6.1 | 0.3 | 0.2 | 32.6 | 13.3 |
| 17 | N | Golden | 97,225 | 7.9 | 0.3 | 15.1 | 10.8 | 1.3 | 58.6 | 6.0 |
| 17 | N | Royal | 29,496 | 16.7 | 24.2 | 9.0 | 0.1 | 0.3 | 35.9 | 13.9 |
| 17 | N1 | Golden / Royal | 17,013 / 4,872 | 13.3 / 17.9 | 0.3 / 21.0 | 13.4 / 6.9 | 14.3 / 0.2 | 0.9 / 0.2 | 49.6 / 37.6 | 8.2 / 16.1 |
| 19 | F-late | Golden | 21,886 | 39.0 | 0.1 | 0 | 2.7 | 6.2 | 51.6 | 0.5 |
| 19 | F-late | Royal | 13,414 | 79.4 | 6.5 | 0 | 0 | 0.1 | 14.0 | 0 |
| 19 | N | Golden | 57,081 | 26.3 | 0.1 | 0 | 3.0 | 8.4 | 61.6 | 0.7 |
| 19 | N | Royal | 22,995 | 50.3 | 14.5 | 0 | 0 | 0.3 | 34.9 | 0 |
| 19 | N1 | Golden / Royal | 11,397 / 6,365 | 31.0 / 68.0 | 0.1 / 9.9 | 0 / 0 | 3.0 / 0 | 7.4 / 0.2 | 58.0 / 22.0 | 0.4 / 0 |

**Where the Joker itself came from**: the `new_sticker_source` of Joker-filled new Goldens and Royals, F-late plus N, d=-7…-1:
- **Album 17:** Market 24.6%, Empty 23.7%, BuyThemAll 21.8%, Puzzle 9.1%, 1po 7.9%, joker 4.9%, 1+12/1+15 3.9%, Info 3.2%. About 39% are paid-offer labels.
- **Album 19:** Trail 22.0%, joker 20.7%, Missions 13.9%, Temple 9.1%, AdventureWheel 7.8%, mtx 7.0%, Blast 5.2%, 1+9 4.6%. About 46% are paid-offer labels and about 44% are event rewards.

Album 19 has no Market at all in this window.

### T4 Purchase linkage, d=-7…-1

Purchase timestamps come from the curated table `prod_20_core.core_purchase`. Rows are deduplicated by `external_order_id` and require `total_usd_amount` > 0.

| Album | Group | Type | On a paying day | ≤10 min after a purchase | ≤60 min after a purchase |
|---|---|---|---|---|---|
| 17 | F-late | Golden | 81.1 | **44.9** | 63.1 |
| 17 | F-late | Royal | 83.3 | **37.0** | 62.6 |
| 17 | F-late | Common (control) | 59.9 | 24.7 | 38.7 |
| 17 | N | Golden / Royal / Common | 64.0 / 66.2 / 50.9 | 31.5 / 25.7 / 20.8 | 47.0 / 46.3 / 31.8 |
| 17 | N1 | Golden / Royal / Common | 75.0 / 78.8 / 58.5 | 38.0 / 31.8 / 24.1 | 56.2 / 56.0 / 37.7 |
| 19 | F-late | Golden | 69.9 | **37.3** | 53.8 |
| 19 | F-late | Royal | 80.4 | **40.5** | 64.0 |
| 19 | F-late | Common (control) | 53.0 | 18.2 | 29.8 |
| 19 | N | Golden / Royal / Common | 59.4 / 64.7 / 48.2 | 30.5 / 26.6 / 19.1 | 44.1 / 47.4 / 29.9 |
| 19 | N1 | Golden / Royal / Common | 62.7 / 70.3 / 50.5 | 32.1 / 28.3 / 20.3 | 46.7 / 51.7 / 32.0 |

The Common control is small. In d=-7…-1 the counts are 0.5K–6.6K Commons per group, because most payers already hold all their Commons.

### T5 Sequences and what is missing

**Top patterns of F-late finishers' last 5 new stickers**, in chronological order with the finishing sticker last. G = Golden, R = Royal, C = Common, and "j" marks a Joker fill.

| Album 17 (n=7,652) | Share | Album 19 (n=5,312) | Share |
|---|---|---|---|
| G>G>G>Gj>G | 3.3% | G>Gj>Rj>Rj>Gj | 9.9% |
| G>G>G>G>Gj | 3.2% | G>Gj>Gj>Rj>Rj | 9.6% |
| G>G>G>Gj>Gj | 2.8% | G>G>Gj>Rj>Rj | 7.2% |
| G>G>G>G>G | 2.8% | G>G>Rj>Rj>Gj | 6.9% |
| G>G>Gj>G>G | 2.1% | Rj>G>Gj>Rj>Gj | 3.0% |
| G>G>R>Gj>G | 1.8% | Gj>G>Gj>Rj>Rj | 2.9% |

Album 17 is fragmented: the top 6 patterns cover 16%, and they are Golden-led with mixed Joker use. Album 19 is concentrated: the top 6 cover 40%, and most end with 3–4 Joker picks, 2 Royals plus 1–2 Goldens.

**Near-finishers: what is missing at d=-1, by type**

| Album | Group | Golden slots | Royal slots | Common slots | Share missing ≥1 Golden | Share missing ≥1 Royal | Obtainable* |
|---|---|---|---|---|---|---|---|
| 17 | N (n=20,309) | 82.2% | 17.5% | 0.3% | 97.3% | 37.8% | 100% |
| 17 | N1 (n=3,075) | 86.6% | 12.3% | 1.1% | 86.6% | 12.3% | 100% |
| 19 | N (n=15,209) | 37.1% | 62.3% | 0.6% | 72.6% | 88.9% | 100% |
| 19 | N1 (n=2,720) | 44.8% | 53.7% | 1.5% | 44.8% | 53.7% | 100% |

\*Obtainable means at least 1% of the population held that sticker by d=-2. Under that rule every missing slot counts as obtainable, but the gate stickers sit at only 6–9%.

**Most-missing stickers (N)**

| Album | Sticker | Phase | % of N missing it | Population holding it by d=-2 | First day any payer had it |
|---|---|---|---|---|---|
| 17 | 106 Golden | 6 | 81.6% | 6.6% | day 3 |
| 17 | 104 Golden | 6 | 73.4% | 8.8% | day 1 |
| 17 | 108 Royal | 6 | 35.3% | 16.9% | day 8 |
| 17 | 130 Golden | 6 | 31.3% | 19.1% | day 2 |
| 17 | 107 Golden | 6 | 6.6% | 30.0% | day 1 |
| 19 | 107 Royal | 6 | 72.4% | 5.6% | day 5 |
| 19 | 108 Royal | 6 | 65.9% | 6.9% | day 5 |
| 19 | 101 Golden | 6 | 60.2% | 6.7% | day 5 |
| 19 | 130 Golden | 6 | 20.7% | 12.2% | day 2 |

Every top-missing sticker except 132 Royal (album 19, 2.5% missing) is a phase-6 sticker. Each one was already held by a few payers in the first days. That fits Jokers being able to pick any card, but this is a Hypothesis.

## 3. Story of the last week

- **Payers arrive at the last week already close.** Commons are finished. The first new Golden, the first new Royal and the first payment in the window all fall in the baseline week (median d=-13 to -11). What decides finishing is the last 2–5 gate stickers, almost all in phase 6.
- **Album 17 (Golden gate): a two-wave close.**
  - On d=-7 there is a burst of new Goldens: 54.6% of F-late got one, against 35.9% per baseline day. Market, paid Golden offers and Jokers grow on that day too.
  - Then a quieter middle (d=-5…-3), and a second burst on d=-1, when 37.6% got a Golden and 19.7% a Royal.
  - Finishes are spread over the week, with 39% on d=-1.
  - Finishing stickers are mostly Goldens: Joker 36%, paid offer 19%, event 13%.
- **Album 19 (Royal gate): a 3-day Joker sprint.**
  - d=-7…-4 is quiet: the new-Royal share falls below baseline, to 9.5–16%.
  - From d=-3, Joker fills jump: 28%, then 43%, then 56% of F-late per day. New Royals rise to 50% on d=-1.
  - 81% of finishes happen on d=-2 or d=-1. The typical last five are "G > Gj > Rj > Rj > Gj": two Royals and a Golden picked by Joker, consistent with the phase-6 trio.
- **Paying ramps up with the close.**
  - F-late payers paying per day rise from 34–37% in the baseline week to 57–65% on d=-1. ARPDAU roughly doubles in album 19 ($13 → $27) and rises 1.6× in album 17 ($13 → $22).
  - Revenue per paying day stays flat at $34–47. More payers are paying, but each paying day is about the same size.
- **Rares follow purchases more closely than Commons do.** About 37–45% of new Royals and Goldens land within 10 minutes after a purchase, against 18–25% for Commons. For the finishing sticker the rate is 46–56%. This is a timing link, not proof that the purchase delivered the sticker.
- **Where near-finishers get stuck.** They are active (93–98% per day) and in album 19 N1 they act like finishers on d=-1: 55% pay and 52% use a Joker. They still end missing a phase-6 sticker that only 6–9% of payers held by d=-2:
  - album 17: Golden 106 or 104;
  - album 19: Royal 107 or 108, or Golden 101.
- **N pays less than F-late.** On d=-1 N pays 34% (album 17) / 41% (album 19), against 57% / 65% for F-late. N ARPDAU stays flat at $5–7.5. In album 17, N uses Jokers rarely (≤6% per day in the last 4 days), even though Goldens are what they lack.
- **Cross-game note** (from yesterday's analysis, not re-run here):
  - Dice also closes with a pick-type sticker (last Super via Wild in 87–90% of cases), and it follows a purchase within 10 minutes 72–82% of the time.
  - Disney closes on a single locked Royal (131), filled by Joker.
  - Domino 19 looks like Disney: a Joker-filled phase-6 trio in the last 3 days. Domino 17 is the outlier, with a Golden-led close spread across the week.

## 4. Caveats and definition gaps

- **The Joker flag did not change in the data model.** `collected_by_joker_flag` (dbt: `pack_type='joker'`) equals `number_of_jokers_today` exactly in both albums (119,046 vs 119,045 in album 17; 178,532 vs 178,529 in album 19). There is no break around the Royal Tower launch (07-06).
  - What did change is how much it is used. Over the whole album, the Joker share of new Royals is 1.5% (album 17) vs 4.0% (album 19). In the last week for F-late it is 27.5% vs 79.4%.
  - Whether the game started tagging Royal Tower or event rewards as Joker packs cannot be seen in the data. The studio needs to confirm this (**Needs Validation**).
- **"Joker" and "Wild" are not the same thing.** Domino has no Wild. A Joker is a pick-any-card pack, excluding Pixie and Bonus cards.
  - Joker is a pick mechanism, not an acquisition channel. The Joker pack itself comes from a paid offer, an event, or the Market (see the Joker-origin table).
  - In T3 the Joker bucket is checked first, so Joker-filled stickers are not counted under their campaign label.
  - In T1, J% counts Joker-filled stickers of any type, Commons included.
- **Channel mapping is approximate.**
  - `new_sticker_source` is a campaign label for the first collection. There is no "regular pack pull" label, and level packs and vague packs are not separable.
  - `Info`, `Empty`, `Event` and `(null)` are treated as Unknown: 7–16% of album-17 rares, under 1% in album 19.
  - `Missions` and `mtx` are treated as paid offers, following the topic5 mapping (unconfirmed).
  - `Market` is treated as its own channel; whether its currency is paid is unknown.
- **What a "new" sticker is.** It is the first-ever collection of that sticker. Duplicates and Royal Tower door effects are not counted.
- **Paid day and the 10-minute window.**
  - "Paid day" uses `album_spent_today` > 0, and the calendar day is the album table's date. Purchase dates and sticker dates may sit on different time zones; this was not checked.
  - The 10-minute measure means a purchase timestamp in [sticker_ts − 10 min, sticker_ts]. It assumes purchase and sticker timestamps share one clock.
  - The Commons control is small, because few payers still lack Commons in the last week.
- **The T2 "first day" measures saturate.** Payers collect Goldens and pay almost daily, so first Golden, first Royal and first payment land in the baseline week for 72–96% of players. Use the last-day measures, the first Joker fill and the T1 daily shares.
- **F-early is tiny** (131 / 8). Most album-17 "early" finishes happen on d=-7, which counts as F-late. Yesterday's "10% finished 7+ days before close" included d=-7.
- **Release timing.** Phase-6 release timing is inferred from the data only. Every gate sticker had a few holders by day 1–8, plausibly through Jokers. A time-lock is a **Hypothesis** until the studio shares the release calendar.
- **Close-day finishers.** Close-day finishes are excluded, so some N players may have finished on the close day. Yesterday's finish rates (5.7% / 4.5%) reproduce from these group sizes.

## 5. SQL appendix

All queries ran in `domino-dreams-dbt`, read-only, with a partition filter, and each was dry-run first with the identical SQL. Total scanned is about 100.7 GB across 8 queries; the largest single query was 24.06 GB. The full SQL is saved at `/tmp/claude-0/-home-claude/5629d190-2f4d-5652-8298-2143c958a9b2/scratchpad/dom/domino_last_week_queries.sql`.

| Query | Purpose | Scanned |
|---|---|---|
| Q0 | Source × Joker map, all users, d=-14…-1 | 1.08 GB |
| Q1 | T1 daily profile | 13.34 GB |
| Q2 | T2 first and last days | 13.26 GB |
| Q3 | T3 channels + T4 purchase linkage | 14.13 GB |
| Q4 | T5 sequences and finishing sticker | 14.13 GB |
| Q5 | T5 near-finisher missing stickers | 24.06 GB |
| Q6 | Joker flag vs `number_of_jokers_today` | 7.10 GB |
| Q7 | Origin campaign of Joker-filled rares | 13.58 GB |

**Shared CTEs** (population and groups, plus the window sticker table `st`; Q1–Q4 and Q7 use both, and Q5 uses the population CTEs with its own `sa` sticker table):
```sql
WITH ex AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN '2026-04-02' AND '2026-08-23' AND suspected_cheater_flag),
b AS (SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c, a.login_ratio AS lr, a.user_album_count AS uac,
    IFNULL(a.album_spent_today,0) AS sp, IFNULL(a.active_flag,FALSE) AS act,
    IFNULL(a.unique_common_stickers_lt,0)+IFNULL(a.unique_golden_stickers_lt,0)+IFNULL(a.unique_royal_stickers_tl,0) AS u
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN ex e ON e.user_id=a.user_id
  WHERE a.date_dim BETWEEN '2026-04-02' AND '2026-08-23' AND a.album_id IN (17,19)
    AND a.special_user_flag=FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
p0 AS (SELECT album_id, user_id, ANY_VALUE(c) AS c, MAX(u) AS u_end, MIN(IF(u>=144, date_dim, NULL)) AS fin_d,
    ARRAY_AGG(STRUCT(lr, uac) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l
  FROM b GROUP BY 1,2 HAVING SUM(sp) > 0),
pop AS (SELECT album_id, user_id, c, u_end, fin_d,
    CASE WHEN u_end>=144 AND fin_d >= DATE_SUB(c, INTERVAL 7 DAY) THEN 'F_late'
         WHEN u_end>=144 THEN 'F_early'
         WHEN u_end BETWEEN 141 AND 143 THEN 'N' END AS grp
  FROM p0 WHERE l.lr >= 0.5 AND l.uac > 1),
g AS (SELECT album_id, user_id, c, u_end, fin_d, gl FROM pop, UNNEST(IF(grp IS NULL, [], IF(grp='N' AND u_end=143, ['N','N1'], IF(grp LIKE 'F%', [grp,'F'], [grp])))) gl),
st AS (SELECT s.album_id, s.user_id, s.sticker_id, LOWER(s.sticker_type) AS t, s.sticker_collected_min_date AS sd, s.sticker_collected_min_ts AS ts,
    IFNULL(s.collected_by_joker_flag,FALSE) AS jk, IFNULL(NULLIF(s.new_sticker_source,''),'(null)') AS src
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
  WHERE ((s.album_id = 17 AND s.sticker_collected_min_date BETWEEN '2026-04-27' AND '2026-05-10')
      OR (s.album_id = 19 AND s.sticker_collected_min_date BETWEEN '2026-08-10' AND '2026-08-23'))
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('golden','royal','common')),
```

**Q1, T1 tail**
```sql
std AS (SELECT album_id, user_id, sd, COUNTIF(t='golden') AS ng, COUNTIF(t='royal') AS nr, COUNTIF(t='common') AS nc, COUNTIF(jk) AS nj FROM st GROUP BY 1,2,3),
gs AS (SELECT album_id, gl, COUNT(*) AS gn FROM g GROUP BY 1,2),
dd AS (SELECT g.album_id, g.gl, g.user_id, DATE_DIFF(b.date_dim, g.c, DAY) AS d, b.act, b.sp,
    IFNULL(x.ng,0) AS ng, IFNULL(x.nr,0) AS nr, IFNULL(x.nj,0) AS nj
  FROM g JOIN b ON b.album_id=g.album_id AND b.user_id=g.user_id AND b.date_dim >= DATE_SUB(g.c, INTERVAL 14 DAY)
  LEFT JOIN std x ON x.album_id=g.album_id AND x.user_id=g.user_id AND x.sd=b.date_dim)
SELECT album_id, gl, IF(d<=-8,'base_-14..-8',CAST(d AS STRING)) AS dd, ANY_VALUE(gn) AS n,
  ROUND(COUNTIF(act)/(ANY_VALUE(gn)*IF(MIN(d)<=-8,7,1)),3) AS act_sh,
  ROUND(COUNTIF(ng>0)/(ANY_VALUE(gn)*IF(MIN(d)<=-8,7,1)),3) AS g_sh,
  ROUND(COUNTIF(nr>0)/(ANY_VALUE(gn)*IF(MIN(d)<=-8,7,1)),3) AS r_sh,
  ROUND(COUNTIF(nj>0)/(ANY_VALUE(gn)*IF(MIN(d)<=-8,7,1)),3) AS j_sh,
  ROUND(SUM(ng)/NULLIF(COUNTIF(act),0),3) AS g_pa, ROUND(SUM(nr)/NULLIF(COUNTIF(act),0),3) AS r_pa, ROUND(SUM(nj)/NULLIF(COUNTIF(act),0),3) AS j_pa,
  ROUND(COUNTIF(sp>0)/(ANY_VALUE(gn)*IF(MIN(d)<=-8,7,1)),3) AS paid_sh,
  ROUND(SUM(sp)/NULLIF(COUNTIF(act),0),2) AS arpdau, ROUND(SUM(sp)/NULLIF(COUNTIF(sp>0),0),1) AS rev_payday
FROM dd JOIN gs USING (album_id, gl) GROUP BY 1,2,3 ORDER BY 1,2,3
```

**Q2, T2 tail** (`std` and `dd` exactly as in Q1)
```sql
pu AS (SELECT album_id, gl, user_id,
    MIN(IF(ng>0,d,NULL)) AS first_g, MIN(IF(nr>0,d,NULL)) AS first_r, MIN(IF(nj>0,d,NULL)) AS first_j, MIN(IF(sp>0,d,NULL)) AS first_pay,
    MAX(IF(ng>0,d,NULL)) AS last_g, MAX(IF(nr>0,d,NULL)) AS last_r
  FROM dd WHERE gl IN ('F_late','N','N1') GROUP BY 1,2,3),
m AS (SELECT album_id, gl, user_id, k, v FROM pu,
  UNNEST([STRUCT('first_g' AS k, first_g AS v), ('first_r', first_r), ('first_j', first_j), ('first_pay', first_pay), ('last_g', last_g), ('last_r', last_r)]))
SELECT album_id, gl, k, COUNT(*) AS n, ROUND(COUNTIF(v IS NULL)/COUNT(*),3) AS none,
  ROUND(COUNTIF(v<=-8)/COUNT(*),3) AS base, ROUND(COUNTIF(v=-7)/COUNT(*),3) AS d7, ROUND(COUNTIF(v=-6)/COUNT(*),3) AS d6,
  ROUND(COUNTIF(v=-5)/COUNT(*),3) AS d5, ROUND(COUNTIF(v=-4)/COUNT(*),3) AS d4, ROUND(COUNTIF(v=-3)/COUNT(*),3) AS d3,
  ROUND(COUNTIF(v=-2)/COUNT(*),3) AS d2, ROUND(COUNTIF(v=-1)/COUNT(*),3) AS d1, APPROX_QUANTILES(v,2 IGNORE NULLS)[OFFSET(1)] AS med
FROM m WHERE NOT (gl<>'F_late' AND k LIKE 'last%') GROUP BY 1,2,3 ORDER BY 1,2,3
```

**Q3, T3/T4 tail**
```sql
pur AS (SELECT user_id, timestamp AS pts FROM `domino-dreams-dbt.prod_20_core.core_purchase`
  WHERE (date_dim BETWEEN '2026-05-02' AND '2026-05-11' OR date_dim BETWEEN '2026-08-15' AND '2026-08-24') AND total_usd_amount > 0
  QUALIFY ROW_NUMBER() OVER (PARTITION BY user_id, external_order_id ORDER BY timestamp) = 1),
x AS (SELECT g.album_id, g.gl, st.user_id, st.sticker_id, st.t, st.ts, st.src,
    CASE WHEN jk THEN '1_Joker' WHEN src='duplicates' THEN '2_Dup' WHEN src='Market' THEN '3_Market'
      WHEN src IN ('joker','progress_offer','Missions','BuyThemAll','SeasonPass','OfferLuckyTwister','Box','mtx','1po') OR src LIKE '1+%' THEN '4_Paid'
      WHEN src IN ('days_milestone','area completed','pet tier') THEN '5_ProgDaily'
      WHEN src IN ('(null)','Empty','Info','Event') THEN '7_Unknown' ELSE '6_EventMTX' END AS ch,
    IFNULL(b.sp,0) > 0 AS paid_day
  FROM g JOIN st ON st.album_id=g.album_id AND st.user_id=g.user_id
  LEFT JOIN b ON b.album_id=g.album_id AND b.user_id=g.user_id AND b.date_dim=st.sd
  WHERE g.gl IN ('F_late','N','N1') AND st.sd >= DATE_SUB(g.c, INTERVAL 7 DAY)),
y AS (SELECT x.album_id, x.gl, x.user_id, x.sticker_id, ANY_VALUE(x.t) AS t, ANY_VALUE(x.ch) AS ch, LOGICAL_OR(x.paid_day) AS paid_day,
    LOGICAL_OR(p.pts BETWEEN TIMESTAMP_SUB(x.ts, INTERVAL 10 MINUTE) AND x.ts) AS p10,
    LOGICAL_OR(p.pts BETWEEN TIMESTAMP_SUB(x.ts, INTERVAL 60 MINUTE) AND x.ts) AS p60
  FROM x LEFT JOIN pur p ON p.user_id=x.user_id AND p.pts BETWEEN TIMESTAMP_SUB(x.ts, INTERVAL 60 MINUTE) AND x.ts
  GROUP BY 1,2,3,4)
SELECT album_id, gl, t, COUNT(*) AS n_new, COUNT(DISTINCT user_id) AS players,
  ROUND(COUNTIF(ch='1_Joker')/COUNT(*),3) AS joker, ROUND(COUNTIF(ch='2_Dup')/COUNT(*),3) AS dup, ROUND(COUNTIF(ch='3_Market')/COUNT(*),3) AS market,
  ROUND(COUNTIF(ch='4_Paid')/COUNT(*),3) AS paid_offer, ROUND(COUNTIF(ch='5_ProgDaily')/COUNT(*),3) AS prog_daily,
  ROUND(COUNTIF(ch='6_EventMTX')/COUNT(*),3) AS event_mtx, ROUND(COUNTIF(ch='7_Unknown')/COUNT(*),3) AS unknown,
  ROUND(COUNTIF(paid_day)/COUNT(*),3) AS on_paid_day, ROUND(COUNTIF(p10)/COUNT(*),3) AS within10, ROUND(COUNTIF(p60)/COUNT(*),3) AS within60
FROM y GROUP BY 1,2,3 ORDER BY 1,2,3
```

**Q4, T5 sequences and finishing sticker tail** (`pur` and the CASE are the same as in Q3)
```sql
x AS (SELECT g.album_id, g.user_id, g.c, st.sticker_id, st.t, st.ts, st.sd, st.jk, <CASE as Q3> AS ch,
    IFNULL(b.sp,0) > 0 AS paid_day,
    ROW_NUMBER() OVER (PARTITION BY g.album_id, g.user_id ORDER BY st.ts DESC, st.sticker_id DESC) AS rn
  FROM g JOIN st ON st.album_id=g.album_id AND st.user_id=g.user_id
  LEFT JOIN b ON b.album_id=g.album_id AND b.user_id=g.user_id AND b.date_dim=st.sd
  WHERE g.gl = 'F_late'),
l5 AS (SELECT album_id, user_id, STRING_AGG(CONCAT(UPPER(SUBSTR(t,1,1)), IF(jk,'j','')), '>' ORDER BY ts, sticker_id) AS seq FROM x WHERE rn <= 5 GROUP BY 1,2),
f1 AS (SELECT x.album_id, x.user_id, x.t, x.ch, x.paid_day, DATE_DIFF(x.sd, x.c, DAY) AS d,
    LOGICAL_OR(p.pts BETWEEN TIMESTAMP_SUB(x.ts, INTERVAL 10 MINUTE) AND x.ts) AS p10
  FROM x LEFT JOIN pur p ON p.user_id=x.user_id AND p.pts BETWEEN TIMESTAMP_SUB(x.ts, INTERVAL 10 MINUTE) AND x.ts
  WHERE x.rn = 1 GROUP BY 1,2,3,4,5,6)
(SELECT album_id, 'seq' AS kind, seq AS label, COUNT(*) AS n, ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY album_id),3) AS share,
  CAST(NULL AS FLOAT64) AS paid_day_sh, CAST(NULL AS FLOAT64) AS w10_sh, CAST(NULL AS INT64) AS med_d
 FROM l5 GROUP BY 1,2,3 QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) <= 6)
UNION ALL SELECT album_id, 'finish', CONCAT(t,'|',ch), COUNT(*), ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY album_id),3),
  ROUND(COUNTIF(paid_day)/COUNT(*),3), ROUND(COUNTIF(p10)/COUNT(*),3), APPROX_QUANTILES(d,2)[OFFSET(1)] FROM f1 GROUP BY 1,2,3
UNION ALL SELECT album_id, 'finish_all', 'all', COUNT(*), 1.0, ROUND(COUNTIF(paid_day)/COUNT(*),3), ROUND(COUNTIF(p10)/COUNT(*),3), APPROX_QUANTILES(d,2)[OFFSET(1)] FROM f1 GROUP BY 1,2,3
UNION ALL SELECT album_id, 'finish_d', CAST(d AS STRING), COUNT(*), ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY album_id),3), NULL, NULL, NULL FROM f1 GROUP BY 1,2,3
ORDER BY 1,2,4 DESC
```

**Q5, T5 near-finisher missing stickers.** This uses the shared CTEs through `g`, plus a full-album sticker scan.
```sql
sa AS (SELECT s.album_id, s.user_id, s.sticker_id, LOWER(s.sticker_type) AS t, s.phase, s.sticker_collected_min_date AS sd
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
  WHERE ((s.album_id = 17 AND s.sticker_collected_min_date BETWEEN '2026-04-02' AND '2026-05-10')
      OR (s.album_id = 19 AND s.sticker_collected_min_date BETWEEN '2026-07-06' AND '2026-08-23'))
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('golden','royal','common')),
cfg AS (SELECT album_id, sticker_id, ANY_VALUE(t) AS t, ANY_VALUE(phase) AS phase FROM sa GROUP BY 1,2),
npop AS (SELECT album_id, COUNT(*) AS np FROM pop GROUP BY 1),
avail AS (SELECT sa.album_id, sa.sticker_id, MIN(sa.sd) AS first_sd, COUNTIF(sa.sd <= DATE_SUB(p.c, INTERVAL 2 DAY)) AS held_by_c2
  FROM sa JOIN pop p ON p.album_id=sa.album_id AND p.user_id=sa.user_id GROUP BY 1,2),
own AS (SELECT sa.album_id, sa.user_id, sa.sticker_id FROM sa JOIN g ON g.album_id=sa.album_id AND g.user_id=sa.user_id AND g.gl='N' WHERE sa.sd < g.c),
miss AS (SELECT g.album_id, g.gl, g.user_id, cfg.sticker_id, cfg.t, cfg.phase FROM g JOIN cfg ON cfg.album_id=g.album_id
  LEFT JOIN own o ON o.album_id=g.album_id AND o.user_id=g.user_id AND o.sticker_id=cfg.sticker_id
  WHERE g.gl IN ('N','N1') AND o.sticker_id IS NULL),
m2 AS (SELECT m.album_id, m.gl, m.user_id, m.sticker_id, m.t, m.phase, IFNULL(a.held_by_c2,0) AS held_c2, a.first_sd,
    IFNULL(a.held_by_c2,0)/n.np AS held_sh FROM miss m LEFT JOIN avail a USING (album_id, sticker_id) JOIN npop n USING (album_id)),
gsz AS (SELECT album_id, gl, COUNT(*) AS gn FROM g WHERE gl IN ('N','N1') GROUP BY 1,2)
SELECT m2.album_id, m2.gl, 'by_type' AS kind, m2.t AS label, COUNT(*) AS miss_slots,
  ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY m2.album_id, m2.gl),3) AS share_slots,
  ROUND(COUNT(DISTINCT m2.user_id)/ANY_VALUE(gsz.gn),3) AS players_missing_sh,
  ROUND(COUNTIF(held_c2>0)/COUNT(*),3) AS obtainable_any, ROUND(COUNTIF(held_sh>=0.01)/COUNT(*),3) AS obtainable_1pct,
  CAST(NULL AS INT64) AS phase, CAST(NULL AS INT64) AS first_day, CAST(NULL AS FLOAT64) AS pop_held_c2
FROM m2 JOIN gsz USING (album_id, gl) GROUP BY 1,2,3,4
UNION ALL
(SELECT m2.album_id, m2.gl, 'top_sticker', CONCAT(CAST(m2.sticker_id AS STRING),'-',ANY_VALUE(m2.t)), COUNT(*),
  ROUND(COUNT(*)/ANY_VALUE(gsz.gn),3), NULL, NULL, NULL, ANY_VALUE(m2.phase),
  DATE_DIFF(ANY_VALUE(m2.first_sd), ANY_VALUE(IF(m2.album_id=17, DATE '2026-04-02', DATE '2026-07-06')), DAY)+1, ROUND(ANY_VALUE(m2.held_sh),3)
 FROM m2 JOIN gsz USING (album_id, gl) WHERE m2.gl='N' GROUP BY m2.album_id, m2.gl, m2.sticker_id
 QUALIFY ROW_NUMBER() OVER (PARTITION BY m2.album_id ORDER BY COUNT(*) DESC) <= 10)
ORDER BY 1,2,3,5 DESC
```

**Q0, source × Joker map**
```sql
WITH s AS (SELECT album_id, LOWER(sticker_type) AS t, IFNULL(NULLIF(new_sticker_source,''),'(null)') AS src, COUNT(*) AS n, COUNTIF(IFNULL(collected_by_joker_flag,FALSE)) AS jk
FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers`
WHERE ((album_id = 17 AND sticker_collected_min_date BETWEEN '2026-04-27' AND '2026-05-10') OR (album_id = 19 AND sticker_collected_min_date BETWEEN '2026-08-10' AND '2026-08-23'))
  AND user_collected_sticker_flag AND LOWER(sticker_type) IN ('golden','royal') GROUP BY 1,2,3)
SELECT album_id, t, src, n, ROUND(n/SUM(n) OVER (PARTITION BY album_id,t),3) AS sh, ROUND(jk/n,3) AS jk_share
FROM s QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id,t ORDER BY n DESC) <= 10 ORDER BY 1,2,4 DESC
```

**Q6, Joker flag consistency**
```sql
WITH j AS (SELECT album_id, SUM(IFNULL(number_of_jokers_today,0)) AS jokers_used, SUM(IFNULL(unique_album_stickers_today,0)) AS uniq_today
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE ((album_id=17 AND date_dim BETWEEN '2026-04-02' AND '2026-05-10') OR (album_id=19 AND date_dim BETWEEN '2026-07-06' AND '2026-08-23')) GROUP BY 1),
s AS (SELECT album_id, COUNTIF(IFNULL(collected_by_joker_flag,FALSE)) AS jk_flag_stickers, COUNT(*) AS new_stickers,
    COUNTIF(IFNULL(collected_by_joker_flag,FALSE) AND LOWER(sticker_type)='royal') AS jk_royal, COUNTIF(LOWER(sticker_type)='royal') AS royal
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers`
  WHERE ((album_id=17 AND sticker_collected_min_date BETWEEN '2026-04-02' AND '2026-05-10') OR (album_id=19 AND sticker_collected_min_date BETWEEN '2026-07-06' AND '2026-08-23'))
    AND user_collected_sticker_flag GROUP BY 1)
SELECT album_id, jokers_used, jk_flag_stickers, ROUND(jk_flag_stickers/NULLIF(jokers_used,0),3) AS flag_per_joker_used,
  new_stickers, uniq_today, ROUND(jk_royal/royal,3) AS royal_jk_share
FROM j JOIN s USING (album_id) ORDER BY 1
```

**Q7, origin of Joker-filled rares** (shared CTEs + `st`)
```sql
z AS (SELECT g.album_id, st.src, st.t FROM g JOIN st ON st.album_id=g.album_id AND st.user_id=g.user_id
  WHERE g.gl IN ('F_late','N') AND st.jk AND st.t IN ('golden','royal') AND st.sd >= DATE_SUB(g.c, INTERVAL 7 DAY))
SELECT album_id, src, COUNT(*) AS n, ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY album_id),3) AS share, ROUND(COUNTIF(t='royal')/COUNT(*),3) AS royal_sh
FROM z GROUP BY 1,2 QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) <= 8 ORDER BY 1,3 DESC
```

**Worth saving to memory or the project:**
- Domino `collected_by_joker_flag` equals `number_of_jokers_today` 1:1 in both albums, so there is no data-model break at the Royal Tower launch.
- Domino album 19 closes with a Joker-filled phase-6 trio in d=-3…-1: 95.5% of finishing stickers are Joker-filled and 81% finish on d=-2 or d=-1. Album 17 closes on Goldens over the whole last week, with 45% via Joker.
- Domino curated purchase timestamps are in `domino-dreams-dbt.prod_20_core.core_purchase` (`timestamp`, `external_order_id`, `total_usd_amount`).
---

# Disney Solitaire (albums 14 and 15): how players finish the album in the last week

**Scope.** Project `solitaire-dreams-411507`. Population is payers who are not in their first album (`user_album_count > 1`), not special and not excluded, with login ratio ≥ 0.5 on their last row before close. The close day is excluded. "Finished" means 144 unique Common + Golden + Royal stickers before close. "New" means the player's first-ever receipt of that sticker in the album, deduplicated per user × sticker. Day index d = date − close, so d = −1 is the last full day. The baseline week is d = −14…−8.

**Joker vs Wild.** Disney has no Wild mechanic. "Joker fill" means `collected_by_joker_flag` = TRUE. The source on that row says where the Joker came from (marketplace, purchase, or an event).

**Session note.** Another agent had locked the shared BigQuery session to `domino-dreams-dbt`. I did not change the lock. Every Disney table is fully qualified, so the jobs were billed under the domino project. The results are unaffected.

## 1. Five headline findings

1. **No payer finished early; every finish fell in d = −4…−1.**
   - 64.6% / 58.7% finished on d = −1, 26.0% / 32.2% on d = −2, and 8.5% / 8.1% on d = −3.
   - Label: **Known**. Population: not-first finishers, n = 14,037 (album 14) / 13,184 (album 15).
   - There were 0 F-early players (finished before d = −7) in either album, so F = F-late.
2. **The last three stickers ("locked trio") open in two waves, Goldens first and then Royal 131, and Joker use follows the Royal.**
   - The trio is Royal 131 plus two Goldens: 84 and 130 in album 14, 141 and 142 in album 15.
   - Album 14: Goldens 84 and 130 jump from ~0 to thousands of collectors a day at d = −7 (big step at d = −5). Royal 131 goes from ~300 to 3,371 a day at d = −3.
   - Album 15: Goldens 141 and 142 open at d = −5. Royal 131 had an event pulse at d = −11 (5,452 rows; this is the Sugar Rush day 32 from yesterday). Its main wave is d = −3 to −1.
   - Finishers' daily Joker-fill rate: about 0.1–0.5% until d = −5, then 1% / 7.5% at d = −4, 12% / 17% at d = −3, 33% / 41% at d = −2 and 64% / 56% at d = −1.
   - Label: **Known** for the timing (all collectors). That the release is set by album config is a **Hypothesis**.
3. **Most finishers close the album with a Joker-filled sticker.**
   - The finishing sticker is a Royal for 80% (album 14) / 47% (album 15) of finishers. It is Joker-filled for 86% / 69%.
   - Joker or direct from the Market: 54% / 45%. From a paid offer (Joker or direct): 21% / 26%.
   - Label: **Known**. Population: F, n = 14,037 / 13,184. Whether the Market costs real money is still unknown.
4. **New rares in the last week arrive on paying days far more often than the Common control, and Joker-filled Royals almost always do.**
   - For finishers, a new Royal (d = −7…−1) lands on a day the player paid 83.5% / 84.5% of the time; a new Golden 82% / 84%. The Common placebo is 40% / 51%.
   - Joker-filled Royals land on a paid day 91% / 95% of the time.
   - Label: **Known** for the day-level co-occurrence. That the purchase is what bought the sticker is **Needs Validation**: purchase timestamps are not available in curated layers, so the 10-minute test could not be run.
5. **Near-finishers stop at exactly the locked trio, and almost no payer could get it before the last 3–7 days.**
   - 96.6% / 85.6% of near-finishers are missing a Royal; 95.8% / 79.2% are missing 131 specifically.
   - The most common missing set is R+G+G (55% / 61%), which is exactly the trio.
   - By end of d = −2, only 2.0% / 5.5% of all payers held 131, and 5–12% held the trio Goldens.
   - Label: **Known**. Population: N, n = 70,069 / 48,258 (sticker-table basis).
   - Revenue (`album_spent_today`) is confirmed as **USD gross**: Known (detail in section 4).

## 2. Tables

### Group sizes

| Group | Album 14 | Album 15 |
|---|---|---|
| F (finished, 144 before close) = F-late | 14,037 | 13,184 |
| F-early (finished before d = −7) | 0 | 0 |
| N (1–3 short at end of d = −1) | 71,272 | 49,456 |
| N1 (exactly 1 short) | 10,206 | 7,128 |

### T1 — Daily acquisition profile

How to read the tables:
- Each cell shows **album 14 / album 15**.
- "%act" is active player-days divided by group size. All other rates are per active player-day.
- G = Golden, R = Royal (rare), J = Joker-filled new sticker (any type).
- The "base" row averages d = −14…−8.

**F — finishers (n = 14,037 / 13,184)**

| d | %act | %newG | %newR | %J | G/act | R/act | J/act | %paid | PU ARPDAU | $ per paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base | .95/.96 | .26/.28 | .05/.16 | .00/.00 | .44/.54 | .06/.19 | .00/.00 | .35/.34 | 11.6/13.4 | 33.4/39.0 |
| −7 | .96/.96 | .27/.11 | .12/.18 | .00/.00 | .46/.17 | .15/.21 | .00/.00 | .33/.28 | 10.1/10.1 | 30.8/35.6 |
| −6 | .96/.96 | .18/.10 | .07/.09 | .00/.00 | .27/.15 | .09/.11 | .00/.00 | .34/.29 | 9.6/8.9 | 28.2/30.9 |
| −5 | .96/.96 | .16/.14 | .06/.05 | .00/.01 | .35/.22 | .08/.07 | .00/.01 | .34/.30 | 10.3/10.5 | 29.9/34.6 |
| −4 | .96/.96 | .23/.20 | .07/.10 | .01/.08 | .44/.35 | .09/.13 | .01/.08 | .39/.37 | 13.7/15.7 | 35.4/42.3 |
| −3 | .97/.96 | .35/.31 | .14/.19 | .12/.17 | .60/.52 | .17/.24 | .12/.20 | .47/.47 | 19.0/19.9 | 40.2/42.5 |
| −2 | .97/.98 | .34/.50 | .34/.42 | .33/.41 | .65/1.01 | .42/.66 | .40/.57 | .55/.64 | 22.8/27.0 | 41.7/42.5 |
| −1 | .99/.99 | .52/.50 | .63/.49 | .64/.56 | 1.18/1.10 | .79/.73 | .87/.86 | .72/.69 | 27.8/29.4 | 38.5/42.4 |

**N1 — exactly 1 short (n = 10,206 / 7,128)**

| d | %act | %newG | %newR | %J | G/act | R/act | J/act | %paid | PU ARPDAU | $ per paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base | .95/.96 | .27/.30 | .05/.16 | .00/.00 | .44/.56 | .06/.18 | .00/.00 | .30/.33 | 7.9/10.2 | 26.1/31.5 |
| −7 | .96/.96 | .28/.13 | .13/.22 | .00/.00 | .46/.20 | .15/.25 | .00/.00 | .29/.30 | 7.4/8.8 | 25.5/29.2 |
| −6 | .96/.96 | .22/.13 | .10/.13 | .00/.00 | .34/.21 | .12/.15 | .00/.00 | .32/.32 | 7.2/8.6 | 22.7/27.1 |
| −5 | .96/.96 | .28/.19 | .12/.09 | .00/.01 | .77/.33 | .18/.12 | .00/.01 | .39/.37 | 9.5/10.5 | 24.4/28.7 |
| −4 | .97/.97 | .27/.27 | .10/.13 | .00/.08 | .58/.49 | .14/.18 | .00/.09 | .39/.44 | 10.8/15.1 | 27.4/34.2 |
| −3 | .97/.97 | .29/.30 | .08/.15 | .05/.13 | .49/.50 | .11/.20 | .05/.13 | .42/.47 | 12.0/15.9 | 28.6/33.6 |
| −2 | .96/.97 | .35/.39 | .17/.23 | .18/.21 | .62/.71 | .23/.38 | .20/.25 | .48/.51 | 14.3/15.1 | 29.7/29.7 |
| −1 | .97/.97 | .44/.53 | .24/.28 | .33/.43 | .95/1.03 | .34/.48 | .40/.57 | .50/.58 | 13.4/17.2 | 26.8/29.8 |

**N — 1–3 short (n = 71,272 / 49,456)**

| d | %act | %newG | %newR | %J | G/act | R/act | J/act | %paid | PU ARPDAU | $ per paying day |
|---|---|---|---|---|---|---|---|---|---|---|
| base | .96/.96 | .28/.32 | .05/.18 | .00/.00 | .48/.65 | .07/.22 | .00/.00 | .28/.34 | 6.0/8.6 | 21.7/25.6 |
| −7 | .96/.96 | .36/.12 | .19/.22 | .00/.00 | .68/.19 | .24/.26 | .00/.00 | .31/.30 | 6.2/7.2 | 20.4/24.2 |
| −6 | .96/.96 | .23/.10 | .12/.12 | .00/.00 | .37/.17 | .15/.14 | .00/.00 | .31/.31 | 5.8/6.3 | 18.6/20.4 |
| −5 | .96/.96 | .24/.13 | .14/.09 | .00/.00 | .58/.23 | .19/.12 | .00/.00 | .34/.34 | 6.6/7.3 | 19.2/21.8 |
| −4 | .96/.95 | .19/.17 | .10/.09 | .00/.02 | .39/.30 | .14/.12 | .00/.02 | .30/.35 | 6.0/8.2 | 19.9/23.6 |
| −3 | .95/.95 | .13/.15 | .05/.09 | .01/.04 | .20/.23 | .06/.11 | .01/.04 | .28/.32 | 5.6/7.3 | 20.0/22.5 |
| −2 | .93/.94 | .14/.15 | .09/.14 | .05/.07 | .22/.25 | .12/.20 | .06/.08 | .28/.31 | 5.7/6.4 | 20.5/20.4 |
| −1 | .94/.94 | .18/.20 | .10/.17 | .10/.16 | .34/.34 | .14/.25 | .11/.20 | .27/.33 | 5.1/6.7 | 18.8/20.6 |

### T2 — "When do they start"

Each cell is the share of the group whose **first** event in d = −14…−1 fell on that day (album 14 / album 15). "base" means the first one already came in d = −14…−8.

| Group · metric | base | −7 | −6 | −5 | −4 | −3 | −2 | −1 | none | median d |
|---|---|---|---|---|---|---|---|---|---|---|
| F · 1st new Golden | .91/.85 | .04/.01 | .02/.01 | .01/.02 | .01/.02 | .01/.03 | .00/.04 | .00/.03 | .00/.00 | −11/−12 |
| F · 1st new Royal | .31/.76 | .09/.07 | .05/.03 | .04/.01 | .04/.02 | .08/.03 | .16/.05 | .24/.04 | .01/.00 | −4/−11 |
| F · 1st Joker fill | .00/.01 | .00/.00 | .00/.00 | .00/.01 | .01/.07 | .11/.15 | .30/.34 | .56/.40 | .01/.02 | −1/−2 |
| F · 1st purchase | .78/.77 | .03/.03 | .03/.02 | .02/.03 | .03/.03 | .02/.03 | .03/.05 | .05/.04 | .02/.01 | −12/−12 |
| N1 · 1st Joker fill | .00/.01 | .00/.00 | .00/.00 | .00/.01 | .00/.08 | .05/.12 | .17/.18 | .31/.35 | .47/.25 | −1/−2 |
| N1 · 1st new Royal | .29/.76 | .10/.08 | .07/.04 | .08/.02 | .06/.02 | .04/.02 | .08/.03 | .09/.03 | .21/.02 | −6/−11 |
| N1 · 1st purchase | .72/.74 | .03/.03 | .03/.02 | .04/.04 | .03/.05 | .03/.03 | .03/.03 | .03/.04 | .05/.03 | −12/−12 |
| N · 1st Joker fill | .00/.01 | .00/.00 | .00/.00 | .00/.00 | .00/.02 | .01/.04 | .05/.06 | .09/.13 | .85/.73 | −1/−2 |
| N · 1st new Royal | .32/.83 | .14/.06 | .08/.03 | .08/.01 | .05/.01 | .02/.01 | .04/.01 | .03/.01 | .23/.02 | −7/−11 |
| N · 1st purchase | .70/.80 | .04/.03 | .04/.02 | .05/.03 | .03/.03 | .02/.02 | .02/.02 | .02/.02 | .10/.05 | −12/−12 |

Finishers only: the **last** new Golden, the last new Royal, and the finishing sticker.

| Metric | ≤ −5 | −4 | −3 | −2 | −1 | median d |
|---|---|---|---|---|---|---|
| Last new Golden | .02/.01 | .06/.03 | .16/.13 | .25/.35 | .52/.49 | −1/−2 |
| Last new Royal | .00/.03 | .01/.05 | .09/.11 | .27/.34 | .62/.48 | −1/−2 |
| Finishing sticker | 0/0 | .01/.01 | .09/.08 | .26/.32 | .65/.59 | −1/−1 |

Type and channel of the finishing sticker (n = 14,037 / 13,184):

| Finishing sticker | Album 14 | Album 15 |
|---|---|---|
| Royal · Joker via Market | 50.2% | 20.8% |
| Royal · Joker via paid offer | 16.4% | 13.5% |
| Royal · Joker via event | 12.6% | 9.1% |
| Royal · not Joker | 0.8% | 3.8% |
| Golden · Joker (Market / paid / event) | 6.8% | 25.6% |
| Golden · Market direct | — | 9.7% |
| Golden · paid offer direct | 2.1% | 5.6% |
| Golden · event or core loop | 11.0% | 11.9% |
| **Total Royal / Golden** | 80 / 20 | 47 / 53 |
| **Total Joker-filled** | 86% | 69% |

### T3 — Channel of new Golden and Royal stickers, d = −7…−1 (share within type)

| Channel | F · Royal | F · Golden | N1 · Royal | N · Royal | N · Golden | F · Common (control) |
|---|---|---|---|---|---|---|
| Joker via Market | 38.2 / 14.8 | 3.9 / 9.9 | 19.6 / 7.0 | 5.9 / 4.3 | 2.1 / 4.5 | 0 / 0 |
| Joker via paid offer | 14.1 / 16.5 | 4.3 / 6.8 | 4.3 / 8.0 | 1.4 / 4.9 | 1.2 / 2.6 | 0 / 0.1 |
| Joker via event | 7.8 / 13.6 | 0.2 / 4.9 | 1.5 / 10.2 | 0.4 / 6.0 | 0.1 / 2.5 | 0 / 0.1 |
| Paid offer (direct) | 1.9 / 0 | 21.5 / 21.1 | 2.9 / 0 | 1.9 / 0 | 10.8 / 19.7 | 2.8 / 2.2 |
| Market (direct) | 0.6 / 0 | 1.1 / 10.1 | 1.1 / 0 | 1.6 / 0 | 1.9 / 7.5 | 6.1 / 5.0 |
| Dup exchange | 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0 | 3.1 / 1.8 |
| Event / MTX reward | 16.7 / 23.1 | 42.4 / 14.3 | 26.0 / 31.2 | 35.4 / 34.9 | 56.6 / 25.4 | 52.8 / 41.7 |
| Core loop / free progression | 20.7 / 31.9 | 25.7 / 32.5 | 44.4 / 43.4 | 53.3 / 49.7 | 26.1 / 36.8 | 35.2 / 49.1 |
| Unknown | 0 / 0 | 0.8 / 0.4 | 0 / 0.1 | 0.1 / 0.1 | 1.3 / 1.0 | 0 / 0 |
| **n stickers** | 24,623 / 27,541 | 53,868 / 45,189 | 12,476 / 12,117 | 70,757 / 57,000 | 190,354 / 79,977 | 3,872 / 27,100 |

How raw `new_sticker_source` values map to buckets:
- **Joker:** any row with `collected_by_joker_flag`. The sub-bucket comes from the source: `marketplace` → Market; `purchase` or `purchase_gift` → paid offer; anything else (`conveyor_belt`, `mtx challenge`, `holiday_tree`, `recovery`) → event.
- **Paid offer (direct):** `purchase`, `purchase_gift`, `free_after_purchase`.
- **Market (direct):** `marketplace`.
- **Dup exchange:** `duplicates`.
- **Core loop / free progression:** `daily_reward`, `momentum`, `flytext`, `area completed`, `enough DR`, `album tutorial`, `free`, `days_milestone`, `welcomeback`, `journey-panel`, `recovery_free`, `compensation`, `friend_invite`, `mf *` (Magical Friend).
- **Unknown:** `(null)`, `backfill_data`.
- **Event / MTX reward:** everything else, including `mtx challenge`, `mini_collection`, `scrolling`, `black-friday-wheel`, `gamified_8box`, `blast`, `race`, `tournament`, `lightyear-trail`, `sleigh-trails`, `conveyor_belt`, `Trio-*`, `tick-tock`, `farmers-market-chef`, `art-studio`, `fortune_flight`, `merge *`, `catcher`, `duel`, `trivia`.

### T4 — Purchase linkage (day level only)

Each cell shows the share of new stickers arriving **on a day the player paid**, with "paid that day or the day before" in brackets.

| Group | New Royal, d −7…−1 | Royal, Joker-filled | Royal, not Joker | New Golden, d −7…−1 | **Common (control)** | Royal, baseline week |
|---|---|---|---|---|---|---|
| F | 83.5 / 84.5 (88 / 88) | 91.2 / 95.0 | 71.8 / 75.9 | 81.9 / 84.4 | **39.8 / 50.5** | 77.4 / 66.3 |
| N1 | 69.2 / 77.5 | 75.3 / 93.2 | 67.2 / 72.2 | 73.9 / 79.7 | **39.3 / 50.5** | 72.1 / 62.9 |
| N | 59.2 / 68.5 | 74.3 / 90.4 | 58.0 / 64.6 | 62.7 / 74.5 | **38.3 / 54.0** | 70.9 / 66.2 |

- **The 10-minute test could not be run.** The only timestamped purchase source, `bi_entity_prod.purchase_completed_fix_vw`, was refused by the server's partition guard. It is a view over raw `mp_solitaire_dreams_prod.purchase_completed` and unpartitioned `user_profile` / VAT tables, so it needs a raw-layer approval.
- `fact_user_campaign_purchases` has dates only.
- The results above are therefore day-level only.

### T5 — Sequence and what is missing

**Finishers' last 5 new stickers, oldest to newest.** C/G/R = Common/Golden/Royal; "j" means Joker-filled.

| Album 14 pattern | Share | Album 15 pattern | Share |
|---|---|---|---|
| G-G-G-G-Rj | 32.8% | G-R-G-G-Rj | 2.9% |
| R-G-G-G-Rj | 6.8% | R-R-G-G-Rj | 2.9% |
| G-R-G-G-Rj | 6.6% | R-G-G-G-Rj | 2.6% |
| G-G-G-Rj-G | 5.3% | C-R-G-G-Rj | 2.4% |
| G-G-Gj-G-Rj | 4.6% | C-C-G-G-Rj | 2.4% |

- Make-up of the last 5 stickers. Album 14: Golden 69% (6% Joker), Royal 31% (21% Joker), Common 0.4%. Album 15: Golden 53% (14% Joker), Royal 39% (18% Joker), Common 8%.
- Album 15 patterns are spread out (no pattern above 3%) because 131 was partly released at d = −11.

**Near-finishers at the end of d = −1.** These figures use the sticker table, which gives n = 70,069 / 48,258.

| | Album 14 | Album 15 |
|---|---|---|
| Missing ≥ 1 Royal | 96.6% | 85.6% |
| Missing Royal 131 | 95.8% | 79.2% |
| Missing stickers by type (R / G / C) | 42 / 58 / 0% | 35 / 65 / 0% |
| Top missing set | R+G+G 55.0% (131 in 99.9%) | R+G+G 60.5% (131 in 92.8%) |
| 2nd and 3rd | R+G 25.3%, R 11.8% | R+G 14.5%, R 8.8% |
| N1 missing a Royal / missing 131 | 81.7% / 79.0% (n = 9,460) | 61.3% / 56.4% (n = 6,384) |

**Which stickers are missing, and whether they could be had:**

| Album | Sticker | % of N missing it | Payers holding it by end of d = −2 | Daily-collector timing (all players) |
|---|---|---|---|---|
| 14 | 131 Royal | 94.2% | 2.0% (7,535) | <300/day until d = −4; 3.4K at d = −3, 10K at d = −2, 26K at d = −1 |
| 14 | 130 Golden | 67.6% | 8.1% (29,807) | ~0 until d = −8; 4.9K at d = −7, 21.7K at d = −5 |
| 14 | 84 Golden | 52.0% | 12.1% (44,607) | ~100/day until d = −8; 9.7K at d = −7, 36.9K at d = −5 |
| 15 | 131 Royal | 77.3% | 5.5% (17,802) | 5.5K at d = −11 (event); 0.4–1.6K/day d = −10…−4; 10.6K at d = −2, 16.9K at d = −1 |
| 15 | 142 Golden | 75.5% | 5.1% (16,481) | <40/day until d = −7; 1.8K at d = −5, 10K at d = −2 |
| 15 | 141 Golden | 75.4% | 5.1% (16,487) | same timing as 142 |

Every other sticker is missing for under 9% of N, and more than 42% of payers held each of them by d = −2.

On "obtainable before d = −1": a handful of payers collected each trio sticker as early as d = −42. That is a trickle (backfill, recovery or compensation sources), not a real release.

## 3. Story of the last week (Disney)

- **Through d = −8 the trio cannot be had.** Finishers and near-finishers look alike: they are 95% active, about 26–30% get a new Golden each day, there are almost no Jokers, and about 30–35% pay each day. Most new Royals in this period are the six earlier Royals, from events and the core loop.
- **From d = −7 (album 14) or d = −5 (album 15) the two trio Goldens open.** Finishers pick them up through events, the core loop and direct paid offers. Market and Joker use for Goldens is low in album 14 but is about 30% of finishers' new Goldens in album 15.
- **From d = −4 to −3 Royal 131 opens and Joker fills switch on.** Finishers' daily Joker rate goes 1–8% → 12–17% → 33–41% → 56–64%. Their pay rate doubles from 33% to 69–72%, and PU ARPDAU goes from about $10 to $28–29.
- **The typical album-14 finisher ends G-G-G-G-Rj.** They collect the Goldens, then fill 131 with a Joker, most often bought in the Market (50% of finishing stickers). In album 15, 131 was partly available from d = −11, so about half of finishers end on a Golden instead.
- **Every finish is crammed into the last 4 days.** 65% / 59% finish on the last full day, and nobody has 7 or more days left to keep spending after finishing.
- **Near-finishers are mostly waiting on the same trio**, and 131 is missing for 79–96% of them. By d = −2 only 2–5.5% of all payers held 131.
- **N1 players' end-of-album ramp is much flatter than finishers'.** Their pay rate goes 30% → 50–58% (finishers: 35% → 69–72%), and 47% / 25% of them never use a Joker in the window. For the wider N group (1–3 short), the pay rate and ARPDAU do not rise at all ($6.0 base → $5.1 at d = −1 in album 14).
- **The control shows a difference, not a cause.** New rares in the last week land on paying days about twice as often as new Commons (83% vs 40–51%). This fits paid closing, but day-level co-occurrence does not show that the purchase bought the sticker.

## 4. Caveats and definition gaps

- **Joker vs Wild.** Disney has only Jokers. The Joker's own origin (Market vs paid offer vs event) is inferred from `new_sticker_source` on the Joker-filled row. Whether the Market is paid in real currency is still **unknown**, so "Joker via Market" cannot be called paid.
- **Channel mapping is judgment-based.** `enough DR` and `flytext` sit in "core loop" but their meaning is unconfirmed. `purchase_gift` sits in "paid offer". `mtx challenge` and `scrolling` sit in "event" even though MTX events may be paid. Dup exchange exists for Commons (2–4%) but is 0 for Goldens and Royals, which is consistent with yesterday's "Disney has no rare dup exchange".
- **No purchase timestamps.** T4 is day-level only (details under the T4 table). Date boundaries are game-day `date_dim` vs `sticker_collected_min_date`; they are assumed to share a day boundary, which is not verified.
- **Revenue column: Known, USD gross.** Checked on album 15, d = −14…−1, for all non-special users:
  - `album_spent_today` ÷ `bi_prod.fact_purchase_channels.gross_revenues` = 0.995.
  - The two match to within $0.05 on 99.1% of paying user-days.
  - The `currency` column is the local transaction currency (53% of rows are not USD), but `gross_revenues` is already converted: gross per transaction is $11.17 for JPY rows vs $11.05 for USD rows.
- **The two group bases differ slightly.** The daily table (`unique_*_lt`) gives N = 71,272 / 49,456 and N1 = 10,206 / 7,128. The sticker table gives 70,069 / 48,258 and 9,460 / 6,384, because about 1.7% of N have all 144 in the sticker table. T1, T2 and T4 use the daily-table groups; the missing-sticker tables use sticker-table missing.
- **"New" is checked only within this album.** Stickers are deduplicated per user × sticker, and earlier receipts in the same album are excluded with an anti-join.
- **The trio's release timing is inferred from collector counts.** The config calendar has not been checked. The trio Goldens are 84/130 (album 14) and 141/142 (album 15), not one fixed pair.
- **First purchase in T2 says little.** 72–80% of every group already paid in the baseline week, so the daily pay rate in T1 is the better ramp signal.

## 5. SQL appendix

All queries were read-only, dry-run first with identical SQL, partition-filtered, and fully qualified to `solitaire-dreams-411507`. They were billed in `domino-dreams-dbt` (the session lock).

| # | Query | Bytes |
|---|---|---|
| E0 | INFORMATION_SCHEMA table and column search (3 calls) | 3 × 10.5 MB |
| E1 | Raw source values × type × Joker share, last 14 days (all users) | 7.76 GB |
| E2 | Timestamped purchase check (`purchase_completed_fix_vw`) | **refused at dry run** (partition guard on underlying `user_profile` / VAT tables), 0 B |
| E3 | USD check: album spend vs `fact_purchase_channels` | 1.87 GB |
| E4 | Gross per transaction by currency | 0.025 GB |
| Q1 | T1 daily profile | 57.53 GB |
| Q2 | T2 first/last-day distributions | 57.36 GB |
| Q3 | T3, T4, finishing sticker, T5 patterns | 64.39 GB |
| Q4 | T5 near-finishers missing and obtainability | 52.61 GB |
| Q5 | Trio daily collector timing | 3.85 GB |
| | **Total** | **≈ 245 GB** (each query under 100 GB) |

The first Q1 dry run failed with 0 B, because a three-part `s.x.ts` column path was read as a project; it was fixed by flattening the struct.

**Shared base CTEs, used by Q1–Q3.** Q4 uses the first four CTEs only.

```sql
WITH ex AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN '2020-01-01' AND '2026-10-05' AND exclude_reason IS NOT NULL),
b AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS c, a.login_ratio, a.user_album_count,
    IFNULL(a.album_spent_today,0) AS sp, IFNULL(a.active_flag,FALSE) AS act,
    IFNULL(a.unique_common_stickers_lt,0)+IFNULL(a.unique_golden_stickers_lt,0)+IFNULL(a.unique_royal_stickers_tl,0) AS u
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN ex e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN '2026-07-13' AND '2026-10-04' AND a.album_id IN (14,15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
pop AS (
  SELECT album_id, user_id, ANY_VALUE(c) AS c, MAX(u) AS u_end, MIN(IF(u >= 144, date_dim, NULL)) AS fin_d
  FROM b GROUP BY 1,2
  HAVING SUM(sp) > 0 AND MAX(user_album_count) > 1
    AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
g AS (
  SELECT album_id, user_id, c, u_end, fin_d,
    CASE WHEN u_end >= 144 AND fin_d >= DATE_SUB(c, INTERVAL 7 DAY) THEN 'F_late'
         WHEN u_end >= 144 THEN 'F_early'
         WHEN 144 - u_end = 1 THEN 'N1' ELSE 'N23' END AS grp
  FROM pop WHERE u_end >= 144 OR 144 - u_end BETWEEN 1 AND 3),
sw0 AS (
  SELECT album_id, user_id, sticker_id, ANY_VALUE(sticker_type) AS t,
    ARRAY_AGG(STRUCT(sticker_collected_min_ts AS ts, sticker_collected_min_date AS dt,
      IFNULL(NULLIF(new_sticker_source,''),'(null)') AS src, IFNULL(collected_by_joker_flag,FALSE) AS jk)
      ORDER BY sticker_collected_min_ts LIMIT 1)[OFFSET(0)] AS x
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers`
  WHERE ((album_id = 14 AND sticker_collected_min_date BETWEEN '2026-08-10' AND '2026-08-23')
      OR (album_id = 15 AND sticker_collected_min_date BETWEEN '2026-09-21' AND '2026-10-04'))
    AND user_collected_sticker_flag AND sticker_type IN ('Common','Golden','Royal')
  GROUP BY 1,2,3),
sw AS (SELECT album_id, user_id, sticker_id, t, x.ts AS ts, x.dt AS dt, x.src AS src, x.jk AS jk FROM sw0),
sp_ AS (
  SELECT DISTINCT album_id, user_id, sticker_id
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers`
  WHERE ((album_id = 14 AND sticker_collected_min_date BETWEEN '2026-07-13' AND '2026-08-09')
      OR (album_id = 15 AND sticker_collected_min_date BETWEEN '2026-08-24' AND '2026-09-20'))
    AND user_collected_sticker_flag AND sticker_type IN ('Common','Golden','Royal')),
ns AS (
  SELECT s.album_id, s.user_id, s.sticker_id, s.t, s.ts, s.dt, s.src, s.jk,
    DATE_DIFF(s.dt, g.c, DAY) AS d, g.grp,
    CASE WHEN s.jk AND s.src = 'marketplace' THEN 'Joker via Market'
         WHEN s.jk AND s.src IN ('purchase','purchase_gift') THEN 'Joker via paid offer'
         WHEN s.jk THEN 'Joker via event/other'
         WHEN s.src IN ('purchase','purchase_gift','free_after_purchase') THEN 'Paid offer (direct)'
         WHEN s.src = 'marketplace' THEN 'Market (direct)'
         WHEN s.src = 'duplicates' THEN 'Dup exchange'
         WHEN s.src IN ('daily_reward','momentum','flytext','area completed','enough DR','album tutorial','free','days_milestone',
                        'welcomeback','journey-panel','recovery_free','compensation','friend_invite') OR LOWER(s.src) LIKE 'mf %' THEN 'Core loop / free progression'
         WHEN s.src IN ('(null)','backfill_data') THEN 'Unknown'
         ELSE 'Event / MTX reward' END AS ch   -- the ch column was omitted in Q1/Q2 as executed
  FROM sw s JOIN g ON g.album_id = s.album_id AND g.user_id = s.user_id
  LEFT JOIN sp_ p ON p.album_id = s.album_id AND p.user_id = s.user_id AND p.sticker_id = s.sticker_id
  WHERE p.user_id IS NULL AND s.dt < g.c)
```

**Q1 tail (T1)**
```sql
, ud AS (SELECT b.album_id, b.user_id, g.grp, DATE_DIFF(b.date_dim, b.c, DAY) AS d, b.act, b.sp
  FROM b JOIN g ON g.album_id = b.album_id AND g.user_id = b.user_id WHERE b.date_dim >= DATE_SUB(b.c, INTERVAL 14 DAY)),
sd AS (SELECT album_id, user_id, d, COUNTIF(t='Golden') AS ng, COUNTIF(t='Royal') AS nr, COUNTIF(jk) AS nj FROM ns GROUP BY 1,2,3),
gn AS (SELECT album_id, lbl, COUNT(*) AS n_grp FROM g, UNNEST([grp, IF(grp LIKE 'F%', 'F_all', 'N_all')]) AS lbl GROUP BY 1,2),
j AS (SELECT u.album_id, lbl, IF(u.d <= -8, 'base', FORMAT('%d', u.d)) AS dd, u.user_id, u.act, u.sp,
    IFNULL(s.ng,0) AS ng, IFNULL(s.nr,0) AS nr, IFNULL(s.nj,0) AS nj
  FROM ud u LEFT JOIN sd s ON s.album_id = u.album_id AND s.user_id = u.user_id AND s.d = u.d,
  UNNEST([u.grp, IF(u.grp LIKE 'F%', 'F_all', 'N_all')]) AS lbl WHERE lbl != 'N23')
SELECT j.album_id, j.lbl, j.dd, ANY_VALUE(gn.n_grp) AS n_grp,
  ROUND(COUNTIF(act)/(ANY_VALUE(gn.n_grp)*IF(j.dd='base',7,1)),3) AS pct_active,
  ROUND(COUNTIF(act AND ng>0)/COUNTIF(act),3) AS pct_newG, ROUND(COUNTIF(act AND nr>0)/COUNTIF(act),3) AS pct_newR,
  ROUND(COUNTIF(act AND nj>0)/COUNTIF(act),3) AS pct_joker, ROUND(SUM(IF(act,ng,0))/COUNTIF(act),3) AS ng_pa,
  ROUND(SUM(IF(act,nr,0))/COUNTIF(act),3) AS nr_pa, ROUND(SUM(IF(act,nj,0))/COUNTIF(act),3) AS nj_pa,
  ROUND(COUNTIF(act AND sp>0)/COUNTIF(act),3) AS pct_paid, ROUND(SUM(sp)/COUNTIF(act),2) AS arpdau,
  ROUND(SUM(sp)/NULLIF(COUNTIF(sp>0),0),2) AS rev_payday
FROM j JOIN gn ON gn.album_id = j.album_id AND gn.lbl = j.lbl GROUP BY 1,2,3 ORDER BY 1,2,3
```

**Q2 tail (T2)**
```sql
, fd AS (SELECT album_id, user_id, MIN(IF(t='Golden', d, NULL)) AS fg, MIN(IF(t='Royal', d, NULL)) AS fr, MIN(IF(jk, d, NULL)) AS fj,
    MAX(IF(t='Golden', d, NULL)) AS lg, MAX(IF(t='Royal', d, NULL)) AS lr, MAX(d) AS lf FROM ns GROUP BY 1,2),
fp AS (SELECT b.album_id, b.user_id, MIN(IF(b.sp > 0, DATE_DIFF(b.date_dim, b.c, DAY), NULL)) AS fpd
  FROM b JOIN g ON g.album_id = b.album_id AND g.user_id = b.user_id WHERE b.date_dim >= DATE_SUB(b.c, INTERVAL 14 DAY) GROUP BY 1,2),
u2 AS (SELECT g.album_id, g.user_id, g.grp, fd.fg, fd.fr, fd.fj, fd.lg, fd.lr, fd.lf, fp.fpd FROM g
  LEFT JOIN fd ON fd.album_id = g.album_id AND fd.user_id = g.user_id LEFT JOIN fp ON fp.album_id = g.album_id AND fp.user_id = g.user_id),
lng AS (SELECT album_id, lbl, m, v FROM u2, UNNEST([IF(grp LIKE 'F%', 'F_all', 'N_all'), IF(grp = 'N1', 'N1', NULL)]) AS lbl,
  UNNEST([STRUCT('1st_newG' AS m, fg AS v), STRUCT('1st_newR' AS m, fr AS v), STRUCT('1st_joker' AS m, fj AS v),
          STRUCT('1st_purchase' AS m, fpd AS v), STRUCT('last_newG' AS m, lg AS v), STRUCT('last_newR' AS m, lr AS v),
          STRUCT('finish_day' AS m, IF(grp LIKE 'F%', lf, NULL) AS v)])
  WHERE lbl IS NOT NULL AND (m NOT IN ('last_newG','last_newR','finish_day') OR lbl = 'F_all'))
SELECT album_id, lbl, m, COUNT(*) AS n, ROUND(COUNTIF(v <= -8)/COUNT(*),3) AS s_base, ROUND(COUNTIF(v = -7)/COUNT(*),3) AS s7,
  ROUND(COUNTIF(v = -6)/COUNT(*),3) AS s6, ROUND(COUNTIF(v = -5)/COUNT(*),3) AS s5, ROUND(COUNTIF(v = -4)/COUNT(*),3) AS s4,
  ROUND(COUNTIF(v = -3)/COUNT(*),3) AS s3, ROUND(COUNTIF(v = -2)/COUNT(*),3) AS s2, ROUND(COUNTIF(v = -1)/COUNT(*),3) AS s1,
  ROUND(COUNTIF(v IS NULL)/COUNT(*),3) AS s_none, APPROX_QUANTILES(v, 100)[OFFSET(50)] AS med_d
FROM lng GROUP BY 1,2,3 ORDER BY 1,2,3
```

**Q3 tail (T3, T4, finishing sticker, T5 patterns)**
```sql
, pdays AS (SELECT b.album_id, b.user_id, DATE_DIFF(b.date_dim, b.c, DAY) AS d, b.sp > 0 AS paid
  FROM b JOIN g ON g.album_id = b.album_id AND g.user_id = b.user_id WHERE b.date_dim >= DATE_SUB(b.c, INTERVAL 15 DAY)),
nsl AS (SELECT n.album_id, n.user_id, n.sticker_id, n.t, n.ts, n.d, n.jk, n.ch, n.grp,
    IFNULL(p0.paid, FALSE) AS paid0, IFNULL(p0.paid, FALSE) OR IFNULL(p1.paid, FALSE) AS paid01
  FROM ns n LEFT JOIN pdays p0 ON p0.album_id = n.album_id AND p0.user_id = n.user_id AND p0.d = n.d
  LEFT JOIN pdays p1 ON p1.album_id = n.album_id AND p1.user_id = n.user_id AND p1.d = n.d - 1),
lab AS (SELECT nsl.album_id, nsl.user_id, nsl.sticker_id, nsl.t, nsl.ts, nsl.d, nsl.jk, nsl.ch, nsl.grp, nsl.paid0, nsl.paid01, lbl
  FROM nsl, UNNEST([IF(grp LIKE 'F%', 'F_all', 'N_all'), IF(grp = 'N1', 'N1', NULL)]) AS lbl WHERE lbl IS NOT NULL),
t3 AS (SELECT 'T3_channel_last7' AS section, album_id, lbl, t AS k1, ch AS k2, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, lbl, t), 3) AS share, CAST(NULL AS FLOAT64) AS share2
  FROM lab WHERE d >= -7 GROUP BY 1,2,3,4,5),
t4 AS (SELECT 'T4_paid_day' AS section, album_id, lbl, t AS k1, CONCAT(IF(d >= -7, 'last7', 'base_wk'), IF(jk, '_joker', '_nonjoker')) AS k2, COUNT(*) AS n,
    ROUND(COUNTIF(paid0)/COUNT(*), 3) AS share, ROUND(COUNTIF(paid01)/COUNT(*), 3) AS share2 FROM lab GROUP BY 1,2,3,4,5
  UNION ALL SELECT 'T4_paid_day', album_id, lbl, t, IF(d >= -7, 'last7_all', 'base_wk_all'), COUNT(*),
    ROUND(COUNTIF(paid0)/COUNT(*), 3), ROUND(COUNTIF(paid01)/COUNT(*), 3) FROM lab GROUP BY 1,2,3,4,5),
fin AS (SELECT album_id, user_id, ARRAY_AGG(STRUCT(t, jk, ch, d) ORDER BY ts DESC, sticker_id DESC LIMIT 5) AS l5
  FROM ns WHERE grp LIKE 'F%' GROUP BY 1,2),
fe AS (SELECT f.album_id, f.user_id, e.t, e.jk, e.ch, e.d, o FROM fin f, UNNEST(f.l5) AS e WITH OFFSET o),
last1 AS (SELECT 'T2_finishing_sticker' AS section, album_id, 'F_all' AS lbl, t AS k1, ch AS k2, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 3) AS share, CAST(NULL AS FLOAT64) AS share2
  FROM fe WHERE o = 0 GROUP BY 1,2,3,4,5),
pat AS (SELECT album_id, user_id, STRING_AGG(CONCAT(SUBSTR(t, 1, 1), IF(jk, 'j', '')), '-' ORDER BY o DESC) AS p FROM fe GROUP BY 1,2),
t5 AS (SELECT 'T5_last5_pattern' AS section, album_id, 'F_all' AS lbl, p AS k1, CAST(NULL AS STRING) AS k2, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 3) AS share, CAST(NULL AS FLOAT64) AS share2
  FROM pat GROUP BY 1,2,3,4,5 QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) <= 8),
t5b AS (SELECT 'T5_last5_composition' AS section, album_id, 'F_all' AS lbl, t AS k1, IF(jk, 'joker', 'nonjoker') AS k2, COUNT(*) AS n,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 3) AS share, CAST(NULL AS FLOAT64) AS share2
  FROM fe GROUP BY 1,2,3,4,5)
SELECT section, album_id, lbl, k1, k2, n, share, share2 FROM t3
UNION ALL SELECT section, album_id, lbl, k1, k2, n, share, share2 FROM t4
UNION ALL SELECT section, album_id, lbl, k1, k2, n, share, share2 FROM last1
UNION ALL SELECT section, album_id, lbl, k1, k2, n, share, share2 FROM t5
UNION ALL SELECT section, album_id, lbl, k1, k2, n, share, share2 FROM t5b
ORDER BY 1,2,3,4,6 DESC
```

**Q4: CTEs `ex`, `b`, `pop` and `g` as above, then:**
```sql
, own AS (SELECT s.album_id, s.user_id, s.sticker_id, ANY_VALUE(s.sticker_type) AS t, MIN(s.sticker_collected_min_date) AS dt
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s
  WHERE ((s.album_id = 14 AND s.sticker_collected_min_date BETWEEN '2026-07-13' AND '2026-08-23')
      OR (s.album_id = 15 AND s.sticker_collected_min_date BETWEEN '2026-08-24' AND '2026-10-04'))
    AND s.user_collected_sticker_flag AND s.sticker_type IN ('Common','Golden','Royal') GROUP BY 1,2,3),
cfg AS (SELECT album_id, sticker_id, ANY_VALUE(t) AS t, MIN(dt) AS first_any_user FROM own GROUP BY 1,2),
popown AS (SELECT o.album_id, o.sticker_id, COUNT(*) AS pop_holders_by_dm2, MIN(DATE_DIFF(o.dt, p.c, DAY)) AS first_d_pop
  FROM own o JOIN pop p ON p.album_id = o.album_id AND p.user_id = o.user_id WHERE o.dt <= DATE_SUB(p.c, INTERVAL 2 DAY) GROUP BY 1,2),
npl AS (SELECT album_id, user_id, c, grp FROM g WHERE grp IN ('N1','N23')),
miss AS (SELECT n.album_id, n.user_id, n.grp, c.sticker_id, c.t FROM npl n JOIN cfg c ON c.album_id = n.album_id
  LEFT JOIN own o ON o.album_id = n.album_id AND o.user_id = n.user_id AND o.sticker_id = c.sticker_id AND o.dt < n.c WHERE o.user_id IS NULL),
mu AS (SELECT album_id, user_id, grp, COUNT(*) AS nm, COUNTIF(t='Royal') AS mr, COUNTIF(t='Golden') AS mg, COUNTIF(t='Common') AS mc,
    LOGICAL_OR(sticker_id = 131) AS m131, STRING_AGG(SUBSTR(t,1,1), '+' ORDER BY t DESC) AS combo FROM miss GROUP BY 1,2,3),
mlab AS (SELECT mu.album_id, mu.user_id, mu.nm, mu.mr, mu.mg, mu.mc, mu.m131, mu.combo, lbl
  FROM mu, UNNEST(['N_all', IF(grp = 'N1', 'N1', NULL)]) AS lbl WHERE lbl IS NOT NULL),
s1 AS (SELECT 'A_missing_summary' AS section, album_id, lbl, 'all' AS k1, COUNT(*) AS n, ROUND(AVG(nm),3) AS v1,
    ROUND(COUNTIF(mr > 0)/COUNT(*),3) AS v2, ROUND(COUNTIF(m131)/COUNT(*),3) AS v3, ROUND(SUM(mr)/SUM(nm),3) AS v4,
    ROUND(SUM(mg)/SUM(nm),3) AS v5, ROUND(SUM(mc)/SUM(nm),3) AS v6, CAST(NULL AS INT64) AS v7 FROM mlab GROUP BY 1,2,3,4),
s2 AS (SELECT 'B_combo' AS section, album_id, lbl, combo AS k1, COUNT(*) AS n,
    ROUND(COUNT(*)/SUM(COUNT(*)) OVER (PARTITION BY album_id, lbl),3) AS v1, ROUND(COUNTIF(m131)/COUNT(*),3) AS v2,
    CAST(NULL AS FLOAT64) AS v3, CAST(NULL AS FLOAT64) AS v4, CAST(NULL AS FLOAT64) AS v5, CAST(NULL AS FLOAT64) AS v6, CAST(NULL AS INT64) AS v7
  FROM mlab GROUP BY 1,2,3,4 QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id, lbl ORDER BY COUNT(*) DESC) <= 6),
npop AS (SELECT album_id, COUNT(*) AS n_pop FROM pop GROUP BY 1),
s3 AS (SELECT 'C_top_missing_sticker' AS section, m.album_id, 'N_all' AS lbl, CONCAT(CAST(m.sticker_id AS STRING), ' ', m.t) AS k1, COUNT(*) AS n,
    ROUND(COUNT(*)/ANY_VALUE(nn.n_n),3) AS v1, ROUND(ANY_VALUE(IFNULL(po.pop_holders_by_dm2,0))/ANY_VALUE(np.n_pop),4) AS v2,
    CAST(ANY_VALUE(po.first_d_pop) AS FLOAT64) AS v3,
    CAST(DATE_DIFF(ANY_VALUE(c.first_any_user), IF(m.album_id = 14, DATE '2026-07-13', DATE '2026-08-24'), DAY) + 1 AS FLOAT64) AS v4,
    CAST(NULL AS FLOAT64) AS v5, CAST(NULL AS FLOAT64) AS v6, ANY_VALUE(IFNULL(po.pop_holders_by_dm2,0)) AS v7
  FROM miss m JOIN cfg c ON c.album_id = m.album_id AND c.sticker_id = m.sticker_id
  LEFT JOIN popown po ON po.album_id = m.album_id AND po.sticker_id = m.sticker_id
  JOIN npop np ON np.album_id = m.album_id
  JOIN (SELECT album_id, COUNT(*) AS n_n FROM npl GROUP BY 1) nn ON nn.album_id = m.album_id
  GROUP BY 1,2,3,4 QUALIFY ROW_NUMBER() OVER (PARTITION BY m.album_id ORDER BY COUNT(*) DESC) <= 8)
SELECT section, album_id, lbl, k1, n, v1, v2, v3, v4, v5, v6, v7 FROM s1
UNION ALL SELECT section, album_id, lbl, k1, n, v1, v2, v3, v4, v5, v6, v7 FROM s2
UNION ALL SELECT section, album_id, lbl, k1, n, v1, v2, v3, v4, v5, v6, v7 FROM s3 ORDER BY 1,2,3,5 DESC
```

**Q5 (trio timing)**
```sql
WITH x AS (
  SELECT album_id, sticker_id, DATE_DIFF(sticker_collected_min_date, IF(album_id = 14, DATE '2026-08-24', DATE '2026-10-05'), DAY) AS d, COUNT(*) AS n
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers`
  WHERE ((album_id = 14 AND sticker_collected_min_date BETWEEN '2026-07-13' AND '2026-08-23' AND sticker_id IN (131, 130, 84))
      OR (album_id = 15 AND sticker_collected_min_date BETWEEN '2026-08-24' AND '2026-10-04' AND sticker_id IN (131, 141, 142)))
    AND user_collected_sticker_flag GROUP BY 1,2,3)
SELECT album_id, sticker_id, SUM(IF(d < -14, n, 0)) AS rows_before_dm14, MIN(IF(n >= 1000, d, NULL)) AS first_d_1k,
  STRING_AGG(IF(d >= -14, FORMAT('%d:%d', d, n), NULL), ' ' ORDER BY d) AS daily_last14
FROM x GROUP BY 1,2 ORDER BY 1,2
```

**E1 (source mapping)**
```sql
SELECT album_id, sticker_type AS t, IFNULL(NULLIF(new_sticker_source,''),'(null)') AS src,
  COUNT(DISTINCT CONCAT(user_id,'-',CAST(sticker_id AS STRING))) AS n, ROUND(COUNTIF(collected_by_joker_flag)/COUNT(*),3) AS joker_share
FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers`
WHERE ((album_id=14 AND sticker_collected_min_date BETWEEN '2026-08-10' AND '2026-08-23') OR (album_id=15 AND sticker_collected_min_date BETWEEN '2026-09-21' AND '2026-10-04'))
  AND user_collected_sticker_flag AND sticker_type IN ('Golden','Royal','Common')
GROUP BY 1,2,3 HAVING COUNT(*) >= 100 ORDER BY 1,2,4 DESC
```

**E3 and E4 (USD check)**
```sql
WITH a AS (SELECT user_id, date_dim, SUM(IFNULL(album_spent_today,0)) AS sp FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN '2026-09-21' AND '2026-10-04' AND album_id = 15 AND special_user_flag = FALSE AND date_dim < album_close_date GROUP BY 1,2),
fc AS (SELECT user_id, date_dim AS d, SUM(gross_revenues) AS g, SUM(net_revenues) AS n, SUM(trx_cnt) AS trx, LOGICAL_OR(currency != 'USD') AS non_usd
  FROM `solitaire-dreams-411507.bi_prod.fact_purchase_channels` WHERE date_dim BETWEEN '2026-09-21' AND '2026-10-04' GROUP BY 1,2),
cur AS (SELECT currency, COUNT(*) AS n FROM `solitaire-dreams-411507.bi_prod.fact_purchase_channels` WHERE date_dim BETWEEN '2026-09-21' AND '2026-10-04' GROUP BY 1)
SELECT COUNTIF(a.sp>0) AS pay_days, ROUND(SUM(a.sp),0) AS album_spend, ROUND(SUM(IF(a.sp>0 OR fc.g>0, fc.g, 0)),0) AS channels_gross, ROUND(SUM(fc.n),0) AS channels_net,
  ROUND(SUM(a.sp)/SUM(fc.g),4) AS ratio_gross, ROUND(SUM(a.sp)/SUM(fc.n),4) AS ratio_net,
  ROUND(COUNTIF(a.sp>0 AND ABS(a.sp - IFNULL(fc.g,0)) < 0.05)/COUNTIF(a.sp>0),4) AS share_paydays_exact_gross,
  ROUND(COUNTIF(a.sp>0 AND fc.g IS NULL)/COUNTIF(a.sp>0),4) AS share_paydays_no_channel_row,
  ROUND(COUNTIF(fc.non_usd)/COUNTIF(fc.g IS NOT NULL),4) AS share_rows_non_usd,
  (SELECT STRING_AGG(CONCAT(currency,':',CAST(n AS STRING)) ORDER BY n DESC LIMIT 5) FROM cur) AS currencies
FROM a LEFT JOIN fc ON fc.user_id=a.user_id AND fc.d=a.date_dim;
-- result: ratio_gross 0.9951, exact on 99.1% of pay-days, ratio_net 1.269

SELECT currency, SUM(trx_cnt) AS trx, ROUND(SUM(gross_revenues)/SUM(trx_cnt),2) AS gross_per_trx
FROM `solitaire-dreams-411507.bi_prod.fact_purchase_channels`
WHERE date_dim BETWEEN '2026-09-21' AND '2026-10-04' AND currency IN ('USD','EUR','JPY','GBP','CAD') AND trx_cnt > 0 GROUP BY 1 ORDER BY 2 DESC;
-- USD 11.05, JPY 11.17, CAD 10.66, GBP 8.74, EUR 8.32
```

SQL files are in `/tmp/claude-0/-home-claude/5629d190-2f4d-5652-8298-2143c958a9b2/scratchpad/disney/`: `base2.sql`, `q2.sql`, `q3.sql`, `q4.sql`. `q1.sql` differs slightly from the executed T1 query; the version above is the one that ran.

**Worth saving to memory (for the lead):**
- Disney `album_spent_today` is USD gross revenue (it matches `fact_purchase_channels.gross_revenues` at 0.995).
- Disney's locked trio is Royal 131 + Goldens 84/130 (album 14) or 141/142 (album 15). The Goldens open at d = −7 / −5, and 131 at d = −3.
- No Disney payer finished before close−7, and Joker use starts only from d = −4.
- Disney has no curated timestamped purchase table: `purchase_completed_fix_vw` is blocked by the partition guard.
