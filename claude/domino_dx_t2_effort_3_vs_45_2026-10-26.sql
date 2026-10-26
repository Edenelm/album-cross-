-- 2026-10-26 Domino diagnosis, topic 2 follow-up (Eden): Easy payers at 3 vs 4-5 (vs 1-2, 6-10) missing on close-4, SAME prior spend level.
-- Question: beyond finish rate, did the 3-missing player bring more revenue or put in a different effort in close-3..close-1?
--   And does everyone converge to <=3 missing by close-3 (so effort cannot differ)?
-- Population / level / state: same as domino_dx_t2_within_level_2026-10-25.sql (standard-population payers, Easy only, albums 19 and 20;
--   level = own $ per album day start..close-4; state = missing on close-4, both fixed before the outcome).
-- Per player: $ close-3..close-1 (close day left out), paying days in that window, stickers gained close-4 -> close-1,
--   missing on close-3 / close-2 / close-1 (144 - max unique set stickers up to that day), finished (144 by end of close day).
-- Averages are per player in the cell (all players, finishers or not), plus split finishers / non-finishers.
-- sh_game_rev = cell album spend (start..close-1) / total game purchase revenue in the album (19 = 17,644,426; 20 = 16,269,671).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, album_segment AS seg
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    SUM(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), spend, 0)) AS rev_pre,
    COUNTIF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY)) AS days_pre,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 3 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY), spend, 0)) AS rev_post,
    COUNTIF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 3 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY) AND spend > 0) AS pay_days_post,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS u4,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), uniq, NULL)) AS u3,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 2 DAY), uniq, NULL)) AS u2,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 1 DAY), uniq, NULL)) AS u1,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    ARRAY_AGG(seg IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg0
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, alb_rev, rev_post, pay_days_post, uniq_end >= 144 AS fin,
    144 - u4 AS miss4, 144 - u3 AS miss3, 144 - u2 AS miss2, 144 - u1 AS miss1, u1 - u4 AS gained,
    SAFE_DIVIDE(rev_pre, days_pre) AS pd,
    CASE WHEN LOWER(seg0) LIKE '%easy%' THEN 'easy' ELSE 'other' END AS seg
  FROM u0
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND alb_rev > 0
    AND user_id NOT IN (SELECT user_id FROM bad)
),
b AS (
  SELECT *,
    CASE WHEN miss4 <= 2 THEN '1-2' WHEN miss4 = 3 THEN '3' WHEN miss4 <= 5 THEN '4-5' ELSE '6-10' END AS bucket,
    CASE WHEN pd <= 2 THEN '1_le2' WHEN pd <= 5 THEN '2_2-5' ELSE '3_5-20' END AS lvl,
    IF(album_id = 19, 17644426, 16269671) AS game_rev
  FROM pop WHERE seg = 'easy' AND miss4 > 0 AND miss4 <= 10 AND pd <= 20
)
SELECT album_id, lvl, bucket, COUNT(*) AS payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(game_rev), 4) AS sh_game_rev,
  ROUND(COUNTIF(fin) / COUNT(*), 3) AS fin_rate,
  ROUND(AVG(pd), 2) AS pre_usd_per_day,
  ROUND(AVG(rev_post), 2) AS post_usd_per_player,
  ROUND(AVG(IF(fin, rev_post, NULL)), 2) AS post_usd_finishers,
  ROUND(AVG(IF(NOT fin, rev_post, NULL)), 2) AS post_usd_non_finishers,
  ROUND(COUNTIF(pay_days_post > 0) / COUNT(*), 3) AS sh_paid_post,
  ROUND(AVG(pay_days_post), 2) AS pay_days_post,
  ROUND(AVG(gained), 2) AS stickers_gained,
  ROUND(AVG(miss3), 2) AS avg_miss_c3, ROUND(COUNTIF(miss3 <= 3) / COUNT(*), 3) AS sh_le3_c3,
  ROUND(COUNTIF(miss2 <= 3) / COUNT(*), 3) AS sh_le3_c2,
  ROUND(COUNTIF(miss1 <= 3) / COUNT(*), 3) AS sh_le3_c1
FROM b GROUP BY 1,2,3 ORDER BY 1,2,3
