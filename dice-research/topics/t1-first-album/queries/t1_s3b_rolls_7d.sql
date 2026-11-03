-- Topic 1 / S3b: rolls economy in the first 7 days from entry (equal window for every entry band). Project dice-dreams-dbt. Albums 57-65.
-- Population: first-album players (all bands) and veterans who entered in the first third (reference), same rules as t1_s2_s4_core.sql.
-- Window = entry day .. entry + 6 (calendar days, not capped at close: rolls and game play continue across albums).
-- Rolls in by group (30_intermediate.user_daily_rolls_by_source): album = source_rolls_group 'album' (set / album completed, Pixies);
--   paid = source_purchase_group <> 'others' (offers, passes, DDJ); wager = 'core wager' (rolls won back while rolling); free = the rest.
-- Rolls out = roll_type 'rolls_out'. Balance = rolls_enday on the last active day in the window (user_daily_metrics_agg).
-- Medians per player (means are distorted by a few extreme players: see t1_s2_s4_core results).
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 65),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
p AS (
  SELECT u.album_id, u.user_id, MIN(u.date_dim) AS entry, ANY_VALUE(a.a_start) AS a_start, ANY_VALUE(a.a_end) AS a_end, ANY_VALUE(a.n_days) AS n_days,
    LOGICAL_OR(IFNULL(u.is_excluded, FALSE)) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND u.album_id BETWEEN 57 AND 65 AND u.date_dim <= a.a_end
  GROUP BY 1, 2),
base AS (
  SELECT p.album_id, p.user_id, p.entry, CASE WHEN f.first_album = p.album_id THEN 'first' ELSE 'veteran' END AS ptype,
    CASE WHEN p.entry >= DATE_SUB(p.a_end, INTERVAL 14 DAY) THEN 'L14'
         WHEN (DATE_DIFF(p.entry, p.a_start, DAY) + 1) / p.n_days <= 1/3 THEN 'T1'
         WHEN (DATE_DIFF(p.entry, p.a_start, DAY) + 1) / p.n_days <= 2/3 THEN 'T2' ELSE 'T3' END AS band
  FROM p JOIN first_alb f USING (user_id) LEFT JOIN hist pv ON pv.user_id = p.user_id AND pv.album_id = p.album_id - 2
  WHERE NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl) AND (f.first_album = p.album_id OR pv.user_id IS NOT NULL)),
b AS (SELECT * FROM base WHERE ptype = 'first' OR band = 'T1'),
r AS (
  SELECT b.album_id, b.user_id,
    SUM(IF(s.roll_type = 'rolls_in' AND s.source_rolls_group = 'album', s.rolls_value_sum, 0)) AS in_album,
    SUM(IF(s.roll_type = 'rolls_in' AND s.source_purchase_group <> 'others', s.rolls_value_sum, 0)) AS in_paid,
    SUM(IF(s.roll_type = 'rolls_in' AND s.source_rolls_group = 'core wager', s.rolls_value_sum, 0)) AS in_wager,
    SUM(IF(s.roll_type = 'rolls_in' AND s.source_rolls_group NOT IN ('album', 'core wager') AND s.source_purchase_group = 'others', s.rolls_value_sum, 0)) AS in_free,
    SUM(IF(s.roll_type = 'rolls_out', s.rolls_value_sum, 0)) AS out_all
  FROM b JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
    ON s.user_id = b.user_id AND s.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 6 DAY)
  WHERE s.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-25'
  GROUP BY 1, 2),
g AS (
  SELECT b.album_id, b.user_id, COUNT(*) AS act7,
    ARRAY_AGG(m.rolls_enday IGNORE NULLS ORDER BY m.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal7,
    SUM(IFNULL(m.revenues_sum, 0)) AS rev7
  FROM b JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = b.user_id AND m.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 6 DAY)
  WHERE m.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-25'
  GROUP BY 1, 2),
t AS (
  SELECT b.album_id, b.ptype, b.band, IFNULL(g.act7, 0) AS act7, g.bal7, IFNULL(g.rev7, 0) AS rev7,
    IFNULL(r.in_album, 0) AS in_album, IFNULL(r.in_paid, 0) AS in_paid, IFNULL(r.in_wager, 0) AS in_wager, IFNULL(r.in_free, 0) AS in_free,
    IFNULL(r.out_all, 0) AS out_all
  FROM b LEFT JOIN r USING (album_id, user_id) LEFT JOIN g USING (album_id, user_id))
SELECT album_id, ptype, band, COUNT(*) AS players, ROUND(AVG(act7), 2) AS act_days7,
  APPROX_QUANTILES(in_album, 2)[OFFSET(1)] AS med_in_album, APPROX_QUANTILES(in_free, 2)[OFFSET(1)] AS med_in_free,
  APPROX_QUANTILES(in_wager, 2)[OFFSET(1)] AS med_in_wager, APPROX_QUANTILES(in_paid, 2)[OFFSET(1)] AS med_in_paid,
  APPROX_QUANTILES(out_all, 2)[OFFSET(1)] AS med_out, APPROX_QUANTILES(bal7, 2)[OFFSET(1)] AS med_balance7,
  ROUND(AVG(IF(in_album + in_free + in_wager + in_paid > 0, in_album / (in_album + in_free + in_wager + in_paid), NULL)), 3) AS avg_album_share_in,
  ROUND(AVG(IF(in_album + in_free + in_paid > 0, in_album / (in_album + in_free + in_paid), NULL)), 3) AS avg_album_share_in_excl_wager,
  COUNTIF(in_paid > 0) AS with_paid_rolls, ROUND(AVG(rev7), 2) AS rev7_per_player, COUNTIF(rev7 > 0) AS payers7
FROM t GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;
