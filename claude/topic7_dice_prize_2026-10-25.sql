-- Topic 7 (2026-10-25): Dice payer finishers — who finishes, by spend level x final-prize code, and how fast they return to buying.
-- Population, spend levels, finished status and the after-week: exactly as claude/topic6_after_album_2026-10-24.sql (Dice 61/63, next 63/65).
-- Prize = album_reward_value (rolls) on the last row before close; code = album_reward_code (1-7; 7 = 200K).
-- Own play = rolls out per day over the album (start .. close-1), from 30_intermediate.user_daily_rolls_in_out.
-- Prize in days of own play = prize / own rolls out per day.
-- After vs pace = after-week spend per day / album pace per day (group totals). Gap $ = pace x 7 - after-week spend (gap to own pace, not a forecast).
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend,
    album_reward_code AS r_code, album_reward_value AS r_val
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.r_code, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS r_code,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.r_val, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS r_val,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-09-05' AND album_id IN (61, 63) GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.spent_in_album_today,0)) AS rev7, COUNTIF(IFNULL(n.spent_in_album_today,0) > 0) AS pay_days7
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 2
  WHERE n.date_dim BETWEEN DATE '2026-07-28' AND DATE '2026-09-14' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.a_start, u.a_end, u.alb_rev, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7,
    u.r_code, u.r_val,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    u.uniq_end >= 144 AS fin
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
f AS (SELECT * FROM t WHERE fin),
play AS (
  SELECT f.album_id, f.user_id, SUM(IFNULL(r.rolls_out_sum,0)) / ANY_VALUE(DATE_DIFF(f.a_end, f.a_start, DAY)) AS out_pd
  FROM f JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out` r
    ON r.user_id = f.user_id AND r.date_dim >= f.a_start AND r.date_dim < f.a_end
  WHERE r.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07'
  GROUP BY 1, 2),
g AS (
  SELECT f.*, SAFE_DIVIDE(f.r_val, p.out_pd) AS pdays,
    CASE WHEN SAFE_DIVIDE(f.r_val, p.out_pd) IS NULL THEN 'z_na' WHEN SAFE_DIVIDE(f.r_val, p.out_pd) < 2 THEN 'p1_lt2'
         WHEN SAFE_DIVIDE(f.r_val, p.out_pd) < 4 THEN 'p2_2_4' WHEN SAFE_DIVIDE(f.r_val, p.out_pd) < 8 THEN 'p3_4_8' ELSE 'p4_8plus' END AS pbucket
  FROM f LEFT JOIN play p USING (album_id, user_id)),
agg AS (
  SELECT 'code' AS dim, album_id, tier, CAST(r_code AS STRING) AS grp, user_id, alb_rev, pace, rev7, pay_days7, pdays, r_val FROM g
  UNION ALL
  SELECT 'pdays', album_id, tier, pbucket, user_id, alb_rev, pace, rev7, pay_days7, pdays, r_val FROM g)
SELECT dim, a.album_id, tier, grp, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, ROUND(AVG(r_val)) AS avg_prize,
  ROUND(APPROX_QUANTILES(pdays, 2)[OFFSET(1)], 1) AS med_prize_days,
  ROUND(SUM(pace)) AS pace_per_day, ROUND(SUM(rev7)) AS rev_after7,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d,
  ROUND(SUM(pace) * 7 - SUM(rev7)) AS gap_usd
FROM agg a JOIN tot USING (album_id) WHERE tier != 't0_0' GROUP BY 1, 2, 3, 4 ORDER BY 1, 2, 3, 4
