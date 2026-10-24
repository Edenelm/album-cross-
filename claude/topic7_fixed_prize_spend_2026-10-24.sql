-- Topic 7 (Eden 2026-10-24): "these players spend a lot album after album but stay on a fixed prize".
-- Cohort: Dice album 63, prize code 7 (200K) on the last row before close, not excluded, split by album-63 spend (start..close-1):
--   top = $2,000+, low = under $150. Then the same players in albums 59 and 61: album spend, prize value, share with $2K+.
-- Rolls of prize per $ = prize value / album spend (median player). Results: claude/topic7-fixed-prize-spend-2026-10-24.md
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end, album_reward_code AS code, album_reward_value AS r_val,
    IFNULL(spent_in_album_today,0) AS spend, IFNULL(is_excluded,FALSE) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-09-07' AND album_id IN (59, 61, 63) AND date_dim < album_end_date),
u AS (
  SELECT album_id, user_id, SUM(spend) AS alb_rev,
    ARRAY_AGG(code IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS code,
    ARRAY_AGG(r_val IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS r_val, LOGICAL_OR(excl) AS excl
  FROM ud GROUP BY 1, 2),
c AS (
  SELECT user_id, IF(alb_rev >= 2000, 'top_2k', 'low_150') AS grp
  FROM u WHERE album_id = 63 AND code = 7 AND NOT excl AND (alb_rev >= 2000 OR alb_rev < 150))
SELECT c.grp, u.album_id, COUNT(*) AS players_in_album, ROUND(APPROX_QUANTILES(u.alb_rev, 2)[OFFSET(1)]) AS med_spend,
  ROUND(AVG(u.alb_rev)) AS avg_spend, ROUND(AVG(IF(u.alb_rev >= 2000, 1, 0)), 3) AS pct_2k, ROUND(AVG(IF(u.code = 7, 1, 0)), 3) AS pct_code7,
  ROUND(APPROX_QUANTILES(u.r_val, 2)[OFFSET(1)]) AS med_prize,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(u.r_val, NULLIF(u.alb_rev, 0)), 2)[OFFSET(1)]) AS med_rolls_per_usd
FROM c JOIN u USING (user_id) GROUP BY 1, 2 ORDER BY 1, 2
