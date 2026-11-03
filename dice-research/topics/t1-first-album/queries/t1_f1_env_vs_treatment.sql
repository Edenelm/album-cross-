-- Topic 1 / F1: is the extra pack content a late-entry treatment or an end-of-album environment? Project dice-dreams-dbt. Albums 57-65.
-- Groups (first album A): EARLY / LATE eligible first-album entrants (D-009); VET = veterans (record in album A-2) who entered in the first
--   third, 10% sample by FARM_FINGERPRINT(user_id).
-- Packs of album A only (pack-received event; receipt). Calendar segment of the pack date: first third / middle / last third of album A.
-- Collection before the pack = unique_stickers - number_of_new_stickers (event fields). Same collection bucket + same calendar segment:
--   if early entrants and veterans in the last third get the same new-per-pack as late entrants, it is the environment; if only late
--   entrants get more, it is tied to the late entrant (treatment / progress-relative balancing).
-- Also pre-entry profile (install age, prior payer, kingdom at entry) for EARLY / LATE.
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 65),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
p AS (
  SELECT u.user_id, u.album_id, MIN(u.date_dim) AS entry, LOGICAL_OR(IFNULL(u.is_excluded, FALSE)) AS ex, MIN(u.kingdom_id_start_day) AS k_entry
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND u.album_id BETWEEN 57 AND 65 AND u.date_dim <= a.a_end
  GROUP BY 1, 2),
g AS (
  SELECT p.user_id, p.album_id, p.entry, p.k_entry, a.a_start, a.a_end, a.n_days,
    CASE WHEN f.first_album = p.album_id AND p.entry <= DATE_SUB(a.a_end, INTERVAL 7 DAY) AND (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 1/3 THEN 'EARLY'
         WHEN f.first_album = p.album_id AND p.entry <= DATE_SUB(a.a_end, INTERVAL 7 DAY) AND (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days > 2/3 THEN 'LATE'
         WHEN f.first_album < p.album_id AND pv.user_id IS NOT NULL AND (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 1/3
              AND MOD(ABS(FARM_FINGERPRINT(p.user_id)), 10) = 0 THEN 'VET' END AS grp
  FROM p JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  LEFT JOIN hist pv ON pv.user_id = p.user_id AND pv.album_id = p.album_id - 2
  WHERE NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl)),
gg AS (SELECT * FROM g WHERE grp IS NOT NULL),
pk AS (
  SELECT k.user_id AS uid, k.pdate, k.album_id AS aid, IFNULL(k.number_of_new_stickers, 0) AS n_new, IFNULL(k.total_stickers_in_pack, 0) AS n_st,
    k.unique_stickers AS uniq_after, k.progression_balance_factor_value_golden AS pb_g
  FROM `dice-dreams-dbt.10_staging.stg_album_pack_received_vw` k
  WHERE k.pdate BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND k.album_id BETWEEN 57 AND 65),
j AS (
  SELECT gg.grp,
    CASE WHEN (DATE_DIFF(pk.pdate, gg.a_start, DAY) + 1) / gg.n_days <= 1/3 THEN 'cal_1_first' WHEN (DATE_DIFF(pk.pdate, gg.a_start, DAY) + 1) / gg.n_days <= 2/3 THEN 'cal_2_mid' ELSE 'cal_3_last' END AS cal,
    CASE WHEN pk.uniq_after - pk.n_new < 25 THEN 'a_0_24' WHEN pk.uniq_after - pk.n_new < 50 THEN 'b_25_49' WHEN pk.uniq_after - pk.n_new < 75 THEN 'c_50_74'
         WHEN pk.uniq_after - pk.n_new < 100 THEN 'd_75_99' WHEN pk.uniq_after - pk.n_new < 125 THEN 'e_100_124' ELSE 'f_125plus' END AS coll,
    pk.n_new, pk.n_st, pk.pb_g, gg.user_id
  FROM gg JOIN pk ON pk.uid = gg.user_id AND pk.aid = gg.album_id AND pk.pdate BETWEEN gg.entry AND DATE_SUB(gg.a_end, INTERVAL 1 DAY)
  WHERE pk.uniq_after IS NOT NULL),
prof AS (
  SELECT gg.grp, gg.user_id, gg.entry, gg.k_entry, MIN(m.install_date) AS inst, MAX(IF(m.date_dim < gg.entry, m.ltv, NULL)) AS ltv_before,
    COUNTIF(m.date_dim < gg.entry) AS act_before
  FROM gg JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = gg.user_id AND m.date_dim BETWEEN DATE_SUB(gg.entry, INTERVAL 60 DAY) AND gg.entry
  WHERE m.date_dim BETWEEN DATE '2026-01-22' AND DATE '2026-10-19' AND gg.grp IN ('EARLY', 'LATE')
  GROUP BY 1, 2, 3, 4)
SELECT 'packs' AS part, grp, cal, coll, COUNT(*) AS packs, COUNT(DISTINCT user_id) AS users,
  ROUND(AVG(n_new), 3) AS new_per_pack, ROUND(AVG(n_st), 2) AS stickers_per_pack, ROUND(AVG(pb_g), 3) AS pb_golden,
  CAST(NULL AS FLOAT64) AS med_days_install_to_entry, CAST(NULL AS FLOAT64) AS share_paid_before, CAST(NULL AS FLOAT64) AS med_kingdom_entry, CAST(NULL AS FLOAT64) AS avg_act_60d_before
FROM j GROUP BY 1, 2, 3, 4
UNION ALL
SELECT 'profile', grp, 'pre_entry', 'all', COUNT(*), COUNT(DISTINCT user_id), NULL, NULL, NULL,
  APPROX_QUANTILES(DATE_DIFF(entry, inst, DAY), 2)[OFFSET(1)], ROUND(AVG(IF(IFNULL(ltv_before, 0) > 0, 1, 0)), 3),
  APPROX_QUANTILES(k_entry, 2)[OFFSET(1)], ROUND(AVG(act_before), 2)
FROM prof GROUP BY 1, 2, 3, 4
ORDER BY 1, 4, 3, 2;
