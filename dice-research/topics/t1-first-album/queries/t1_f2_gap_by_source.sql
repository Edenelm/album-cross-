-- Topic 1 / F2: where do late entrants' extra new stickers in week 1 come from? Project dice-dreams-dbt. Albums 57-65.
-- Eligible population (D-009); new stickers (first copies, sticker table) of the FIRST album, days 0-6 since entry.
-- Source family from sticker_source (lowercase contains): kingdom / progress bar / trail / home / pet / tournament / calendar / wheel /
--   wild / other. direct_purchase = a purchase with the same source <= 10 minutes before the sticker (validated rule, 94-98% match,
--   placebo 0-2%; claude/dice-sticker-source-vs-purchase-2026-11-02.md). It overrides the family.
-- Indirect purchase links (gameplay fuelled by bought rolls, passes) are NOT traceable per sticker: feature families are "gameplay/feature",
--   not "free".
-- Cells: all players; and non-payers in week 1 by active days (1-2 / 3-4 / 5-7) to compare like with like.
-- Output: new stickers per player by family (denominator = all players in the cell, zeros included); gap = LATE - EARLY.
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 65),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
p AS (
  SELECT u.user_id, u.album_id, MIN(u.date_dim) AS entry, LOGICAL_OR(IFNULL(u.is_excluded, FALSE)) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND u.album_id BETWEEN 57 AND 65 AND u.date_dim <= a.a_end
  GROUP BY 1, 2),
bb AS (
  SELECT p.user_id, p.album_id, p.entry,
    CASE WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 1/3 THEN 'EARLY'
         WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days > 2/3 THEN 'LATE' END AS grp
  FROM p JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p.album_id AND NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl)
    AND p.entry <= DATE_SUB(a.a_end, INTERVAL 7 DAY)),
b AS (SELECT * FROM bb WHERE grp IS NOT NULL),
gm AS (
  SELECT b.user_id, b.album_id, COUNT(*) AS act7, SUM(IFNULL(m.revenues_sum, 0)) AS rev7
  FROM b JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = b.user_id AND m.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 6 DAY)
  WHERE m.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-25'
  GROUP BY 1, 2),
st AS (
  SELECT f.user_id, f.album_id, f.sticker_collected_ts AS ts, LOWER(IFNULL(f.sticker_source, '')) AS src_raw, IFNULL(NULLIF(f.sticker_source, ''), '(none)') AS src,
    IFNULL(f.collected_from_wild, FALSE) AS wild
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` f JOIN b ON b.user_id = f.user_id AND b.album_id = f.album_id
  WHERE f.sticker_collected_date BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND f.album_id BETWEEN 57 AND 65
    AND f.sticker_collected_date BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 6 DAY)
    AND f.is_sticker_collected AND f.sticker_type IN ('common', 'golden', 'super')),
pu AS (
  SELECT DISTINCT c.user_id, c.timestamp AS ts, IFNULL(NULLIF(c.source, ''), '(none)') AS psrc
  FROM `dice-dreams-dbt.20_core.purchase_completed_vw` c
  WHERE c.pdate BETWEEN DATE '2026-03-22' AND DATE '2026-10-18' AND c.purchase_amount > 0 AND c.user_id IN (SELECT user_id FROM b)),
lk AS (
  SELECT DISTINCT st.user_id, st.album_id, st.ts, st.src
  FROM st JOIN pu ON pu.user_id = st.user_id AND pu.psrc = st.src AND pu.ts BETWEEN TIMESTAMP_SUB(st.ts, INTERVAL 600 SECOND) AND st.ts),
sf AS (
  SELECT st.user_id, st.album_id,
    CASE WHEN lk.user_id IS NOT NULL THEN 'direct_purchase' WHEN st.wild THEN 'wild'
         WHEN st.src_raw LIKE '%kingdom%' THEN 'kingdom' WHEN st.src_raw LIKE '%progress%' THEN 'progress_bar'
         WHEN st.src_raw LIKE '%trail%' THEN 'trail' WHEN st.src_raw LIKE '%home%' THEN 'home_makeover'
         WHEN st.src_raw LIKE '%pet%' THEN 'pets' WHEN st.src_raw LIKE '%tournament%' THEN 'tournament'
         WHEN st.src_raw LIKE '%calendar%' THEN 'reward_calendar' WHEN st.src_raw LIKE '%wheel%' THEN 'wheel'
         WHEN st.src_raw LIKE '%pass%' THEN 'dream_pass_track' ELSE 'other' END AS fam
  FROM st LEFT JOIN lk USING (user_id, album_id, ts, src)),
pf AS (SELECT user_id, album_id, fam, COUNT(*) AS n FROM sf GROUP BY 1, 2, 3),
cells AS (
  SELECT b.user_id, b.album_id, b.grp, 'all' AS cell FROM b
  UNION ALL
  SELECT b.user_id, b.album_id, b.grp,
    CONCAT('nonpayer_act_', CASE WHEN IFNULL(g.act7, 0) <= 2 THEN '1_2' WHEN g.act7 <= 4 THEN '3_4' ELSE '5_7' END)
  FROM b LEFT JOIN gm g USING (user_id, album_id) WHERE IFNULL(g.rev7, 0) = 0
  UNION ALL
  SELECT b.user_id, b.album_id, b.grp, CONCAT('payer_act_', CASE WHEN IFNULL(g.act7, 0) <= 4 THEN '1_4' ELSE '5_7' END)
  FROM b JOIN gm g USING (user_id, album_id) WHERE g.rev7 > 0),
cn AS (SELECT grp, cell, COUNT(*) AS players FROM cells GROUP BY 1, 2),
cf AS (
  SELECT c.grp, c.cell, pf.fam, SUM(pf.n) AS stickers
  FROM cells c JOIN pf USING (user_id, album_id) GROUP BY 1, 2, 3)
SELECT cf.cell, cf.fam,
  MAX(IF(cf.grp = 'EARLY', cn.players, NULL)) AS early_players, MAX(IF(cf.grp = 'LATE', cn.players, NULL)) AS late_players,
  ROUND(MAX(IF(cf.grp = 'EARLY', cf.stickers / cn.players, NULL)), 2) AS early_per_player,
  ROUND(MAX(IF(cf.grp = 'LATE', cf.stickers / cn.players, NULL)), 2) AS late_per_player,
  ROUND(MAX(IF(cf.grp = 'LATE', cf.stickers / cn.players, NULL)) - MAX(IF(cf.grp = 'EARLY', cf.stickers / cn.players, NULL)), 2) AS gap
FROM cf JOIN cn USING (grp, cell)
GROUP BY 1, 2 ORDER BY 1, gap DESC;
