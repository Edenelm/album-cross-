-- Topic 1 / E1: core analysis on the ELIGIBLE population (Eden 2026-11-03, D-009). Project dice-dreams-dbt. First albums 57-65.
-- Eligible = first-album player (no earlier album_pop record, >= 1 sticker, not excluded) with entry date E <= close date C - 7,
--   so days 0-6 (E .. E+6) all fall before the close day, entirely inside the first album. No activity requirement.
-- Groups: LATE = entry in the final third of the album (by share of album days) and eligible; EARLY = entry in the first third.
-- Album attribution: first-album metrics use rows of the first album only (album_id = A); second-album metrics use album A+2 only.
-- Windows (labelled in the output):
--   w7    = days 0-6 since entry (all inside album A by construction);
--   close = entry .. C-1 (album A; close-day stickers are not updated in the Dice daily table, close-day rolls not attributed);
--   alb2  = album A+2, its days 1-14 (start date S2 .. S2+13), game activity and revenue in that calendar window;
--   d0_29 = days 0-29 since entry, game level (activity, revenue); stickers/sets split by album.
-- Rolls: album = source_rolls_group 'album' (set / album completion, Pixies); wager = 'core wager'; other = the rest (free and paid sources).
-- Revenue: game gross revenue (user_daily_metrics_agg.revenues_sum). share_game_rev = player revenue on album days A_start..C-1 /
--   all game revenue on those days (excluded users removed), pooled over the five albums. cohort_rev_share = share of the group's revenue
--   from entry to C-1.
-- Types (days 0-6, mutually exclusive, D-008 provisional thresholds): a_barely < 20 new stickers; b_collector >= 20 new and 0 sets;
--   c_steady 1-3 sets; d_rapid >= 4 sets.
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 67),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
ad AS (
  SELECT u.user_id, u.album_id, u.date_dim, IFNULL(u.packs_received_today, 0) AS packs, IFNULL(u.unique_stickers_today, 0) AS new_s,
    IFNULL(u.total_stickers_today, 0) AS all_s, IFNULL(u.sets_completed_today, 0) AS sets, IFNULL(u.unique_stickers_lt, 0) AS uniq_lt,
    u.user_album_finish_date AS fin, IFNULL(u.is_excluded, FALSE) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND u.album_id BETWEEN 57 AND 67),
p AS (
  SELECT ad.user_id, ad.album_id, MIN(ad.date_dim) AS entry, LOGICAL_OR(ad.ex) AS ex
  FROM ad JOIN alb a USING (album_id) WHERE ad.album_id BETWEEN 57 AND 65 AND ad.date_dim <= a.a_end GROUP BY 1, 2),
b AS (
  SELECT p.user_id, p.album_id, p.entry, a.a_start, a.a_end, n.a_start AS n_start, n.a_end AS n_end,
    DATE_DIFF(a.a_end, p.entry, DAY) AS days_left,
    CASE WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 1/3 THEN 'EARLY'
         WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days > 2/3 THEN 'LATE' END AS grp
  FROM p JOIN alb a USING (album_id) JOIN alb n ON n.album_id = p.album_id + 2 JOIN first_alb f USING (user_id)
  WHERE f.first_album = p.album_id AND NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl)
    AND p.entry <= DATE_SUB(a.a_end, INTERVAL 7 DAY)),
bb AS (SELECT * FROM b WHERE grp IS NOT NULL),
a1 AS (
  SELECT bb.user_id, bb.album_id,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 6 DAY), ad.packs, 0)) AS packs7,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 6 DAY), ad.new_s, 0)) AS new7,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 6 DAY), ad.all_s, 0)) AS all7,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 6 DAY), ad.sets, 0)) AS sets7,
    MAX(IF(ad.date_dim < bb.a_end, ad.uniq_lt, 0)) AS uniq_close,
    SUM(IF(ad.date_dim < bb.a_end, ad.sets, 0)) AS sets_close,
    MIN(IF(ad.sets > 0, DATE_DIFF(ad.date_dim, bb.entry, DAY), NULL)) AS first_set_day,
    MAX(IF(ad.sets > 0 AND ad.date_dim < bb.a_end, DATE_DIFF(ad.date_dim, bb.entry, DAY), NULL)) AS last_set_day,
    LOGICAL_OR(ad.fin <= bb.a_end) AS fin,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 13 DAY) AND ad.date_dim < bb.a_end, ad.new_s, 0)) AS new_a1_14,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 13 DAY) AND ad.date_dim < bb.a_end, ad.sets, 0)) AS sets_a1_14,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 29 DAY) AND ad.date_dim < bb.a_end, ad.new_s, 0)) AS new_a1_29,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 29 DAY) AND ad.date_dim < bb.a_end, ad.sets, 0)) AS sets_a1_29
  FROM bb JOIN ad ON ad.user_id = bb.user_id AND ad.album_id = bb.album_id AND ad.date_dim BETWEEN bb.entry AND bb.a_end
  GROUP BY 1, 2),
a2 AS (
  SELECT bb.user_id, bb.album_id, MIN(ad.date_dim) AS entry2,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.n_start, INTERVAL 13 DAY), ad.new_s, 0)) AS new_alb2_14d,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.n_start, INTERVAL 13 DAY), ad.sets, 0)) AS sets_alb2_14d,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 13 DAY), ad.new_s, 0)) AS new_a2_14,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 13 DAY), ad.sets, 0)) AS sets_a2_14,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 29 DAY), ad.new_s, 0)) AS new_a2_29,
    SUM(IF(ad.date_dim <= DATE_ADD(bb.entry, INTERVAL 29 DAY), ad.sets, 0)) AS sets_a2_29
  FROM bb JOIN ad ON ad.user_id = bb.user_id AND ad.album_id = bb.album_id + 2 AND ad.date_dim <= GREATEST(DATE_ADD(bb.n_start, INTERVAL 13 DAY), DATE_ADD(bb.entry, INTERVAL 29 DAY))
  GROUP BY 1, 2),
g AS (
  SELECT bb.user_id, bb.album_id,
    SUM(IF(m.date_dim BETWEEN bb.a_start AND DATE_SUB(bb.a_end, INTERVAL 1 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev_album_period,
    COUNTIF(m.date_dim BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 6 DAY)) AS act7,
    SUM(IF(m.date_dim BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 6 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev7,
    SUM(IF(m.date_dim BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 6 DAY), IFNULL(m.trx_cnt, 0), 0)) AS trx7,
    MIN(IF(IFNULL(m.revenues_sum, 0) > 0 AND m.date_dim >= bb.entry, DATE_DIFF(m.date_dim, bb.entry, DAY), NULL)) AS first_pay_day,
    ARRAY_AGG(IF(m.date_dim BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 6 DAY), m.rolls_enday, NULL) IGNORE NULLS ORDER BY m.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal7,
    COUNTIF(m.date_dim BETWEEN bb.entry AND DATE_SUB(bb.a_end, INTERVAL 1 DAY)) AS act_close,
    SUM(IF(m.date_dim BETWEEN bb.entry AND DATE_SUB(bb.a_end, INTERVAL 1 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev_close,
    COUNTIF(m.date_dim BETWEEN DATE_SUB(bb.a_end, INTERVAL 3 DAY) AND DATE_SUB(bb.a_end, INTERVAL 1 DAY)) > 0 AS act_last3,
    ARRAY_AGG(IF(m.date_dim BETWEEN bb.entry AND DATE_SUB(bb.a_end, INTERVAL 1 DAY), m.rolls_enday, NULL) IGNORE NULLS ORDER BY m.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_close,
    COUNTIF(m.date_dim BETWEEN bb.n_start AND DATE_ADD(bb.n_start, INTERVAL 13 DAY)) AS act_alb2_14d,
    SUM(IF(m.date_dim BETWEEN bb.n_start AND DATE_ADD(bb.n_start, INTERVAL 13 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev_alb2_14d,
    COUNTIF(m.date_dim BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 29 DAY)) AS act29,
    SUM(IF(m.date_dim BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 13 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev14,
    SUM(IF(m.date_dim BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 29 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev29,
    SUM(IF(m.date_dim BETWEEN DATE_ADD(bb.entry, INTERVAL 7 DAY) AND DATE_ADD(bb.entry, INTERVAL 29 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev7_29,
    COUNTIF(m.date_dim BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 13 DAY)) AS act14,
    COUNTIF(m.date_dim BETWEEN DATE_ADD(bb.entry, INTERVAL 14 DAY) AND DATE_ADD(bb.entry, INTERVAL 27 DAY)) AS act14_27,
    LOGICAL_OR(m.date_dim = DATE_ADD(bb.entry, INTERVAL 7 DAY)) AS ex7, LOGICAL_OR(m.date_dim BETWEEN DATE_ADD(bb.entry, INTERVAL 6 DAY) AND DATE_ADD(bb.entry, INTERVAL 8 DAY)) AS w7,
    LOGICAL_OR(m.date_dim = DATE_ADD(bb.entry, INTERVAL 14 DAY)) AS ex14, LOGICAL_OR(m.date_dim BETWEEN DATE_ADD(bb.entry, INTERVAL 13 DAY) AND DATE_ADD(bb.entry, INTERVAL 15 DAY)) AS w14,
    LOGICAL_OR(m.date_dim = DATE_ADD(bb.entry, INTERVAL 29 DAY)) AS ex29, LOGICAL_OR(m.date_dim BETWEEN DATE_ADD(bb.entry, INTERVAL 27 DAY) AND DATE_ADD(bb.entry, INTERVAL 29 DAY)) AS w29
  FROM bb JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = bb.user_id AND m.date_dim BETWEEN bb.a_start AND GREATEST(DATE_ADD(bb.entry, INTERVAL 29 DAY), DATE_ADD(bb.n_start, INTERVAL 13 DAY))
  WHERE m.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02'
  GROUP BY 1, 2),
r AS (
  SELECT bb.user_id, bb.album_id,
    SUM(IF(s.date_dim <= DATE_ADD(bb.entry, INTERVAL 6 DAY) AND s.roll_type = 'rolls_in' AND s.source_rolls_group = 'album', s.rolls_value_sum, 0)) AS ralb7,
    SUM(IF(s.date_dim <= DATE_ADD(bb.entry, INTERVAL 6 DAY) AND s.roll_type = 'rolls_in' AND s.source_rolls_group = 'core wager', s.rolls_value_sum, 0)) AS rwag7,
    SUM(IF(s.date_dim <= DATE_ADD(bb.entry, INTERVAL 6 DAY) AND s.roll_type = 'rolls_in' AND s.source_rolls_group NOT IN ('album', 'core wager'), s.rolls_value_sum, 0)) AS roth7,
    SUM(IF(s.date_dim <= DATE_ADD(bb.entry, INTERVAL 6 DAY) AND s.roll_type = 'rolls_out', s.rolls_value_sum, 0)) AS rout7,
    SUM(IF(s.date_dim < bb.a_end AND s.roll_type = 'rolls_in' AND s.source_rolls_group = 'album', s.rolls_value_sum, 0)) AS ralb_close,
    SUM(IF(s.date_dim < bb.a_end AND s.roll_type = 'rolls_in', s.rolls_value_sum, 0)) AS rin_close
  FROM bb JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
    ON s.user_id = bb.user_id AND s.date_dim BETWEEN bb.entry AND DATE_SUB(bb.a_end, INTERVAL 1 DAY)
  WHERE s.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18'
  GROUP BY 1, 2),
tot AS (
  SELECT SUM(IFNULL(x.revenues_sum, 0)) AS game_rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` x JOIN alb a ON x.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE x.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND a.album_id BETWEEN 57 AND 65 AND x.user_id NOT IN (SELECT user_id FROM excl)),
t AS (
  SELECT bb.grp, bb.album_id, bb.days_left,
    CASE WHEN IFNULL(a1.new7, 0) < 20 THEN 'a_barely' WHEN IFNULL(a1.sets7, 0) = 0 THEN 'b_collector' WHEN a1.sets7 <= 3 THEN 'c_steady' ELSE 'd_rapid' END AS type7,
    IFNULL(g.rev7, 0) > 0 AS payer7,
    IFNULL(a1.packs7, 0) AS packs7, IFNULL(a1.new7, 0) AS new7, IFNULL(a1.all7, 0) AS all7, IFNULL(a1.sets7, 0) AS sets7,
    IFNULL(a1.uniq_close, 0) AS uniq_close, IFNULL(a1.sets_close, 0) AS sets_close, a1.first_set_day, a1.last_set_day, IFNULL(a1.fin, FALSE) AS fin,
    IFNULL(a1.new_a1_14, 0) AS new_a1_14, IFNULL(a1.sets_a1_14, 0) AS sets_a1_14, IFNULL(a1.new_a1_29, 0) AS new_a1_29, IFNULL(a1.sets_a1_29, 0) AS sets_a1_29,
    a2.entry2 IS NOT NULL AS in_alb2, IFNULL(a2.new_alb2_14d, 0) AS new_alb2_14d, IFNULL(a2.sets_alb2_14d, 0) AS sets_alb2_14d,
    IFNULL(a2.new_a2_14, 0) AS new_a2_14, IFNULL(a2.sets_a2_14, 0) AS sets_a2_14, IFNULL(a2.new_a2_29, 0) AS new_a2_29, IFNULL(a2.sets_a2_29, 0) AS sets_a2_29,
    IFNULL(g.rev_album_period, 0) AS rev_album_period, IFNULL(g.act7, 0) AS act7, IFNULL(g.rev7, 0) AS rev7, IFNULL(g.trx7, 0) AS trx7, g.first_pay_day, g.bal7,
    IFNULL(g.act_close, 0) AS act_close, IFNULL(g.rev_close, 0) AS rev_close, IFNULL(g.act_last3, FALSE) AS act_last3, g.bal_close,
    IFNULL(g.act_alb2_14d, 0) AS act_alb2_14d, IFNULL(g.rev_alb2_14d, 0) AS rev_alb2_14d,
    IFNULL(g.act29, 0) AS act29, IFNULL(g.rev14, 0) AS rev14, IFNULL(g.rev29, 0) AS rev29, IFNULL(g.rev7_29, 0) AS rev7_29, IFNULL(g.act14, 0) AS act14, IFNULL(g.act14_27, 0) AS act14_27,
    IFNULL(g.ex7, FALSE) AS ex7, IFNULL(g.w7, FALSE) AS w7, IFNULL(g.ex14, FALSE) AS ex14, IFNULL(g.w14, FALSE) AS w14, IFNULL(g.ex29, FALSE) AS ex29, IFNULL(g.w29, FALSE) AS w29,
    DATE_ADD(bb.entry, INTERVAL 14 DAY) >= bb.a_end AS d14_in_alb2, DATE_ADD(bb.entry, INTERVAL 29 DAY) >= bb.a_end AS d29_in_alb2,
    DATE_ADD(bb.entry, INTERVAL 29 DAY) <= DATE '2026-11-02' AS ok29, DATE_ADD(bb.n_start, INTERVAL 13 DAY) <= DATE '2026-11-02' AS ok_alb2,
    IFNULL(r.ralb7, 0) AS ralb7, IFNULL(r.rwag7, 0) AS rwag7, IFNULL(r.roth7, 0) AS roth7, IFNULL(r.rout7, 0) AS rout7,
    IFNULL(r.ralb_close, 0) AS ralb_close, IFNULL(r.rin_close, 0) AS rin_close
  FROM bb LEFT JOIN a1 USING (user_id, album_id) LEFT JOIN a2 USING (user_id, album_id) LEFT JOIN g USING (user_id, album_id) LEFT JOIN r USING (user_id, album_id)),
t2 AS (SELECT t.*, PERCENT_RANK() OVER (PARTITION BY grp ORDER BY rev_close) >= 0.99 AS top1 FROM t),
gt AS (SELECT grp, SUM(rev_close) AS grp_rev_close FROM t GROUP BY 1),
agg AS (
  SELECT part, x.grp, k1, k2, COUNT(*) AS players,
    ROUND(SAFE_DIVIDE(SUM(IF(top1, rev_close, 0)), SUM(rev_close)), 3) AS top1pct_rev_share,
    ROUND(SUM(rev_album_period) / ANY_VALUE(tot.game_rev), 5) AS share_game_rev,
    ROUND(SUM(rev_close) / ANY_VALUE(gt.grp_rev_close), 4) AS cohort_rev_share,
    ROUND(AVG(days_left), 1) AS days_left,
    ROUND(AVG(act7), 2) AS act7, ROUND(AVG(packs7), 1) AS packs7, ROUND(AVG(new7), 1) AS new7, APPROX_QUANTILES(new7, 2)[OFFSET(1)] AS med_new7,
    ROUND(1 - SAFE_DIVIDE(SUM(new7), SUM(all7)), 3) AS dup7, ROUND(AVG(sets7), 2) AS sets7, ROUND(AVG(IF(sets7 >= 1, 1, 0)), 3) AS sh_set7,
    ROUND(AVG(IF(ralb7 > 0, 1, 0)), 3) AS sh_ralb7, APPROX_QUANTILES(ralb7, 2)[OFFSET(1)] AS med_ralb7, APPROX_QUANTILES(ralb7, 10)[OFFSET(9)] AS p90_ralb7,
    APPROX_QUANTILES(roth7, 2)[OFFSET(1)] AS med_roth7, APPROX_QUANTILES(rwag7, 2)[OFFSET(1)] AS med_rwag7, APPROX_QUANTILES(rout7, 2)[OFFSET(1)] AS med_rout7,
    ROUND(SAFE_DIVIDE(SUM(ralb7), SUM(ralb7 + roth7)), 3) AS album_share_rolls7_excl_wager,
    APPROX_QUANTILES(bal7, 2)[OFFSET(1)] AS med_bal7,
    ROUND(AVG(rev7), 2) AS rev7, ROUND(AVG(IF(rev7 > 0, 1, 0)), 3) AS payer7_share, ROUND(AVG(IF(rev7 > 0, trx7, NULL)), 2) AS trx7_per_payer,
    APPROX_QUANTILES(first_pay_day, 4) AS q_first_pay_day,
    ROUND(AVG(act_close), 1) AS act_close, ROUND(AVG(sets_close), 2) AS sets_close, ROUND(AVG(144 - uniq_close), 1) AS missing_close,
    APPROX_QUANTILES(uniq_close, 4) AS q_stickers_close, ROUND(AVG(IF(fin, 1, 0)), 4) AS finish_rate,
    APPROX_QUANTILES(first_set_day, 2)[OFFSET(1)] AS med_first_set_day,
    ROUND(AVG(IF(sets_close >= 2, SAFE_DIVIDE(last_set_day - first_set_day, sets_close - 1), NULL)), 2) AS avg_days_between_sets,
    APPROX_QUANTILES(ralb_close, 10)[OFFSET(9)] AS p90_ralb_close, ROUND(SAFE_DIVIDE(SUM(ralb_close), SUM(rin_close)), 4) AS album_share_rolls_close,
    APPROX_QUANTILES(bal_close, 2)[OFFSET(1)] AS med_bal_close, ROUND(AVG(IF(act_last3, 1, 0)), 3) AS active_last3,
    ROUND(AVG(rev_close), 2) AS rev_close, ROUND(AVG(IF(rev_close > 0, 1, 0)), 3) AS payer_close,
    ROUND(AVG(IF(in_alb2, 1, 0)), 3) AS in_alb2, ROUND(AVG(IF(ok_alb2, new_alb2_14d, NULL)), 1) AS new_alb2_14d, ROUND(AVG(IF(ok_alb2, sets_alb2_14d, NULL)), 2) AS sets_alb2_14d,
    ROUND(AVG(IF(ok_alb2, act_alb2_14d, NULL)), 2) AS act_alb2_14d, ROUND(AVG(IF(ok_alb2, IF(act_alb2_14d > 0, 1, 0), NULL)), 3) AS active_alb2_14d,
    ROUND(AVG(IF(ok_alb2, rev_alb2_14d, NULL)), 2) AS rev_alb2_14d, ROUND(AVG(IF(ok_alb2, IF(rev_alb2_14d > 0, 1, 0), NULL)), 3) AS payer_alb2_14d,
    COUNTIF(ok29) AS n_ok29, ROUND(AVG(IF(ok29, act29, NULL)), 2) AS act0_29, ROUND(AVG(IF(ok29, rev29, NULL)), 2) AS rev0_29,
    ROUND(AVG(IF(ok29, IF(act14_27 > 0, 1, 0), NULL)), 3) AS active14_27, ROUND(AVG(IF(ok29, rev7_29, NULL)), 2) AS rev7_29,
    ROUND(AVG(IF(ex7, 1, 0)), 3) AS exact7, ROUND(AVG(IF(w7, 1, 0)), 3) AS win6_8,
    ROUND(AVG(IF(ex14, 1, 0)), 3) AS exact14, ROUND(AVG(IF(w14, 1, 0)), 3) AS win13_15, ROUND(AVG(IF(d14_in_alb2, 1, 0)), 3) AS d14_is_alb2,
    ROUND(AVG(IF(ok29, IF(ex29, 1, 0), NULL)), 3) AS exact29, ROUND(AVG(IF(ok29, IF(w29, 1, 0), NULL)), 3) AS win27_29, ROUND(AVG(IF(ok29, IF(d29_in_alb2, 1, 0), NULL)), 3) AS d29_is_alb2
  FROM (
    SELECT 'group' AS part, 'all' AS k1, 'all' AS k2, t2.* FROM t2
    UNION ALL SELECT 'group_album', CAST(album_id AS STRING), 'all', t2.* FROM t2
    UNION ALL SELECT 'type', type7, 'all', t2.* FROM t2
    UNION ALL SELECT 'type_payer', type7, IF(payer7, 'payer7', 'nonpayer7'), t2.* FROM t2
    UNION ALL SELECT 'sets7_dist', CAST(LEAST(sets7, 8) AS STRING), 'all', t2.* FROM t2
    UNION ALL SELECT 'ralb7_dist', CASE WHEN ralb7 = 0 THEN 'a_0' WHEN ralb7 < 500 THEN 'b_1_499' WHEN ralb7 < 1000 THEN 'c_500_999'
      WHEN ralb7 < 2000 THEN 'd_1000_1999' WHEN ralb7 < 5000 THEN 'e_2000_4999' ELSE 'f_5000plus' END, 'all', t2.* FROM t2
  ) x, tot, gt WHERE gt.grp = x.grp
  GROUP BY 1, 2, 3, 4)
SELECT * FROM agg ORDER BY part, grp, k1, k2;
