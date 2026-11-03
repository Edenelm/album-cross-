-- Topic 1 / E4: milestones at days 6, 13 and 29 since entry (end of the first 7 / 14 / 30 days), eligible population (D-009).
-- Project dice-dreams-dbt. First albums 57-65. Cumulative from day 0 to day N inclusive.
-- part 'all'      = every eligible player whose day N has happened (follow-up available); no activity filter.
-- part 'survivor' = survivor profile: players active on any of days N-1..N+1 (window), among those with follow-up to N+1.
-- Stickers and sets are split by album: first album A (rows of album A, before its close day) and second album A+2.
-- Album rolls = source_rolls_group 'album' (cannot be split by album; dates after A's close belong to A+2).
-- Balance = rolls_enday on the last active day on or before day N. in_alb2_at_N = day N falls on or after A's close date.
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 67),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
ad AS (
  SELECT u.user_id, u.album_id, u.date_dim, IFNULL(u.unique_stickers_today, 0) AS new_s, IFNULL(u.sets_completed_today, 0) AS sets,
    IFNULL(u.is_excluded, FALSE) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND u.album_id BETWEEN 57 AND 67),
p AS (
  SELECT ad.user_id, ad.album_id, MIN(ad.date_dim) AS entry, LOGICAL_OR(ad.ex) AS ex
  FROM ad JOIN alb a USING (album_id) WHERE ad.album_id BETWEEN 57 AND 65 AND ad.date_dim <= a.a_end GROUP BY 1, 2),
bb AS (
  SELECT p.user_id, p.album_id, p.entry, a.a_end,
    CASE WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 1/3 THEN 'EARLY'
         WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days > 2/3 THEN 'LATE' END AS grp
  FROM p JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p.album_id AND NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl)
    AND p.entry <= DATE_SUB(a.a_end, INTERVAL 7 DAY)),
b AS (SELECT * FROM bb WHERE grp IS NOT NULL),
ms AS (SELECT n FROM UNNEST([6, 13, 29]) AS n),
bn AS (SELECT b.*, ms.n, DATE_ADD(b.entry, INTERVAL ms.n DAY) AS dn FROM b CROSS JOIN ms WHERE DATE_ADD(b.entry, INTERVAL ms.n + 1 DAY) <= DATE '2026-11-02'),
al AS (
  SELECT bn.user_id, bn.album_id, bn.n,
    SUM(IF(ad.album_id = bn.album_id AND ad.date_dim < bn.a_end, ad.new_s, 0)) AS new_a1, SUM(IF(ad.album_id = bn.album_id AND ad.date_dim < bn.a_end, ad.sets, 0)) AS sets_a1,
    SUM(IF(ad.album_id = bn.album_id + 2, ad.new_s, 0)) AS new_a2, SUM(IF(ad.album_id = bn.album_id + 2, ad.sets, 0)) AS sets_a2
  FROM bn JOIN ad ON ad.user_id = bn.user_id AND ad.date_dim BETWEEN bn.entry AND bn.dn AND ad.album_id IN (bn.album_id, bn.album_id + 2)
  GROUP BY 1, 2, 3),
gm AS (
  SELECT bn.user_id, bn.album_id, bn.n,
    COUNTIF(m.date_dim <= bn.dn) AS act, LOGICAL_OR(m.date_dim = bn.dn) AS act_exact,
    LOGICAL_OR(m.date_dim BETWEEN DATE_SUB(bn.dn, INTERVAL 1 DAY) AND DATE_ADD(bn.dn, INTERVAL 1 DAY)) AS act_win,
    SUM(IF(m.date_dim <= bn.dn, IFNULL(m.revenues_sum, 0), 0)) AS rev, COUNTIF(m.date_dim <= bn.dn AND IFNULL(m.revenues_sum, 0) > 0) AS pay_days,
    SUM(IF(m.date_dim <= bn.dn, IFNULL(m.trx_cnt, 0), 0)) AS trx,
    ARRAY_AGG(IF(m.date_dim <= bn.dn, m.rolls_enday, NULL) IGNORE NULLS ORDER BY m.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal
  FROM bn JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = bn.user_id AND m.date_dim BETWEEN bn.entry AND DATE_ADD(bn.dn, INTERVAL 1 DAY)
  WHERE m.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02'
  GROUP BY 1, 2, 3),
rb AS (
  SELECT bn.user_id, bn.album_id, bn.n,
    SUM(IF(s.roll_type = 'rolls_in' AND s.source_rolls_group = 'album', s.rolls_value_sum, 0)) AS ralb,
    SUM(IF(s.roll_type = 'rolls_in' AND s.source_rolls_group NOT IN ('album', 'core wager'), s.rolls_value_sum, 0)) AS roth,
    SUM(IF(s.roll_type = 'rolls_out', s.rolls_value_sum, 0)) AS rout
  FROM bn JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
    ON s.user_id = bn.user_id AND s.date_dim BETWEEN bn.entry AND bn.dn
  WHERE s.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02'
  GROUP BY 1, 2, 3),
t AS (
  SELECT bn.grp, bn.n, bn.dn >= bn.a_end AS in_alb2_at_n,
    IFNULL(al.new_a1, 0) AS new_a1, IFNULL(al.sets_a1, 0) AS sets_a1, IFNULL(al.new_a2, 0) AS new_a2, IFNULL(al.sets_a2, 0) AS sets_a2,
    IFNULL(g.act, 0) AS act, IFNULL(g.act_exact, FALSE) AS act_exact, IFNULL(g.act_win, FALSE) AS act_win, IFNULL(g.rev, 0) AS rev,
    IFNULL(g.pay_days, 0) AS pay_days, IFNULL(g.trx, 0) AS trx, g.bal,
    IFNULL(r.ralb, 0) AS ralb, IFNULL(r.roth, 0) AS roth, IFNULL(r.rout, 0) AS rout
  FROM bn LEFT JOIN al USING (user_id, album_id, n) LEFT JOIN gm g USING (user_id, album_id, n) LEFT JOIN rb r USING (user_id, album_id, n)),
u AS (SELECT 'all' AS part, t.* FROM t UNION ALL SELECT 'survivor', t.* FROM t WHERE act_win)
SELECT part, grp, n AS day, COUNT(*) AS players,
  ROUND(AVG(IF(act_exact, 1, 0)), 3) AS active_exact_day, ROUND(AVG(IF(act_win, 1, 0)), 3) AS active_window,
  ROUND(AVG(act), 2) AS active_days_cum, ROUND(AVG(IF(in_alb2_at_n, 1, 0)), 3) AS day_n_in_album2,
  APPROX_QUANTILES(new_a1, 2)[OFFSET(1)] AS med_new_album1, ROUND(AVG(sets_a1), 2) AS sets_album1, ROUND(AVG(IF(sets_a1 >= 1, 1, 0)), 3) AS sh_1set_album1,
  ROUND(AVG(new_a2), 1) AS new_album2, ROUND(AVG(sets_a2), 2) AS sets_album2,
  ROUND(AVG(IF(ralb > 0, 1, 0)), 3) AS sh_album_rolls, APPROX_QUANTILES(ralb, 10)[OFFSET(9)] AS p90_album_rolls,
  APPROX_QUANTILES(roth, 2)[OFFSET(1)] AS med_other_rolls_in, APPROX_QUANTILES(rout, 2)[OFFSET(1)] AS med_rolls_out, APPROX_QUANTILES(bal, 2)[OFFSET(1)] AS med_balance,
  ROUND(AVG(rev), 2) AS rev_cum_per_player, ROUND(AVG(IF(rev > 0, 1, 0)), 3) AS paid_by_day, ROUND(AVG(IF(pay_days >= 2, 1, 0)), 3) AS paid_on_2plus_days,
  ROUND(AVG(IF(rev > 0, trx, NULL)), 2) AS purchases_per_payer
FROM u GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;
