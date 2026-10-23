-- Eden 2026-10-23: (A) Disney 15 all-144 stalls (days 10-13, 26-31): new stickers per day by source and phase open day;
-- (B) which sticker types payers miss at close, by game. Population = standard population payers (same as all144_steps_2026-10-23.sql).
-- Results: claude/disney-stalls-missing-2026-10-23.md

-- ===== A. DISNEY 15 (solitaire-dreams-411507): per day, new stickers per payer by source; first day each phase gives stickers =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id = 15 AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_start, a_end FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND rev_c > 0 AND user_id NOT IN (SELECT user_id FROM bad_users)),
r AS (
  SELECT s.user_id, s.sticker_id, ANY_VALUE(s.phase) AS phase, ANY_VALUE(LOWER(s.sticker_type)) AS typ,
    ARRAY_AGG(IFNULL(s.new_sticker_source,'(none)') ORDER BY s.sticker_collected_min_ts LIMIT 1)[OFFSET(0)] AS src,
    MIN(s.sticker_collected_min_date) AS d
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p ON p.user_id = s.user_id AND p.album_id = s.album_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id = 15
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2
),
rd AS (SELECT r.*, DATE_DIFF(r.d, p.a_start, DAY) + 1 AS day FROM r JOIN pop p USING (user_id)),
n AS (SELECT COUNT(*) AS n_pay FROM pop)
SELECT 'src' AS kind, src AS k, STRING_AGG(FORMAT('%d:%.2f', day, per_payer), ' ' ORDER BY day) AS series, ROUND(SUM(per_payer),1) AS total_per_payer
FROM (SELECT src, day, COUNT(*) / ANY_VALUE(n.n_pay) AS per_payer FROM rd, n GROUP BY 1,2) GROUP BY 1,2
UNION ALL
SELECT 'phase', CAST(phase AS STRING), STRING_AGG(FORMAT('%d:%.2f', day, per_payer), ' ' ORDER BY day), ROUND(SUM(per_payer),1)
FROM (SELECT phase, day, COUNT(*) / ANY_VALUE(n.n_pay) AS per_payer FROM rd, n GROUP BY 1,2) GROUP BY 1,2
ORDER BY kind, total_per_payer DESC;

-- ===== A2 + B. DISNEY 14/15 (solitaire-dreams-411507): set open day (first album day >=5% of payers hold a sticker of the set)
-- and missing stickers at close by type. Type size = distinct sticker_id per type in the album (from the payers' rows).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_start, a_end FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND rev_c > 0 AND user_id NOT IN (SELECT user_id FROM bad_users)),
r AS (
  SELECT s.album_id, s.user_id, s.set_id, s.sticker_id, ANY_VALUE(LOWER(s.sticker_type)) AS typ, MIN(s.sticker_collected_min_date) AS d
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (14,15)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3,4
),
npay AS (SELECT album_id, COUNT(*) AS n FROM pop GROUP BY 1),
-- A2: set open day
sfirst AS (SELECT r.album_id, r.set_id, r.user_id, MIN(DATE_DIFF(r.d, p.a_start, DAY) + 1) AS day FROM r JOIN pop p USING (album_id, user_id) GROUP BY 1,2,3),
scum AS (SELECT album_id, set_id, day, SUM(COUNT(*)) OVER (PARTITION BY album_id, set_id ORDER BY day) AS c FROM sfirst GROUP BY 1,2,3),
sopen AS (SELECT s.album_id, s.set_id, MIN(IF(s.c >= 0.05 * n.n, s.day, NULL)) AS open_day FROM scum s JOIN npay n USING (album_id) GROUP BY 1,2),
-- B: missing by type
tsize AS (SELECT album_id, typ, COUNT(DISTINCT sticker_id) AS n_typ FROM r GROUP BY 1,2),
held AS (SELECT album_id, user_id, typ, COUNT(*) AS h FROM r GROUP BY 1,2,3),
miss AS (
  SELECT p.album_id, p.user_id, t.typ, t.n_typ - IFNULL(h.h, 0) AS m
  FROM pop p JOIN tsize t USING (album_id) LEFT JOIN held h ON h.album_id = p.album_id AND h.user_id = p.user_id AND h.typ = t.typ
)
SELECT 'open' AS kind, album_id, STRING_AGG(FORMAT('set%d:d%d', set_id, open_day), ' ' ORDER BY open_day, set_id) AS v
FROM sopen GROUP BY 1,2
UNION ALL
SELECT 'miss', album_id, STRING_AGG(FORMAT('%s n=%d avg_miss=%.2f med=%d miss_any=%.2f', typ, n_typ, avg_m, med_m, any_m), ' | ' ORDER BY typ)
FROM (SELECT m.album_id, m.typ, ANY_VALUE(t.n_typ) AS n_typ, AVG(m.m) AS avg_m, APPROX_QUANTILES(m.m, 2)[OFFSET(1)] AS med_m, AVG(IF(m.m > 0, 1, 0)) AS any_m
      FROM miss m JOIN tsize t USING (album_id, typ) GROUP BY 1,2) GROUP BY 1,2
ORDER BY kind, album_id;

-- ===== B. DOMINO 19/20 (domino-dreams-dbt), all payers: missing stickers at close by type =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
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
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
tsize AS (SELECT album_id, typ, COUNT(DISTINCT sticker_id) AS n_typ FROM r GROUP BY 1,2),
held AS (SELECT album_id, user_id, typ, COUNT(*) AS h FROM r GROUP BY 1,2,3),
miss AS (
  SELECT p.album_id, p.user_id, t.typ, t.n_typ - IFNULL(h.h, 0) AS m
  FROM pop p JOIN tsize t USING (album_id) LEFT JOIN held h ON h.album_id = p.album_id AND h.user_id = p.user_id AND h.typ = t.typ
)
SELECT album_id, STRING_AGG(FORMAT('%s n=%d avg_miss=%.2f med=%d miss_any=%.2f', typ, n_typ, avg_m, med_m, any_m), ' | ' ORDER BY typ) AS v
FROM (SELECT m.album_id, m.typ, ANY_VALUE(t.n_typ) AS n_typ, AVG(m.m) AS avg_m, APPROX_QUANTILES(m.m, 2)[OFFSET(1)] AS med_m, AVG(IF(m.m > 0, 1, 0)) AS any_m
      FROM miss m JOIN tsize t USING (album_id, typ) GROUP BY 1,2) GROUP BY 1
ORDER BY 1;

-- ===== C. DISNEY 15 (solitaire-dreams-411507): per album day, share of payers active and album spend per active payer (lulls vs waves) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    IFNULL(active_flag, FALSE) AS act
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
pop AS (SELECT user_id FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND rev_c > 0 AND user_id NOT IN (SELECT user_id FROM bad_users))
SELECT STRING_AGG(FORMAT('%d:%.2f:%.2f', day, act_share, spend_per_act), ' ' ORDER BY day) AS series
FROM (
  SELECT DATE_DIFF(d.date_dim, d.a_start, DAY) + 1 AS day,
    COUNTIF(d.act) / (SELECT COUNT(*) FROM pop) AS act_share,
    SAFE_DIVIDE(SUM(IF(d.act, d.spend, 0)), COUNTIF(d.act)) AS spend_per_act
  FROM ud d JOIN pop USING (user_id) GROUP BY 1
);
