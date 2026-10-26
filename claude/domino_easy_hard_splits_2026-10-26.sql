-- 2026-10-26: Domino Easy vs Hard splits of three slides. Results: claude/domino-easy-hard-splits-2026-10-26.md
-- Segment = album_segment on the player's first album row (as domino_easy_goldens_progression_2026-10-26.sql). No player fell outside Easy/Hard.
-- Q1 (checks 1 + 3), albums 17/19/20, standard-population payers (not first album, not special/cheater, login_ratio >= 0.5 on last row before close,
--   row on close-1, paid on any album day incl. close). Album revenue = spend start..close-1.
--   Check 1: average share of the album's Royals (8 in 17, 9 in 19/20) held at end of day round(n_days*0.9) and at close (sticker table).
--   Check 3: share of the segment's album revenue from payers with >=141 unique stickers on day close-k (k=7..1), daily table.  Scan 35 GB.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, album_segment AS seg,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end, SUM(spend) AS rev_c, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', IF(LOWER(seg) LIKE '%hard%', 'hard', 'other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 7 DAY), uniq, NULL)) AS u7, MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 6 DAY), uniq, NULL)) AS u6,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 5 DAY), uniq, NULL)) AS u5, MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 4 DAY), uniq, NULL)) AS u4,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 3 DAY), uniq, NULL)) AS u3, MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 2 DAY), uniq, NULL)) AS u2,
    MAX(IF(date_dim <= DATE_SUB(a_end, INTERVAL 1 DAY), uniq, NULL)) AS u1
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT u.* EXCEPT(l), DATE_DIFF(a_end, a_start, DAY) + 1 AS n_days FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5 AND rev_c > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
r AS (
  SELECT s.album_id, s.user_id, s.sticker_id, DATE_DIFF(MIN(s.sticker_collected_min_date), ANY_VALUE(p.a_start), DAY) + 1 AS day
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-04-02' AND DATE '2026-10-12' AND s.album_id IN (17,19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal' AND s.sticker_collected_min_date <= p.a_end
  GROUP BY 1,2,3
),
nroy AS (SELECT album_id, COUNT(DISTINCT sticker_id) AS n_roy FROM r GROUP BY 1),
held AS (
  SELECT p.album_id, p.user_id, COUNTIF(r.day <= CAST(ROUND(p.n_days * 0.9) AS INT64)) AS h90, COUNT(r.day) AS h100
  FROM pop p LEFT JOIN r ON r.album_id = p.album_id AND r.user_id = p.user_id GROUP BY 1,2
),
t AS (SELECT album_id, COUNT(*) AS all_payers, SUM(alb_rev) AS all_rev FROM pop GROUP BY 1)
SELECT p.album_id, p.seg0, COUNT(*) AS payers, ROUND(100*COUNT(*)/ANY_VALUE(t.all_payers)) AS pct_payers, ROUND(100*SUM(p.alb_rev)/ANY_VALUE(t.all_rev)) AS pct_rev,
  ANY_VALUE(nroy.n_roy) AS n_roy,
  ROUND(100*AVG(h.h90)/ANY_VALUE(nroy.n_roy),1) AS pct90, ROUND(100*AVG(h.h100)/ANY_VALUE(nroy.n_roy),1) AS pct100,
  ROUND(100*SUM(IF(u7>=141,alb_rev,0))/SUM(alb_rev),1) AS r7, ROUND(100*SUM(IF(u6>=141,alb_rev,0))/SUM(alb_rev),1) AS r6,
  ROUND(100*SUM(IF(u5>=141,alb_rev,0))/SUM(alb_rev),1) AS r5, ROUND(100*SUM(IF(u4>=141,alb_rev,0))/SUM(alb_rev),1) AS r4,
  ROUND(100*SUM(IF(u3>=141,alb_rev,0))/SUM(alb_rev),1) AS r3, ROUND(100*SUM(IF(u2>=141,alb_rev,0))/SUM(alb_rev),1) AS r2,
  ROUND(100*SUM(IF(u1>=141,alb_rev,0))/SUM(alb_rev),1) AS r1,
  ROUND(100*COUNTIF(u7>=141)/COUNT(*)) AS n7pct, ROUND(100*COUNTIF(u1>=141)/COUNT(*)) AS n1pct
FROM pop p JOIN held h USING (album_id, user_id) JOIN t USING (album_id) JOIN nroy USING (album_id)
GROUP BY 1,2 ORDER BY 1,2
;

-- Q2 (check 2), albums 19/20: same population as far_rare_gate_gap_2026-10-23.sql (its own: payers by spend so far at 75% of album, P50-95 rank over
--   all payers of the album, far = 4+ missing at close-1; no close-1-row rule). Ranked over the whole album, then split by segment. Scan 11 GB.
--   Totals match the original (Domino 19 38,622 far; 20 15,370).
WITH excluded AS (SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_close_date AS a_close,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d, DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend, a.album_segment AS seg,
    IFNULL(a.unique_common_stickers_lt, 0) AS uc, IFNULL(a.unique_golden_stickers_lt, 0) AS ug, IFNULL(a.unique_royal_stickers_tl, 0) AS ur
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND a.album_id IN (19, 20)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
r1 AS (SELECT r0.*, MAX(uc) OVER w AS uc_end, MAX(ug) OVER w AS ug_end, MAX(ur) OVER w AS ur_end FROM r0 WINDOW w AS (PARTITION BY album_id, user_id)),
r2 AS (SELECT r1.*, MIN(IF(ur = ur_end, d, NULL)) OVER (PARTITION BY album_id, user_id) AS r_st FROM r1),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, SUM(spend) AS total, MIN(d) AS first_d,
    SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far,
    144 - (ANY_VALUE(uc_end) + ANY_VALUE(ug_end) + ANY_VALUE(ur_end)) AS m_end, ANY_VALUE(r_st) AS r_st,
    ARRAY_AGG(IF(LOWER(seg) LIKE '%easy%', 'easy', IF(LOWER(seg) LIKE '%hard%', 'hard', 'other')) ORDER BY date_dim LIMIT 1)[OFFSET(0)] AS seg0,
    ARRAY_AGG(IFNULL(login_ratio, -1) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS lr_last, ARRAY_AGG(IFNULL(user_album_count, 0) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS uac_last
  FROM r2 GROUP BY 1, 2),
tgt AS (SELECT * FROM ua WHERE lr_last >= 0.5 AND IFNULL(uac_last, 0) > 1 AND first_d <= CAST(CEIL(0.75 * n) AS INT64) - 1),
p AS (SELECT tgt.*, IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr FROM tgt),
pay AS (SELECT album_id, seg0, COUNT(*) AS n_pay, SUM(total) AS rev_pay FROM p WHERE total > 0 GROUP BY 1, 2),
far AS (SELECT * FROM p WHERE so_far > 0 AND pr >= 0.5 AND pr < 0.95 AND m_end >= 4)
SELECT f.album_id, f.seg0, COUNT(*) AS n_far, ROUND(100 * COUNT(*) / ANY_VALUE(pay.n_pay), 1) AS pct_seg_payers, ROUND(100 * SUM(f.total) / ANY_VALUE(pay.rev_pay), 1) AS pct_seg_rev,
  ROUND(SUM(f.total * (f.n - f.r_st)) / SUM(f.total), 1) AS last_royal_dbc, APPROX_QUANTILES(f.n - f.r_st, 2)[OFFSET(1)] AS last_royal_dbc_median,
  (SELECT COUNT(*) FROM p p2 WHERE p2.album_id = f.album_id AND p2.seg0 = f.seg0 AND p2.so_far > 0 AND p2.pr >= 0.5 AND p2.pr < 0.95) AS n_mid
FROM far f JOIN pay USING (album_id, seg0) GROUP BY 1, 2 ORDER BY 1, 2;
