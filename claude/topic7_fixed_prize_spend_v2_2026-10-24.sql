-- Topic 7 (Eden 2026-10-24): clean rerun of topic7_fixed_prize_spend_2026-10-24.sql for slide t7g.
-- Changes: light group = PAYERS only (album spend > $0 and < $150); both groups split by finished (got the prize) vs all;
-- exact share of album revenue (all non-excluded players). Dice album 63, prize code 7 (200K) on the last row before close.
-- Finished = 144 unique stickers on close-1 (Dice daily table does not update on the close day). Results: claude/topic7-fixed-prize-spend-2026-10-24.md
WITH ud AS (
  SELECT user_id, date_dim, IFNULL(unique_stickers_lt,0) AS uniq, album_reward_code AS code, album_reward_value AS r_val,
    IFNULL(spent_in_album_today,0) AS spend, IFNULL(is_excluded,FALSE) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND album_id = 63 AND date_dim < album_end_date),
u AS (
  SELECT user_id, SUM(spend) AS alb_rev, MAX(uniq) AS uniq_end,
    ARRAY_AGG(code IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS code,
    ARRAY_AGG(r_val IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS r_val, LOGICAL_OR(excl) AS excl
  FROM ud GROUP BY 1),
tot AS (SELECT SUM(alb_rev) AS rev_all, COUNTIF(alb_rev > 0) AS payers_all FROM u WHERE NOT excl),
g AS (
  SELECT IF(alb_rev >= 2000, 'top_2k', 'light_0_150') AS grp, alb_rev, uniq_end >= 144 AS fin, r_val
  FROM u WHERE NOT excl AND code = 7 AND (alb_rev >= 2000 OR (alb_rev > 0 AND alb_rev < 150))),
agg AS (SELECT grp, 'all' AS who, alb_rev, r_val FROM g UNION ALL SELECT grp, 'finished', alb_rev, r_val FROM g WHERE fin)
SELECT grp, who, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(payers_all), 4) AS share_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev, ROUND(SUM(alb_rev)) AS rev,
  ROUND(APPROX_QUANTILES(alb_rev, 2)[OFFSET(1)]) AS med_spend, ROUND(APPROX_QUANTILES(r_val, 2)[OFFSET(1)]) AS med_prize,
  ROUND(APPROX_QUANTILES(r_val / alb_rev, 2)[OFFSET(1)]) AS med_rolls_per_usd, ROUND(SUM(r_val) / SUM(alb_rev)) AS group_rolls_per_usd
FROM agg CROSS JOIN tot GROUP BY 1, 2 ORDER BY 1, 2
