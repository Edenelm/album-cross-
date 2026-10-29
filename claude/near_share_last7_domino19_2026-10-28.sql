-- 2026-10-28: Domino 19 version of the Domino block of claude/near_share_last7_2026-10-25.sql (same definitions) for slide n19 (Revenue share within 3, Domino 19). Results: claude/near-share-last7-2026-10-25.md (Domino 19 row).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-15' AND album_id = 19 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-15' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.user_id, SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    MAX(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 7 DAY), a.uniq, NULL)) AS u7,
    MAX(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 6 DAY), a.uniq, NULL)) AS u6,
    MAX(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 5 DAY), a.uniq, NULL)) AS u5,
    MAX(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 4 DAY), a.uniq, NULL)) AS u4,
    MAX(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 3 DAY), a.uniq, NULL)) AS u3,
    MAX(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 2 DAY), a.uniq, NULL)) AS u2,
    MAX(IF(a.date_dim <= DATE_SUB(a.a_end, INTERVAL 1 DAY), a.uniq, NULL)) AS u1,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1)
SELECT 'Domino 19' AS g, COUNT(*) AS payers, ROUND(SUM(alb_rev)) AS rev,
  COUNTIF(u7 >= 141) AS n7, ROUND(SUM(IF(u7 >= 141, alb_rev, 0))) AS r7,
  COUNTIF(u6 >= 141) AS n6, ROUND(SUM(IF(u6 >= 141, alb_rev, 0))) AS r6,
  COUNTIF(u5 >= 141) AS n5, ROUND(SUM(IF(u5 >= 141, alb_rev, 0))) AS r5,
  COUNTIF(u4 >= 141) AS n4, ROUND(SUM(IF(u4 >= 141, alb_rev, 0))) AS r4,
  COUNTIF(u3 >= 141) AS n3, ROUND(SUM(IF(u3 >= 141, alb_rev, 0))) AS r3,
  COUNTIF(u2 >= 141) AS n2, ROUND(SUM(IF(u2 >= 141, alb_rev, 0))) AS r2,
  COUNTIF(u1 >= 141) AS n1, ROUND(SUM(IF(u1 >= 141, alb_rev, 0))) AS r1
FROM u WHERE ok;

