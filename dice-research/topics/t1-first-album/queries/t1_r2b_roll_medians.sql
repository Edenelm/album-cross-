-- Topic 1 reopened / R2b: validation of R2 roll magnitudes. Project dice-dreams-dbt. Albums 57-65, first-album entrants, D-010 groups.
-- Why: R2 means of rolls (features, spent) were millions per player = driven by a few heavy players. This query gives per-player
--   medians, p90 and each player's own share of non-wager inflow by source (album / features & other / bought).
-- Window entry .. close-1. Close-day entrants have no window (entry < close filter).
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 65),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
ad AS (
  SELECT u.user_id, u.album_id, u.date_dim, IFNULL(u.is_excluded, FALSE) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND u.album_id BETWEEN 57 AND 65 AND u.date_dim <= a.a_end),
p1 AS (SELECT user_id, album_id, MIN(date_dim) AS entry, LOGICAL_OR(ex) AS ex FROM ad GROUP BY 1, 2),
b AS (
  SELECT p1.user_id, p1.album_id, p1.entry, a.a_end,
    CASE WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 29 THEN 'a_start' WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 15 THEN 'b_middle'
         WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 8 THEN 'c_late' WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 4 THEN 'd_final_week'
         WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 1 THEN 'e_last_days' ELSE 'f_close_day' END AS grp
  FROM p1 JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p1.album_id AND NOT p1.ex AND p1.user_id NOT IN (SELECT user_id FROM excl)
    AND p1.entry < a.a_end),
rio AS (
  SELECT b.user_id, b.album_id, COUNT(*) AS days, SUM(IFNULL(x.rolls_in_sum, 0)) AS r_in, SUM(IFNULL(x.rolls_out_sum, 0)) AS r_out,
    SUM(IFNULL(x.rolls_amount_from_purchase, 0)) AS r_bought
  FROM b JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out` x
    ON x.user_id = b.user_id AND x.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY)
  WHERE x.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18'
  GROUP BY 1, 2),
rbs AS (
  SELECT b.user_id, b.album_id,
    SUM(IF(s.source_rolls_group = 'album', s.rolls_value_sum, 0)) AS r_album, SUM(IF(s.source_rolls_group = 'core wager', s.rolls_value_sum, 0)) AS r_wager,
    SUM(s.rolls_value_sum) AS r_in_src
  FROM b JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
    ON s.user_id = b.user_id AND s.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY)
  WHERE s.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND s.roll_type = 'rolls_in'
  GROUP BY 1, 2),
t AS (
  SELECT b.grp, IFNULL(r.r_in, 0) AS r_in, IFNULL(r.r_out, 0) AS r_out, IFNULL(r.r_bought, 0) AS r_bought, IFNULL(r.days, 0) AS days,
    IFNULL(s.r_album, 0) AS r_album, IFNULL(s.r_wager, 0) AS r_wager, IFNULL(s.r_in_src, 0) AS r_in_src,
    GREATEST(IFNULL(s.r_in_src, 0) - IFNULL(s.r_album, 0) - IFNULL(s.r_wager, 0) - IFNULL(r.r_bought, 0), 0) AS r_feat
  FROM b LEFT JOIN rio r USING (user_id, album_id) LEFT JOIN rbs s USING (user_id, album_id))
SELECT grp, COUNT(*) AS players,
  APPROX_QUANTILES(r_in_src, 2)[OFFSET(1)] AS med_rolls_in_by_source, APPROX_QUANTILES(r_in, 2)[OFFSET(1)] AS med_rolls_in_daily_table,
  APPROX_QUANTILES(r_out, 2)[OFFSET(1)] AS med_rolls_out, APPROX_QUANTILES(r_album, 2)[OFFSET(1)] AS med_album,
  APPROX_QUANTILES(r_feat, 2)[OFFSET(1)] AS med_features, APPROX_QUANTILES(r_wager, 2)[OFFSET(1)] AS med_wager,
  APPROX_QUANTILES(r_bought, 2)[OFFSET(1)] AS med_bought, ROUND(AVG(IF(r_bought > 0, 1, 0)), 3) AS share_with_bought_rolls,
  APPROX_QUANTILES(r_in_src, 10)[OFFSET(9)] AS p90_rolls_in, APPROX_QUANTILES(r_out, 10)[OFFSET(9)] AS p90_rolls_out,
  ROUND(AVG(SAFE_DIVIDE(r_album, NULLIF(r_in_src - r_wager, 0))), 3) AS mean_player_album_share_excl_wager,
  APPROX_QUANTILES(SAFE_DIVIDE(r_album, NULLIF(r_in_src - r_wager, 0)), 10)[OFFSET(9)] AS p90_player_album_share,
  ROUND(AVG(SAFE_DIVIDE(r_feat, NULLIF(r_in_src - r_wager, 0))), 3) AS mean_player_feature_share,
  ROUND(AVG(SAFE_DIVIDE(r_bought, NULLIF(r_in_src - r_wager, 0))), 3) AS mean_player_bought_share,
  APPROX_QUANTILES(SAFE_DIVIDE(r_out, NULLIF(days, 0)), 2)[OFFSET(1)] AS med_rolls_out_per_day,
  APPROX_QUANTILES(SAFE_DIVIDE(r_in_src - r_wager, NULLIF(days, 0)), 2)[OFFSET(1)] AS med_inflow_excl_wager_per_day
FROM t GROUP BY 1 ORDER BY 1;
