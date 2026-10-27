-- 2026-10-27: Domino 20 Easy payers stuck at exactly 3 missing at close vs finishers vs 1-2 missing: weak payers or a problem? (Eden)
-- Population: standard-population payers (as median_missing_at_close_2026-10-25.sql, Domino) + Easy (album_segment on first row).
-- Missing at close = 144 - unique stickers on the close-day row (user_daily_album; Domino updates on close day).
-- Spend level = album spend per album day before the last quarter (days 1..round(0.75*n_days)), cuts 0 / <=2 / 2-5 / 5-20 / >20 (as t5a).
-- First day at <=3 missing = first date with unique >= 141, as days before close. Joker Puzzle tier = max tier completed in jokerpuzzle (28.9-8.10).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, album_segment AS seg,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', 'other') ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    MAX(uniq) AS u_close, MIN(IF(uniq >= 141, date_dim, NULL)) AS d_near,
    SUM(IF(DATE_DIFF(date_dim, a_start, DAY) + 1 <= CAST(ROUND(0.75 * (DATE_DIFF(a_end, a_start, DAY) + 1)) AS INT64), spend, 0)) AS spend_q3,
    CAST(ROUND(0.75 * (DATE_DIFF(ANY_VALUE(a_end), ANY_VALUE(a_start), DAY) + 1)) AS INT64) AS q3_days
  FROM ud GROUP BY 1
),
pop AS (
  SELECT user_id, a_end, alb_rev, u_close, d_near, spend_q3 / q3_days AS dpd FROM u
  WHERE seg0 = 'easy' AND last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
jp AS (
  SELECT user_id, MAX(mini_collection_current_tier) AS jp_tier
  FROM `domino-dreams-dbt.prod_20_core.core_mini_collection_tier_completed`
  WHERE date_dim BETWEEN DATE '2026-09-26' AND DATE '2026-10-12' AND LOWER(mtx_campaign_name) LIKE 'jokerpuzzle%'
  GROUP BY 1
),
x AS (
  SELECT p.*, j.jp_tier,
    CASE WHEN u_close >= 144 THEN 'a finished' WHEN u_close >= 142 THEN 'b 1-2 missing' WHEN u_close = 141 THEN 'c 3 missing' ELSE 'd 4+ missing' END AS grp,
    CASE WHEN dpd = 0 THEN '1 $0' WHEN dpd <= 2 THEN '2 <=2' WHEN dpd <= 5 THEN '3 2-5' WHEN dpd <= 20 THEN '4 5-20' ELSE '5 >20' END AS lvl,
    DATE_DIFF(a_end, d_near, DAY) AS dbc_near
  FROM pop p LEFT JOIN jp j USING (user_id)
)
SELECT grp, lvl, COUNT(*) AS payers, ROUND(SUM(alb_rev)) AS rev,
  ROUND(100*COUNTIF(dbc_near >= 7)/COUNT(*)) AS pct_near_by_c7, ROUND(100*COUNTIF(dbc_near BETWEEN 2 AND 6)/COUNT(*)) AS pct_near_c6_c2,
  ROUND(100*COUNTIF(dbc_near <= 1)/COUNT(*)) AS pct_near_c1_or_close,
  ROUND(100*COUNTIF(jp_tier >= 4)/COUNT(*)) AS pct_jp_tier4plus, ROUND(100*COUNTIF(jp_tier >= 5)/COUNT(*)) AS pct_jp_tier5,
  ROUND(100*COUNTIF(jp_tier IS NULL)/COUNT(*)) AS pct_no_jp
FROM x GROUP BY 1,2 ORDER BY 1,2
