-- 2026-10-27: Domino 20, Easy payers only: stickers held by album day, finishers vs payers who end 4+ away (Eden: gl1_slide design, Easy only).
-- Same rules as gap_by_day_3games_2026-10-24.sql (standard-population payers, finished = 144 on close-1, far = 140 or fewer on close-1) + Easy segment + split by type.
WITH ud AS (
  SELECT user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, album_segment AS seg,
    IFNULL(unique_common_stickers_lt,0) AS uc, IFNULL(unique_golden_stickers_lt,0) AS ug, IFNULL(unique_royal_stickers_tl,0) AS ur,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim < album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end, SUM(a.spend) AS rev,
    ARRAY_AGG(a.uc + a.ug + a.ur ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    ARRAY_AGG(IF(LOWER(a.seg) LIKE '%easy%', 'easy', 'other') ORDER BY a.date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    MAX(a.date_dim) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(a.lr ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(a.uac ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1),
allp AS (SELECT COUNT(*) AS n_all, SUM(rev) AS rev_all FROM u WHERE ok),
s AS (SELECT user_id, a_start, rev, IF(uniq_end >= 144, 'finished', 'far_4plus') AS st FROM u WHERE ok AND seg0 = 'easy' AND (uniq_end >= 144 OR uniq_end <= 140)),
sz AS (SELECT st, COUNT(*) AS n, SUM(rev) AS r FROM s GROUP BY 1)
SELECT DATE_DIFF(d.date_dim, s.a_start, DAY) + 1 AS album_day, s.st, ANY_VALUE(sz.n) AS players,
  ROUND(100*ANY_VALUE(sz.n)/ANY_VALUE(allp.n_all),1) AS pct_payers, ROUND(100*ANY_VALUE(sz.r)/ANY_VALUE(allp.rev_all),1) AS pct_album_rev,
  ROUND(AVG(d.uc + d.ug + d.ur), 1) AS avg_all, ROUND(AVG(d.uc), 1) AS avg_common, ROUND(AVG(d.ug), 2) AS avg_golden, ROUND(AVG(d.ur), 2) AS avg_royal
FROM s JOIN ud d USING (user_id) JOIN sz USING (st) CROSS JOIN allp GROUP BY 1, 2 ORDER BY 1, 2
