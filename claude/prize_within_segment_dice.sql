-- Dice: prize size within the same difficulty segment. Albums 61, 63. Payer finishers (144 by end of close day), standard population.
-- Rows = album x album_segment (Easy/Medium/Hard/Extreme) x album_reward_code (1-7). Same definitions as claude/finisher_prize_burn_queries.sql (Dice).
-- Question (Eden 2026-10-19): inside the same segment, do players with a bigger final prize return to purchase more slowly?
-- Strength check per row: median habit revenue per day and median album revenue, so codes can be compared at similar strength.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, DATE(user_album_finish_ts) AS flag_fin_d,
    album_segment AS a_seg, album_reward_code AS r_code, album_reward_value AS r_val
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    NULLIF(LEAST(IFNULL(MIN(IF(uniq >= 144, date_dim, NULL)), DATE '2099-01-01'), IFNULL(MIN(IF(flag_fin_d <= a_end, flag_fin_d, NULL)), DATE '2099-01-01')), DATE '2099-01-01') AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    MAX(a_seg) AS a_seg, MAX(r_code) AS r_code, MAX(r_val) AS r_val
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev, a_seg, r_code, r_val FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
tot AS (SELECT album_id, COUNT(*) AS pop_all, SUM(alb_rev) AS pop_rev, COUNTIF(fin_d IS NOT NULL AND alb_rev > 0) AS n_fin_pay FROM pop GROUP BY 1),
fin AS (SELECT album_id, user_id, a_end, fin_d, alb_rev, a_seg, r_code, r_val FROM pop WHERE fin_d IS NOT NULL AND alb_rev > 0),
m AS (
  SELECT COALESCE(a.user_id, r.user_id) AS user_id, COALESCE(a.date_dim, r.date_dim) AS d,
    IFNULL(a.revenues_sum,0) AS rev, IFNULL(r.rolls_out_sum,0) AS play, IFNULL(r.not_enough_rolls_count,0) > 0 AS ooc
  FROM (SELECT user_id, date_dim, revenues_sum FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
        WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-22') a
  FULL JOIN (SELECT user_id, date_dim, rolls_out_sum, not_enough_rolls_count FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
        WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-22') r
  ON a.user_id = r.user_id AND a.date_dim = r.date_dim
),
bal AS (
  SELECT user_id, mtx_day AS d, start_rolls_balance AS bal FROM `dice-dreams-dbt.40_mart.user_daily_mtx_brut_rolls`
  WHERE mtx_day BETWEEN DATE '2026-07-01' AND DATE '2026-09-22'
),
maxd AS (SELECT MAX(date_dim) AS md FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-09-22'),
pre AS (
  SELECT f.album_id, f.user_id, ARRAY_AGG(b.bal ORDER BY b.d DESC LIMIT 1)[SAFE_OFFSET(0)] AS pre_bal
  FROM fin f JOIN bal b ON b.user_id = f.user_id AND b.d BETWEEN DATE_SUB(f.fin_d, INTERVAL 3 DAY) AND DATE_SUB(f.fin_d, INTERVAL 1 DAY)
  GROUP BY 1,2
),
x AS (
  SELECT f.album_id, f.user_id, DATE_DIFF(m.d, f.fin_d, DAY) AS k,
    m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_SUB(f.a_end, INTERVAL 5 DAY) AS in_base, m.rev, m.play, m.ooc
  FROM fin f JOIN m ON m.user_id = f.user_id AND m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_ADD(f.fin_d, INTERVAL 14 DAY)
),
pu AS (
  SELECT album_id, user_id,
    SUM(IF(in_base, rev, 0)) AS b_rev, COUNTIF(in_base AND rev > 0) AS b_pay_days, SUM(IF(in_base, play, 0)) / 14 AS b_play_pd,
    SUM(IF(k BETWEEN 1 AND 7, rev, 0)) AS rev_1_7, SUM(IF(k BETWEEN 1 AND 7, play, 0)) AS play_1_7,
    MIN(IF(k >= 1 AND rev > 0, k, NULL)) AS buy_k,
    COUNTIF(in_base AND ooc) AS b_ooc_days, MIN(IF(k >= 1 AND ooc, k, NULL)) AS ooc_k
  FROM x GROUP BY 1,2
),
pb AS (
  SELECT f.album_id, f.user_id, MIN(IF(DATE_DIFF(b.d, f.fin_d, DAY) >= 1 AND b.bal <= p.pre_bal, DATE_DIFF(b.d, f.fin_d, DAY), NULL)) AS burn_k,
    MAX(IF(DATE_DIFF(b.d, f.fin_d, DAY) = 1, b.bal, NULL)) AS bal1
  FROM fin f JOIN pre p USING (album_id, user_id)
  JOIN bal b ON b.user_id = f.user_id AND b.d BETWEEN DATE_ADD(f.fin_d, INTERVAL 1 DAY) AND DATE_ADD(f.fin_d, INTERVAL 14 DAY)
  GROUP BY 1,2
),
ev AS (
  SELECT f.album_id, f.user_id, f.fin_d, f.alb_rev, f.a_seg, f.r_code, f.r_val,
    p.b_rev, p.b_play_pd, p.rev_1_7, p.play_1_7, p.buy_k, SAFE_DIVIDE(p.b_pay_days, 14) AS p_day, p.ooc_k, SAFE_DIVIDE(p.b_ooc_days, 14) AS q_day,
    pr.pre_bal, pb.burn_k, pb.bal1,
    SAFE_DIVIDE(f.r_val, p.b_play_pd) AS prize_days,
    CASE WHEN p.b_play_pd IS NULL OR p.b_play_pd = 0 THEN 'p0_no_habit_play'
         WHEN f.r_val / p.b_play_pd < 3 THEN 'p1_lt3_days' WHEN f.r_val / p.b_play_pd < 7 THEN 'p2_3_7_days'
         WHEN f.r_val / p.b_play_pd < 14 THEN 'p3_7_14_days' ELSE 'p4_14plus_days' END AS prize_days_bkt
  FROM fin f JOIN pu p USING (album_id, user_id)
  LEFT JOIN pre pr USING (album_id, user_id) LEFT JOIN pb USING (album_id, user_id)
),
sg AS (
  SELECT e.album_id, e.user_id, e.fin_d, e.alb_rev, e.r_val, e.b_rev, e.b_play_pd, e.rev_1_7, e.play_1_7, e.buy_k, e.p_day, e.ooc_k, e.q_day,
    e.pre_bal, e.burn_k, e.bal1, e.prize_days, IFNULL(e.a_seg, 'n/a') AS a_seg, e.r_code, mx.md
  FROM ev e CROSS JOIN maxd mx
)
SELECT g.album_id, g.a_seg, g.r_code,
  COUNT(*) AS n_seg,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 4) AS share_of_payer_finishers,
  ROUND(COUNT(*) / ANY_VALUE(t.pop_all), 5) AS share_of_players,
  ROUND(SUM(g.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS album_rev_share,
  ROUND(APPROX_QUANTILES(g.alb_rev, 2)[OFFSET(1)], 0) AS med_album_rev,
  ROUND(APPROX_QUANTILES(g.b_rev / 14, 2)[OFFSET(1)], 2) AS med_habit_rev_per_day,
  ROUND(APPROX_QUANTILES(g.b_play_pd, 2)[OFFSET(1)], 0) AS med_habit_rolls_out_per_day,
  ROUND(APPROX_QUANTILES(g.prize_days, 2)[OFFSET(1)], 1) AS med_prize_in_habit_days,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(g.bal1, g.pre_bal), 2)[OFFSET(1)], 2) AS med_bal_day1_vs_before,
  ROUND(SAFE_DIVIDE(COUNTIF(g.ooc_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS oor_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.ooc_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS oor_3,
  ROUND(AVG(g.q_day), 3) AS habit_oor_day_rate,
  ROUND(SAFE_DIVIDE(COUNTIF(g.burn_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS burned_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.burn_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS burned_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS bought_3,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md, 1 - POW(1 - g.p_day, 3), NULL)), 3) AS exp_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bought_7,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, 1 - POW(1 - g.p_day, 7), NULL)), 3) AS exp_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.rev_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.b_rev / 2, 0))), 2) AS spend_ratio_1_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.play_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.b_play_pd * 7, 0))), 2) AS play_pace_1_7
FROM sg g JOIN tot t USING (album_id)
GROUP BY 1,2,3
ORDER BY 1,2,3
