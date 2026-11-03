-- Topic 1 / S2 (corrected) + S3 core + S4: first-album players vs veterans, albums 57-65, next album 59-67. Project dice-dreams-dbt.
-- Replaces the entry date of t1_s2_base.sql: album_pop.user_album_start_date is overwritten to the close day for 25-31% of rows
-- in albums 63/65 (rows rebuilt after close; DECISIONS C-005). Entry here = first row in user_daily_album (= its user_album_start_date
-- for every player checked), so the population = players with at least one sticker (album_pop players without a sticker = 1-4%, left out).
-- Player type: first = no album_pop row in any earlier album (album existence is not affected by the bug); veteran = row in album id - 2.
--   Returning players (earlier album but not the previous one) are left out of this query (backlog).
-- Entry band: L14 = entry >= close - 14 days (Eden); otherwise T1 / T2 / T3 by share of album days at entry (days incl. close day).
-- Album experience (entry .. close-1, daily album table): active days, new stickers (unique_stickers_lt at close-1), all stickers incl.
--   duplicates, sets, packs, Wilds received, finish (user_album_finish_date <= close date; sticker-table based), first 7 days from entry.
-- Game data (user_daily_metrics_agg; a row = an active day): revenue on album days start..close-1 (revenue share), payer incl. close day,
--   revenue and rolls from entry, roll balance at close-1, active in days 7-13 after entry (retention by days since entry, H4).
-- Next album (id + 2): fixed window = its first 14 days (album 67 started 10-19, so complete for all cohorts); full album for 59-65 only.
-- After close: active in the game on days 1-7 after the first album's close date.
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 67),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
d AS (
  SELECT u.album_id, u.user_id, u.date_dim, a.a_start, a.a_end, a.n_days,
    IFNULL(u.is_active, FALSE) AS act, IFNULL(u.spent_in_album_today, 0) AS spend,
    IFNULL(u.unique_stickers_lt, 0) AS uniq_lt, IFNULL(u.unique_stickers_today, 0) AS uniq_d, IFNULL(u.total_stickers_today, 0) AS tot_d,
    IFNULL(u.sets_completed_lt, 0) AS sets_lt, IFNULL(u.packs_received_today, 0) AS packs_d, IFNULL(u.wild_received_today, 0) AS wild_d,
    u.user_album_finish_date AS fin_date, IFNULL(u.is_excluded, FALSE) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02' AND u.album_id BETWEEN 57 AND 67 AND u.date_dim <= a.a_end),
p AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, ANY_VALUE(n_days) AS n_days,
    MIN(date_dim) AS entry, LOGICAL_OR(excl) AS excl,
    COUNTIF(act AND date_dim < a_end) AS act_days,
    MAX(IF(date_dim < a_end, uniq_lt, 0)) AS uniq_c1,
    SUM(IF(date_dim < a_end, tot_d, 0)) AS tot_c1,
    MAX(IF(date_dim < a_end, sets_lt, 0)) AS sets_c1,
    SUM(IF(date_dim < a_end, packs_d, 0)) AS packs_c1,
    SUM(IF(date_dim < a_end, wild_d, 0)) AS wilds_c1,
    MAX(fin_date) AS fin_date
  FROM d GROUP BY 1, 2),
p7 AS (
  SELECT d.album_id, d.user_id,
    SUM(d.uniq_d) AS new7, SUM(d.tot_d) AS tot7, SUM(d.packs_d) AS packs7, COUNTIF(d.act) AS act7, SUM(d.spend) AS spend7
  FROM d JOIN p USING (album_id, user_id)
  WHERE d.date_dim < DATE_ADD(p.entry, INTERVAL 7 DAY) AND d.date_dim < d.a_end
  GROUP BY 1, 2),
nx AS (
  SELECT d.album_id - 2 AS album_id, d.user_id,
    COUNTIF(d.act AND d.date_dim < DATE_ADD(d.a_start, INTERVAL 14 DAY)) AS n_act14_album,
    MAX(IF(d.date_dim < DATE_ADD(d.a_start, INTERVAL 14 DAY), d.uniq_lt, 0)) AS n_uniq14,
    LOGICAL_OR(d.fin_date <= d.a_end) AS n_fin
  FROM d WHERE d.album_id BETWEEN 59 AND 67 GROUP BY 1, 2),
base AS (
  SELECT p.*, CASE WHEN f.first_album = p.album_id THEN 'first' ELSE 'veteran' END AS ptype,
    CASE WHEN p.entry >= DATE_SUB(p.a_end, INTERVAL 14 DAY) THEN 'L14'
         WHEN (DATE_DIFF(p.entry, p.a_start, DAY) + 1) / p.n_days <= 1/3 THEN 'T1'
         WHEN (DATE_DIFF(p.entry, p.a_start, DAY) + 1) / p.n_days <= 2/3 THEN 'T2' ELSE 'T3' END AS band,
    n.a_start AS n_start, n.a_end AS n_end
  FROM p JOIN first_alb f USING (user_id)
  LEFT JOIN hist pv ON pv.user_id = p.user_id AND pv.album_id = p.album_id - 2
  JOIN alb n ON n.album_id = p.album_id + 2
  WHERE p.album_id BETWEEN 57 AND 65 AND NOT p.excl AND p.user_id NOT IN (SELECT user_id FROM excl)
    AND (f.first_album = p.album_id OR pv.user_id IS NOT NULL)),
m AS (
  SELECT b.album_id, b.user_id,
    SUM(IF(g.date_dim BETWEEN b.a_start AND DATE_SUB(b.a_end, INTERVAL 1 DAY), IFNULL(g.revenues_sum, 0), 0)) AS rev_album,
    SUM(IF(g.date_dim BETWEEN b.a_start AND b.a_end, IFNULL(g.revenues_sum, 0), 0)) AS rev_incl_close,
    SUM(IF(g.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY), IFNULL(g.revenues_sum, 0), 0)) AS rev_from_entry,
    SUM(IF(g.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY), IFNULL(g.rolls_in_sum, 0), 0)) AS rolls_in_alb,
    SUM(IF(g.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY), IFNULL(g.rolls_out_sum, 0), 0)) AS rolls_out_alb,
    MAX(IF(g.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY), g.date_dim, NULL)) AS last_act_alb,
    ARRAY_AGG(IF(g.date_dim BETWEEN b.entry AND DATE_SUB(b.a_end, INTERVAL 1 DAY), g.rolls_enday, NULL) IGNORE NULLS ORDER BY g.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS bal_last,
    COUNTIF(g.date_dim BETWEEN DATE_ADD(b.entry, INTERVAL 7 DAY) AND DATE_ADD(b.entry, INTERVAL 13 DAY)) > 0 AS act_d7_13,
    COUNTIF(g.date_dim BETWEEN DATE_ADD(b.a_end, INTERVAL 1 DAY) AND DATE_ADD(b.a_end, INTERVAL 7 DAY)) > 0 AS act_post7,
    COUNTIF(g.date_dim BETWEEN b.n_start AND DATE_ADD(b.n_start, INTERVAL 13 DAY)) AS n_game_act14,
    SUM(IF(g.date_dim BETWEEN b.n_start AND DATE_ADD(b.n_start, INTERVAL 13 DAY), IFNULL(g.revenues_sum, 0), 0)) AS n_rev14,
    SUM(IF(g.date_dim BETWEEN b.n_start AND DATE_SUB(b.n_end, INTERVAL 1 DAY), IFNULL(g.revenues_sum, 0), 0)) AS n_rev_full,
    SUM(IF(g.date_dim BETWEEN b.n_start AND DATE_ADD(b.n_start, INTERVAL 13 DAY), IFNULL(g.rolls_out_sum, 0), 0)) AS n_rolls_out14
  FROM base b JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` g
    ON g.user_id = b.user_id AND g.date_dim BETWEEN b.a_start AND LEAST(b.n_end, DATE '2026-11-02')
  WHERE g.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02'
  GROUP BY 1, 2),
t AS (
  SELECT b.album_id, b.ptype, b.band, DATE_DIFF(b.a_end, b.entry, DAY) AS days_left, b.act_days, b.uniq_c1, b.tot_c1, b.sets_c1,
    b.packs_c1, b.wilds_c1, b.fin_date <= b.a_end AS fin,
    IFNULL(p7.new7, 0) AS new7, IFNULL(p7.tot7, 0) AS tot7, IFNULL(p7.packs7, 0) AS packs7, IFNULL(p7.act7, 0) AS act7, IFNULL(p7.spend7, 0) AS spend7,
    IFNULL(m.rev_album, 0) AS rev_album, IFNULL(m.rev_incl_close, 0) > 0 AS payer, IFNULL(m.rev_from_entry, 0) AS rev_from_entry,
    IFNULL(m.rolls_in_alb, 0) AS rolls_in_alb, IFNULL(m.rolls_out_alb, 0) AS rolls_out_alb, m.bal_last,
    DATE_DIFF(m.last_act_alb, b.entry, DAY) AS last_act_day, m.last_act_alb < DATE_SUB(b.a_end, INTERVAL 7 DAY) AS stopped,
    IFNULL(m.act_d7_13, FALSE) AS act_d7_13, IFNULL(m.act_post7, FALSE) AS act_post7,
    nx.user_id IS NOT NULL AS in_next, IFNULL(nx.n_act14_album, 0) AS n_act14_album, IFNULL(nx.n_uniq14, 0) AS n_uniq14, IFNULL(nx.n_fin, FALSE) AS n_fin,
    IFNULL(m.n_game_act14, 0) AS n_game_act14, IFNULL(m.n_rev14, 0) AS n_rev14, IFNULL(m.n_rev_full, 0) AS n_rev_full, IFNULL(m.n_rolls_out14, 0) AS n_rolls_out14
  FROM base b LEFT JOIN p7 USING (album_id, user_id) LEFT JOIN m USING (album_id, user_id) LEFT JOIN nx USING (album_id, user_id)),
tot AS (
  SELECT a.album_id, SUM(IFNULL(g.revenues_sum, 0)) AS game_rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` g JOIN alb a ON g.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE g.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND a.album_id BETWEEN 57 AND 65 AND g.user_id NOT IN (SELECT user_id FROM excl)
  GROUP BY 1),
apop AS (SELECT album_id, COUNT(*) AS n_album, COUNTIF(NOT excl) AS n_album_ok FROM p WHERE album_id BETWEEN 57 AND 65 GROUP BY 1)
SELECT t.album_id, ptype, band,
  COUNT(*) AS players, ROUND(COUNT(*) / ANY_VALUE(apop.n_album_ok), 4) AS share_album_players,
  COUNTIF(payer) AS payers, ROUND(SUM(rev_album)) AS rev_album, ROUND(SUM(rev_album) / ANY_VALUE(tot.game_rev), 4) AS share_game_rev,
  ROUND(SUM(rev_from_entry)) AS rev_from_entry, ROUND(AVG(days_left), 1) AS days_left, ROUND(AVG(act_days), 1) AS act_days,
  ROUND(SAFE_DIVIDE(SUM(rev_from_entry), SUM(act_days)), 2) AS rev_per_act_day,
  ROUND(SAFE_DIVIDE(SUM(uniq_c1), SUM(act_days)), 2) AS new_per_act_day, ROUND(SAFE_DIVIDE(SUM(tot_c1), SUM(act_days)), 2) AS stickers_per_act_day,
  ROUND(SAFE_DIVIDE(SUM(packs_c1), SUM(act_days)), 2) AS packs_per_act_day, ROUND(1 - SAFE_DIVIDE(SUM(uniq_c1), SUM(tot_c1)), 3) AS dup_share,
  ROUND(AVG(uniq_c1), 1) AS avg_stickers_close, ROUND(AVG(sets_c1), 2) AS avg_sets_close, ROUND(AVG(wilds_c1), 2) AS avg_wilds,
  COUNTIF(fin) AS finishers, COUNTIF(fin AND payer) AS payer_finishers,
  ROUND(SAFE_DIVIDE(SUM(new7), SUM(act7)), 2) AS new_per_act_day_7, ROUND(1 - SAFE_DIVIDE(SUM(new7), SUM(tot7)), 3) AS dup_share_7,
  ROUND(SAFE_DIVIDE(SUM(spend7), COUNT(*)), 2) AS spend7_per_player, COUNTIF(spend7 > 0) AS payers7,
  ROUND(SAFE_DIVIDE(SUM(rolls_in_alb), SUM(act_days)), 0) AS rolls_in_per_act_day, ROUND(SAFE_DIVIDE(SUM(rolls_out_alb), SUM(act_days)), 0) AS rolls_out_per_act_day,
  ROUND(APPROX_QUANTILES(bal_last, 2)[OFFSET(1)], 0) AS med_balance_last,
  COUNTIF(stopped) AS stopped, COUNTIF(act_d7_13) AS act_d7_13, COUNTIF(act_post7) AS act_post7,
  COUNTIF(in_next) AS in_next, COUNTIF(n_game_act14 > 0) AS active_next14, ROUND(AVG(n_game_act14), 2) AS game_act_days_next14,
  ROUND(SUM(n_rev14)) AS rev_next14, COUNTIF(n_rev14 > 0) AS payers_next14, ROUND(SUM(n_rev_full)) AS rev_next_full,
  ROUND(SAFE_DIVIDE(SUM(n_rolls_out14), SUM(n_game_act14)), 0) AS rolls_out_per_act_day_next14,
  ROUND(SAFE_DIVIDE(SUM(n_uniq14), COUNTIF(in_next)), 1) AS stickers_next14_per_entrant, COUNTIF(n_fin) AS finishers_next,
  COUNTIF(payer AND n_rev14 > 0) AS payers_pay_next14,
  ANY_VALUE(tot.game_rev) AS game_rev, ANY_VALUE(apop.n_album_ok) AS album_players
FROM t JOIN tot USING (album_id) JOIN apop USING (album_id)
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;
