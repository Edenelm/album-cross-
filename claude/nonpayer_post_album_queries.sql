-- NOT RUN YET (proposed 2026-10-18): did non-paying finishers start paying after the album? Groups: finisher payer / finisher nonpayer / nonpayer missing 1-10 (control). Revenue = album-table spend column (post days are next-album days) + metrics-table cross-check. RV = ad_revenues from metrics table (only source); ads_watched in Dice only.
-- ===== dice =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim < album_end_date
),
uda AS (SELECT user_id, date_dim, SUM(IFNULL(spent_in_album_today,0)) AS spend FROM `dice-dreams-dbt.50_reporting.user_daily_album` WHERE date_dim BETWEEN DATE '2026-03-01' AND CURRENT_DATE() GROUP BY 1,2),
udm AS (SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(ad_revenues,0) AS adrev, IFNULL(ads_watched,0) AS adw, FALSE AS bad FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-03-01' AND CURRENT_DATE()),
maxd AS (SELECT MAX(date_dim) AS md FROM udm),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
base AS (
  SELECT album_id, user_id, a_start, a_end, uniq FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 134 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cls AS (
  SELECT b.album_id, b.user_id, b.a_start, b.a_end,
    CASE WHEN b.uniq >= 144 AND SUM(u.spend) > 0 THEN '1_finisher_payer'
         WHEN b.uniq >= 144 THEN '2_finisher_nonpayer'
         WHEN SUM(u.spend) = 0 THEN '3_missing1to10_nonpayer' END AS grp
  FROM base b JOIN ud u USING (album_id, user_id) GROUP BY b.album_id, b.user_id, b.a_start, b.a_end, b.uniq
),
w AS (
  SELECT c.album_id, c.user_id, c.grp, c.a_end,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY), a.spend, 0)) AS pre30,
    SUM(IF(a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 6 DAY), a.spend, 0)) AS post7,
    SUM(IF(a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 13 DAY), a.spend, 0)) AS post14,
    SUM(IF(a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 29 DAY), a.spend, 0)) AS post30
  FROM cls c LEFT JOIN uda a ON a.user_id = c.user_id
    AND a.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_ADD(c.a_end, INTERVAL 29 DAY)
  WHERE c.grp IS NOT NULL GROUP BY 1,2,3,4
),
wm AS (
  SELECT c.album_id, c.user_id,
    SUM(IF(m.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 29 DAY), m.rev, 0)) AS post30_m,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY), m.adrev, 0)) AS ad_pre30,
    SUM(IF(m.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY), m.adrev, 0)) AS ad_album,
    SUM(IF(m.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY), m.adw, 0)) AS adw_album,
    SUM(IF(m.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 29 DAY), m.adrev, 0)) AS ad_post30
  FROM cls c LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_ADD(c.a_end, INTERVAL 29 DAY)
  WHERE c.grp IS NOT NULL GROUP BY 1,2
)
SELECT w.album_id, w.grp, COUNT(*) AS n,
  MIN(DATE_DIFF((SELECT md FROM maxd), w.a_end, DAY)) + 1 AS days_after_available,
  ROUND(100 * COUNTIF(pre30 > 0) / COUNT(*), 1) AS pct_paid_pre30,
  ROUND(100 * COUNTIF(post7 > 0) / COUNT(*), 1) AS pct_paid_post7,
  ROUND(100 * COUNTIF(post14 > 0) / COUNT(*), 1) AS pct_paid_post14,
  ROUND(100 * COUNTIF(post30 > 0) / COUNT(*), 1) AS pct_paid_post30,
  ROUND(100 * COUNTIF(pre30 = 0 AND post30 > 0) / NULLIF(COUNTIF(pre30 = 0), 0), 1) AS pct_new_payers_post30,
  ROUND(AVG(pre30), 2) AS avg_pre30,
  ROUND(AVG(post30), 2) AS avg_post30,
  ROUND(APPROX_QUANTILES(IF(post30 > 0, post30, NULL), 2)[OFFSET(1)], 2) AS median_post30_payers,
  ROUND(100 * COUNTIF(wm.post30_m > 0) / COUNT(*), 1) AS pct_paid_post30_metrics,
  ROUND(100 * COUNTIF(ad_pre30 > 0) / COUNT(*), 1) AS pct_rv_pre30,
  ROUND(100 * COUNTIF(ad_album > 0) / COUNT(*), 1) AS pct_rv_album,
  ROUND(AVG(ad_album), 2) AS avg_ad_rev_album,
  ROUND(AVG(adw_album), 1) AS avg_ads_watched_album,
  ROUND(100 * COUNTIF(ad_post30 > 0) / COUNT(*), 1) AS pct_rv_post30,
  ROUND(AVG(ad_post30), 2) AS avg_ad_rev_post30
FROM w JOIN wm USING (album_id, user_id)
GROUP BY 1,2 ORDER BY 1,2

-- ===== domino =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim < album_close_date
),
uda AS (SELECT user_id, date_dim, SUM(IFNULL(album_spent_today,0)) AS spend FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` WHERE date_dim BETWEEN DATE '2026-01-15' AND CURRENT_DATE() GROUP BY 1,2),
udm AS (SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev, IFNULL(ad_revenues,0) AS adrev, CAST(NULL AS INT64) AS adw, IFNULL(suspected_cheater_flag,FALSE) AS bad FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-01-15' AND CURRENT_DATE()),
maxd AS (SELECT MAX(date_dim) AS md FROM udm),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
base AS (
  SELECT album_id, user_id, a_start, a_end, uniq FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 134 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cls AS (
  SELECT b.album_id, b.user_id, b.a_start, b.a_end,
    CASE WHEN b.uniq >= 144 AND SUM(u.spend) > 0 THEN '1_finisher_payer'
         WHEN b.uniq >= 144 THEN '2_finisher_nonpayer'
         WHEN SUM(u.spend) = 0 THEN '3_missing1to10_nonpayer' END AS grp
  FROM base b JOIN ud u USING (album_id, user_id) GROUP BY b.album_id, b.user_id, b.a_start, b.a_end, b.uniq
),
w AS (
  SELECT c.album_id, c.user_id, c.grp, c.a_end,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY), a.spend, 0)) AS pre30,
    SUM(IF(a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 6 DAY), a.spend, 0)) AS post7,
    SUM(IF(a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 13 DAY), a.spend, 0)) AS post14,
    SUM(IF(a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 29 DAY), a.spend, 0)) AS post30
  FROM cls c LEFT JOIN uda a ON a.user_id = c.user_id
    AND a.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_ADD(c.a_end, INTERVAL 29 DAY)
  WHERE c.grp IS NOT NULL GROUP BY 1,2,3,4
),
wm AS (
  SELECT c.album_id, c.user_id,
    SUM(IF(m.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 29 DAY), m.rev, 0)) AS post30_m,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY), m.adrev, 0)) AS ad_pre30,
    SUM(IF(m.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY), m.adrev, 0)) AS ad_album,
    SUM(IF(m.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY), m.adw, 0)) AS adw_album,
    SUM(IF(m.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 29 DAY), m.adrev, 0)) AS ad_post30
  FROM cls c LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_ADD(c.a_end, INTERVAL 29 DAY)
  WHERE c.grp IS NOT NULL GROUP BY 1,2
)
SELECT w.album_id, w.grp, COUNT(*) AS n,
  MIN(DATE_DIFF((SELECT md FROM maxd), w.a_end, DAY)) + 1 AS days_after_available,
  ROUND(100 * COUNTIF(pre30 > 0) / COUNT(*), 1) AS pct_paid_pre30,
  ROUND(100 * COUNTIF(post7 > 0) / COUNT(*), 1) AS pct_paid_post7,
  ROUND(100 * COUNTIF(post14 > 0) / COUNT(*), 1) AS pct_paid_post14,
  ROUND(100 * COUNTIF(post30 > 0) / COUNT(*), 1) AS pct_paid_post30,
  ROUND(100 * COUNTIF(pre30 = 0 AND post30 > 0) / NULLIF(COUNTIF(pre30 = 0), 0), 1) AS pct_new_payers_post30,
  ROUND(AVG(pre30), 2) AS avg_pre30,
  ROUND(AVG(post30), 2) AS avg_post30,
  ROUND(APPROX_QUANTILES(IF(post30 > 0, post30, NULL), 2)[OFFSET(1)], 2) AS median_post30_payers,
  ROUND(100 * COUNTIF(wm.post30_m > 0) / COUNT(*), 1) AS pct_paid_post30_metrics,
  ROUND(100 * COUNTIF(ad_pre30 > 0) / COUNT(*), 1) AS pct_rv_pre30,
  ROUND(100 * COUNTIF(ad_album > 0) / COUNT(*), 1) AS pct_rv_album,
  ROUND(AVG(ad_album), 2) AS avg_ad_rev_album,
  ROUND(AVG(adw_album), 1) AS avg_ads_watched_album,
  ROUND(100 * COUNTIF(ad_post30 > 0) / COUNT(*), 1) AS pct_rv_post30,
  ROUND(AVG(ad_post30), 2) AS avg_ad_rev_post30
FROM w JOIN wm USING (album_id, user_id)
GROUP BY 1,2 ORDER BY 1,2

-- ===== disney =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND album_id IN (12,14,15) AND date_dim < album_close_date
),
uda AS (SELECT user_id, date_dim, SUM(IFNULL(album_spent_today,0)) AS spend FROM `solitaire-dreams-411507.bi_prod.user_daily_album` WHERE date_dim BETWEEN DATE '2026-04-10' AND CURRENT_DATE() GROUP BY 1,2),
udm AS (SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(ad_revenues,0) AS adrev, CAST(NULL AS INT64) AS adw, exclude_reason IS NOT NULL AS bad FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-04-10' AND CURRENT_DATE()),
maxd AS (SELECT MAX(date_dim) AS md FROM udm),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
base AS (
  SELECT album_id, user_id, a_start, a_end, uniq FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 134 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cls AS (
  SELECT b.album_id, b.user_id, b.a_start, b.a_end,
    CASE WHEN b.uniq >= 144 AND SUM(u.spend) > 0 THEN '1_finisher_payer'
         WHEN b.uniq >= 144 THEN '2_finisher_nonpayer'
         WHEN SUM(u.spend) = 0 THEN '3_missing1to10_nonpayer' END AS grp
  FROM base b JOIN ud u USING (album_id, user_id) GROUP BY b.album_id, b.user_id, b.a_start, b.a_end, b.uniq
),
w AS (
  SELECT c.album_id, c.user_id, c.grp, c.a_end,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY), a.spend, 0)) AS pre30,
    SUM(IF(a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 6 DAY), a.spend, 0)) AS post7,
    SUM(IF(a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 13 DAY), a.spend, 0)) AS post14,
    SUM(IF(a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 29 DAY), a.spend, 0)) AS post30
  FROM cls c LEFT JOIN uda a ON a.user_id = c.user_id
    AND a.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_ADD(c.a_end, INTERVAL 29 DAY)
  WHERE c.grp IS NOT NULL GROUP BY 1,2,3,4
),
wm AS (
  SELECT c.album_id, c.user_id,
    SUM(IF(m.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 29 DAY), m.rev, 0)) AS post30_m,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY), m.adrev, 0)) AS ad_pre30,
    SUM(IF(m.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY), m.adrev, 0)) AS ad_album,
    SUM(IF(m.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY), m.adw, 0)) AS adw_album,
    SUM(IF(m.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 29 DAY), m.adrev, 0)) AS ad_post30
  FROM cls c LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_ADD(c.a_end, INTERVAL 29 DAY)
  WHERE c.grp IS NOT NULL GROUP BY 1,2
)
SELECT w.album_id, w.grp, COUNT(*) AS n,
  MIN(DATE_DIFF((SELECT md FROM maxd), w.a_end, DAY)) + 1 AS days_after_available,
  ROUND(100 * COUNTIF(pre30 > 0) / COUNT(*), 1) AS pct_paid_pre30,
  ROUND(100 * COUNTIF(post7 > 0) / COUNT(*), 1) AS pct_paid_post7,
  ROUND(100 * COUNTIF(post14 > 0) / COUNT(*), 1) AS pct_paid_post14,
  ROUND(100 * COUNTIF(post30 > 0) / COUNT(*), 1) AS pct_paid_post30,
  ROUND(100 * COUNTIF(pre30 = 0 AND post30 > 0) / NULLIF(COUNTIF(pre30 = 0), 0), 1) AS pct_new_payers_post30,
  ROUND(AVG(pre30), 2) AS avg_pre30,
  ROUND(AVG(post30), 2) AS avg_post30,
  ROUND(APPROX_QUANTILES(IF(post30 > 0, post30, NULL), 2)[OFFSET(1)], 2) AS median_post30_payers,
  ROUND(100 * COUNTIF(wm.post30_m > 0) / COUNT(*), 1) AS pct_paid_post30_metrics,
  ROUND(100 * COUNTIF(ad_pre30 > 0) / COUNT(*), 1) AS pct_rv_pre30,
  ROUND(100 * COUNTIF(ad_album > 0) / COUNT(*), 1) AS pct_rv_album,
  ROUND(AVG(ad_album), 2) AS avg_ad_rev_album,
  ROUND(AVG(adw_album), 1) AS avg_ads_watched_album,
  ROUND(100 * COUNTIF(ad_post30 > 0) / COUNT(*), 1) AS pct_rv_post30,
  ROUND(AVG(ad_post30), 2) AS avg_ad_rev_post30
FROM w JOIN wm USING (album_id, user_id)
GROUP BY 1,2 ORDER BY 1,2

