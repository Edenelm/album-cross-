-- Topic 6 point 2 (Eden, 2026-10-24): payers 1-2 stickers short on close-1 — what happened on the close day and after the album.
-- Same population, spend levels, last week and week after as claude/topic6_before_after_2026-10-24.sql (status on close-1 = 142-143 stickers).
-- New: close-day outcome = 144 by the end of the close day (Domino/Disney: daily table incl. the close-day row; Dice: sticker table
-- 30_intermediate.fact_user_album_stickers, because the Dice daily table does not update stickers on the close day).
-- Rows: album x spend level (+ 'all') x close-day outcome ('all' / 'fin_close' / 'short_end'). Results: claude/topic6-short-payers-2026-10-24.md

-- ===== DISNEY 14/15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end, MAX(a.uniq) >= 144 AS cf,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_close_date) AS a_end FROM `solitaire-dreams-411507.bi_prod.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-05' AND album_id IN (14, 15) GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.album_spent_today,0)) AS rev7, COUNTIF(IFNULL(n.album_spent_today,0) > 0) AS pay_days7
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 1
  WHERE n.date_dim BETWEEN DATE '2026-08-25' AND DATE '2026-10-12' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN u.uniq_end >= 144 THEN 'a_finished' WHEN u.uniq_end >= 142 THEN 'b_1_2' WHEN u.uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status, u.cf
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
s AS (SELECT * FROM t WHERE status = 'b_1_2'),
agg AS (
  SELECT album_id, tier, IF(cf, 'fin_close', 'short_end') AS outcome, alb_rev, last7, pace, rev7, pay_days7 FROM s
  UNION ALL SELECT album_id, tier, 'all', alb_rev, last7, pace, rev7, pay_days7 FROM s
  UNION ALL SELECT album_id, 'all', IF(cf, 'fin_close', 'short_end'), alb_rev, last7, pace, rev7, pay_days7 FROM s WHERE tier != 't0_0'
  UNION ALL SELECT album_id, 'all', 'all', alb_rev, last7, pace, rev7, pay_days7 FROM s WHERE tier != 't0_0')
SELECT a.album_id, tier, outcome, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(SAFE_DIVIDE(SUM(last7) / 7, SUM(pace)), 3) AS last7_vs_pace,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d
FROM agg a JOIN tot USING (album_id) WHERE tier != 't0_0' GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;


-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end, MAX(a.uniq) >= 144 AS cf,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
cl AS (SELECT album_id, ANY_VALUE(album_close_date) AS a_end FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-05' AND album_id IN (19, 20) GROUP BY 1),
nx AS (
  SELECT c.album_id, n.user_id, SUM(IFNULL(n.album_spent_today,0)) AS rev7, COUNTIF(IFNULL(n.album_spent_today,0) > 0) AS pay_days7
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` n JOIN cl c ON n.album_id = c.album_id + 1
  WHERE n.date_dim BETWEEN DATE '2026-08-25' AND DATE '2026-10-19' AND n.date_dim BETWEEN DATE_ADD(c.a_end, INTERVAL 1 DAY) AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN u.uniq_end >= 144 THEN 'a_finished' WHEN u.uniq_end >= 142 THEN 'b_1_2' WHEN u.uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status, u.cf
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
s AS (SELECT * FROM t WHERE status = 'b_1_2'),
agg AS (
  SELECT album_id, tier, IF(cf, 'fin_close', 'short_end') AS outcome, alb_rev, last7, pace, rev7, pay_days7 FROM s
  UNION ALL SELECT album_id, tier, 'all', alb_rev, last7, pace, rev7, pay_days7 FROM s
  UNION ALL SELECT album_id, 'all', IF(cf, 'fin_close', 'short_end'), alb_rev, last7, pace, rev7, pay_days7 FROM s WHERE tier != 't0_0'
  UNION ALL SELECT album_id, 'all', 'all', alb_rev, last7, pace, rev7, pay_days7 FROM s WHERE tier != 't0_0')
SELECT a.album_id, tier, outcome, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(SAFE_DIVIDE(SUM(last7) / 7, SUM(pace)), 3) AS last7_vs_pace,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d
FROM agg a JOIN tot USING (album_id) WHERE tier != 't0_0' GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;


-- ===== DICE 61/63 (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(a.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 7 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY), a.spend, 0)) AS last7,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
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
  SELECT u.album_id, u.user_id, u.alb_rev, u.last7, u.so_far / u.q_days AS pace, IFNULL(x.rev7, 0) AS rev7, IFNULL(x.pay_days7, 0) AS pay_days7,
    CASE WHEN u.so_far <= 0 THEN 't0_0' WHEN u.so_far / u.q_days <= 2 THEN 't1_le2' WHEN u.so_far / u.q_days <= 5 THEN 't2_2_5'
         WHEN u.so_far / u.q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier,
    CASE WHEN u.uniq_end >= 144 THEN 'a_finished' WHEN u.uniq_end >= 142 THEN 'b_1_2' WHEN u.uniq_end = 141 THEN 'c_3' ELSE 'd_4plus' END AS status
  FROM u LEFT JOIN nx x USING (album_id, user_id) WHERE u.ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1),
st1 AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_date) AS first_d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE)
  GROUP BY 1,2,3),
stc AS (
  SELECT t1.album_id, t1.user_id, COUNT(*) >= 144 AS cf
  FROM st1 t1 JOIN cl USING (album_id) WHERE t1.first_d <= cl.a_end GROUP BY 1,2),
s AS (SELECT t.*, IFNULL(stc.cf, FALSE) AS cf FROM t LEFT JOIN stc USING (album_id, user_id) WHERE t.status = 'b_1_2'),
agg AS (
  SELECT album_id, tier, IF(cf, 'fin_close', 'short_end') AS outcome, alb_rev, last7, pace, rev7, pay_days7 FROM s
  UNION ALL SELECT album_id, tier, 'all', alb_rev, last7, pace, rev7, pay_days7 FROM s
  UNION ALL SELECT album_id, 'all', IF(cf, 'fin_close', 'short_end'), alb_rev, last7, pace, rev7, pay_days7 FROM s WHERE tier != 't0_0'
  UNION ALL SELECT album_id, 'all', 'all', alb_rev, last7, pace, rev7, pay_days7 FROM s WHERE tier != 't0_0')
SELECT a.album_id, tier, outcome, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(SAFE_DIVIDE(SUM(last7) / 7, SUM(pace)), 3) AS last7_vs_pace,
  ROUND(SAFE_DIVIDE(SUM(rev7) / 7, SUM(pace)), 3) AS after_vs_pace, ROUND(AVG(IF(pay_days7 > 0, 1, 0)), 3) AS bought_7d
FROM agg a JOIN tot USING (album_id) WHERE tier != 't0_0' GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;
