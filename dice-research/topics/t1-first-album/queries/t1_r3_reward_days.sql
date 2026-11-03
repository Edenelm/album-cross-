-- Topic 1 reopened / R3: payout mechanism. What does an album reward day look like next to the player's other days? Project dice-dreams-dbt.
-- Population: first-album entrants 57-65 (D-010 groups), active days in entry .. close-1 of the first album, players with >= 1 album-reward day.
-- Reward day = album rolls received that day > 0 (user_daily_rolls_by_source, source_rolls_group = 'album': set + album-completion rewards).
-- Compared, for the same players: reward days vs their other active days. Rolls spent (rolls_out_sum), out of rolls (out_of_rolls_count > 0),
--   paid that day (revenues_sum > 0), active next day (next calendar day in user_daily_metrics_agg; next day may fall after close).
-- Reward size = album rolls / rolls spent that day. Why: tells whether album rewards are big enough to extend play, or small next to daily use.
-- Bias guarded: player mix (same players on both day types). Not removed: reward days are high-activity days by construction (sets come from play).
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
  SELECT p1.user_id, p1.entry, a.a_end,
    CASE WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 29 THEN 'a_start' WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 15 THEN 'b_middle'
         WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 8 THEN 'c_late' WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 4 THEN 'd_final_week'
         ELSE 'e_last_days' END AS grp
  FROM p1 JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p1.album_id AND NOT p1.ex AND p1.user_id NOT IN (SELECT user_id FROM excl) AND p1.entry < a.a_end),
m AS (
  SELECT b.user_id, b.grp, x.date_dim, IFNULL(x.revenues_sum, 0) AS rev
  FROM b JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` x
    ON x.user_id = b.user_id AND x.date_dim BETWEEN b.entry AND b.a_end
  WHERE x.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19'),
md AS (
  SELECT user_id, grp, date_dim, rev, DATE_DIFF(LEAD(date_dim) OVER (PARTITION BY user_id ORDER BY date_dim), date_dim, DAY) = 1 AS next_active
  FROM m),
r AS (
  SELECT x.user_id, x.date_dim, IFNULL(x.rolls_out_sum, 0) AS r_out, IFNULL(x.out_of_rolls_count, 0) > 0 AS ooc
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out` x
  WHERE x.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND x.user_id IN (SELECT user_id FROM b)),
s AS (
  SELECT y.user_id, y.date_dim, SUM(y.rolls_value_sum) AS r_album
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` y
  WHERE y.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND y.roll_type = 'rolls_in' AND y.source_rolls_group = 'album'
    AND y.user_id IN (SELECT user_id FROM b)
  GROUP BY 1, 2),
d AS (
  SELECT md.user_id, md.grp, md.rev, IFNULL(md.next_active, FALSE) AS next_active, IFNULL(r.r_out, 0) AS r_out, IFNULL(r.ooc, FALSE) AS ooc,
    IFNULL(s.r_album, 0) AS r_album
  FROM md JOIN b ON b.user_id = md.user_id AND md.date_dim <= DATE_SUB(b.a_end, INTERVAL 1 DAY)
  LEFT JOIN r ON r.user_id = md.user_id AND r.date_dim = md.date_dim
  LEFT JOIN s ON s.user_id = md.user_id AND s.date_dim = md.date_dim),
pl AS (SELECT user_id FROM d GROUP BY 1 HAVING COUNTIF(r_album > 0) >= 1)
SELECT d.grp, IF(d.r_album > 0, 'reward_day', 'other_day') AS day_type, COUNT(DISTINCT d.user_id) AS players, COUNT(*) AS days,
  APPROX_QUANTILES(d.r_album, 2)[OFFSET(1)] AS med_album_rolls, APPROX_QUANTILES(d.r_out, 2)[OFFSET(1)] AS med_rolls_spent,
  APPROX_QUANTILES(SAFE_DIVIDE(d.r_album, NULLIF(d.r_out, 0)), 4) AS q_reward_vs_spent,
  ROUND(AVG(IF(d.ooc, 1, 0)), 3) AS out_of_rolls_share, ROUND(AVG(IF(d.rev > 0, 1, 0)), 3) AS paid_share,
  ROUND(AVG(d.rev), 2) AS rev_per_day, ROUND(AVG(IF(d.next_active, 1, 0)), 3) AS next_day_active
FROM d JOIN pl USING (user_id)
GROUP BY 1, 2 ORDER BY 1, 2;
