-- 2026-10-26 (Eden): Domino 19/20, week after close vs the same players' normal week.
-- CHECK 1 (mirrors dice_gt20_finishers_cz_ron_2026-10-25.sql, slide a6s8s): payers >$20 a day, finished vs 1-2 short.
--   Status as a6s8s / topic6_normal_week_check_2026-10-24.sql: unique set stickers on the last row BEFORE close (close-1).
-- CHECK 2 (as vipa / vip_normal_week_churn_2026-10-24.sql): VIP = LTV on album start >= $5K, status at the END of the close day
--   (max unique stickers incl. close day): finished / 1-3 short / 4+ short; split by deck spend level (pace days 0-20).
-- Population: standard population (user_album_count > 1, not special_user_flag, not suspected cheater, login ratio >= 0.5 on last row
--   before close, row on close-1), payer = spend > 0 on any album day incl. close. Album revenue = album_spent_today start..close-1.
-- Spend level = album spend days 0-20 / 21: <=2, 2-5, 5-20, >20 $ a day.
-- Windows: normal week = album days 21-27; week after = close+1..+7 (album 19: Aug 25-31; album 20: Oct 13-19).
-- Window metrics from prod_40_mart.user_daily_metrics (all in-game spend = inapp + stripe; number_of_purchases_today; pau_flag;
--   sessions_today; daily_seesion_duration_min; ooc_today_flag). Per player first, then summed / averaged. All players kept (no row = 0).
-- Results: claude/domino-after-close-20plus-vip-2026-10-26.md

-- ===== Q1+Q2: per segment, normal week vs week after =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, ltv_on_album_start AS ltv
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-19' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end, MAX(a.ltv) AS ltv,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) BETWEEN 0 AND 20, a.spend, 0)) AS s_a,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_pre,
    MAX(a.uniq) AS uniq_close,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
pop AS (
  SELECT album_id, user_id, a_start, a_end, alb_rev, s_a / 21 AS pace,
    SUM(alb_rev) OVER (PARTITION BY album_id) AS rev_all, COUNT(*) OVER (PARTITION BY album_id) AS n_all,
    CASE WHEN s_a / 21 <= 2 THEN 'l1_le2' WHEN s_a / 21 <= 5 THEN 'l2_2_5' WHEN s_a / 21 <= 20 THEN 'l3_5_20' ELSE 'l4_gt20' END AS lvl,
    CASE WHEN uniq_pre >= 144 THEN 'a_fin' WHEN uniq_pre >= 142 THEN 'b_1_2' ELSE 'z' END AS st1,
    CASE WHEN uniq_close >= 144 THEN 'a_fin' WHEN uniq_close >= 141 THEN 'b_1_3' ELSE 'c_4plus' END AS st2,
    IFNULL(ltv,0) >= 5000 AS vip
  FROM u WHERE ok),
seg AS (
  SELECT *, 'C1_gt20' AS chk, st1 AS st FROM pop WHERE lvl = 'l4_gt20' AND st1 != 'z'
  UNION ALL SELECT *, 'C2_vip', st2 FROM pop WHERE vip),
m AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(number_of_purchases_today,0) AS trx, IFNULL(pau_flag,FALSE) AS act, IFNULL(sessions_today,0) AS ses,
    IFNULL(daily_seesion_duration_min,0) AS mins, IFNULL(ooc_today_flag,FALSE) AS ooc
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-10-19'),
pw AS (
  SELECT s.chk, s.album_id, s.lvl, s.st, s.user_id, w.win, ANY_VALUE(s.pace) AS pace, ANY_VALUE(s.alb_rev) AS alb_rev,
    ANY_VALUE(s.rev_all) AS rev_all, ANY_VALUE(s.n_all) AS n_all,
    SUM(IF(m.date_dim BETWEEN w.d0 AND w.d1, m.rev, 0)) AS rev, SUM(IF(m.date_dim BETWEEN w.d0 AND w.d1, m.trx, 0)) AS trx,
    COUNTIF(m.date_dim BETWEEN w.d0 AND w.d1 AND m.act) AS act_days, SUM(IF(m.date_dim BETWEEN w.d0 AND w.d1, m.ses, 0)) AS ses,
    SUM(IF(m.date_dim BETWEEN w.d0 AND w.d1, m.mins, 0)) AS mins, COUNTIF(m.date_dim BETWEEN w.d0 AND w.d1 AND m.ooc) AS ooc_days
  FROM seg s
  CROSS JOIN UNNEST([STRUCT('1_normal' AS win, DATE_ADD(s.a_start, INTERVAL 21 DAY) AS d0, DATE_ADD(s.a_start, INTERVAL 27 DAY) AS d1),
                     STRUCT('2_after', DATE_ADD(s.a_end, INTERVAL 1 DAY), DATE_ADD(s.a_end, INTERVAL 7 DAY))]) w
  LEFT JOIN m ON m.user_id = s.user_id AND m.date_dim BETWEEN DATE_ADD(s.a_start, INTERVAL 21 DAY) AND DATE_ADD(s.a_end, INTERVAL 7 DAY)
  GROUP BY 1,2,3,4,5,6)
SELECT chk, album_id AS a, IF(chk = 'C1_gt20', 'all', lvl) AS l, st, win, COUNT(*) AS n,
  ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS sh_players, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS sh_rev,
  ROUND(SUM(7 * pace)) AS pace7, ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / SUM(7 * pace), 3) AS rev_vs_pace,
  ROUND(AVG(act_days), 2) AS act_days, ROUND(AVG(IF(trx > 0, 1, 0)), 3) AS buyers,
  ROUND(SAFE_DIVIDE(SUM(trx), COUNTIF(trx > 0)), 2) AS trx_per_buyer, ROUND(SAFE_DIVIDE(SUM(rev), SUM(trx)), 2) AS usd_per_trx,
  ROUND(SAFE_DIVIDE(SUM(ses), SUM(act_days)), 1) AS ses_per_act_day, ROUND(SAFE_DIVIDE(SUM(mins), SUM(act_days))) AS min_per_act_day,
  ROUND(AVG(ooc_days), 2) AS ooc_days
FROM pw GROUP BY chk, album_id, l, st, win ORDER BY 1,2,3,4,5;

-- ===== Q3: which offers sold in each window (whole game), top 15 campaigns by revenue (staging, approved by Eden 2026-10-26) =====
WITH w AS (
  SELECT '19_normal' AS win, DATE '2026-07-27' AS d0, DATE '2026-08-02' AS d1 UNION ALL
  SELECT '19_after', DATE '2026-08-25', DATE '2026-08-31' UNION ALL
  SELECT '20_normal', DATE '2026-09-14', DATE '2026-09-20' UNION ALL
  SELECT '20_after', DATE '2026-10-13', DATE '2026-10-19'),
p AS (
  SELECT w.win, s.external_order_id, COALESCE(s.mtx_campaign_name, '(none)') AS camp, SAFE_CAST(s.usd_amount AS FLOAT64) AS amt
  FROM `domino-dreams-dbt.prod_10_staging.stg_purchase_completed_vw` s JOIN w ON s.pdate BETWEEN w.d0 AND w.d1
  WHERE s.pdate BETWEEN DATE '2026-07-27' AND DATE '2026-10-19' AND SAFE_CAST(s.usd_amount AS FLOAT64) > 0),
g AS (SELECT win, REGEXP_REPLACE(camp, r'^\d{6}_', '') AS camp, COUNT(DISTINCT external_order_id) AS n, SUM(amt) AS rev FROM p GROUP BY 1,2),
r AS (SELECT *, rev / SUM(rev) OVER (PARTITION BY win) AS sh, ROW_NUMBER() OVER (PARTITION BY win ORDER BY rev DESC) AS rk FROM g)
SELECT win, rk, camp, n, ROUND(rev) AS rev, ROUND(sh, 3) AS sh FROM r WHERE rk <= 15 ORDER BY win, rk;
