-- 2026-10-27 (Eden): GoldenKiosk (album 20, ds 10-05 / de 10-06, first stickers dated 10-05..10-07) on the standard population.
-- Population: standard-population payers (not first album, not excluded/cheater, login ratio >= 0.5 on last row before close, row on close-1, paid on any album day incl. close), Easy + Hard (segment on first row).
-- Kiosk sticker = first collection with new_sticker_mtx_campaign_name LIKE 'GoldenKiosk%'. Closed a set = kiosk sticker is the 12th (last) collected sticker of its set.
-- State before = missing at the end of 10-04 (user_daily_album row). Finished = 144 by end of close day. Album revenue = spend open..close-1 (album table).
WITH ud AS (
  SELECT user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, album_segment AS seg,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', 'hard') ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    MAX(uniq) AS u_close, MAX(IF(date_dim <= DATE '2026-10-04', uniq, NULL)) AS u_before
  FROM ud GROUP BY 1
),
pop AS (
  SELECT user_id, seg0, alb_rev, u_close, IFNULL(u_before,0) AS u_before FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
st AS (
  SELECT user_id, set_id, sticker_type, sticker_collected_min_ts AS ts, LOWER(new_sticker_mtx_campaign_name) LIKE 'goldenkiosk%' AS kiosk
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers`
  WHERE sticker_collected_min_date BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20
),
st2 AS (
  SELECT user_id, sticker_type, kiosk,
    COUNT(*) OVER (PARTITION BY user_id, set_id) AS n_set,
    ROW_NUMBER() OVER (PARTITION BY user_id, set_id ORDER BY ts) AS rn
  FROM st
),
k AS (
  SELECT user_id, COUNTIF(kiosk AND sticker_type = 'Golden') AS k_g, COUNTIF(kiosk AND sticker_type = 'Royal') AS k_r,
    COUNTIF(kiosk AND sticker_type = 'Common') AS k_c, COUNTIF(kiosk AND rn = 12 AND n_set = 12) AS k_closed
  FROM st2 WHERE kiosk GROUP BY 1
),
x AS (
  SELECT p.*, IFNULL(k.k_g,0) AS k_g, IFNULL(k.k_r,0) AS k_r, IFNULL(k.k_c,0) AS k_c, IFNULL(k.k_closed,0) AS k_closed,
    CASE WHEN 144 - u_before <= 0 THEN '0 done' WHEN 144 - u_before <= 3 THEN '1 1-3' WHEN 144 - u_before <= 5 THEN '2 4-5'
         WHEN 144 - u_before <= 10 THEN '3 6-10' ELSE '4 11+' END AS before_grp
  FROM pop p LEFT JOIN k USING (user_id)
)
SELECT seg0, before_grp, (k_g + k_r) > 0 AS got_kiosk_rare,
  COUNT(*) AS payers, ROUND(SUM(alb_rev)) AS rev,
  SUM(k_g) AS goldens, SUM(k_r) AS royals, SUM(k_c) AS commons, SUM(k_closed) AS sets_closed,
  COUNTIF(u_close >= 144) AS finished, COUNTIF(u_close >= 141) AS reached_fu_by_close
FROM x GROUP BY 1,2,3 ORDER BY 1,2,3
