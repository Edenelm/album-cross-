-- Eden 2026-10-24 (story review, item 4 + Dice 65 follow-up): three checks. Results: claude/open-checks-2026-10-24.md
-- A. First-album flag in Domino / Disney: user_album_count (field) vs "no row in an earlier album" (rows), on the standard-population payers
--    (all other filters as usual). Dice was fixed this way on 2026-10-21 (19-22K returning payers were hidden).
-- B. Disney ARPDAU albums 10-15 by albums seen (1 / 2-3 / 4-6 / 7+), then re-weighted to album 10's mix of active days (done in the doc).
-- C. Dice 63 vs 65: daily album spend per payer by days to close, by spend level (topic-5 tiers), standard-population payers.

-- ===== A1. DOMINO 19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end, login_ratio AS lr, IFNULL(user_album_count,1) AS uac,
    IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
hist AS (SELECT user_id, MIN(album_id) AS first_album FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2024-06-01' AND DATE '2026-10-12' AND album_id <= 20 GROUP BY 1),
u AS (
  SELECT album_id, user_id, SUM(IF(date_dim < a_end, spend, 0)) AS rev,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_lr,
    ARRAY_AGG(IF(date_dim < a_end, uac, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_uac,
    ARRAY_AGG(IF(date_dim < a_end, excl, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_excl,
    MAX(IF(date_dim < a_end, date_dim, NULL)) = DATE_SUB(ANY_VALUE(a_end), INTERVAL 1 DAY) AS row_c1, SUM(spend) > 0 AS payer
  FROM ud GROUP BY 1,2),
p AS (SELECT u.album_id, u.rev, u.l_uac > 1 AS past_field, h.first_album < u.album_id AS past_rows
  FROM u JOIN hist h USING (user_id) WHERE u.row_c1 AND NOT u.l_excl AND u.l_lr >= 0.5 AND u.payer AND u.user_id NOT IN (SELECT user_id FROM bad))
SELECT album_id, past_field, past_rows, COUNT(*) AS payers, ROUND(SUM(rev)) AS rev,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS sh_payers, ROUND(SUM(rev) / SUM(SUM(rev)) OVER (PARTITION BY album_id), 4) AS sh_rev
FROM p GROUP BY 1,2,3 ORDER BY 1,2,3;

-- ===== A2. DISNEY 14/15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end, login_ratio AS lr, IFNULL(user_album_count,1) AS uac,
    IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (14,15) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
hist AS (SELECT user_id, MIN(album_id) AS first_album FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2024-01-01' AND DATE '2026-10-12' AND album_id <= 15 GROUP BY 1),
u AS (
  SELECT album_id, user_id, SUM(IF(date_dim < a_end, spend, 0)) AS rev,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_lr,
    ARRAY_AGG(IF(date_dim < a_end, uac, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_uac,
    ARRAY_AGG(IF(date_dim < a_end, excl, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_excl,
    MAX(IF(date_dim < a_end, date_dim, NULL)) = DATE_SUB(ANY_VALUE(a_end), INTERVAL 1 DAY) AS row_c1, SUM(spend) > 0 AS payer
  FROM ud GROUP BY 1,2),
p AS (SELECT u.album_id, u.rev, u.l_uac > 1 AS past_field, h.first_album < u.album_id AS past_rows
  FROM u JOIN hist h USING (user_id) WHERE u.row_c1 AND NOT u.l_excl AND u.l_lr >= 0.5 AND u.payer AND u.user_id NOT IN (SELECT user_id FROM bad))
SELECT album_id, past_field, past_rows, COUNT(*) AS payers, ROUND(SUM(rev)) AS rev,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id), 4) AS sh_payers, ROUND(SUM(rev) / SUM(SUM(rev)) OVER (PARTITION BY album_id), 4) AS sh_rev
FROM p GROUP BY 1,2,3 ORDER BY 1,2,3;

-- ===== B. DISNEY 10-15 ARPDAU by albums seen (solitaire-dreams-411507) =====
-- Population as end_lift_by_experience_full_history.sql: all players who received the album, active days from user_album_start_date,
-- close day excluded, special_user_flag / exclude_reason removed. Albums seen = distinct albums with rows up to and including this one.
WITH excl AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
ua AS (
  SELECT user_id, album_id, MAX(album_close_date) AS a_end FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2024-01-01' AND DATE '2026-10-05' AND album_id <= 15 GROUP BY 1, 2),
nseen AS (SELECT user_id, album_id, COUNT(*) OVER (PARTITION BY user_id ORDER BY album_id) AS n FROM ua),
d AS (
  SELECT x.album_id, IFNULL(x.album_spent_today, 0) AS rev,
    CASE WHEN p.n = 1 THEN 'a_1' WHEN p.n <= 3 THEN 'b_2-3' WHEN p.n <= 6 THEN 'c_4-6' ELSE 'd_7+' END AS grp
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x
  JOIN nseen p ON p.user_id = x.user_id AND p.album_id = x.album_id
  LEFT JOIN excl e ON e.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2025-06-01' AND DATE '2026-10-05' AND x.album_id BETWEEN 10 AND 15
    AND x.date_dim < x.album_close_date AND x.date_dim >= x.user_album_start_date
    AND x.active_flag AND x.special_user_flag = FALSE AND e.user_id IS NULL)
SELECT album_id, grp, COUNT(*) AS act_days, ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / COUNT(*), 4) AS arpdau
FROM d GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== C. DICE 63 vs 65 daily spend by days to close, by spend level (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-10-19' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-19' AND album_id IN (63,65) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
t AS (
  SELECT album_id, user_id,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier
  FROM u WHERE ok),
n AS (SELECT album_id, tier, COUNT(*) AS n FROM t GROUP BY 1,2),
dl AS (
  SELECT d.album_id, t.tier, DATE_DIFF(d.date_dim, d.a_end, DAY) AS dtc, FORMAT_DATE('%a', d.date_dim) AS dow, SUM(d.spend) / ANY_VALUE(n.n) AS spp
  FROM ud d JOIN t USING (album_id, user_id) JOIN n USING (album_id, tier)
  WHERE d.date_dim < d.a_end AND DATE_DIFF(d.date_dim, d.a_end, DAY) >= -21 AND t.tier IN ('t2_2_5', 't3_5_20', 't4_gt20')
  GROUP BY 1, 2, 3, 4)
SELECT tier, album_id, ANY_VALUE(n.n) AS payers, STRING_AGG(FORMAT('%d%s:%.2f', dtc, SUBSTR(dow, 1, 2), spp), ' ' ORDER BY dtc) AS spend_per_payer_by_day,
  ROUND(SUM(IF(dtc >= -4, spp, 0)) / 4, 2) AS avg_last4, ROUND(SUM(IF(dtc BETWEEN -11 AND -5, spp, 0)) / 7, 2) AS avg_d11_5,
  ROUND(SUM(IF(dtc BETWEEN -21 AND -12, spp, 0)) / 10, 2) AS avg_d21_12
FROM dl JOIN n USING (album_id, tier) GROUP BY 1, 2 ORDER BY 1, 2;
