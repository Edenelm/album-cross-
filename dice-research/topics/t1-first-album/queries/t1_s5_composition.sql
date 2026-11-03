-- Topic 1 / S5 bias check: are first-album players who enter early (T1) and late (L14) the same kind of player before entry?
-- Project dice-dreams-dbt. Same population and bands as t1_s2_s4_core.sql (first-album players only).
-- Install date and LTV from user_daily_metrics_agg rows in the 60 days up to entry; kingdom at entry = min kingdom_id_start_day in the album rows.
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 65),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
p AS (
  SELECT u.album_id, u.user_id, MIN(u.date_dim) AS entry, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end, ANY_VALUE(a.n_days) AS n_days,
    LOGICAL_OR(IFNULL(u.is_excluded, FALSE)) AS ex, MIN(u.kingdom_id_start_day) AS k_entry
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND u.album_id BETWEEN 57 AND 65 AND u.date_dim <= a.a_end
  GROUP BY 1, 2),
b AS (
  SELECT p.album_id, p.user_id, p.entry, p.k_entry,
    CASE WHEN p.entry >= DATE_SUB(p.a_end, INTERVAL 14 DAY) THEN 'L14'
         WHEN (DATE_DIFF(p.entry, p.a_start, DAY) + 1) / p.n_days <= 1/3 THEN 'T1'
         WHEN (DATE_DIFF(p.entry, p.a_start, DAY) + 1) / p.n_days <= 2/3 THEN 'T2' ELSE 'T3' END AS band
  FROM p JOIN first_alb f USING (user_id)
  WHERE NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl) AND f.first_album = p.album_id),
g AS (
  SELECT b.album_id, b.user_id, MIN(m.install_date) AS inst, MAX(IF(m.date_dim < b.entry, m.ltv, NULL)) AS ltv_before,
    COUNTIF(m.date_dim < b.entry) AS act_before
  FROM b JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = b.user_id AND m.date_dim BETWEEN DATE_SUB(b.entry, INTERVAL 60 DAY) AND b.entry
  WHERE m.date_dim BETWEEN DATE '2026-01-22' AND DATE '2026-10-19'
  GROUP BY 1, 2)
SELECT b.album_id, b.band, COUNT(*) AS players,
  APPROX_QUANTILES(DATE_DIFF(b.entry, g.inst, DAY), 4) AS q_days_install_to_entry,
  ROUND(COUNTIF(DATE_DIFF(b.entry, g.inst, DAY) <= 7) / COUNT(*), 3) AS share_inst_le7,
  ROUND(COUNTIF(DATE_DIFF(b.entry, g.inst, DAY) > 60) / COUNT(*), 3) AS share_inst_gt60,
  ROUND(COUNTIF(IFNULL(g.ltv_before, 0) > 0) / COUNT(*), 3) AS share_paid_before,
  APPROX_QUANTILES(b.k_entry, 2)[OFFSET(1)] AS med_kingdom_entry,
  ROUND(AVG(g.act_before), 1) AS avg_active_days_60d_before
FROM b LEFT JOIN g USING (album_id, user_id)
GROUP BY 1, 2 ORDER BY 1, 2;
