-- 2026-10-26 Domino: album-end lift (Eden's success metrics). Albums 18, 19, 20. Game level, special + suspected-cheater users excluded.
-- Last 4 = the 4 full days before the close day (close-4 .. close-1; the partial close day is left out). Rest = open .. close-5.
-- Active players = pau_flag; revenue = in-app + Stripe gross. Lift = average per day in the last 4 vs average per day in the rest, in %.
-- Q1 (lift + split into active players x revenue per active player), Q2 (calendar control: the same Thursday-Sunday lift in the earlier weeks of each album;
--   all three albums close on a Monday, so close-4..close-1 is Thursday-Sunday). Results: claude/domino-dx-end-lift-2026-10-26.md
-- Q1
WITH al AS (
  SELECT 18 AS album_id, DATE '2026-05-11' AS d0, DATE '2026-07-06' AS d1 UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
m AS (
  SELECT a.album_id, a.d1, u.date_dim,
    IFNULL(u.user_daily_inapp_purchase_amount,0) + IFNULL(u.user_daily_stripe_amount,0) AS rev,
    IFNULL(u.pau_flag,FALSE) AS act, IFNULL(u.pu_flag,FALSE) AS pu
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` u
  JOIN al a ON u.date_dim >= a.d0 AND u.date_dim < a.d1
  WHERE u.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-12'
    AND NOT IFNULL(u.special_user_flag,FALSE) AND NOT IFNULL(u.suspected_cheater_flag,FALSE)
),
d AS (
  SELECT album_id, date_dim, IF(date_dim >= DATE_SUB(ANY_VALUE(d1), INTERVAL 4 DAY), 'last4', 'rest') AS per,
    COUNTIF(act) AS dau, COUNTIF(pu) AS payers, SUM(rev) AS rev
  FROM m GROUP BY album_id, date_dim
),
a AS (
  SELECT album_id, per, COUNT(*) AS days, AVG(dau) AS dau, AVG(payers) AS payers, AVG(rev) AS rev, SUM(rev) / SUM(dau) AS arpdau, AVG(payers / dau) AS pau_rate
  FROM d GROUP BY 1,2
)
SELECT l.album_id, l.days AS last_days, r.days AS rest_days,
  ROUND(r.dau) AS dau_rest, ROUND(l.dau) AS dau_last4, ROUND(100 * (l.dau / r.dau - 1), 1) AS dau_lift_pct,
  ROUND(r.rev) AS rev_day_rest, ROUND(l.rev) AS rev_day_last4, ROUND(100 * (l.rev / r.rev - 1), 1) AS rev_lift_pct,
  ROUND(r.arpdau, 3) AS arpdau_rest, ROUND(l.arpdau, 3) AS arpdau_last4, ROUND(100 * (l.arpdau / r.arpdau - 1), 1) AS arpdau_lift_pct,
  ROUND(100 * r.pau_rate, 2) AS pay_share_rest, ROUND(100 * l.pau_rate, 2) AS pay_share_last4
FROM a l JOIN a r ON l.album_id = r.album_id AND l.per = 'last4' AND r.per = 'rest' ORDER BY 1;
-- Q2
WITH al AS (
  SELECT 18 AS album_id, DATE '2026-05-11' AS d0, DATE '2026-07-06' AS d1 UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
m AS (
  SELECT a.album_id, DATE_DIFF(a.d1, u.date_dim, DAY) AS k, u.date_dim,
    SUM(IFNULL(u.user_daily_inapp_purchase_amount,0) + IFNULL(u.user_daily_stripe_amount,0)) AS rev,
    COUNTIF(IFNULL(u.pau_flag,FALSE)) AS dau
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` u
  JOIN al a ON u.date_dim >= a.d0 AND u.date_dim < a.d1
  WHERE u.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-12'
    AND NOT IFNULL(u.special_user_flag,FALSE) AND NOT IFNULL(u.suspected_cheater_flag,FALSE)
  GROUP BY 1,2,3
),
blocks AS (SELECT j FROM UNNEST(GENERATE_ARRAY(0, 6)) AS j),
x AS (
  SELECT m.album_id, b.j,
    AVG(IF(m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4, m.rev, NULL)) AS rev_blk,
    AVG(IF(m.k NOT BETWEEN 7*b.j + 1 AND 7*b.j + 4 AND m.k > 4 OR (b.j = 0 AND m.k > 4), m.rev, NULL)) AS rev_oth,
    AVG(IF(m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4, m.dau, NULL)) AS dau_blk,
    AVG(IF(m.k NOT BETWEEN 7*b.j + 1 AND 7*b.j + 4 AND m.k > 4 OR (b.j = 0 AND m.k > 4), m.dau, NULL)) AS dau_oth,
    COUNTIF(m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4) AS n_blk
  FROM m CROSS JOIN blocks b GROUP BY 1,2
)
SELECT album_id, j AS weeks_before_final, n_blk,
  ROUND(100 * (rev_blk / rev_oth - 1), 1) AS rev_lift_pct, ROUND(100 * (dau_blk / dau_oth - 1), 1) AS dau_lift_pct
FROM x WHERE n_blk = 4 ORDER BY 1, 2;

-- ===== Easy / Hard version (Eden's second request, 2026-10-26) =====
-- Population (does not depend on finishing, reaching the gate or end-of-album activity): all players with a row in the album table for the album,
--   segment = album_segment on the first row (Easy / Hard), not a first-album player (user_album_count > 1 on the first row), not special/suspected-cheater.
-- Daily activity and revenue from user_daily_metrics (pau_flag, in-app + Stripe) for those users on album days (open .. close-1). Last 4 = close-4 .. close-1.
-- Q3: lift table (Easy and Hard x albums 18, 19, 20) and Q4: calibration by weeks before the final (same Thursday-Sunday blocks) were run as one query each with this population;
-- their text is the same as Q1 / Q2 above with the user filter `JOIN p2 p ON p.user_id = u.user_id AND p.album_id = a.album_id` and the grouping by seg0.
-- Population CTE used:
--   ab AS (SELECT album_id, user_id, date_dim, album_segment AS seg, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl
--          FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-12' AND album_id IN (18,19,20) AND date_dim < album_close_date),
--   pop AS (SELECT album_id, user_id, ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%','easy',IF(LOWER(seg) LIKE '%hard%','hard','other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
--                  ARRAY_AGG(uac ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS uac0, LOGICAL_OR(excl) AS excl FROM ab GROUP BY 1,2),
--   p2 AS (SELECT * FROM pop WHERE seg0 IN ('easy','hard') AND uac0 > 1 AND NOT excl AND user_id NOT IN (SELECT user_id FROM bad))

-- ===== Album 17 (Eden: "18 was unusual, check against 17"), same Easy / Hard population and metrics. Album 17 = 2026-04-02 .. 2026-05-11 (39 days, closes on a Monday). =====
WITH al AS (
  SELECT 17 AS album_id, DATE '2026-04-02' AS d0, DATE '2026-05-11' AS d1
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-05-11' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
ab AS (
  SELECT t.album_id, t.user_id, t.date_dim, t.album_segment AS seg, IFNULL(t.user_album_count,1) AS uac, IFNULL(t.special_user_flag,FALSE) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` t
  WHERE t.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-05-11' AND t.album_id = 17 AND t.date_dim < t.album_close_date
),
pop AS (
  SELECT album_id, user_id,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', IF(LOWER(seg) LIKE '%hard%', 'hard', 'other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    ARRAY_AGG(uac ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS uac0, LOGICAL_OR(excl) AS excl
  FROM ab GROUP BY 1,2
),
p2 AS (SELECT * FROM pop WHERE seg0 IN ('easy','hard') AND uac0 > 1 AND NOT excl AND user_id NOT IN (SELECT user_id FROM bad)),
m AS (
  SELECT a.album_id, p.seg0 AS seg, u.date_dim, DATE_DIFF(a.d1, u.date_dim, DAY) AS k,
    COUNTIF(IFNULL(u.pau_flag,FALSE)) AS dau, COUNTIF(IFNULL(u.pu_flag,FALSE)) AS payers,
    SUM(IFNULL(u.user_daily_inapp_purchase_amount,0) + IFNULL(u.user_daily_stripe_amount,0)) AS rev
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` u
  JOIN al a ON u.date_dim >= a.d0 AND u.date_dim < a.d1
  JOIN p2 p ON p.user_id = u.user_id AND p.album_id = a.album_id
  WHERE u.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-05-11'
  GROUP BY 1,2,3,4
),
fin AS (
  SELECT seg, 'final' AS what, 0 AS j,
    AVG(IF(k <= 4, dau, NULL)) AS dau_l, AVG(IF(k > 4, dau, NULL)) AS dau_r,
    AVG(IF(k <= 4, rev, NULL)) AS rev_l, AVG(IF(k > 4, rev, NULL)) AS rev_r,
    SUM(IF(k <= 4, rev, 0)) / SUM(IF(k <= 4, dau, 0)) AS arpdau_l, SUM(IF(k > 4, rev, 0)) / SUM(IF(k > 4, dau, 0)) AS arpdau_r,
    AVG(IF(k <= 4, payers / dau, NULL)) AS ps_l, AVG(IF(k > 4, payers / dau, NULL)) AS ps_r
  FROM m GROUP BY 1
),
blocks AS (SELECT j FROM UNNEST(GENERATE_ARRAY(1, 3)) AS j),
x AS (
  SELECT m.seg, 'week_before' AS what, b.j,
    AVG(IF(m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4, m.dau, NULL)) AS dau_l,
    AVG(IF(NOT (m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4) AND m.k > 4, m.dau, NULL)) AS dau_r,
    AVG(IF(m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4, m.rev, NULL)) AS rev_l,
    AVG(IF(NOT (m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4) AND m.k > 4, m.rev, NULL)) AS rev_r,
    CAST(NULL AS FLOAT64) AS arpdau_l, CAST(NULL AS FLOAT64) AS arpdau_r, CAST(NULL AS FLOAT64) AS ps_l, CAST(NULL AS FLOAT64) AS ps_r
  FROM m CROSS JOIN blocks b GROUP BY 1,2,3
),
u AS (SELECT * FROM fin UNION ALL SELECT * FROM x)
SELECT seg, what, j, (SELECT COUNT(*) FROM p2 WHERE p2.seg0 = u.seg) AS players_in_pop,
  ROUND(dau_r) AS dau_rest, ROUND(dau_l) AS dau_last, ROUND(100 * (dau_l / dau_r - 1), 1) AS dau_lift_pct,
  ROUND(rev_r) AS rev_rest, ROUND(rev_l) AS rev_last, ROUND(100 * (rev_l / rev_r - 1), 1) AS rev_lift_pct,
  ROUND(100 * (arpdau_l / arpdau_r - 1), 1) AS arpdau_lift_pct, ROUND(100 * ps_r, 2) AS pay_share_rest, ROUND(100 * ps_l, 2) AS pay_share_last
FROM u ORDER BY seg, what, j;

-- ===== FINAL VERSION (Eden: population = logged in on over half of the album days), albums 17-20, Easy and Hard =====
-- Population: not first album (user_album_count > 1 on the first row), not special/suspected-cheater, login_ratio >= 0.5 on the last row before close,
--   a row on the day before close; segment from the first row. Does not depend on finishing or reaching the gate.
-- Q5: lift table
WITH al AS (
  SELECT 17 AS album_id, DATE '2026-04-02' AS d0, DATE '2026-05-11' AS d1 UNION ALL
  SELECT 18, DATE '2026-05-11', DATE '2026-07-06' UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
ab AS (
  SELECT t.album_id, t.user_id, t.date_dim, t.album_segment AS seg, IFNULL(t.user_album_count,1) AS uac, IFNULL(t.special_user_flag,FALSE) AS excl, t.login_ratio AS lr, a.d1
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` t JOIN al a ON t.album_id = a.album_id
  WHERE t.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND t.date_dim >= a.d0 AND t.date_dim < a.d1
),
pop AS (
  SELECT album_id, user_id,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', IF(LOWER(seg) LIKE '%hard%', 'hard', 'other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    ARRAY_AGG(uac ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS uac0, LOGICAL_OR(excl) AS excl,
    MAX(date_dim) AS last_d, ANY_VALUE(d1) AS d1,
    ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS lr_last
  FROM ab GROUP BY 1,2
),
p2 AS (
  SELECT album_id, user_id, seg0 FROM pop
  WHERE seg0 IN ('easy','hard') AND uac0 > 1 AND NOT excl AND lr_last >= 0.5 AND last_d = DATE_SUB(d1, INTERVAL 1 DAY)
    AND user_id NOT IN (SELECT user_id FROM bad)
),
d AS (
  SELECT a.album_id, p.seg0 AS seg, u.date_dim, IF(u.date_dim >= DATE_SUB(a.d1, INTERVAL 4 DAY), 'last4', 'rest') AS per,
    COUNTIF(IFNULL(u.pau_flag,FALSE)) AS dau, COUNTIF(IFNULL(u.pu_flag,FALSE)) AS payers,
    SUM(IFNULL(u.user_daily_inapp_purchase_amount,0) + IFNULL(u.user_daily_stripe_amount,0)) AS rev
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` u
  JOIN al a ON u.date_dim >= a.d0 AND u.date_dim < a.d1
  JOIN p2 p ON p.user_id = u.user_id AND p.album_id = a.album_id
  WHERE u.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12'
  GROUP BY 1,2,3,4
),
g AS (
  SELECT album_id, seg, per, COUNT(*) AS days, AVG(dau) AS dau, AVG(rev) AS rev, SUM(rev) / SUM(dau) AS arpdau, AVG(payers / dau) AS pay_share
  FROM d GROUP BY 1,2,3
)
SELECT l.album_id, l.seg, (SELECT COUNT(*) FROM p2 WHERE p2.album_id = l.album_id AND p2.seg0 = l.seg) AS players_in_pop,
  ROUND(r.dau) AS dau_rest, ROUND(l.dau) AS dau_last4, ROUND(100 * (l.dau / r.dau - 1), 1) AS dau_lift_pct,
  ROUND(r.rev) AS rev_day_rest, ROUND(l.rev) AS rev_day_last4, ROUND(100 * (l.rev / r.rev - 1), 1) AS rev_lift_pct,
  ROUND(100 * (l.arpdau / r.arpdau - 1), 1) AS arpdau_lift_pct, ROUND(100 * r.pay_share, 2) AS pay_share_rest, ROUND(100 * l.pay_share, 2) AS pay_share_last4
FROM g l JOIN g r ON l.album_id = r.album_id AND l.seg = r.seg AND l.per = 'last4' AND r.per = 'rest'
ORDER BY l.seg, l.album_id;
-- Q6: calibration (same population): replace the final SELECT / CTEs after p2 with:
--   m AS (SELECT a.album_id, p.seg0 AS seg, DATE_DIFF(a.d1, u.date_dim, DAY) AS k, COUNTIF(IFNULL(u.pau_flag,FALSE)) AS dau,
--           SUM(IFNULL(u.user_daily_inapp_purchase_amount,0) + IFNULL(u.user_daily_stripe_amount,0)) AS rev
--         FROM user_daily_metrics u JOIN al a ON u.date_dim >= a.d0 AND u.date_dim < a.d1 JOIN p2 p ON p.user_id = u.user_id AND p.album_id = a.album_id GROUP BY 1,2,3),
--   blocks AS (SELECT j FROM UNNEST(GENERATE_ARRAY(1, 3)) AS j),
--   x AS (SELECT m.album_id, m.seg, b.j, AVG(IF(m.k BETWEEN 7*b.j+1 AND 7*b.j+4, m.rev, NULL)) AS rev_l,
--           AVG(IF(NOT (m.k BETWEEN 7*b.j+1 AND 7*b.j+4) AND m.k > 4, m.rev, NULL)) AS rev_r, (same for dau) FROM m CROSS JOIN blocks b GROUP BY 1,2,3)
--   SELECT album_id, seg, j AS weeks_before_final, ROUND(100 * (rev_l / rev_r - 1), 1) AS rev_lift_pct, ROUND(100 * (dau_l / dau_r - 1), 1) AS dau_lift_pct FROM x ORDER BY seg, album_id, j

-- Q7 (ARPDAU, Eden 2026-10-26): ARPDAU = total revenue / total active player days per window, same population as Q5. Windows: block j = days k in [7j+1, 7j+4] where k = days before the close date
-- (j = 0: last 4 full days, j = 1..3: the same Thursday-Sunday block 1..3 weeks earlier); "rest" = k > 4 and not in the block (close day excluded from both). Full text:
WITH al AS (
  SELECT 17 AS album_id, DATE '2026-04-02' AS d0, DATE '2026-05-11' AS d1 UNION ALL
  SELECT 18, DATE '2026-05-11', DATE '2026-07-06' UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
ab AS (
  SELECT t.album_id, t.user_id, t.date_dim, t.album_segment AS seg, IFNULL(t.user_album_count,1) AS uac, IFNULL(t.special_user_flag,FALSE) AS excl, t.login_ratio AS lr, a.d1
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` t JOIN al a ON t.album_id = a.album_id
  WHERE t.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND t.date_dim >= a.d0 AND t.date_dim < a.d1
),
pop AS (
  SELECT album_id, user_id,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', IF(LOWER(seg) LIKE '%hard%', 'hard', 'other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    ARRAY_AGG(uac ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS uac0, LOGICAL_OR(excl) AS excl,
    MAX(date_dim) AS last_d, ANY_VALUE(d1) AS d1, ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS lr_last
  FROM ab GROUP BY 1,2
),
p2 AS (
  SELECT album_id, user_id, seg0 FROM pop
  WHERE seg0 IN ('easy','hard') AND uac0 > 1 AND NOT excl AND lr_last >= 0.5 AND last_d = DATE_SUB(d1, INTERVAL 1 DAY)
    AND user_id NOT IN (SELECT user_id FROM bad)
),
m AS (
  SELECT a.album_id, p.seg0 AS seg, DATE_DIFF(a.d1, u.date_dim, DAY) AS k,
    COUNTIF(IFNULL(u.pau_flag,FALSE)) AS dau,
    SUM(IFNULL(u.user_daily_inapp_purchase_amount,0) + IFNULL(u.user_daily_stripe_amount,0)) AS rev
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` u
  JOIN al a ON u.date_dim >= a.d0 AND u.date_dim < a.d1
  JOIN p2 p ON p.user_id = u.user_id AND p.album_id = a.album_id
  WHERE u.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12'
  GROUP BY 1,2,3
),
blocks AS (SELECT j FROM UNNEST(GENERATE_ARRAY(0, 3)) AS j),
x AS (
  SELECT m.album_id, m.seg, b.j,
    SUM(IF(m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4, m.rev, 0)) / SUM(IF(m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4, m.dau, 0)) AS arpdau_blk,
    SUM(IF(NOT (m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4) AND m.k > 4, m.rev, 0)) / SUM(IF(NOT (m.k BETWEEN 7*b.j + 1 AND 7*b.j + 4) AND m.k > 4, m.dau, 0)) AS arpdau_oth
  FROM m CROSS JOIN blocks b GROUP BY 1,2,3
)
SELECT album_id, seg, IF(j = 0, 'final 4 days', CONCAT(CAST(j AS STRING), ' week(s) before')) AS window_name,
  ROUND(arpdau_oth, 3) AS arpdau_rest, ROUND(arpdau_blk, 3) AS arpdau_window, ROUND(100 * (arpdau_blk / arpdau_oth - 1), 1) AS arpdau_lift_pct
FROM x ORDER BY seg, album_id, j;

-- Q8 (Eden: why compare only with the weekend one week earlier?): same query as Q7 with blocks j = 0..6 (GENERATE_ARRAY(0, 6)), keeping the blocks with 4 full days
-- (WHERE n_days = 4, n_days = COUNTIF(k BETWEEN 7*j+1 AND 7*j+4)) and the final SELECT:
--   SELECT album_id, seg, j AS weeks_before, ROUND(100 * (arpdau_blk / arpdau_oth - 1), 1) AS arpdau_lift_pct FROM x WHERE n_days = 4 ORDER BY seg, album_id, j
