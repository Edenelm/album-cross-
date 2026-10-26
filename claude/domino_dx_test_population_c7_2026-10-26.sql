-- 2026-10-26 Domino diagnosis, slide 4 (test): size of the Easy test population at the proposed assignment time (7 days before close), album 20.
-- Population: standard-population Easy payers (not first album, not excluded, login ratio >= 0.5 on the last row before close, row on close-1, album spend > 0 to close-1).
-- State fixed at the END of close-7 (missing = 144 - unique set stickers). Outcomes: finished (144 by end of close day), $ last 6 days (close-6..close-1), share <=3 missing at close-4.
-- sh_game_rev = album spend (start..close-1) / total game purchase revenue in album 20 (16,269,671).
WITH ud AS (
  SELECT user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, album_segment AS seg
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
u0 AS (
  SELECT user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 6 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY), spend, 0)) AS rev_last6,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 7 DAY), uniq, NULL)) AS u7,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS u4,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    ARRAY_AGG(seg IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg0
  FROM ud GROUP BY 1
),
pop AS (
  SELECT user_id, alb_rev, rev_last6, uniq_end >= 144 AS fin, 144 - u7 AS miss7, 144 - u4 AS miss4
  FROM u0
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND LOWER(seg0) LIKE '%easy%' AND user_id NOT IN (SELECT user_id FROM bad)
)
SELECT CASE WHEN miss7 <= 0 THEN '0_done' WHEN miss7 <= 2 THEN '1_1-2' WHEN miss7 <= 5 THEN '2_3-5' WHEN miss7 <= 8 THEN '3_6-8' WHEN miss7 <= 12 THEN '4_9-12' ELSE '5_13+' END AS miss_c7,
  COUNT(*) AS payers,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (), 3) AS sh_easy_payers,
  ROUND(SUM(alb_rev) / 16269671, 4) AS sh_game_rev,
  ROUND(COUNTIF(fin) / COUNT(*), 3) AS fin_rate,
  ROUND(AVG(rev_last6), 2) AS usd_last6_per_player,
  ROUND(COUNTIF(miss4 <= 3) / COUNT(*), 3) AS sh_le3_at_c4
FROM pop GROUP BY 1 ORDER BY 1
