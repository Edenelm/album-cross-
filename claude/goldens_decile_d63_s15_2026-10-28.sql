-- 2026-10-28 (Eden): "% of the Album's Goldens Collected, by % of Album Time" for single albums: Dice 63, Disney 15 (Domino 20 from domino_easy_goldens_progression_2026-10-26.sql).
-- Same measure as the Domino query: average share of the album's Goldens held at the end of day round(n_days*k/10), k=1..10. Standard population payers (paid any album day incl. close).
-- Dice: fixed first-album rule (golden_timeline_2026-10-23.sql), 28 Goldens. Disney: 24 Goldens.

-- ===== DICE 63 =====
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1
),
ud AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_start_date AS a_start, a.album_end_date AS a_end,
    a.album_login_ratio_until_this_day AS lr, h.first_album_seen < a.album_id AS past, IFNULL(a.is_excluded,FALSE) AS excl,
    IFNULL(a.spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN hist h ON h.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND a.album_id = 63 AND a.date_dim <= a.album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_start, DATE_DIFF(a_end, a_start, DAY) + 1 AS n_days, a_end FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0),
r AS (
  SELECT s.user_id, s.sticker_id, DATE_DIFF(MIN(s.sticker_collected_date), ANY_VALUE(p.a_start), DAY) + 1 AS day
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND s.album_id = 63
    AND s.sticker_type = 'golden' AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2
),
held AS (
  SELECT p.user_id, k, COUNTIF(r.day <= CAST(ROUND(p.n_days * k / 10) AS INT64)) AS n_held
  FROM pop p CROSS JOIN UNNEST(GENERATE_ARRAY(1,10)) AS k LEFT JOIN r ON r.user_id = p.user_id GROUP BY 1,2
)
SELECT k AS decile, COUNT(*) AS payers, ROUND(100 * AVG(n_held) / 28, 1) AS pct FROM held GROUP BY 1 ORDER BY 1;

-- ===== DISNEY 15 =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id = 15 AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (SELECT album_id, user_id, a_start, DATE_DIFF(a_end, a_start, DAY) + 1 AS n_days, a_end FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)),
r AS (
  SELECT s.user_id, s.sticker_id, DATE_DIFF(MIN(s.sticker_collected_min_date), ANY_VALUE(p.a_start), DAY) + 1 AS day
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id = 15
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'golden' AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2
),
held AS (
  SELECT p.user_id, k, COUNTIF(r.day <= CAST(ROUND(p.n_days * k / 10) AS INT64)) AS n_held
  FROM pop p CROSS JOIN UNNEST(GENERATE_ARRAY(1,10)) AS k LEFT JOIN r ON r.user_id = p.user_id GROUP BY 1,2
)
SELECT k AS decile, COUNT(*) AS payers, ROUND(100 * AVG(n_held) / 24, 1) AS pct FROM held GROUP BY 1 ORDER BY 1;
