-- NOT RUN YET (approved by Eden 2026-10-18): prior-30-day value of finishers, non-payers vs payers. Revenue = daily metrics (all days, incl. non-album players) + album-table cross-check.
-- ===== dice =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-15' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim < album_end_date
),
uda AS (SELECT user_id, date_dim, SUM(IFNULL(spent_in_album_today,0)) AS spend FROM `dice-dreams-dbt.50_reporting.user_daily_album` WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-09-07' GROUP BY 1,2),
udm AS (SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act, FALSE AS bad FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-09-07'),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cls AS (
  SELECT f.album_id, f.user_id, f.a_start, IF(SUM(u.spend) > 0, 'payer', 'nonpayer') AS grp
  FROM fin f JOIN ud u USING (album_id, user_id) GROUP BY 1,2,3
),
pm AS (
  SELECT c.album_id, c.user_id, SUM(IFNULL(m.rev,0)) AS rev_m FROM cls c
  LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY)
  GROUP BY 1,2
),
pa AS (
  SELECT c.album_id, c.user_id, SUM(IFNULL(a.spend,0)) AS rev_a FROM cls c
  LEFT JOIN uda a ON a.user_id = c.user_id AND a.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY)
  GROUP BY 1,2
),
pre AS (SELECT c.album_id, c.user_id, c.grp, pm.rev_m, pa.rev_a FROM cls c JOIN pm USING (album_id, user_id) JOIN pa USING (album_id, user_id))
SELECT album_id, grp, COUNT(*) AS n,
  ROUND(100 * COUNTIF(rev_m > 0) / COUNT(*), 1) AS pct_paid_pre,
  ROUND(AVG(rev_m), 2) AS avg_rev_pre,
  ROUND(APPROX_QUANTILES(IF(rev_m > 0, rev_m, NULL), 2)[OFFSET(1)], 2) AS median_rev_pre_payers,
  ROUND(SUM(rev_m)) AS total_rev_pre,
  ROUND(100 * COUNTIF(rev_m > 0 AND rev_m <= 5) / COUNT(*), 1) AS pct_le5,
  ROUND(100 * COUNTIF(rev_m > 5 AND rev_m <= 20) / COUNT(*), 1) AS pct_5_20,
  ROUND(100 * COUNTIF(rev_m > 20 AND rev_m <= 100) / COUNT(*), 1) AS pct_20_100,
  ROUND(100 * COUNTIF(rev_m > 100) / COUNT(*), 1) AS pct_100p,
  ROUND(100 * COUNTIF(rev_a > 0) / COUNT(*), 1) AS pct_paid_pre_albtbl,
  ROUND(AVG(rev_a), 2) AS avg_rev_pre_albtbl
FROM pre GROUP BY 1,2 ORDER BY 1,2

-- ===== domino =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-02-01' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim < album_close_date
),
uda AS (SELECT user_id, date_dim, SUM(IFNULL(album_spent_today,0)) AS spend FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` WHERE date_dim BETWEEN DATE '2026-01-15' AND DATE '2026-10-12' GROUP BY 1,2),
udm AS (SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev, IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-01-15' AND DATE '2026-10-12'),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cls AS (
  SELECT f.album_id, f.user_id, f.a_start, IF(SUM(u.spend) > 0, 'payer', 'nonpayer') AS grp
  FROM fin f JOIN ud u USING (album_id, user_id) GROUP BY 1,2,3
),
pm AS (
  SELECT c.album_id, c.user_id, SUM(IFNULL(m.rev,0)) AS rev_m FROM cls c
  LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY)
  GROUP BY 1,2
),
pa AS (
  SELECT c.album_id, c.user_id, SUM(IFNULL(a.spend,0)) AS rev_a FROM cls c
  LEFT JOIN uda a ON a.user_id = c.user_id AND a.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY)
  GROUP BY 1,2
),
pre AS (SELECT c.album_id, c.user_id, c.grp, pm.rev_m, pa.rev_a FROM cls c JOIN pm USING (album_id, user_id) JOIN pa USING (album_id, user_id))
SELECT album_id, grp, COUNT(*) AS n,
  ROUND(100 * COUNTIF(rev_m > 0) / COUNT(*), 1) AS pct_paid_pre,
  ROUND(AVG(rev_m), 2) AS avg_rev_pre,
  ROUND(APPROX_QUANTILES(IF(rev_m > 0, rev_m, NULL), 2)[OFFSET(1)], 2) AS median_rev_pre_payers,
  ROUND(SUM(rev_m)) AS total_rev_pre,
  ROUND(100 * COUNTIF(rev_m > 0 AND rev_m <= 5) / COUNT(*), 1) AS pct_le5,
  ROUND(100 * COUNTIF(rev_m > 5 AND rev_m <= 20) / COUNT(*), 1) AS pct_5_20,
  ROUND(100 * COUNTIF(rev_m > 20 AND rev_m <= 100) / COUNT(*), 1) AS pct_20_100,
  ROUND(100 * COUNTIF(rev_m > 100) / COUNT(*), 1) AS pct_100p,
  ROUND(100 * COUNTIF(rev_a > 0) / COUNT(*), 1) AS pct_paid_pre_albtbl,
  ROUND(AVG(rev_a), 2) AS avg_rev_pre_albtbl
FROM pre GROUP BY 1,2 ORDER BY 1,2

-- ===== disney =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-05' AND album_id IN (12,14,15) AND date_dim < album_close_date
),
uda AS (SELECT user_id, date_dim, SUM(IFNULL(album_spent_today,0)) AS spend FROM `solitaire-dreams-411507.bi_prod.user_daily_album` WHERE date_dim BETWEEN DATE '2026-04-10' AND DATE '2026-10-05' GROUP BY 1,2),
udm AS (SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-04-10' AND DATE '2026-10-05'),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cls AS (
  SELECT f.album_id, f.user_id, f.a_start, IF(SUM(u.spend) > 0, 'payer', 'nonpayer') AS grp
  FROM fin f JOIN ud u USING (album_id, user_id) GROUP BY 1,2,3
),
pm AS (
  SELECT c.album_id, c.user_id, SUM(IFNULL(m.rev,0)) AS rev_m FROM cls c
  LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY)
  GROUP BY 1,2
),
pa AS (
  SELECT c.album_id, c.user_id, SUM(IFNULL(a.spend,0)) AS rev_a FROM cls c
  LEFT JOIN uda a ON a.user_id = c.user_id AND a.date_dim BETWEEN DATE_SUB(c.a_start, INTERVAL 30 DAY) AND DATE_SUB(c.a_start, INTERVAL 1 DAY)
  GROUP BY 1,2
),
pre AS (SELECT c.album_id, c.user_id, c.grp, pm.rev_m, pa.rev_a FROM cls c JOIN pm USING (album_id, user_id) JOIN pa USING (album_id, user_id))
SELECT album_id, grp, COUNT(*) AS n,
  ROUND(100 * COUNTIF(rev_m > 0) / COUNT(*), 1) AS pct_paid_pre,
  ROUND(AVG(rev_m), 2) AS avg_rev_pre,
  ROUND(APPROX_QUANTILES(IF(rev_m > 0, rev_m, NULL), 2)[OFFSET(1)], 2) AS median_rev_pre_payers,
  ROUND(SUM(rev_m)) AS total_rev_pre,
  ROUND(100 * COUNTIF(rev_m > 0 AND rev_m <= 5) / COUNT(*), 1) AS pct_le5,
  ROUND(100 * COUNTIF(rev_m > 5 AND rev_m <= 20) / COUNT(*), 1) AS pct_5_20,
  ROUND(100 * COUNTIF(rev_m > 20 AND rev_m <= 100) / COUNT(*), 1) AS pct_20_100,
  ROUND(100 * COUNTIF(rev_m > 100) / COUNT(*), 1) AS pct_100p,
  ROUND(100 * COUNTIF(rev_a > 0) / COUNT(*), 1) AS pct_paid_pre_albtbl,
  ROUND(AVG(rev_a), 2) AS avg_rev_pre_albtbl
FROM pre GROUP BY 1,2 ORDER BY 1,2

