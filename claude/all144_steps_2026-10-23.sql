-- All 144 set stickers held by the median paying player, per album day (Eden, 2026-10-23).
-- Domino 20 = ALL payers (no easy/hard split); Dice 63; Disney 15. Payer = spent on any album day incl. close.
-- Same population and logic as golden_timeline_2026-10-23.sql; output only the daily series (day:median held:share getting a new sticker).

-- ===== DOMINO 20, all payers (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id = 20 AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)
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
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_min_date) AS d
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id = 20
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
rd AS (SELECT r.album_id, r.user_id, DATE_DIFF(r.d, p.a_start, DAY) + 1 AS day FROM r JOIN pop p USING (album_id, user_id)),
alen AS (SELECT album_id, DATE_DIFF(ANY_VALUE(a_end), ANY_VALUE(a_start), DAY) + 1 AS n_days FROM pop GROUP BY 1),
grid AS (SELECT p.album_id, p.user_id, day FROM pop p JOIN alen USING (album_id), UNNEST(GENERATE_ARRAY(1, alen.n_days)) AS day),
daily AS (SELECT album_id, user_id, day, COUNT(*) AS new_r FROM rd GROUP BY 1,2,3),
cum AS (
  SELECT g.album_id, g.day, IFNULL(dl.new_r, 0) AS new_r,
    SUM(IFNULL(dl.new_r, 0)) OVER (PARTITION BY g.album_id, g.user_id ORDER BY g.day) AS held
  FROM grid g LEFT JOIN daily dl USING (album_id, user_id, day)
)
SELECT album_id, (SELECT COUNT(*) FROM pop) AS n_payers, STRING_AGG(FORMAT('%d:%d:%.2f', day, p50, got_new), ' ' ORDER BY day) AS series
FROM (SELECT album_id, day, APPROX_QUANTILES(held, 2)[OFFSET(1)] AS p50, AVG(IF(new_r > 0, 1, 0)) AS got_new FROM cum GROUP BY 1,2)
GROUP BY 1;

-- ===== DICE 63 (dice-dreams-dbt) and DISNEY 15 (solitaire-dreams-411507): same query shape, as run 2026-10-23 =====
-- Dice: population from golden_timeline_2026-10-23.sql (hist CTE, fixed first-album rule), album_id = 63,
--   sticker table 30_intermediate.fact_user_album_stickers, s.sticker_type IN ('common','golden','super'), date column sticker_collected_date, window 2026-06-15..2026-09-07.
-- Disney: bi_prod.user_daily_album / bi_entity_prod.dim_user_album_stickers, album_id = 15, bad_users from bi_prod.solitaire_user_daily_metrics_agg_df (exclude_reason IS NOT NULL),
--   LOWER(s.sticker_type) IN ('common','golden','royal').
