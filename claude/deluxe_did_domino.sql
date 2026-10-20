-- Deluxe before vs after launch (Eden 2026-10-19: "what can we say about Deluxe that proves it is good?").
-- Difference-in-differences: early finishers (finish >= 2 days before close, Deluxe has days to run) vs late finishers (close day / day before, Deluxe barely reaches them),
-- albums before Deluxe existed vs after. Domino albums 15, 16 (pre, check has_deluxe_row = 0) vs 17, 19, 20 (post). Album 18 left out (14 sets, 56 days).
-- Population: payer finishers (144 or game flag by end of close day), standard population. Habit = close-18 .. close-5. Day 0 = completion day.
-- Metrics: bought d1-7 vs expected (habit pay-day rate), spend d1-7 vs habit, spend d1-14 vs habit (catches pull-forward into the next album), Deluxe share of d1-7 revenue.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    IFNULL(album_finished_flag,FALSE) AS ff
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-12-01' AND DATE '2026-10-12' AND album_id IN (15,16,17,19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2025-12-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144 OR ff, date_dim, NULL)) AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev, COUNTIF(fin_d IS NOT NULL AND alb_rev > 0) AS n_fin_pay, COUNTIF(alb_rev > 0) AS n_pay FROM pop GROUP BY 1),
fin AS (SELECT album_id, user_id, a_end, fin_d, alb_rev FROM pop WHERE fin_d IS NOT NULL AND alb_rev > 0),
dlx AS (
  SELECT album_id, user_id, date_dim AS d, SUM(IFNULL(deluxe_album_spent_today,0)) AS ev_rev
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_deluxe_album`
  WHERE date_dim BETWEEN DATE '2025-12-01' AND DATE '2026-10-27' AND album_id IN (15,16,17,19,20)
  GROUP BY 1,2,3
),
dlx_u AS (SELECT DISTINCT album_id, user_id FROM dlx),
m AS (
  SELECT user_id, date_dim AS d, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2025-12-01' AND DATE '2026-10-27'
),
maxd AS (SELECT MAX(date_dim) AS md FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-10-01' AND DATE '2026-10-27'),
x AS (
  SELECT f.album_id, f.user_id, DATE_DIFF(m.d, f.fin_d, DAY) AS k,
    m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_SUB(f.a_end, INTERVAL 5 DAY) AS in_base, m.rev, IFNULL(e.ev_rev,0) AS ev_rev
  FROM fin f JOIN m ON m.user_id = f.user_id AND m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_ADD(f.fin_d, INTERVAL 14 DAY)
  LEFT JOIN dlx e ON e.album_id = f.album_id AND e.user_id = f.user_id AND e.d = m.d
),
pu AS (
  SELECT album_id, user_id,
    SUM(IF(in_base, rev, 0)) AS b_rev, COUNTIF(in_base AND rev > 0) AS b_pay_days,
    SUM(IF(k BETWEEN 1 AND 7, rev, 0)) AS rev_1_7, SUM(IF(k BETWEEN 1 AND 14, rev, 0)) AS rev_1_14,
    SUM(IF(k BETWEEN 1 AND 7, ev_rev, 0)) AS ev_1_7,
    MIN(IF(k >= 1 AND rev > 0, k, NULL)) AS buy_k
  FROM x GROUP BY 1,2
),
g AS (
  SELECT f.album_id, f.user_id, f.fin_d, f.alb_rev, p.b_rev, SAFE_DIVIDE(p.b_pay_days, 14) AS p_day, p.rev_1_7, p.rev_1_14, p.ev_1_7, p.buy_k,
    d.user_id IS NOT NULL AS has_dlx,
    IF(DATE_DIFF(f.a_end, f.fin_d, DAY) >= 2, 'a_early_2plus_days', 'b_late_close_or_d-1') AS timing
  FROM fin f JOIN pu p USING (album_id, user_id) LEFT JOIN dlx_u d USING (album_id, user_id)
)
SELECT g.album_id, g.timing,
  COUNT(*) AS n,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 3) AS share_of_payer_finishers,
  ROUND(COUNT(*) / ANY_VALUE(t.n_pay), 4) AS share_of_payers,
  ROUND(SUM(g.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS album_rev_share,
  ROUND(AVG(IF(g.has_dlx, 1, 0)), 3) AS has_deluxe_row,
  ROUND(APPROX_QUANTILES(g.b_rev / 14, 2)[OFFSET(1)], 2) AS med_habit_rev_per_day,
  COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= mx.md) AS n_obs_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md)), 3) AS bought_7,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, 1 - POW(1 - g.p_day, 7), NULL)), 3) AS exp_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, g.rev_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, g.b_rev / 2, 0))), 3) AS spend_ratio_1_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= mx.md, g.rev_1_14, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= mx.md, g.b_rev, 0))), 3) AS spend_ratio_1_14,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, g.ev_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, g.rev_1_7, 0))), 3) AS deluxe_share_rev_1_7
FROM g JOIN tot t USING (album_id) CROSS JOIN maxd mx
GROUP BY 1, 2
ORDER BY 1, 2
