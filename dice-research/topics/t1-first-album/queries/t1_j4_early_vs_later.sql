-- Topic 1 / J4: first-7-days experience -> later outcome, within activity and early-payer strata; profiles of players active around days 7/14/30.
-- Project dice-dreams-dbt. First albums 57-65; groups T1 (first third) and L14 (last 14 days). Same population rules as t1_j1.
-- Early experience (days 0-6 since entry, album rows of any album): type7 = a_barely (< 20 new stickers) / b_collector (20+ new, 0 sets)
--   / c_steady (1-3 sets) / d_rapid (4+ sets). Thresholds chosen from the J2 distribution (2026-11-03).
-- Strata fixed in the same window: act7 = game active days 0-6 (1-2 / 3-4 / 5-7); payer7 = revenue > 0 on days 0-6.
-- Later outcomes (measured after the early window): active on any of days 14-27 and active days 14-27; revenue and payer on days 7-29;
--   active on any of days 28-34. Each outcome uses only players whose window is complete by 2026-11-02 (n_14_27, n_7_29, n_28_34).
-- For T1 these later windows fall inside the first album (35 days left on average); for L14 they fall after the next album starts.
-- Fix 2026-11-03: early windows (act7, rev7, rev14, rev30, act14, act30) start at entry; the first run counted days from album start.
-- Survivor profiles: players active on any of days 6-8 / 13-15 / 27-29 (follow-up complete), with their cumulative journey up to day 7 / 14 / 29.
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 67),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
ad AS (
  SELECT u.user_id, u.album_id, u.date_dim, IFNULL(u.unique_stickers_today, 0) AS new_s, IFNULL(u.sets_completed_today, 0) AS sets,
    IFNULL(u.is_excluded, FALSE) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND u.album_id BETWEEN 57 AND 67),
p AS (
  SELECT ad.user_id, ad.album_id, MIN(ad.date_dim) AS entry, LOGICAL_OR(ad.ex) AS ex
  FROM ad JOIN alb a USING (album_id) WHERE ad.album_id BETWEEN 57 AND 65 AND ad.date_dim <= a.a_end GROUP BY 1, 2),
pp AS (
  SELECT p.user_id, p.album_id, p.entry, a.a_start, a.a_end,
    CASE WHEN p.entry >= DATE_SUB(a.a_end, INTERVAL 14 DAY) THEN 'L14' WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 1/3 THEN 'T1' ELSE 'other' END AS grp
  FROM p JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p.album_id AND NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl)),
b AS (SELECT * FROM pp WHERE grp <> 'other'),
al AS (
  SELECT b.user_id, b.album_id,
    SUM(IF(ad.date_dim <= DATE_ADD(b.entry, INTERVAL 6 DAY), ad.new_s, 0)) AS new7, SUM(IF(ad.date_dim <= DATE_ADD(b.entry, INTERVAL 6 DAY), ad.sets, 0)) AS sets7,
    SUM(IF(ad.date_dim <= DATE_ADD(b.entry, INTERVAL 13 DAY), ad.new_s, 0)) AS new14, SUM(IF(ad.date_dim <= DATE_ADD(b.entry, INTERVAL 13 DAY), ad.sets, 0)) AS sets14,
    SUM(ad.new_s) AS new30, SUM(ad.sets) AS sets30,
    MIN(IF(ad.album_id = b.album_id + 2, ad.date_dim, NULL)) AS next_entry
  FROM b JOIN ad ON ad.user_id = b.user_id AND ad.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 29 DAY)
  GROUP BY 1, 2),
gm AS (
  SELECT b.user_id, b.album_id,
    COUNTIF(m.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 6 DAY)) AS act7,
    SUM(IF(m.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 6 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev7,
    SUM(IF(m.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 13 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev14,
    SUM(IF(m.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 29 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev30,
    COUNTIF(m.date_dim BETWEEN DATE_ADD(b.entry, INTERVAL 14 DAY) AND DATE_ADD(b.entry, INTERVAL 27 DAY)) AS act14_27,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(b.entry, INTERVAL 7 DAY) AND DATE_ADD(b.entry, INTERVAL 29 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev7_29,
    COUNTIF(m.date_dim BETWEEN DATE_ADD(b.entry, INTERVAL 28 DAY) AND DATE_ADD(b.entry, INTERVAL 34 DAY)) AS act28_34,
    COUNTIF(m.date_dim BETWEEN DATE_ADD(b.entry, INTERVAL 6 DAY) AND DATE_ADD(b.entry, INTERVAL 8 DAY)) > 0 AS alive7,
    COUNTIF(m.date_dim BETWEEN DATE_ADD(b.entry, INTERVAL 13 DAY) AND DATE_ADD(b.entry, INTERVAL 15 DAY)) > 0 AS alive14,
    COUNTIF(m.date_dim BETWEEN DATE_ADD(b.entry, INTERVAL 27 DAY) AND DATE_ADD(b.entry, INTERVAL 29 DAY)) > 0 AS alive30,
    COUNTIF(m.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 13 DAY)) AS act14, COUNTIF(m.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 29 DAY)) AS act30,
    SUM(IF(m.date_dim BETWEEN b.a_start AND DATE_SUB(b.a_end, INTERVAL 1 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev_album
  FROM b JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = b.user_id AND m.date_dim BETWEEN b.a_start AND DATE_ADD(b.entry, INTERVAL 34 DAY)
  WHERE m.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02'
  GROUP BY 1, 2),
rb AS (
  SELECT b.user_id, b.album_id,
    SUM(IF(s.date_dim <= DATE_ADD(b.entry, INTERVAL 6 DAY), s.rolls_value_sum, 0)) AS ralb7,
    SUM(IF(s.date_dim <= DATE_ADD(b.entry, INTERVAL 13 DAY), s.rolls_value_sum, 0)) AS ralb14,
    SUM(s.rolls_value_sum) AS ralb30
  FROM b JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
    ON s.user_id = b.user_id AND s.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 29 DAY)
  WHERE s.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND s.roll_type = 'rolls_in' AND s.source_rolls_group = 'album'
  GROUP BY 1, 2),
tot AS (
  SELECT SUM(IFNULL(g.revenues_sum, 0)) AS game_rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` g JOIN alb a ON g.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE g.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND a.album_id BETWEEN 57 AND 65 AND g.user_id NOT IN (SELECT user_id FROM excl)),
t AS (
  SELECT b.grp, b.entry,
    CASE WHEN IFNULL(al.new7, 0) < 20 THEN 'a_barely' WHEN IFNULL(al.sets7, 0) = 0 THEN 'b_collector' WHEN al.sets7 <= 3 THEN 'c_steady' ELSE 'd_rapid' END AS type7,
    CASE WHEN IFNULL(g.act7, 0) <= 2 THEN 'act_1_2' WHEN g.act7 <= 4 THEN 'act_3_4' ELSE 'act_5_7' END AS act_band,
    IFNULL(g.rev7, 0) > 0 AS payer7,
    IFNULL(al.new7, 0) AS new7, IFNULL(al.sets7, 0) AS sets7, IFNULL(al.new14, 0) AS new14, IFNULL(al.sets14, 0) AS sets14,
    IFNULL(al.new30, 0) AS new30, IFNULL(al.sets30, 0) AS sets30, al.next_entry,
    IFNULL(r.ralb7, 0) AS ralb7, IFNULL(r.ralb14, 0) AS ralb14, IFNULL(r.ralb30, 0) AS ralb30,
    IFNULL(g.act7, 0) AS act7, IFNULL(g.act14, 0) AS act14, IFNULL(g.act30, 0) AS act30,
    IFNULL(g.rev7, 0) AS rev7, IFNULL(g.rev14, 0) AS rev14, IFNULL(g.rev30, 0) AS rev30, IFNULL(g.rev_album, 0) AS rev_album,
    IFNULL(g.act14_27, 0) AS act14_27, IFNULL(g.rev7_29, 0) AS rev7_29, IFNULL(g.act28_34, 0) AS act28_34,
    IFNULL(g.alive7, FALSE) AS alive7, IFNULL(g.alive14, FALSE) AS alive14, IFNULL(g.alive30, FALSE) AS alive30,
    DATE_ADD(b.entry, INTERVAL 27 DAY) <= DATE '2026-11-02' AS ok27, DATE_ADD(b.entry, INTERVAL 29 DAY) <= DATE '2026-11-02' AS ok29,
    DATE_ADD(b.entry, INTERVAL 34 DAY) <= DATE '2026-11-02' AS ok34
  FROM b LEFT JOIN al USING (user_id, album_id) LEFT JOIN gm g USING (user_id, album_id) LEFT JOIN rb r USING (user_id, album_id))
SELECT 'outcome' AS part, grp, type7 AS k1, act_band AS k2, payer7, COUNT(*) AS players, ROUND(SUM(rev_album) / ANY_VALUE(tot.game_rev), 4) AS share_game_rev,
  ROUND(AVG(new7), 1) AS new7, ROUND(AVG(sets7), 2) AS sets7, APPROX_QUANTILES(ralb7, 2)[OFFSET(1)] AS med_ralb7, ROUND(AVG(act7), 2) AS act7, ROUND(AVG(rev7), 2) AS rev7,
  COUNTIF(ok27) AS n_14_27, ROUND(AVG(IF(ok27, IF(act14_27 > 0, 1, 0), NULL)), 3) AS active_14_27, ROUND(AVG(IF(ok27, act14_27, NULL)), 2) AS act_days_14_27,
  COUNTIF(ok29) AS n_7_29, ROUND(AVG(IF(ok29, rev7_29, NULL)), 2) AS rev_7_29, ROUND(AVG(IF(ok29, IF(rev7_29 > 0, 1, 0), NULL)), 3) AS payer_7_29,
  COUNTIF(ok34) AS n_28_34, ROUND(AVG(IF(ok34, IF(act28_34 > 0, 1, 0), NULL)), 3) AS active_28_34
FROM t, tot GROUP BY 1, 2, 3, 4, 5
UNION ALL
SELECT 'outcome_type', grp, type7, 'all', CAST(NULL AS BOOL), COUNT(*), ROUND(SUM(rev_album) / ANY_VALUE(tot.game_rev), 4),
  ROUND(AVG(new7), 1), ROUND(AVG(sets7), 2), APPROX_QUANTILES(ralb7, 2)[OFFSET(1)], ROUND(AVG(act7), 2), ROUND(AVG(rev7), 2),
  COUNTIF(ok27), ROUND(AVG(IF(ok27, IF(act14_27 > 0, 1, 0), NULL)), 3), ROUND(AVG(IF(ok27, act14_27, NULL)), 2),
  COUNTIF(ok29), ROUND(AVG(IF(ok29, rev7_29, NULL)), 2), ROUND(AVG(IF(ok29, IF(rev7_29 > 0, 1, 0), NULL)), 3),
  COUNTIF(ok34), ROUND(AVG(IF(ok34, IF(act28_34 > 0, 1, 0), NULL)), 3)
FROM t, tot GROUP BY 1, 2, 3, 4, 5
UNION ALL
SELECT 'survivor_d7', grp, 'alive_6_8', '', CAST(NULL AS BOOL), COUNTIF(alive7), ROUND(SUM(IF(alive7, rev_album, 0)) / ANY_VALUE(tot.game_rev), 4),
  ROUND(AVG(IF(alive7, new7, NULL)), 1), ROUND(AVG(IF(alive7, sets7, NULL)), 2), APPROX_QUANTILES(IF(alive7, ralb7, NULL), 2)[OFFSET(1)],
  ROUND(AVG(IF(alive7, act7, NULL)), 2), ROUND(AVG(IF(alive7, rev7, NULL)), 2),
  COUNT(*), ROUND(AVG(IF(alive7, 1, 0)), 3), NULL, NULL, ROUND(AVG(IF(alive7, IF(rev7 > 0, 1, 0), NULL)), 3), NULL,
  NULL, ROUND(AVG(IF(alive7, IF(next_entry <= DATE_ADD(entry, INTERVAL 7 DAY), 1, 0), NULL)), 3)
FROM t, tot GROUP BY 1, 2, 3, 4, 5
UNION ALL
SELECT 'survivor_d14', grp, 'alive_13_15', '', CAST(NULL AS BOOL), COUNTIF(alive14), ROUND(SUM(IF(alive14, rev_album, 0)) / ANY_VALUE(tot.game_rev), 4),
  ROUND(AVG(IF(alive14, new14, NULL)), 1), ROUND(AVG(IF(alive14, sets14, NULL)), 2), APPROX_QUANTILES(IF(alive14, ralb14, NULL), 2)[OFFSET(1)],
  ROUND(AVG(IF(alive14, act14, NULL)), 2), ROUND(AVG(IF(alive14, rev14, NULL)), 2),
  COUNT(*), ROUND(AVG(IF(alive14, 1, 0)), 3), NULL, NULL, ROUND(AVG(IF(alive14, IF(rev14 > 0, 1, 0), NULL)), 3), NULL,
  NULL, ROUND(AVG(IF(alive14, IF(next_entry <= DATE_ADD(entry, INTERVAL 14 DAY), 1, 0), NULL)), 3)
FROM t, tot GROUP BY 1, 2, 3, 4, 5
UNION ALL
SELECT 'survivor_d30', grp, 'alive_27_29', '', CAST(NULL AS BOOL), COUNTIF(alive30 AND ok29), ROUND(SUM(IF(alive30 AND ok29, rev_album, 0)) / ANY_VALUE(tot.game_rev), 4),
  ROUND(AVG(IF(alive30 AND ok29, new30, NULL)), 1), ROUND(AVG(IF(alive30 AND ok29, sets30, NULL)), 2), APPROX_QUANTILES(IF(alive30 AND ok29, ralb30, NULL), 2)[OFFSET(1)],
  ROUND(AVG(IF(alive30 AND ok29, act30, NULL)), 2), ROUND(AVG(IF(alive30 AND ok29, rev30, NULL)), 2),
  COUNTIF(ok29), ROUND(AVG(IF(ok29, IF(alive30, 1, 0), NULL)), 3), NULL, NULL, ROUND(AVG(IF(alive30 AND ok29, IF(rev30 > 0, 1, 0), NULL)), 3), NULL,
  NULL, ROUND(AVG(IF(alive30 AND ok29, IF(next_entry <= DATE_ADD(entry, INTERVAL 29 DAY), 1, 0), NULL)), 3)
FROM t, tot GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2, 3, 4, 5;
-- Column reuse in survivor rows: players = alive players; new7/sets7/med_ralb7/act7/rev7 = cumulative to day 7 / 14 / 29;
-- n_14_27 = all players with follow-up; active_14_27 = share alive; payer_7_29 = share of alive who paid by that day;
-- active_28_34 = share of alive already in the next album by that day.
