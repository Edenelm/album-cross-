-- Topic 1 reopened / R4: the same first-album cohorts in their next album (album A+2), two clocks. Project dice-dreams-dbt.
-- Cohort: first-album entrants of albums 57-65 by D-010 entry group (whole cohort kept; nobody dropped for not returning).
-- Clock 2 (next-album start): window = next start .. next start + 13 (14 days; album 67 is open, 10-19..11-01 is available).
--   Next album starts on the close day of the first album, so the wait from entry to next start = D days (36 for Start, 2 for Last days).
-- Clock 1 (time since first entry): days 0..41 since entry, across both albums; only cohorts with entry + 41 <= 2026-11-02 (flag ok1).
-- Segments: all = whole cohort; returners = has a next-album row in the 14 days; set_yes / set_no = completed >= 1 set in the first album
--   (association only: completing a set is partly the player's own engagement).
-- New payer = no payment before next start (ltv) and pays in window; repeat payer = paid before next start and pays again in window.
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 67),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
ad AS (
  SELECT u.user_id, u.album_id, u.date_dim, IFNULL(u.packs_received_today, 0) AS packs, IFNULL(u.unique_stickers_today, 0) AS new_s,
    IFNULL(u.sets_completed_today, 0) AS sets, IFNULL(u.is_excluded, FALSE) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND u.album_id BETWEEN 57 AND 67 AND u.date_dim <= a.a_end),
p1 AS (SELECT user_id, album_id, MIN(date_dim) AS entry, LOGICAL_OR(ex) AS ex FROM ad WHERE album_id <= 65 GROUP BY 1, 2),
b AS (
  SELECT p1.user_id, p1.album_id, p1.entry, a.a_end, n.a_start AS n_start,
    CASE WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 29 THEN 'a_start' WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 15 THEN 'b_middle'
         WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 8 THEN 'c_late' WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 4 THEN 'd_final_week'
         WHEN DATE_DIFF(a.a_end, p1.entry, DAY) >= 1 THEN 'e_last_days' ELSE 'f_close_day' END AS grp
  FROM p1 JOIN alb a USING (album_id) JOIN alb n ON n.album_id = p1.album_id + 2 JOIN first_alb f USING (user_id)
  WHERE f.first_album = p1.album_id AND NOT p1.ex AND p1.user_id NOT IN (SELECT user_id FROM excl)),
a1 AS (
  SELECT b.user_id, SUM(ad.sets) AS sets1
  FROM b JOIN ad ON ad.user_id = b.user_id AND ad.album_id = b.album_id AND ad.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY)
  GROUP BY 1),
a2 AS (
  SELECT b.user_id, COUNT(*) AS rows2, SUM(ad.packs) AS packs2, SUM(ad.new_s) AS new2, SUM(ad.sets) AS sets2
  FROM b JOIN ad ON ad.user_id = b.user_id AND ad.album_id = b.album_id + 2 AND ad.date_dim BETWEEN b.n_start AND DATE_ADD(b.n_start, INTERVAL 13 DAY)
  GROUP BY 1),
gm AS (
  SELECT b.user_id,
    MAX(IF(m.date_dim < b.n_start, m.ltv, NULL)) AS ltv_before_next,
    COUNTIF(m.date_dim BETWEEN b.n_start AND DATE_ADD(b.n_start, INTERVAL 13 DAY)) AS act2,
    SUM(IF(m.date_dim BETWEEN b.n_start AND DATE_ADD(b.n_start, INTERVAL 13 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev2,
    MIN(IF(m.date_dim BETWEEN b.n_start AND DATE_ADD(b.n_start, INTERVAL 13 DAY) AND IFNULL(m.revenues_sum, 0) > 0, DATE_DIFF(m.date_dim, b.n_start, DAY), NULL)) AS pay_day2,
    ARRAY_AGG(IF(m.date_dim BETWEEN b.n_start AND DATE_ADD(b.n_start, INTERVAL 13 DAY), m.rolls_startday, NULL) IGNORE NULLS ORDER BY m.date_dim LIMIT 1)[SAFE_OFFSET(0)] AS bal2,
    COUNTIF(m.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 41 DAY)) AS act_c1,
    SUM(IF(m.date_dim BETWEEN b.entry AND DATE_ADD(b.entry, INTERVAL 41 DAY), IFNULL(m.revenues_sum, 0), 0)) AS rev_c1
  FROM b JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = b.user_id AND m.date_dim BETWEEN DATE_SUB(b.entry, INTERVAL 60 DAY) AND DATE_ADD(GREATEST(b.n_start, b.entry), INTERVAL 41 DAY)
  WHERE m.date_dim BETWEEN DATE '2026-01-22' AND DATE '2026-11-02'
  GROUP BY 1),
s2 AS (
  SELECT b.user_id, SUM(s.rolls_value_sum) AS ralb2
  FROM b JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
    ON s.user_id = b.user_id AND s.date_dim BETWEEN b.n_start AND DATE_ADD(b.n_start, INTERVAL 13 DAY)
  WHERE s.date_dim BETWEEN DATE '2026-05-04' AND DATE '2026-11-01' AND s.roll_type = 'rolls_in' AND s.source_rolls_group = 'album'
  GROUP BY 1),
t AS (
  SELECT b.grp, DATE_DIFF(b.n_start, b.entry, DAY) AS wait_days, DATE_ADD(b.entry, INTERVAL 41 DAY) <= DATE '2026-11-02' AS ok1,
    IFNULL(a1.sets1, 0) AS sets1, IFNULL(a2.rows2, 0) > 0 AS ret, IFNULL(a2.packs2, 0) AS packs2, IFNULL(a2.new2, 0) AS new2,
    IFNULL(a2.sets2, 0) AS sets2, IFNULL(s2.ralb2, 0) AS ralb2, IFNULL(g.act2, 0) AS act2, IFNULL(g.rev2, 0) AS rev2, g.pay_day2, g.bal2,
    IFNULL(g.ltv_before_next, 0) > 0 AS prior_payer, IFNULL(g.act_c1, 0) AS act_c1, IFNULL(g.rev_c1, 0) AS rev_c1
  FROM b LEFT JOIN a1 USING (user_id) LEFT JOIN a2 USING (user_id) LEFT JOIN gm g USING (user_id) LEFT JOIN s2 USING (user_id)),
seg AS (
  SELECT t.*, sg FROM t, UNNEST(['all', IF(ret, 'returners', NULL), IF(sets1 >= 1, 'set_yes', 'set_no')]) sg WHERE sg IS NOT NULL)
SELECT grp, sg AS segment, COUNT(*) AS players, ROUND(AVG(wait_days), 1) AS wait_days,
  ROUND(AVG(IF(ret, 1, 0)), 3) AS in_next_album_14d, ROUND(AVG(IF(act2 > 0, 1, 0)), 3) AS active_any_14d, ROUND(AVG(act2), 2) AS active_days_14d,
  APPROX_QUANTILES(bal2, 2)[OFFSET(1)] AS med_start_balance, ROUND(AVG(packs2), 1) AS packs_14d, ROUND(AVG(new2), 1) AS new_stickers_14d,
  ROUND(SAFE_DIVIDE(SUM(new2), NULLIF(SUM(act2), 0)), 2) AS new_per_active_day, ROUND(AVG(sets2), 2) AS sets_14d, ROUND(AVG(IF(sets2 >= 1, 1, 0)), 3) AS any_set_14d,
  APPROX_QUANTILES(ralb2, 2)[OFFSET(1)] AS med_album_rolls_14d, ROUND(AVG(ralb2), 0) AS mean_album_rolls_14d,
  ROUND(AVG(rev2), 2) AS rev_14d, ROUND(AVG(IF(rev2 > 0, 1, 0)), 3) AS payer_14d, ROUND(AVG(IF(prior_payer, 1, 0)), 3) AS prior_payer_share,
  ROUND(SAFE_DIVIDE(COUNTIF(NOT prior_payer AND rev2 > 0), COUNTIF(NOT prior_payer)), 3) AS new_payer_rate,
  ROUND(SAFE_DIVIDE(COUNTIF(prior_payer AND rev2 > 0), COUNTIF(prior_payer)), 3) AS repeat_payer_rate,
  APPROX_QUANTILES(pay_day2, 2)[OFFSET(1)] AS med_first_pay_day_14d,
  COUNTIF(ok1) AS n_clock1, ROUND(AVG(IF(ok1, act_c1, NULL)), 2) AS active_days_0_41, ROUND(AVG(IF(ok1, rev_c1, NULL)), 2) AS rev_0_41,
  ROUND(AVG(IF(ok1, IF(rev_c1 > 0, 1, 0), NULL)), 3) AS payer_0_41
FROM seg GROUP BY 1, 2 ORDER BY 1, 2;
