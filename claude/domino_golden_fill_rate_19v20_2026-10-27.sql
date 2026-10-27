-- 2026-10-27 (Eden): Goldens / Royals 19 vs 20, normalised: per day d=-10..-1, of the Goldens (Royals) still missing at the end of the previous day,
-- what % got filled that day. Standard-population payers active that day. From user_daily_album lifetime counters (28 Goldens, 9 Royals per album).
-- Also: payers' avg missing Goldens / Royals at the end of d-11 (starting point).
WITH alb AS (
  SELECT 19 AS album_id, DATE '2026-07-06' AS a_start, DATE '2026-08-24' AS a_end UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'),
ud AS (
  SELECT u.album_id, u.user_id, u.date_dim, a.a_end, IFNULL(u.login_ratio,-1) AS lr, IFNULL(u.user_album_count,1) AS uac,
    IFNULL(u.special_user_flag,FALSE) AS excl, IFNULL(u.album_spent_today,0) AS spend, IFNULL(u.active_flag,FALSE) AS act,
    IFNULL(u.unique_golden_stickers_lt,0) AS g, IFNULL(u.unique_royal_stickers_tl,0) AS r
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` u JOIN alb a ON a.album_id = u.album_id AND u.date_dim BETWEEN a.a_start AND a.a_end
  WHERE u.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND u.album_id IN (19, 20)),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
pay AS (
  SELECT a.album_id, a.user_id FROM ud a GROUP BY a.album_id, a.user_id, a.a_end
  HAVING MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(a.a_end, INTERVAL 1 DAY)
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
    AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0),
x AS (
  SELECT u.album_id, DATE_DIFF(u.date_dim, u.a_end, DAY) AS d, u.act, u.g, u.r,
    LAG(u.g) OVER (PARTITION BY u.album_id, u.user_id ORDER BY u.date_dim) AS g0,
    LAG(u.r) OVER (PARTITION BY u.album_id, u.user_id ORDER BY u.date_dim) AS r0
  FROM ud u JOIN pay USING (album_id, user_id)
  WHERE u.user_id NOT IN (SELECT user_id FROM bad) AND DATE_DIFF(u.date_dim, u.a_end, DAY) BETWEEN -12 AND -1)
SELECT album_id, d, COUNTIF(act) AS active_payers,
  ROUND(AVG(IF(act, 28 - g0, NULL)), 2) AS avg_missing_g_start, ROUND(AVG(IF(act, 9 - r0, NULL)), 2) AS avg_missing_r_start,
  ROUND(100 * SUM(IF(act, GREATEST(g - g0, 0), 0)) / NULLIF(SUM(IF(act, 28 - g0, 0)), 0), 1) AS pct_missing_g_filled,
  ROUND(100 * SUM(IF(act, GREATEST(r - r0, 0), 0)) / NULLIF(SUM(IF(act, 9 - r0, 0)), 0), 1) AS pct_missing_r_filled
FROM x WHERE d BETWEEN -10 AND -1 AND g0 IS NOT NULL GROUP BY 1, 2 ORDER BY 1, 2
