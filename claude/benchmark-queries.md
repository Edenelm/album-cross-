# Topic 4 queries — rare progression (PU, login ratio >= 0.5), 2026-10-07

## dice
```sql
WITH totals AS (SELECT 61 AS album_id, 12 AS total_rares UNION ALL SELECT 63, 12),
rows_ AS (
  SELECT a.album_id, a.user_id, a.day_in_album AS d, a.date_dim, a.album_login_ratio AS login_ratio,
    IFNULL(a.spent_in_album_today, 0) AS spend, a.unique_super_stickers_lt AS u,
    DATE_DIFF(a.album_end_date, a.album_start_date, DAY) AS dd
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE
    AND a.date_dim < a.album_end_date AND a.day_in_album >= 1),
pop AS (
  SELECT album_id, user_id, MAX(dd) AS dd, MIN(d) AS first_d, SUM(spend) > 0 AS is_pu
  FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
obs AS (SELECT album_id, user_id, d, MAX(u) AS u FROM rows_ GROUP BY 1, 2, 3),
filled AS (
  SELECT p.album_id, p.user_id, p.is_pu, p.dd, d,
    IFNULL(MAX(o.u) OVER (PARTITION BY p.album_id, p.user_id ORDER BY d ROWS UNBOUNDED PRECEDING), 0) AS cum
  FROM pop p CROSS JOIN UNNEST(GENERATE_ARRAY(p.first_d, p.dd)) AS d
  LEFT JOIN obs o ON o.album_id = p.album_id AND o.user_id = p.user_id AND o.d = d),
seg AS (
  SELECT f.album_id, f.user_id, f.is_pu, f.dd, f.d, f.cum, t.total_rares, s AS segment FROM filled f JOIN totals t USING (album_id)
  CROSS JOIN UNNEST(['PU']) AS s WHERE f.is_pu),
curve AS (
  SELECT 'pct_collected' AS metric, segment, s.album_id, pct AS point, COUNT(*) AS n,
    APPROX_QUANTILES(cum / total_rares, 100)[OFFSET(50)] AS p50,
    APPROX_QUANTILES(cum / total_rares, 100)[OFFSET(75)] AS p75,
    APPROX_QUANTILES(cum, 100)[OFFSET(50)] AS p50_raw, APPROX_QUANTILES(cum, 100)[OFFSET(75)] AS p75_raw
  FROM seg s CROSS JOIN UNNEST([10, 25, 50, 75, 90, 100]) AS pct
  WHERE s.d = LEAST(s.dd, GREATEST(1, CAST(ROUND(pct / 100 * s.dd) AS INT64)))
  GROUP BY 1, 2, 3, 4),
rec AS (
  SELECT segment, album_id, user_id, d, new_rares FROM (
    SELECT segment, album_id, user_id, d, cum - LAG(cum, 1, 0) OVER w AS new_rares
    FROM seg WINDOW w AS (PARTITION BY segment, album_id, user_id ORDER BY d))
  WHERE new_rares > 0),
gaps AS (
  SELECT segment, album_id, user_id, d - LAG(d) OVER (PARTITION BY segment, album_id, user_id ORDER BY d) AS gap
  FROM rec),
gap_pooled AS (
  SELECT 'gap_days_all_gaps' AS metric, segment, album_id, NULL AS point, COUNT(*) AS n,
    APPROX_QUANTILES(gap, 100)[OFFSET(50)] AS p50, APPROX_QUANTILES(gap, 100)[OFFSET(75)] AS p75,
    NULL AS p50_raw, NULL AS p75_raw
  FROM gaps WHERE gap IS NOT NULL GROUP BY 1, 2, 3),
gap_player AS (
  SELECT 'gap_days_player_median' AS metric, segment, album_id, NULL AS point, COUNT(*) AS n,
    APPROX_QUANTILES(med, 100)[OFFSET(50)] AS p50, APPROX_QUANTILES(med, 100)[OFFSET(75)] AS p75,
    NULL AS p50_raw, NULL AS p75_raw
  FROM (SELECT segment, album_id, user_id, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS med
        FROM gaps WHERE gap IS NOT NULL GROUP BY 1, 2, 3)
  GROUP BY 1, 2, 3),
clusters AS (
  SELECT 'share_receipt_days_2plus' AS metric, segment, album_id, NULL AS point, COUNT(*) AS n,
    COUNTIF(new_rares >= 2) / COUNT(*) AS p50, NULL AS p75, NULL AS p50_raw, NULL AS p75_raw
  FROM rec GROUP BY 1, 2, 3),
first_rare AS (
  SELECT 'first_rare_day' AS metric, s.segment, s.album_id, NULL AS point, COUNT(*) AS n,
    APPROX_QUANTILES(r.first_d, 100 IGNORE NULLS)[OFFSET(50)] AS p50,
    APPROX_QUANTILES(r.first_d, 100 IGNORE NULLS)[OFFSET(75)] AS p75,
    COUNTIF(r.first_d IS NULL) / COUNT(*) AS p50_raw, NULL AS p75_raw  -- p50_raw here = share with no rare
  FROM (SELECT DISTINCT segment, album_id, user_id FROM seg) s
  LEFT JOIN (SELECT segment, album_id, user_id, MIN(d) AS first_d FROM rec GROUP BY 1, 2, 3) r
    USING (segment, album_id, user_id)
  GROUP BY 1, 2, 3)
SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM curve UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM gap_pooled UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM gap_player UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM clusters UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM first_rare
ORDER BY metric, segment, album_id, point
```

## domino
```sql
WITH totals AS (SELECT 17 AS album_id, 8 AS total_rares UNION ALL SELECT 19, 9),
excluded AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND suspected_cheater_flag),
rows_ AS (
  SELECT a.album_id, a.user_id, a.day_in_album AS d, a.date_dim, a.login_ratio,
    IFNULL(a.album_spent_today, 0) AS spend, a.unique_royal_stickers_tl AS u,
    DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS dd
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-23' AND a.album_id IN (17, 19)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL
    AND a.date_dim < a.album_close_date AND a.day_in_album >= 1),
pop AS (
  SELECT album_id, user_id, MAX(dd) AS dd, MIN(d) AS first_d, SUM(spend) > 0 AS is_pu
  FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
obs AS (SELECT album_id, user_id, d, MAX(u) AS u FROM rows_ GROUP BY 1, 2, 3),
filled AS (
  SELECT p.album_id, p.user_id, p.is_pu, p.dd, d,
    IFNULL(MAX(o.u) OVER (PARTITION BY p.album_id, p.user_id ORDER BY d ROWS UNBOUNDED PRECEDING), 0) AS cum
  FROM pop p CROSS JOIN UNNEST(GENERATE_ARRAY(p.first_d, p.dd)) AS d
  LEFT JOIN obs o ON o.album_id = p.album_id AND o.user_id = p.user_id AND o.d = d),
seg AS (
  SELECT f.album_id, f.user_id, f.is_pu, f.dd, f.d, f.cum, t.total_rares, s AS segment FROM filled f JOIN totals t USING (album_id)
  CROSS JOIN UNNEST(['PU']) AS s WHERE f.is_pu),
curve AS (
  SELECT 'pct_collected' AS metric, segment, s.album_id, pct AS point, COUNT(*) AS n,
    APPROX_QUANTILES(cum / total_rares, 100)[OFFSET(50)] AS p50,
    APPROX_QUANTILES(cum / total_rares, 100)[OFFSET(75)] AS p75,
    APPROX_QUANTILES(cum, 100)[OFFSET(50)] AS p50_raw, APPROX_QUANTILES(cum, 100)[OFFSET(75)] AS p75_raw
  FROM seg s CROSS JOIN UNNEST([10, 25, 50, 75, 90, 100]) AS pct
  WHERE s.d = LEAST(s.dd, GREATEST(1, CAST(ROUND(pct / 100 * s.dd) AS INT64)))
  GROUP BY 1, 2, 3, 4),
rec AS (
  SELECT segment, album_id, user_id, d, new_rares FROM (
    SELECT segment, album_id, user_id, d, cum - LAG(cum, 1, 0) OVER w AS new_rares
    FROM seg WINDOW w AS (PARTITION BY segment, album_id, user_id ORDER BY d))
  WHERE new_rares > 0),
gaps AS (
  SELECT segment, album_id, user_id, d - LAG(d) OVER (PARTITION BY segment, album_id, user_id ORDER BY d) AS gap
  FROM rec),
gap_pooled AS (
  SELECT 'gap_days_all_gaps' AS metric, segment, album_id, NULL AS point, COUNT(*) AS n,
    APPROX_QUANTILES(gap, 100)[OFFSET(50)] AS p50, APPROX_QUANTILES(gap, 100)[OFFSET(75)] AS p75,
    NULL AS p50_raw, NULL AS p75_raw
  FROM gaps WHERE gap IS NOT NULL GROUP BY 1, 2, 3),
gap_player AS (
  SELECT 'gap_days_player_median' AS metric, segment, album_id, NULL AS point, COUNT(*) AS n,
    APPROX_QUANTILES(med, 100)[OFFSET(50)] AS p50, APPROX_QUANTILES(med, 100)[OFFSET(75)] AS p75,
    NULL AS p50_raw, NULL AS p75_raw
  FROM (SELECT segment, album_id, user_id, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS med
        FROM gaps WHERE gap IS NOT NULL GROUP BY 1, 2, 3)
  GROUP BY 1, 2, 3),
clusters AS (
  SELECT 'share_receipt_days_2plus' AS metric, segment, album_id, NULL AS point, COUNT(*) AS n,
    COUNTIF(new_rares >= 2) / COUNT(*) AS p50, NULL AS p75, NULL AS p50_raw, NULL AS p75_raw
  FROM rec GROUP BY 1, 2, 3),
first_rare AS (
  SELECT 'first_rare_day' AS metric, s.segment, s.album_id, NULL AS point, COUNT(*) AS n,
    APPROX_QUANTILES(r.first_d, 100 IGNORE NULLS)[OFFSET(50)] AS p50,
    APPROX_QUANTILES(r.first_d, 100 IGNORE NULLS)[OFFSET(75)] AS p75,
    COUNTIF(r.first_d IS NULL) / COUNT(*) AS p50_raw, NULL AS p75_raw  -- p50_raw here = share with no rare
  FROM (SELECT DISTINCT segment, album_id, user_id FROM seg) s
  LEFT JOIN (SELECT segment, album_id, user_id, MIN(d) AS first_d FROM rec GROUP BY 1, 2, 3) r
    USING (segment, album_id, user_id)
  GROUP BY 1, 2, 3)
SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM curve UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM gap_pooled UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM gap_player UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM clusters UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM first_rare
ORDER BY metric, segment, album_id, point
```

## disney
```sql
WITH totals AS (SELECT 14 AS album_id, 7 AS total_rares UNION ALL SELECT 15, 7),
excluded AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
rows_ AS (
  SELECT a.album_id, a.user_id, a.day_in_album AS d, a.date_dim, a.login_ratio,
    IFNULL(a.album_spent_today, 0) AS spend, a.unique_royal_stickers_tl AS u,
    DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS dd
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a
  LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND a.album_id IN (14, 15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL
    AND a.date_dim < a.album_close_date AND a.day_in_album >= 1),
pop AS (
  SELECT album_id, user_id, MAX(dd) AS dd, MIN(d) AS first_d, SUM(spend) > 0 AS is_pu
  FROM rows_ GROUP BY 1, 2
  HAVING SUM(spend) > 0 AND ARRAY_AGG(login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
obs AS (SELECT album_id, user_id, d, MAX(u) AS u FROM rows_ GROUP BY 1, 2, 3),
filled AS (
  SELECT p.album_id, p.user_id, p.is_pu, p.dd, d,
    IFNULL(MAX(o.u) OVER (PARTITION BY p.album_id, p.user_id ORDER BY d ROWS UNBOUNDED PRECEDING), 0) AS cum
  FROM pop p CROSS JOIN UNNEST(GENERATE_ARRAY(p.first_d, p.dd)) AS d
  LEFT JOIN obs o ON o.album_id = p.album_id AND o.user_id = p.user_id AND o.d = d),
seg AS (
  SELECT f.album_id, f.user_id, f.is_pu, f.dd, f.d, f.cum, t.total_rares, s AS segment FROM filled f JOIN totals t USING (album_id)
  CROSS JOIN UNNEST(['PU']) AS s WHERE f.is_pu),
curve AS (
  SELECT 'pct_collected' AS metric, segment, s.album_id, pct AS point, COUNT(*) AS n,
    APPROX_QUANTILES(cum / total_rares, 100)[OFFSET(50)] AS p50,
    APPROX_QUANTILES(cum / total_rares, 100)[OFFSET(75)] AS p75,
    APPROX_QUANTILES(cum, 100)[OFFSET(50)] AS p50_raw, APPROX_QUANTILES(cum, 100)[OFFSET(75)] AS p75_raw
  FROM seg s CROSS JOIN UNNEST([10, 25, 50, 75, 90, 100]) AS pct
  WHERE s.d = LEAST(s.dd, GREATEST(1, CAST(ROUND(pct / 100 * s.dd) AS INT64)))
  GROUP BY 1, 2, 3, 4),
rec AS (
  SELECT segment, album_id, user_id, d, new_rares FROM (
    SELECT segment, album_id, user_id, d, cum - LAG(cum, 1, 0) OVER w AS new_rares
    FROM seg WINDOW w AS (PARTITION BY segment, album_id, user_id ORDER BY d))
  WHERE new_rares > 0),
gaps AS (
  SELECT segment, album_id, user_id, d - LAG(d) OVER (PARTITION BY segment, album_id, user_id ORDER BY d) AS gap
  FROM rec),
gap_pooled AS (
  SELECT 'gap_days_all_gaps' AS metric, segment, album_id, NULL AS point, COUNT(*) AS n,
    APPROX_QUANTILES(gap, 100)[OFFSET(50)] AS p50, APPROX_QUANTILES(gap, 100)[OFFSET(75)] AS p75,
    NULL AS p50_raw, NULL AS p75_raw
  FROM gaps WHERE gap IS NOT NULL GROUP BY 1, 2, 3),
gap_player AS (
  SELECT 'gap_days_player_median' AS metric, segment, album_id, NULL AS point, COUNT(*) AS n,
    APPROX_QUANTILES(med, 100)[OFFSET(50)] AS p50, APPROX_QUANTILES(med, 100)[OFFSET(75)] AS p75,
    NULL AS p50_raw, NULL AS p75_raw
  FROM (SELECT segment, album_id, user_id, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS med
        FROM gaps WHERE gap IS NOT NULL GROUP BY 1, 2, 3)
  GROUP BY 1, 2, 3),
clusters AS (
  SELECT 'share_receipt_days_2plus' AS metric, segment, album_id, NULL AS point, COUNT(*) AS n,
    COUNTIF(new_rares >= 2) / COUNT(*) AS p50, NULL AS p75, NULL AS p50_raw, NULL AS p75_raw
  FROM rec GROUP BY 1, 2, 3),
first_rare AS (
  SELECT 'first_rare_day' AS metric, s.segment, s.album_id, NULL AS point, COUNT(*) AS n,
    APPROX_QUANTILES(r.first_d, 100 IGNORE NULLS)[OFFSET(50)] AS p50,
    APPROX_QUANTILES(r.first_d, 100 IGNORE NULLS)[OFFSET(75)] AS p75,
    COUNTIF(r.first_d IS NULL) / COUNT(*) AS p50_raw, NULL AS p75_raw  -- p50_raw here = share with no rare
  FROM (SELECT DISTINCT segment, album_id, user_id FROM seg) s
  LEFT JOIN (SELECT segment, album_id, user_id, MIN(d) AS first_d FROM rec GROUP BY 1, 2, 3) r
    USING (segment, album_id, user_id)
  GROUP BY 1, 2, 3)
SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM curve UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM gap_pooled UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM gap_player UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM clusters UNION ALL SELECT metric, segment, album_id, point, n, p50, p75, p50_raw, p75_raw FROM first_rare
ORDER BY metric, segment, album_id, point
```

# Topic 2 follow-up — album-end ratio query (Disney pattern; adapt per game)
```sql
WITH alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN '2025-07-01' AND '2026-10-06' GROUP BY 1
  HAVING MAX(album_close_date) BETWEEN '2025-10-01' AND '2026-10-07'
),
seq AS (
  SELECT user_id, album_id, user_album_start_date,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_album_start_date, album_id) AS n
  FROM (SELECT user_id, album_id, MIN(user_album_start_date) AS user_album_start_date
        FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
        WHERE date_dim BETWEEN '2025-04-01' AND '2026-10-06' GROUP BY 1, 2)
),
coh AS (
  SELECT s.user_id, s.album_id, s.user_album_start_date,
         CASE WHEN s.n >= 7 THEN '7+' ELSE CAST(s.n AS STRING) END AS cohort
  FROM seq s JOIN alb USING (album_id)
  JOIN `solitaire-dreams-411507.bi_prod.user_profile` p
    ON p.user_id = s.user_id AND p.install_date BETWEEN '2020-01-01' AND '2026-10-06' AND p.exclude_reason IS NULL
),
d AS (
  SELECT c.album_id, a.a_start, a.a_end, c.cohort, x.user_id,
         x.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 4 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY) AS endw,
         IFNULL(x.album_spent_today, 0) AS rev
  FROM coh c JOIN alb a USING (album_id)
  JOIN `solitaire-dreams-411507.bi_prod.user_daily_album` x
    ON x.user_id = c.user_id AND x.album_id = c.album_id
   AND x.date_dim BETWEEN c.user_album_start_date AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE x.date_dim BETWEEN '2025-07-01' AND '2026-10-06'
    AND x.active_flag AND x.special_user_flag = FALSE
)
SELECT 'Disney' AS game, album_id, ANY_VALUE(a_start) AS album_start, ANY_VALUE(a_end) AS album_end, cohort,
  COUNT(DISTINCT user_id) AS players, COUNT(*) AS act_days, ROUND(SUM(rev), 2) AS rev, COUNTIF(rev > 0) AS pay_days,
  COUNT(DISTINCT IF(endw, user_id, NULL)) AS end_players, COUNTIF(endw) AS end_days, ROUND(SUM(IF(endw, rev, 0)), 2) AS end_rev,
  COUNTIF(endw AND rev > 0) AS end_pay_days
FROM d GROUP BY album_id, cohort ORDER BY album_id, cohort```

