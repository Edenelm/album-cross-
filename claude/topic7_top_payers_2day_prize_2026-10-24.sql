-- Topic 7 (Eden 2026-10-24): test arm = only $2K+ payers in the 200K tier, prize = 2 days of the player's own play.
-- Who: Dice players with album_reward_code 7 (200K) on the last row before close, album spend (start..close-1) >= $2,000, not excluded.
-- Own play a day = rolls bet (30_intermediate.user_daily_rolls_in_out.rolls_out_sum) from album start to close-1 / album days.
-- Output per album: players, finishers (144 on close-1; the Dice daily table does not update on the close day), share of album revenue
-- (all non-excluded players), median rolls a day, today's prize in days, the 2-day prize, extra rolls for the finishers.
-- Albums 59 / 61 / 63. Results: claude/topic7-top-payers-2day-prize-2026-10-24.md
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    album_reward_code AS code, album_reward_value AS r_val, IFNULL(spent_in_album_today,0) AS spend, IFNULL(is_excluded,FALSE) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-09-07' AND album_id IN (59, 61, 63) AND date_dim < album_end_date),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS alb_rev, MAX(uniq) AS uniq_end,
    ARRAY_AGG(code IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS code,
    ARRAY_AGG(r_val IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS r_val, LOGICAL_OR(excl) AS excl
  FROM ud GROUP BY 1, 2),
tot AS (SELECT album_id, SUM(alb_rev) AS rev_all FROM u WHERE NOT excl GROUP BY 1),
g AS (SELECT album_id, user_id, a_start, a_end, alb_rev, uniq_end, r_val FROM u WHERE NOT excl AND code = 7 AND alb_rev >= 2000),
play AS (
  SELECT g.album_id, g.user_id, SUM(IFNULL(r.rolls_out_sum,0)) / ANY_VALUE(DATE_DIFF(g.a_end, g.a_start, DAY)) AS pd
  FROM g JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out` r ON r.user_id = g.user_id AND r.date_dim >= g.a_start AND r.date_dim < g.a_end
  WHERE r.date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-09-07'
  GROUP BY 1, 2),
x AS (SELECT g.album_id, g.alb_rev, g.uniq_end >= 144 AS fin, g.r_val, p.pd FROM g LEFT JOIN play p USING (album_id, user_id))
SELECT x.album_id, COUNT(*) AS players, COUNTIF(fin) AS finishers, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(SUM(IF(fin, alb_rev, 0)) / ANY_VALUE(rev_all), 4) AS share_rev_fin, ROUND(APPROX_QUANTILES(alb_rev, 2)[OFFSET(1)]) AS med_album_usd,
  ROUND(APPROX_QUANTILES(r_val, 2)[OFFSET(1)]) AS med_prize_now, ROUND(APPROX_QUANTILES(pd, 2)[OFFSET(1)]) AS med_rolls_day,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(r_val, pd), 4)[OFFSET(2)], 2) AS med_days_now,
  ROUND(APPROX_QUANTILES(2 * pd, 4)[OFFSET(1)]) AS p25_prize_2d, ROUND(APPROX_QUANTILES(2 * pd, 4)[OFFSET(2)]) AS med_prize_2d,
  ROUND(APPROX_QUANTILES(2 * pd, 4)[OFFSET(3)]) AS p75_prize_2d,
  ROUND(SUM(IF(fin, GREATEST(2 * pd - r_val, 0), 0))) AS extra_rolls_finishers,
  ROUND(SUM(IF(fin, pd, 0))) AS finishers_rolls_day_total
FROM x JOIN tot USING (album_id) GROUP BY 1 ORDER BY 1
