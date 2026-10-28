-- 2026-10-28 (Eden): which album do the "x% rev · y% payers" labels on slide "Same Spend, Different Gate" belong to?
-- Standard-population payers of album 19 / 20; tier = player's spend in the previous album (18 / 19); % of the album's payers and album revenue per tier.
WITH alb AS (
  SELECT 18 AS album_id, DATE '2026-05-11' AS a_start, DATE '2026-07-06' AS a_end UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'),
ud AS (
  SELECT u.album_id, u.user_id, u.date_dim, a.a_end, IFNULL(u.login_ratio,-1) AS lr, IFNULL(u.user_album_count,1) AS uac,
    IFNULL(u.special_user_flag,FALSE) AS excl, IFNULL(u.album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` u JOIN alb a ON a.album_id = u.album_id AND u.date_dim BETWEEN a.a_start AND a.a_end
  WHERE u.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-12' AND u.album_id IN (18, 19, 20)),
prev AS (SELECT album_id + 1 AS album_id, user_id, SUM(IF(date_dim < a_end, spend, 0)) AS prev_spend FROM ud WHERE album_id IN (18, 19) GROUP BY 1, 2),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
pay AS (
  SELECT a.album_id, a.user_id, SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS rev
  FROM ud a WHERE a.album_id IN (19, 20) GROUP BY a.album_id, a.user_id, a.a_end
  HAVING MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(a.a_end, INTERVAL 1 DAY)
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
    AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0),
t AS (
  SELECT p.album_id, p.rev, IFNULL(v.prev_spend, 0) AS ps FROM pay p LEFT JOIN prev v USING (album_id, user_id)
  WHERE p.user_id NOT IN (SELECT user_id FROM bad))
SELECT album_id,
  CASE WHEN ps < 100 THEN '0 <100' WHEN ps < 200 THEN '1 100-200' WHEN ps < 250 THEN '2 200-250' WHEN ps < 300 THEN '3 250-300'
       WHEN ps < 350 THEN '4 300-350' WHEN ps < 400 THEN '5 350-400' WHEN ps < 600 THEN '6 400-600' WHEN ps < 1000 THEN '7 600-1K' ELSE '8 1K+' END AS tier,
  COUNT(*) AS payers, ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 1) AS pct_payers,
  ROUND(100 * SUM(rev) / SUM(SUM(rev)) OVER (PARTITION BY album_id), 1) AS pct_rev
FROM t GROUP BY 1, 2 ORDER BY 1, 2
