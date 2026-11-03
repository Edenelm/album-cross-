-- Topic 1 / J1: day-by-day journey from first exposure, days 0-29 since entry. Project dice-dreams-dbt. First albums 57-65.
-- Population: first-album players (no earlier album record, >= 1 sticker, not excluded), entry = first row in user_daily_album (C-005).
-- Groups: T1 = entered in the first third; L14 split by days left at entry (album end date - entry): 0-2 / 3-6 / 7-10 / 11-14.
-- Day d = entry + d. A player counts on day d only if that date <= 2026-11-02 (follow-up available) -> n_avail. No survivor filter.
-- Album rows (any album 57-67, so the next album counts too): packs, new stickers, all stickers, sets completed.
-- Game rows (user_daily_metrics_agg; a row = an active day): active, revenue, roll balance at end of day (last known, carried forward).
-- Rolls (user_daily_rolls_by_source): album = source_rolls_group 'album'; all rolls in; rolls out.
-- Next album: crossed = has a row in album id + 2 on or before day d.
-- Medians / percentiles are of cumulative per-player values on day d; revenue is a mean (whole $ per available player).
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 67),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
ad AS (
  SELECT u.user_id, u.album_id, u.date_dim, IFNULL(u.packs_received_today, 0) AS packs, IFNULL(u.unique_stickers_today, 0) AS new_s,
    IFNULL(u.total_stickers_today, 0) AS all_s, IFNULL(u.sets_completed_today, 0) AS sets, IFNULL(u.is_excluded, FALSE) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND u.album_id BETWEEN 57 AND 67),
p AS (
  SELECT ad.user_id, ad.album_id, MIN(ad.date_dim) AS entry, LOGICAL_OR(ad.ex) AS ex
  FROM ad JOIN alb a USING (album_id) WHERE ad.album_id BETWEEN 57 AND 65 AND ad.date_dim <= a.a_end GROUP BY 1, 2),
pop AS (
  SELECT p.user_id, p.album_id, p.entry, a.a_end,
    CASE WHEN p.entry >= DATE_SUB(a.a_end, INTERVAL 14 DAY) THEN
           CASE WHEN DATE_DIFF(a.a_end, p.entry, DAY) <= 2 THEN 'L14_0_2' WHEN DATE_DIFF(a.a_end, p.entry, DAY) <= 6 THEN 'L14_3_6'
                WHEN DATE_DIFF(a.a_end, p.entry, DAY) <= 10 THEN 'L14_7_10' ELSE 'L14_11_14' END
         WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 1/3 THEN 'T1' ELSE 'other' END AS grp
  FROM p JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p.album_id AND NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl)),
pp AS (SELECT * FROM pop WHERE grp <> 'other'),
nxt AS (SELECT ad.user_id, ad.album_id - 2 AS album_id, MIN(ad.date_dim) AS next_entry FROM ad JOIN pp USING (user_id) WHERE ad.album_id = pp.album_id + 2 GROUP BY 1, 2),
spine AS (
  SELECT pp.user_id, pp.album_id, pp.grp, d, DATE_ADD(pp.entry, INTERVAL d DAY) AS dt, nxt.next_entry
  FROM pp LEFT JOIN nxt USING (user_id, album_id), UNNEST(GENERATE_ARRAY(0, 29)) AS d
  WHERE DATE_ADD(pp.entry, INTERVAL d DAY) <= DATE '2026-11-02'),
adu AS (SELECT user_id, date_dim, SUM(packs) AS packs, SUM(new_s) AS new_s, SUM(all_s) AS all_s, SUM(sets) AS sets FROM ad GROUP BY 1, 2),
gm AS (
  SELECT m.user_id, m.date_dim, IFNULL(m.revenues_sum, 0) AS rev, m.rolls_enday
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
  WHERE m.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND m.user_id IN (SELECT user_id FROM pp)),
rb AS (
  SELECT s.user_id, s.date_dim,
    SUM(IF(s.roll_type = 'rolls_in' AND s.source_rolls_group = 'album', s.rolls_value_sum, 0)) AS r_album,
    SUM(IF(s.roll_type = 'rolls_in', s.rolls_value_sum, 0)) AS r_in,
    SUM(IF(s.roll_type = 'rolls_out', s.rolls_value_sum, 0)) AS r_out
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
  WHERE s.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND s.user_id IN (SELECT user_id FROM pp)
  GROUP BY 1, 2),
x AS (
  SELECT s.grp, s.d, s.user_id, s.album_id,
    g.user_id IS NOT NULL AS act, IFNULL(g.rev, 0) AS rev,
    IFNULL(a.packs, 0) AS packs, IFNULL(a.new_s, 0) AS new_s, IFNULL(a.all_s, 0) AS all_s, IFNULL(a.sets, 0) AS sets,
    IFNULL(r.r_album, 0) AS r_album, IFNULL(r.r_in, 0) AS r_in, IFNULL(r.r_out, 0) AS r_out,
    s.next_entry IS NOT NULL AND s.next_entry <= s.dt AS crossed,
    LAST_VALUE(g.rolls_enday IGNORE NULLS) OVER w AS bal
  FROM spine s LEFT JOIN gm g ON g.user_id = s.user_id AND g.date_dim = s.dt
  LEFT JOIN adu a ON a.user_id = s.user_id AND a.date_dim = s.dt
  LEFT JOIN rb r ON r.user_id = s.user_id AND r.date_dim = s.dt
  WINDOW w AS (PARTITION BY s.user_id, s.album_id ORDER BY s.d ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)),
c AS (
  SELECT *,
    SUM(IF(act, 1, 0)) OVER w AS c_act, SUM(rev) OVER w AS c_rev, SUM(packs) OVER w AS c_packs, SUM(new_s) OVER w AS c_new,
    SUM(all_s) OVER w AS c_all, SUM(sets) OVER w AS c_sets, SUM(r_album) OVER w AS c_ralb, SUM(r_in) OVER w AS c_rin, SUM(r_out) OVER w AS c_rout
  FROM x WINDOW w AS (PARTITION BY user_id, album_id ORDER BY d ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
SELECT grp, d, COUNT(*) AS n_avail,
  ROUND(AVG(IF(act, 1, 0)), 3) AS active_share, ROUND(AVG(c_act), 2) AS cum_active_days,
  ROUND(AVG(IF(act, packs, NULL)), 1) AS packs_per_active, ROUND(AVG(IF(act, new_s, NULL)), 1) AS new_per_active,
  ROUND(1 - SAFE_DIVIDE(SUM(new_s), SUM(all_s)), 3) AS dup_share_day,
  APPROX_QUANTILES(c_new, 2)[OFFSET(1)] AS med_cum_new, ROUND(AVG(c_sets), 2) AS avg_cum_sets, ROUND(AVG(IF(c_sets >= 1, 1, 0)), 3) AS share_1plus_set,
  ROUND(AVG(IF(c_ralb > 0, 1, 0)), 3) AS share_album_rolls, APPROX_QUANTILES(c_ralb, 10)[OFFSET(9)] AS p90_cum_album_rolls,
  APPROX_QUANTILES(c_rin, 2)[OFFSET(1)] AS med_cum_rolls_in, APPROX_QUANTILES(c_rout, 2)[OFFSET(1)] AS med_cum_rolls_out,
  APPROX_QUANTILES(bal, 2)[OFFSET(1)] AS med_balance,
  ROUND(AVG(rev), 3) AS rev_day_per_player, ROUND(AVG(c_rev), 2) AS cum_rev_per_player, ROUND(AVG(IF(c_rev > 0, 1, 0)), 3) AS share_paid_by_day,
  ROUND(AVG(IF(crossed, 1, 0)), 3) AS share_in_next_album
FROM c GROUP BY 1, 2 ORDER BY 1, 2;
