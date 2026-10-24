-- Did Domino album 20's easier end (two Puzzle Jokers) pay a second time at the start of album 21? (Eden, 2026-10-24)
-- Same population, spend levels, end status and after-week as claude/topic6_after_album_2026-10-24.sql (Domino block).
-- Albums 18 / 19 / 20 (close 2026-07-06 / 08-24 / 10-12); after-week = close+1..close+7 of the next album (19 / 20 / 21).
-- Rows: each end status, plus status = 'all' (all payers in the level) = what the album start actually got.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-12' AND album_id IN (18,19,20) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-19' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (18, 19, 20) GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.album_spent_today,0)) AS rev7, COUNTIF(IFNULL(n.album_spent_today,0) > 0) AS pay_days7
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 1
  WHERE n.date_dim BETWEEN DATE '2026-07-07' AND DATE '2026-10-19' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN u.uniq_end >= 144 THEN 'a_finished' WHEN u.uniq_end >= 141 THEN 'b_1_3' ELSE 'c_4plus' END AS status
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
s AS (SELECT album_id, tier, status, alb_rev, pace, rev7, pay_days7 FROM t
      UNION ALL SELECT album_id, tier, 'z_all', alb_rev, pace, rev7, pay_days7 FROM t)
SELECT s.album_id, tier, status, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, ROUND(SUM(pace)) AS pace_per_day, ROUND(SUM(rev7)) AS rev_after7,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d,
  ROUND(SUM(pace) * 7 - SUM(rev7)) AS gap_usd
FROM s JOIN tot USING (album_id) WHERE tier != 't0_0' GROUP BY 1, 2, 3 ORDER BY 2, 3, 1
