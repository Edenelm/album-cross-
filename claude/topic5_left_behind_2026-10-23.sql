-- Topic 5 reruns (Eden 2026-10-23: "run all three"): those left behind, on the fixed populations.
-- Population: standard population payers (not first album, not excluded, login ratio >= 0.5 on the last row before close,
--   row on close-1, paid on any album day incl. close). Albums Dice 61/63, Domino 19/20, Disney 14/15.
-- End status = unique set stickers on close-1 (Dice daily table does not update stickers on close day): finished / 1 / 2-3 / 4+ missing.
-- Heavy near-missers = 2-3 missing on close-1 AND album revenue before close / album days >= $20 a day.
-- Album revenue = album-table spend, album start .. close-1. Share of revenue = of all standard-population payers' album revenue.
-- A (keep playing): last 14 days = close-14 .. close-1: share of days active, $ per player, share who paid.
-- C (give up): play and spend per player-day, last 7 days (close-7..close-1) vs the 14 days before (close-21..close-8);
--   share of days active in each window. Play = Dice rolls out; Domino coins spent (allowance units); Disney levels played (all modes).
-- Finishers: days after their own finish day are left out (Eden rule).

-- ===== DISNEY 14/15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, IFNULL(active_flag,FALSE) AS act
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-12' AND exclude_reason IS NOT NULL),
days AS (SELECT album_id, user_id, date_dim, act, spend FROM ud WHERE date_dim < a_end),
play AS (SELECT user_id, date_dim AS d,
    IFNULL(levels_played_mode_1,0) + IFNULL(levels_played_mode_2,0) + IFNULL(levels_played_mode_3,0) + IFNULL(levels_played_mode_4,0) AS play
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05'),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev, ANY_VALUE(DATE_DIFF(a.a_end, a.a_start, DAY)) AS n_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MIN(IF(a.uniq >= 144 AND a.date_dim < a.a_end, a.date_dim, NULL)) AS fin_d,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
pop AS (
  SELECT album_id, user_id, a_start, a_end, alb_rev, n_days, uniq_end, fin_d,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end = 143 THEN 'b_miss1' WHEN uniq_end >= 141 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp,
    uniq_end BETWEEN 141 AND 142 AND SAFE_DIVIDE(alb_rev, n_days) >= 20 AS heavy
  FROM u WHERE ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM pop GROUP BY 1),
x AS (
  SELECT p.album_id, p.user_id, p.grp, p.heavy, DATE_DIFF(p.a_end, d.date_dim, DAY) AS dbc, d.act, d.spend, IFNULL(pl.play, 0) AS play
  FROM pop p JOIN days d ON d.user_id = p.user_id AND d.album_id = p.album_id
  LEFT JOIN play pl ON pl.user_id = p.user_id AND pl.d = d.date_dim
  WHERE DATE_DIFF(p.a_end, d.date_dim, DAY) BETWEEN 1 AND 21 AND (p.fin_d IS NULL OR d.date_dim <= p.fin_d)),
pu AS (
  SELECT album_id, user_id, grp, heavy,
    COUNTIF(dbc <= 14) AS d14, COUNTIF(dbc <= 14 AND act) AS a14, SUM(IF(dbc <= 14, spend, 0)) AS s14,
    COUNTIF(dbc <= 7) AS d7, COUNTIF(dbc <= 7 AND act) AS a7, SUM(IF(dbc <= 7, spend, 0)) AS s7, SUM(IF(dbc <= 7, play, 0)) AS p7,
    COUNTIF(dbc >= 8) AS d8, COUNTIF(dbc >= 8 AND act) AS a8, SUM(IF(dbc >= 8, spend, 0)) AS s8, SUM(IF(dbc >= 8, play, 0)) AS p8
  FROM x GROUP BY 1,2,3,4),
g AS (
  SELECT p.album_id, IF(gg = 'heavy', 'h_heavy_2_3', p.grp) AS grp, p.user_id, p.alb_rev
  FROM pop p, UNNEST(IF(p.heavy, ['base','heavy'], ['base'])) gg)
SELECT g.album_id, g.grp, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(t.n_all), 4) AS share_payers,
  ROUND(SUM(g.alb_rev)) AS album_rev, ROUND(SUM(g.alb_rev) / ANY_VALUE(t.rev_all), 4) AS share_rev,
  ROUND(SAFE_DIVIDE(SUM(q.a14), SUM(q.d14)), 3) AS active_share_last14,
  ROUND(AVG(q.s14), 2) AS usd_pp_last14, ROUND(AVG(IF(q.s14 > 0, 1, 0)), 3) AS paid_share_last14,
  ROUND(SAFE_DIVIDE(SUM(q.a8), SUM(q.d8)), 3) AS active_share_d21_8, ROUND(SAFE_DIVIDE(SUM(q.a7), SUM(q.d7)), 3) AS active_share_d7_1,
  ROUND(SAFE_DIVIDE(SUM(q.s8), SUM(q.d8)), 2) AS usd_per_day_d21_8, ROUND(SAFE_DIVIDE(SUM(q.s7), SUM(q.d7)), 2) AS usd_per_day_d7_1,
  ROUND(SAFE_DIVIDE(SUM(q.p8), SUM(q.a8)), 1) AS play_per_active_day_d21_8, ROUND(SAFE_DIVIDE(SUM(q.p7), SUM(q.a7)), 1) AS play_per_active_day_d7_1
FROM g JOIN tot t USING (album_id) LEFT JOIN pu q ON q.album_id = g.album_id AND q.user_id = g.user_id AND q.grp = IF(g.grp = 'h_heavy_2_3', 'c_miss2_3', g.grp)
GROUP BY 1,2 ORDER BY 1,2;

-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    IFNULL(login_ratio,-1) AS lr, IFNULL(user_album_count,1) AS uac, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS spend, IFNULL(active_flag,FALSE) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date),
bad AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
days AS (SELECT album_id, user_id, date_dim, act, spend FROM ud WHERE date_dim < a_end),
play AS (SELECT user_id, date_dim AS d, IFNULL(spent_in_allowance,0) AS play
  FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_spent` WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12'),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev, ANY_VALUE(DATE_DIFF(a.a_end, a.a_start, DAY)) AS n_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MIN(IF(a.uniq >= 144 AND a.date_dim < a.a_end, a.date_dim, NULL)) AS fin_d,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.uac, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] > 1
      AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AND MAX(b.user_id) IS NULL AS ok
  FROM ud a LEFT JOIN bad b ON b.user_id = a.user_id GROUP BY 1,2),
pop AS (
  SELECT album_id, user_id, a_start, a_end, alb_rev, n_days, uniq_end, fin_d,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end = 143 THEN 'b_miss1' WHEN uniq_end >= 141 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp,
    uniq_end BETWEEN 141 AND 142 AND SAFE_DIVIDE(alb_rev, n_days) >= 20 AS heavy
  FROM u WHERE ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM pop GROUP BY 1),
x AS (
  SELECT p.album_id, p.user_id, p.grp, p.heavy, DATE_DIFF(p.a_end, d.date_dim, DAY) AS dbc, d.act, d.spend, IFNULL(pl.play, 0) AS play
  FROM pop p JOIN days d ON d.user_id = p.user_id AND d.album_id = p.album_id
  LEFT JOIN play pl ON pl.user_id = p.user_id AND pl.d = d.date_dim
  WHERE DATE_DIFF(p.a_end, d.date_dim, DAY) BETWEEN 1 AND 21 AND (p.fin_d IS NULL OR d.date_dim <= p.fin_d)),
pu AS (
  SELECT album_id, user_id, grp, heavy,
    COUNTIF(dbc <= 14) AS d14, COUNTIF(dbc <= 14 AND act) AS a14, SUM(IF(dbc <= 14, spend, 0)) AS s14,
    COUNTIF(dbc <= 7) AS d7, COUNTIF(dbc <= 7 AND act) AS a7, SUM(IF(dbc <= 7, spend, 0)) AS s7, SUM(IF(dbc <= 7, play, 0)) AS p7,
    COUNTIF(dbc >= 8) AS d8, COUNTIF(dbc >= 8 AND act) AS a8, SUM(IF(dbc >= 8, spend, 0)) AS s8, SUM(IF(dbc >= 8, play, 0)) AS p8
  FROM x GROUP BY 1,2,3,4),
g AS (
  SELECT p.album_id, IF(gg = 'heavy', 'h_heavy_2_3', p.grp) AS grp, p.user_id, p.alb_rev
  FROM pop p, UNNEST(IF(p.heavy, ['base','heavy'], ['base'])) gg)
SELECT g.album_id, g.grp, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(t.n_all), 4) AS share_payers,
  ROUND(SUM(g.alb_rev)) AS album_rev, ROUND(SUM(g.alb_rev) / ANY_VALUE(t.rev_all), 4) AS share_rev,
  ROUND(SAFE_DIVIDE(SUM(q.a14), SUM(q.d14)), 3) AS active_share_last14,
  ROUND(AVG(q.s14), 2) AS usd_pp_last14, ROUND(AVG(IF(q.s14 > 0, 1, 0)), 3) AS paid_share_last14,
  ROUND(SAFE_DIVIDE(SUM(q.a8), SUM(q.d8)), 3) AS active_share_d21_8, ROUND(SAFE_DIVIDE(SUM(q.a7), SUM(q.d7)), 3) AS active_share_d7_1,
  ROUND(SAFE_DIVIDE(SUM(q.s8), SUM(q.d8)), 2) AS usd_per_day_d21_8, ROUND(SAFE_DIVIDE(SUM(q.s7), SUM(q.d7)), 2) AS usd_per_day_d7_1,
  ROUND(SAFE_DIVIDE(SUM(q.p8), SUM(q.a8)), 1) AS play_per_active_day_d21_8, ROUND(SAFE_DIVIDE(SUM(q.p7), SUM(q.a7)), 1) AS play_per_active_day_d7_1
FROM g JOIN tot t USING (album_id) LEFT JOIN pu q ON q.album_id = g.album_id AND q.user_id = g.user_id AND q.grp = IF(g.grp = 'h_heavy_2_3', 'c_miss2_3', g.grp)
GROUP BY 1,2 ORDER BY 1,2;

-- ===== DICE 61/63 (dice-dreams-dbt) =====
-- Not first album = a row in an earlier album of user_daily_album (history from 2023-11-01). Excluded = is_excluded.
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_stickers_lt,0) AS uniq,
    IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend, IFNULL(is_active,FALSE) AS act
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date),
days AS (SELECT album_id, user_id, date_dim, act, spend FROM ud WHERE date_dim < a_end),
play AS (SELECT user_id, date_dim AS d, IFNULL(rolls_out_sum,0) AS play
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out` WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07'),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev, ANY_VALUE(DATE_DIFF(a.a_end, a.a_start, DAY)) AS n_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.uniq, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS uniq_end,
    MIN(IF(a.uniq >= 144 AND a.date_dim < a.a_end, a.date_dim, NULL)) AS fin_d,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0 AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2),
pop AS (
  SELECT album_id, user_id, a_start, a_end, alb_rev, n_days, uniq_end, fin_d,
    CASE WHEN uniq_end >= 144 THEN 'a_finished' WHEN uniq_end = 143 THEN 'b_miss1' WHEN uniq_end >= 141 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp,
    uniq_end BETWEEN 141 AND 142 AND SAFE_DIVIDE(alb_rev, n_days) >= 20 AS heavy
  FROM u WHERE ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM pop GROUP BY 1),
x AS (
  SELECT p.album_id, p.user_id, p.grp, p.heavy, DATE_DIFF(p.a_end, d.date_dim, DAY) AS dbc, d.act, d.spend, IFNULL(pl.play, 0) AS play
  FROM pop p JOIN days d ON d.user_id = p.user_id AND d.album_id = p.album_id
  LEFT JOIN play pl ON pl.user_id = p.user_id AND pl.d = d.date_dim
  WHERE DATE_DIFF(p.a_end, d.date_dim, DAY) BETWEEN 1 AND 21 AND (p.fin_d IS NULL OR d.date_dim <= p.fin_d)),
pu AS (
  SELECT album_id, user_id, grp, heavy,
    COUNTIF(dbc <= 14) AS d14, COUNTIF(dbc <= 14 AND act) AS a14, SUM(IF(dbc <= 14, spend, 0)) AS s14,
    COUNTIF(dbc <= 7) AS d7, COUNTIF(dbc <= 7 AND act) AS a7, SUM(IF(dbc <= 7, spend, 0)) AS s7, SUM(IF(dbc <= 7, play, 0)) AS p7,
    COUNTIF(dbc >= 8) AS d8, COUNTIF(dbc >= 8 AND act) AS a8, SUM(IF(dbc >= 8, spend, 0)) AS s8, SUM(IF(dbc >= 8, play, 0)) AS p8
  FROM x GROUP BY 1,2,3,4),
g AS (
  SELECT p.album_id, IF(gg = 'heavy', 'h_heavy_2_3', p.grp) AS grp, p.user_id, p.alb_rev
  FROM pop p, UNNEST(IF(p.heavy, ['base','heavy'], ['base'])) gg)
SELECT g.album_id, g.grp, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(t.n_all), 4) AS share_payers,
  ROUND(SUM(g.alb_rev)) AS album_rev, ROUND(SUM(g.alb_rev) / ANY_VALUE(t.rev_all), 4) AS share_rev,
  ROUND(SAFE_DIVIDE(SUM(q.a14), SUM(q.d14)), 3) AS active_share_last14,
  ROUND(AVG(q.s14), 2) AS usd_pp_last14, ROUND(AVG(IF(q.s14 > 0, 1, 0)), 3) AS paid_share_last14,
  ROUND(SAFE_DIVIDE(SUM(q.a8), SUM(q.d8)), 3) AS active_share_d21_8, ROUND(SAFE_DIVIDE(SUM(q.a7), SUM(q.d7)), 3) AS active_share_d7_1,
  ROUND(SAFE_DIVIDE(SUM(q.s8), SUM(q.d8)), 2) AS usd_per_day_d21_8, ROUND(SAFE_DIVIDE(SUM(q.s7), SUM(q.d7)), 2) AS usd_per_day_d7_1,
  ROUND(SAFE_DIVIDE(SUM(q.p8), SUM(q.a8)), 1) AS play_per_active_day_d21_8, ROUND(SAFE_DIVIDE(SUM(q.p7), SUM(q.a7)), 1) AS play_per_active_day_d7_1
FROM g JOIN tot t USING (album_id) LEFT JOIN pu q ON q.album_id = g.album_id AND q.user_id = g.user_id AND q.grp = IF(g.grp = 'h_heavy_2_3', 'c_miss2_3', g.grp)
GROUP BY 1,2 ORDER BY 1,2;
