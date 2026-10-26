-- 2026-10-26 Domino diagnosis, topic 1 story check (Eden): was album 20 really better than 18 / 19? what explains it? what did they buy?
-- Project domino-dreams-dbt. Album windows (open .. day before close, close day left out): 17 = 2026-04-02..05-11, 18 = 05-11..07-06, 19 = 07-06..08-24, 20 = 08-24..10-12.
-- Excluded: special_user_flag, suspected_cheater_flag (Q1, Q2). Q3, Q4 read core_purchase, which has no such flags (about +1.5% revenue vs Q1).
-- Results: claude/domino-dx-t1-story-check-2026-10-26.md

-- Q1: game level per album, per-day basis. Revenue = in-app + Stripe gross (same as game-revenue-rebase; matches 17,388,298 / 17,644,426 / 16,269,671 within 0.01%).
WITH al AS (
  SELECT 17 AS album_id, DATE '2026-04-02' AS d0, DATE '2026-05-11' AS d1 UNION ALL
  SELECT 18, DATE '2026-05-11', DATE '2026-07-06' UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
m AS (
  SELECT a.album_id, a.d0, a.d1, u.date_dim, u.user_id,
    IFNULL(u.user_daily_inapp_purchase_amount,0) + IFNULL(u.user_daily_stripe_amount,0) AS rev,
    IFNULL(u.number_of_purchases_today,0) AS purch,
    IFNULL(u.pau_flag,FALSE) AS act, IFNULL(u.pu_flag,FALSE) AS pu, IFNULL(u.install_today_flag,FALSE) AS inst
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` u
  JOIN al a ON u.date_dim >= a.d0 AND u.date_dim < a.d1
  WHERE u.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12'
    AND NOT IFNULL(u.special_user_flag,FALSE) AND NOT IFNULL(u.suspected_cheater_flag,FALSE)
),
dday AS (
  SELECT album_id, date_dim, COUNTIF(act) AS dau, COUNTIF(pu) AS payers, SUM(rev) AS rev, SUM(purch) AS purch, COUNTIF(inst) AS installs
  FROM m GROUP BY 1,2
)
SELECT album_id, COUNT(*) AS days, ROUND(SUM(rev)) AS game_rev, ROUND(SUM(rev)/COUNT(*)) AS rev_per_day,
  ROUND(AVG(dau)) AS avg_dau, ROUND(AVG(payers)) AS avg_daily_payers, ROUND(AVG(payers/dau),4) AS pau_rate,
  ROUND(SUM(rev)/SUM(dau),4) AS arpdau, ROUND(SUM(rev)/SUM(payers),2) AS arppu_day,
  ROUND(SUM(purch)/SUM(payers),3) AS purch_per_payer_day, ROUND(SUM(rev)/SUM(purch),2) AS usd_per_purchase,
  ROUND(AVG(installs)) AS avg_installs
FROM dday GROUP BY 1 ORDER BY 1;

-- Q2: same players across albums (stayers = in the album table in both albums, leavers = earlier only, joiners = later only). Spend = album_spent_today, open..close-1.
WITH s AS (
  SELECT album_id, user_id, SUM(IFNULL(album_spent_today,0)) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-12' AND album_id IN (18,19,20) AND date_dim < album_close_date
    AND NOT IFNULL(special_user_flag,FALSE)
  GROUP BY 1,2
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
p AS (SELECT * FROM s WHERE user_id NOT IN (SELECT user_id FROM bad)),
t AS (
  SELECT 'A_18_to_19' AS pair, COALESCE(a.user_id, b.user_id) AS user_id, a.spend AS s_prev, b.spend AS s_next
  FROM (SELECT * FROM p WHERE album_id = 18) a FULL OUTER JOIN (SELECT * FROM p WHERE album_id = 19) b ON a.user_id = b.user_id
  UNION ALL
  SELECT 'B_19_to_20', COALESCE(a.user_id, b.user_id), a.spend, b.spend
  FROM (SELECT * FROM p WHERE album_id = 19) a FULL OUTER JOIN (SELECT * FROM p WHERE album_id = 20) b ON a.user_id = b.user_id
)
SELECT pair,
  CASE WHEN s_prev IS NOT NULL AND s_next IS NOT NULL THEN 'stayers' WHEN s_prev IS NOT NULL THEN 'leavers (earlier album only)' ELSE 'joiners (later album only)' END AS grp,
  COUNT(*) AS players,
  ROUND(SUM(IFNULL(s_prev,0))) AS rev_prev, ROUND(SUM(IFNULL(s_next,0))) AS rev_next,
  ROUND(AVG(s_prev),2) AS avg_prev, ROUND(AVG(s_next),2) AS avg_next,
  ROUND(SAFE_DIVIDE(COUNTIF(s_prev > 0), COUNTIF(s_prev IS NOT NULL)), 3) AS pay_rate_prev,
  ROUND(SAFE_DIVIDE(COUNTIF(s_next > 0), COUNTIF(s_next IS NOT NULL)), 3) AS pay_rate_next
FROM t GROUP BY 1,2 ORDER BY 1,2;

-- Q3: purchases per price bucket per album (core_purchase, total_usd_amount > 0), per day.
WITH al AS (
  SELECT 17 AS album_id, DATE '2026-04-02' AS d0, DATE '2026-05-11' AS d1 UNION ALL
  SELECT 18, DATE '2026-05-11', DATE '2026-07-06' UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
p AS (
  SELECT a.album_id, DATE_DIFF(a.d1, a.d0, DAY) AS days, c.external_order_id, IFNULL(c.total_usd_amount,0) AS amt,
    CASE WHEN c.total_usd_amount < 2 THEN '1_<2' WHEN c.total_usd_amount < 5 THEN '2_2-5' WHEN c.total_usd_amount < 10 THEN '3_5-10'
         WHEN c.total_usd_amount < 20 THEN '4_10-20' WHEN c.total_usd_amount < 50 THEN '5_20-50' WHEN c.total_usd_amount < 100 THEN '6_50-100' ELSE '7_100+' END AS bucket
  FROM `domino-dreams-dbt.prod_20_core.core_purchase` c JOIN al a ON c.date_dim >= a.d0 AND c.date_dim < a.d1
  WHERE c.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND c.total_usd_amount > 0
)
SELECT album_id, bucket, ANY_VALUE(days) AS days, COUNT(DISTINCT external_order_id) AS purchases, ROUND(SUM(amt)) AS rev,
  ROUND(COUNT(DISTINCT external_order_id) / ANY_VALUE(days)) AS purch_per_day,
  ROUND(SUM(amt) / ANY_VALUE(days)) AS rev_per_day
FROM p GROUP BY 1,2 ORDER BY 1,2;

-- Q4: price points of $20+ purchases (only points with 2,000+ purchases in album 19 or 20). core_purchase has no offer id; USD amounts also vary by currency,
-- so this does not separate "price changed" from "mix changed" (the listed points cover about 40% of the $20-50 purchases).
WITH al AS (
  SELECT 18 AS album_id, DATE '2026-05-11' AS d0, DATE '2026-07-06' AS d1 UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
p AS (
  SELECT a.album_id, DATE_DIFF(a.d1, a.d0, DAY) AS days, c.external_order_id, ROUND(c.total_usd_amount, 2) AS amt
  FROM `domino-dreams-dbt.prod_20_core.core_purchase` c JOIN al a ON c.date_dim >= a.d0 AND c.date_dim < a.d1
  WHERE c.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-12' AND c.total_usd_amount >= 20
),
g AS (SELECT album_id, amt, ANY_VALUE(days) AS days, COUNT(DISTINCT external_order_id) AS n FROM p GROUP BY 1,2)
SELECT amt,
  MAX(IF(album_id = 18, ROUND(n / days, 1), NULL)) AS a18_per_day,
  MAX(IF(album_id = 19, ROUND(n / days, 1), NULL)) AS a19_per_day,
  MAX(IF(album_id = 20, ROUND(n / days, 1), NULL)) AS a20_per_day,
  SUM(IF(album_id = 20, n, 0)) AS n20
FROM g GROUP BY 1 HAVING SUM(IF(album_id = 20, n, 0)) >= 2000 OR SUM(IF(album_id = 19, n, 0)) >= 2000 ORDER BY amt;

-- ===== Staging (Eden approved 2026-10-26): domino-dreams-dbt.prod_10_staging.stg_purchase_completed_vw (fields purchase_sku, usd_amount STRING, mtx_campaign_name, pdate) =====
-- Q5: per SKU, purchases and revenue per day, albums 18 / 19 / 20; top 25 by change in revenue per day 19 -> 20.
WITH al AS (
  SELECT 18 AS album_id, DATE '2026-05-11' AS d0, DATE '2026-07-06' AS d1 UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
p AS (
  SELECT a.album_id, DATE_DIFF(a.d1, a.d0, DAY) AS days, s.external_order_id, IFNULL(s.purchase_sku, '(none)') AS sku, SAFE_CAST(s.usd_amount AS FLOAT64) AS amt
  FROM `domino-dreams-dbt.prod_10_staging.stg_purchase_completed_vw` s JOIN al a ON s.pdate >= a.d0 AND s.pdate < a.d1
  WHERE s.pdate BETWEEN DATE '2026-05-11' AND DATE '2026-10-12' AND SAFE_CAST(s.usd_amount AS FLOAT64) > 0
),
g AS (
  SELECT album_id, sku, ANY_VALUE(days) AS days, COUNT(DISTINCT external_order_id) AS n, SUM(amt) AS rev, AVG(amt) AS avg_amt
  FROM p GROUP BY 1,2
),
w AS (
  SELECT sku,
    MAX(IF(album_id = 18, n / days, NULL)) AS n18, MAX(IF(album_id = 19, n / days, NULL)) AS n19, MAX(IF(album_id = 20, n / days, NULL)) AS n20,
    MAX(IF(album_id = 18, rev / days, NULL)) AS r18, MAX(IF(album_id = 19, rev / days, NULL)) AS r19, MAX(IF(album_id = 20, rev / days, NULL)) AS r20,
    MAX(IF(album_id = 20, avg_amt, NULL)) AS price20, MAX(IF(album_id = 19, avg_amt, NULL)) AS price19
  FROM g GROUP BY 1
)
SELECT sku, ROUND(price19,2) AS avg_price_19, ROUND(price20,2) AS avg_price_20,
  ROUND(IFNULL(n18,0)) AS n_day_18, ROUND(IFNULL(n19,0)) AS n_day_19, ROUND(IFNULL(n20,0)) AS n_day_20,
  ROUND(IFNULL(r18,0)) AS rev_day_18, ROUND(IFNULL(r19,0)) AS rev_day_19, ROUND(IFNULL(r20,0)) AS rev_day_20,
  ROUND(IFNULL(r20,0) - IFNULL(r19,0)) AS rev_day_change
FROM w ORDER BY ABS(IFNULL(r20,0) - IFNULL(r19,0)) DESC LIMIT 25;

-- Q6: by SKU family (_1 / _2) and price bucket, purchases and revenue per day (days 56 / 49 / 49).
WITH al AS (
  SELECT 18 AS album_id, DATE '2026-05-11' AS d0, DATE '2026-07-06' AS d1 UNION ALL
  SELECT 19, DATE '2026-07-06', DATE '2026-08-24' UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
p AS (
  SELECT a.album_id, s.external_order_id,
    CASE WHEN REGEXP_CONTAINS(IFNULL(s.purchase_sku,''), r'mtx_\d+usd_1\)') THEN 'fam_1'
         WHEN REGEXP_CONTAINS(IFNULL(s.purchase_sku,''), r'mtx_\d+usd_2\)') THEN 'fam_2'
         WHEN REGEXP_CONTAINS(IFNULL(s.purchase_sku,''), r'mtx_\d+usd_\d') THEN 'fam_other'
         ELSE 'other_sku' END AS fam,
    SAFE_CAST(s.usd_amount AS FLOAT64) AS amt
  FROM `domino-dreams-dbt.prod_10_staging.stg_purchase_completed_vw` s JOIN al a ON s.pdate >= a.d0 AND s.pdate < a.d1
  WHERE s.pdate BETWEEN DATE '2026-05-11' AND DATE '2026-10-12' AND SAFE_CAST(s.usd_amount AS FLOAT64) > 0
),
q AS (SELECT *, CASE WHEN amt < 5 THEN '1_<5' WHEN amt < 10 THEN '2_5-10' WHEN amt < 20 THEN '3_10-20' WHEN amt < 50 THEN '4_20-50' ELSE '5_50+' END AS bucket FROM p)
SELECT fam, bucket,
  ROUND(SUM(IF(album_id=18, 1, 0)) / 56) AS n_day_18, ROUND(SUM(IF(album_id=19, 1, 0)) / 49) AS n_day_19, ROUND(SUM(IF(album_id=20, 1, 0)) / 49) AS n_day_20,
  ROUND(SUM(IF(album_id=18, amt, 0)) / 56) AS rev_day_18, ROUND(SUM(IF(album_id=19, amt, 0)) / 49) AS rev_day_19, ROUND(SUM(IF(album_id=20, amt, 0)) / 49) AS rev_day_20
FROM q GROUP BY 1,2 ORDER BY 1,2;

-- Q7: top campaigns by change in revenue per day, albums 19 vs 20, split by SKU family (campaign offers rotate every album, so this was not decisive).
WITH al AS (
  SELECT 19 AS album_id, DATE '2026-07-06' AS d0, DATE '2026-08-24' AS d1 UNION ALL
  SELECT 20, DATE '2026-08-24', DATE '2026-10-12'
),
p AS (
  SELECT a.album_id, s.external_order_id,
    IF(REGEXP_CONTAINS(IFNULL(s.purchase_sku,''), r'mtx_\d+usd_2\)'), 'fam_2', 'fam_1') AS fam,
    COALESCE(NULLIF(s.mtx_campaign_name,''), NULLIF(s.mtx_event_name,''), NULLIF(s.source,''), '(none)') AS camp,
    SAFE_CAST(s.usd_amount AS FLOAT64) AS amt
  FROM `domino-dreams-dbt.prod_10_staging.stg_purchase_completed_vw` s JOIN al a ON s.pdate >= a.d0 AND s.pdate < a.d1
  WHERE s.pdate BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND SAFE_CAST(s.usd_amount AS FLOAT64) > 0
),
g AS (SELECT fam, camp,
  SUM(IF(album_id=19, 1, 0)) / 49 AS n19, SUM(IF(album_id=20, 1, 0)) / 49 AS n20,
  SUM(IF(album_id=19, amt, 0)) / 49 AS r19, SUM(IF(album_id=20, amt, 0)) / 49 AS r20 FROM p GROUP BY 1,2)
SELECT fam, camp, ROUND(n19) AS n_day_19, ROUND(n20) AS n_day_20, ROUND(r19) AS rev_day_19, ROUND(r20) AS rev_day_20, ROUND(r20 - r19) AS rev_change
FROM g ORDER BY ABS(r20 - r19) DESC LIMIT 16;
