-- Finish rate and revenue share by payer strength percentile (2026-10-21, Eden). Results: claude/strength-percentile-2026-10-21.md
-- Strength = $ per active day from album start to the START OF THE LAST QUARTER (q4 = a_start + floor(0.75 * album days)), album-table spend,
--   active days from the daily album table (Dice is_active, Domino / Disney active_flag). Measured before the end, so it is not inflated by end buying.
-- Population: standard population payers (album-table spend > 0, start..close-1). Finisher = 144 unique set stickers by the end of the close day.
-- Buckets among payers with strength > 0: deciles d1..d9 (10% each, up to p90), p90-95, p95-99, p99+; payers with no spend before q4 = '00_zero'.
-- sh_game_rev = bucket's album spend / total game purchase revenue during the album (all players, cheaters / test excluded).

-- ===== DICE 61/63 (dice-dreams-dbt) =====
WITH alb AS (SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end UNION ALL SELECT 63, DATE '2026-07-27', DATE '2026-09-07'),
tgt AS (SELECT album_id, a_start, a_end, DATE_ADD(a_start, INTERVAL CAST(FLOOR(0.75 * DATE_DIFF(a_end, a_start, DAY)) AS INT64) DAY) AS q4 FROM alb),
ud AS (
  SELECT album_id, user_id, date_dim,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, IFNULL(is_active, FALSE) AS act
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND album_id IN (61,63) AND date_dim < album_end_date
),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN tgt t USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= t.a_end
  GROUP BY 1,2
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06'
),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
tot AS (
  SELECT t.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN tgt t ON m.date_dim BETWEEN t.a_start AND DATE_SUB(t.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM excl)
  GROUP BY 1
),
u0 AS (
  SELECT u.album_id, u.user_id, MAX(u.uniq) AS uniq_prev, SUM(u.spend) AS alb_rev,
    SUM(IF(u.date_dim < t.q4, u.spend, 0)) AS q_rev, COUNTIF(u.act AND u.date_dim < t.q4) AS q_days, MAX(u.date_dim) AS last_d,
    ARRAY_AGG(STRUCT(u.lr, u.past, u.excl) ORDER BY u.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud u JOIN tgt t USING (album_id) GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, uniq_prev, alb_rev, q_rev, q_days, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT u.album_id, u.user_id, u.alb_rev, IFNULL(SAFE_DIVIDE(u.q_rev, u.q_days), 0) AS strength,
    GREATEST(IFNULL(s.n_uniq, 0), IFNULL(u.uniq_prev, 0)) >= 144 AS fin
  FROM u1 u JOIN tgt t USING (album_id) LEFT JOIN st s USING (album_id, user_id)
  WHERE u.last_d = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
),
rk AS (SELECT album_id, alb_rev, fin, strength, PERCENT_RANK() OVER (PARTITION BY album_id, strength > 0 ORDER BY strength) AS pr FROM pop),
b AS (
  SELECT album_id, alb_rev, fin, strength,
    CASE WHEN strength = 0 THEN '00_zero' WHEN pr < 0.1 THEN '01_d1' WHEN pr < 0.2 THEN '02_d2' WHEN pr < 0.3 THEN '03_d3' WHEN pr < 0.4 THEN '04_d4'
         WHEN pr < 0.5 THEN '05_d5' WHEN pr < 0.6 THEN '06_d6' WHEN pr < 0.7 THEN '07_d7' WHEN pr < 0.8 THEN '08_d8' WHEN pr < 0.9 THEN '09_d9'
         WHEN pr < 0.95 THEN '10_p90_95' WHEN pr < 0.99 THEN '11_p95_99' ELSE '12_p99' END AS bucket
  FROM rk
)
SELECT b.album_id, b.bucket, COUNT(*) AS n, ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY b.album_id), 4) AS sh_payers,
  ROUND(MIN(b.strength), 2) AS min_pd, ROUND(MAX(b.strength), 2) AS max_pd,
  COUNTIF(b.fin) AS finishers, ROUND(COUNTIF(b.fin) / COUNT(*), 4) AS fin_rate,
  ROUND(SUM(b.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev, ROUND(SUM(IF(b.fin, b.alb_rev, 0)) / ANY_VALUE(t.game_rev), 4) AS fin_sh_game_rev
FROM b JOIN tot t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH alb AS (SELECT 19 AS album_id, DATE '2026-07-06' AS a_start, DATE '2026-08-24' AS a_end UNION ALL SELECT 20, DATE '2026-08-24', DATE '2026-10-12'),
tgt AS (SELECT album_id, a_start, a_end, DATE_ADD(a_start, INTERVAL CAST(FLOOR(0.75 * DATE_DIFF(a_end, a_start, DAY)) AS INT64) DAY) AS q4 FROM alb),
ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    IFNULL(active_flag, FALSE) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(special_user_flag,FALSE) OR IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
tot AS (
  SELECT t.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN tgt t ON m.date_dim BETWEEN t.a_start AND DATE_SUB(t.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1
),
u0 AS (
  SELECT u.album_id, u.user_id, MAX(u.uniq) AS uniq_close, SUM(IF(u.date_dim < u.a_end, u.spend, 0)) AS alb_rev,
    SUM(IF(u.date_dim < t.q4, u.spend, 0)) AS q_rev, COUNTIF(u.act AND u.date_dim < t.q4) AS q_days,
    MAX(IF(u.date_dim < u.a_end, u.date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(u.date_dim < u.a_end, STRUCT(u.lr, u.past, u.excl), NULL) IGNORE NULLS ORDER BY u.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud u JOIN tgt t USING (album_id) GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, uniq_close, alb_rev, q_rev, q_days, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT u.album_id, u.user_id, u.alb_rev, IFNULL(SAFE_DIVIDE(u.q_rev, u.q_days), 0) AS strength, u.uniq_close >= 144 AS fin
  FROM u1 u JOIN tgt t USING (album_id)
  WHERE u.last_d = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
rk AS (SELECT album_id, alb_rev, fin, strength, PERCENT_RANK() OVER (PARTITION BY album_id, strength > 0 ORDER BY strength) AS pr FROM pop),
b AS (
  SELECT album_id, alb_rev, fin, strength,
    CASE WHEN strength = 0 THEN '00_zero' WHEN pr < 0.1 THEN '01_d1' WHEN pr < 0.2 THEN '02_d2' WHEN pr < 0.3 THEN '03_d3' WHEN pr < 0.4 THEN '04_d4'
         WHEN pr < 0.5 THEN '05_d5' WHEN pr < 0.6 THEN '06_d6' WHEN pr < 0.7 THEN '07_d7' WHEN pr < 0.8 THEN '08_d8' WHEN pr < 0.9 THEN '09_d9'
         WHEN pr < 0.95 THEN '10_p90_95' WHEN pr < 0.99 THEN '11_p95_99' ELSE '12_p99' END AS bucket
  FROM rk
)
SELECT b.album_id, b.bucket, COUNT(*) AS n, ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY b.album_id), 4) AS sh_payers,
  ROUND(MIN(b.strength), 2) AS min_pd, ROUND(MAX(b.strength), 2) AS max_pd,
  COUNTIF(b.fin) AS finishers, ROUND(COUNTIF(b.fin) / COUNT(*), 4) AS fin_rate,
  ROUND(SUM(b.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev, ROUND(SUM(IF(b.fin, b.alb_rev, 0)) / ANY_VALUE(t.game_rev), 4) AS fin_sh_game_rev
FROM b JOIN tot t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507) =====
WITH alb AS (SELECT 14 AS album_id, DATE '2026-07-13' AS a_start, DATE '2026-08-24' AS a_end UNION ALL SELECT 15, DATE '2026-08-24', DATE '2026-10-05'),
tgt AS (SELECT album_id, a_start, a_end, DATE_ADD(a_start, INTERVAL CAST(FLOOR(0.75 * DATE_DIFF(a_end, a_start, DAY)) AS INT64) DAY) AS q4 FROM alb),
ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    IFNULL(active_flag, FALSE) AS act
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
tot AS (
  SELECT t.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN tgt t ON m.date_dim BETWEEN t.a_start AND DATE_SUB(t.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1
),
u0 AS (
  SELECT u.album_id, u.user_id, MAX(u.uniq) AS uniq_close, SUM(IF(u.date_dim < u.a_end, u.spend, 0)) AS alb_rev,
    SUM(IF(u.date_dim < t.q4, u.spend, 0)) AS q_rev, COUNTIF(u.act AND u.date_dim < t.q4) AS q_days,
    MAX(IF(u.date_dim < u.a_end, u.date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(u.date_dim < u.a_end, STRUCT(u.lr, u.past, u.excl), NULL) IGNORE NULLS ORDER BY u.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud u JOIN tgt t USING (album_id) GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, uniq_close, alb_rev, q_rev, q_days, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT u.album_id, u.user_id, u.alb_rev, IFNULL(SAFE_DIVIDE(u.q_rev, u.q_days), 0) AS strength, u.uniq_close >= 144 AS fin
  FROM u1 u JOIN tgt t USING (album_id)
  WHERE u.last_d = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
rk AS (SELECT album_id, alb_rev, fin, strength, PERCENT_RANK() OVER (PARTITION BY album_id, strength > 0 ORDER BY strength) AS pr FROM pop),
b AS (
  SELECT album_id, alb_rev, fin, strength,
    CASE WHEN strength = 0 THEN '00_zero' WHEN pr < 0.1 THEN '01_d1' WHEN pr < 0.2 THEN '02_d2' WHEN pr < 0.3 THEN '03_d3' WHEN pr < 0.4 THEN '04_d4'
         WHEN pr < 0.5 THEN '05_d5' WHEN pr < 0.6 THEN '06_d6' WHEN pr < 0.7 THEN '07_d7' WHEN pr < 0.8 THEN '08_d8' WHEN pr < 0.9 THEN '09_d9'
         WHEN pr < 0.95 THEN '10_p90_95' WHEN pr < 0.99 THEN '11_p95_99' ELSE '12_p99' END AS bucket
  FROM rk
)
SELECT b.album_id, b.bucket, COUNT(*) AS n, ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY b.album_id), 4) AS sh_payers,
  ROUND(MIN(b.strength), 2) AS min_pd, ROUND(MAX(b.strength), 2) AS max_pd,
  COUNTIF(b.fin) AS finishers, ROUND(COUNTIF(b.fin) / COUNT(*), 4) AS fin_rate,
  ROUND(SUM(b.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev, ROUND(SUM(IF(b.fin, b.alb_rev, 0)) / ANY_VALUE(t.game_rev), 4) AS fin_sh_game_rev
FROM b JOIN tot t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;
