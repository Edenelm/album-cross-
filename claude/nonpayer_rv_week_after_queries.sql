-- RUN 2026-10-18 (Eden narrowed scope): finishers payer/nonpayer — (1) RV (ad revenue, metrics table) during album days, (2) paid in the 7 days from close (album-table spend).
-- ===== dice =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim < album_end_date
),
uda AS (SELECT user_id, date_dim, SUM(IFNULL(spent_in_album_today,0)) AS spend FROM `dice-dreams-dbt.50_reporting.user_daily_album` WHERE date_dim BETWEEN DATE '2026-03-15' AND CURRENT_DATE() GROUP BY 1,2),
udm AS (SELECT user_id, date_dim, IFNULL(ad_revenues,0) AS adrev, IFNULL(ads_watched,0) AS adw, FALSE AS bad FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-03-15' AND CURRENT_DATE()),
maxd AS (SELECT MAX(date_dim) AS md FROM uda),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cls AS (
  SELECT f.album_id, f.user_id, f.a_start, f.a_end, IF(SUM(u.spend) > 0, 'payer', 'nonpayer') AS grp
  FROM fin f JOIN ud u USING (album_id, user_id) GROUP BY 1,2,3,4
),
rv AS (
  SELECT c.album_id, c.user_id, SUM(m.adrev) AS ad_album, SUM(m.adw) AS adw_album, COUNTIF(m.adrev > 0) AS rv_days
  FROM cls c LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
wk AS (
  SELECT c.album_id, c.user_id, SUM(IFNULL(a.spend,0)) AS post7
  FROM cls c LEFT JOIN uda a ON a.user_id = c.user_id AND a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 6 DAY)
  GROUP BY 1,2
)
SELECT c.album_id, c.grp, COUNT(*) AS n,
  MIN(DATE_DIFF((SELECT md FROM maxd), c.a_end, DAY)) + 1 AS days_after_available,
  ROUND(100 * COUNTIF(IFNULL(ad_album,0) > 0) / COUNT(*), 1) AS pct_rv_album,
  ROUND(AVG(IFNULL(ad_album,0)), 2) AS avg_ad_rev_album,
  ROUND(AVG(rv_days), 1) AS avg_rv_days,
  ROUND(AVG(adw_album), 1) AS avg_ads_watched_album,
  ROUND(100 * COUNTIF(post7 > 0) / COUNT(*), 1) AS pct_paid_week_after,
  ROUND(AVG(post7), 2) AS avg_rev_week_after
FROM cls c JOIN rv USING (album_id, user_id) JOIN wk USING (album_id, user_id)
GROUP BY 1,2 ORDER BY 1,2

-- ===== domino =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim < album_close_date
),
uda AS (SELECT user_id, date_dim, SUM(IFNULL(album_spent_today,0)) AS spend FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` WHERE date_dim BETWEEN DATE '2026-02-01' AND CURRENT_DATE() GROUP BY 1,2),
udm AS (SELECT user_id, date_dim, IFNULL(ad_revenues,0) AS adrev, CAST(NULL AS INT64) AS adw, IFNULL(suspected_cheater_flag,FALSE) AS bad FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-02-01' AND CURRENT_DATE()),
maxd AS (SELECT MAX(date_dim) AS md FROM uda),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cls AS (
  SELECT f.album_id, f.user_id, f.a_start, f.a_end, IF(SUM(u.spend) > 0, 'payer', 'nonpayer') AS grp
  FROM fin f JOIN ud u USING (album_id, user_id) GROUP BY 1,2,3,4
),
rv AS (
  SELECT c.album_id, c.user_id, SUM(m.adrev) AS ad_album, SUM(m.adw) AS adw_album, COUNTIF(m.adrev > 0) AS rv_days
  FROM cls c LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
wk AS (
  SELECT c.album_id, c.user_id, SUM(IFNULL(a.spend,0)) AS post7
  FROM cls c LEFT JOIN uda a ON a.user_id = c.user_id AND a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 6 DAY)
  GROUP BY 1,2
)
SELECT c.album_id, c.grp, COUNT(*) AS n,
  MIN(DATE_DIFF((SELECT md FROM maxd), c.a_end, DAY)) + 1 AS days_after_available,
  ROUND(100 * COUNTIF(IFNULL(ad_album,0) > 0) / COUNT(*), 1) AS pct_rv_album,
  ROUND(AVG(IFNULL(ad_album,0)), 2) AS avg_ad_rev_album,
  ROUND(AVG(rv_days), 1) AS avg_rv_days,
  ROUND(AVG(adw_album), 1) AS avg_ads_watched_album,
  ROUND(100 * COUNTIF(post7 > 0) / COUNT(*), 1) AS pct_paid_week_after,
  ROUND(AVG(post7), 2) AS avg_rev_week_after
FROM cls c JOIN rv USING (album_id, user_id) JOIN wk USING (album_id, user_id)
GROUP BY 1,2 ORDER BY 1,2

-- ===== disney =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND album_id IN (12,14,15) AND date_dim < album_close_date
),
uda AS (SELECT user_id, date_dim, SUM(IFNULL(album_spent_today,0)) AS spend FROM `solitaire-dreams-411507.bi_prod.user_daily_album` WHERE date_dim BETWEEN DATE '2026-05-01' AND CURRENT_DATE() GROUP BY 1,2),
udm AS (SELECT user_id, date_dim, IFNULL(ad_revenues,0) AS adrev, CAST(NULL AS INT64) AS adw, exclude_reason IS NOT NULL AS bad FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-05-01' AND CURRENT_DATE()),
maxd AS (SELECT MAX(date_dim) AS md FROM uda),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cls AS (
  SELECT f.album_id, f.user_id, f.a_start, f.a_end, IF(SUM(u.spend) > 0, 'payer', 'nonpayer') AS grp
  FROM fin f JOIN ud u USING (album_id, user_id) GROUP BY 1,2,3,4
),
rv AS (
  SELECT c.album_id, c.user_id, SUM(m.adrev) AS ad_album, SUM(m.adw) AS adw_album, COUNTIF(m.adrev > 0) AS rv_days
  FROM cls c LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
wk AS (
  SELECT c.album_id, c.user_id, SUM(IFNULL(a.spend,0)) AS post7
  FROM cls c LEFT JOIN uda a ON a.user_id = c.user_id AND a.date_dim BETWEEN c.a_end AND DATE_ADD(c.a_end, INTERVAL 6 DAY)
  GROUP BY 1,2
)
SELECT c.album_id, c.grp, COUNT(*) AS n,
  MIN(DATE_DIFF((SELECT md FROM maxd), c.a_end, DAY)) + 1 AS days_after_available,
  ROUND(100 * COUNTIF(IFNULL(ad_album,0) > 0) / COUNT(*), 1) AS pct_rv_album,
  ROUND(AVG(IFNULL(ad_album,0)), 2) AS avg_ad_rev_album,
  ROUND(AVG(rv_days), 1) AS avg_rv_days,
  ROUND(AVG(adw_album), 1) AS avg_ads_watched_album,
  ROUND(100 * COUNTIF(post7 > 0) / COUNT(*), 1) AS pct_paid_week_after,
  ROUND(AVG(post7), 2) AS avg_rev_week_after
FROM cls c JOIN rv USING (album_id, user_id) JOIN wk USING (album_id, user_id)
GROUP BY 1,2 ORDER BY 1,2

