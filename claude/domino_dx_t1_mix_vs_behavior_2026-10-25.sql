-- 2026-10-25 Domino diagnosis, topic 1: album 19 vs 20 - player mix vs behaviour within levels fixed BEFORE the album.
-- Population: standard population, ALL players (payers and non-payers): not first album, not special / suspected cheater,
--   login ratio >= 0.5 on last row before close, row on close-1.
-- Level = $ a day in the PREVIOUS album (album_id - 1; spend start..close-1 / rows start..close-1): no_prev / 0 / <=2 / 2-5 / 5-20 / >20.
-- Metrics (album start..close-1 unless said): players; payers (paid any album day incl. close day); revenue (album_spent_today);
--   active days (active_flag, close day excluded); purchases (core_purchase distinct orders, total_usd_amount > 0, start..close-1);
--   finished (144 by end of close day); end lift = $ per active day last 4 full days (close-4..close-1) / $ per active day before.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end, album_open_date AS a_start,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, IFNULL(active_flag,FALSE) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-12' AND album_id IN (18,19,20) AND date_dim <= album_close_date
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-10-12' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, ANY_VALUE(a_start) AS a_start, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev, SUM(spend) AS rev_incl_close,
    COUNTIF(date_dim < a_end) AS rows_n,
    COUNTIF(act AND date_dim < a_end) AS act_days,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 4 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY), spend, 0)) AS rev_end,
    COUNTIF(act AND date_dim BETWEEN DATE_SUB(a_end, INTERVAL 4 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS act_end,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
u2 AS (SELECT album_id, user_id, a_end, uniq_end, rev, rev_incl_close, rows_n, act_days, rev_end, act_end, last_d,
  l.lr AS lr, l.past AS past, l.excl AS excl FROM u),
prev AS (SELECT album_id + 1 AS album_id, user_id, SAFE_DIVIDE(rev, rows_n) AS pd_prev FROM u2 WHERE album_id IN (18,19)),
pop AS (
  SELECT u.album_id, u.user_id, u.a_end, u.rev, u.rev_incl_close > 0 AS payer, u.act_days, u.rev_end, u.act_end, u.uniq_end >= 144 AS fin,
    CASE WHEN p.user_id IS NULL THEN '0_no_prev' WHEN IFNULL(p.pd_prev,0) = 0 THEN '1_zero' WHEN p.pd_prev <= 2 THEN '2_le2'
      WHEN p.pd_prev <= 5 THEN '3_2-5' WHEN p.pd_prev <= 20 THEN '4_5-20' ELSE '5_20+' END AS lvl
  FROM u2 u LEFT JOIN prev p USING (album_id, user_id)
  WHERE u.album_id IN (19,20) AND u.last_d = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad)
),
pur AS (
  SELECT c.user_id, IF(c.date_dim < DATE '2026-08-24', 19, 20) AS album_id, COUNT(DISTINCT c.external_order_id) AS n_pur
  FROM `domino-dreams-dbt.prod_20_core.core_purchase` c
  WHERE c.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND c.date_dim != DATE '2026-08-24' AND IFNULL(c.total_usd_amount,0) > 0
  GROUP BY 1,2
)
SELECT p.album_id, p.lvl, COUNT(*) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY p.album_id), 4) AS sh_players,
  ROUND(SUM(p.rev), 0) AS rev,
  ROUND(SUM(p.rev) / SUM(SUM(p.rev)) OVER (PARTITION BY p.album_id), 4) AS sh_rev,
  ROUND(COUNTIF(p.payer) / COUNT(*), 4) AS pu_rate,
  ROUND(SUM(p.rev) / COUNT(*), 2) AS rev_per_player,
  ROUND(SUM(p.rev) / SUM(p.act_days), 3) AS arpdau,
  ROUND(SUM(IFNULL(q.n_pur,0)) / SUM(p.act_days), 4) AS purch_per_act_day,
  ROUND(SAFE_DIVIDE(SUM(p.rev), SUM(IFNULL(q.n_pur,0))), 2) AS usd_per_purchase,
  ROUND(SUM(p.act_days) / COUNT(*), 1) AS act_days_per_player,
  ROUND(COUNTIF(p.fin) / COUNT(*), 4) AS fin_rate_all,
  ROUND(SAFE_DIVIDE(COUNTIF(p.fin AND p.payer), COUNTIF(p.payer)), 4) AS fin_rate_payers,
  ROUND(SAFE_DIVIDE(SUM(p.rev_end) / NULLIF(SUM(p.act_end),0), (SUM(p.rev) - SUM(p.rev_end)) / NULLIF(SUM(p.act_days) - SUM(p.act_end),0)), 3) AS end_lift
FROM pop p LEFT JOIN pur q USING (album_id, user_id)
GROUP BY 1,2 ORDER BY 1,2

;
-- Trend check: same query for 18 vs 19 (levels from 17 / 18). Album 18 = 56 days, 14 sets: compare per-day and per-player rates only, not finish.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end, album_open_date AS a_start,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, IFNULL(active_flag,FALSE) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-24' AND album_id IN (17,18,19) AND date_dim <= album_close_date
),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-08-24' AND (IFNULL(suspected_cheater_flag,FALSE) OR IFNULL(special_user_flag,FALSE))),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, ANY_VALUE(a_start) AS a_start, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev, SUM(spend) AS rev_incl_close,
    COUNTIF(date_dim < a_end) AS rows_n,
    COUNTIF(act AND date_dim < a_end) AS act_days,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 4 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY), spend, 0)) AS rev_end,
    COUNTIF(act AND date_dim BETWEEN DATE_SUB(a_end, INTERVAL 4 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS act_end,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud GROUP BY 1,2
),
u2 AS (SELECT album_id, user_id, a_end, uniq_end, rev, rev_incl_close, rows_n, act_days, rev_end, act_end, last_d,
  l.lr AS lr, l.past AS past, l.excl AS excl FROM u),
prev AS (SELECT album_id + 1 AS album_id, user_id, SAFE_DIVIDE(rev, rows_n) AS pd_prev FROM u2 WHERE album_id IN (17,18)),
pop AS (
  SELECT u.album_id, u.user_id, u.a_end, u.rev, u.rev_incl_close > 0 AS payer, u.act_days, u.rev_end, u.act_end, u.uniq_end >= 144 AS fin,
    CASE WHEN p.user_id IS NULL THEN '0_no_prev' WHEN IFNULL(p.pd_prev,0) = 0 THEN '1_zero' WHEN p.pd_prev <= 2 THEN '2_le2'
      WHEN p.pd_prev <= 5 THEN '3_2-5' WHEN p.pd_prev <= 20 THEN '4_5-20' ELSE '5_20+' END AS lvl
  FROM u2 u LEFT JOIN prev p USING (album_id, user_id)
  WHERE u.album_id IN (18,19) AND u.last_d = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad)
),
pur AS (
  SELECT c.user_id, IF(c.date_dim < DATE '2026-07-06', 18, 19) AS album_id, COUNT(DISTINCT c.external_order_id) AS n_pur
  FROM `domino-dreams-dbt.prod_20_core.core_purchase` c
  WHERE c.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-23' AND c.date_dim != DATE '2026-07-06' AND IFNULL(c.total_usd_amount,0) > 0
  GROUP BY 1,2
)
SELECT p.album_id, p.lvl, COUNT(*) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY p.album_id), 4) AS sh_players,
  ROUND(SUM(p.rev), 0) AS rev,
  ROUND(SUM(p.rev) / SUM(SUM(p.rev)) OVER (PARTITION BY p.album_id), 4) AS sh_rev,
  ROUND(COUNTIF(p.payer) / COUNT(*), 4) AS pu_rate,
  ROUND(SUM(p.rev) / COUNT(*), 2) AS rev_per_player,
  ROUND(SUM(p.rev) / SUM(p.act_days), 3) AS arpdau,
  ROUND(SUM(IFNULL(q.n_pur,0)) / SUM(p.act_days), 4) AS purch_per_act_day,
  ROUND(SAFE_DIVIDE(SUM(p.rev), SUM(IFNULL(q.n_pur,0))), 2) AS usd_per_purchase,
  ROUND(SUM(p.act_days) / COUNT(*), 1) AS act_days_per_player,
  ROUND(COUNTIF(p.fin) / COUNT(*), 4) AS fin_rate_all,
  ROUND(SAFE_DIVIDE(COUNTIF(p.fin AND p.payer), COUNTIF(p.payer)), 4) AS fin_rate_payers,
  ROUND(SAFE_DIVIDE(SUM(p.rev_end) / NULLIF(SUM(p.act_end),0), (SUM(p.rev) - SUM(p.rev_end)) / NULLIF(SUM(p.act_days) - SUM(p.act_end),0)), 3) AS end_lift
FROM pop p LEFT JOIN pur q USING (album_id, user_id)
GROUP BY 1,2 ORDER BY 1,2
