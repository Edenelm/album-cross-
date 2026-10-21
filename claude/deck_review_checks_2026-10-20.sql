-- Deck review checks, 2026-10-20. Results: claude/deck-review-2026-10-20.md

-- ===== CHECK 1 — DICE grand-prize slides with Eden's finisher rule + a no-prize comparison (albums 59 / 61 / 63) =====
-- Why: seg-return, prize-fit, seg7-top and prize-rec counted a finisher as "144 OR game finish flag"
--      (claude/finisher_prize_burn_queries.sql, prize_within_segment_dice.sql, seg7_top_payers_dice.sql).
--      Eden's rule (2026-10-19) = 144 unique set stickers by the END of the close day, not the flag.
--      Album 59 is added to see whether album 61 or 63 is the usual pattern.
-- Finisher = 144 unique common/golden/super stickers in fact_user_album_stickers collected by the close day;
--   finish day = day of the 144th new sticker.
-- Payer = spend on any album day, close day included (Eden 2026-10-20). Album revenue = album-table spend, start .. close-1.
-- Standard population: not first album, not excluded, login ratio >= 0.5 on the last row before close, has a row on close-1.
-- Habit = close-18 .. close-5 (14 days), as in the earlier slides. Day 0 = finish day (finishers) or the close day (non-finishers).
-- Buying gap = share who bought in days 1-7 minus the share their own habit predicts (1-(1-p)^7), in points.
-- Spend ratio = revenue days 1-7 / (habit revenue / 14 x 7).
-- Comparison: payers who ended 1-3 missing at the end of the close day get no grand prize. If they show the same step by
--   reward code, the step is not the prize.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, album_segment AS a_seg, album_reward_code AS r_code
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (59,61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_incl_close,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d, MAX(a_seg) AS a_seg, MAX(r_code) AS r_code
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev, rev_incl_close > 0 AS payer, a_seg, r_code FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
st1 AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_date) AS first_d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (59,61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE)
  GROUP BY 1,2,3
),
st AS (
  SELECT t.album_id, t.user_id, COUNT(*) AS n_uniq, MAX(t.first_d) AS last_new_d
  FROM st1 t JOIN (SELECT DISTINCT album_id, a_end FROM pop) a USING (album_id)
  WHERE t.first_d <= a.a_end
  GROUP BY 1,2
),
p AS (
  SELECT p.album_id, p.user_id, p.a_end, p.alb_rev, p.payer, p.a_seg, p.r_code,
    IFNULL(s.n_uniq, 0) AS n_uniq,
    IF(IFNULL(s.n_uniq,0) >= 144, s.last_new_d, NULL) AS fin_d
  FROM pop p LEFT JOIN st s USING (album_id, user_id)
),
tot AS (
  SELECT album_id, COUNT(*) AS pop_all, SUM(alb_rev) AS pop_rev, COUNTIF(payer) AS payers,
    COUNTIF(payer AND fin_d IS NOT NULL) AS pay_fin
  FROM p GROUP BY 1
),
g AS (
  SELECT album_id, user_id, a_end, alb_rev, a_seg, r_code,
    CASE WHEN fin_d IS NOT NULL AND fin_d >= DATE_SUB(a_end, INTERVAL 1 DAY) THEN 'fin_late'
         WHEN fin_d IS NOT NULL THEN 'fin_early'
         WHEN 144 - n_uniq BETWEEN 1 AND 3 THEN 'miss_1_3' END AS grp,
    IFNULL(fin_d, a_end) AS d0,
    CASE WHEN alb_rev < 200 THEN 'a_lt200' WHEN alb_rev < 700 THEN 'b_200_700' ELSE 'c_700plus' END AS spend_band
  FROM p WHERE payer AND (fin_d IS NOT NULL OR 144 - n_uniq BETWEEN 1 AND 3)
),
m AS (
  SELECT a.user_id, a.date_dim AS d, IFNULL(a.revenues_sum,0) AS rev
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` a
  WHERE a.date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-09-22'
),
x AS (
  SELECT g.album_id, g.user_id,
    SUM(IF(m.d BETWEEN DATE_SUB(g.a_end, INTERVAL 18 DAY) AND DATE_SUB(g.a_end, INTERVAL 5 DAY), m.rev, 0)) AS b_rev,
    COUNTIF(m.d BETWEEN DATE_SUB(g.a_end, INTERVAL 18 DAY) AND DATE_SUB(g.a_end, INTERVAL 5 DAY) AND m.rev > 0) AS b_pay_days,
    SUM(IF(DATE_DIFF(m.d, g.d0, DAY) BETWEEN 1 AND 7, m.rev, 0)) AS rev_1_7,
    COUNTIF(DATE_DIFF(m.d, g.d0, DAY) BETWEEN 1 AND 7 AND m.rev > 0) > 0 AS bought_7
  FROM g JOIN m ON m.user_id = g.user_id AND m.d BETWEEN DATE_SUB(g.a_end, INTERVAL 18 DAY) AND DATE_ADD(g.d0, INTERVAL 7 DAY)
  GROUP BY 1,2
),
e AS (
  SELECT g.album_id, g.grp, g.alb_rev, g.spend_band,
    CASE WHEN g.r_code BETWEEN 1 AND 3 THEN 'c1_3' WHEN g.r_code BETWEEN 4 AND 6 THEN 'c4_6' WHEN g.r_code = 7 THEN 'c7' ELSE 'c_na' END AS code_bkt,
    CASE WHEN g.a_seg IN ('Easy','Medium') THEN 'light_mid' WHEN g.a_seg IN ('Hard','Extreme') THEN 'high_top' ELSE 'seg_na' END AS seg_bkt,
    IFNULL(x.b_rev,0) AS b_rev, IFNULL(x.rev_1_7,0) AS rev_1_7, IFNULL(x.bought_7,FALSE) AS bought_7,
    1 - POW(1 - IFNULL(x.b_pay_days,0) / 14, 7) AS exp_7
  FROM g LEFT JOIN x USING (album_id, user_id)
),
cuts AS (
  SELECT e.album_id, e.grp, c.cut, c.val, e.alb_rev, e.b_rev, e.rev_1_7, e.bought_7, e.exp_7
  FROM e CROSS JOIN UNNEST([
    STRUCT('all' AS cut, 'all' AS val),
    STRUCT('code', e.code_bkt),
    STRUCT('seg_x_code', CONCAT(e.seg_bkt, '|', e.code_bkt)),
    STRUCT('code7_spend', IF(e.code_bkt = 'c7', e.spend_band, NULL))]) c
  WHERE c.val IS NOT NULL
)
SELECT c.album_id, c.grp, c.cut, c.val,
  COUNT(*) AS n,
  ANY_VALUE(t.pay_fin) AS pay_fin, ANY_VALUE(t.payers) AS payers, ANY_VALUE(t.pop_all) AS pop_all,
  ROUND(SUM(c.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share,
  ROUND(100 * (AVG(IF(c.bought_7, 1, 0)) - AVG(c.exp_7)), 1) AS buy_gap_pts,
  ROUND(SAFE_DIVIDE(SUM(c.rev_1_7), SUM(c.b_rev) / 2), 2) AS spend_ratio_1_7
FROM cuts c JOIN tot t USING (album_id)
GROUP BY 1,2,3,4
ORDER BY 1,2,3,4
;

-- ===== CHECK 2 — DICE prize-fit / seg7-top numbers per reward code with Eden's finisher rule (albums 61 / 63) =====
-- Same definitions as the slides (habit = close-18..close-5, day 0 = completion day, roll balance from 40_mart.user_daily_mtx_brut_rolls,
-- not-enough-rolls from 30_intermediate.user_daily_rolls_in_out), but finisher = 144 from fact_user_album_stickers by the end of the close day
-- (no game flag) and payer = paid on any album day incl. the close day.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, album_reward_code AS r_code, album_reward_value AS r_val
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_incl_close,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d, MAX(r_code) AS r_code, MAX(r_val) AS r_val
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev, rev_incl_close > 0 AS payer, r_code, r_val FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
st1 AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_date) AS first_d
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE)
  GROUP BY 1,2,3
),
st AS (
  SELECT t.album_id, t.user_id, COUNT(*) AS n_uniq, MAX(t.first_d) AS last_new_d
  FROM st1 t JOIN (SELECT DISTINCT album_id, a_end FROM pop) a USING (album_id)
  WHERE t.first_d <= a.a_end
  GROUP BY 1,2
),
tot AS (
  SELECT p.album_id, COUNT(*) AS pop_all, SUM(p.alb_rev) AS pop_rev, COUNTIF(p.payer AND s.n_uniq >= 144) AS n_fin_pay
  FROM pop p LEFT JOIN st s USING (album_id, user_id) GROUP BY 1
),
fin AS (
  SELECT p.album_id, p.user_id, p.a_end, s.last_new_d AS fin_d, p.alb_rev, p.r_code, p.r_val
  FROM pop p JOIN st s USING (album_id, user_id) WHERE p.payer AND s.n_uniq >= 144
),
m AS (
  SELECT COALESCE(a.user_id, r.user_id) AS user_id, COALESCE(a.date_dim, r.date_dim) AS d,
    IFNULL(a.revenues_sum,0) AS rev, IFNULL(r.rolls_out_sum,0) AS play, IFNULL(r.not_enough_rolls_count,0) > 0 AS ooc
  FROM (SELECT user_id, date_dim, revenues_sum FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
        WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-22') a
  FULL JOIN (SELECT user_id, date_dim, rolls_out_sum, not_enough_rolls_count FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
        WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-22') r
  ON a.user_id = r.user_id AND a.date_dim = r.date_dim
),
bal AS (
  SELECT user_id, mtx_day AS d, start_rolls_balance AS bal FROM `dice-dreams-dbt.40_mart.user_daily_mtx_brut_rolls`
  WHERE mtx_day BETWEEN DATE '2026-07-01' AND DATE '2026-09-22'
),
pre AS (
  SELECT f.album_id, f.user_id, ARRAY_AGG(b.bal ORDER BY b.d DESC LIMIT 1)[SAFE_OFFSET(0)] AS pre_bal
  FROM fin f JOIN bal b ON b.user_id = f.user_id AND b.d BETWEEN DATE_SUB(f.fin_d, INTERVAL 3 DAY) AND DATE_SUB(f.fin_d, INTERVAL 1 DAY)
  GROUP BY 1,2
),
b1 AS (
  SELECT f.album_id, f.user_id, MAX(b.bal) AS bal1
  FROM fin f JOIN bal b ON b.user_id = f.user_id AND b.d = DATE_ADD(f.fin_d, INTERVAL 1 DAY)
  GROUP BY 1,2
),
x AS (
  SELECT f.album_id, f.user_id,
    SUM(IF(m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_SUB(f.a_end, INTERVAL 5 DAY), m.rev, 0)) AS b_rev,
    COUNTIF(m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_SUB(f.a_end, INTERVAL 5 DAY) AND m.rev > 0) AS b_pay_days,
    SUM(IF(m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_SUB(f.a_end, INTERVAL 5 DAY), m.play, 0)) / 14 AS b_play_pd,
    SUM(IF(DATE_DIFF(m.d, f.fin_d, DAY) BETWEEN 1 AND 7, m.rev, 0)) AS rev_1_7,
    MIN(IF(DATE_DIFF(m.d, f.fin_d, DAY) >= 1 AND m.rev > 0, DATE_DIFF(m.d, f.fin_d, DAY), NULL)) AS buy_k,
    LOGICAL_OR(DATE_DIFF(m.d, f.fin_d, DAY) = 1 AND m.ooc) AS ooc_1
  FROM fin f JOIN m ON m.user_id = f.user_id AND m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_ADD(f.fin_d, INTERVAL 7 DAY)
  GROUP BY 1,2
),
e AS (
  SELECT f.album_id, f.alb_rev, f.r_val, CAST(f.r_code AS STRING) AS code,
    CASE WHEN f.alb_rev < 200 THEN 'a_lt200' WHEN f.alb_rev < 700 THEN 'b_200_700' ELSE 'c_700plus' END AS band,
    x.b_rev, x.b_play_pd, x.rev_1_7, x.buy_k, IFNULL(x.ooc_1, FALSE) AS ooc_1,
    1 - POW(1 - IFNULL(x.b_pay_days,0) / 14, 7) AS exp_7,
    SAFE_DIVIDE(b1.bal1, pr.pre_bal) AS bal_ratio, SAFE_DIVIDE(f.r_val, x.b_play_pd) AS prize_days
  FROM fin f LEFT JOIN x USING (album_id, user_id) LEFT JOIN pre pr USING (album_id, user_id) LEFT JOIN b1 USING (album_id, user_id)
),
cuts AS (
  SELECT e.album_id, c.cut, c.val, e.alb_rev, e.b_rev, e.b_play_pd, e.rev_1_7, e.buy_k, e.ooc_1, e.exp_7, e.bal_ratio, e.prize_days
  FROM e CROSS JOIN UNNEST([STRUCT('all' AS cut, 'all' AS val), STRUCT('code', e.code),
                            STRUCT('code7_band', IF(e.code = '7', e.band, NULL))]) c
  WHERE c.val IS NOT NULL
)
SELECT c.album_id, c.cut, c.val, COUNT(*) AS n,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 3) AS share_fin, ROUND(COUNT(*) / ANY_VALUE(t.pop_all), 4) AS share_players,
  ROUND(SUM(c.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share, ROUND(SUM(c.alb_rev)) AS rev,
  ROUND(APPROX_QUANTILES(c.b_play_pd, 2)[OFFSET(1)], -3) AS med_rolls_pd,
  ROUND(APPROX_QUANTILES(c.prize_days, 2)[OFFSET(1)], 1) AS med_prize_days,
  ROUND(APPROX_QUANTILES(c.bal_ratio, 2)[OFFSET(1)], 1) AS med_bal1_vs_before,
  ROUND(AVG(IF(c.ooc_1, 1, 0)), 2) AS ooc_day1,
  ROUND(100 * (AVG(IF(c.buy_k <= 7, 1, 0)) - AVG(c.exp_7)), 1) AS buy_gap_pts,
  ROUND(AVG(IF(c.buy_k <= 3, 1, 0)), 2) AS bought_by_3,
  ROUND(SAFE_DIVIDE(SUM(c.rev_1_7), SUM(c.b_rev) / 2), 2) AS spend_ratio_1_7
FROM cuts c JOIN tot t USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2,3
;
