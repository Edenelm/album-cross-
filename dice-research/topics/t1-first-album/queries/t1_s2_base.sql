-- SUPERSEDED 2026-11-03 by t1_s2_s4_core.sql: album_pop.user_album_start_date is overwritten to the close day for 25-31% of rows in 63/65 (DECISIONS C-005).
-- Topic 1 / S2: first-album players, size and revenue share. Project dice-dreams-dbt. Albums 57, 59, 61, 63, 65 (Eden D-005).
-- Population: every non-excluded player in album_pop for the album (first album event: started, sticker or pack).
-- Player type: first = no album_pop row in any earlier album; veteran = row in the previous album (id - 2); returning = earlier album but not the previous one.
-- Entry = user_album_start_date (clamped to the album window). Third = (entry - album start + 1) / album days (days incl. close day, dim_album_season).
-- Last 14 = entry date >= album end date - 14 (Eden: started in the last 14 days before close).
-- Revenue = game gross revenue (user_daily_metrics_agg.revenues_sum) on album days start..close-1; rev_from_entry = same from the entry day.
-- Payer = revenue > 0 on any album day incl. close day. Denominator = all game revenue on album days start..close-1, excluded users removed
-- (same rule as claude/first_album_finish_rate_queries.sql).
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id IN (57, 59, 61, 63, 65)),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
pop AS (
  SELECT p.album_id, p.user_id, a.a_start, a.a_end, a.n_days,
    LEAST(GREATEST(MIN(p.user_album_start_date), a.a_start), a.a_end) AS entry
  FROM `dice-dreams-dbt.30_intermediate.album_pop` p JOIN alb a USING (album_id)
  WHERE NOT IFNULL(p.is_excluded, FALSE)
  GROUP BY 1, 2, 3, 4, 5),
rev AS (
  SELECT a.album_id, m.user_id,
    SUM(IF(m.date_dim < a.a_end, IFNULL(m.revenues_sum, 0), 0)) AS rev,
    SUM(IFNULL(m.revenues_sum, 0)) AS rev_incl_close,
    ARRAY_AGG(STRUCT(m.date_dim AS d, IFNULL(m.revenues_sum, 0) AS r)) AS days
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m JOIN alb a ON m.date_dim BETWEEN a.a_start AND a.a_end
  WHERE m.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19'
  GROUP BY 1, 2),
tot AS (
  SELECT r.album_id, SUM(r.rev) AS game_rev, COUNT(*) AS game_players
  FROM rev r WHERE r.user_id NOT IN (SELECT user_id FROM excl) GROUP BY 1),
sticker AS (
  SELECT album_id, user_id FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND album_id IN (57, 59, 61, 63, 65)
  GROUP BY 1, 2),
t AS (
  SELECT p.album_id, p.user_id,
    CASE WHEN f.first_album = p.album_id THEN 'a_first' WHEN pv.user_id IS NOT NULL THEN 'c_veteran' ELSE 'b_returning' END AS ptype,
    CASE WHEN (DATE_DIFF(p.entry, p.a_start, DAY) + 1) / p.n_days <= 1/3 THEN 'T1'
         WHEN (DATE_DIFF(p.entry, p.a_start, DAY) + 1) / p.n_days <= 2/3 THEN 'T2' ELSE 'T3' END AS third,
    p.entry >= DATE_SUB(p.a_end, INTERVAL 14 DAY) AS last14,
    DATE_DIFF(p.a_end, p.entry, DAY) AS days_left,
    s.user_id IS NOT NULL AS got_sticker,
    IFNULL(r.rev, 0) AS rev, IFNULL(r.rev_incl_close, 0) > 0 AS payer,
    IFNULL((SELECT SUM(x.r) FROM UNNEST(r.days) x WHERE x.d >= p.entry AND x.d < p.a_end), 0) AS rev_from_entry
  FROM pop p
  JOIN first_alb f ON f.user_id = p.user_id
  LEFT JOIN hist pv ON pv.user_id = p.user_id AND pv.album_id = p.album_id - 2
  LEFT JOIN sticker s ON s.user_id = p.user_id AND s.album_id = p.album_id
  LEFT JOIN rev r ON r.user_id = p.user_id AND r.album_id = p.album_id
  WHERE p.user_id NOT IN (SELECT user_id FROM excl)),
pt AS (SELECT album_id, COUNT(*) AS n_pop, COUNTIF(payer) AS pay_pop FROM t GROUP BY 1)
SELECT t.album_id, ptype, third, last14,
  COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(pt.n_pop), 4) AS share_album_players,
  COUNTIF(got_sticker) AS got_sticker,
  COUNTIF(payer) AS payers, ROUND(COUNTIF(payer) / ANY_VALUE(pt.pay_pop), 4) AS share_album_payers,
  ROUND(SUM(rev)) AS rev, ROUND(SUM(rev) / ANY_VALUE(tot.game_rev), 4) AS share_game_rev,
  ROUND(SUM(rev_from_entry)) AS rev_from_entry,
  ROUND(AVG(days_left), 1) AS avg_days_left,
  ANY_VALUE(tot.game_rev) AS game_rev, ANY_VALUE(tot.game_players) AS game_players, ANY_VALUE(pt.n_pop) AS album_players
FROM t JOIN pt USING (album_id) JOIN tot USING (album_id)
GROUP BY 1, 2, 3, 4 ORDER BY 1, 2, 3, 4;
