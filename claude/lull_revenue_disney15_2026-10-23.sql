-- Eden 2026-10-23: burst 1 has higher payout and lower spend — more buyers or less revenue? And who falls behind, how much money they are worth.
-- Disney 15 (solitaire-dreams-411507), standard-population payers (paid any album day incl. close), all players. Daily album table only.
-- Q1 daily: active payers, buyers (spend > 0), revenue, ARPDAU (revenue / active), ARPPU (revenue / buyers), conversion (buyers / active).
-- Q2 by end status (unique stickers on close-1): players, revenue, stickers held at the end of each window, revenue per window.
WITH ud AS (
  SELECT user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, IFNULL(active_flag,FALSE) AS act
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-05' AND album_id = 15 AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS lr_l,
    ARRAY_AGG(IF(date_dim < a_end, uac, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uac_l,
    ARRAY_AGG(IF(date_dim < a_end, excl, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS excl_l,
    ARRAY_AGG(IF(date_dim < a_end, uniq, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1
),
pop AS (
  SELECT u.user_id, a_start, a_end,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end = 143 THEN 'b_miss1' WHEN uniq_end >= 141 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp
  FROM u LEFT JOIN bad_users b ON b.user_id = u.user_id
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND uac_l > 1 AND NOT excl_l AND lr_l >= 0.5 AND rev_c > 0 AND b.user_id IS NULL
),
pd AS (
  SELECT p.grp, d.user_id, DATE_DIFF(d.date_dim, p.a_start, DAY) + 1 AS ad, d.spend, d.act, d.uniq
  FROM ud d JOIN pop p USING (user_id) WHERE d.date_dim < p.a_end
)
SELECT 'daily' AS part, CAST(ad AS STRING) AS k, COUNTIF(act) AS active, COUNTIF(spend > 0) AS buyers, ROUND(SUM(spend)) AS revenue,
  ROUND(SAFE_DIVIDE(SUM(spend), COUNTIF(act)), 2) AS arpdau, ROUND(SAFE_DIVIDE(SUM(spend), COUNTIF(spend > 0)), 2) AS arppu,
  ROUND(SAFE_DIVIDE(COUNTIF(spend > 0), COUNTIF(act)), 4) AS conversion,
  CAST(NULL AS FLOAT64) AS held_d9, CAST(NULL AS FLOAT64) AS held_d13, CAST(NULL AS FLOAT64) AS held_d26, CAST(NULL AS FLOAT64) AS held_d31,
  CAST(NULL AS FLOAT64) AS rev_lull1, CAST(NULL AS FLOAT64) AS rev_burst1, CAST(NULL AS FLOAT64) AS rev_lull2, CAST(NULL AS FLOAT64) AS rev_burst2
FROM pd GROUP BY ad
UNION ALL
SELECT 'group', grp, COUNT(DISTINCT user_id), NULL, ROUND(SUM(spend)), NULL, NULL, NULL,
  ROUND(SAFE_DIVIDE(SUM(IF(ad = 9, uniq, 0)), COUNTIF(ad = 9)), 1), ROUND(SAFE_DIVIDE(SUM(IF(ad = 13, uniq, 0)), COUNTIF(ad = 13)), 1),
  ROUND(SAFE_DIVIDE(SUM(IF(ad = 26, uniq, 0)), COUNTIF(ad = 26)), 1), ROUND(SAFE_DIVIDE(SUM(IF(ad = 31, uniq, 0)), COUNTIF(ad = 31)), 1),
  ROUND(SUM(IF(ad BETWEEN 10 AND 13, spend, 0))), ROUND(SUM(IF(ad BETWEEN 16 AND 19, spend, 0))),
  ROUND(SUM(IF(ad BETWEEN 27 AND 31, spend, 0))), ROUND(SUM(IF(ad BETWEEN 32 AND 35, spend, 0)))
FROM pd GROUP BY grp
ORDER BY part, SAFE_CAST(k AS INT64), k
