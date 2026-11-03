-- Topic 1 / E2: are late entrants' extra new stickers per pack a matter of pack source, collection size, or pack content? Project dice-dreams-dbt.
-- Eligible population (D-009), days 0-6 since entry, packs of the FIRST album only (album_id = A), from the pack-received event
-- (10_staging.stg_album_pack_received_vw; receipt only, opening is not logged). Collection before the pack = unique_stickers (event field,
-- read as the count after the pack) - number_of_new_stickers. progression_balance_factor_value_* and probability_factor_on_* are event fields
-- whose meaning is not documented (event doc status "Investigate"); they are shown as observed values only.
-- Result: results/t1_e2_packs_equal_collection_2026-11-03.csv (key rows). Scan ≈112 GB.
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
pk AS (
  SELECT k.user_id AS uid, k.pdate, k.album_id AS aid,
    CASE WHEN LOWER(k.source) IN ('new kingdom', 'progress bar v2', 'trail – chest', 'home_makeover', 'pets feature', 'rewardcalendar', 'tournament - chest', 'tournament - final reward') THEN LOWER(k.source) ELSE 'other' END AS src,
    IFNULL(k.total_stickers_in_pack, 0) AS n_st, IFNULL(k.number_of_new_stickers, 0) AS n_new,
    k.unique_stickers AS uniq_after, k.probability_factor_on_golden AS pf_g, k.probability_factor_on_super AS pf_s,
    k.progression_balance_factor_value_golden AS pb_g, k.progression_balance_factor_value_super AS pb_s,
    IFNULL(k.is_pity_counter_triggered, FALSE) AS pity, IFNULL(k.is_given_in_restart, FALSE) AS restart
  FROM `dice-dreams-dbt.10_staging.stg_album_pack_received_vw` k
  WHERE k.pdate BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND k.album_id BETWEEN 57 AND 65),
j AS (
  SELECT bb.grp, bb.user_id, pk.src, pk.n_st, pk.n_new, pk.pf_g, pk.pf_s, pk.pb_g, pk.pb_s, pk.pity, pk.restart,
    CASE WHEN pk.uniq_after IS NULL THEN 'x_unknown' WHEN pk.uniq_after - pk.n_new < 25 THEN 'a_0_24' WHEN pk.uniq_after - pk.n_new < 50 THEN 'b_25_49'
         WHEN pk.uniq_after - pk.n_new < 75 THEN 'c_50_74' WHEN pk.uniq_after - pk.n_new < 100 THEN 'd_75_99' ELSE 'e_100plus' END AS coll
  FROM bb JOIN pk ON pk.uid = bb.user_id AND pk.aid = bb.album_id AND pk.pdate BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 6 DAY)
  WHERE bb.grp IS NOT NULL)
SELECT grp, 'all' AS src, coll, COUNT(*) AS packs, COUNT(DISTINCT user_id) AS users,
  ROUND(AVG(n_st), 2) AS stickers_per_pack, ROUND(AVG(n_new), 2) AS new_per_pack,
  ROUND(AVG(pf_g), 3) AS pf_golden, ROUND(AVG(pf_s), 3) AS pf_super, ROUND(AVG(pb_g), 3) AS pb_golden, ROUND(AVG(pb_s), 3) AS pb_super,
  ROUND(AVG(IF(pity, 1, 0)), 4) AS pity_share, ROUND(AVG(IF(restart, 1, 0)), 4) AS restart_share
FROM j GROUP BY 1, 2, 3
UNION ALL
SELECT grp, src, 'all', COUNT(*), COUNT(DISTINCT user_id), ROUND(AVG(n_st), 2), ROUND(AVG(n_new), 2),
  ROUND(AVG(pf_g), 3), ROUND(AVG(pf_s), 3), ROUND(AVG(pb_g), 3), ROUND(AVG(pb_s), 3), ROUND(AVG(IF(pity, 1, 0)), 4), ROUND(AVG(IF(restart, 1, 0)), 4)
FROM j GROUP BY 1, 2, 3
UNION ALL
SELECT grp, src, coll, COUNT(*), COUNT(DISTINCT user_id), ROUND(AVG(n_st), 2), ROUND(AVG(n_new), 2),
  ROUND(AVG(pf_g), 3), ROUND(AVG(pf_s), 3), ROUND(AVG(pb_g), 3), ROUND(AVG(pb_s), 3), ROUND(AVG(IF(pity, 1, 0)), 4), ROUND(AVG(IF(restart, 1, 0)), 4)
FROM j WHERE src IN ('new kingdom', 'progress bar v2', 'trail – chest') GROUP BY 1, 2, 3
ORDER BY 2, 3, 1;
