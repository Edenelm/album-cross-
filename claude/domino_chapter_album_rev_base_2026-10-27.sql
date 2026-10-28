-- 2026-10-27: Domino chapter on one base (Eden): share of album revenue of standard-population payers.
-- Standard-population payers as domino_easy_hard_splits_2026-10-26.sql. Album revenue = spend start..close-1. Finished = all stickers (144; album 18: 168) by end of close day.
-- Rows: (a) finishers per album 17-20 (payers): N, % of payers, % of album revenue -> dxsrc;
--       (b) album 20 Easy payers by stickers missing at close-4 -> dxfar; (c) album 20 Easy payers by missing at close-7 -> dxrec / test sizes.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, album_segment AS seg,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND album_id IN (17,18,19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', IF(LOWER(seg) LIKE '%hard%', 'hard', 'other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    MAX(uniq) AS u_close, MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS u4,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 7 DAY), uniq, NULL)) AS u7
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, seg0, alb_rev, u_close, IFNULL(u4,0) AS u4, IFNULL(u7,0) AS u7, IF(album_id = 18, 168, 144) AS n_st FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
t AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM pop GROUP BY 1),
b AS (
  SELECT 'a_finished' AS part, album_id, 'all' AS bucket, user_id, alb_rev FROM pop WHERE u_close >= n_st
  UNION ALL
  SELECT 'b_easy_c4', album_id,
    CASE WHEN n_st - u4 <= 0 THEN '0 done' WHEN n_st - u4 <= 3 THEN '1-3' WHEN n_st - u4 <= 5 THEN '4-5' WHEN n_st - u4 <= 10 THEN '6-10' ELSE '11+' END,
    user_id, alb_rev FROM pop WHERE album_id = 20 AND seg0 = 'easy'
  UNION ALL
  SELECT 'c_easy_c7', album_id,
    CASE WHEN n_st - u7 <= 2 THEN '0-2' WHEN n_st - u7 <= 5 THEN '3-5' WHEN n_st - u7 <= 8 THEN '6-8' WHEN n_st - u7 <= 12 THEN '9-12' ELSE '13+' END,
    user_id, alb_rev FROM pop WHERE album_id = 20 AND seg0 = 'easy'
)
SELECT part, album_id, bucket, COUNT(*) AS players, ROUND(100*COUNT(*)/ANY_VALUE(t.n_all),1) AS pct_payers, ROUND(100*SUM(alb_rev)/ANY_VALUE(t.rev_all),1) AS pct_album_rev
FROM b JOIN t USING (album_id) GROUP BY 1,2,3 ORDER BY 1,2,3
