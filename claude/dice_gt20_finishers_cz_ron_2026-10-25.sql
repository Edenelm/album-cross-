-- 2026-10-25 (Eden): Dice finishers over $20 a day drop 15-19% in the week after close vs their normal week (albums 59, 63; not 61).
-- Quick check: what changes for them in the week after? comfort_ron / comfort_zone (smart segments, start of day), purchases, bets, out-of-rolls.
-- Population = topic6_normal_week_check_2026-10-24.sql (Dice part): standard population, status on close-1, spend level from album days 0-20.
-- Groups: finishers (144 on close-1) and 1-2 short, level >$20 a day. Windows: normal week = album days 21-27; week after = close+1..+7.
-- Metrics from dice-dreams-dbt.50_reporting.user_daily_metrics_agg, average per player first, then across players; days without a row count as 0 spend.
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) BETWEEN 0 AND 20, a.spend, 0)) AS s_a,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
pop AS (
  SELECT album_id, user_id, a_start, a_end, s_a / 21 AS pace,
    IF(uniq_end >= 144, 'a_finished', 'b_1_2') AS status
  FROM u WHERE ok AND s_a / 21 > 20 AND uniq_end >= 142),
m AS (
  SELECT user_id, date_dim, comfort_ron_start_day AS ron, comfort_zone_start_day AS cz, IFNULL(revenues_sum,0) AS rev, IFNULL(trx_cnt,0) AS trx,
    p50_bet_mult AS bet, IFNULL(out_of_rolls_cnt,0) AS oor, IFNULL(rolls_out_sum,0) AS rolls_out
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-05-25' AND DATE '2026-09-14'),
w AS (
  SELECT p.album_id, p.status, p.user_id, p.pace,
    IF(m.date_dim BETWEEN DATE_ADD(p.a_start, INTERVAL 21 DAY) AND DATE_ADD(p.a_start, INTERVAL 27 DAY), '1_normal', '2_after') AS win,
    m.ron, m.cz, m.rev, m.trx, m.bet, m.oor, m.rolls_out
  FROM pop p JOIN m ON m.user_id = p.user_id
  WHERE m.date_dim BETWEEN DATE_ADD(p.a_start, INTERVAL 21 DAY) AND DATE_ADD(p.a_start, INTERVAL 27 DAY)
     OR m.date_dim BETWEEN DATE_ADD(p.a_end, INTERVAL 1 DAY) AND DATE_ADD(p.a_end, INTERVAL 7 DAY)),
pu AS (
  SELECT album_id, status, user_id, win, ANY_VALUE(pace) AS pace, COUNT(*) AS act_days, AVG(ron) AS ron, AVG(cz) AS cz,
    SUM(rev) AS rev, SUM(trx) AS trx, AVG(bet) AS bet, SUM(oor) AS oor, SUM(rolls_out) AS rolls_out
  FROM w GROUP BY 1,2,3,4)
SELECT album_id AS a, status AS s, win, COUNT(*) AS players_active,
  ROUND(AVG(act_days), 2) AS act_days, ROUND(AVG(ron), 2) AS ron_avg, ROUND(APPROX_QUANTILES(ron, 2)[OFFSET(1)], 2) AS ron_med,
  ROUND(AVG(cz), 2) AS cz_avg, ROUND(APPROX_QUANTILES(cz, 2)[OFFSET(1)], 2) AS cz_med,
  ROUND(SUM(rev) / SUM(7 * pace), 3) AS rev_vs_pace, ROUND(AVG(IF(trx > 0, 1, 0)), 3) AS buyers,
  ROUND(SAFE_DIVIDE(SUM(trx), COUNTIF(trx > 0)), 2) AS trx_per_buyer, ROUND(SAFE_DIVIDE(SUM(rev), SUM(trx)), 2) AS usd_per_trx,
  ROUND(AVG(bet), 1) AS bet_p50, ROUND(AVG(oor), 2) AS oor_per_player, ROUND(AVG(rolls_out)) AS rolls_out_per_player
FROM pu GROUP BY 1,2,3 ORDER BY 1,2,3
