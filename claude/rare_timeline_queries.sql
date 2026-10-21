-- Rare-sticker timeline for the median paying player (Eden, 2026-10-20). Results: claude/rare-timeline-2026-10-20.md
-- Population: standard (not first album, not excluded, login ratio >= 0.5 on the last row before close, row on close-1),
--   payer = paid on any album day incl. the close day. Albums Dice 61/63, Domino 19/20, Disney 14/15.
-- Rare = Dice Super (12 per album), Domino Royal (8-9), Disney Royal (7). New rare = first receipt of that sticker.
-- Day = days since album start (day 1 = start day). Output A (row_type 'day'): per album and day, median / p25 / p75 rares held
--   at the end of the day, share of payers who got a new rare that day. Output B ('gap'): per album, gaps between a player's
--   consecutive new rares (start -> 1st rare counts as the first gap): median gap, share of gaps <= 4 days,
--   median of each player's own median gap, median day of the 1st rare, median rares at close, revenue share of the population.

-- ===== DICE 61/63 (dice-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_start, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
pop AS (SELECT album_id, user_id, a_start, a_end, alb_rev FROM pop0 WHERE rev_c > 0),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_date) AS d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type = 'super' AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
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
),
gaps AS (
  SELECT album_id, user_id, day - IFNULL(LAG(day) OVER (PARTITION BY album_id, user_id ORDER BY day), 0) AS gap,
    ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY day) AS k
  FROM (SELECT DISTINCT album_id, user_id, day FROM rd)
),
pg AS (SELECT album_id, user_id, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS own_med FROM gaps GROUP BY 1,2),
endh AS (SELECT album_id, user_id, COUNT(*) AS n_r FROM rd GROUP BY 1,2)
SELECT 'day' AS row_type, album_id, day, COUNT(*) AS n,
  APPROX_QUANTILES(held, 4)[OFFSET(1)] AS p25, APPROX_QUANTILES(held, 4)[OFFSET(2)] AS p50, APPROX_QUANTILES(held, 4)[OFFSET(3)] AS p75,
  ROUND(AVG(IF(new_r > 0, 1, 0)), 3) AS got_new, NULL AS gap_med, NULL AS gap_le4, NULL AS own_med, NULL AS first_day, NULL AS rev_share
FROM cum GROUP BY 1,2,3
UNION ALL
SELECT 'gap', gs.album_id, NULL, gs.n_gaps, NULL, NULL, NULL, NULL, gs.gap_med, gs.gap_le4, os.own_med, gs.first_day, rs.rev_share
FROM (SELECT album_id, COUNT(*) AS n_gaps, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS gap_med, ROUND(AVG(IF(gap <= 4, 1, 0)), 3) AS gap_le4,
        APPROX_QUANTILES(IF(k = 1, gap, NULL), 2 IGNORE NULLS)[OFFSET(1)] AS first_day FROM gaps GROUP BY 1) gs
JOIN (SELECT album_id, APPROX_QUANTILES(own_med, 2)[OFFSET(1)] AS own_med FROM pg GROUP BY 1) os USING (album_id)
JOIN (SELECT p.album_id, ROUND(SUM(p.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share FROM pop p JOIN tot t USING (album_id) GROUP BY 1) rs USING (album_id)
ORDER BY 1,2,3
;

-- ===== DOMINO 19/20 (domino-dreams-dbt) — Royals; compact output: series = day:median rares held:share getting a new rare =====
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
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_start, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND user_id NOT IN (SELECT user_id FROM bad_users)),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
pop AS (SELECT album_id, user_id, a_start, a_end, alb_rev FROM pop0 WHERE rev_c > 0),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_min_date) AS d
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal' AND s.sticker_collected_min_date <= p.a_end
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
),
gaps AS (
  SELECT album_id, user_id, day - IFNULL(LAG(day) OVER (PARTITION BY album_id, user_id ORDER BY day), 0) AS gap,
    ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY day) AS k
  FROM (SELECT DISTINCT album_id, user_id, day FROM rd)
),
pg AS (SELECT album_id, user_id, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS own_med FROM gaps GROUP BY 1,2),
endh AS (SELECT album_id, user_id, COUNT(*) AS n_r FROM rd GROUP BY 1,2)
SELECT d.album_id, d.series, g.gap_med, g.gap_le4, o.own_med, g.first_day, rs.rev_share, rs.n_payers
FROM (SELECT album_id, STRING_AGG(FORMAT('%d:%d:%.2f', day, p50, got_new), ' ' ORDER BY day) AS series
      FROM (SELECT album_id, day, APPROX_QUANTILES(held, 2)[OFFSET(1)] AS p50, AVG(IF(new_r > 0, 1, 0)) AS got_new FROM cum GROUP BY 1,2)
      GROUP BY 1) d
JOIN (SELECT album_id, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS gap_med, ROUND(AVG(IF(gap <= 4, 1, 0)), 3) AS gap_le4,
        APPROX_QUANTILES(IF(k = 1, gap, NULL), 2 IGNORE NULLS)[OFFSET(1)] AS first_day FROM gaps GROUP BY 1) g USING (album_id)
JOIN (SELECT album_id, APPROX_QUANTILES(own_med, 2)[OFFSET(1)] AS own_med FROM pg GROUP BY 1) o USING (album_id)
JOIN (SELECT p.album_id, COUNT(*) AS n_payers, ROUND(SUM(p.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share FROM pop p JOIN tot t USING (album_id) GROUP BY 1) rs USING (album_id)
ORDER BY 1
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507) — Royals; same output =====
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
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_start, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
  AND user_id NOT IN (SELECT user_id FROM bad_users)),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
pop AS (SELECT album_id, user_id, a_start, a_end, alb_rev FROM pop0 WHERE rev_c > 0),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_min_date) AS d
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (14,15)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal' AND s.sticker_collected_min_date <= p.a_end
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
),
gaps AS (
  SELECT album_id, user_id, day - IFNULL(LAG(day) OVER (PARTITION BY album_id, user_id ORDER BY day), 0) AS gap,
    ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY day) AS k
  FROM (SELECT DISTINCT album_id, user_id, day FROM rd)
),
pg AS (SELECT album_id, user_id, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS own_med FROM gaps GROUP BY 1,2),
endh AS (SELECT album_id, user_id, COUNT(*) AS n_r FROM rd GROUP BY 1,2)
SELECT d.album_id, d.series, g.gap_med, g.gap_le4, o.own_med, g.first_day, rs.rev_share, rs.n_payers
FROM (SELECT album_id, STRING_AGG(FORMAT('%d:%d:%.2f', day, p50, got_new), ' ' ORDER BY day) AS series
      FROM (SELECT album_id, day, APPROX_QUANTILES(held, 2)[OFFSET(1)] AS p50, AVG(IF(new_r > 0, 1, 0)) AS got_new FROM cum GROUP BY 1,2)
      GROUP BY 1) d
JOIN (SELECT album_id, APPROX_QUANTILES(gap, 2)[OFFSET(1)] AS gap_med, ROUND(AVG(IF(gap <= 4, 1, 0)), 3) AS gap_le4,
        APPROX_QUANTILES(IF(k = 1, gap, NULL), 2 IGNORE NULLS)[OFFSET(1)] AS first_day FROM gaps GROUP BY 1) g USING (album_id)
JOIN (SELECT album_id, APPROX_QUANTILES(own_med, 2)[OFFSET(1)] AS own_med FROM pg GROUP BY 1) o USING (album_id)
JOIN (SELECT p.album_id, COUNT(*) AS n_payers, ROUND(SUM(p.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share FROM pop p JOIN tot t USING (album_id) GROUP BY 1) rs USING (album_id)
ORDER BY 1
;
