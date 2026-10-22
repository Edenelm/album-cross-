-- Topic 2 Dice reruns on the fixed standard population (Eden approved 2026-10-22). Results: claude/dice-topic2-reruns-2026-10-22.md
-- Only change vs the original queries: "not first album" = the player has a row in an earlier album of user_daily_album
--   (history from 2023-11-01), replacing user_past_album_count > 0 (decisions-definitions-register, 2026-10-21).
-- Originals: B = stand_close3_queries.sql (Dice); C = EndWin Dice in middle-payers-stall-2026-10-15.md; D = strength_percentile_queries.sql (Dice).

-- ===== B. Where payers stand 3 days before close (Dice 61/63) =====
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-08' AND album_id IN (61, 63) GROUP BY 1),
hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07'
  GROUP BY 1),
u0 AS (
  SELECT x.album_id, x.user_id,
    SUM(IF(x.date_dim <= DATE_SUB(a.a_end, INTERVAL 3 DAY), IFNULL(x.spent_in_album_today, 0), 0)) AS rev_c3,
    MAX(IF(x.date_dim <= DATE_SUB(a.a_end, INTERVAL 3 DAY), x.unique_stickers_lt, NULL)) AS stk_c3,
    ANY_VALUE(DATE_DIFF(DATE_SUB(a.a_end, INTERVAL 3 DAY), a.a_start, DAY) + 1) AS days_c3,
    ARRAY_AGG(STRUCT(x.album_login_ratio AS lr, x.is_excluded AS ex) ORDER BY x.date_dim DESC LIMIT 1)[OFFSET(0)] AS l
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x JOIN alb a USING (album_id)
  WHERE x.date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-08' AND x.date_dim < a.a_end
  GROUP BY 1, 2),
u AS (SELECT album_id, user_id, rev_c3, stk_c3, days_c3, l.lr AS lr, l.ex AS ex FROM u0)
SELECT u.album_id,
  CASE WHEN rev_c3 = 0 THEN '0' WHEN rev_c3 / days_c3 <= 2 THEN '<=2' WHEN rev_c3 / days_c3 <= 5 THEN '2-5'
       WHEN rev_c3 / days_c3 <= 20 THEN '5-20' ELSE '>20' END AS grp,
  COUNT(*) AS players, ROUND(SUM(rev_c3)) AS rev,
  COUNTIF(144 - stk_c3 <= 3) AS players_near, ROUND(SUM(IF(144 - stk_c3 <= 3, rev_c3, 0))) AS rev_near
FROM u JOIN hist h USING (user_id)
WHERE u.lr >= 0.5 AND h.first_album_seen < u.album_id AND NOT IFNULL(u.ex, FALSE) AND u.stk_c3 IS NOT NULL
GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== C. Last 14 days by window: who the Wild reaches (EndWin, Dice 61/63) =====
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end, 35 AS n UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07', 42),
hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07'
  GROUP BY 1),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.a_start, alb.n,
    DATE_DIFF(a.date_dim, alb.a_start, DAY) AS d,
    a.album_login_ratio AS lr, h.first_album_seen < a.album_id AS returning,
    IFNULL(a.spent_in_album_today, 0) AS spend, IFNULL(a.is_active, FALSE) AS act,
    144 - IFNULL(a.unique_stickers_lt, 0) AS miss
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id) JOIN hist h USING (user_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
tgt AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_st, ANY_VALUE(n) AS n_, SUM(spend) AS total,
    SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far, MIN(miss) AS m_end
  FROM r0 GROUP BY 1, 2
  HAVING LOGICAL_AND(returning) AND MIN(d) <= CAST(CEIL(0.75 * ANY_VALUE(n)) AS INT64) - 1
     AND ARRAY_AGG(lr ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
p AS (
  SELECT album_id, user_id, a_st AS a_start, n_ AS n, total, so_far, m_end,
    IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr
  FROM tgt),
g AS (
  SELECT album_id, user_id, a_start, n, total,
    CASE WHEN pr < 0.5 THEN '1 weak' WHEN pr < 0.95 THEN '2 middle' ELSE '3 strong' END AS grp,
    CASE WHEN m_end >= 4 THEN '4+' ELSE '1-3' END AS st
  FROM p WHERE so_far > 0 AND m_end > 0),
gs AS (SELECT album_id, grp, st, COUNT(*) AS players, SUM(total) AS rev FROM g GROUP BY 1, 2, 3),
uw AS (
  SELECT g.album_id, g.grp, g.st, g.user_id,
    CASE WHEN g.n - r.d BETWEEN 11 AND 14 THEN 'a 14-11' WHEN g.n - r.d BETWEEN 8 AND 10 THEN 'b 10-8'
         WHEN g.n - r.d BETWEEN 5 AND 7 THEN 'c 7-5' ELSE 'd 4-1' END AS w,
    COUNTIF(r.act) AS act_days, SUM(r.spend) AS spend
  FROM g JOIN r0 r ON r.album_id = g.album_id AND r.user_id = g.user_id
  WHERE g.n - r.d BETWEEN 1 AND 14 GROUP BY 1, 2, 3, 4, 5),
wa AS (SELECT album_id, grp, st, w, SUM(act_days) AS act_days, SUM(spend) AS spend, COUNTIF(spend > 0) AS payers FROM uw GROUP BY 1, 2, 3, 4),
sk AS (
  SELECT g.album_id, g.grp, g.st, g.n, g.a_start, LOWER(s.sticker_type) AS typ, IFNULL(s.collected_from_wild, FALSE) AS wild,
    s.sticker_mtx_campaign_name IS NOT NULL AS paid, s.sticker_collected_date AS cdate
  FROM g JOIN `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s ON s.album_id = g.album_id AND s.user_id = g.user_id
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND s.album_id IN (61, 63) AND s.is_sticker_collected
  QUALIFY ROW_NUMBER() OVER (PARTITION BY g.album_id, g.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1),
sw AS (
  SELECT album_id, grp, st,
    CASE WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 11 AND 14 THEN 'a 14-11' WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 8 AND 10 THEN 'b 10-8'
         WHEN n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 5 AND 7 THEN 'c 7-5' ELSE 'd 4-1' END AS w,
    COUNTIF(typ = 'super') AS gate_new, COUNTIF(typ = 'super' AND wild) AS gate_wild, COUNTIF(typ = 'super' AND paid AND NOT wild) AS gate_paid,
    COUNTIF(typ = 'golden') AS golden_new, COUNTIF(wild) AS wild_any
  FROM sk WHERE n - DATE_DIFF(cdate, a_start, DAY) BETWEEN 1 AND 14 GROUP BY 1, 2, 3, 4)
SELECT wa.album_id, wa.grp, wa.st, wa.w, gs.players, ROUND(gs.rev) AS group_rev,
  ROUND(wa.act_days / (gs.players * CASE wa.w WHEN 'a 14-11' THEN 4 WHEN 'b 10-8' THEN 3 WHEN 'c 7-5' THEN 3 ELSE 4 END), 3) AS active_rate,
  ROUND(wa.payers / gs.players, 3) AS payer_rate,
  ROUND(wa.spend / gs.rev, 3) AS share_of_group_rev,
  ROUND(100 * IFNULL(sw.gate_new, 0) / gs.players, 1) AS gate_new_per100,
  ROUND(100 * IFNULL(sw.gate_wild, 0) / gs.players, 1) AS gate_wild_per100,
  ROUND(100 * IFNULL(sw.gate_paid, 0) / gs.players, 1) AS gate_paid_per100,
  ROUND(100 * IFNULL(sw.golden_new, 0) / gs.players, 1) AS golden_new_per100,
  ROUND(100 * IFNULL(sw.wild_any, 0) / gs.players, 1) AS wild_any_per100
FROM wa JOIN gs USING (album_id, grp, st) LEFT JOIN sw USING (album_id, grp, st, w)
ORDER BY 1, 2, 3, 4;

-- ===== D. Finish rate and revenue share by payer strength percentile (Dice 61/63) =====
WITH alb AS (SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end UNION ALL SELECT 63, DATE '2026-07-27', DATE '2026-09-07'),
tgt AS (SELECT album_id, a_start, a_end, DATE_ADD(a_start, INTERVAL CAST(FLOOR(0.75 * DATE_DIFF(a_end, a_start, DAY)) AS INT64) DAY) AS q4 FROM alb),
hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07'
  GROUP BY 1),
ud AS (
  SELECT d.album_id, d.user_id, d.date_dim,
    IFNULL(d.unique_common_stickers_lt,0) + IFNULL(d.unique_golden_stickers_lt,0) + IFNULL(d.unique_super_stickers_lt,0) AS uniq,
    d.album_login_ratio_until_this_day AS lr, h.first_album_seen < d.album_id AS past, IFNULL(d.is_excluded,FALSE) AS excl,
    IFNULL(d.spent_in_album_today,0) AS spend, IFNULL(d.is_active, FALSE) AS act
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` d JOIN hist h USING (user_id)
  WHERE d.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND d.album_id IN (61,63) AND d.date_dim < d.album_end_date
),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN tgt t USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= t.a_end
  GROUP BY 1,2
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06'
),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
tot AS (
  SELECT t.album_id, SUM(m.rev) AS game_rev
  FROM udm m JOIN tgt t ON m.date_dim BETWEEN t.a_start AND DATE_SUB(t.a_end, INTERVAL 1 DAY)
  WHERE m.user_id NOT IN (SELECT user_id FROM excl)
  GROUP BY 1
),
u0 AS (
  SELECT u.album_id, u.user_id, MAX(u.uniq) AS uniq_prev, SUM(u.spend) AS alb_rev,
    SUM(IF(u.date_dim < t.q4, u.spend, 0)) AS q_rev, COUNTIF(u.act AND u.date_dim < t.q4) AS q_days, MAX(u.date_dim) AS last_d,
    ARRAY_AGG(STRUCT(u.lr, u.past, u.excl) ORDER BY u.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l
  FROM ud u JOIN tgt t USING (album_id) GROUP BY 1,2
),
u1 AS (SELECT album_id, user_id, uniq_prev, alb_rev, q_rev, q_days, last_d, l.lr AS lr, l.past AS past, l.excl AS excl FROM u0),
pop AS (
  SELECT u.album_id, u.user_id, u.alb_rev, IFNULL(SAFE_DIVIDE(u.q_rev, u.q_days), 0) AS strength,
    GREATEST(IFNULL(s.n_uniq, 0), IFNULL(u.uniq_prev, 0)) >= 144 AS fin
  FROM u1 u JOIN tgt t USING (album_id) LEFT JOIN st s USING (album_id, user_id)
  WHERE u.last_d = DATE_SUB(t.a_end, INTERVAL 1 DAY) AND u.past AND NOT u.excl AND u.lr >= 0.5 AND u.alb_rev > 0
),
rk AS (SELECT album_id, alb_rev, fin, strength, PERCENT_RANK() OVER (PARTITION BY album_id, strength > 0 ORDER BY strength) AS pr FROM pop),
b AS (
  SELECT album_id, alb_rev, fin, strength,
    CASE WHEN strength = 0 THEN '00_zero' WHEN pr < 0.1 THEN '01_d1' WHEN pr < 0.2 THEN '02_d2' WHEN pr < 0.3 THEN '03_d3' WHEN pr < 0.4 THEN '04_d4'
         WHEN pr < 0.5 THEN '05_d5' WHEN pr < 0.6 THEN '06_d6' WHEN pr < 0.7 THEN '07_d7' WHEN pr < 0.8 THEN '08_d8' WHEN pr < 0.9 THEN '09_d9'
         WHEN pr < 0.95 THEN '10_p90_95' WHEN pr < 0.99 THEN '11_p95_99' ELSE '12_p99' END AS bucket
  FROM rk
)
SELECT b.album_id, b.bucket, COUNT(*) AS n, ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY b.album_id), 4) AS sh_payers,
  ROUND(MIN(b.strength), 2) AS min_pd, ROUND(MAX(b.strength), 2) AS max_pd,
  COUNTIF(b.fin) AS finishers, ROUND(COUNTIF(b.fin) / COUNT(*), 4) AS fin_rate,
  ROUND(SUM(b.alb_rev) / ANY_VALUE(t.game_rev), 4) AS sh_game_rev, ROUND(SUM(IF(b.fin, b.alb_rev, 0)) / ANY_VALUE(t.game_rev), 4) AS fin_sh_game_rev
FROM b JOIN tot t USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;
