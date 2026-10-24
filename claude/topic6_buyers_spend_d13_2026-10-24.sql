-- Topic 6 (Eden 2026-10-24): split the return after close into % who buy x spend per buyer, days 1-3 after close only.
-- Population, status (close-1), levels, own pace (album $ a day before the last quarter): as claude/topic6_payout_by_status_2026-10-24.sql.
-- d1_3_vs_pace = spend close+1..+3 (next album, album table) / (3 x own pace) = buyers_share_of_pace x buyer_vs_own_pace (exact identity).
-- pct_bought = % with spend > 0 in days 1-3. buyer_vs_own_pace = buyers' spend / (3 x buyers' own pace). $ per buyer = days 1-3 gross $.
-- Latest album: Dice 63, Domino 20, Disney 15. Results: claude/topic6-buyers-spend-d13-2026-10-24.md

-- ===== DICE 63 (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-09-05' AND album_id = 63 GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.spent_in_album_today,0)) AS rev3, COUNTIF(IFNULL(n.spent_in_album_today,0) > 0) AS pay_days3
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 2
  WHERE n.date_dim BETWEEN DATE '2026-07-28' AND DATE '2026-09-14' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 3 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev3, 0) AS rev3, IFNULL(x.pay_days3, 0) AS pay_days3,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN u.uniq_end >= 144 THEN 'a_finished' WHEN u.uniq_end >= 142 THEN 'b_1_2' WHEN u.uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
agg AS (
  SELECT status, 'all' AS lvl, alb_rev, pace, rev3 FROM t WHERE tier != 't0_0'
  UNION ALL SELECT status, 'l2_20', alb_rev, pace, rev3 FROM t WHERE tier IN ('t2_2_5','t3_5_20'))
SELECT status, lvl, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(SAFE_DIVIDE(SUM(rev3) / 3, SUM(pace)), 3) AS d1_3_vs_pace,
  ROUND(AVG(IF(rev3 > 0, 1, 0)), 3) AS pct_bought,
  ROUND(SAFE_DIVIDE(SUM(IF(rev3 > 0, pace, 0)), SUM(pace)), 3) AS buyers_share_of_pace,
  ROUND(SAFE_DIVIDE(SUM(IF(rev3 > 0, rev3, 0)) / 3, SUM(IF(rev3 > 0, pace, 0))), 3) AS buyer_vs_own_pace,
  ROUND(AVG(IF(rev3 > 0, rev3, NULL)), 1) AS avg_usd_per_buyer,
  ROUND(APPROX_QUANTILES(IF(rev3 > 0, rev3, NULL), 2)[OFFSET(1)], 1) AS med_usd_per_buyer,
  ROUND(AVG(IF(rev3 > 0, pace, NULL)) * 3, 1) AS avg_buyer_pace_usd_3d
FROM agg CROSS JOIN tot GROUP BY 1, 2 ORDER BY 2, 1;

-- ===== DOMINO 20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end, MAX(a.uniq) >= 144 AS cf,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-05' AND album_id = 20 GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.album_spent_today,0)) AS rev3, COUNTIF(IFNULL(n.album_spent_today,0) > 0) AS pay_days3
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 1
  WHERE n.date_dim BETWEEN DATE '2026-08-25' AND DATE '2026-10-19' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 3 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev3, 0) AS rev3, IFNULL(x.pay_days3, 0) AS pay_days3,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN u.uniq_end >= 144 THEN 'a_finished' WHEN u.uniq_end >= 142 THEN 'b_1_2' WHEN u.uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status, u.cf
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
agg AS (
  SELECT status, 'all' AS lvl, alb_rev, pace, rev3 FROM t WHERE tier != 't0_0'
  UNION ALL SELECT status, 'l2_20', alb_rev, pace, rev3 FROM t WHERE tier IN ('t2_2_5','t3_5_20'))
SELECT status, lvl, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(SAFE_DIVIDE(SUM(rev3) / 3, SUM(pace)), 3) AS d1_3_vs_pace,
  ROUND(AVG(IF(rev3 > 0, 1, 0)), 3) AS pct_bought,
  ROUND(SAFE_DIVIDE(SUM(IF(rev3 > 0, pace, 0)), SUM(pace)), 3) AS buyers_share_of_pace,
  ROUND(SAFE_DIVIDE(SUM(IF(rev3 > 0, rev3, 0)) / 3, SUM(IF(rev3 > 0, pace, 0))), 3) AS buyer_vs_own_pace,
  ROUND(AVG(IF(rev3 > 0, rev3, NULL)), 1) AS avg_usd_per_buyer,
  ROUND(APPROX_QUANTILES(IF(rev3 > 0, rev3, NULL), 2)[OFFSET(1)], 1) AS med_usd_per_buyer,
  ROUND(AVG(IF(rev3 > 0, pace, NULL)) * 3, 1) AS avg_buyer_pace_usd_3d
FROM agg CROSS JOIN tot GROUP BY 1, 2 ORDER BY 2, 1;

-- ===== DISNEY 15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id = 15 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end, MAX(a.uniq) >= 144 AS cf,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_close_date) AS a_end FROM `solitaire-dreams-411507.bi_prod.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-05' AND album_id = 15 GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.album_spent_today,0)) AS rev3, COUNTIF(IFNULL(n.album_spent_today,0) > 0) AS pay_days3
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 1
  WHERE n.date_dim BETWEEN DATE '2026-08-25' AND DATE '2026-10-12' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 3 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev3, 0) AS rev3, IFNULL(x.pay_days3, 0) AS pay_days3,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN u.uniq_end >= 144 THEN 'a_finished' WHEN u.uniq_end >= 142 THEN 'b_1_2' WHEN u.uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status, u.cf
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
agg AS (
  SELECT status, 'all' AS lvl, alb_rev, pace, rev3 FROM t WHERE tier != 't0_0'
  UNION ALL SELECT status, 'l2_20', alb_rev, pace, rev3 FROM t WHERE tier IN ('t2_2_5','t3_5_20'))
SELECT status, lvl, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(SAFE_DIVIDE(SUM(rev3) / 3, SUM(pace)), 3) AS d1_3_vs_pace,
  ROUND(AVG(IF(rev3 > 0, 1, 0)), 3) AS pct_bought,
  ROUND(SAFE_DIVIDE(SUM(IF(rev3 > 0, pace, 0)), SUM(pace)), 3) AS buyers_share_of_pace,
  ROUND(SAFE_DIVIDE(SUM(IF(rev3 > 0, rev3, 0)) / 3, SUM(IF(rev3 > 0, pace, 0))), 3) AS buyer_vs_own_pace,
  ROUND(AVG(IF(rev3 > 0, rev3, NULL)), 1) AS avg_usd_per_buyer,
  ROUND(APPROX_QUANTILES(IF(rev3 > 0, rev3, NULL), 2)[OFFSET(1)], 1) AS med_usd_per_buyer,
  ROUND(AVG(IF(rev3 > 0, pace, NULL)) * 3, 1) AS avg_buyer_pace_usd_3d
FROM agg CROSS JOIN tot GROUP BY 1, 2 ORDER BY 2, 1;
