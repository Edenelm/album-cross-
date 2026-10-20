-- Dice reference for the event comparison: same recovery metrics by finish timing (no paid post-album event in Dice; finisher Fortune Wheel / Lava give rolls only).
-- Albums 61, 63. Payer finishers (144 by end of close day), standard population. Same definitions as claude/event_effect_domino.sql / _disney.sql.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, DATE(user_album_finish_ts) AS flag_fin_d,
    album_segment AS a_seg, album_reward_code AS r_code, album_reward_value AS r_val
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    NULLIF(LEAST(IFNULL(MIN(IF(uniq >= 144, date_dim, NULL)), DATE '2099-01-01'), IFNULL(MIN(IF(flag_fin_d <= a_end, flag_fin_d, NULL)), DATE '2099-01-01')), DATE '2099-01-01') AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    MAX(a_seg) AS a_seg, MAX(r_code) AS r_code, MAX(r_val) AS r_val
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev, a_seg, r_code, r_val FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
tot AS (SELECT album_id, COUNT(*) AS pop_all, SUM(alb_rev) AS pop_rev, COUNTIF(fin_d IS NOT NULL AND alb_rev > 0) AS n_fin_pay FROM pop GROUP BY 1),
fin AS (SELECT album_id, user_id, a_end, fin_d, alb_rev, a_seg, r_code, r_val FROM pop WHERE fin_d IS NOT NULL AND alb_rev > 0),
m AS (
  SELECT COALESCE(a.user_id, r.user_id) AS user_id, COALESCE(a.date_dim, r.date_dim) AS d,
    IFNULL(a.revenues_sum,0) AS rev, IFNULL(r.rolls_out_sum,0) AS play, IFNULL(r.not_enough_rolls_count,0) > 0 AS ooc
  FROM (SELECT user_id, date_dim, revenues_sum FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
        WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-22') a
  FULL JOIN (SELECT user_id, date_dim, rolls_out_sum, not_enough_rolls_count FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
        WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-22') r
  ON a.user_id = r.user_id AND a.date_dim = r.date_dim
),
maxd AS (SELECT MAX(date_dim) AS md FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-09-22'),
x AS (
  SELECT f.album_id, f.user_id, DATE_DIFF(m.d, f.fin_d, DAY) AS k,
    m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_SUB(f.a_end, INTERVAL 5 DAY) AS in_base, m.rev, m.play, m.ooc
  FROM fin f JOIN m ON m.user_id = f.user_id AND m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_ADD(f.fin_d, INTERVAL 14 DAY)
),
pu AS (
  SELECT album_id, user_id,
    SUM(IF(in_base, rev, 0)) AS b_rev, COUNTIF(in_base AND rev > 0) AS b_pay_days, SUM(IF(in_base, play, 0)) / 14 AS b_play_pd,
    SUM(IF(k BETWEEN 1 AND 7, rev, 0)) AS rev_1_7, SUM(IF(k BETWEEN 1 AND 7, play, 0)) AS play_1_7,
    MIN(IF(k >= 1 AND rev > 0, k, NULL)) AS buy_k,
    COUNTIF(in_base AND ooc) AS b_ooc_days, MIN(IF(k >= 1 AND ooc, k, NULL)) AS ooc_k
  FROM x GROUP BY 1,2
),
ev AS (
  SELECT f.album_id, f.user_id, f.fin_d, f.alb_rev, p.b_rev, p.b_play_pd, p.rev_1_7, p.play_1_7, p.buy_k, SAFE_DIVIDE(p.b_pay_days, 14) AS p_day,
    CASE DATE_DIFF(f.fin_d, f.a_end, DAY) WHEN 0 THEN 'a_close_day' WHEN -1 THEN 'b_d-1' WHEN -2 THEN 'c_d-2_3' WHEN -3 THEN 'c_d-2_3' ELSE 'd_d-4plus' END AS timing
  FROM fin f JOIN pu p USING (album_id, user_id)
),
sg AS (
  SELECT e.album_id, e.user_id, e.fin_d, e.alb_rev, e.b_rev, e.b_play_pd, e.rev_1_7, e.play_1_7, e.buy_k, e.p_day, s.seg_type, s.seg, mx.md
  FROM ev e
  CROSS JOIN UNNEST([STRUCT('all' AS seg_type, 'all' AS seg), STRUCT('timing', e.timing)]) s
  CROSS JOIN maxd mx
)
SELECT g.album_id, g.seg_type, g.seg,
  COUNT(*) AS n_seg,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 4) AS share_of_payer_finishers,
  ROUND(SUM(g.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS album_rev_share,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bought_7,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, 1 - POW(1 - g.p_day, 7), NULL)), 3) AS exp_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.rev_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.b_rev / 2, 0))), 2) AS spend_ratio_1_7,
  ROUND(SAFE_DIVIDE(SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.play_1_7, 0)), SUM(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, g.b_play_pd * 7, 0))), 2) AS play_pace_1_7
FROM sg g JOIN tot t USING (album_id)
GROUP BY 1,2,3
ORDER BY 1,2,3
