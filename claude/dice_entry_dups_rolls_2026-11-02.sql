-- Dice (Eden 2026-11-02): five checks. Albums 59 (05-04..06-22, 49 days), 61 (06-22..07-27, 35 days), 63 (07-27..09-07, 42 days). Project dice-dreams-dbt.
-- Q1 first album + entry third (new / returning / continuing), Q2 duplicates and set exhaustion, Q3 rolls in the last days before finishing + prize.
-- Results: claude/dice-entry-dups-rolls-2026-11-02.md

-- ===== Q1: entry third x player type =====
-- Population: every non-excluded player with a row in the album (= at least 1 sticker). No login or close-1 filter, so players who join and leave stay in.
-- Entry day = user_album_start_date. Third = (entry day - album start + 1) / album days: T1 <= 1/3, T2 <= 2/3, T3 rest.
-- Type: new = no row in any earlier album since 2023-11 (floor: a player whose last album was before that looks new);
--   returning = a row in an earlier album but not in the previous album (id - 2) = came back after at least one album away;
--   continuing = a row in the previous album.
-- Album revenue = album-table spend start..close-1. Payer = spend on any album day incl. close. Finisher = 144 set stickers by end of close day (sticker table).
-- Next album = row in album id + 2; next revenue = its album revenue (start..close-1).
WITH hist AS (
  SELECT user_id, album_id FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-10-19' GROUP BY 1, 2),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, album_number_of_days AS n_days,
    user_album_start_date AS u_start, IFNULL(is_excluded, FALSE) AS excl, IFNULL(spent_in_album_today, 0) AS spend,
    IFNULL(is_active, FALSE) AS act, IFNULL(unique_stickers_lt, 0) AS uniq
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-10-19' AND album_id IN (59, 61, 63, 65) AND date_dim <= album_end_date),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, ANY_VALUE(n_days) AS n_days, MIN(u_start) AS u_start,
    LOGICAL_OR(excl) AS excl, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) > 0 AS payer,
    COUNTIF(act AND date_dim < a_end) AS act_days, MAX(IF(date_dim < a_end, uniq, NULL)) AS uniq_c1
  FROM ud GROUP BY 1, 2),
fin AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) >= 144 AS fin
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  JOIN (SELECT DISTINCT album_id, a_end FROM u WHERE album_id IN (59, 61, 63)) e ON e.album_id = s.album_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-04' AND DATE '2026-09-07' AND s.album_id IN (59, 61, 63)
    AND s.is_sticker_collected AND s.sticker_type IN ('common', 'golden', 'super') AND s.sticker_collected_date <= e.a_end
  GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.payer, u.act_days, u.uniq_c1, IFNULL(f.fin, FALSE) AS fin,
    DATE_DIFF(u.a_end, u.u_start, DAY) AS days_left,
    CASE WHEN (DATE_DIFF(u.u_start, u.a_start, DAY) + 1) / u.n_days <= 1/3 THEN 'T1' WHEN (DATE_DIFF(u.u_start, u.a_start, DAY) + 1) / u.n_days <= 2/3 THEN 'T2' ELSE 'T3' END AS third,
    CASE WHEN fs.first_seen >= u.album_id THEN 'a_new' WHEN pv.user_id IS NOT NULL THEN 'c_continuing' ELSE 'b_returning' END AS ptype,
    n.user_id IS NOT NULL AS in_next, IFNULL(n.alb_rev, 0) AS next_rev, IFNULL(n.payer, FALSE) AS next_payer
  FROM u LEFT JOIN fin f USING (album_id, user_id)
  JOIN (SELECT user_id, MIN(album_id) AS first_seen FROM hist GROUP BY 1) fs ON fs.user_id = u.user_id
  LEFT JOIN hist pv ON pv.user_id = u.user_id AND pv.album_id = u.album_id - 2
  LEFT JOIN u n ON n.user_id = u.user_id AND n.album_id = u.album_id + 2 AND NOT n.excl
  WHERE u.album_id IN (59, 61, 63) AND NOT u.excl),
tot AS (SELECT album_id, COUNT(*) AS n_all, COUNTIF(payer) AS pay_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1)
SELECT t.album_id, ptype, third, COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_players,
  COUNTIF(payer) AS payers, ROUND(COUNTIF(payer) / ANY_VALUE(pay_all), 4) AS share_payers,
  ROUND(SUM(alb_rev)) AS alb_rev, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(AVG(days_left), 1) AS avg_days_left, ROUND(AVG(act_days), 1) AS avg_act_days,
  ROUND(SAFE_DIVIDE(SUM(alb_rev), SUM(act_days)), 2) AS rev_per_act_day,
  ROUND(SAFE_DIVIDE(SUM(uniq_c1), SUM(act_days)), 2) AS new_stickers_per_act_day,
  ROUND(APPROX_QUANTILES(uniq_c1, 2)[OFFSET(1)]) AS med_stickers_c1,
  COUNTIF(fin) AS finishers, COUNTIF(fin AND payer) AS payer_finishers,
  COUNTIF(in_next) AS in_next, COUNTIF(in_next AND payer) AS payers_in_next, COUNTIF(next_payer AND payer) AS payers_pay_next,
  ROUND(SUM(next_rev)) AS next_rev
FROM t JOIN tot USING (album_id) GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;

-- Q1b check (album 63): players who joined in the last third and still finished — entry day, first-sticker day, days to 144, album $, top sticker sources.
-- Result: 1,171 finishers; entry day 31/33/36 (quartiles of 42); 144 reached in 5/7/10 days; album $ 65/122/213; top sources new kingdom 21%, Progress Bar 14%, Trail chest 8%.

-- ===== Q2: duplicates per active day =====
-- Population: non-excluded players, album days before close (close day not updated in the Dice daily table), days with stickers received.
-- Stickers = total_stickers_today (incl. duplicates); new = unique_stickers_today; duplicate share = 1 - new / total.
-- Band = unique set stickers at the START of the day (unique_stickers_lt - unique_stickers_today). Tenth = tenth of album days. Payer = total_spent_in_album > 0.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end, album_number_of_days AS n_days, day_in_album,
    IFNULL(total_stickers_today, 0) AS tot, IFNULL(unique_stickers_today, 0) AS uni, IFNULL(unique_stickers_lt, 0) AS ult,
    IFNULL(is_excluded, FALSE) AS excl, IFNULL(total_spent_in_album, 0) > 0 AS payer
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-09-06' AND album_id IN (59, 61, 63) AND date_dim < album_end_date),
d AS (
  SELECT album_id, payer, LEAST(CAST(FLOOR(10 * (day_in_album - 1) / n_days) AS INT64) + 1, 10) AS tenth,
    CASE WHEN ult - uni < 50 THEN 'b1_0_49' WHEN ult - uni < 100 THEN 'b2_50_99' WHEN ult - uni < 120 THEN 'b3_100_119'
         WHEN ult - uni < 135 THEN 'b4_120_134' WHEN ult - uni < 141 THEN 'b5_135_140' ELSE 'b6_141_143' END AS band,
    tot, uni
  FROM ud WHERE NOT excl AND tot > 0 AND ult - uni < 144)
SELECT 'tenth' AS dim, album_id, payer, CAST(tenth AS STRING) AS grp, COUNT(*) AS player_days, SUM(tot) AS stickers, SUM(uni) AS new_stickers,
  ROUND(SUM(tot) / COUNT(*), 2) AS stickers_per_day, ROUND(SUM(uni) / COUNT(*), 2) AS new_per_day, ROUND(1 - SUM(uni) / SUM(tot), 3) AS dup_share
FROM d GROUP BY 1, 2, 3, 4
UNION ALL
SELECT 'band', album_id, payer, band, COUNT(*), SUM(tot), SUM(uni), ROUND(SUM(tot) / COUNT(*), 2), ROUND(SUM(uni) / COUNT(*), 2), ROUND(1 - SUM(uni) / SUM(tot), 3)
FROM d GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3, 4;

-- ===== Q3: rolls in the last days before finishing + the final prize =====
-- Population: standard population (fixed first-album rule; not excluded; login ratio >= 0.5 on the last row before close; row on close-1), finishers only
--   (144 set stickers by end of close day, sticker table). Finish day = day of the 144th sticker. Early = finish day <= close-4; late = after.
-- Window = the 4 days before the finish day + the finish day (5 calendar days; daily data, so the finish day counts in full, also after the 144th sticker).
-- Rolls out = rolls_out_sum (30_intermediate.user_daily_rolls_in_out; includes bet multiplier). Own pace = rolls out per playing day before the window.
-- Window vs pace = window rolls / 5 / pace (group totals). Rolls bought = rolls_amount_from_purchase. $ in window = album-table spend on those days.
-- Prize = album_reward_value (rolls) on the last row before close. Spend level = album $ a day in the first 75% of the album.
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    IFNULL(album_login_ratio, -1) AS lr, IFNULL(is_excluded, FALSE) AS excl, IFNULL(spent_in_album_today, 0) AS spend,
    album_reward_code AS r_code, album_reward_value AS r_val
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-09-07' AND album_id IN (59, 61, 63) AND date_dim <= album_end_date),
u AS (
  SELECT a.album_id, a.user_id, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end,
    SUM(IF(a.date_dim < a.a_end, a.spend, 0)) AS alb_rev,
    SUM(IF(DATE_DIFF(a.date_dim, a.a_start, DAY) <= CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64) - 1, a.spend, 0)) AS so_far,
    ANY_VALUE(CAST(CEIL(0.75 * DATE_DIFF(a.a_end, a.a_start, DAY)) AS INT64)) AS q_days,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.r_code, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS r_code,
    ARRAY_AGG(IF(a.date_dim < a.a_end, a.r_val, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS r_val,
    MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
      AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
      AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AS ok
  FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1, 2),
pop AS (
  SELECT album_id, user_id, a_start, a_end, alb_rev, r_code, r_val,
    CASE WHEN so_far <= 0 THEN 't0_0' WHEN so_far / q_days <= 2 THEN 't1_le2' WHEN so_far / q_days <= 5 THEN 't2_2_5'
         WHEN so_far / q_days <= 20 THEN 't3_5_20' ELSE 't4_gt20' END AS tier
  FROM u WHERE ok),
tot AS (SELECT album_id, COUNT(*) AS n_all, COUNTIF(alb_rev > 0) AS pay_all, SUM(alb_rev) AS rev_all FROM pop GROUP BY 1),
st AS (
  SELECT p.album_id, p.user_id, s.sticker_id, s.sticker_collected_date AS d
  FROM pop p JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = p.album_id AND s.user_id = p.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-04' AND DATE '2026-09-07' AND s.album_id IN (59, 61, 63)
    AND s.is_sticker_collected AND s.sticker_type IN ('common', 'golden', 'super') AND s.sticker_collected_date <= p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.album_id, p.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
fin AS (
  SELECT album_id, user_id, (ARRAY_AGG(d ORDER BY d))[SAFE_OFFSET(143)] AS fin_d FROM st GROUP BY 1, 2 HAVING COUNT(*) >= 144),
f AS (SELECT p.*, fin.fin_d, IF(fin.fin_d <= DATE_SUB(p.a_end, INTERVAL 4 DAY), 'a_early', 'b_late') AS timing FROM pop p JOIN fin USING (album_id, user_id)),
r AS (
  SELECT f.album_id, f.user_id,
    SUM(IF(x.date_dim BETWEEN DATE_SUB(f.fin_d, INTERVAL 4 DAY) AND f.fin_d, IFNULL(x.rolls_out_sum, 0), 0)) AS out_w,
    SUM(IF(x.date_dim BETWEEN DATE_SUB(f.fin_d, INTERVAL 4 DAY) AND f.fin_d, IFNULL(x.rolls_amount_from_purchase, 0), 0)) AS bought_w,
    SUM(IF(x.date_dim BETWEEN DATE_SUB(f.fin_d, INTERVAL 4 DAY) AND f.fin_d, IFNULL(x.rolls_in_sum, 0), 0)) AS in_w,
    COUNTIF(x.date_dim BETWEEN DATE_SUB(f.fin_d, INTERVAL 4 DAY) AND f.fin_d AND IFNULL(x.out_of_rolls_count, 0) > 0) AS ooc_days_w,
    SUM(IF(x.date_dim < DATE_SUB(f.fin_d, INTERVAL 4 DAY), IFNULL(x.rolls_out_sum, 0), 0)) AS out_before,
    COUNTIF(x.date_dim < DATE_SUB(f.fin_d, INTERVAL 4 DAY) AND IFNULL(x.rolls_out_sum, 0) > 0) AS days_before
  FROM f JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out` x ON x.user_id = f.user_id AND x.date_dim BETWEEN f.a_start AND f.fin_d
  WHERE x.date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-09-07'
  GROUP BY 1, 2),
sp AS (
  SELECT f.album_id, f.user_id, SUM(IFNULL(a.spent_in_album_today, 0)) AS spend_w
  FROM f JOIN `dice-dreams-dbt.50_reporting.user_daily_album` a ON a.user_id = f.user_id AND a.album_id = f.album_id
    AND a.date_dim BETWEEN DATE_SUB(f.fin_d, INTERVAL 4 DAY) AND f.fin_d
  WHERE a.date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-09-07' GROUP BY 1, 2),
j AS (
  SELECT f.album_id, f.tier, f.timing, f.alb_rev, f.r_val, r.out_w, r.bought_w, r.in_w, r.ooc_days_w, IFNULL(sp.spend_w, 0) AS spend_w,
    SAFE_DIVIDE(r.out_before, r.days_before) AS pace
  FROM f JOIN r USING (album_id, user_id) LEFT JOIN sp USING (album_id, user_id))
SELECT j.album_id, tier, timing, COUNT(*) AS finishers, ROUND(COUNT(*) / ANY_VALUE(pay_all), 4) AS share_of_payers,
  ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(APPROX_QUANTILES(out_w, 2)[OFFSET(1)]) AS med_rolls_out_w, ROUND(AVG(out_w)) AS avg_rolls_out_w,
  ROUND(APPROX_QUANTILES(pace, 2)[OFFSET(1)]) AS med_pace_per_day,
  ROUND(SAFE_DIVIDE(SUM(out_w) / 5, SUM(pace)), 2) AS window_vs_pace,
  ROUND(AVG(bought_w)) AS avg_rolls_bought_w, ROUND(SAFE_DIVIDE(SUM(bought_w), SUM(out_w)), 3) AS bought_share_of_out,
  ROUND(AVG(IF(ooc_days_w > 0, 1, 0)), 3) AS ran_out_in_window,
  ROUND(AVG(spend_w), 1) AS avg_spend_w, ROUND(APPROX_QUANTILES(spend_w, 2)[OFFSET(1)], 1) AS med_spend_w,
  ROUND(AVG(r_val)) AS avg_prize, ROUND(APPROX_QUANTILES(SAFE_DIVIDE(r_val, out_w), 2)[OFFSET(1)], 2) AS med_prize_vs_window_rolls,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(r_val, pace), 2)[OFFSET(1)], 1) AS med_prize_days_of_pace
FROM j JOIN tot USING (album_id) GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;

-- ===== Q4 (2026-11-03): where new players who start in the first third stop, vs veterans (continuing) who start in the first third =====
-- Stopped = no active day in the album's last 7 days (is_active = game activity, so stopping the album = stopping the game). Stop day = days from own entry to last active day.
-- Early spend level = $ in the first 7 days from own entry (0 / <=10 / 10-50 / >50), fixed before most stops. Shares = of first-third entrants (all types) in the album.
-- stop_dist = paying stoppers only, 3 albums pooled. Results: claude/dice-entry-dups-rolls-2026-11-02.md §6; CSVs dice_new_stop_summary / dice_new_stop_dist_2026-11-03.csv
WITH hist AS (
  SELECT user_id, album_id FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' GROUP BY 1, 2),
ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, album_number_of_days AS n_days,
    user_album_start_date AS u_start, IFNULL(is_excluded, FALSE) AS excl, IFNULL(spent_in_album_today, 0) AS spend,
    IFNULL(is_active, FALSE) AS act, IFNULL(unique_stickers_lt, 0) AS uniq, IFNULL(unique_stickers_today, 0) AS uni_d,
    kingdom_id_end_day AS kd
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-09-07' AND album_id IN (59, 61, 63) AND date_dim < album_end_date),
ar AS (
  SELECT ud.*, ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY date_dim DESC) AS rk_desc
  FROM ud WHERE act),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, ANY_VALUE(n_days) AS n_days, MIN(u_start) AS u_start,
    LOGICAL_OR(excl) AS excl, SUM(spend) AS alb_rev,
    SUM(IF(date_dim < DATE_ADD(u_start, INTERVAL 7 DAY), spend, 0)) AS spend7,
    MAX(uniq) AS uniq_c1
  FROM ud GROUP BY 1, 2),
a AS (
  SELECT album_id, user_id, COUNT(*) AS act_days, MAX(date_dim) AS last_act,
    MAX(IF(rk_desc = 1, uniq, NULL)) AS uniq_stop, MAX(IF(rk_desc = 1, kd, NULL)) AS kd_stop,
    SUM(IF(rk_desc <= 3, uni_d, 0)) AS new_last3, COUNTIF(rk_desc <= 3) AS n_last3,
    SUM(IF(DATE_DIFF(date_dim, u_start, DAY) < 3, uni_d, 0)) AS new_first3, COUNTIF(DATE_DIFF(date_dim, u_start, DAY) < 3) AS n_first3
  FROM ar GROUP BY 1, 2),
t AS (
  SELECT u.album_id, u.user_id, u.alb_rev, u.uniq_c1, IFNULL(a.act_days, 0) AS act_days, a.uniq_stop, a.kd_stop, a.new_last3, a.n_last3, a.new_first3, a.n_first3,
    DATE_DIFF(a.last_act, u.u_start, DAY) + 1 AS stop_day,
    a.last_act IS NULL OR a.last_act < DATE_SUB(u.a_end, INTERVAL 7 DAY) AS stopped,
    CASE WHEN fs.first_seen >= u.album_id THEN 'a_new' WHEN pv.user_id IS NOT NULL THEN 'c_continuing' ELSE 'b_returning' END AS ptype,
    CASE WHEN u.spend7 <= 0 THEN 's0' WHEN u.spend7 <= 10 THEN 's1_le10' WHEN u.spend7 <= 50 THEN 's2_10_50' ELSE 's3_gt50' END AS sp7
  FROM u LEFT JOIN a USING (album_id, user_id)
  JOIN (SELECT user_id, MIN(album_id) AS first_seen FROM hist GROUP BY 1) fs ON fs.user_id = u.user_id
  LEFT JOIN hist pv ON pv.user_id = u.user_id AND pv.album_id = u.album_id - 2
  WHERE NOT u.excl AND (DATE_DIFF(u.u_start, u.a_start, DAY) + 1) / u.n_days <= 1/3),
tot AS (SELECT album_id, COUNT(*) AS n_all, SUM(alb_rev) AS rev_all FROM t GROUP BY 1)
SELECT 'summary' AS dim, t.album_id, ptype, sp7 AS grp, CAST(NULL AS STRING) AS grp2, COUNT(*) AS players,
  ROUND(COUNT(*) / ANY_VALUE(n_all), 4) AS share_players, ROUND(SUM(alb_rev) / ANY_VALUE(rev_all), 4) AS share_rev,
  ROUND(AVG(IF(stopped, 1, 0)), 3) AS stopped_share,
  APPROX_QUANTILES(IF(stopped, stop_day, NULL), 4)[OFFSET(2)] AS med_stop_day,
  APPROX_QUANTILES(IF(stopped, uniq_stop, NULL), 4)[OFFSET(2)] AS med_stickers_at_stop,
  APPROX_QUANTILES(IF(stopped, kd_stop, NULL), 4)[OFFSET(2)] AS med_kingdom_at_stop,
  ROUND(SAFE_DIVIDE(SUM(IF(stopped, new_first3, 0)), SUM(IF(stopped, n_first3, 0))), 2) AS stoppers_new_per_day_first3,
  ROUND(SAFE_DIVIDE(SUM(IF(stopped, new_last3, 0)), SUM(IF(stopped, n_last3, 0))), 2) AS stoppers_new_per_day_last3,
  ROUND(SAFE_DIVIDE(SUM(IF(NOT stopped, new_first3, 0)), SUM(IF(NOT stopped, n_first3, 0))), 2) AS stayers_new_per_day_first3,
  ROUND(SUM(IF(stopped, alb_rev, 0)) / ANY_VALUE(rev_all), 4) AS stoppers_share_rev
FROM t JOIN tot USING (album_id) WHERE ptype != 'b_returning' GROUP BY 1, 2, 3, 4, 5
UNION ALL
SELECT 'stop_dist', 0, ptype,
  CASE WHEN stop_day IS NULL OR stop_day <= 3 THEN 'd1_3' WHEN stop_day <= 7 THEN 'd4_7' WHEN stop_day <= 14 THEN 'd8_14' WHEN stop_day <= 21 THEN 'd15_21' ELSE 'd22p' END,
  CASE WHEN IFNULL(uniq_stop, 0) < 25 THEN 'u0_24' WHEN uniq_stop < 50 THEN 'u25_49' WHEN uniq_stop < 75 THEN 'u50_74' WHEN uniq_stop < 100 THEN 'u75_99' ELSE 'u100p' END,
  COUNT(*), NULL, ROUND(SUM(alb_rev)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM t WHERE stopped AND ptype IN ('a_new', 'c_continuing') AND alb_rev > 0 GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2, 3, 4, 5
;
