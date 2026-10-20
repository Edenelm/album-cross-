-- Who are Easy / Medium / Hard / Extreme among Dice payer finishers? Albums 61, 63 (previous album = id - 2: 59, 61).
-- Population = payer finishers (144 by end of close day) in the standard population, same as claude/prize_within_segment_dice.sql.
-- Split: album x difficulty segment x prize group (codes 1-3 = 25K-65K, codes 4-7 = 100K-200K).
-- Normalised spend = total_spent_in_album * 70 / (album_number_of_days - 1) (same rule the segment uses).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, DATE(user_album_finish_ts) AS flag_fin_d,
    album_segment AS a_seg, album_segment_code AS seg_code, album_reward_code AS r_code,
    ltv_until_album_start AS ltv0, user_past_album_count AS past_n
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    NULLIF(LEAST(IFNULL(MIN(IF(uniq >= 144, date_dim, NULL)), DATE '2099-01-01'), IFNULL(MIN(IF(flag_fin_d <= a_end, flag_fin_d, NULL)), DATE '2099-01-01')), DATE '2099-01-01') AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    MAX(a_seg) AS a_seg, MAX(seg_code) AS seg_code, MAX(r_code) AS r_code, MAX(ltv0) AS ltv0, MAX(past_n) AS past_n
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, fin_d, alb_rev, a_seg, seg_code, r_code, ltv0, past_n FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
tot AS (SELECT album_id, COUNT(*) AS pop_all, SUM(alb_rev) AS pop_rev, COUNTIF(fin_d IS NOT NULL AND alb_rev > 0) AS n_fin_pay FROM pop GROUP BY 1),
fin AS (SELECT album_id, user_id, alb_rev, a_seg, seg_code, r_code, ltv0, past_n FROM pop WHERE fin_d IS NOT NULL AND alb_rev > 0),
prev AS (
  SELECT album_id + 2 AS album_id, user_id,
    MAX(total_spent_in_album) AS prev_spent,
    MAX(total_spent_in_album) * 70 / (MAX(album_number_of_days) - 1) AS prev_adj,
    LOGICAL_OR(is_album_finisher) AS prev_fin,
    MAX(album_segment_code) AS prev_seg_code, MAX(album_reward_code) AS prev_r_code
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-04-01' AND DATE '2026-07-28' AND album_id IN (59, 61)
  GROUP BY 1, 2
),
cur_adj AS (
  SELECT album_id, user_id, MAX(total_spent_in_album) * 70 / (MAX(album_number_of_days) - 1) AS cur_adj
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61, 63)
  GROUP BY 1, 2
),
x AS (
  SELECT f.album_id, f.user_id, f.alb_rev, f.a_seg, f.seg_code, f.r_code, f.ltv0, f.past_n,
    IF(f.r_code >= 4, 'codes_4_7', 'codes_1_3') AS prize_grp,
    p.prev_spent, p.prev_adj, p.prev_fin, p.prev_seg_code, p.prev_r_code, c.cur_adj
  FROM fin f LEFT JOIN prev p USING (album_id, user_id) LEFT JOIN cur_adj c USING (album_id, user_id)
)
SELECT x.album_id, x.a_seg, x.prize_grp,
  COUNT(*) AS n,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 4) AS share_of_payer_finishers,
  ROUND(SUM(x.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS album_rev_share,
  ROUND(APPROX_QUANTILES(x.alb_rev, 2)[OFFSET(1)], 0) AS med_album_spend,
  ROUND(APPROX_QUANTILES(x.cur_adj, 2)[OFFSET(1)], 0) AS med_album_spend_norm70,
  ROUND(AVG(IF(x.prev_spent IS NOT NULL, 1, 0)), 3) AS played_prev_album,
  ROUND(APPROX_QUANTILES(x.prev_spent, 2)[OFFSET(1)], 0) AS med_prev_album_spend,
  ROUND(AVG(IF(x.prev_fin, 1, 0)), 3) AS finished_prev_album,
  ROUND(SAFE_DIVIDE(COUNTIF(x.prev_adj > 2 * x.cur_adj), COUNTIF(x.prev_adj IS NOT NULL)), 3) AS prev_spend_over_2x_now,
  ROUND(SAFE_DIVIDE(COUNTIF(x.prev_adj < 0.5 * x.cur_adj), COUNTIF(x.prev_adj IS NOT NULL)), 3) AS prev_spend_under_half_now,
  ROUND(SAFE_DIVIDE(COUNTIF(x.prev_seg_code > x.seg_code), COUNTIF(x.prev_seg_code IS NOT NULL)), 3) AS prev_album_higher_segment,
  ROUND(APPROX_QUANTILES(x.ltv0, 2)[OFFSET(1)], 0) AS med_ltv_at_album_start,
  ROUND(APPROX_QUANTILES(x.past_n, 2)[OFFSET(1)], 0) AS med_past_albums
FROM x JOIN tot t USING (album_id)
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
