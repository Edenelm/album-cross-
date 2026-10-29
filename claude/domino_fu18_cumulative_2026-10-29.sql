-- q28 (2026-10-29, Eden): FU18 cumulative check + by end state.
-- Population = q27 (A/B board definition): album-18 players with an Easy album_segment, server_user_id not null,
--   not special / not deactivated on any day 04-03..09-07. MOD(sid,997) < 498 = Test (3 locked), else Control (5 locked).
-- Revenue = gross in-app $ (user_daily_metrics.user_daily_inapp_purchase_amount) on days with level_id_end_day >= 35 (as q27).
-- Windows: pre 05-12..06-27 (before the test) | test 06-28..07-06 | after18 07-07..07-20 | alb19 07-21..08-24 | after19 08-25..09-07
--   cum = 06-28..09-07 (test start to 2 weeks after album 19). Per-player sums + sums of squares for a normal-approx CI.
-- End state = 168 - unique_album_stickers_lt at end of 07-05: fin 0 / m12 1-2 / m35 3-5 / m6 6+ (an outcome of the test: descriptive).
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    LOGICAL_OR(LOWER(a.album_segment) LIKE '%easy%') AS easy, LOGICAL_OR(a.special_user_flag) AS sp,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18
  GROUP BY 1),
d AS (
  SELECT m.user_id, m.date_dim dd, IF(m.level_id_end_day >= 35, m.user_daily_inapp_purchase_amount, 0) amt,
    m.special_user_flag sp, m.deactivated_user_flag de
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m
  WHERE m.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07'),
ex AS (SELECT user_id FROM d GROUP BY 1 HAVING LOGICAL_OR(IFNULL(sp, FALSE) OR IFNULL(de, FALSE))),
pop AS (
  SELECT a.user_id, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uq, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uq, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uq, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a LEFT JOIN ex USING (user_id)
  WHERE a.sid IS NOT NULL AND a.easy AND NOT IFNULL(a.sp, FALSE) AND ex.user_id IS NULL),
pu AS (
  SELECT p.user_id, p.grp, p.st,
    SUM(IF(d.dd BETWEEN DATE '2026-05-12' AND DATE '2026-06-27', d.amt, 0)) pre,
    SUM(IF(d.dd BETWEEN DATE '2026-06-28' AND DATE '2026-07-06', d.amt, 0)) tst,
    SUM(IF(d.dd BETWEEN DATE '2026-07-07' AND DATE '2026-07-20', d.amt, 0)) a18,
    SUM(IF(d.dd BETWEEN DATE '2026-07-21' AND DATE '2026-08-24', d.amt, 0)) al19,
    SUM(IF(d.dd BETWEEN DATE '2026-08-25' AND DATE '2026-09-07', d.amt, 0)) a19,
    SUM(IF(d.dd BETWEEN DATE '2026-06-28' AND DATE '2026-09-07', d.amt, 0)) cum
  FROM pop p LEFT JOIN d ON d.user_id = p.user_id AND d.amt > 0
  GROUP BY 1, 2, 3)
SELECT grp, s2 st, COUNT(*) n,
  SUM(pre) s_pre, SUM(pre*pre) q_pre, SUM(tst) s_tst, SUM(tst*tst) q_tst,
  SUM(a18) s_a18, SUM(a18*a18) q_a18, SUM(al19) s_al19, SUM(al19*al19) q_al19,
  SUM(a19) s_a19, SUM(a19*a19) q_a19, SUM(cum) s_cum, SUM(cum*cum) q_cum,
  COUNTIF(pre > 0) p_pre, COUNTIF(a18 > 0) p_a18, COUNTIF(cum > 0) p_cum
FROM pu CROSS JOIN UNNEST([st, 'all']) s2
GROUP BY 1, 2 ORDER BY 2, 1

-- ===== q29 (2026-10-29): same as q28 but the state is fixed BEFORE the test = missing at end of 06-27
-- (cannot be moved by the treatment, so test vs control inside a state is a fair split). p_fin / p_m12 / p_m35 / p_m610 / p_m11.
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    LOGICAL_OR(LOWER(a.album_segment) LIKE '%easy%') AS easy, LOGICAL_OR(a.special_user_flag) AS sp,
    MAX(IF(a.date_dim <= DATE '2026-06-27', a.unique_album_stickers_lt, NULL)) AS uq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18
  GROUP BY 1),
d AS (
  SELECT m.user_id, m.date_dim dd, IF(m.level_id_end_day >= 35, m.user_daily_inapp_purchase_amount, 0) amt,
    m.special_user_flag sp, m.deactivated_user_flag de
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m
  WHERE m.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07'),
ex AS (SELECT user_id FROM d GROUP BY 1 HAVING LOGICAL_OR(IFNULL(sp, FALSE) OR IFNULL(de, FALSE))),
pop AS (
  SELECT a.user_id, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uq, 0) <= 0 THEN 'p_fin' WHEN 168 - IFNULL(a.uq, 0) <= 2 THEN 'p_m12'
         WHEN 168 - IFNULL(a.uq, 0) <= 5 THEN 'p_m35' WHEN 168 - IFNULL(a.uq, 0) <= 10 THEN 'p_m610' ELSE 'p_m11' END AS st
  FROM a LEFT JOIN ex USING (user_id)
  WHERE a.sid IS NOT NULL AND a.easy AND NOT IFNULL(a.sp, FALSE) AND ex.user_id IS NULL),
pu AS (
  SELECT p.user_id, p.grp, p.st,
    SUM(IF(d.dd BETWEEN DATE '2026-05-12' AND DATE '2026-06-27', d.amt, 0)) pre,
    SUM(IF(d.dd BETWEEN DATE '2026-06-28' AND DATE '2026-07-06', d.amt, 0)) tst,
    SUM(IF(d.dd BETWEEN DATE '2026-07-07' AND DATE '2026-07-20', d.amt, 0)) a18,
    SUM(IF(d.dd BETWEEN DATE '2026-07-21' AND DATE '2026-08-24', d.amt, 0)) al19,
    SUM(IF(d.dd BETWEEN DATE '2026-08-25' AND DATE '2026-09-07', d.amt, 0)) a19,
    SUM(IF(d.dd BETWEEN DATE '2026-06-28' AND DATE '2026-09-07', d.amt, 0)) cum
  FROM pop p LEFT JOIN d ON d.user_id = p.user_id AND d.amt > 0
  GROUP BY 1, 2, 3)
SELECT grp, s2 st, COUNT(*) n,
  SUM(pre) s_pre, SUM(pre*pre) q_pre, SUM(tst) s_tst, SUM(tst*tst) q_tst,
  SUM(a18) s_a18, SUM(a18*a18) q_a18, SUM(al19) s_al19, SUM(al19*al19) q_al19,
  SUM(a19) s_a19, SUM(a19*a19) q_a19, SUM(cum) s_cum, SUM(cum*cum) q_cum,
  COUNTIF(pre > 0) p_pre, COUNTIF(a18 > 0) p_a18, COUNTIF(cum > 0) p_cum
FROM pu CROSS JOIN UNNEST([st, 'all']) s2
GROUP BY 1, 2 ORDER BY 2, 1


-- ===== q30 (2026-10-29, Eden): as q29 but the before-test baseline = the 14 days before the test (06-14..06-27), Eden's standard AB pre period.
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    LOGICAL_OR(LOWER(a.album_segment) LIKE '%easy%') AS easy, LOGICAL_OR(a.special_user_flag) AS sp,
    MAX(IF(a.date_dim <= DATE '2026-06-27', a.unique_album_stickers_lt, NULL)) AS uq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18
  GROUP BY 1),
d AS (
  SELECT m.user_id, m.date_dim dd, IF(m.level_id_end_day >= 35, m.user_daily_inapp_purchase_amount, 0) amt,
    m.special_user_flag sp, m.deactivated_user_flag de
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m
  WHERE m.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07'),
ex AS (SELECT user_id FROM d GROUP BY 1 HAVING LOGICAL_OR(IFNULL(sp, FALSE) OR IFNULL(de, FALSE))),
pop AS (
  SELECT a.user_id, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uq, 0) <= 0 THEN 'p_fin' WHEN 168 - IFNULL(a.uq, 0) <= 2 THEN 'p_m12'
         WHEN 168 - IFNULL(a.uq, 0) <= 5 THEN 'p_m35' WHEN 168 - IFNULL(a.uq, 0) <= 10 THEN 'p_m610' ELSE 'p_m11' END AS st
  FROM a LEFT JOIN ex USING (user_id)
  WHERE a.sid IS NOT NULL AND a.easy AND NOT IFNULL(a.sp, FALSE) AND ex.user_id IS NULL),
pu AS (
  SELECT p.user_id, p.grp, p.st,
    SUM(IF(d.dd BETWEEN DATE '2026-06-14' AND DATE '2026-06-27', d.amt, 0)) pre,
    SUM(IF(d.dd BETWEEN DATE '2026-06-28' AND DATE '2026-07-06', d.amt, 0)) tst,
    SUM(IF(d.dd BETWEEN DATE '2026-07-07' AND DATE '2026-07-20', d.amt, 0)) a18,
    SUM(IF(d.dd BETWEEN DATE '2026-07-21' AND DATE '2026-08-24', d.amt, 0)) al19,
    SUM(IF(d.dd BETWEEN DATE '2026-08-25' AND DATE '2026-09-07', d.amt, 0)) a19,
    SUM(IF(d.dd BETWEEN DATE '2026-06-28' AND DATE '2026-09-07', d.amt, 0)) cum
  FROM pop p LEFT JOIN d ON d.user_id = p.user_id AND d.amt > 0
  GROUP BY 1, 2, 3)
SELECT grp, s2 st, COUNT(*) n,
  SUM(pre) s_pre, SUM(pre*pre) q_pre, SUM(tst) s_tst, SUM(tst*tst) q_tst,
  SUM(a18) s_a18, SUM(a18*a18) q_a18, SUM(al19) s_al19, SUM(al19*al19) q_al19,
  SUM(a19) s_a19, SUM(a19*a19) q_a19, SUM(cum) s_cum, SUM(cum*cum) q_cum,
  COUNTIF(pre > 0) p_pre, COUNTIF(a18 > 0) p_a18, COUNTIF(cum > 0) p_cum
FROM pu CROSS JOIN UNNEST([st, 'all']) s2
GROUP BY 1, 2 ORDER BY 2, 1

