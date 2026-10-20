-- Domino Deluxe eligibility cut-off: finishers just before vs just after the "Deluxe Hour To Album End Eligibility" cut-off (Eden 2026-10-19: "כן תריץ").
-- Albums 17, 19, 20. Payer finishers (144 unique set stickers, by end of close day), standard population (not first album, login ratio >= 0.5 on last row before close, not special, not suspected cheater, album revenue > 0).
-- Finish time = timestamp of the last first-receipt set sticker (common / golden / royal) on or before the close day (int_user_album_stickers).
-- h = hours from finish time to 00:00 UTC of the close date (negative = before). The cut-off value is not documented (ACX parameter), so it is read from the data: the step in Deluxe entry rate.
-- v2 (after Eden shared the Deluxe Economy dashboard): Deluxe from prod_40_mart.user_daily_deluxe_album: has row / deluxe_activity_flag / got a Deluxe sticker / paid in Deluxe.
-- Outcome, day 0 = finish date (calendar): bought d1-7, expected from habit pay-day rate (close-18 .. close-5); spend d0-7 and d1-7 vs habit; Deluxe spend d0-7.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend,
    IFNULL(album_finished_flag,FALSE) AS ff
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-20' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-20' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
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
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev, COUNTIF(fin_d IS NOT NULL AND alb_rev > 0) AS n_fin_pay FROM pop GROUP BY 1),
fin AS (SELECT album_id, user_id, a_end, fin_d, alb_rev FROM pop WHERE fin_d IS NOT NULL AND alb_rev > 0),
fts AS (
  SELECT f.album_id, f.user_id, MAX(s.sticker_collected_min_ts) AS fin_ts
  FROM fin f JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-03-20' AND DATE '2026-10-12' AND s.album_id IN (17,19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= f.a_end
  GROUP BY 1,2
),
dlx AS (
  SELECT album_id, user_id, LOGICAL_OR(IFNULL(deluxe_activity_flag,FALSE)) AS act,
    SUM(IFNULL(deluxe_album_stickers_today,0)) > 0 AS stk, SUM(IFNULL(deluxe_album_spent_today,0)) > 0 AS paid
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_deluxe_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-27' AND album_id IN (17,19,20)
  GROUP BY 1,2
),
evd AS (
  SELECT album_id, user_id, date_dim AS d, SUM(IFNULL(deluxe_album_spent_today,0)) AS ev_rev
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_deluxe_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-27' AND album_id IN (17,19,20)
  GROUP BY 1,2,3
),
m AS (
  SELECT user_id, date_dim AS d, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-10-27'
),
maxd AS (SELECT MAX(date_dim) AS md FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-10-01' AND DATE '2026-10-27'),
x AS (
  SELECT f.album_id, f.user_id, DATE_DIFF(m.d, f.fin_d, DAY) AS k,
    m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_SUB(f.a_end, INTERVAL 5 DAY) AS in_base, m.rev, IFNULL(e.ev_rev,0) AS ev_rev
  FROM fin f JOIN m ON m.user_id = f.user_id AND m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_ADD(f.fin_d, INTERVAL 7 DAY)
  LEFT JOIN evd e ON e.album_id = f.album_id AND e.user_id = f.user_id AND e.d = m.d
),
pu AS (
  SELECT album_id, user_id,
    SUM(IF(in_base, rev, 0)) AS b_rev, COUNTIF(in_base AND rev > 0) AS b_pay_days,
    SUM(IF(k BETWEEN 0 AND 7, rev, 0)) AS rev_0_7, SUM(IF(k BETWEEN 1 AND 7, rev, 0)) AS rev_1_7,
    SUM(IF(k BETWEEN 0 AND 7, ev_rev, 0)) AS ev_0_7,
    MIN(IF(k >= 1 AND rev > 0, k, NULL)) AS buy_k
  FROM x GROUP BY 1,2
),
g AS (
  SELECT f.album_id, f.user_id, f.fin_d, f.alb_rev, p.b_rev, SAFE_DIVIDE(p.b_pay_days, 14) AS p_day, p.rev_0_7, p.rev_1_7, p.ev_0_7, p.buy_k,
    d.user_id IS NOT NULL AS entered, IFNULL(d.act,FALSE) AS act, IFNULL(d.stk,FALSE) AS stk, IFNULL(d.paid,FALSE) AS dpaid,
    TIMESTAMP_DIFF(t.fin_ts, TIMESTAMP(f.a_end), MINUTE) / 60 AS h
  FROM fin f JOIN pu p USING (album_id, user_id) JOIN fts t USING (album_id, user_id)
  LEFT JOIN dlx d USING (album_id, user_id)
)
SELECT g.album_id,
  CAST(FLOOR(g.h / 6) * 6 AS INT64) AS h_bucket_6h,
  COUNT(*) AS n,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 4) AS share_of_payer_finishers,
  ROUND(SUM(g.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS album_rev_share,
  ROUND(AVG(IF(g.entered, 1, 0)), 3) AS has_deluxe_row, ROUND(AVG(IF(g.act, 1, 0)), 3) AS deluxe_active, ROUND(AVG(IF(g.stk, 1, 0)), 3) AS got_deluxe_sticker, ROUND(AVG(IF(g.dpaid, 1, 0)), 3) AS paid_in_deluxe,
  ROUND(APPROX_QUANTILES(g.b_rev / 14, 2)[OFFSET(1)], 2) AS med_habit_rev_per_day,
  COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md) AS n_obs_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md)), 3) AS bought_7,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, 1 - POW(1 - g.p_day, 7), NULL)), 3) AS exp_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, g.rev_0_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, g.b_rev * 8 / 14, 0))), 2) AS spend_ratio_0_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, g.rev_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, g.b_rev / 2, 0))), 2) AS spend_ratio_1_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, g.ev_0_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= mx.md, g.rev_0_7, 0))), 3) AS deluxe_share_of_rev_0_7
FROM g JOIN tot t USING (album_id) CROSS JOIN maxd mx
WHERE g.h >= -72 AND g.h < 24
GROUP BY 1, 2
ORDER BY 1, 2
