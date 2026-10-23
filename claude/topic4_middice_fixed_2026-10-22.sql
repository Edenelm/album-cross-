-- Topic 4 (2026-10-22): MidDice rerun on the fixed Dice population. Only change: 'not first album' = has a row in an earlier album (hist), not user_past_album_count > 0.
-- MidDice (2026-10-15) Dice 61/63: same as StallDice, groups = P50-80 / P80-95 (middle payers).
-- stall = first day reaching final count: total / commons / Goldens / Supers. Rare stall = later of Golden / Super. After stall: is_active days and spend.
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-06'
  GROUP BY 1),
alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end, 35 AS n UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07', 42),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.n, CAST(CEIL(0.75 * alb.n) AS INT64) AS cp,
    DATE_DIFF(a.date_dim, alb.a_start, DAY) AS d,
    a.album_login_ratio AS lr, IF(h.first_album_seen < a.album_id, 1, 0) AS past,
    IFNULL(a.spent_in_album_today, 0) AS spend, IFNULL(a.is_active, FALSE) AS act,
    IFNULL(a.unique_stickers_lt, 0) AS ua_, IFNULL(a.unique_common_stickers_lt, 0) AS uc,
    IFNULL(a.unique_golden_stickers_lt, 0) AS ug, IFNULL(a.unique_super_stickers_lt, 0) AS us
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id) JOIN hist h ON h.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
r1 AS (
  SELECT album_id, user_id, date_dim, n, cp, d, lr, past, spend, act, ua_, uc, ug, us,
    MAX(ua_) OVER w AS ua_end, MAX(uc) OVER w AS uc_end, MAX(ug) OVER w AS ug_end, MAX(us) OVER w AS us_end
  FROM r0 WINDOW w AS (PARTITION BY album_id, user_id)),
r2 AS (
  SELECT album_id, user_id, date_dim, n, cp, d, lr, past, spend, act, ua_end, uc_end, ug_end, us_end,
    MIN(IF(ua_ = ua_end, d, NULL)) OVER w AS t_st, MIN(IF(uc = uc_end, d, NULL)) OVER w AS c_st,
    MIN(IF(ug = ug_end, d, NULL)) OVER w AS g_st, MIN(IF(us = us_end, d, NULL)) OVER w AS s_st
  FROM r1 WINDOW w AS (PARTITION BY album_id, user_id)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, ANY_VALUE(cp) AS cpv, SUM(spend) AS total, SUM(IF(d <= cp - 1, spend, 0)) AS so_far,
    144 - ANY_VALUE(ua_end) AS m_end, 12 - ANY_VALUE(us_end) AS miss_super,
    ANY_VALUE(t_st) AS t_st, ANY_VALUE(c_st) AS c_st, ANY_VALUE(g_st) AS g_st, ANY_VALUE(s_st) AS s_st,
    SUM(IF(d > t_st, spend, 0)) AS spend_after, COUNTIF(d > t_st AND act) AS act_after,
    SUM(IF(d > GREATEST(g_st, s_st), spend, 0)) AS spend_after_rare, COUNTIF(d > GREATEST(g_st, s_st) AND act) AS act_after_rare
  FROM r2 GROUP BY 1, 2
  HAVING MIN(past) > 0 AND MIN(d) <= ANY_VALUE(cp) - 1
     AND ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
p AS (
  SELECT album_id, n, total, so_far, m_end, miss_super, t_st, c_st, g_st, s_st, GREATEST(g_st, s_st) AS rare_st,
    spend_after, act_after, spend_after_rare, act_after_rare,
    (n - 1) - t_st AS days_after, (n - 1) - GREATEST(g_st, s_st) AS rare_days_after,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM u),
f AS (
  SELECT album_id, n, total, m_end, miss_super, t_st, c_st, g_st, s_st, rare_st, spend_after, act_after, spend_after_rare, act_after_rare,
    days_after, rare_days_after,
    CASE WHEN pr >= 0.5 AND pr < 0.8 THEN 'P50-80' WHEN pr >= 0.8 AND pr < 0.95 THEN 'P80-95' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0)
SELECT album_id, grp, st, COUNT(*) AS players, ROUND(SUM(total)) AS rev,
  ROUND(SUM(IF(t_st / n >= 0.9, total, 0)) / SUM(total), 3) AS rev_stall_last_10pct,
  ROUND(SUM(IF(t_st / n >= 0.75 AND t_st / n < 0.9, total, 0)) / SUM(total), 3) AS rev_stall_75_90,
  ROUND(SUM(total * days_after) / SUM(total), 1) AS rev_w_days_stuck,
  ROUND(SAFE_DIVIDE(SUM(act_after), SUM(days_after)), 3) AS active_rate_after_stall,
  ROUND(SUM(spend_after) / SUM(total), 3) AS share_rev_after_stall,
  ROUND(SUM(total * c_st / n) / SUM(total), 3) AS rev_w_common_stall_pct,
  ROUND(SUM(total * g_st / n) / SUM(total), 3) AS rev_w_golden_stall_pct,
  ROUND(SUM(total * s_st / n) / SUM(total), 3) AS rev_w_super_stall_pct,
  ROUND(SUM(IF(rare_st / n < 0.75, total, 0)) / SUM(total), 3) AS rev_rare_stuck_before_q4,
  ROUND(SUM(IF(rare_st < c_st, total, 0)) / SUM(total), 3) AS rev_rare_stuck_before_commons,
  ROUND(SUM(total * rare_days_after) / SUM(total), 1) AS rev_w_rare_days_stuck,
  ROUND(SUM(total * (n - rare_st)) / SUM(total), 1) AS rev_w_last_rare_days_before_close,
  ROUND(SAFE_DIVIDE(SUM(act_after_rare), SUM(rare_days_after)), 3) AS active_rate_after_rare_stall,
  ROUND(SUM(spend_after_rare) / SUM(total), 3) AS share_rev_after_rare_stall,
  ROUND(SUM(total * miss_super) / SUM(total), 2) AS rev_w_missing_super,
  ROUND(SUM(total * m_end) / SUM(total), 2) AS rev_w_missing_total
FROM f WHERE grp IS NOT NULL GROUP BY 1,2,3 ORDER BY 1,2,3
