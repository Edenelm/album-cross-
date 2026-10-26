-- 2026-10-26 Domino diagnosis, topic 2 follow-up 2 (Eden): among Easy payers at 4-5 missing on close-4 (album 20, gate = 3 joker-only stickers),
-- does reaching <=3 missing by close-3 finish / pay like someone who STARTED at 3?
-- Population, level, close-4 state: as domino_dx_t2_effort_3_vs_45_2026-10-26.sql. Album 20 only (the gate was 5 in album 19, so "3" is not comparable).
-- Groups (state fixed at END of close-3, before the outcome window):
--   A = 3 missing on close-4 (started at the gate); B = 4-5 on close-4 and <=3 on close-3; C = 4-5 on close-4 and still >=4 on close-3.
-- Outcome window close-2..close-1 (close day left out); on close-3 itself we only report whether they paid (how B got there).
-- sh_game_rev = cell album spend (start..close-1) / total game purchase revenue in album 20 (16,269,671).
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
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), spend, 0)) AS rev_pre,
    COUNTIF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY)) AS days_pre,
    SUM(IF(date_dim = DATE_SUB(a_end, INTERVAL 3 DAY), spend, 0)) AS rev_c3,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 2 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY), spend, 0)) AS rev_c21,
    COUNTIF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 2 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY) AND spend > 0) AS pay_days_c21,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS u4,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), uniq, NULL)) AS u3,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    ARRAY_AGG(seg IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg0
  FROM ud GROUP BY 1
),
pop AS (
  SELECT user_id, alb_rev, rev_c3, rev_c21, pay_days_c21, uniq_end >= 144 AS fin,
    144 - u4 AS miss4, 144 - u3 AS miss3, SAFE_DIVIDE(rev_pre, days_pre) AS pd
  FROM u0
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND LOWER(seg0) LIKE '%easy%' AND user_id NOT IN (SELECT user_id FROM bad)
),
b AS (
  SELECT *,
    CASE WHEN miss4 = 3 THEN 'A_start3' WHEN miss3 <= 3 THEN 'B_45_reached3_by_c3' ELSE 'C_45_still4plus_c3' END AS grp,
    CASE WHEN pd <= 2 THEN '1_le2' WHEN pd <= 5 THEN '2_2-5' ELSE '3_5-20' END AS lvl
  FROM pop WHERE miss4 BETWEEN 3 AND 5 AND pd <= 20
)
SELECT lvl, grp, COUNT(*) AS payers,
  ROUND(SUM(alb_rev) / 16269671, 4) AS sh_game_rev,
  ROUND(AVG(pd), 2) AS pre_usd_per_day,
  ROUND(COUNTIF(rev_c3 > 0) / COUNT(*), 3) AS sh_paid_c3,
  ROUND(COUNTIF(fin) / COUNT(*), 3) AS fin_rate,
  ROUND(AVG(rev_c21), 2) AS usd_c2_c1_per_player,
  ROUND(COUNTIF(pay_days_c21 > 0) / COUNT(*), 3) AS sh_paid_c2_c1
FROM b GROUP BY 1,2 ORDER BY 1,2
