-- Dice supers mechanism one-pager (2026-10-12). Project: dice-dreams-dbt. Albums 61/63. PU (is_album_pu), not excluded, album_login_ratio on last row before close >= 0.5. End state = close-1.

-- Q1 Dice (dice-dreams-dbt) albums 61/63, PU: end-of-album unique-super distribution, spend & finish rate by super bin,
--    and album-wide near-finishers (missing 1-3 of 144) who are missing >= 1 super. End = close-1.
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_login_ratio, a.is_album_pu, a.is_album_finisher,
    a.is_active, IFNULL(a.spent_in_album_today, 0) AS spend, a.unique_super_stickers_lt, a.unique_stickers_lt
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),          -- close date excluded (partial)
pop AS (  -- PU, login ratio on last row before close >= 0.5; end state = close-1
  SELECT album_id, user_id,
    LOGICAL_OR(IFNULL(is_album_finisher, FALSE)) AS finisher,
    MAX(unique_super_stickers_lt) AS supers_end, MAX(unique_stickers_lt) AS stickers_end,
    SUM(spend) AS spend, COUNTIF(is_active) AS act_days
  FROM r GROUP BY 1, 2
  HAVING LOGICAL_OR(IFNULL(is_album_pu, FALSE))
     AND ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5)
, b AS (
  SELECT album_id, user_id, finisher, supers_end, stickers_end, spend, act_days,
    CASE WHEN supers_end <= 6 THEN '0-6' ELSE CAST(supers_end AS STRING) END AS bin,
    144 - stickers_end AS missing_total, 12 - supers_end AS missing_supers
  FROM pop)
SELECT 'bin' AS view, album_id, bin, COUNT(*) AS pu,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS pu_share,
  ROUND(SUM(spend) / SUM(SUM(spend)) OVER (PARTITION BY album_id), 4) AS rev_share,
  ROUND(SUM(spend) / SUM(act_days), 3) AS arpdau,                 -- game revenue on album days / active days
  ROUND(AVG(spend), 2) AS spend_per_pu,
  ROUND(AVG(act_days), 1) AS avg_active_days,
  ROUND(COUNTIF(finisher) / COUNT(*), 4) AS finish_rate
FROM b GROUP BY 1, 2, 3
UNION ALL
SELECT 'all', album_id, 'all', COUNT(*), 1, 1, ROUND(SUM(spend) / SUM(act_days), 3), ROUND(AVG(spend), 2),
  ROUND(AVG(act_days), 1), ROUND(COUNTIF(finisher) / COUNT(*), 4)
FROM b GROUP BY 1, 2, 3
UNION ALL  -- near-finishers album-wide at close-1: missing 1-3 stickers; pu_share = share of them missing >= 1 super
SELECT 'near_finish_1_3', album_id, CONCAT('missing_', CAST(missing_total AS STRING)), COUNT(*),
  ROUND(COUNTIF(missing_supers >= 1) / COUNT(*), 4), NULL, ROUND(SUM(spend) / SUM(act_days), 3), ROUND(AVG(spend), 2),
  ROUND(AVG(act_days), 1), ROUND(COUNTIF(finisher) / COUNT(*), 4)
FROM b WHERE missing_total BETWEEN 1 AND 3 GROUP BY 1, 2, 3
ORDER BY view, album_id, bin
;

-- Q2 Dice (dice-dreams-dbt) albums 61/63, PU: FU-1 / FU-2 sets at close-1 and how many are blocked on a missing Super.
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_login_ratio, a.is_album_pu, a.is_album_finisher,
    a.is_active, IFNULL(a.spent_in_album_today, 0) AS spend, a.unique_super_stickers_lt, a.unique_stickers_lt
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),          -- close date excluded (partial)
pop AS (  -- PU, login ratio on last row before close >= 0.5; end state = close-1
  SELECT album_id, user_id,
    LOGICAL_OR(IFNULL(is_album_finisher, FALSE)) AS finisher,
    MAX(unique_super_stickers_lt) AS supers_end, MAX(unique_stickers_lt) AS stickers_end,
    SUM(spend) AS spend, COUNTIF(is_active) AS act_days
  FROM r GROUP BY 1, 2
  HAVING LOGICAL_OR(IFNULL(is_album_pu, FALSE))
     AND ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5)
, s AS (  -- last set state on or before close-1
  SELECT f.album_id, f.user_id, f.set_id, f.cnt_stickers_to_complete_set AS miss, f.set_missing_super_stickers AS miss_super
  FROM `dice-dreams-dbt.30_intermediate.fact_user_daily_set_progression` f JOIN alb USING (album_id)
  WHERE f.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND f.album_id IN (61, 63) AND f.date_dim < alb.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, f.set_id ORDER BY f.date_dim DESC) = 1),
u AS (
  SELECT p.album_id, p.user_id,
    COUNTIF(s.miss = 1) AS fu1, COUNTIF(s.miss = 1 AND s.miss_super >= 1) AS fu1_super,
    COUNTIF(s.miss = 2) AS fu2, COUNTIF(s.miss = 2 AND s.miss_super >= 1) AS fu2_super
  FROM pop p LEFT JOIN s USING (album_id, user_id) GROUP BY 1, 2)
SELECT album_id, COUNT(*) AS pu,
  COUNTIF(fu1 > 0) AS pu_with_fu1, ROUND(COUNTIF(fu1_super > 0) / NULLIF(COUNTIF(fu1 > 0), 0), 4) AS pct_fu1_pu_blocked_by_super,
  SUM(fu1) AS fu1_sets, ROUND(SUM(fu1_super) / NULLIF(SUM(fu1), 0), 4) AS pct_fu1_sets_missing_super,
  COUNTIF(fu2 > 0) AS pu_with_fu2, ROUND(COUNTIF(fu2_super > 0) / NULLIF(COUNTIF(fu2 > 0), 0), 4) AS pct_fu2_pu_blocked_by_super,
  SUM(fu2) AS fu2_sets, ROUND(SUM(fu2_super) / NULLIF(SUM(fu2), 0), 4) AS pct_fu2_sets_missing_super,
  COUNTIF(fu1 + fu2 > 0) AS pu_with_fu1_or_fu2,
  ROUND(COUNTIF(fu1_super + fu2_super > 0) / NULLIF(COUNTIF(fu1 + fu2 > 0), 0), 4) AS pct_fu12_pu_blocked_by_super
FROM u GROUP BY 1 ORDER BY 1
;

-- Q3 Dice (dice-dreams-dbt) albums 61/63, PU finishers: type of the last 3 stickers collected (first-time collection order),
--    plus how the Supers among them were obtained. Baseline: Supers = 12/144 = 8.3% of set stickers.
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_login_ratio, a.is_album_pu, a.is_album_finisher,
    a.is_active, IFNULL(a.spent_in_album_today, 0) AS spend, a.unique_super_stickers_lt, a.unique_stickers_lt
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),          -- close date excluded (partial)
pop AS (  -- PU, login ratio on last row before close >= 0.5; end state = close-1
  SELECT album_id, user_id,
    LOGICAL_OR(IFNULL(is_album_finisher, FALSE)) AS finisher,
    MAX(unique_super_stickers_lt) AS supers_end, MAX(unique_stickers_lt) AS stickers_end,
    SUM(spend) AS spend, COUNTIF(is_active) AS act_days
  FROM r GROUP BY 1, 2
  HAVING LOGICAL_OR(IFNULL(is_album_pu, FALSE))
     AND ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5)
, st AS (
  SELECT s.album_id, s.user_id, s.sticker_type, s.collected_from_wild, s.sticker_source,
    ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id ORDER BY s.sticker_collected_ts DESC, s.sticker_id DESC) AS rn_from_end
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  JOIN (SELECT album_id, user_id FROM pop WHERE finisher) f USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND s.album_id IN (61, 63)
    AND s.sticker_type IN ('common', 'golden', 'super') AND s.is_sticker_collected),
last3 AS (SELECT album_id, user_id, sticker_type, collected_from_wild, sticker_source, rn_from_end FROM st WHERE rn_from_end <= 3)
SELECT 'type_by_position' AS view, album_id, CAST(rn_from_end AS STRING) AS k, sticker_type AS v, COUNT(*) AS n,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, rn_from_end), 4) AS share
FROM last3 GROUP BY 1, 2, 3, 4, rn_from_end
UNION ALL
SELECT 'type_last3_pooled', album_id, 'all', sticker_type, COUNT(*), ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4)
FROM last3 GROUP BY 1, 2, 3, 4
UNION ALL  -- share of finishers with >= 1 Super among their last 3
SELECT 'finishers_with_super_in_last3', album_id, 'all', 'any_super', COUNT(*), ROUND(COUNTIF(has_super) / COUNT(*), 4)
FROM (SELECT album_id, user_id, LOGICAL_OR(sticker_type = 'super') AS has_super FROM last3 GROUP BY 1, 2) GROUP BY 1, 2, 3, 4
UNION ALL  -- how Supers in the last 3 were obtained
SELECT 'super_last3_source', album_id, IF(collected_from_wild, 'wild', 'not_wild'), IFNULL(sticker_source, 'null'), COUNT(*),
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4)
FROM last3 WHERE sticker_type = 'super' GROUP BY 1, 2, 3, 4
ORDER BY view, album_id, k, n DESC
;

-- Q4 Dice (dice-dreams-dbt) albums 61/63: players 1-2 stickers short entering the last 4 full days (state at end of close-5),
-- split by WHICH sticker type is missing. Outcomes in close-4..close-1 vs their own pre-window baseline.
-- Population: not excluded, album_login_ratio on last row before close >= 0.5. Segments: all players / pre-window payers.
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-07-27' AS a_end UNION ALL SELECT 63, DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.a_end, a.album_login_ratio, a.is_active,
    IFNULL(a.spent_in_album_today, 0) AS spend, a.unique_stickers_lt AS u_all,
    a.unique_super_stickers_lt AS u_s, a.unique_golden_stickers_lt AS u_g
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
gold AS (  -- golden count per album from the max any player reached (cross-check vs 28)
  SELECT album_id, MAX(u_g) AS n_gold FROM r GROUP BY 1),
usr AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 5 DAY), spend, 0)) AS pre_rev,
    COUNTIF(is_active AND date_dim <= DATE_SUB(a_end, INTERVAL 5 DAY)) AS pre_days,
    SUM(IF(date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY), spend, 0)) AS end_rev,
    COUNTIF(is_active AND date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY)) AS end_days,
    COUNTIF(is_active AND date_dim >= DATE_SUB(a_end, INTERVAL 4 DAY) AND spend > 0) AS end_pay_days,
    MAX(u_all) AS u_end
  FROM r GROUP BY 1, 2
  HAVING ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
ent AS (
  SELECT r.album_id, r.user_id, 144 - r.u_all AS miss, 12 - r.u_s AS miss_s, g.n_gold - r.u_g AS miss_g
  FROM r JOIN gold g USING (album_id) WHERE r.date_dim = DATE_SUB(r.a_end, INTERVAL 5 DAY)),
grp AS (
  SELECT u.album_id, u.user_id, u.pre_rev, u.pre_days, u.end_rev, u.end_days, u.end_pay_days, u.u_end,
    e.miss, e.miss_s, e.miss_g, e.miss - e.miss_s - e.miss_g AS miss_c,
    CASE
      WHEN e.miss = 1 AND e.miss_s = 1 THEN '1: Super'
      WHEN e.miss = 1 AND e.miss_g = 1 THEN '1: Golden'
      WHEN e.miss = 1 THEN '1: Common'
      WHEN e.miss = 2 AND e.miss_s = 2 THEN '2: Super+Super'
      WHEN e.miss = 2 AND e.miss_s = 1 AND e.miss_g = 1 THEN '2: Super+Golden'
      WHEN e.miss = 2 AND e.miss_g = 2 THEN '2: Golden+Golden'
      WHEN e.miss = 2 THEN '2: with Common'
    END AS missing
  FROM usr u JOIN ent e USING (album_id, user_id)
  WHERE e.miss IN (1, 2)),
seg AS (
  SELECT album_id, missing, 'all' AS segment, pre_rev, pre_days, end_rev, end_days, end_pay_days, u_end, miss_c FROM grp
  UNION ALL
  SELECT album_id, missing, 'pre_payer', pre_rev, pre_days, end_rev, end_days, end_pay_days, u_end, miss_c FROM grp WHERE pre_rev > 0)
SELECT album_id, segment, missing, COUNT(*) AS players,
  ROUND(SUM(pre_rev) / NULLIF(SUM(pre_days), 0), 2) AS pre_arpdau,
  ROUND(SUM(end_rev) / NULLIF(SUM(end_days), 0), 2) AS end_arpdau,
  ROUND(SAFE_DIVIDE(SUM(end_rev) / NULLIF(SUM(end_days), 0), SUM(pre_rev) / NULLIF(SUM(pre_days), 0)), 2) AS end_vs_pre,
  ROUND(SUM(end_pay_days) / NULLIF(SUM(end_days), 0), 3) AS end_payer_day_rate,
  ROUND(SUM(end_rev) / NULLIF(SUM(end_pay_days), 0), 2) AS end_rev_per_paying_day,
  ROUND(COUNTIF(end_rev > 0) / COUNT(*), 3) AS share_paid_in_end_window,
  ROUND(COUNTIF(u_end >= 144) / COUNT(*), 3) AS finished_by_close_minus_1,
  ROUND(SUM(end_days) / COUNT(*), 2) AS avg_end_active_days,
  COUNTIF(miss_c < 0) AS qa_negative_common
FROM seg GROUP BY 1, 2, 3
ORDER BY album_id, segment, missing
;

-- Q5a (2026-10-12) Golden- vs Super-missers: spend before close-4, last Super timing/source. Project dice-dreams-dbt.
WITH alb AS (
  SELECT 61 AS album_id, TIMESTAMP '2026-06-22 12:00:00' AS a_start_ts, DATE '2026-07-27' AS a_end UNION ALL
  SELECT 63, TIMESTAMP '2026-07-27 12:00:00', DATE '2026-09-07'),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.a_end, alb.a_start_ts, a.album_login_ratio,
    IFNULL(a.spent_in_album_today, 0) AS spend, a.unique_stickers_lt AS u_all,
    a.unique_super_stickers_lt AS u_s, a.unique_golden_stickers_lt AS u_g
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
gold AS (SELECT album_id, MAX(u_g) AS n_gold FROM r GROUP BY 1),
usr AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, ANY_VALUE(a_start_ts) AS a_start_ts,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 5 DAY), spend, 0)) AS pre_rev_uda
  FROM r GROUP BY 1, 2
  HAVING ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
pop AS (  -- missing exactly 1 album sticker at end of close-5
  SELECT u.album_id, u.user_id, u.a_start_ts, u.pre_rev_uda,
    TIMESTAMP(DATE_SUB(u.a_end, INTERVAL 4 DAY)) AS w_start_ts,
    CASE WHEN 12 - e.u_s = 1 THEN 'Super' WHEN g.n_gold - e.u_g = 1 THEN 'Golden' ELSE 'Common' END AS missing
  FROM usr u JOIN r e ON e.album_id = u.album_id AND e.user_id = u.user_id AND e.date_dim = DATE_SUB(u.a_end, INTERVAL 5 DAY)
  JOIN gold g ON g.album_id = u.album_id
  WHERE 144 - e.u_all = 1),
sup AS (  -- Super first-collections before the window
  SELECT p.album_id, p.user_id, s.sticker_collected_ts AS ts, s.collected_from_wild AS wild, s.sticker_source AS src,
    ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id ORDER BY s.sticker_collected_ts DESC, s.sticker_id DESC) AS rn_desc,
    COUNT(*) OVER (PARTITION BY p.album_id, p.user_id) AS n_supers
  FROM pop p JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
    ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63)
    AND s.sticker_type = 'super' AND s.is_sticker_collected AND s.sticker_collected_ts < p.w_start_ts),
lastsup AS (SELECT album_id, user_id, ts AS last_super_ts, wild AS last_super_wild, src AS last_super_src, n_supers FROM sup WHERE rn_desc = 1),
pur AS (  -- purchases in album before the window (deduped)
  SELECT p.album_id, p.user_id, v.timestamp AS ts, v.purchase_amount AS amt, v.source, v.unique_super_stickers AS sup_state
  FROM pop p JOIN `dice-dreams-dbt.20_core.purchase_completed_vw` v ON v.user_id = p.user_id
  WHERE v.pdate BETWEEN DATE '2026-06-22' AND DATE '2026-09-03'
    AND v.timestamp >= p.a_start_ts AND v.timestamp < p.w_start_ts AND v.purchase_amount IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (PARTITION BY v.user_id, v.timestamp, v.external_order_id ORDER BY v.timestamp) = 1),
pl AS (
  SELECT p.album_id, p.user_id, p.missing, p.pre_rev_uda, l.n_supers, l.last_super_wild, l.last_super_src,
    TIMESTAMP_DIFF(p.w_start_ts, l.last_super_ts, HOUR) / 24 AS days_last_super_to_window,
    COUNT(pu.ts) AS n_pur, IFNULL(SUM(pu.amt), 0) AS spend_pre,
    IFNULL(SUM(IF(pu.ts <= l.last_super_ts, pu.amt, 0)), 0) AS spend_until_last_super,
    IFNULL(SUM(IF(pu.ts > l.last_super_ts, pu.amt, 0)), 0) AS spend_after_last_super,
    IFNULL(SUM(IF(pu.sup_state = 11, pu.amt, 0)), 0) AS spend_while_11_supers,
    LOGICAL_OR(pu.ts BETWEEN TIMESTAMP_SUB(l.last_super_ts, INTERVAL 10 MINUTE) AND l.last_super_ts) AS pur_10m_before_last_super,
    LOGICAL_OR(pu.ts BETWEEN TIMESTAMP_SUB(l.last_super_ts, INTERVAL 60 MINUTE) AND l.last_super_ts) AS pur_60m_before_last_super,
    LOGICAL_OR(pu.ts BETWEEN TIMESTAMP_SUB(l.last_super_ts, INTERVAL 60 MINUTE) AND l.last_super_ts
               AND LOWER(pu.source) = LOWER(l.last_super_src)) AS pur_60m_same_source
  FROM pop p LEFT JOIN lastsup l USING (album_id, user_id) LEFT JOIN pur pu USING (album_id, user_id)
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8)
SELECT album_id, missing, COUNT(*) AS players,
  ROUND(AVG(n_supers), 2) AS avg_supers_before_window,
  ROUND(COUNTIF(n_pur > 0) / COUNT(*), 3) AS share_purchased_before_window,
  ROUND(COUNTIF(pre_rev_uda > 0) / COUNT(*), 3) AS share_paid_uda_check,
  ROUND(AVG(spend_pre), 1) AS avg_spend_pre, APPROX_QUANTILES(spend_pre, 100)[OFFSET(50)] AS p50_spend_pre,
  ROUND(AVG(pre_rev_uda), 1) AS avg_spend_pre_uda_check,
  ROUND(AVG(n_pur), 1) AS avg_purchases_pre, APPROX_QUANTILES(n_pur, 100)[OFFSET(50)] AS p50_purchases_pre,
  ROUND(AVG(spend_until_last_super), 1) AS avg_spend_until_last_super,
  ROUND(AVG(spend_after_last_super), 1) AS avg_spend_after_last_super,
  APPROX_QUANTILES(spend_after_last_super, 100)[OFFSET(50)] AS p50_spend_after_last_super,
  ROUND(AVG(spend_while_11_supers), 1) AS avg_spend_while_11_supers,
  ROUND(COUNTIF(spend_while_11_supers > 0) / COUNT(*), 3) AS share_paid_while_11_supers,
  ROUND(APPROX_QUANTILES(days_last_super_to_window, 100)[OFFSET(50)], 1) AS p50_days_last_super_to_window,
  ROUND(COUNTIF(last_super_wild) / COUNT(*), 3) AS share_last_super_via_wild,
  ROUND(COUNTIF(pur_10m_before_last_super) / COUNT(*), 3) AS share_purchase_10m_before_last_super,
  ROUND(COUNTIF(pur_60m_before_last_super) / COUNT(*), 3) AS share_purchase_60m_before_last_super,
  ROUND(COUNTIF(pur_60m_same_source) / COUNT(*), 3) AS share_purchase_60m_same_source
FROM pl GROUP BY 1, 2 ORDER BY 1, 2
;

-- Q5b: purchases before close-4 classified by new stickers first-collected within 10 min after (timing only). Same pop/pur CTEs as Q5a, plus:
-- st = fact_user_album_stickers (common/golden/super, before window); pj = purchase LEFT JOIN st on [ts, ts+10min); class: new Super > new Golden > Common only > none.

