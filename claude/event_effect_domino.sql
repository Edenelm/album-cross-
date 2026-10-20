-- Do the post-album events make finishers come back to buying faster? DOMINO albums 19, 20. Payer finishers (144 or game flag, by end of close day), standard population.
-- Event = Deluxe album (prod_40_mart.user_daily_deluxe_album; joined = deluxe_activity_flag or Deluxe spend on days 0-7). Event spend per day from deluxe_album_spent_today. Revenue = all purchases (same as recovery queries).
-- Habit = close-18 .. close-5. Day 0 = completion day. Expected = 1-(1-p)^k from the player's habit pay-day rate.
-- "Excluding event" = a purchase day counts only if non-event revenue that day > $0.01; spend ratio uses revenue minus event spend.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    IFNULL(album_finished_flag,FALSE) AS ff
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
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
tot AS (SELECT album_id, COUNT(*) AS pop_all, SUM(alb_rev) AS pop_rev, COUNTIF(fin_d IS NOT NULL AND alb_rev > 0) AS n_fin_pay FROM pop GROUP BY 1),
fin AS (SELECT album_id, user_id, a_end, fin_d, alb_rev FROM pop WHERE fin_d IS NOT NULL AND alb_rev > 0),
m AS (
  SELECT a.user_id, a.date_dim AS d,
    IFNULL(a.user_daily_inapp_purchase_amount,0) + IFNULL(a.user_daily_stripe_amount,0) AS rev, IFNULL(c.spent_in_allowance,0) AS play
  FROM (SELECT user_id, date_dim, user_daily_inapp_purchase_amount, user_daily_stripe_amount FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
        WHERE date_dim BETWEEN DATE '2026-08-01' AND DATE '2026-10-27') a
  LEFT JOIN (SELECT user_id, date_dim, spent_in_allowance FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_spent`
        WHERE date_dim BETWEEN DATE '2026-08-01' AND DATE '2026-10-27') c
  ON a.user_id = c.user_id AND a.date_dim = c.date_dim
),
evd AS (
  SELECT album_id, user_id, date_dim AS d, SUM(IFNULL(deluxe_album_spent_today,0)) AS ev_rev, LOGICAL_OR(IFNULL(deluxe_activity_flag,FALSE)) AS ev_act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_deluxe_album`
  WHERE date_dim BETWEEN DATE '2026-08-01' AND DATE '2026-10-27' AND album_id IN (19,20)
  GROUP BY 1,2,3
),
maxd AS (SELECT MAX(date_dim) AS md FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-10-01' AND DATE '2026-10-27'),
x AS (
  SELECT f.album_id, f.user_id, DATE_DIFF(m.d, f.fin_d, DAY) AS k,
    m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_SUB(f.a_end, INTERVAL 5 DAY) AS in_base,
    m.rev, m.play, IFNULL(e.ev_rev, 0) AS ev_rev, IFNULL(e.ev_act, FALSE) AS ev_act
  FROM fin f JOIN m ON m.user_id = f.user_id AND m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_ADD(f.fin_d, INTERVAL 14 DAY)
  LEFT JOIN evd e ON e.album_id = f.album_id AND e.user_id = f.user_id AND e.d = m.d
),
pu AS (
  SELECT album_id, user_id,
    SUM(IF(in_base, rev, 0)) AS b_rev, COUNTIF(in_base AND rev > 0) AS b_pay_days, SUM(IF(in_base, play, 0)) / 14 AS b_play_pd,
    SUM(IF(k BETWEEN 1 AND 7, rev, 0)) AS rev_1_7, SUM(IF(k BETWEEN 1 AND 7, ev_rev, 0)) AS ev_1_7, SUM(IF(k BETWEEN 0 AND 7, ev_rev, 0)) AS ev_0_7,
    SUM(IF(k BETWEEN 1 AND 7, play, 0)) AS play_1_7,
    MIN(IF(k >= 1 AND rev > 0, k, NULL)) AS buy_k,
    MIN(IF(k >= 1 AND rev - ev_rev > 0.01, k, NULL)) AS buy_ne_k,
    LOGICAL_OR(k BETWEEN 0 AND 7 AND (ev_act OR ev_rev > 0)) AS joined
  FROM x GROUP BY 1,2
),
ev AS (
  SELECT f.album_id, f.user_id, f.fin_d, f.alb_rev, p.b_rev, p.b_play_pd, p.rev_1_7, p.ev_1_7, p.ev_0_7, p.play_1_7, p.buy_k, p.buy_ne_k,
    SAFE_DIVIDE(p.b_pay_days, 14) AS p_day, IFNULL(p.joined, FALSE) AS joined,
    CASE DATE_DIFF(f.fin_d, f.a_end, DAY) WHEN 0 THEN 'a_close_day' WHEN -1 THEN 'b_d-1' WHEN -2 THEN 'c_d-2_3' WHEN -3 THEN 'c_d-2_3' ELSE 'd_d-4plus' END AS timing
  FROM fin f JOIN pu p USING (album_id, user_id)
),
sg AS (
  SELECT e.album_id, e.user_id, e.fin_d, e.alb_rev, e.b_rev, e.b_play_pd, e.rev_1_7, e.ev_1_7, e.ev_0_7, e.play_1_7, e.buy_k, e.buy_ne_k, e.p_day,
    s.seg_type, s.seg, mx.md
  FROM ev e
  CROSS JOIN UNNEST([STRUCT('all' AS seg_type, 'all' AS seg),
                     STRUCT('joined', IF(e.joined, 'joined', 'not_joined')),
                     STRUCT('timing_x_joined', CONCAT(e.timing, '_', IF(e.joined, 'joined', 'not_joined')))]) s
  CROSS JOIN maxd mx
)
SELECT g.album_id, g.seg_type, g.seg,
  COUNT(*) AS n_seg,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 4) AS share_of_payer_finishers,
  ROUND(SUM(g.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS album_rev_share,
  COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md) AS n_obs_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bought_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_ne_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bought_7_excl_event,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, 1 - POW(1 - g.p_day, 7), NULL)), 3) AS exp_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.rev_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.b_rev / 2, 0))), 2) AS spend_ratio_1_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.rev_1_7 - g.ev_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.b_rev / 2, 0))), 2) AS spend_ratio_1_7_excl_event,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.ev_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.rev_1_7, 0))), 3) AS event_share_of_rev_1_7,
  ROUND(SAFE_DIVIDE(SUM(g.ev_0_7), ANY_VALUE(t.pop_rev)), 4) AS event_spend_d0_7_pct_album_rev,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.play_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.b_play_pd * 7, 0))), 2) AS play_pace_1_7
FROM sg g JOIN tot t USING (album_id)
GROUP BY 1,2,3
ORDER BY 1,2,3
