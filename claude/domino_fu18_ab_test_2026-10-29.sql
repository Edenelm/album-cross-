-- FU18 A/B test (Domino album 18, Album FU 3 vs 5 locked): queries copied from claude/domino-fu18-ab-test-2026-10-29.md section 5.
-- Ran 2026-10-27/28 on domino-dreams-dbt (read-only). Labels: MOD(server_user_id,997) < 498 = Test (3 locked).
-- WARNING q14 uses RAW labels (MOD<498 = 'Control'); swap on read. Outputs live on the work box (/workspace/dom19), not in the repo.

-- ===== q27_daily_lines_official.sql (doc section 5.1) =====
-- **Slide 137 (v5).** Easy daily in-app $ per player, 3 vs 5 locked, on the closest BQ copy of the official A/B board definition.  
-- q27: Easy $ per player per day, 3 locked vs 5 locked, closest BQ copy of the official A/B board
-- (Mixpanel Domino board 11315328 "1553- Album Fu (3 Vs 5)", read 2026-10-28).
-- Board rules -> BQ:
--   Groups property set (server_user_id % 997)          -> server_user_id NOT NULL; MOD(sid,997) < 498 = Test (3 locked),
--                                                          per Page section F verification (matches Mixpanel "Test Group" counts
--                                                          and players stuck at 3 vs 5 missing). NOTE the board formula text says
--                                                          <498 = "Control Group"; see report.
--   Excluded User = false (special / status / deactivated) -> special_user_flag = FALSE AND deactivated_user_flag = FALSE
--   Suspected Fraudulent Purchase = false (event level)    -> NOT reproducible in marts; no cheater filter applied (board has none)
--   Cohort 6106615 "Relevant Users"                        -> NOT reproducible (404, not in cohort list); replaced by:
--                                                          album 18 players with an Easy album_segment (any activity)
--   Level ID >= 35 (event filter on the purchase)          -> revenue counted only on days with level_id_end_day >= 35
--   KPI Sum of Gross Revenue on purchase completed         -> user_daily_inapp_purchase_amount (gross in-app)
-- SELECT only; no writes.
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    LOGICAL_OR(LOWER(a.album_segment) LIKE '%easy%') AS easy, LOGICAL_OR(a.special_user_flag) AS sp
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18
  GROUP BY 1),
d AS (
  SELECT m.user_id, m.date_dim dd, m.user_daily_inapp_purchase_amount amt, m.level_id_end_day lvl,
    m.special_user_flag sp, m.deactivated_user_flag de
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m
  WHERE m.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07'),
ex AS (SELECT user_id FROM d GROUP BY 1 HAVING LOGICAL_OR(IFNULL(sp, FALSE) OR IFNULL(de, FALSE))),
pop AS (
  SELECT a.user_id, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp
  FROM a LEFT JOIN ex USING (user_id)
  WHERE a.sid IS NOT NULL AND a.easy AND NOT IFNULL(a.sp, FALSE) AND ex.user_id IS NULL),
gs AS (SELECT grp, COUNT(*) n FROM pop GROUP BY 1),
day AS (
  SELECT p.grp, d.dd,
    SUM(IF(d.lvl >= 35, d.amt, 0)) rev, COUNT(DISTINCT IF(d.lvl >= 35 AND d.amt > 0, d.user_id, NULL)) payers,
    SUM(d.amt) rev_all_lvls
  FROM d JOIN pop p USING (user_id)
  WHERE d.amt > 0
  GROUP BY 1, 2)
SELECT day.grp, day.dd, gs.n, day.rev, day.payers, day.rev_all_lvls, day.rev / gs.n AS rev_pp, day.payers / gs.n AS payer_rate
FROM day JOIN gs USING (grp)
ORDER BY day.dd, day.grp
;

-- ===== q14_fu_recut.sql (doc section 5.2) =====
-- **Slides 135, 136.** Album 18 re-cut by real group (level-35+ proxy): sums/sums of squares for pre, window, last-4, in-app window, post; payers; end states; revenue by end state. ⚠ **Raw labels** (`MO
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    SUM(IF(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', IFNULL(a.album_spent_today, 0), 0)) AS r_win,
    SUM(IF(a.date_dim BETWEEN DATE '2026-07-02' AND DATE '2026-07-05', IFNULL(a.album_spent_today, 0), 0)) AS r_last,
    SUM(IF(a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-06-27', IFNULL(a.album_spent_today, 0), 0)) AS r_pre,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    MAX(IF(a.date_dim <= DATE '2026-06-27', a.unique_album_stickers_lt, NULL)) AS uniq_pre,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
m AS (
  SELECT m.user_id,
    MAX(IF(m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', m.level_id_end_day, NULL)) AS lvl,
    SUM(IF(m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-06', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS iap_win,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS iap_post
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-08-04'
  GROUP BY 1),
u AS (
  SELECT a.*, m.lvl, IFNULL(m.iap_win, 0) AS iap_win, IFNULL(m.iap_post, 0) AS iap_post,
    IF(MOD(a.sid, 997) < 498, 'Control', 'Test') AS grp,
    168 - IFNULL(a.uniq_end, 0) AS miss
  FROM a LEFT JOIN m USING (user_id)
  WHERE a.sid IS NOT NULL AND IFNULL(m.lvl, 0) >= 35)
SELECT seg, grp, COUNT(*) AS n,
  SUM(r_win) s_win, SUM(r_win*r_win) q_win,
  SUM(r_last) s_last, SUM(r_last*r_last) q_last,
  SUM(r_pre) s_pre, SUM(r_pre*r_pre) q_pre,
  SUM(iap_win) s_iap, SUM(iap_win*iap_win) q_iap,
  SUM(iap_post) s_post, SUM(iap_post*iap_post) q_post,
  COUNTIF(r_win > 0) payers, COUNTIF(iap_win > 0) iap_payers,
  COUNTIF(miss <= 0) fin, COUNTIF(miss BETWEEN 1 AND 2) m12, COUNTIF(miss BETWEEN 3 AND 5) m35, COUNTIF(miss >= 6) m6,
  SUM(IF(miss <= 0, r_win, 0)) rfin, SUM(IF(miss BETWEEN 1 AND 2, r_win, 0)) rm12, SUM(IF(miss BETWEEN 3 AND 5, r_win, 0)) rm35, SUM(IF(miss >= 6, r_win, 0)) rm6,
  COUNTIF(168 - IFNULL(uniq_pre,0) BETWEEN 1 AND 5) pre_m15, COUNTIF(168 - IFNULL(uniq_pre,0) <= 0) pre_fin,
  MIN(miss) min_miss, COUNTIF(sid < 0) neg_sid
FROM u GROUP BY 1, 2 ORDER BY 1, 2
;

-- ===== q23_phase_pt.sql (doc section 5.3) =====
-- Phase-matched point estimates: end ratio and after ratio per group × end state × album (17, 18, 18pre, 19), plus zero-baseline counts, medians, trimmed means.  
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
alb AS (
  SELECT a, s, c FROM UNNEST([STRUCT(17 AS a, DATE '2026-04-02' AS s, DATE '2026-05-11' AS c),
    STRUCT(18, DATE '2026-05-11', DATE '2026-07-06'), STRUCT(19, DATE '2026-07-06', DATE '2026-08-24')])),
ua AS (
  SELECT x.user_id, x.album_id a, MIN(x.date_dim) f
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x JOIN pop p ON p.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-24' AND x.album_id IN (17, 18, 19)
  GROUP BY 1, 2),
m AS (
  SELECT d.user_id, d.date_dim dd, d.user_daily_inapp_purchase_amount amt
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` d JOIN pop p ON p.user_id = d.user_id
  WHERE d.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07' AND d.user_daily_inapp_purchase_amount > 0),
pa AS (
  SELECT p.user_id, p.seg, p.grp, p.st, alb.a, alb.c, GREATEST(ua.f, DATE_ADD(alb.s, INTERVAL 1 DAY)) f2
  FROM pop p JOIN ua USING (user_id) JOIN alb ON alb.a = ua.a),
pu0 AS (
  SELECT pa.user_id, ANY_VALUE(pa.seg) seg, ANY_VALUE(pa.grp) grp, ANY_VALUE(pa.st) st, pa.a,
    GREATEST(DATE_DIFF(DATE_SUB(ANY_VALUE(pa.c), INTERVAL 4 DAY), ANY_VALUE(pa.f2), DAY) + 1, 0) rd,
    GREATEST(DATE_DIFF(DATE '2026-06-27', ANY_VALUE(pa.f2), DAY) + 1, 0) rdp,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE_SUB(pa.c, INTERVAL 4 DAY), m.amt, 0)) rest,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE '2026-06-27', m.amt, 0)) restp,
    SUM(IF(m.dd BETWEEN DATE_SUB(pa.c, INTERVAL 3 DAY) AND pa.c, m.amt, 0)) endd,
    SUM(IF(m.dd BETWEEN DATE_ADD(pa.c, INTERVAL 1 DAY) AND DATE_ADD(pa.c, INTERVAL 14 DAY), m.amt, 0)) aft
  FROM pa LEFT JOIN m ON m.user_id = pa.user_id AND m.dd BETWEEN pa.f2 AND DATE_ADD(pa.c, INTERVAL 14 DAY)
  GROUP BY pa.user_id, pa.a),
pv AS (
  SELECT user_id, seg, grp, st, CAST(a AS STRING) v, rd, rest, endd, aft FROM pu0
  UNION ALL
  SELECT user_id, seg, grp, st, '18pre', rdp, restp, endd, aft FROM pu0 WHERE a = 18),
pu AS (
  SELECT user_id, seg, grp, s2 st, v, rd, rest, endd, aft,
    IF(rd > 0 AND rest > 0, (endd / 4) / (rest / rd), NULL) er,
    IF(rd > 0 AND rest > 0, (aft / 14) / (rest / rd), NULL) ar
  FROM pv CROSS JOIN UNNEST([st, 'all']) s2),
cut AS (
  SELECT seg, grp, st, v, APPROX_QUANTILES(er, 100)[OFFSET(99)] ce, APPROX_QUANTILES(ar, 100)[OFFSET(99)] ca
  FROM pu GROUP BY 1, 2, 3, 4)
SELECT pu.seg, pu.grp, pu.st, pu.v, COUNT(*) n, COUNTIF(rd = 0) n_norest, COUNTIF(rd > 0 AND rest = 0) n_zero,
  SUM(rd) s_rd, SUM(rest) s_rest, SUM(endd) s_end, SUM(aft) s_aft,
  SUM(IF(er IS NULL, endd, 0)) s_end_z, SUM(IF(er IS NULL, aft, 0)) s_aft_z,
  SUM(IF(er IS NULL AND rd > 0, endd, 0)) s_end_z0, SUM(IF(er IS NULL AND rd > 0, aft, 0)) s_aft_z0,
  APPROX_QUANTILES(er, 2)[OFFSET(1)] med_er, APPROX_QUANTILES(ar, 2)[OFFSET(1)] med_ar,
  AVG(IF(er <= cut.ce, er, NULL)) tm_er, AVG(IF(ar <= cut.ca, ar, NULL)) tm_ar,
  COUNTIF(er > 0) n_er_pos, COUNTIF(ar > 0) n_ar_pos, COUNTIF(er IS NOT NULL) n_base,
  APPROX_QUANTILES(er, 4)[OFFSET(1)] q1_er, APPROX_QUANTILES(er, 4)[OFFSET(3)] q3_er,
  APPROX_QUANTILES(ar, 4)[OFFSET(1)] q1_ar, APPROX_QUANTILES(ar, 4)[OFFSET(3)] q3_ar
FROM pu JOIN cut USING (seg, grp, st, v)
GROUP BY 1, 2, 3, 4 ORDER BY 1, 3, 4, 2
;

-- ===== q24_phase_bs.sql (doc section 5.4) =====
-- Same population/phases as q23 with a 100-rep Poisson bootstrap → 95% CIs for test-vs-control and net-of-17.  
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
alb AS (
  SELECT a, s, c FROM UNNEST([STRUCT(17 AS a, DATE '2026-04-02' AS s, DATE '2026-05-11' AS c),
    STRUCT(18, DATE '2026-05-11', DATE '2026-07-06'), STRUCT(19, DATE '2026-07-06', DATE '2026-08-24')])),
ua AS (
  SELECT x.user_id, x.album_id a, MIN(x.date_dim) f
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x JOIN pop p ON p.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-24' AND x.album_id IN (17, 18, 19)
  GROUP BY 1, 2),
m AS (
  SELECT d.user_id, d.date_dim dd, d.user_daily_inapp_purchase_amount amt
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` d JOIN pop p ON p.user_id = d.user_id
  WHERE d.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07' AND d.user_daily_inapp_purchase_amount > 0),
pa AS (
  SELECT p.user_id, p.seg, p.grp, p.st, alb.a, alb.c, GREATEST(ua.f, DATE_ADD(alb.s, INTERVAL 1 DAY)) f2
  FROM pop p JOIN ua USING (user_id) JOIN alb ON alb.a = ua.a),
pu0 AS (
  SELECT pa.user_id, ANY_VALUE(pa.seg) seg, ANY_VALUE(pa.grp) grp, ANY_VALUE(pa.st) st, pa.a,
    GREATEST(DATE_DIFF(DATE_SUB(ANY_VALUE(pa.c), INTERVAL 4 DAY), ANY_VALUE(pa.f2), DAY) + 1, 0) rd,
    GREATEST(DATE_DIFF(DATE '2026-06-27', ANY_VALUE(pa.f2), DAY) + 1, 0) rdp,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE_SUB(pa.c, INTERVAL 4 DAY), m.amt, 0)) rest,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE '2026-06-27', m.amt, 0)) restp,
    SUM(IF(m.dd BETWEEN DATE_SUB(pa.c, INTERVAL 3 DAY) AND pa.c, m.amt, 0)) endd,
    SUM(IF(m.dd BETWEEN DATE_ADD(pa.c, INTERVAL 1 DAY) AND DATE_ADD(pa.c, INTERVAL 14 DAY), m.amt, 0)) aft
  FROM pa LEFT JOIN m ON m.user_id = pa.user_id AND m.dd BETWEEN pa.f2 AND DATE_ADD(pa.c, INTERVAL 14 DAY)
  GROUP BY pa.user_id, pa.a),
pv AS (
  SELECT user_id, seg, grp, st, CAST(a AS STRING) v, rd, rest, endd, aft FROM pu0
  UNION ALL
  SELECT user_id, seg, grp, st, '18pre', rdp, restp, endd, aft FROM pu0 WHERE a = 18),
pu AS (
  SELECT user_id, seg, grp, s2 st, v, rd, rest, endd, aft,
    IF(rd > 0 AND rest > 0, (endd / 4) / (rest / rd), NULL) er,
    IF(rd > 0 AND rest > 0, (aft / 14) / (rest / rd), NULL) ar
  FROM pv CROSS JOIN UNNEST([st, 'all']) s2),
cut AS (
  SELECT seg, grp, st, v, APPROX_QUANTILES(er, 100)[OFFSET(99)] ce, APPROX_QUANTILES(ar, 100)[OFFSET(99)] ca
  FROM pu GROUP BY 1, 2, 3, 4),
bw AS (
  SELECT seg, grp, st, v, r,
    CASE WHEN u < 0.367879 THEN 0 WHEN u < 0.735759 THEN 1 WHEN u < 0.919699 THEN 2 WHEN u < 0.981012 THEN 3
         WHEN u < 0.996340 THEN 4 WHEN u < 0.999406 THEN 5 ELSE 6 END w,
    rd, rest, endd, aft, ert, art
  FROM (
    SELECT pu.seg, pu.grp, pu.st, pu.v, r, pu.rd, pu.rest, pu.endd, pu.aft,
      IF(pu.er <= cut.ce, pu.er, NULL) ert, IF(pu.ar <= cut.ca, pu.ar, NULL) art,
      MOD(ABS(FARM_FINGERPRINT(CONCAT(CAST(pu.user_id AS STRING), '-', CAST(r AS STRING)))), 1000000) / 1e6 u
    FROM pu JOIN cut USING (seg, grp, st, v), UNNEST(GENERATE_ARRAY(1, 100)) AS r)),
g AS (
  SELECT seg, grp, st, v, r,
    SAFE_DIVIDE(SUM(w * endd) / (4 * SUM(w)), SUM(w * rest) / SUM(w * rd)) ge,
    SAFE_DIVIDE(SUM(w * aft) / (14 * SUM(w)), SUM(w * rest) / SUM(w * rd)) ga,
    SAFE_DIVIDE(SUM(IF(ert IS NOT NULL, w * ert, 0)), SUM(IF(ert IS NOT NULL, w, 0))) te,
    SAFE_DIVIDE(SUM(IF(art IS NOT NULL, w * art, 0)), SUM(IF(art IS NOT NULL, w, 0))) ta
  FROM bw GROUP BY 1, 2, 3, 4, 5),
tc AS (
  SELECT t.seg, t.st, t.v, t.r, t.ge / c.ge - 1 de, t.ga / c.ga - 1 da, t.te / c.te - 1 dte, t.ta / c.ta - 1 dta,
    t.ge, c.ge cge, t.ga, c.ga cga
  FROM g t JOIN g c ON c.seg = t.seg AND c.st = t.st AND c.v = t.v AND c.r = t.r AND t.grp = 'Test' AND c.grp = 'Control'),
did AS (
  SELECT x.seg, x.st, CONCAT(x.v, '_vs_17') v, x.r, (1 + x.de) / (1 + y.de) - 1 de, (1 + x.da) / (1 + y.da) - 1 da,
    (1 + x.dte) / (1 + y.dte) - 1 dte, (1 + x.dta) / (1 + y.dta) - 1 dta, NULL ge, NULL cge, NULL ga, NULL cga
  FROM tc x JOIN tc y ON y.seg = x.seg AND y.st = x.st AND y.r = x.r AND y.v = '17' AND x.v IN ('18', '18pre', '19'))
SELECT seg, st, v, COUNT(*) reps,
  APPROX_QUANTILES(de, 40)[OFFSET(1)] de_lo, APPROX_QUANTILES(de, 40)[OFFSET(39)] de_hi,
  APPROX_QUANTILES(da, 40)[OFFSET(1)] da_lo, APPROX_QUANTILES(da, 40)[OFFSET(39)] da_hi,
  APPROX_QUANTILES(dte, 40)[OFFSET(1)] dte_lo, APPROX_QUANTILES(dte, 40)[OFFSET(39)] dte_hi,
  APPROX_QUANTILES(dta, 40)[OFFSET(1)] dta_lo, APPROX_QUANTILES(dta, 40)[OFFSET(39)] dta_hi,
  AVG(de) de_m, AVG(da) da_m
FROM (SELECT seg, st, v, r, de, da, dte, dta FROM tc UNION ALL SELECT seg, st, v, r, de, da, dte, dta FROM did)
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
;

-- ===== q25_coins_phase.sql (doc section 5.5) =====
-- **Slide 138 callout.** Same phase design as q23/q24, but on coins bought (staging coin-in units). Rep 0 = full sample.  
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
alb AS (
  SELECT a, s, c FROM UNNEST([STRUCT(17 AS a, DATE '2026-04-02' AS s, DATE '2026-05-11' AS c),
    STRUCT(18, DATE '2026-05-11', DATE '2026-07-06'), STRUCT(19, DATE '2026-07-06', DATE '2026-08-24')])),
ua AS (
  SELECT x.user_id, x.album_id a, MIN(x.date_dim) f
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x JOIN pop p ON p.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-24' AND x.album_id IN (17, 18, 19)
  GROUP BY 1, 2),
m AS (
  SELECT i.user_id, i.pdate dd, SUM(IF(SAFE_DIVIDE(COALESCE(i.amount, i.coins), i.coins_allowance) BETWEEN 0 AND 1000, SAFE_DIVIDE(COALESCE(i.amount, i.coins), i.coins_allowance), 0)) amt
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw` i JOIN pop p ON p.user_id = i.user_id
  WHERE i.pdate BETWEEN DATE '2026-04-03' AND DATE '2026-09-07' AND i.source IN ('purchase', 'purchase_gift', 'store bundle gift')
  GROUP BY 1, 2),
pa AS (
  SELECT p.user_id, p.seg, p.grp, p.st, alb.a, alb.c, GREATEST(ua.f, DATE_ADD(alb.s, INTERVAL 1 DAY)) f2
  FROM pop p JOIN ua USING (user_id) JOIN alb ON alb.a = ua.a),
pu0 AS (
  SELECT pa.user_id, ANY_VALUE(pa.seg) seg, ANY_VALUE(pa.grp) grp, ANY_VALUE(pa.st) st, pa.a,
    GREATEST(DATE_DIFF(DATE_SUB(ANY_VALUE(pa.c), INTERVAL 4 DAY), ANY_VALUE(pa.f2), DAY) + 1, 0) rd,
    GREATEST(DATE_DIFF(DATE '2026-06-27', ANY_VALUE(pa.f2), DAY) + 1, 0) rdp,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE_SUB(pa.c, INTERVAL 4 DAY), m.amt, 0)) rest,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE '2026-06-27', m.amt, 0)) restp,
    SUM(IF(m.dd BETWEEN DATE_SUB(pa.c, INTERVAL 3 DAY) AND pa.c, m.amt, 0)) endd,
    SUM(IF(m.dd BETWEEN DATE_ADD(pa.c, INTERVAL 1 DAY) AND DATE_ADD(pa.c, INTERVAL 14 DAY), m.amt, 0)) aft
  FROM pa LEFT JOIN m ON m.user_id = pa.user_id AND m.dd BETWEEN pa.f2 AND DATE_ADD(pa.c, INTERVAL 14 DAY)
  GROUP BY pa.user_id, pa.a),
pv AS (
  SELECT user_id, seg, grp, st, CAST(a AS STRING) v, rd, rest, endd, aft FROM pu0
  UNION ALL
  SELECT user_id, seg, grp, st, '18pre', rdp, restp, endd, aft FROM pu0 WHERE a = 18),
pu AS (
  SELECT user_id, seg, grp, s2 st, v, rd, rest, endd, aft,
    IF(rd > 0 AND rest > 0, (endd / 4) / (rest / rd), NULL) er,
    IF(rd > 0 AND rest > 0, (aft / 14) / (rest / rd), NULL) ar
  FROM pv CROSS JOIN UNNEST([st, 'all']) s2),
g AS (
  SELECT seg, grp, st, v, r, SUM(w) n,
    SAFE_DIVIDE(SUM(w * endd) / (4 * SUM(w)), SUM(w * rest) / SUM(w * rd)) ge,
    SAFE_DIVIDE(SUM(w * aft) / (14 * SUM(w)), SUM(w * rest) / SUM(w * rd)) ga,
    SUM(w * rest) srest, SUM(w * endd) send, SUM(w * aft) saft, SUM(w * rd) srd
  FROM (
    SELECT seg, grp, st, v, r, rd, rest, endd, aft,
      CASE WHEN u < 0 THEN 1 WHEN u < 0.367879 THEN 0 WHEN u < 0.735759 THEN 1 WHEN u < 0.919699 THEN 2 WHEN u < 0.981012 THEN 3
           WHEN u < 0.996340 THEN 4 WHEN u < 0.999406 THEN 5 ELSE 6 END w
    FROM (
      SELECT pu.seg, pu.grp, pu.st, pu.v, r, pu.rd, pu.rest, pu.endd, pu.aft,
        IF(r = 0, -1, MOD(ABS(FARM_FINGERPRINT(CONCAT(CAST(pu.user_id AS STRING), '-', CAST(r AS STRING)))), 1000000) / 1e6) u
      FROM pu, UNNEST(GENERATE_ARRAY(0, 100)) AS r)
    WHERE st = 'all' OR v != '18pre')
  GROUP BY 1, 2, 3, 4, 5)
SELECT t.seg, t.st, t.v, t.r, t.n tn, c.n cn, t.ge tge, c.ge cge, t.ga tga, c.ga cga, t.srest, c.srest csrest, t.saft, c.saft csaft, t.srd, c.srd csrd
FROM g t JOIN g c ON c.seg = t.seg AND c.st = t.st AND c.v = t.v AND c.r = t.r AND t.grp = 'Test' AND c.grp = 'Control'
WHERE t.r = 0 OR t.st = 'all'
;

-- ===== q20_gpflow.sql (doc section 5.6) =====
-- **Slide 138 bars + notes.** GP received, coins bought/earned/spent pre (06-14..06-27) and post (07-07..08-04), configured prize, balances; by group × end state.  
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
ev AS (
  SELECT i.user_id, i.pdate, 'in' dir, i.source, SAFE_DIVIDE(COALESCE(i.amount, i.coins), i.coins_allowance) u
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw` i JOIN pop p ON p.user_id = i.user_id
  WHERE i.pdate BETWEEN DATE '2026-06-14' AND DATE '2026-08-04'
  UNION ALL
  SELECT o.user_id, o.pdate, 'out', o.source, SAFE_DIVIDE(COALESCE(o.amount, o.coins), o.coins_allowance)
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw` o JOIN pop p ON p.user_id = o.user_id
  WHERE o.pdate BETWEEN DATE '2026-06-14' AND DATE '2026-08-04'),
f AS (
  SELECT user_id,
    SUM(IF(dir='in' AND source='album completed' AND pdate BETWEEN DATE '2026-06-28' AND DATE '2026-07-06', u, 0)) gp18,
    SUM(IF(dir='in' AND source='album completed' AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', u, 0)) gp19,
    SUM(IF(dir='in' AND source IN ('purchase','purchase_gift','store bundle gift') AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', u, 0)) buy_post,
    SUM(IF(dir='in' AND source NOT IN ('purchase','purchase_gift','store bundle gift','album completed') AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', u, 0)) earn_post,
    SUM(IF(dir='out' AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', u, 0)) out_post,
    SUM(IF(dir='out' AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-07-13', u, 0)) out_w1,
    SUM(IF(dir='in' AND source IN ('purchase','purchase_gift','store bundle gift') AND pdate BETWEEN DATE '2026-07-07' AND DATE '2026-07-13', u, 0)) buy_w1,
    SUM(IF(dir='in' AND source IN ('purchase','purchase_gift','store bundle gift') AND pdate BETWEEN DATE '2026-06-14' AND DATE '2026-06-27', u, 0)) buy_pre,
    SUM(IF(dir='in' AND source NOT IN ('purchase','purchase_gift','store bundle gift','album completed') AND pdate BETWEEN DATE '2026-06-14' AND DATE '2026-06-27', u, 0)) earn_pre,
    SUM(IF(dir='out' AND pdate BETWEEN DATE '2026-06-14' AND DATE '2026-06-27', u, 0)) out_pre,
    COUNTIF(u_raw < 0 OR u_raw > 1000) clipped
  FROM (SELECT user_id,pdate,dir,source,u AS u_raw, IF(u BETWEEN 0 AND 1000, u, 0) AS u FROM ev) ev
  GROUP BY 1),
ac AS (
  SELECT c.user_id,
    ANY_VALUE(SAFE_DIVIDE(SAFE_CAST(REGEXP_EXTRACT(c.album_grand_prize, r'Coins: (\d+)') AS FLOAT64), c.coins_allowance)) gp_cfg,
    ANY_VALUE(c.coins_balance_in_allowance) bal_ac, ANY_VALUE(SAFE_DIVIDE(c.coins_balance, c.coins_allowance)) bal_ac_calc,
    ANY_VALUE(c.pdate) ac_date
  FROM `domino-dreams-dbt.prod_10_staging.stg_album_completed_vw` c JOIN pop p ON p.user_id = c.user_id
  WHERE c.pdate BETWEEN DATE '2026-06-28' AND DATE '2026-07-06' AND c.album_id = 18
  GROUP BY 1),
rv AS (
  SELECT r.user_id, r.date_dim, r.coins_balance_in_allowance_end_day b
  FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_balance` r JOIN pop p ON p.user_id = r.user_id
  WHERE r.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-06'),
u AS (
  SELECT p.seg, p.grp, p.st, p.user_id,
    IFNULL(f.gp18,0) gp18, IFNULL(f.gp19,0) gp19, IFNULL(f.buy_post,0) buy_post, IFNULL(f.earn_post,0) earn_post, IFNULL(f.out_post,0) out_post,
    IFNULL(f.out_w1,0) out_w1, IFNULL(f.buy_w1,0) buy_w1, IFNULL(f.buy_pre,0) buy_pre, IFNULL(f.earn_pre,0) earn_pre, IFNULL(f.out_pre,0) out_pre,
    IFNULL(f.clipped,0) clipped, ac.gp_cfg, ac.bal_ac, ac.bal_ac_calc, rvac.b rv_ac, rv6.b rv_0706,
    ac.user_id IS NOT NULL has_ac
  FROM pop p LEFT JOIN f USING (user_id) LEFT JOIN ac USING (user_id)
  LEFT JOIN rv rvac ON rvac.user_id = p.user_id AND rvac.date_dim = ac.ac_date
  LEFT JOIN rv rv6 ON rv6.user_id = p.user_id AND rv6.date_dim = DATE '2026-07-06'),
lng AS (
  SELECT seg, grp, st, metric, val FROM u
  UNPIVOT (val FOR metric IN (gp18, gp19, buy_post, earn_post, out_post, out_w1, buy_w1, buy_pre, earn_pre, out_pre, gp_cfg, bal_ac, bal_ac_calc, rv_ac, rv_0706))),
cut AS (SELECT seg, grp, st, metric, APPROX_QUANTILES(val, 100)[OFFSET(99)] p99 FROM lng GROUP BY 1,2,3,4)
SELECT l.seg, l.grp, l.st, l.metric, COUNT(*) n_nonnull, COUNTIF(l.val > 0) n_pos, SUM(l.val) s,
  APPROX_QUANTILES(l.val, 2)[OFFSET(1)] med, APPROX_QUANTILES(IF(l.val > 0, l.val, NULL), 2)[OFFSET(1)] med_pos,
  ANY_VALUE(c.p99) p99, AVG(IF(l.val <= c.p99, l.val, NULL)) tmean
FROM lng l JOIN cut c USING (seg, grp, st, metric)
GROUP BY 1,2,3,4
UNION ALL
SELECT seg, grp, st, 'n_users', COUNT(*), COUNTIF(has_ac), SUM(clipped), NULL, NULL, NULL,
  CORR(bal_ac, rv_ac) FROM u GROUP BY 1,2,3
;

-- ===== q21_balval.sql (doc section 5.7) =====
-- Validates `int_rv_user_daily_coins_balance` against the last staging balance of the day (07-06, 08-04). Supports R21.  
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
ev AS (
  SELECT i.user_id, i.pdate, i.timestamp ts, i.coins_balance_in_allowance b, SAFE_DIVIDE(i.coins_balance, i.coins_allowance) bc
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw` i JOIN pop p ON p.user_id = i.user_id
  WHERE i.pdate IN (DATE '2026-07-06', DATE '2026-08-04')
  UNION ALL
  SELECT o.user_id, o.pdate, o.timestamp, o.coins_balance_in_allowance, SAFE_DIVIDE(o.coins_balance, o.coins_allowance)
  FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw` o JOIN pop p ON p.user_id = o.user_id
  WHERE o.pdate IN (DATE '2026-07-06', DATE '2026-08-04')),
last AS (
  SELECT user_id, pdate, ARRAY_AGG(b ORDER BY ts DESC LIMIT 1)[OFFSET(0)] lb, ARRAY_AGG(bc ORDER BY ts DESC LIMIT 1)[OFFSET(0)] lbc FROM ev GROUP BY 1,2),
rv AS (
  SELECT r.user_id, r.date_dim, r.coins_balance_in_allowance_end_day b
  FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_balance` r JOIN pop p ON p.user_id = r.user_id
  WHERE r.date_dim IN (DATE '2026-07-06', DATE '2026-08-04')),
j AS (
  SELECT p.seg, p.grp, d, l.lb sb, l.lbc sbc, rv.b rb
  FROM pop p CROSS JOIN UNNEST([DATE '2026-07-06', DATE '2026-08-04']) d
  LEFT JOIN last l ON l.user_id = p.user_id AND l.pdate = d
  LEFT JOIN rv ON rv.user_id = p.user_id AND rv.date_dim = d)
SELECT seg, grp, d, COUNT(*) n, COUNTIF(sb IS NOT NULL) n_stg, COUNTIF(rb IS NOT NULL) n_rv,
  COUNTIF(sb IS NOT NULL AND rb IS NOT NULL) n_both, COUNTIF(sb IS NOT NULL AND rb IS NULL) stg_only, COUNTIF(sb IS NULL AND rb IS NOT NULL) rv_only,
  COUNTIF(ABS(sb - rb) <= 0.5) n_match05, COUNTIF(ABS(sb - rb) <= 0.01 * GREATEST(ABS(sb), 1)) n_match1pct,
  COUNTIF(ABS(sb - sbc) <= 0.01) n_stg_internal,
  APPROX_QUANTILES(IF(rb IS NOT NULL, sb, NULL), 2)[OFFSET(1)] med_stg, APPROX_QUANTILES(IF(sb IS NOT NULL, rb, NULL), 2)[OFFSET(1)] med_rv,
  AVG(IF(rb IS NOT NULL, sb, NULL)) mean_stg, AVG(IF(sb IS NOT NULL, rb, NULL)) mean_rv,
  APPROX_QUANTILES(rb, 2)[OFFSET(1)] med_rv_all, AVG(rb) mean_rv_all
FROM j GROUP BY 1,2,3 ORDER BY 1,2,3
;

-- ===== q26_daily_lines.sql (doc section 5.8) =====
-- Daily $ per player on the level-35+ proxy population (the comparison for q27).  
-- q26: Easy $ per player per day, 3 locked (Test, MOD(sid,997)<498) vs 5 locked (Control).
-- Population = exactly q23_phase_pt pop (album 18 players, active 06-28..07-05, level 35+, Easy,
-- no special users, no suspected cheaters 05-11..08-04). Fixed denominator = group size.
-- SELECT only; no writes.
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg = 'Easy'),
gs AS (SELECT grp, COUNT(*) n FROM pop GROUP BY 1),
d AS (
  SELECT p.grp, m.date_dim dd, SUM(m.user_daily_inapp_purchase_amount) rev, COUNT(DISTINCT m.user_id) payers
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN pop p ON p.user_id = m.user_id
  WHERE m.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07' AND m.user_daily_inapp_purchase_amount > 0
  GROUP BY 1, 2)
SELECT d.grp, d.dd, gs.n, d.rev, d.payers, d.rev / gs.n AS rev_pp, d.payers / gs.n AS payer_rate
FROM d JOIN gs USING (grp)
ORDER BY d.dd, d.grp
;

-- ===== q18_stock.sql (doc section 5.9) =====
-- Calendar-baseline post-test comparison (superseded by q23–q25), weekly gaps, coin balances, album 19 outcomes by group (R23, R24).  
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    SUM(IF(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', IFNULL(a.album_spent_today, 0), 0)) AS r_win,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
m AS (
  SELECT m.user_id,
    MAX(IF(m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', m.level_id_end_day, NULL)) AS lvl,
    SUM(IF(m.date_dim BETWEEN DATE '2026-05-31' AND DATE '2026-06-27', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS pre4,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-07' AND DATE '2026-08-04', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS post,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-07' AND DATE '2026-07-13', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS w1,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-14' AND DATE '2026-07-20', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS w2,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-21' AND DATE '2026-07-27', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS w3,
    SUM(IF(m.date_dim BETWEEN DATE '2026-07-28' AND DATE '2026-08-04', IFNULL(m.user_daily_inapp_purchase_amount, 0), 0)) AS w4
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-05-31' AND DATE '2026-08-04'
  GROUP BY 1),
cb AS (
  SELECT c.user_id,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-06-27', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0627,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-07-06', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0706,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-07-13', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0713,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-07-20', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0720,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-07-27', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0727,
    ARRAY_AGG(IF(c.date_dim <= DATE '2026-08-04', c.coins_balance_in_allowance_end_day, NULL) IGNORE NULLS ORDER BY c.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] b0804
  FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_balance` c JOIN a USING (user_id)
  WHERE c.date_dim BETWEEN DATE '2026-06-13' AND DATE '2026-08-04'
  GROUP BY 1),
a19 AS (
  SELECT b.user_id,
    MAX(IF(b.date_dim <= DATE '2026-08-23', b.unique_album_stickers_lt, NULL)) uq19,
    SUM(IF(b.date_dim <= DATE '2026-08-23', IFNULL(b.album_spent_today, 0), 0)) r19,
    ANY_VALUE(b.album_segment) seg19
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` b JOIN a USING (user_id)
  WHERE b.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-08-24' AND b.album_id = 19
  GROUP BY 1),
u AS (
  SELECT a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,  -- flipped to match Mixpanel labels
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st,
    a.r_win, IFNULL(m.pre4,0) pre4, IFNULL(m.post,0) post, IFNULL(m.w1,0) w1, IFNULL(m.w2,0) w2, IFNULL(m.w3,0) w3, IFNULL(m.w4,0) w4,
    cb.b0627, cb.b0706, cb.b0713, cb.b0720, cb.b0727, cb.b0804,
    a19.uq19, IFNULL(a19.r19, 0) r19, a19.seg19
  FROM a LEFT JOIN m USING (user_id) LEFT JOIN cb USING (user_id) LEFT JOIN a19 USING (user_id)
  WHERE a.sid IS NOT NULL AND IFNULL(m.lvl, 0) >= 35 AND a.seg IN ('Easy','Hard'))
SELECT seg, grp, st, COUNT(*) n,
  SUM(r_win) s_win, SUM(pre4) s_pre4, SUM(pre4*pre4) q_pre4, SUM(post) s_post, SUM(post*post) q_post,
  SUM(post*pre4) x_pp,
  SUM(w1) s_w1, SUM(w1*w1) q_w1, SUM(w2) s_w2, SUM(w2*w2) q_w2, SUM(w3) s_w3, SUM(w3*w3) q_w3, SUM(w4) s_w4, SUM(w4*w4) q_w4,
  COUNTIF(post > 0) post_payers, COUNTIF(pre4 > 0) pre_payers,
  COUNT(b0706) nb, AVG(b0627) b0627, AVG(b0706) b0706, AVG(b0713) b0713, AVG(b0720) b0720, AVG(b0727) b0727, AVG(b0804) b0804,
  APPROX_QUANTILES(b0706, 2)[OFFSET(1)] med_b0706, APPROX_QUANTILES(b0627, 2)[OFFSET(1)] med_b0627,
  COUNT(uq19) n19, COUNTIF(uq19 >= 144) fin19, COUNTIF(144 - uq19 BETWEEN 1 AND 2) m12_19, COUNTIF(144 - uq19 BETWEEN 3 AND 5) m35_19,
  COUNTIF(144 - uq19 = 3) m3_19, COUNTIF(144 - uq19 = 5) m5_19, SUM(r19) s_r19,
  COUNTIF(LOWER(seg19) LIKE '%easy%') easy19
FROM u GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
;

-- ===== q13_aa.sql (doc section 5.10) =====
-- A/A noise check: 200 random 50/50 splits of Easy album 18 players (R6).  
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
e AS (
  SELECT a.user_id, SUM(IF(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', IFNULL(a.album_spent_today, 0), 0)) AS r_test8,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-06') AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL AND LOWER(a.album_segment) LIKE '%easy%'
  GROUP BY 1 HAVING act),
m AS (
  SELECT m.user_id, SUM(IFNULL(m.user_daily_inapp_purchase_amount, 0)) AS r_long
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN e USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-08-04'
  GROUP BY 1),
u AS (SELECT e.user_id, e.r_test8, IFNULL(m.r_long, 0) AS r_long FROM e LEFT JOIN m USING (user_id)),
s AS (SELECT seed FROM UNNEST(GENERATE_ARRAY(1, 200)) seed),
g AS (
  SELECT seed, MOD(ABS(FARM_FINGERPRINT(CONCAT(CAST(user_id AS STRING), '-', CAST(seed AS STRING)))), 2) AS grp,
    COUNT(*) AS n, SUM(r_test8) AS r8, SUM(r_long) AS rl
  FROM u CROSS JOIN s GROUP BY 1, 2)
SELECT seed, MAX(IF(grp = 0, n, NULL)) AS n0, MAX(IF(grp = 1, n, NULL)) AS n1,
  MAX(IF(grp = 0, r8 / n, NULL)) / MAX(IF(grp = 1, r8 / n, NULL)) - 1 AS d8,
  MAX(IF(grp = 0, rl / n, NULL)) / MAX(IF(grp = 1, rl / n, NULL)) - 1 AS dl,
  SUM(r8) AS r8_tot, SUM(rl) AS rl_tot, SUM(n) AS n_tot
FROM g GROUP BY 1
;

-- ===== q16_ids.sql (doc section 5.11) =====
-- [DIAG] Group assignment check: server_user_id vs user_id bucketing, active and finisher counts per bucket side.  
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) sid,
    MAX(IF(a.date_dim <= DATE '2026-07-06', a.unique_album_stickers_lt, NULL)) uq,
    MIN(IF(a.unique_album_stickers_lt >= 168, a.date_dim, NULL)) fin_date,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-06' AND a.active_flag) act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18
    AND LOWER(a.album_segment) LIKE '%easy%'
  GROUP BY 1)
SELECT IF(MOD(sid,997)<498,'C_by_sid','T_by_sid') g_sid,
  IF(MOD(SAFE_CAST(user_id AS INT64),997)<498,'C_by_uid','T_by_uid') g_uid,
  COUNTIF(act) active, COUNTIF(fin_date BETWEEN DATE '2026-06-28' AND DATE '2026-07-06') fin_win,
  COUNTIF(SAFE_CAST(user_id AS INT64) IS NULL) uid_not_int, COUNTIF(SAFE_CAST(user_id AS INT64) = sid) uid_eq_sid
FROM a GROUP BY 1,2 ORDER BY 1,2
;

-- ===== q15_set11.sql (doc section 5.12) =====
-- [DIAG] Set 11/12 completion by group and date (only Test could complete Set 11 from 06-28).  
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%','Easy','Hard') seg,
    LOGICAL_OR(IFNULL(a.is_11th_set_completed_flag,FALSE)) s11,
    LOGICAL_OR(IFNULL(a.is_12th_set_completed_flag,FALSE)) s12,
    MAX(a.sets_completed_lt) sets,
    MIN(IF(a.is_11th_set_completed_flag, a.date_dim, NULL)) s11_date,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
  GROUP BY 1 HAVING act)
SELECT seg, IF(MOD(sid,997)<498,'Control','Test') grp, COUNT(*) n, COUNTIF(s11) s11, COUNTIF(s12) s12,
  COUNTIF(s11_date < DATE '2026-06-28') s11_before, COUNTIF(s11_date >= DATE '2026-06-28') s11_after, AVG(sets) avg_sets
FROM a WHERE sid IS NOT NULL GROUP BY 1,2 ORDER BY 1,2
;

-- ===== q22_dates.sql (doc section 5.13) =====
-- [DIAG] Album date ranges 16–21 in user_daily_album.  
SELECT album_id, MIN(date_dim) d0, MAX(date_dim) d1, COUNT(DISTINCT date_dim) nd
FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-27' AND album_id BETWEEN 16 AND 21
GROUP BY 1 ORDER BY 1
;

-- ===== q12_segs18.sql (doc section 5.14) =====
-- [DIAG] Album 18/19 segment sizes.  
SELECT album_id, album_segment, COUNT(DISTINCT user_id) AS users, MIN(date_dim) AS first_d, MAX(date_dim) AS last_d
FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-24' AND album_id IN (18, 19) AND special_user_flag = FALSE
GROUP BY 1, 2 ORDER BY 1, 3 DESC
;

-- ===== q19_gp.sql (doc section 5.15) =====
-- [DIAG] Configured grand prize per segment (album_grand_prize, allowance).  
SELECT album_grand_prize, album_segment, COUNT(*) ev, COUNT(DISTINCT user_id) users, MIN(pdate) d0, MAX(pdate) d1,
  APPROX_QUANTILES(coins_allowance, 2)[OFFSET(1)] med_allow
FROM `domino-dreams-dbt.prod_10_staging.stg_album_completed_vw`
WHERE pdate BETWEEN DATE '2026-05-11' AND DATE '2026-07-07' AND album_id = 18
GROUP BY 1,2 ORDER BY ev DESC LIMIT 40
;

-- ===== q19_src.sql (doc section 5.16) =====
-- [DIAG] Coin-in/out sources on 07-07 (to pick 'album completed' and purchase sources).  
SELECT 'in' dir, source, COUNT(*) ev, COUNT(DISTINCT user_id) users,
  SUM(SAFE_DIVIDE(COALESCE(amount, coins), coins_allowance)) units,
  APPROX_QUANTILES(SAFE_DIVIDE(COALESCE(amount, coins), coins_allowance), 2)[OFFSET(1)] med_units
FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw`
WHERE pdate = DATE '2026-07-07'
GROUP BY 1,2
UNION ALL
SELECT 'out', source, COUNT(*), COUNT(DISTINCT user_id),
  SUM(SAFE_DIVIDE(COALESCE(amount, coins), coins_allowance)),
  APPROX_QUANTILES(SAFE_DIVIDE(COALESCE(amount, coins), coins_allowance), 2)[OFFSET(1)]
FROM `domino-dreams-dbt.prod_10_staging.stg_coins_out_vw`
WHERE pdate = DATE '2026-07-07'
GROUP BY 1,2
ORDER BY 1, units DESC
;

-- ===== q14_cols.sql (doc section 5.17) =====
-- [DIAG] Schema lookup: level/server/sticker columns.  
SELECT table_name, column_name, data_type FROM `domino-dreams-dbt.prod_40_mart.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name IN ('user_daily_metrics','user_daily_album') AND (LOWER(column_name) LIKE '%level%' OR LOWER(column_name) LIKE '%server%' OR LOWER(column_name) LIKE '%golden%' OR LOWER(column_name) LIKE '%dup%' OR LOWER(column_name) LIKE '%complet%' OR LOWER(column_name) LIKE '%sticker%')
;

-- ===== q17_cols.sql (doc section 5.18) =====
-- [DIAG] Schema lookup: coin/balance/allowance columns.  
SELECT 'mart' ds, table_name, column_name FROM `domino-dreams-dbt.prod_40_mart.INFORMATION_SCHEMA.COLUMNS`
WHERE REGEXP_CONTAINS(LOWER(column_name), r'coin|balance|allowance')
UNION ALL
SELECT 'int', table_name, column_name FROM `domino-dreams-dbt.prod_30_intermediate.INFORMATION_SCHEMA.COLUMNS`
WHERE REGEXP_CONTAINS(LOWER(column_name), r'coin|balance|allowance')
;

-- ===== delta.sql (doc section 5.19) =====
-- (review recompute)
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%easy%', 'Easy', IF(LOWER(ANY_VALUE(a.album_segment)) LIKE '%hard%', 'Hard', 'Other')) AS seg,
    MAX(IF(a.date_dim <= DATE '2026-07-05', a.unique_album_stickers_lt, NULL)) AS uniq_end,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1),
pop AS (
  SELECT a.user_id, a.seg, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp,
    CASE WHEN 168 - IFNULL(a.uniq_end, 0) <= 0 THEN 'fin' WHEN 168 - IFNULL(a.uniq_end, 0) <= 2 THEN 'm12'
         WHEN 168 - IFNULL(a.uniq_end, 0) <= 5 THEN 'm35' ELSE 'm6' END AS st
  FROM a JOIN lv USING (user_id)
  WHERE a.sid IS NOT NULL AND lv.lvl >= 35 AND a.seg IN ('Easy','Hard')),
alb AS (
  SELECT a, s, c FROM UNNEST([STRUCT(17 AS a, DATE '2026-04-02' AS s, DATE '2026-05-11' AS c),
    STRUCT(18, DATE '2026-05-11', DATE '2026-07-06'), STRUCT(19, DATE '2026-07-06', DATE '2026-08-24')])),
ua AS (
  SELECT x.user_id, x.album_id a, MIN(x.date_dim) f
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x JOIN pop p ON p.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-24' AND x.album_id IN (17, 18, 19)
  GROUP BY 1, 2),
m AS (
  SELECT d.user_id, d.date_dim dd, d.user_daily_inapp_purchase_amount amt
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` d JOIN pop p ON p.user_id = d.user_id
  WHERE d.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07' AND d.user_daily_inapp_purchase_amount > 0),
pa AS (
  SELECT p.user_id, p.seg, p.grp, p.st, alb.a, alb.c, GREATEST(ua.f, DATE_ADD(alb.s, INTERVAL 1 DAY)) f2
  FROM pop p JOIN ua USING (user_id) JOIN alb ON alb.a = ua.a),
pu0 AS (
  SELECT pa.user_id, ANY_VALUE(pa.seg) seg, ANY_VALUE(pa.grp) grp, ANY_VALUE(pa.st) st, pa.a,
    GREATEST(DATE_DIFF(DATE_SUB(ANY_VALUE(pa.c), INTERVAL 4 DAY), ANY_VALUE(pa.f2), DAY) + 1, 0) rd,
    GREATEST(DATE_DIFF(DATE '2026-06-27', ANY_VALUE(pa.f2), DAY) + 1, 0) rdp,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE_SUB(pa.c, INTERVAL 4 DAY), m.amt, 0)) rest,
    SUM(IF(m.dd BETWEEN pa.f2 AND DATE '2026-06-27', m.amt, 0)) restp,
    SUM(IF(m.dd BETWEEN DATE_SUB(pa.c, INTERVAL 3 DAY) AND pa.c, m.amt, 0)) endd,
    SUM(IF(m.dd BETWEEN DATE_ADD(pa.c, INTERVAL 1 DAY) AND DATE_ADD(pa.c, INTERVAL 14 DAY), m.amt, 0)) aft
  FROM pa LEFT JOIN m ON m.user_id = pa.user_id AND m.dd BETWEEN pa.f2 AND DATE_ADD(pa.c, INTERVAL 14 DAY)
  GROUP BY pa.user_id, pa.a),

pp AS (
  SELECT user_id, ANY_VALUE(grp) grp,
    SUM(IF(a=17,aft,0)) A17, SUM(IF(a=17,rest,0)) R17, SUM(IF(a=17,rd,0)) D17, COUNTIF(a=17) I17,
    SUM(IF(a=18,aft,0)) A18, SUM(IF(a=18,rest,0)) R18, SUM(IF(a=18,rd,0)) D18,
    SUM(IF(a=19,aft,0)) A19, SUM(IF(a=19,rest,0)) R19, SUM(IF(a=19,rd,0)) D19, COUNTIF(a=19) I19
  FROM pu0 WHERE seg='Easy' GROUP BY 1)
SELECT grp, COUNT(*) N, SUM(A17) s_A17, SUM(R17) s_R17, SUM(D17) s_D17, SUM(I17) s_I17, SUM(A18) s_A18, SUM(R18) s_R18, SUM(D18) s_D18, SUM(A19) s_A19, SUM(R19) s_R19, SUM(D19) s_D19, SUM(I19) s_I19, SUM(A17*A17) x_A17_A17, SUM(A17*R17) x_A17_R17, SUM(A17*D17) x_A17_D17, SUM(A17*I17) x_A17_I17, SUM(A17*A18) x_A17_A18, SUM(A17*R18) x_A17_R18, SUM(A17*D18) x_A17_D18, SUM(A17*A19) x_A17_A19, SUM(A17*R19) x_A17_R19, SUM(A17*D19) x_A17_D19, SUM(A17*I19) x_A17_I19, SUM(R17*R17) x_R17_R17, SUM(R17*D17) x_R17_D17, SUM(R17*I17) x_R17_I17, SUM(R17*A18) x_R17_A18, SUM(R17*R18) x_R17_R18, SUM(R17*D18) x_R17_D18, SUM(R17*A19) x_R17_A19, SUM(R17*R19) x_R17_R19, SUM(R17*D19) x_R17_D19, SUM(R17*I19) x_R17_I19, SUM(D17*D17) x_D17_D17, SUM(D17*I17) x_D17_I17, SUM(D17*A18) x_D17_A18, SUM(D17*R18) x_D17_R18, SUM(D17*D18) x_D17_D18, SUM(D17*A19) x_D17_A19, SUM(D17*R19) x_D17_R19, SUM(D17*D19) x_D17_D19, SUM(D17*I19) x_D17_I19, SUM(I17*I17) x_I17_I17, SUM(I17*A18) x_I17_A18, SUM(I17*R18) x_I17_R18, SUM(I17*D18) x_I17_D18, SUM(I17*A19) x_I17_A19, SUM(I17*R19) x_I17_R19, SUM(I17*D19) x_I17_D19, SUM(I17*I19) x_I17_I19, SUM(A18*A18) x_A18_A18, SUM(A18*R18) x_A18_R18, SUM(A18*D18) x_A18_D18, SUM(A18*A19) x_A18_A19, SUM(A18*R19) x_A18_R19, SUM(A18*D19) x_A18_D19, SUM(A18*I19) x_A18_I19, SUM(R18*R18) x_R18_R18, SUM(R18*D18) x_R18_D18, SUM(R18*A19) x_R18_A19, SUM(R18*R19) x_R18_R19, SUM(R18*D19) x_R18_D19, SUM(R18*I19) x_R18_I19, SUM(D18*D18) x_D18_D18, SUM(D18*A19) x_D18_A19, SUM(D18*R19) x_D18_R19, SUM(D18*D19) x_D18_D19, SUM(D18*I19) x_D18_I19, SUM(A19*A19) x_A19_A19, SUM(A19*R19) x_A19_R19, SUM(A19*D19) x_A19_D19, SUM(A19*I19) x_A19_I19, SUM(R19*R19) x_R19_R19, SUM(R19*D19) x_R19_D19, SUM(R19*I19) x_R19_I19, SUM(D19*D19) x_D19_D19, SUM(D19*I19) x_D19_I19, SUM(I19*I19) x_I19_I19
FROM pp GROUP BY 1 ORDER BY 1
;
