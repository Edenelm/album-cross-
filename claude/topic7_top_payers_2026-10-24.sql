-- Topic 7b (2026-10-24): why did Dice >$20 a day finishers start album 65 at 85% of own pace (album 63) when album 61 was 103%?
-- Same population, spend levels and finished status as claude/topic6_after_album_2026-10-24.sql; Dice albums 61 / 63 / 65 (next 63 / 65 / 67).
-- >$20 split into $20-50 / $50-100 / >$100 a day (my cut, round numbers) to see if a few big payers drive it.
-- After windows: close+1..close+4 (all three albums; album 67 has 4 full days on 2026-10-24) and close+1..close+7 (61, 63).
-- Close day spend = the closing album's close-day row (close day = next album day 1; not in album revenue).
-- ratio_agg = group after-spend per day / group pace per day. ratio_med = median of each player's own ratio.
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-10-19' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-10-19' AND album_id IN (61,63,65) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim = a.a_end, a.spend, 0)) AS cd_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) > CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1 AND a.date_dim < a.a_end, a.spend, 0)) AS last_q,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ANY_VALUE(DATE_DIFF(a.a_end, a.a_start, DAY) - CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS lq_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-19' AND album_id IN (61, 63, 65) GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id,
    SUM(IF(n.date_dim <= DATE_ADD(c.a_end, INTERVAL 4 DAY), IFNULL(n.spent_in_album_today,0), 0)) AS rev4,
    SUM(IFNULL(n.spent_in_album_today,0)) AS rev7,
    COUNTIF(n.date_dim <= DATE_ADD(c.a_end, INTERVAL 4 DAY) AND IFNULL(n.spent_in_album_today,0) > 0) AS pay_days4
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 2
  WHERE n.date_dim BETWEEN DATE '2026-07-28' AND DATE '2026-10-24' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.cd_rev, u.so_far / u.q_days AS pace, u.last_q / u.lq_days AS lq_pd,
    IFNULL(x.rev4, 0) AS rev4, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days4, 0) AS pay_days4,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' WHEN u.so_far / u.q_days <= 50 THEN 't4a_20_50'
         WHEN u.so_far / u.q_days <= 100 THEN 't4b_50_100' ELSE 't4c_gt100' END AS tier,
    IF(u.uniq_end >= 144, 'fin', 'not') AS status
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1)
SELECT t.album_id, tier, status, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, ROUND(SUM(pace)) AS pace_pd,
  ROUND(SAFE_DIVIDE(SUM(lq_pd), SUM(pace)), 3) AS lastq_vs_pace, ROUND(SAFE_DIVIDE(SUM(cd_rev), SUM(pace)), 3) AS closeday_vs_pace,
  ROUND(SAFE_DIVIDE(SUM(rev4) / 4, SUM(pace)), 3) AS d4_ratio_agg,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(rev4 / 4, pace), 2)[OFFSET(1)], 3) AS d4_ratio_med,
  ROUND(AVG(IF(pay_days4 > 0, 1, 0)), 3) AS bought_4d,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS d7_ratio_agg,
  ROUND(SUM(pace) * 4 - SUM(rev4)) AS gap4_usd
FROM t JOIN tot USING (album_id) WHERE tier NOT IN ('t0_0', 't1_le2') GROUP BY 1, 2, 3 ORDER BY 2, 3, 1

-- Campaign calendar around the start of albums 63 / 65 / 67 (2026-10-24, Eden). dim_campaign has only id + name;
-- the date is read from the name prefix DDMMYY (assumed = launch date). Window: 2 days before to 4 days after the album start.
WITH c AS (
  SELECT campaign_id, campaign_name, SAFE.PARSE_DATE('%d%m%y', SUBSTR(campaign_name, 1, 6)) AS d
  FROM `dice-dreams-dbt.20_core.dim_campaign`),
w AS (
  SELECT 'start_63' AS win, DATE '2026-07-27' AS s UNION ALL SELECT 'start_65', DATE '2026-09-07' UNION ALL SELECT 'start_67', DATE '2026-10-19')
SELECT w.win, DATE_DIFF(c.d, w.s, DAY) AS day_vs_close, c.campaign_name
FROM c JOIN w ON c.d BETWEEN DATE_SUB(w.s, INTERVAL 2 DAY) AND DATE_ADD(w.s, INTERVAL 4 DAY)
ORDER BY 1, 2, 3;
