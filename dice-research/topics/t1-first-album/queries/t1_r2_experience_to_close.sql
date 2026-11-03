-- Topic 1 reopened / R2: first-album experience from entry to close, by entry-timing group (D-010). Project dice-dreams-dbt. Albums 57-65.
-- Window = entry .. close-1 (exact exposure = D days; the close day is excluded for everyone because Dice daily rows do not update
--   stickers on the close day; close-day entrants therefore have no measurable first-album window and are shown only as a count).
-- First-album rows only (album_id = A). Rolls: user_daily_rolls_in_out (rolls_in_sum, rolls_out_sum, rolls_amount_from_purchase =
--   purchased rolls, out_of_rolls_count) and user_daily_rolls_by_source (album = source_rolls_group 'album'; wager = 'core wager').
--   Features & other = rolls_in - album - wager - purchased (floored at 0).
-- Payout (D-010): album rolls earned / own rolls spent per active day = "days of play the album rewards bought".
-- Standardised values ('std'): group metric re-weighted to the a_start mix of pre-entry cells (age x pay x kingdom x balance x activity).
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 65),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
ad AS (
  SELECT u.user_id, u.album_id, u.date_dim, u.kingdom_id_start_day AS k, IFNULL(u.packs_received_today, 0) AS packs,
    IFNULL(u.unique_stickers_today, 0) AS new_s, IFNULL(u.total_stickers_today, 0) AS all_s, IFNULL(u.sets_completed_today, 0) AS sets,
    IFNULL(u.unique_stickers_lt, 0) AS uniq_lt, u.user_album_finish_date AS fin, IFNULL(u.is_excluded, FALSE) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND u.album_id BETWEEN 57 AND 65 AND u.date_dim <= a.a_end),
p0 AS (
  SELECT user_id, album_id, ARRAY_AGG(STRUCT(date_dim AS d, k AS k) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS e, LOGICAL_OR(ex) AS ex
  FROM ad GROUP BY 1, 2),
p1 AS (SELECT user_id, album_id, e.d AS entry, e.k AS k_entry, ex FROM p0),
b AS (
  SELECT p1.user_id, p1.album_id, p1.entry, p1.k_entry, a.a_start, a.a_end, DATE_DIFF(a.a_end, p1.entry, DAY) AS dleft,
    CASE WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 29 THEN 'a_start' WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 15 THEN 'b_middle'
         WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 8 THEN 'c_late' WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 4 THEN 'd_final_week'
         WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 1 THEN 'e_last_days' ELSE 'f_close_day' END AS grp
  FROM p1 JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p1.album_id AND NOT p1.ex AND p1.user_id NOT IN (SELECT user_id FROM excl)),
alb1 AS (
  SELECT b.user_id, b.album_id, SUM(ad.packs) AS packs, SUM(ad.new_s) AS new_s, SUM(ad.all_s) AS all_s, SUM(ad.sets) AS sets,
    MAX(ad.uniq_lt) AS uniq_close, MIN(IF(ad.sets > 0, DATE_DIFF(ad.date_dim, b.entry, DAY), NULL)) AS first_set_day,
    LOGICAL_OR(ad.fin <= b.a_end) AS fin
  FROM b JOIN ad ON ad.user_id = b.user_id AND ad.album_id = b.album_id AND ad.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY)
  GROUP BY 1, 2),
gm AS (
  SELECT b.user_id, b.album_id, MIN(m.install_date) AS inst, MAX(IF(m.date_dim < b.entry, m.ltv, NULL)) AS ltv_before,
    ANY_VALUE(IF(m.date_dim = b.entry, m.rolls_startday, NULL)) AS bal_entry,
    COUNTIF(m.date_dim BETWEEN DATE_SUB(b.entry, INTERVAL 7 DAY) AND DATE_SUB(b.entry, INTERVAL 1 DAY)) AS act7_before,
    COUNTIF(m.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY)) AS act,
    SUM(IF(m.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev,
    MIN(IF(m.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY) AND IFNULL(m.revenues_sum, 0) > 0, DATE_DIFF(m.date_dim, b.entry, DAY), NULL)) AS first_pay_day,
    ARRAY_AGG(IF(m.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY), m.rolls_enday, NULL) IGNORE NULLS ORDER BY m.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_close,
    SUM(IF(m.date_dim BETWEEN b.a_start AND DATE_SUB(b.a_end, INTERVAL 1 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev_album_period
  FROM b JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = b.user_id AND m.date_dim BETWEEN DATE_SUB(b.entry, INTERVAL 60 DAY) AND b.a_end
  WHERE m.date_dim BETWEEN DATE '2026-01-22' AND DATE '2026-10-19'
  GROUP BY 1, 2),
rio AS (
  SELECT b.user_id, b.album_id, SUM(IFNULL(x.rolls_in_sum, 0)) AS r_in, SUM(IFNULL(x.rolls_out_sum, 0)) AS r_out,
    SUM(IFNULL(x.rolls_amount_from_purchase, 0)) AS r_bought, COUNTIF(IFNULL(x.out_of_rolls_count, 0) > 0) AS ooc_days
  FROM b JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out` x
    ON x.user_id = b.user_id AND x.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY)
  WHERE x.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18'
  GROUP BY 1, 2),
rbs AS (
  SELECT b.user_id, b.album_id,
    SUM(IF(s.source_rolls_group = 'album', s.rolls_value_sum, 0)) AS r_album, SUM(IF(s.source_rolls_group = 'core wager', s.rolls_value_sum, 0)) AS r_wager
  FROM b JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
    ON s.user_id = b.user_id AND s.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY)
  WHERE s.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND s.roll_type = 'rolls_in'
  GROUP BY 1, 2),
tot AS (
  SELECT SUM(IFNULL(x.revenues_sum, 0)) AS game_rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` x JOIN alb a ON x.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE x.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND x.user_id NOT IN (SELECT user_id FROM excl)),
t AS (
  SELECT b.grp, b.dleft,
    CONCAT(CASE WHEN DATE_DIFF(b.entry, g.inst, DAY) <= 2 THEN 'a' WHEN DATE_DIFF(b.entry, g.inst, DAY) <= 7 THEN 'b' WHEN DATE_DIFF(b.entry, g.inst, DAY) <= 30 THEN 'c' ELSE 'd' END,
      CASE WHEN IFNULL(g.ltv_before, 0) = 0 THEN 'a' WHEN g.ltv_before < 20 THEN 'b' ELSE 'c' END,
      CASE WHEN b.k_entry <= 4 THEN 'a' WHEN b.k_entry <= 6 THEN 'b' WHEN b.k_entry <= 9 THEN 'c' ELSE 'd' END,
      CASE WHEN g.bal_entry IS NULL THEN 'x' WHEN g.bal_entry < 50 THEN 'a' WHEN g.bal_entry < 200 THEN 'b' WHEN g.bal_entry < 1000 THEN 'c' ELSE 'd' END,
      CASE WHEN IFNULL(g.act7_before, 0) = 0 THEN 'a' WHEN g.act7_before <= 3 THEN 'b' ELSE 'c' END) AS cell,
    IFNULL(g.act, 0) AS act, IFNULL(g.rev, 0) AS rev, g.first_pay_day, g.bal_entry, g.bal_close, IFNULL(g.rev_album_period, 0) AS rev_album_period,
    IFNULL(a1.packs, 0) AS packs, IFNULL(a1.new_s, 0) AS new_s, IFNULL(a1.all_s, 0) AS all_s, IFNULL(a1.sets, 0) AS sets,
    IFNULL(a1.uniq_close, 0) AS uniq_close, a1.first_set_day, IFNULL(a1.fin, FALSE) AS fin,
    IFNULL(r.r_in, 0) AS r_in, IFNULL(r.r_out, 0) AS r_out, IFNULL(r.r_bought, 0) AS r_bought, IFNULL(r.ooc_days, 0) AS ooc_days,
    IFNULL(s.r_album, 0) AS r_album, IFNULL(s.r_wager, 0) AS r_wager,
    GREATEST(IFNULL(r.r_in, 0) - IFNULL(s.r_album, 0) - IFNULL(s.r_wager, 0) - IFNULL(r.r_bought, 0), 0) AS r_feat,
    SAFE_DIVIDE(IFNULL(s.r_album, 0), SAFE_DIVIDE(IFNULL(r.r_out, 0), NULLIF(g.act, 0))) AS payout_days
  FROM b LEFT JOIN gm g USING (user_id, album_id) LEFT JOIN alb1 a1 USING (user_id, album_id)
  LEFT JOIN rio r USING (user_id, album_id) LEFT JOIN rbs s USING (user_id, album_id)),
sw AS (SELECT cell, COUNT(*) / SUM(COUNT(*)) OVER () AS w FROM t WHERE grp = 'a_start' GROUP BY 1),
gc AS (
  SELECT grp, cell, AVG(sets) AS sets, AVG(IF(sets >= 1, 1, 0)) AS any_set, AVG(r_album) AS r_album, AVG(rev) AS rev, AVG(IF(rev > 0, 1, 0)) AS payer,
    AVG(SAFE_DIVIDE(act, GREATEST(dleft, 1))) AS act_ratio, AVG(IF(payout_days IS NULL, 0, payout_days)) AS payout_days
  FROM t WHERE grp <> 'f_close_day' GROUP BY 1, 2),
std AS (
  SELECT gc.grp, ROUND(SUM(gc.sets * sw.w) / SUM(sw.w), 2) AS std_sets, ROUND(SUM(gc.any_set * sw.w) / SUM(sw.w), 3) AS std_any_set,
    ROUND(SUM(gc.r_album * sw.w) / SUM(sw.w), 0) AS std_album_rolls, ROUND(SUM(gc.rev * sw.w) / SUM(sw.w), 2) AS std_rev,
    ROUND(SUM(gc.payer * sw.w) / SUM(sw.w), 3) AS std_payer, ROUND(SUM(gc.act_ratio * sw.w) / SUM(sw.w), 3) AS std_active_ratio,
    ROUND(SUM(gc.payout_days * sw.w) / SUM(sw.w), 2) AS std_mean_payout_days
  FROM gc JOIN sw USING (cell) GROUP BY 1)
SELECT t.grp, COUNT(*) AS players, ROUND(SUM(rev_album_period) / ANY_VALUE(tot.game_rev), 5) AS share_game_rev, ROUND(AVG(dleft), 1) AS days_left,
  ROUND(AVG(act), 2) AS active_days, ROUND(SAFE_DIVIDE(SUM(act), SUM(dleft)), 3) AS active_ratio,
  ROUND(AVG(packs), 1) AS packs, ROUND(AVG(new_s), 1) AS new_stickers, ROUND(1 - SAFE_DIVIDE(SUM(new_s), SUM(all_s)), 3) AS dup_share,
  ROUND(SAFE_DIVIDE(SUM(new_s), SUM(act)), 2) AS new_per_active_day, APPROX_QUANTILES(uniq_close, 4) AS q_stickers_close,
  ROUND(AVG(sets), 2) AS sets, ROUND(AVG(IF(sets >= 1, 1, 0)), 3) AS any_set, ROUND(AVG(IF(sets >= 4, 1, 0)), 3) AS sets4plus,
  APPROX_QUANTILES(first_set_day, 2)[OFFSET(1)] AS med_first_set_day, ROUND(AVG(IF(fin, 1, 0)), 4) AS finish_rate,
  ROUND(SAFE_DIVIDE(SUM(r_album), COUNT(*)), 0) AS album_rolls_pp, ROUND(SAFE_DIVIDE(SUM(r_feat), COUNT(*)), 0) AS feature_rolls_pp,
  ROUND(SAFE_DIVIDE(SUM(r_bought), COUNT(*)), 0) AS bought_rolls_pp, ROUND(SAFE_DIVIDE(SUM(r_wager), COUNT(*)), 0) AS wager_rolls_pp,
  ROUND(SAFE_DIVIDE(SUM(r_out), COUNT(*)), 0) AS rolls_spent_pp,
  -- Medians added after R2b: the per-player means above are driven by a few heavy players; read medians.
  APPROX_QUANTILES(r_album, 2)[OFFSET(1)] AS med_album_rolls, APPROX_QUANTILES(r_feat, 2)[OFFSET(1)] AS med_feature_rolls,
  APPROX_QUANTILES(r_out, 2)[OFFSET(1)] AS med_rolls_spent, APPROX_QUANTILES(SAFE_DIVIDE(r_out, NULLIF(act, 0)), 2)[OFFSET(1)] AS med_rolls_spent_per_active_day,
  ROUND(AVG(IF(r_album > 0, 1, 0)), 3) AS sh_any_album_rolls,
  ROUND(SAFE_DIVIDE(SUM(r_album), SUM(r_in)), 3) AS album_share_of_inflow, ROUND(SAFE_DIVIDE(SUM(r_album), SUM(r_in - r_wager)), 3) AS album_share_excl_wager,
  APPROX_QUANTILES(r_album, 10) AS dec_album_rolls, APPROX_QUANTILES(payout_days, 10) AS dec_payout_days,
  ROUND(AVG(IF(payout_days >= 1, 1, 0)), 3) AS sh_payout_1day_plus, ROUND(AVG(IF(payout_days >= 3, 1, 0)), 3) AS sh_payout_3days_plus,
  APPROX_QUANTILES(bal_entry, 2)[OFFSET(1)] AS med_bal_entry, APPROX_QUANTILES(bal_close, 2)[OFFSET(1)] AS med_bal_close,
  ROUND(SAFE_DIVIDE(SUM(ooc_days), SUM(act)), 3) AS out_of_rolls_day_share,
  ROUND(AVG(rev), 2) AS rev_pp, ROUND(SAFE_DIVIDE(SUM(rev), SUM(act)), 2) AS rev_per_active_day, ROUND(AVG(IF(rev > 0, 1, 0)), 3) AS payer_share,
  APPROX_QUANTILES(first_pay_day, 2)[OFFSET(1)] AS med_first_pay_day,
  ANY_VALUE(std.std_sets) AS std_sets, ANY_VALUE(std.std_any_set) AS std_any_set, ANY_VALUE(std.std_album_rolls) AS std_album_rolls,
  ANY_VALUE(std.std_rev) AS std_rev, ANY_VALUE(std.std_payer) AS std_payer, ANY_VALUE(std.std_active_ratio) AS std_active_ratio,
  ANY_VALUE(std.std_mean_payout_days) AS std_mean_payout_days
FROM t CROSS JOIN tot LEFT JOIN std ON std.grp = t.grp
GROUP BY 1 ORDER BY 1;
