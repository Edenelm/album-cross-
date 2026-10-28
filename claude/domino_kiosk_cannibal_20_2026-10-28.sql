-- 2026-10-28 (Eden): did GoldenKiosk (album 20, d-7..d-5) replace Golden purchases / spend?
-- Standard-population payers album 20. Kiosk user = got a new Golden from GoldenKiosk on d-7..d-5.
-- Spend per day in three windows: pre d-14..d-8 (7 days), kiosk d-7..d-5 (3), end d-4..d-1 (4). Close day out.
-- Compared within spend tiers fixed BEFORE the kiosk (avg spend/day d-14..d-8): 0, <2, 2-20, 20+. Own-baseline ratio = window / pre.
-- Also: share who bought a new Golden (paid source) in kiosk window. Correlation, no control group: Kiosk users chose to use it.
WITH alb AS (SELECT MAX(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
             WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND album_id = 20),
ud AS (
  SELECT u.user_id, u.date_dim, u.album_close_date AS a_end, DATE_DIFF(u.date_dim, u.album_close_date, DAY) AS d,
    u.login_ratio AS lr, IFNULL(u.user_album_count,1) > 1 AS past, IFNULL(u.special_user_flag,FALSE) AS excl, IFNULL(u.album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` u
  WHERE u.date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND u.album_id = 20 AND u.date_dim <= u.album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c, SUM(IF(d < 0, spend, 0)) AS rev,
    SUM(IF(d BETWEEN -14 AND -8, spend, 0)) / 7 AS pre, SUM(IF(d BETWEEN -7 AND -5, spend, 0)) / 3 AS kio, SUM(IF(d BETWEEN -4 AND -1, spend, 0)) / 4 AS fin,
    ARRAY_AGG(IF(d < 0, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l, MAX(IF(d < 0, d, NULL)) AS last_d
  FROM ud GROUP BY 1
),
pop AS (SELECT * FROM u WHERE last_d = -1 AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0 AND user_id NOT IN (SELECT user_id FROM bad_users)),
st AS (
  SELECT s.user_id, DATE_DIFF(s.sticker_collected_min_date, a.a_end, DAY) AS d, IFNULL(s.new_sticker_mtx_campaign_name, s.new_sticker_source) AS offer, s.new_sticker_source AS src
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s CROSS JOIN alb a
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND s.album_id = 20 AND s.user_collected_sticker_flag
    AND LOWER(s.sticker_type) = 'golden'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
k AS (SELECT user_id,
        LOGICAL_OR(d BETWEEN -7 AND -5 AND offer LIKE 'GoldenKiosk%') AS kiosk,
        LOGICAL_OR(d BETWEEN -7 AND -5 AND ((offer LIKE '%t_Offer%' AND NOT REGEXP_CONTAINS(offer, r'SeasonPass|DreamPass|Info|ecn_Rewa')) OR offer LIKE '%t_Store%' OR src = 'purchase' OR src LIKE '1+%')) AS bought_k
      FROM st GROUP BY 1),
x AS (SELECT p.*, IFNULL(k.kiosk, FALSE) AS kiosk, IFNULL(k.bought_k, FALSE) AS bought_k,
        CASE WHEN pre = 0 THEN '1 $0' WHEN pre < 2 THEN '2 <$2' WHEN pre < 20 THEN '3 $2-20' ELSE '4 $20+' END AS tier
      FROM pop p LEFT JOIN k USING (user_id))
SELECT tier, kiosk, COUNT(*) AS payers, ROUND(100 * SUM(rev) / SUM(SUM(rev)) OVER (), 1) AS pct_rev,
  ROUND(AVG(pre), 2) AS pre_day, ROUND(AVG(kio), 2) AS kiosk_day, ROUND(AVG(fin), 2) AS end_day,
  ROUND(SUM(kio) / NULLIF(SUM(pre), 0), 2) AS kio_vs_pre, ROUND(SUM(fin) / NULLIF(SUM(pre), 0), 2) AS end_vs_pre,
  ROUND(100 * AVG(IF(bought_k, 1, 0)), 1) AS pct_bought_golden_k
FROM x GROUP BY 1, 2 ORDER BY 1, 2;
