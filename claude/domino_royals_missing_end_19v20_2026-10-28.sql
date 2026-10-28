-- 2026-10-28 (Eden): how much album revenue sits with payers who end missing Royals (esp. 3+), Domino 19 vs 20.
-- Standard-population payers; Royals missing (of 9) at end of close-1 from user_daily_album lifetime counter; album rev = spend before close day.
WITH alb AS (
  SELECT 19 AS album_id, DATE '2026-07-06' AS a_start, DATE '2026-08-24' AS a_end UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'),
ud AS (
  SELECT u.album_id, u.user_id, u.date_dim, a.a_end, IFNULL(u.login_ratio,-1) AS lr, IFNULL(u.user_album_count,1) AS uac,
    IFNULL(u.special_user_flag,FALSE) AS excl, IFNULL(u.album_spent_today,0) AS spend, IFNULL(u.unique_royal_stickers_tl,0) AS r
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` u JOIN alb a ON a.album_id = u.album_id AND u.date_dim BETWEEN a.a_start AND a.a_end
  WHERE u.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND u.album_id IN (19, 20)),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
pay AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS rev,
    MAX(IF(a.date_dim = DATE_SUB(a.a_end, INTERVAL 1 DAY), 9 - a.r, NULL)) AS miss_r
  FROM ud a GROUP BY a.album_id, a.user_id, a.a_end
  HAVING MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(a.a_end, INTERVAL 1 DAY)
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
    AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0)
SELECT album_id, CASE WHEN miss_r >= 3 THEN '3+' ELSE CAST(miss_r AS STRING) END AS royals_missing,
  COUNT(*) AS payers, ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 1) AS pct_payers,
  ROUND(SUM(rev)) AS rev, ROUND(100 * SUM(rev) / SUM(SUM(rev)) OVER (PARTITION BY album_id), 1) AS pct_rev
FROM pay WHERE user_id NOT IN (SELECT user_id FROM bad)
GROUP BY 1, 2 ORDER BY 1, 2
