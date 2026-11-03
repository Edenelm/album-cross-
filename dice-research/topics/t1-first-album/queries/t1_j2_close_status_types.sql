-- Topic 1 / J2: status at album close (by entry group) + distribution of the first-7-days experience. Project dice-dreams-dbt. First albums 57-65.
-- Population and groups as t1_j1_daily_journey.sql (T1, T2, L14 split by days left). First album only (no next-album rows here).
-- Status at close: last row before close (close-day stickers are not updated in the Dice daily table): new stickers, missing = 144 - new,
--   sets completed; finish = user_album_finish_date <= close date; album rolls received entry..close; roll balance on the last active day
--   before close; active in the last 3 days before close (game activity); revenue from entry to close-1; first purchase day since entry.
-- First-7-days experience (days 0-6 since entry, all albums' rows so a late joiner's next album counts too): new stickers, sets, album rolls.
-- Revenue share = player's game revenue on album days start..close-1 / all game revenue on those days (excluded removed), pooled over 5 albums.
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 67),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
ad AS (
  SELECT u.user_id, u.album_id, u.date_dim, IFNULL(u.unique_stickers_today, 0) AS new_s, IFNULL(u.unique_stickers_lt, 0) AS uniq_lt,
    IFNULL(u.sets_completed_today, 0) AS sets, IFNULL(u.sets_completed_lt, 0) AS sets_lt, u.user_album_finish_date AS fin, IFNULL(u.is_excluded, FALSE) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND u.album_id BETWEEN 57 AND 67),
p AS (
  SELECT ad.user_id, ad.album_id, MIN(ad.date_dim) AS entry, LOGICAL_OR(ad.ex) AS ex,
    MAX(IF(ad.date_dim < a.a_end, ad.uniq_lt, 0)) AS uniq_c1, MAX(IF(ad.date_dim < a.a_end, ad.sets_lt, 0)) AS sets_c1,
    LOGICAL_OR(ad.fin <= a.a_end) AS fin
  FROM ad JOIN alb a USING (album_id) WHERE ad.album_id BETWEEN 57 AND 65 AND ad.date_dim <= a.a_end GROUP BY 1, 2),
pp AS (
  SELECT p.*, a.a_start, a.a_end,
    CASE WHEN p.entry >= DATE_SUB(a.a_end, INTERVAL 14 DAY) THEN
           CASE WHEN DATE_DIFF(a.a_end, p.entry, DAY) <= 2 THEN 'L14_0_2' WHEN DATE_DIFF(a.a_end, p.entry, DAY) <= 6 THEN 'L14_3_6'
                WHEN DATE_DIFF(a.a_end, p.entry, DAY) <= 10 THEN 'L14_7_10' ELSE 'L14_11_14' END
         WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 1/3 THEN 'T1'
         WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 2/3 THEN 'T2' ELSE 'T3' END AS grp
  FROM p JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p.album_id AND NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl)),
w7 AS (
  SELECT pp.user_id, pp.album_id, SUM(ad.new_s) AS new7, SUM(ad.sets) AS sets7
  FROM pp JOIN ad ON ad.user_id = pp.user_id AND ad.date_dim BETWEEN pp.entry AND DATE_ADD(pp.entry, INTERVAL 6 DAY)
  GROUP BY 1, 2),
gm AS (
  SELECT pp.user_id, pp.album_id,
    SUM(IF(m.date_dim BETWEEN pp.a_start AND DATE_SUB(pp.a_end, INTERVAL 1 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev_album,
    SUM(IF(m.date_dim BETWEEN pp.entry AND DATE_SUB(pp.a_end, INTERVAL 1 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev_entry,
    COUNTIF(m.date_dim BETWEEN pp.entry AND DATE_SUB(pp.a_end, INTERVAL 1 DAY)) AS act_days,
    COUNTIF(m.date_dim BETWEEN DATE_SUB(pp.a_end, INTERVAL 3 DAY) AND DATE_SUB(pp.a_end, INTERVAL 1 DAY)) > 0 AS act_last3,
    MIN(IF(IFNULL(m.revenues_sum, 0) > 0 AND m.date_dim >= pp.entry, m.date_dim, NULL)) AS first_pay,
    COUNTIF(IFNULL(m.revenues_sum, 0) > 0 AND m.date_dim BETWEEN pp.entry AND DATE_SUB(pp.a_end, INTERVAL 1 DAY)) AS pay_days,
    ARRAY_AGG(IF(m.date_dim BETWEEN pp.entry AND DATE_SUB(pp.a_end, INTERVAL 1 DAY), m.rolls_enday, NULL) IGNORE NULLS ORDER BY m.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_close,
    SUM(IF(m.date_dim BETWEEN pp.entry AND DATE_ADD(pp.entry, INTERVAL 6 DAY), 1, 0)) AS act7,
    SUM(IF(m.date_dim BETWEEN pp.entry AND DATE_ADD(pp.entry, INTERVAL 6 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev7
  FROM pp JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = pp.user_id AND m.date_dim BETWEEN pp.a_start AND DATE_ADD(pp.a_end, INTERVAL 7 DAY)
  WHERE m.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-26'
  GROUP BY 1, 2),
rb AS (
  SELECT pp.user_id, pp.album_id,
    SUM(IF(s.roll_type = 'rolls_in' AND s.source_rolls_group = 'album' AND s.date_dim <= pp.a_end, s.rolls_value_sum, 0)) AS ralb_close,
    SUM(IF(s.roll_type = 'rolls_in' AND s.date_dim <= pp.a_end, s.rolls_value_sum, 0)) AS rin_close,
    SUM(IF(s.roll_type = 'rolls_out' AND s.date_dim <= pp.a_end, s.rolls_value_sum, 0)) AS rout_close,
    SUM(IF(s.roll_type = 'rolls_in' AND s.source_rolls_group = 'album' AND s.date_dim <= DATE_ADD(pp.entry, INTERVAL 6 DAY), s.rolls_value_sum, 0)) AS ralb7,
    SUM(IF(s.roll_type = 'rolls_in' AND s.date_dim <= DATE_ADD(pp.entry, INTERVAL 6 DAY), s.rolls_value_sum, 0)) AS rin7
  FROM pp JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
    ON s.user_id = pp.user_id AND s.date_dim BETWEEN pp.entry AND GREATEST(pp.a_end, DATE_ADD(pp.entry, INTERVAL 6 DAY))
  WHERE s.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-26'
  GROUP BY 1, 2),
tot AS (
  SELECT SUM(IFNULL(g.revenues_sum, 0)) AS game_rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` g JOIN alb a ON g.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE g.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND a.album_id BETWEEN 57 AND 65 AND g.user_id NOT IN (SELECT user_id FROM excl)),
t AS (
  SELECT pp.grp, CASE WHEN pp.grp LIKE 'L14%' THEN 'L14' ELSE pp.grp END AS grp2, DATE_DIFF(pp.a_end, pp.entry, DAY) AS days_left,
    pp.uniq_c1, pp.sets_c1, IFNULL(pp.fin, FALSE) AS fin, IFNULL(w.new7, 0) AS new7, IFNULL(w.sets7, 0) AS sets7,
    IFNULL(g.rev_album, 0) AS rev_album, IFNULL(g.rev_entry, 0) AS rev_entry, IFNULL(g.act_days, 0) AS act_days, IFNULL(g.act_last3, FALSE) AS act_last3,
    DATE_DIFF(g.first_pay, pp.entry, DAY) AS first_pay_day, IFNULL(g.pay_days, 0) AS pay_days, g.bal_close, IFNULL(g.act7, 0) AS act7, IFNULL(g.rev7, 0) AS rev7,
    IFNULL(r.ralb_close, 0) AS ralb_close, IFNULL(r.rin_close, 0) AS rin_close, IFNULL(r.rout_close, 0) AS rout_close,
    IFNULL(r.ralb7, 0) AS ralb7, IFNULL(r.rin7, 0) AS rin7
  FROM pp LEFT JOIN w7 w USING (user_id, album_id) LEFT JOIN gm g USING (user_id, album_id) LEFT JOIN rb r USING (user_id, album_id))
SELECT 'close_status' AS part, grp AS k1, '' AS k2, COUNT(*) AS players, ROUND(SUM(rev_album) / ANY_VALUE(tot.game_rev), 4) AS share_game_rev,
  ROUND(AVG(days_left), 1) AS days_left, ROUND(AVG(act_days), 1) AS act_days,
  APPROX_QUANTILES(uniq_c1, 4) AS q_stickers_close, ROUND(AVG(144 - uniq_c1), 1) AS avg_missing, ROUND(AVG(sets_c1), 2) AS avg_sets_close,
  ROUND(AVG(IF(sets_c1 >= 1, 1, 0)), 3) AS share_1plus_set, COUNTIF(fin) AS finishers,
  ROUND(AVG(IF(ralb_close > 0, 1, 0)), 3) AS share_album_rolls, APPROX_QUANTILES(ralb_close, 10)[OFFSET(9)] AS p90_album_rolls,
  ROUND(SAFE_DIVIDE(SUM(ralb_close), SUM(rin_close)), 4) AS album_share_of_rolls_in,
  APPROX_QUANTILES(rin_close, 2)[OFFSET(1)] AS med_rolls_in, APPROX_QUANTILES(rout_close, 2)[OFFSET(1)] AS med_rolls_out,
  APPROX_QUANTILES(bal_close, 2)[OFFSET(1)] AS med_balance_close, ROUND(AVG(IF(act_last3, 1, 0)), 3) AS active_last3,
  COUNTIF(rev_entry > 0) AS payers_from_entry, ROUND(AVG(rev_entry), 2) AS rev_entry_per_player,
  APPROX_QUANTILES(first_pay_day, 2)[OFFSET(1)] AS med_first_pay_day, ROUND(AVG(IF(rev_entry > 0, pay_days, NULL)), 2) AS pay_days_per_payer
FROM t, tot GROUP BY 1, 2, 3
UNION ALL
SELECT 'dist_sets7', grp2, CAST(LEAST(sets7, 6) AS STRING), COUNT(*), ROUND(SUM(rev_album) / ANY_VALUE(tot.game_rev), 4),
  ROUND(AVG(days_left), 1), ROUND(AVG(act7), 2), APPROX_QUANTILES(new7, 4), NULL, ROUND(AVG(sets7), 2), NULL, COUNTIF(fin),
  ROUND(AVG(IF(ralb7 > 0, 1, 0)), 3), APPROX_QUANTILES(ralb7, 10)[OFFSET(9)], ROUND(SAFE_DIVIDE(SUM(ralb7), SUM(rin7)), 4),
  APPROX_QUANTILES(rin7, 2)[OFFSET(1)], APPROX_QUANTILES(ralb7, 2)[OFFSET(1)], NULL, NULL,
  COUNTIF(rev7 > 0), ROUND(AVG(rev7), 2), NULL, NULL
FROM t, tot WHERE grp2 IN ('T1', 'L14') GROUP BY 1, 2, 3
UNION ALL
SELECT 'dist_new7', grp2,
  CASE WHEN new7 < 10 THEN 'a_0_9' WHEN new7 < 20 THEN 'b_10_19' WHEN new7 < 40 THEN 'c_20_39' WHEN new7 < 60 THEN 'd_40_59' WHEN new7 < 80 THEN 'e_60_79' ELSE 'f_80plus' END,
  COUNT(*), ROUND(SUM(rev_album) / ANY_VALUE(tot.game_rev), 4), ROUND(AVG(days_left), 1), ROUND(AVG(act7), 2), APPROX_QUANTILES(new7, 4), NULL,
  ROUND(AVG(sets7), 2), NULL, COUNTIF(fin), ROUND(AVG(IF(ralb7 > 0, 1, 0)), 3), APPROX_QUANTILES(ralb7, 10)[OFFSET(9)],
  ROUND(SAFE_DIVIDE(SUM(ralb7), SUM(rin7)), 4), APPROX_QUANTILES(rin7, 2)[OFFSET(1)], APPROX_QUANTILES(ralb7, 2)[OFFSET(1)], NULL, NULL,
  COUNTIF(rev7 > 0), ROUND(AVG(rev7), 2), NULL, NULL
FROM t, tot WHERE grp2 IN ('T1', 'L14') GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;
