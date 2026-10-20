-- Where does the post-completion roll stock come from? Dice album 63, payer finishers (144 by end of close day), standard population.
-- Groups: light_mid_big = Easy/Medium with prize code 4-7; light_mid_small = Easy/Medium code 1-3; high_top = Hard/Extreme.
-- Window: completion day (k=0) to k=2 (calendar days). Rolls in by source; share of the group's free rolls in; per player.
-- Habit rolls out per day = close-18 .. close-5 average (same as other recovery queries), to express rolls in as days of play.
WITH ud AS (
  SELECT user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, DATE(user_album_finish_ts) AS flag_fin_d, album_segment AS a_seg, album_reward_code AS r_code
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-09-07' AND album_id = 63 AND date_dim <= album_end_date
),
u AS (
  SELECT user_id, ANY_VALUE(a_end) AS a_end,
    NULLIF(LEAST(IFNULL(MIN(IF(uniq >= 144, date_dim, NULL)), DATE '2099-01-01'), IFNULL(MIN(IF(flag_fin_d <= a_end, flag_fin_d, NULL)), DATE '2099-01-01')), DATE '2099-01-01') AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d, MAX(a_seg) AS a_seg, MAX(r_code) AS r_code
  FROM ud GROUP BY 1
),
fin AS (
  SELECT user_id, a_end, fin_d,
    CASE WHEN a_seg IN ('Easy','Medium') AND r_code >= 4 THEN 'a_light_mid_big'
         WHEN a_seg IN ('Easy','Medium') THEN 'b_light_mid_small' ELSE 'c_high_top' END AS grp
  FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND fin_d IS NOT NULL AND alb_rev > 0
),
habit AS (
  SELECT f.user_id, SUM(r.rolls_out_sum) / 14 AS habit_out_pd
  FROM fin f JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out` r
    ON r.user_id = f.user_id AND r.date_dim BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_SUB(f.a_end, INTERVAL 5 DAY)
  WHERE r.date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-09-02'
  GROUP BY 1
),
rin AS (
  SELECT f.grp, s.source, s.source_rolls_group, SUM(s.rolls_value_sum) AS rolls_in
  FROM fin f JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
    ON s.user_id = f.user_id AND s.date_dim BETWEEN f.fin_d AND DATE_ADD(f.fin_d, INTERVAL 2 DAY)
  WHERE s.date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-09' AND s.roll_type = 'rolls_in'
  GROUP BY 1, 2, 3
),
g AS (
  SELECT f.grp, COUNT(*) AS n, SUM(h.habit_out_pd) AS habit_out_pd_sum, APPROX_QUANTILES(h.habit_out_pd, 2)[OFFSET(1)] AS med_habit_out_pd
  FROM fin f LEFT JOIN habit h USING (user_id) GROUP BY 1
),
tot AS (SELECT grp, SUM(rolls_in) AS all_in FROM rin GROUP BY 1)
SELECT r.grp, g.n, ROUND(g.med_habit_out_pd) AS med_habit_rolls_out_per_day,
  r.source_rolls_group, r.source,
  ROUND(r.rolls_in / g.n) AS rolls_in_per_player_d0_2,
  ROUND(r.rolls_in / t.all_in, 4) AS share_of_group_rolls_in,
  ROUND(SAFE_DIVIDE(r.rolls_in, g.habit_out_pd_sum), 2) AS in_days_of_habit_play,
  ROUND(t.all_in / g.n) AS all_rolls_in_per_player_d0_2,
  ROUND(SAFE_DIVIDE(t.all_in, g.habit_out_pd_sum), 2) AS all_in_days_of_habit_play
FROM rin r JOIN g USING (grp) JOIN tot t USING (grp)
WHERE r.rolls_in / t.all_in >= 0.02
ORDER BY r.grp, share_of_group_rolls_in DESC
