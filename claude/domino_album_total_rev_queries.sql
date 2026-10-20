-- 2026-10-18: Domino 18/19/20 — did total album revenue (all players, not only finishers) rise in 20?
-- Part A (all players in the album table, no filters except special users): total album revenue, album days, revenue per day, players, payers.
-- Part B (19, 20 only): eligible population as before (not first album, login ratio >= 0.5 on last full day, exclusions), by strength group
--   (prev-album $ per active day): revenue per eligible player, payer rate.
-- Revenue = album_spent_today over album days (open .. last full day).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12' AND album_id IN (18,19,20) AND date_dim < album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-01' AND DATE '2026-10-12'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
alb0 AS (SELECT album_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM ud GROUP BY 1),
alb AS (SELECT album_id, a_start, a_end, LAG(album_id) OVER (ORDER BY a_start) AS prev_id FROM alb0),
partA AS (
  SELECT u.album_id, 'A_all_players' AS part, 'all' AS grp, ANY_VALUE(DATE_DIFF(a.a_end, a.a_start, DAY)) AS album_days,
    COUNT(DISTINCT u.user_id) AS players, COUNT(DISTINCT IF(u.spend > 0, u.user_id, NULL)) AS payers, SUM(u.spend) AS rev
  FROM ud u JOIN alb a USING (album_id) WHERE NOT u.excl GROUP BY 1
),
pop AS (
  SELECT u.album_id, u.user_id, a.prev_id, p.a_start AS p_start, p.a_end AS p_end
  FROM ud u JOIN alb a USING (album_id) JOIN alb p ON p.album_id = a.prev_id
  WHERE u.album_id IN (19,20) AND u.date_dim = DATE_SUB(a.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
),
cur AS (SELECT p.album_id, p.user_id, SUM(u.spend) AS rev_alb FROM pop p JOIN ud u USING (album_id, user_id) GROUP BY 1,2),
prv_rev AS (SELECT p.album_id, p.user_id, SUM(u.spend) AS rev_prev FROM pop p JOIN ud u ON u.user_id = p.user_id AND u.album_id = p.prev_id GROUP BY 1,2),
prv_act AS (
  SELECT p.album_id, p.user_id, COUNTIF(m.act) AS ad_prev
  FROM pop p JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN p.p_start AND DATE_SUB(p.p_end, INTERVAL 1 DAY) GROUP BY 1,2
),
d AS (
  SELECT p.album_id, p.user_id, IFNULL(c.rev_alb, 0) AS rev_alb,
    CASE WHEN SAFE_DIVIDE(r.rev_prev, a.ad_prev) IS NULL OR SAFE_DIVIDE(r.rev_prev, a.ad_prev) = 0 THEN 'g0'
         WHEN SAFE_DIVIDE(r.rev_prev, a.ad_prev) <= 2 THEN 'g1_le2' WHEN SAFE_DIVIDE(r.rev_prev, a.ad_prev) <= 5 THEN 'g2_2_5'
         WHEN SAFE_DIVIDE(r.rev_prev, a.ad_prev) <= 20 THEN 'g3_5_20' ELSE 'g4_20plus' END AS grp
  FROM pop p LEFT JOIN cur c USING (album_id, user_id) LEFT JOIN prv_rev r USING (album_id, user_id) LEFT JOIN prv_act a USING (album_id, user_id)
),
partB AS (
  SELECT album_id, 'B_eligible' AS part, grp, NULL AS album_days, COUNT(*) AS players, COUNTIF(rev_alb > 0) AS payers, SUM(rev_alb) AS rev FROM d GROUP BY 1,3
  UNION ALL
  SELECT album_id, 'B_eligible', 'all', NULL, COUNT(*), COUNTIF(rev_alb > 0), SUM(rev_alb) FROM d GROUP BY 1
)
SELECT album_id, part, grp, album_days, players, payers,
  ROUND(100 * payers / players, 1) AS payer_rate, ROUND(rev) AS rev,
  ROUND(rev / players, 2) AS rev_per_player, ROUND(SAFE_DIVIDE(rev, album_days)) AS rev_per_day
FROM (SELECT album_id, part, grp, album_days, players, payers, rev FROM partA UNION ALL SELECT album_id, part, grp, album_days, players, payers, rev FROM partB)
ORDER BY part, grp, album_id
