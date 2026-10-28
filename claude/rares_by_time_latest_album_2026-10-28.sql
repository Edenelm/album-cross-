-- 2026-10-28 (Eden): rebuild slide '% of the Album's Rares Collected, by % of Album Time' on the latest album only (Dice 63, Domino 20, Disney 15).
-- Average standard-population payer, % of the album's rares held at the end of each 10% of album time (day = ceil(k*n/10)). Rares: Dice 12 Supers, Domino 9 Royals, Disney 7 Royals.

-- ===== DICE =====
WITH ud AS (
  SELECT user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, album_login_ratio_until_this_day AS lr,
    IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date),
u AS (SELECT user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_lr,
    ARRAY_AGG(IF(date_dim < a_end, past, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_past,
    LOGICAL_OR(excl) AS any_excl, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d FROM ud GROUP BY 1),
pop AS (SELECT user_id, a_start, a_end FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l_past AND NOT any_excl AND l_lr >= 0.5 AND rev_c > 0),
r AS (SELECT s.user_id, s.sticker_id, MIN(s.sticker_collected_date) AS d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-07-20' AND DATE '2026-09-07' AND s.album_id = 63
    AND s.sticker_type = 'super' AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end GROUP BY 1,2),
rd AS (SELECT r.user_id, DATE_DIFF(r.d, p.a_start, DAY) + 1 AS day FROM r JOIN pop p USING (user_id)),
alen AS (SELECT DATE_DIFF(ANY_VALUE(a_end), ANY_VALUE(a_start), DAY) + 1 AS n FROM pop),
k AS (SELECT k, CAST(CEIL(k * (SELECT n FROM alen) / 10) AS INT64) AS dmax FROM UNNEST(GENERATE_ARRAY(1, 10)) AS k),
h AS (SELECT p.user_id, k.k, COUNTIF(rd.day <= k.dmax) AS held FROM pop p CROSS JOIN k LEFT JOIN rd ON rd.user_id = p.user_id GROUP BY 1,2)
SELECT (SELECT COUNT(*) FROM pop) AS payers, STRING_AGG(FORMAT('%d:%.1f', k, avg_pct), ' ' ORDER BY k) AS deciles
FROM (SELECT k, 100 * AVG(held) / 12 AS avg_pct FROM h GROUP BY k);

-- ===== DOMINO =====
WITH ud AS (
  SELECT user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, login_ratio AS lr,
    IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (SELECT user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_lr,
    ARRAY_AGG(IF(date_dim < a_end, past, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_past,
    LOGICAL_OR(excl) AS any_excl, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d FROM ud GROUP BY 1),
pop AS (SELECT user_id, a_start, a_end FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l_past AND NOT any_excl AND l_lr >= 0.5 AND rev_c > 0 AND user_id NOT IN (SELECT user_id FROM bad)),
r AS (SELECT s.user_id, s.sticker_id, MIN(s.sticker_collected_min_date) AS d
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-24' AND DATE '2026-10-12' AND s.album_id = 20
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal' AND s.sticker_collected_min_date <= p.a_end GROUP BY 1,2),
rd AS (SELECT r.user_id, DATE_DIFF(r.d, p.a_start, DAY) + 1 AS day FROM r JOIN pop p USING (user_id)),
alen AS (SELECT DATE_DIFF(ANY_VALUE(a_end), ANY_VALUE(a_start), DAY) + 1 AS n FROM pop),
k AS (SELECT k, CAST(CEIL(k * (SELECT n FROM alen) / 10) AS INT64) AS dmax FROM UNNEST(GENERATE_ARRAY(1, 10)) AS k),
h AS (SELECT p.user_id, k.k, COUNTIF(rd.day <= k.dmax) AS held FROM pop p CROSS JOIN k LEFT JOIN rd ON rd.user_id = p.user_id GROUP BY 1,2)
SELECT (SELECT COUNT(*) FROM pop) AS payers, STRING_AGG(FORMAT('%d:%.1f', k, avg_pct), ' ' ORDER BY k) AS deciles
FROM (SELECT k, 100 * AVG(held) / 9 AS avg_pct FROM h GROUP BY k);

-- ===== DISNEY =====
WITH ud AS (
  SELECT user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end, login_ratio AS lr,
    IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-06' AND album_id = 15 AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-08-15' AND DATE '2026-10-06' AND exclude_reason IS NOT NULL),
u AS (SELECT user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_lr,
    ARRAY_AGG(IF(date_dim < a_end, past, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l_past,
    LOGICAL_OR(excl) AS any_excl, MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d FROM ud GROUP BY 1),
pop AS (SELECT user_id, a_start, a_end FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l_past AND NOT any_excl AND l_lr >= 0.5 AND rev_c > 0 AND user_id NOT IN (SELECT user_id FROM bad)),
r AS (SELECT s.user_id, s.sticker_id, MIN(s.sticker_collected_min_date) AS d
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p USING (user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-15' AND DATE '2026-10-06' AND s.album_id = 15
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal' AND s.sticker_collected_min_date <= p.a_end GROUP BY 1,2),
rd AS (SELECT r.user_id, DATE_DIFF(r.d, p.a_start, DAY) + 1 AS day FROM r JOIN pop p USING (user_id)),
alen AS (SELECT DATE_DIFF(ANY_VALUE(a_end), ANY_VALUE(a_start), DAY) + 1 AS n FROM pop),
k AS (SELECT k, CAST(CEIL(k * (SELECT n FROM alen) / 10) AS INT64) AS dmax FROM UNNEST(GENERATE_ARRAY(1, 10)) AS k),
h AS (SELECT p.user_id, k.k, COUNTIF(rd.day <= k.dmax) AS held FROM pop p CROSS JOIN k LEFT JOIN rd ON rd.user_id = p.user_id GROUP BY 1,2)
SELECT (SELECT COUNT(*) FROM pop) AS payers, STRING_AGG(FORMAT('%d:%.1f', k, avg_pct), ' ' ORDER BY k) AS deciles
FROM (SELECT k, 100 * AVG(held) / 7 AS avg_pct FROM h GROUP BY k);
