-- 2026-10-27: Domino 19 vs 20 end status by segment (Easy / Hard). Hard gate = 3 stickers in both albums, Easy 5 -> 3:
-- if Hard also improved, the gate size alone does not explain the 19->20 gain.
-- Standard-population payers (as domino_easy_hard_splits_2026-10-26.sql). Finished = 144 unique stickers by end of close day (last row);
-- far = 4+ missing on close-1. Album revenue = spend start..close-1.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, album_segment AS seg,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', IF(LOWER(seg) LIKE '%hard%', 'hard', 'other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    MAX(uniq) AS u_close, MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 1 DAY), uniq, NULL)) AS u1,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS u4
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, seg0, alb_rev, u_close, u1, u4 FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
t AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM pop GROUP BY 1)
SELECT p.album_id, p.seg0, COUNT(*) AS payers, ROUND(100*COUNT(*)/ANY_VALUE(t.n_all)) AS pct_payers, ROUND(100*SUM(alb_rev)/ANY_VALUE(t.rev_all)) AS pct_rev,
  ROUND(100*COUNTIF(u_close >= 144)/COUNT(*),1) AS pct_finished,
  ROUND(100*COUNTIF(u4 <= 140)/COUNT(*),1) AS pct_far_c4,
  ROUND(100*COUNTIF(u1 <= 140)/COUNT(*),1) AS pct_far_c1,
  ROUND(100*SUM(IF(u1 <= 140, alb_rev, 0))/ANY_VALUE(t.rev_all),1) AS far_c1_pct_album_rev
FROM pop p JOIN t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
