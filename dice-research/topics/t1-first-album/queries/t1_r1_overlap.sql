-- Topic 1 reopened / R1: are first-album players comparable across entry-timing groups before entry? Project dice-dreams-dbt. Albums 57-65.
-- Definitions D-010. Entry = first day with a sticker (user_daily_album); D = close date - entry date.
-- Groups: a_start 29+ / b_middle 15-28 / c_late 8-14 / d_final_week 4-7 / e_last_days 1-3 / f_close_day 0.
-- Pre-entry traits: game age = entry - install_date; prior pay = LTV before entry (user_daily_metrics_agg.ltv on days before entry);
--   kingdom at entry = kingdom_id_start_day on the entry row; roll balance = rolls_startday on the entry day; prior activity = active
--   days in the 7 days before entry; install source = organic vs paid (fact_user_installation.media_source).
-- Cells = age4 x pay3 x kingdom4 x balance4 x activity3. Common support for a group = player sits in a cell where both the group and
--   a_start have >= 20 players. Revenue share = game revenue on album days start..close-1 / all game revenue those days (pooled, excl. removed).
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 65),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
p AS (
  SELECT u.user_id, u.album_id, ARRAY_AGG(STRUCT(u.date_dim AS d, u.kingdom_id_start_day AS k) ORDER BY u.date_dim LIMIT 1)[OFFSET(0)] AS e,
    LOGICAL_OR(IFNULL(u.is_excluded, FALSE)) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND u.album_id BETWEEN 57 AND 65 AND u.date_dim <= a.a_end
  GROUP BY 1, 2),
p1 AS (SELECT user_id, album_id, e.d AS entry, e.k AS k_entry, ex FROM p),
b AS (
  SELECT p1.user_id, p1.album_id, p1.entry, p1.k_entry, a.a_start, a.a_end, DATE_DIFF(a.a_end, p1.entry, DAY) AS dleft
  FROM p1 JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p1.album_id AND NOT p1.ex AND p1.user_id NOT IN (SELECT user_id FROM excl)),
g AS (
  SELECT b.user_id, b.album_id, MIN(m.install_date) AS inst,
    MAX(IF(m.date_dim < b.entry, m.ltv, NULL)) AS ltv_before,
    ANY_VALUE(IF(m.date_dim = b.entry, m.rolls_startday, NULL)) AS bal_start,
    COUNTIF(m.date_dim BETWEEN DATE_SUB(b.entry, INTERVAL 7 DAY) AND DATE_SUB(b.entry, INTERVAL 1 DAY)) AS act7_before,
    SUM(IF(m.date_dim BETWEEN b.a_start AND DATE_SUB(b.a_end, INTERVAL 1 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev_album
  FROM b JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = b.user_id AND m.date_dim BETWEEN DATE_SUB(b.entry, INTERVAL 60 DAY) AND b.a_end
  WHERE m.date_dim BETWEEN DATE '2026-01-22' AND DATE '2026-10-19'
  GROUP BY 1, 2),
src AS (
  SELECT user_id, ANY_VALUE(media_source) AS media_source FROM `dice-dreams-dbt.20_core.fact_user_installation`
  WHERE installation_date BETWEEN DATE '2015-01-01' AND DATE '2026-10-19' AND user_id IN (SELECT user_id FROM b) GROUP BY 1),
tot AS (
  SELECT SUM(IFNULL(x.revenues_sum, 0)) AS game_rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` x JOIN alb a ON x.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE x.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND x.user_id NOT IN (SELECT user_id FROM excl)),
t AS (
  SELECT
    CASE WHEN b.dleft >= 29 THEN 'a_start' WHEN b.dleft >= 15 THEN 'b_middle' WHEN b.dleft >= 8 THEN 'c_late'
         WHEN b.dleft >= 4 THEN 'd_final_week' WHEN b.dleft >= 1 THEN 'e_last_days' ELSE 'f_close_day' END AS grp,
    CASE WHEN DATE_DIFF(b.entry, g.inst, DAY) <= 2 THEN 'a_0_2' WHEN DATE_DIFF(b.entry, g.inst, DAY) <= 7 THEN 'b_3_7'
         WHEN DATE_DIFF(b.entry, g.inst, DAY) <= 30 THEN 'c_8_30' ELSE 'd_31plus' END AS age,
    CASE WHEN IFNULL(g.ltv_before, 0) = 0 THEN 'a_0' WHEN g.ltv_before < 20 THEN 'b_1_20' ELSE 'c_20plus' END AS pay,
    CASE WHEN b.k_entry <= 4 THEN 'a_le4' WHEN b.k_entry <= 6 THEN 'b_5_6' WHEN b.k_entry <= 9 THEN 'c_7_9' ELSE 'd_10plus' END AS kgd,
    CASE WHEN g.bal_start IS NULL THEN 'x_na' WHEN g.bal_start < 50 THEN 'a_0_49' WHEN g.bal_start < 200 THEN 'b_50_199'
         WHEN g.bal_start < 1000 THEN 'c_200_999' ELSE 'd_1000plus' END AS bal,
    CASE WHEN IFNULL(g.act7_before, 0) = 0 THEN 'a_0' WHEN g.act7_before <= 3 THEN 'b_1_3' ELSE 'c_4plus' END AS act,
    IF(LOWER(IFNULL(s.media_source, 'organic')) IN ('organic', '', 'none'), 'organic', 'paid') AS src,
    IFNULL(g.rev_album, 0) AS rev_album, b.dleft
  FROM b LEFT JOIN g USING (user_id, album_id) LEFT JOIN src s USING (user_id)),
cell AS (
  SELECT age, pay, kgd, bal, act, COUNTIF(grp = 'a_start') AS n_start,
    COUNTIF(grp = 'b_middle') AS n_b, COUNTIF(grp = 'c_late') AS n_c, COUNTIF(grp = 'd_final_week') AS n_d,
    COUNTIF(grp = 'e_last_days') AS n_e, COUNTIF(grp = 'f_close_day') AS n_f
  FROM t GROUP BY 1, 2, 3, 4, 5),
tc AS (
  SELECT t.*, c.n_start >= 20 AND (CASE t.grp WHEN 'a_start' THEN c.n_start WHEN 'b_middle' THEN c.n_b WHEN 'c_late' THEN c.n_c
      WHEN 'd_final_week' THEN c.n_d WHEN 'e_last_days' THEN c.n_e ELSE c.n_f END) >= 20 AS supported
  FROM t JOIN cell c USING (age, pay, kgd, bal, act)),
gs AS (SELECT grp, COUNT(*) AS n FROM tc GROUP BY 1)
SELECT 'summary' AS part, grp, 'all' AS trait, 'all' AS band, COUNT(*) AS players,
  ROUND(SUM(rev_album) / ANY_VALUE(tot.game_rev), 5) AS share_game_rev, ROUND(AVG(dleft), 1) AS avg_days_left,
  ROUND(AVG(IF(supported, 1, 0)), 3) AS share_in_common_support, ROUND(SAFE_DIVIDE(SUM(IF(supported, rev_album, 0)), SUM(rev_album)), 3) AS rev_share_in_support
FROM tc, tot GROUP BY 1, 2, 3, 4
UNION ALL
SELECT 'trait', tc.grp, x.trait, x.band, COUNT(*), NULL, NULL, ROUND(COUNT(*) / ANY_VALUE(gs.n), 3), NULL
FROM tc JOIN gs USING (grp),
  UNNEST([STRUCT('age' AS trait, age AS band), ('pay', pay), ('kingdom', kgd), ('balance', bal), ('act7_before', act), ('source', src)]) x
GROUP BY 1, 2, 3, 4
ORDER BY 1, 3, 4, 2;
