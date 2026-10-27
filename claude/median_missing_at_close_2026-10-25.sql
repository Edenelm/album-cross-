-- Median paying player: stickers missing at close (end of close day), by type. Eden 2026-10-25 (slide "What the P50 Paying Player Still Misses at Close").
-- Same population and sticker rules as disney_stalls_missing_2026-10-23.sql (B): standard population payers (paid any album day incl. close).
-- New: median of total missing per payer; per-type median; and the average type mix of payers whose total = the median ("the median payer").
-- Results: claude/median-missing-at-close-2026-10-25.md

-- ===== DICE 63 (dice-dreams-dbt) =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1
),
ud AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_end_date AS a_end,
    a.album_login_ratio_until_this_day AS lr, h.first_album_seen < a.album_id AS past, IFNULL(a.is_excluded,FALSE) AS excl,
    IFNULL(a.spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN hist h ON h.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-07' AND a.album_id = 63 AND a.date_dim <= a.album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_end FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, ANY_VALUE(s.sticker_type) AS typ
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-07-01' AND DATE '2026-09-07' AND s.album_id = 63
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2,3
),
tsize AS (SELECT album_id, typ, COUNT(DISTINCT sticker_id) AS n_typ FROM r GROUP BY 1,2),
held AS (SELECT album_id, user_id, typ, COUNT(*) AS h FROM r GROUP BY 1,2,3),
miss AS (
  SELECT p.album_id, p.user_id, t.typ, t.n_typ - IFNULL(h.h, 0) AS m
  FROM pop p JOIN tsize t USING (album_id) LEFT JOIN held h ON h.album_id = p.album_id AND h.user_id = p.user_id AND h.typ = t.typ
),
tot AS (SELECT album_id, user_id, SUM(m) AS t FROM miss GROUP BY 1,2),
med AS (SELECT album_id, APPROX_QUANTILES(t, 100)[OFFSET(50)] AS med_total, AVG(t) AS avg_total, COUNT(*) AS n_payers FROM tot GROUP BY 1)
SELECT m.album_id, m.typ, ANY_VALUE(ts.n_typ) AS n_typ, ANY_VALUE(md.n_payers) AS n_payers,
  ROUND(ANY_VALUE(md.avg_total), 2) AS avg_total, ANY_VALUE(md.med_total) AS med_total,
  ROUND(AVG(m.m), 2) AS avg_m, APPROX_QUANTILES(m.m, 2)[OFFSET(1)] AS med_m,
  ROUND(AVG(IF(t.t = md.med_total, m.m, NULL)), 2) AS mix_at_median, COUNTIF(t.t = md.med_total) AS n_at_median
FROM miss m JOIN tot t USING (album_id, user_id) JOIN med md USING (album_id) JOIN tsize ts USING (album_id, typ)
GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DOMINO 20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_end FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND rev_c > 0 AND user_id NOT IN (SELECT user_id FROM bad_users)),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, ANY_VALUE(LOWER(s.sticker_type)) AS typ
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id = 20
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
tsize AS (SELECT album_id, typ, COUNT(DISTINCT sticker_id) AS n_typ FROM r GROUP BY 1,2),
held AS (SELECT album_id, user_id, typ, COUNT(*) AS h FROM r GROUP BY 1,2,3),
miss AS (
  SELECT p.album_id, p.user_id, t.typ, t.n_typ - IFNULL(h.h, 0) AS m
  FROM pop p JOIN tsize t USING (album_id) LEFT JOIN held h ON h.album_id = p.album_id AND h.user_id = p.user_id AND h.typ = t.typ
),
tot AS (SELECT album_id, user_id, SUM(m) AS t FROM miss GROUP BY 1,2),
med AS (SELECT album_id, APPROX_QUANTILES(t, 100)[OFFSET(50)] AS med_total, AVG(t) AS avg_total, COUNT(*) AS n_payers FROM tot GROUP BY 1)
SELECT m.album_id, m.typ, ANY_VALUE(ts.n_typ) AS n_typ, ANY_VALUE(md.n_payers) AS n_payers,
  ROUND(ANY_VALUE(md.avg_total), 2) AS avg_total, ANY_VALUE(md.med_total) AS med_total,
  ROUND(AVG(m.m), 2) AS avg_m, APPROX_QUANTILES(m.m, 2)[OFFSET(1)] AS med_m,
  ROUND(AVG(IF(t.t = md.med_total, m.m, NULL)), 2) AS mix_at_median, COUNTIF(t.t = md.med_total) AS n_at_median
FROM miss m JOIN tot t USING (album_id, user_id) JOIN med md USING (album_id) JOIN tsize ts USING (album_id, typ)
GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DISNEY 15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id = 15 AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_end FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND rev_c > 0 AND user_id NOT IN (SELECT user_id FROM bad_users)),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, ANY_VALUE(LOWER(s.sticker_type)) AS typ
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id = 15
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
tsize AS (SELECT album_id, typ, COUNT(DISTINCT sticker_id) AS n_typ FROM r GROUP BY 1,2),
held AS (SELECT album_id, user_id, typ, COUNT(*) AS h FROM r GROUP BY 1,2,3),
miss AS (
  SELECT p.album_id, p.user_id, t.typ, t.n_typ - IFNULL(h.h, 0) AS m
  FROM pop p JOIN tsize t USING (album_id) LEFT JOIN held h ON h.album_id = p.album_id AND h.user_id = p.user_id AND h.typ = t.typ
),
tot AS (SELECT album_id, user_id, SUM(m) AS t FROM miss GROUP BY 1,2),
med AS (SELECT album_id, APPROX_QUANTILES(t, 100)[OFFSET(50)] AS med_total, AVG(t) AS avg_total, COUNT(*) AS n_payers FROM tot GROUP BY 1)
SELECT m.album_id, m.typ, ANY_VALUE(ts.n_typ) AS n_typ, ANY_VALUE(md.n_payers) AS n_payers,
  ROUND(ANY_VALUE(md.avg_total), 2) AS avg_total, ANY_VALUE(md.med_total) AS med_total,
  ROUND(AVG(m.m), 2) AS avg_m, APPROX_QUANTILES(m.m, 2)[OFFSET(1)] AS med_m,
  ROUND(AVG(IF(t.t = md.med_total, m.m, NULL)), 2) AS mix_at_median, COUNTIF(t.t = md.med_total) AS n_at_median
FROM miss m JOIN tot t USING (album_id, user_id) JOIN med md USING (album_id) JOIN tsize ts USING (album_id, typ)
GROUP BY 1, 2 ORDER BY 1, 2;
