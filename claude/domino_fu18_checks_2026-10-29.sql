-- 2026-10-29 (Eden): FU18 follow-up checks. domino-dreams-dbt. Test = MOD(server_user_id,997) < 498 (3 locked).
-- q31: slide-2 population (Easy level-35+ proxy, as q14) per window: players, active player-days, payers, album $ -> ARPDAU, ARPPU, $ per player.
-- q32: daily Easy in-app $ per player Jun 14 - Jul 27 (A/B definition, as q27) -> is the Jul 7-20 drop a few days or spread?
-- q33: Hard players (A/B definition) by window, same windows as q28/q30 (Hard was in the test too: finished 29.9% vs 19.6%).

-- ===== q31 =====
WITH excluded AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-08-04'
  GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    LOGICAL_OR(LOWER(a.album_segment) LIKE '%easy%') AS easy,
    SUM(IF(a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-06-27', IFNULL(a.album_spent_today, 0), 0)) AS r_pre,
    SUM(IF(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05', IFNULL(a.album_spent_today, 0), 0)) AS r_win,
    COUNTIF(a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-06-27' AND a.active_flag) AS d_pre,
    COUNTIF(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS d_win,
    LOGICAL_OR(a.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' AND a.active_flag) AS act
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded x ON x.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18 AND a.special_user_flag = FALSE
    AND x.user_id IS NULL
  GROUP BY 1 HAVING act),
lv AS (
  SELECT m.user_id, MAX(m.level_id_end_day) lvl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m JOIN a USING (user_id)
  WHERE m.date_dim BETWEEN DATE '2026-06-28' AND DATE '2026-07-05' GROUP BY 1)
SELECT IF(MOD(a.sid, 997) < 498, 'Test', 'Control') grp, COUNT(*) n,
  SUM(r_pre) rev_pre, SUM(d_pre) dau_pre, COUNTIF(r_pre > 0) pay_pre,
  SUM(r_win) rev_win, SUM(d_win) dau_win, COUNTIF(r_win > 0) pay_win
FROM a JOIN lv USING (user_id)
WHERE a.sid IS NOT NULL AND a.easy AND lv.lvl >= 35
GROUP BY 1 ORDER BY 1;

-- ===== q32 (+q33): daily in-app $ per player by segment (Easy, Hard), Jun 14 - Sep 7, A/B definition (as q27) =====
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    LOGICAL_OR(LOWER(a.album_segment) LIKE '%easy%') AS easy, LOGICAL_OR(LOWER(a.album_segment) LIKE '%hard%') AS hard,
    LOGICAL_OR(a.special_user_flag) AS sp
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18
  GROUP BY 1),
d AS (
  SELECT m.user_id, m.date_dim dd, IF(m.level_id_end_day >= 35, m.user_daily_inapp_purchase_amount, 0) amt,
    m.special_user_flag sp, m.deactivated_user_flag de
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m
  WHERE m.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07'),
ex AS (SELECT user_id FROM d GROUP BY 1 HAVING LOGICAL_OR(IFNULL(sp, FALSE) OR IFNULL(de, FALSE))),
pop AS (
  SELECT a.user_id, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp, IF(a.easy AND NOT a.hard, 'Easy', 'Hard') seg
  FROM a LEFT JOIN ex USING (user_id)
  WHERE a.sid IS NOT NULL AND (a.easy OR a.hard) AND NOT (a.easy AND a.hard) AND NOT IFNULL(a.sp, FALSE) AND ex.user_id IS NULL),
gs AS (SELECT grp, seg, COUNT(*) n FROM pop GROUP BY 1, 2),
day AS (
  SELECT p.grp, p.seg, d.dd, SUM(d.amt) rev, COUNT(DISTINCT IF(d.amt > 0, d.user_id, NULL)) payers, COUNT(DISTINCT d.user_id) rows_active
  FROM d JOIN pop p USING (user_id)
  WHERE d.dd BETWEEN DATE '2026-06-14' AND DATE '2026-09-07'
  GROUP BY 1, 2, 3)
SELECT day.seg, day.grp, day.dd, gs.n, ROUND(day.rev, 2) rev, day.payers, day.rows_active
FROM day JOIN gs USING (grp, seg)
ORDER BY 1, 3, 2;

-- ===== q32a (ran): daily Easy gap Jun 28 - Jul 27 (pivoted Test vs Control) =====
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    LOGICAL_OR(LOWER(a.album_segment) LIKE '%easy%') AS easy, LOGICAL_OR(LOWER(a.album_segment) LIKE '%hard%') AS hard,
    LOGICAL_OR(a.special_user_flag) AS sp
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18
  GROUP BY 1),
d AS (
  SELECT m.user_id, m.date_dim dd, IF(m.level_id_end_day >= 35, m.user_daily_inapp_purchase_amount, 0) amt,
    m.special_user_flag sp, m.deactivated_user_flag de
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m
  WHERE m.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07'),
ex AS (SELECT user_id FROM d GROUP BY 1 HAVING LOGICAL_OR(IFNULL(sp, FALSE) OR IFNULL(de, FALSE))),
pop AS (
  SELECT a.user_id, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp, IF(a.easy AND NOT a.hard, 'Easy', 'Hard') seg
  FROM a LEFT JOIN ex USING (user_id)
  WHERE a.sid IS NOT NULL AND (a.easy OR a.hard) AND NOT (a.easy AND a.hard) AND NOT IFNULL(a.sp, FALSE) AND ex.user_id IS NULL),
gs AS (SELECT grp, seg, COUNT(*) n FROM pop GROUP BY 1, 2),
day AS (
  SELECT p.grp, p.seg, d.dd, SUM(d.amt) rev, COUNT(DISTINCT IF(d.amt > 0, d.user_id, NULL)) payers, COUNT(DISTINCT d.user_id) rows_active
  FROM d JOIN pop p USING (user_id)
  WHERE d.dd BETWEEN DATE '2026-06-14' AND DATE '2026-09-07'
  GROUP BY 1, 2, 3)
SELECT d1.dd, ROUND((t.rev/t.n)/(c.rev/c.n)-1, 4) gap, ROUND(t.rev/t.n, 4) t_pp, ROUND(c.rev/c.n, 4) c_pp,
  ROUND(t.payers/t.n, 5) t_pr, ROUND(c.payers/c.n, 5) c_pr
FROM (SELECT DISTINCT dd FROM day) d1
JOIN (SELECT day.dd, day.rev, day.payers, gs.n FROM day JOIN gs USING (grp, seg) WHERE day.seg='Easy' AND day.grp='Test') t ON t.dd = d1.dd
JOIN (SELECT day.dd, day.rev, day.payers, gs.n FROM day JOIN gs USING (grp, seg) WHERE day.seg='Easy' AND day.grp='Control') c ON c.dd = d1.dd
WHERE d1.dd BETWEEN DATE '2026-06-28' AND DATE '2026-07-27'
ORDER BY 1;

-- ===== q33 (ran): Easy and Hard by window =====
WITH a AS (
  SELECT a.user_id, ANY_VALUE(a.server_user_id) AS sid,
    LOGICAL_OR(LOWER(a.album_segment) LIKE '%easy%') AS easy, LOGICAL_OR(LOWER(a.album_segment) LIKE '%hard%') AS hard,
    LOGICAL_OR(a.special_user_flag) AS sp
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-05-11' AND DATE '2026-07-06' AND a.album_id = 18
  GROUP BY 1),
d AS (
  SELECT m.user_id, m.date_dim dd, IF(m.level_id_end_day >= 35, m.user_daily_inapp_purchase_amount, 0) amt,
    m.special_user_flag sp, m.deactivated_user_flag de
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` m
  WHERE m.date_dim BETWEEN DATE '2026-04-03' AND DATE '2026-09-07'),
ex AS (SELECT user_id FROM d GROUP BY 1 HAVING LOGICAL_OR(IFNULL(sp, FALSE) OR IFNULL(de, FALSE))),
pop AS (
  SELECT a.user_id, IF(MOD(a.sid, 997) < 498, 'Test', 'Control') AS grp, IF(a.easy AND NOT a.hard, 'Easy', 'Hard') seg
  FROM a LEFT JOIN ex USING (user_id)
  WHERE a.sid IS NOT NULL AND (a.easy OR a.hard) AND NOT (a.easy AND a.hard) AND NOT IFNULL(a.sp, FALSE) AND ex.user_id IS NULL),
gs AS (SELECT grp, seg, COUNT(*) n FROM pop GROUP BY 1, 2),
day AS (
  SELECT p.grp, p.seg, d.dd, SUM(d.amt) rev, COUNT(DISTINCT IF(d.amt > 0, d.user_id, NULL)) payers, COUNT(DISTINCT d.user_id) rows_active
  FROM d JOIN pop p USING (user_id)
  WHERE d.dd BETWEEN DATE '2026-06-14' AND DATE '2026-09-07'
  GROUP BY 1, 2, 3)
SELECT day.seg, day.grp, ANY_VALUE(gs.n) n,
  SUM(IF(day.dd BETWEEN DATE '2026-06-14' AND DATE '2026-06-27', day.rev, 0)) pre14,
  SUM(IF(day.dd BETWEEN DATE '2026-06-28' AND DATE '2026-07-06', day.rev, 0)) tst,
  SUM(IF(day.dd BETWEEN DATE '2026-07-07' AND DATE '2026-07-20', day.rev, 0)) a18,
  SUM(IF(day.dd BETWEEN DATE '2026-07-21' AND DATE '2026-08-24', day.rev, 0)) al19,
  SUM(IF(day.dd BETWEEN DATE '2026-08-25' AND DATE '2026-09-07', day.rev, 0)) a19,
  SUM(IF(day.dd BETWEEN DATE '2026-06-28' AND DATE '2026-09-07', day.rev, 0)) cum
FROM day JOIN gs USING (grp, seg) GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== q34 (ran 2026-10-29): end state on Jul 6 by state on Jun 27, Easy, A/B definition =====
-- see claude/domino-fu18-checks-2026-10-29.md section 6 (query text = the inline query of that run: uq_pre <= Jun 27, uq_end <= Jul 6, groups at FU 3-5 / 6-10 / 11+).

-- ===== q35 (ran 2026-10-29): 72-day gap by state on Jun 27 x in-app $ a day in Jun 14-27 ($0 / <=2 / 2-5 / 5-20 / >20), Easy, A/B definition =====
-- Same pop/windows as q30; tier = pre(14 days)/14. Results: claude/domino-fu18-checks-2026-10-29.md section 7.

-- ===== q36 (ran 2026-10-29): end state Jul 6 for players at FU on Jun 27, by in-app $ a day Jun 14-27 (low <$5 / $5-20 / >$20), Easy, A/B definition. Results: claude/domino-fu18-checks-2026-10-29.md section 8.
