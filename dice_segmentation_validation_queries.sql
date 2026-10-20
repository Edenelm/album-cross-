-- Dice segmentation validation queries (2026-10-14). Project dice-dreams-dbt. Albums 61/63.

-- Seg1 (2026-10-14) Dice: pre-assigned album segment vs actual spend in the album. Project dice-dreams-dbt. Albums 61/63.
-- Actual spend normalized like the segment rule: spend x 70 / (album days - 1); close day excluded.
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-07-27' AS a_end, 35 AS n_days UNION ALL
  SELECT 63, DATE '2026-09-07', 42),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.n_days, a.album_login_ratio, a.album_segment_code,
    a.user_past_album_count, IFNULL(a.is_album_pu, FALSE) AS is_pu, IFNULL(a.spent_in_album_today, 0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
usr AS (
  SELECT album_id, user_id,
    ARRAY_AGG(album_segment_code IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg_assigned,
    MIN(user_past_album_count) AS past_albums, LOGICAL_OR(is_pu) AS is_pu,
    SUM(spend) * 70 / ANY_VALUE(n_days) AS adj_spend
  FROM r GROUP BY 1, 2
  HAVING ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
b AS (
  SELECT album_id, user_id, seg_assigned, IF(is_pu, 'payer', 'non_payer') AS payer, adj_spend, CASE WHEN adj_spend >= 1000 THEN 4 WHEN adj_spend >= 400 THEN 3 WHEN adj_spend >= 100 THEN 2 ELSE 1 END AS seg_actual
  FROM usr WHERE IFNULL(past_albums, 0) > 0)       -- not first album (first album = Easy by default)
SELECT album_id, payer, seg_assigned, seg_actual,
  COUNT(*) AS players,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY album_id, payer, seg_assigned), 3) AS share_of_assigned,
  ROUND(APPROX_QUANTILES(adj_spend, 100)[OFFSET(50)], 0) AS p50_adj_spend
FROM b GROUP BY 1, 2, 3, 4 ORDER BY 1, 2, 3, 4
;

-- Seg2 (2026-10-14) Dice: expected spend curve vs actual cumulative share of album spend, by assigned difficulty. Project dice-dreams-dbt.
-- Day d = date_dim - album start date (0-based). Checkpoint p -> last full day d = CEIL(p*n)-1, curve at x = (d+1)*77/n.
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end, 35 AS n_days UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07', 42),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.n_days, DATE_DIFF(a.date_dim, alb.a_start, DAY) AS d,
    a.album_login_ratio, a.album_segment_code, a.user_past_album_count,
    IFNULL(a.is_album_pu, FALSE) AS is_pu, IFNULL(a.spent_in_album_today, 0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
usr AS (
  SELECT album_id, user_id, ANY_VALUE(n_days) AS n_days,
    ARRAY_AGG(album_segment_code IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg,
    SUM(spend) AS total
  FROM r GROUP BY 1, 2
  HAVING LOGICAL_OR(is_pu) AND MIN(user_past_album_count) > 0 AND SUM(spend) > 0
     AND ARRAY_AGG(album_login_ratio ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] >= 0.5),
cp AS (SELECT p FROM UNNEST([0.10, 0.25, 0.50, 0.75, 0.90, 1.00]) AS p),
ucp AS (  -- cumulative spend per player through the checkpoint day
  SELECT u.album_id, u.user_id, u.seg, u.n_days, u.total, c.p,
    CAST(CEIL(c.p * u.n_days) AS INT64) - 1 AS d_cp,
    SUM(IF(r.d <= CAST(CEIL(c.p * u.n_days) AS INT64) - 1, r.spend, 0)) AS cum
  FROM usr u CROSS JOIN cp c JOIN r USING (album_id, user_id)
  GROUP BY 1, 2, 3, 4, 5, 6, 7),
agg AS (
  SELECT album_id, seg, p, ANY_VALUE(d_cp) AS d_cp, ANY_VALUE(n_days) AS n_days, COUNT(*) AS payers,
    SUM(cum) / SUM(total) AS actual_pooled,
    APPROX_QUANTILES(cum / total, 100)[OFFSET(50)] AS actual_p50
  FROM ucp GROUP BY 1, 2, 3),
cv AS (
  SELECT album_id, seg, p, payers, actual_pooled, actual_p50,
    (d_cp + 1) * 77 / n_days AS x
  FROM agg),
cv2 AS (
  SELECT album_id, seg, p, payers, actual_pooled, actual_p50,
    CASE seg
      WHEN 1 THEN 0.000000018*POW(x,4) - 0.000002*POW(x,3) + 0.000202*POW(x,2) + 0.0014*x + 0.0016
      WHEN 2 THEN 0.0000000185*POW(x,4) - 0.000002*POW(x,3) + 0.0001*POW(x,2) + 0.0088*x + 0.01
      ELSE 0.0000006*POW(x,3) - 0.00005*POW(x,2) + 0.0135*x + 0.0041 END AS curve
  FROM cv)
SELECT album_id, seg, MAX(payers) AS payers,
  ROUND(MAX(IF(p = 0.10, actual_pooled, NULL)), 3) AS act_10, ROUND(MAX(IF(p = 0.10, curve, NULL)), 3) AS crv_10,
  ROUND(MAX(IF(p = 0.25, actual_pooled, NULL)), 3) AS act_25, ROUND(MAX(IF(p = 0.25, curve, NULL)), 3) AS crv_25,
  ROUND(MAX(IF(p = 0.50, actual_pooled, NULL)), 3) AS act_50, ROUND(MAX(IF(p = 0.50, curve, NULL)), 3) AS crv_50,
  ROUND(MAX(IF(p = 0.75, actual_pooled, NULL)), 3) AS act_75, ROUND(MAX(IF(p = 0.75, curve, NULL)), 3) AS crv_75,
  ROUND(MAX(IF(p = 0.90, actual_pooled, NULL)), 3) AS act_90, ROUND(MAX(IF(p = 0.90, curve, NULL)), 3) AS crv_90,
  ROUND(MAX(IF(p = 1.00, curve, NULL)), 3) AS crv_100,
  ROUND(MAX(IF(p = 0.50, actual_p50, NULL)), 3) AS p50_player_50,
  ROUND(MAX(IF(p = 0.75, actual_p50, NULL)), 3) AS p50_player_75
FROM cv2 GROUP BY 1, 2 ORDER BY 1, 2
;

-- Seg3 (2026-10-14) Dice: super segment at last-quarter start — original curve vs corrected curve. Project dice-dreams-dbt.
-- Day d = CEIL(0.75*n) (61: 27 = 2026-07-19; 63: 32 = 2026-08-28). x = d*77/n (as in the live query). threshold = curve * budget * n/77.
-- Spend: through end of day d-1 (main) and through end of day d (check vs stored code).
-- Corrected curve = actual pooled share at 75% from the OTHER album (step 2): 61 uses 63's, 63 uses 61's.
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, 35 AS n_days, 27 AS d_q UNION ALL
  SELECT 63, DATE '2026-07-27', 42, 32),
fix AS (  -- corrected curve value at the checkpoint (cross-album)
  SELECT 61 AS album_id, 1 AS seg, 0.715 AS c_fix UNION ALL SELECT 61, 2, 0.740 UNION ALL SELECT 61, 3, 0.753 UNION ALL SELECT 61, 4, 0.766 UNION ALL
  SELECT 63, 1, 0.734 UNION ALL SELECT 63, 2, 0.765 UNION ALL SELECT 63, 3, 0.776 UNION ALL SELECT 63, 4, 0.779),
bud AS (
  SELECT 1 AS seg, 100 AS b0, 300 AS b1, 600 AS b2, 1000 AS b3 UNION ALL
  SELECT 2, 200, 400, 700, 1200 UNION ALL SELECT 3, 400, 700, 1000, 2000 UNION ALL SELECT 4, 700, 1500, 2500, 6000),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.n_days, alb.d_q AS dq,
    DATE_DIFF(a.date_dim, alb.a_start, DAY) < alb.d_q AS is_prev,
    DATE_DIFF(a.date_dim, alb.a_start, DAY) = alb.d_q AS is_q,
    a.album_login_ratio, a.album_segment_code, a.user_past_album_count, a.album_super_segment_code,
    IFNULL(a.spent_in_album_today, 0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-08-28' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE
    AND DATE_DIFF(a.date_dim, alb.a_start, DAY) <= alb.d_q),
u AS (
  SELECT album_id, user_id, ANY_VALUE(n_days) AS n_days, ANY_VALUE(dq) AS d_q,
    ARRAY_AGG(album_segment_code IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg,
    SUM(IF(is_prev, spend, 0)) AS cum_prev, SUM(spend) AS cum_incl,
    MAX(IF(is_q, album_super_segment_code, NULL)) AS stored,
    MAX(IF(is_q, album_login_ratio, NULL)) AS lr_q, MIN(user_past_album_count) AS past
  FROM r GROUP BY 1, 2
  HAVING LOGICAL_OR(is_q)),                                -- has a row on the checkpoint day
c AS (
  SELECT u.album_id, u.user_id, u.seg, u.cum_prev, u.cum_incl, u.stored, b.b0, b.b1, b.b2, b.b3,
    u.n_days / 77 AS scale, f.c_fix,
    CASE u.seg
      WHEN 1 THEN 0.000000018*POW(x,4) - 0.000002*POW(x,3) + 0.000202*POW(x,2) + 0.0014*x + 0.0016
      WHEN 2 THEN 0.0000000185*POW(x,4) - 0.000002*POW(x,3) + 0.0001*POW(x,2) + 0.0088*x + 0.01
      ELSE 0.0000006*POW(x,3) - 0.00005*POW(x,2) + 0.0135*x + 0.0041 END AS c_orig
  FROM (SELECT album_id, user_id, n_days, d_q, seg, cum_prev, cum_incl, stored, lr_q, past, d_q * 77 / n_days AS x FROM u) u
  JOIN bud b ON b.seg = u.seg JOIN fix f ON f.album_id = u.album_id AND f.seg = u.seg
  WHERE u.lr_q >= 0.5 AND IFNULL(u.past, 0) > 0),
t AS (
  SELECT album_id, seg, stored, cum_prev,
    CASE WHEN cum_prev <= c_orig*b0*scale THEN 0 WHEN cum_prev <= c_orig*b1*scale THEN 1
         WHEN cum_prev <= c_orig*b2*scale THEN 2 WHEN cum_prev <= c_orig*b3*scale THEN 3 ELSE 5 END AS t_orig,
    CASE WHEN cum_incl <= c_orig*b0*scale THEN 0 WHEN cum_incl <= c_orig*b1*scale THEN 1
         WHEN cum_incl <= c_orig*b2*scale THEN 2 WHEN cum_incl <= c_orig*b3*scale THEN 3 ELSE 5 END AS t_orig_incl,
    CASE WHEN cum_prev <= c_fix*b0*scale THEN 0 WHEN cum_prev <= c_fix*b1*scale THEN 1
         WHEN cum_prev <= c_fix*b2*scale THEN 2 WHEN cum_prev <= c_fix*b3*scale THEN 3 ELSE 5 END AS t_fix
  FROM c)
SELECT album_id, seg, COUNT(*) AS players, COUNTIF(cum_prev > 0) AS paid_so_far,
  ROUND(COUNTIF(t_orig = stored) / COUNT(*), 3) AS match_stored_prev,
  ROUND(COUNTIF(t_orig_incl = stored) / COUNT(*), 3) AS match_stored_incl,
  -- distributions among players who paid so far
  ROUND(COUNTIF(cum_prev > 0 AND t_orig = 0) / COUNTIF(cum_prev > 0), 3) AS o0,
  ROUND(COUNTIF(cum_prev > 0 AND t_orig = 1) / COUNTIF(cum_prev > 0), 3) AS o1,
  ROUND(COUNTIF(cum_prev > 0 AND t_orig = 2) / COUNTIF(cum_prev > 0), 3) AS o2,
  ROUND(COUNTIF(cum_prev > 0 AND t_orig = 3) / COUNTIF(cum_prev > 0), 3) AS o3,
  ROUND(COUNTIF(cum_prev > 0 AND t_orig = 5) / COUNTIF(cum_prev > 0), 3) AS o5,
  ROUND(COUNTIF(cum_prev > 0 AND t_fix = 0) / COUNTIF(cum_prev > 0), 3) AS f0,
  ROUND(COUNTIF(cum_prev > 0 AND t_fix = 1) / COUNTIF(cum_prev > 0), 3) AS f1,
  ROUND(COUNTIF(cum_prev > 0 AND t_fix = 2) / COUNTIF(cum_prev > 0), 3) AS f2,
  ROUND(COUNTIF(cum_prev > 0 AND t_fix = 3) / COUNTIF(cum_prev > 0), 3) AS f3,
  ROUND(COUNTIF(cum_prev > 0 AND t_fix = 5) / COUNTIF(cum_prev > 0), 3) AS f5,
  COUNTIF(cum_prev > 0 AND t_fix < t_orig) AS moved_down, COUNTIF(cum_prev > 0 AND t_fix > t_orig) AS moved_up
FROM t GROUP BY 1, 2 ORDER BY 1, 2
;

-- Seg4 (2026-10-14) Dice: tier at last-quarter start (reconstructed live query) -> progress at close-4 and end. Project dice-dreams-dbt.
-- Checkpoint d_q = CEIL(0.75*n): 61 day 27 (2026-07-19), 63 day 32 (2026-08-28). Close-4: 61 2026-07-23, 63 2026-09-03.
WITH alb AS (
  SELECT 61 AS album_id, DATE '2026-06-22' AS a_start, DATE '2026-07-27' AS a_end, 35 AS n_days, 27 AS d_q UNION ALL
  SELECT 63, DATE '2026-07-27', DATE '2026-09-07', 42, 32),
bud AS (
  SELECT 1 AS seg, 100 AS b0, 300 AS b1, 600 AS b2, 1000 AS b3 UNION ALL
  SELECT 2, 200, 400, 700, 1200 UNION ALL SELECT 3, 400, 700, 1000, 2000 UNION ALL SELECT 4, 700, 1500, 2500, 6000),
r AS (
  SELECT a.album_id, a.user_id, a.date_dim, alb.n_days, alb.d_q AS dq,
    DATE_DIFF(a.date_dim, alb.a_start, DAY) < alb.d_q AS is_prev,
    DATE_DIFF(a.date_dim, alb.a_start, DAY) = alb.d_q AS is_q,
    DATE_DIFF(a.date_dim, alb.a_start, DAY) >= alb.d_q AS is_q4,
    a.date_dim = DATE_SUB(alb.a_end, INTERVAL 4 DAY) AS is_c4,
    a.date_dim <= DATE_SUB(alb.a_end, INTERVAL 4 DAY) AS to_c4,
    a.album_login_ratio, a.album_segment_code, a.user_past_album_count, a.is_active,
    IFNULL(a.spent_in_album_today, 0) AS spend, a.unique_super_stickers_lt AS u_s, a.unique_stickers_lt AS u_all,
    IFNULL(a.is_album_finisher, FALSE) AS fin
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a JOIN alb USING (album_id)
  WHERE a.date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-06' AND a.album_id IN (61, 63)
    AND IFNULL(a.is_excluded, FALSE) = FALSE AND a.date_dim < alb.a_end),
u AS (
  SELECT album_id, user_id, ANY_VALUE(n_days) AS n_days, ANY_VALUE(dq) AS d_q,
    ARRAY_AGG(album_segment_code IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg,
    SUM(IF(is_prev, spend, 0)) AS cum_prev, SUM(IF(to_c4, spend, 0)) AS rev_c4, SUM(spend) AS rev_end,
    SUM(IF(is_q4, spend, 0)) AS q4_spend, COUNTIF(is_q4 AND is_active) AS q4_days,
    MAX(IF(is_q, album_login_ratio, NULL)) AS lr_q, MIN(user_past_album_count) AS past,
    MAX(IF(is_c4, u_s, NULL)) AS s_c4, MAX(IF(is_c4, u_all, NULL)) AS all_c4,
    MAX(u_s) AS s_end, MAX(u_all) AS all_end, LOGICAL_OR(fin) AS finished
  FROM r GROUP BY 1, 2
  HAVING LOGICAL_OR(is_q)),
c AS (
  SELECT u.album_id, u.seg, u.cum_prev, u.rev_c4, u.rev_end, u.q4_spend, u.q4_days, u.s_c4, u.all_c4, u.s_end, u.all_end, u.finished,
    CASE WHEN u.cum_prev <= cv*b.b0*u.n_days/77 THEN 0 WHEN u.cum_prev <= cv*b.b1*u.n_days/77 THEN 1
         WHEN u.cum_prev <= cv*b.b2*u.n_days/77 THEN 2 WHEN u.cum_prev <= cv*b.b3*u.n_days/77 THEN 3 ELSE 5 END AS tier
  FROM (
    SELECT u.album_id, u.user_id, u.n_days, u.seg, u.cum_prev, u.rev_c4, u.rev_end, u.q4_spend, u.q4_days, u.s_c4, u.all_c4, u.s_end, u.all_end, u.finished, CASE u.seg
      WHEN 1 THEN 0.000000018*POW(x,4) - 0.000002*POW(x,3) + 0.000202*POW(x,2) + 0.0014*x + 0.0016
      WHEN 2 THEN 0.0000000185*POW(x,4) - 0.000002*POW(x,3) + 0.0001*POW(x,2) + 0.0088*x + 0.01
      ELSE 0.0000006*POW(x,3) - 0.00005*POW(x,2) + 0.0135*x + 0.0041 END AS cv
    FROM (SELECT album_id, user_id, n_days, d_q, seg, cum_prev, rev_c4, rev_end, q4_spend, q4_days, lr_q, past, s_c4, all_c4, s_end, all_end, finished,
            d_q * 77 / n_days AS x FROM u) u
    WHERE u.lr_q >= 0.5 AND IFNULL(u.past, 0) > 0) u
  JOIN bud b ON b.seg = u.seg)
SELECT album_id, seg, tier, COUNT(*) AS players, COUNTIF(cum_prev > 0) AS paid_so_far,
  ROUND(SUM(rev_c4), 0) AS rev_to_c4,
  ROUND(SUM(IF(s_c4 >= 10, rev_c4, 0)) / NULLIF(SUM(rev_c4), 0), 3) AS revshare_10plus_supers_c4,
  ROUND(SUM(IF(144 - all_c4 <= 3, rev_c4, 0)) / NULLIF(SUM(rev_c4), 0), 3) AS revshare_max3_missing_c4,
  ROUND(SUM(IF(144 - all_end <= 3, rev_end, 0)) / NULLIF(SUM(rev_end), 0), 3) AS revshare_max3_missing_end,
  ROUND(SUM(IF(finished, rev_end, 0)) / NULLIF(SUM(rev_end), 0), 3) AS revshare_finished,
  ROUND(COUNTIF(s_c4 >= 10) / COUNT(*), 3) AS share_10plus_supers_c4,
  ROUND(COUNTIF(144 - all_c4 <= 3) / COUNT(*), 3) AS share_max3_missing_c4,
  ROUND(COUNTIF(144 - all_end <= 3) / COUNT(*), 3) AS share_max3_missing_end,
  ROUND(COUNTIF(finished) / COUNT(*), 3) AS finish_rate,
  ROUND(SUM(q4_spend) / NULLIF(SUM(q4_days), 0), 2) AS q4_arpdau,
  ROUND(COUNTIF(q4_spend > 0) / COUNT(*), 3) AS share_paid_q4,
  COUNTIF(s_c4 IS NULL) AS no_row_c4
FROM c GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
;

-- Seg4b (2026-10-14) Dice album 63: goal attainment at days-to-end 4 (2026-09-03), tier computed ON that day (live query logic), tracker-like population. Project dice-dreams-dbt.
-- Tier: x = 38*77/42, spend through end of 2026-09-02. Revenue share: revenue album start -> 2026-09-03 of players at/above count target / group revenue.
-- Count targets (goal table, days-to-end 4): stickers 141, commons 104, goldens 27, supers 10, sets 10.
WITH bud AS (
  SELECT 1 AS seg, 100 AS b0, 300 AS b1, 600 AS b2, 1000 AS b3 UNION ALL
  SELECT 2, 200, 400, 700, 1200 UNION ALL SELECT 3, 400, 700, 1000, 2000 UNION ALL SELECT 4, 700, 1500, 2500, 6000),
r AS (
  SELECT a.user_id, a.date_dim, a.album_segment_code, IFNULL(a.spent_in_album_today, 0) AS spend,
    a.unique_stickers_lt AS u_all, a.unique_super_stickers_lt AS u_s, a.unique_golden_stickers_lt AS u_g, a.sets_completed_lt AS sets
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-07-27' AND DATE '2026-09-03' AND a.album_id = 63
    AND IFNULL(a.is_excluded, FALSE) = FALSE),
u AS (
  SELECT user_id,
    ARRAY_AGG(album_segment_code IGNORE NULLS ORDER BY date_dim LIMIT 1)[SAFE_OFFSET(0)] AS seg,
    SUM(IF(date_dim < DATE '2026-09-03', spend, 0)) AS cum_prev, SUM(spend) AS rev,
    MAX(IF(date_dim = DATE '2026-09-03', u_all, NULL)) AS st, MAX(IF(date_dim = DATE '2026-09-03', u_s, NULL)) AS su,
    MAX(IF(date_dim = DATE '2026-09-03', u_g, NULL)) AS go, MAX(IF(date_dim = DATE '2026-09-03', sets, NULL)) AS se
  FROM r GROUP BY 1
  HAVING LOGICAL_OR(date_dim = DATE '2026-09-03')),
c AS (
  SELECT u.seg, u.rev, u.st, u.su, u.go, u.st - u.su - u.go AS co, u.se,
    CASE WHEN u.cum_prev <= cv*b.b0*42/77 THEN 0 WHEN u.cum_prev <= cv*b.b1*42/77 THEN 1
         WHEN u.cum_prev <= cv*b.b2*42/77 THEN 2 WHEN u.cum_prev <= cv*b.b3*42/77 THEN 3 ELSE 5 END AS tier
  FROM (
    SELECT user_id, seg, cum_prev, rev, st, su, go, se, CASE seg
      WHEN 1 THEN 0.000000018*POW(x,4) - 0.000002*POW(x,3) + 0.000202*POW(x,2) + 0.0014*x + 0.0016
      WHEN 2 THEN 0.0000000185*POW(x,4) - 0.000002*POW(x,3) + 0.0001*POW(x,2) + 0.0088*x + 0.01
      ELSE 0.0000006*POW(x,3) - 0.00005*POW(x,2) + 0.0135*x + 0.0041 END AS cv
    FROM (SELECT user_id, IFNULL(seg, 1) AS seg, cum_prev, rev, st, su, go, se, 38 * 77 / 42 AS x FROM u)) u
  JOIN bud b ON b.seg = u.seg)
SELECT seg, tier, COUNT(*) AS players, COUNTIF(rev > 0) AS payers, ROUND(SUM(rev), 0) AS rev,
  ROUND(SUM(IF(st >= 141, rev, 0)) / NULLIF(SUM(rev), 0), 3) AS rs_stickers_141,
  ROUND(SUM(IF(su >= 10, rev, 0)) / NULLIF(SUM(rev), 0), 3) AS rs_supers_10,
  ROUND(SUM(IF(go >= 27, rev, 0)) / NULLIF(SUM(rev), 0), 3) AS rs_goldens_27,
  ROUND(SUM(IF(co >= 104, rev, 0)) / NULLIF(SUM(rev), 0), 3) AS rs_commons_104,
  ROUND(SUM(IF(se >= 10, rev, 0)) / NULLIF(SUM(rev), 0), 3) AS rs_sets_10
FROM c GROUP BY 1, 2 ORDER BY 1, 2
;

