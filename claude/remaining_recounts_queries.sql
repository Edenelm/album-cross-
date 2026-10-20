-- Remaining recounts 2026-10-20 (Eden: 'ספירות שנשארו'). Finisher new = 144 unique set stickers by END of close day; old = before close day. Results: claude/remaining-recounts-2026-10-20.md

-- ===== DICE 61/63 (dice-dreams-dbt, 23.1 GB) =====
-- REMAINING RECOUNTS (2026-10-20) — DICE 61/63. Finisher new = 144 unique set stickers by END of close day; old = before close day.
-- Standard population (not first album, not excluded, login ratio >= 0.5 on last row before close, row on close-1). Payer = album-table spend > 0, start..close-1.
-- (a) finishing sticker (last first-receipt, by ts) via Wild / paid Wild (Pricing pack) / type; last Super via Wild.
-- (b) finishers: spend on close-1 per active player vs days 14..8 (album-table spend, activity = daily metrics sessions); pay rate (share paying per day) days 3..1 vs 14..8.
-- (c) routes: payers 4-6 missing on the close-8 row; route = Wild fill in close-7..close-1 (bought = Pricing pack / gameplay only / none); route_c = same incl. close day.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-06' AND album_id IN (61,63) AND date_dim < album_end_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(sessions_cnt,0) > 0 AS act
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-06'
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8,
    SUM(spend) AS alb_rev,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 14 DAY) AND DATE_SUB(a_end, INTERVAL 8 DAY), spend, 0)) AS b_rev,
    COUNTIF(spend > 0 AND date_dim BETWEEN DATE_SUB(a_end, INTERVAL 14 DAY) AND DATE_SUB(a_end, INTERVAL 8 DAY)) AS b_pd,
    SUM(IF(date_dim = DATE_SUB(a_end, INTERVAL 1 DAY), spend, 0)) AS l1_rev,
    COUNTIF(spend > 0 AND date_dim BETWEEN DATE_SUB(a_end, INTERVAL 3 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS l3_pd,
    ARRAY_AGG(STRUCT(lr, past, excl) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l, MAX(date_dim) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, uniq_m8, alb_rev, alb_rev > 0 AS payer, b_rev, b_pd, l1_rev, l3_pd
  FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
act AS (
  SELECT p.album_id, p.user_id,
    COUNTIF(m.act AND m.date_dim <= DATE_SUB(p.a_end, INTERVAL 8 DAY)) AS b_ad,
    COUNTIF(m.act AND m.date_dim = DATE_SUB(p.a_end, INTERVAL 1 DAY)) AS l1_ad
  FROM pop p JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
st AS (
  SELECT s.album_id, s.user_id, p.a_end, s.sticker_type AS t, s.sticker_collected_ts AS ts, s.sticker_collected_date AS d,
    IFNULL(s.collected_from_wild, FALSE) AS wild, IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AS paid
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1
),
stu0 AS (
  SELECT album_id, user_id, COUNT(*) AS n_uniq,
    ARRAY_AGG(STRUCT(d, t, wild, paid) ORDER BY ts DESC LIMIT 1)[OFFSET(0)] AS ls,
    ARRAY_AGG(IF(t = 'super', STRUCT(wild, paid), NULL) IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS lsup,
    LOGICAL_OR(wild AND paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_paid,
    LOGICAL_OR(wild AND NOT paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_game,
    LOGICAL_OR(wild AND paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND a_end) AS pkc_paid,
    LOGICAL_OR(wild AND NOT paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND a_end) AS pkc_game
  FROM st GROUP BY 1,2
),
stu AS (
  SELECT album_id, user_id, n_uniq, ls.d AS ls_d, ls.t AS ls_t, ls.wild AS ls_wild, ls.paid AS ls_paid, IFNULL(lsup.wild, FALSE) AS lsup_wild,
    pk_paid, pk_game, pkc_paid, pkc_game
  FROM stu0
),
j AS (
  SELECT p.album_id, p.user_id, p.payer, p.alb_rev, p.uniq_m8, p.b_rev, p.b_pd, p.l1_rev, p.l3_pd,
    IFNULL(a.b_ad, 0) AS b_ad, IFNULL(a.l1_ad, 0) AS l1_ad,
    IFNULL(s.n_uniq, 0) >= 144 AS fin_new, IFNULL(s.n_uniq, 0) >= 144 AND s.ls_d < p.a_end AS fin_old,
    IFNULL(s.n_uniq, 0) > 144 AS over144, s.ls_t, s.ls_wild, s.ls_paid, s.lsup_wild,
    CASE WHEN s.pk_paid THEN 'bought' WHEN s.pk_game THEN 'gameplay' ELSE 'none' END AS route,
    CASE WHEN s.pkc_paid THEN 'bought' WHEN s.pkc_game THEN 'gameplay' ELSE 'none' END AS route_c
  FROM pop p LEFT JOIN act a USING (album_id, user_id) LEFT JOIN stu s USING (album_id, user_id)
),
lab AS (
  SELECT album_id, payer, alb_rev, b_rev, b_pd, l1_rev, l3_pd, b_ad, l1_ad, fin_new, fin_old, over144, ls_t, ls_wild, ls_paid, lsup_wild, label FROM j
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    IF(fin_old AND payer, ['F_old_pay'], []), IF(fin_new AND payer, ['F_new_pay'], []),
    IF(fin_new AND NOT fin_old AND payer, ['F_close_pay'], []),
    IF(fin_old AND NOT payer, ['F_old_nonpay'], []), IF(fin_new AND NOT payer, ['F_new_nonpay'], []),
    IF(payer AND uniq_m8 BETWEEN 138 AND 140, [CONCAT('R46_', route), CONCAT('R46c_', route_c), 'R46_all'], []),
    IF(payer, ['all_payers'], []))) AS label
)
SELECT album_id, label, COUNT(*) AS n, ROUND(SUM(alb_rev)) AS rev, COUNTIF(over144) AS over144,
  COUNTIF(fin_old) AS fin_old, COUNTIF(fin_new) AS fin_new,
  ROUND(COUNTIF(ls_wild) / COUNT(*), 4) AS last_wild, ROUND(COUNTIF(ls_wild AND ls_paid) / COUNT(*), 4) AS last_paid_wild,
  ROUND(COUNTIF(ls_paid AND NOT ls_wild) / COUNT(*), 4) AS last_paid_nonwild,
  ROUND(COUNTIF(ls_t = 'super') / COUNT(*), 4) AS last_super, ROUND(COUNTIF(ls_t = 'golden') / COUNT(*), 4) AS last_golden,
  ROUND(COUNTIF(lsup_wild) / COUNT(*), 4) AS last_super_via_wild,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(l1_rev), SUM(l1_ad)), SAFE_DIVIDE(SUM(b_rev), SUM(b_ad))), 3) AS arpdau_d1_vs_base,
  ROUND(SAFE_DIVIDE(SUM(l3_pd) / 3, SUM(b_pd) / 7), 3) AS payrate_l3_vs_base,
  ROUND(SUM(b_pd) / (7 * COUNT(*)), 3) AS payrate_base, ROUND(SUM(l3_pd) / (3 * COUNT(*)), 3) AS payrate_l3
FROM lab GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DOMINO 17/19/20 (domino-dreams-dbt, 48.6 GB) — same sections; paid Joker = validated campaign rule (2026-10-15) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 14 DAY) AND DATE_SUB(a_end, INTERVAL 8 DAY), spend, 0)) AS b_rev,
    COUNTIF(spend > 0 AND date_dim BETWEEN DATE_SUB(a_end, INTERVAL 14 DAY) AND DATE_SUB(a_end, INTERVAL 8 DAY)) AS b_pd,
    SUM(IF(date_dim = DATE_SUB(a_end, INTERVAL 1 DAY), spend, 0)) AS l1_rev,
    COUNTIF(spend > 0 AND date_dim BETWEEN DATE_SUB(a_end, INTERVAL 3 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS l3_pd,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, uniq_m8, alb_rev, alb_rev > 0 AS payer, b_rev, b_pd, l1_rev, l3_pd
  FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
act AS (
  SELECT p.album_id, p.user_id,
    COUNTIF(m.act AND m.date_dim <= DATE_SUB(p.a_end, INTERVAL 8 DAY)) AS b_ad,
    COUNTIF(m.act AND m.date_dim = DATE_SUB(p.a_end, INTERVAL 1 DAY)) AS l1_ad
  FROM pop p JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
st AS (
  SELECT s.album_id, s.user_id, p.a_end, p.fin_d, s.sticker_collected_min_ts AS ts, s.sticker_collected_min_date AS d,
    IFNULL(s.collected_by_joker_flag, FALSE) AS wild, IFNULL(s.new_sticker_source, '') AS src,
    (   (IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Offer%'
         AND NOT REGEXP_CONTAINS(IFNULL(s.new_sticker_mtx_campaign_name, ''), r'SeasonPass|DreamPass|Info|ecn_Rewa'))
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Store%'
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%ActivePassToGetJoker%'
     OR s.new_sticker_source = 'purchase' OR s.new_sticker_source LIKE '1+%') AS paid
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND s.album_id IN (17,19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal')
    AND s.sticker_collected_min_date <= p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
stu0 AS (
  SELECT album_id, user_id,
    ARRAY_AGG(IF(d <= fin_d, STRUCT(wild, paid, src), NULL) IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS ls,
    LOGICAL_OR(wild AND paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_paid,
    LOGICAL_OR(wild AND NOT paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_game,
    LOGICAL_OR(wild AND paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND a_end) AS pkc_paid,
    LOGICAL_OR(wild AND NOT paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND a_end) AS pkc_game
  FROM st GROUP BY 1,2
),
stu AS (
  SELECT album_id, user_id, IFNULL(ls.wild, FALSE) AS ls_wild, IFNULL(ls.paid, FALSE) AS ls_paid, IFNULL(ls.src, '') AS ls_src,
    pk_paid, pk_game, pkc_paid, pkc_game
  FROM stu0
),
j AS (
  SELECT p.album_id, p.payer, p.alb_rev, p.uniq_m8, p.b_rev, p.b_pd, p.l1_rev, p.l3_pd,
    IFNULL(a.b_ad, 0) AS b_ad, IFNULL(a.l1_ad, 0) AS l1_ad,
    p.fin_d IS NOT NULL AS fin_new, p.fin_d < p.a_end AS fin_old,
    IFNULL(s.ls_wild, FALSE) AS ls_wild, IFNULL(s.ls_paid, FALSE) AS ls_paid, IFNULL(s.ls_src, '') AS ls_src,
    CASE WHEN s.pk_paid THEN 'bought' WHEN s.pk_game THEN 'gameplay' ELSE 'none' END AS route,
    CASE WHEN s.pkc_paid THEN 'bought' WHEN s.pkc_game THEN 'gameplay' ELSE 'none' END AS route_c
  FROM pop p LEFT JOIN act a USING (album_id, user_id) LEFT JOIN stu s USING (album_id, user_id)
),
lab AS (
  SELECT album_id, payer, alb_rev, b_rev, b_pd, l1_rev, l3_pd, b_ad, l1_ad, fin_new, fin_old, ls_wild, ls_paid, ls_src, label FROM j
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    IF(fin_old AND payer, ['F_old_pay'], []), IF(fin_new AND payer, ['F_new_pay'], []),
    IF(fin_new AND NOT IFNULL(fin_old, FALSE) AND payer, ['F_close_pay'], []),
    IF(fin_old AND NOT payer, ['F_old_nonpay'], []), IF(fin_new AND NOT payer, ['F_new_nonpay'], []),
    IF(payer AND uniq_m8 BETWEEN 138 AND 140, [CONCAT('R46_', route), CONCAT('R46c_', route_c), 'R46_all'], []))) AS label
)
SELECT album_id, label, COUNT(*) AS n, ROUND(SUM(alb_rev)) AS rev,
  COUNTIF(fin_old) AS fin_old, COUNTIF(fin_new) AS fin_new,
  ROUND(COUNTIF(ls_wild) / COUNT(*), 4) AS last_joker, ROUND(COUNTIF(ls_wild AND ls_paid) / COUNT(*), 4) AS last_paid_joker,
  ROUND(COUNTIF(ls_wild AND ls_src = 'Puzzle') / COUNT(*), 4) AS last_puzzle_joker, ROUND(COUNTIF(ls_src = 'Puzzle') / COUNT(*), 4) AS last_puzzle,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(l1_rev), SUM(l1_ad)), SAFE_DIVIDE(SUM(b_rev), SUM(b_ad))), 3) AS arpdau_d1_vs_base,
  ROUND(SAFE_DIVIDE(SUM(l3_pd) / 3, SUM(b_pd) / 7), 3) AS payrate_l3_vs_base,
  ROUND(SUM(b_pd) / (7 * COUNT(*)), 3) AS payrate_base, ROUND(SUM(l3_pd) / (3 * COUNT(*)), 3) AS payrate_l3
FROM lab GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507, 73.6 GB) — paid = purchase / purchase_gift; Market = gameplay =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 14 DAY) AND DATE_SUB(a_end, INTERVAL 8 DAY), spend, 0)) AS b_rev,
    COUNTIF(spend > 0 AND date_dim BETWEEN DATE_SUB(a_end, INTERVAL 14 DAY) AND DATE_SUB(a_end, INTERVAL 8 DAY)) AS b_pd,
    SUM(IF(date_dim = DATE_SUB(a_end, INTERVAL 1 DAY), spend, 0)) AS l1_rev,
    COUNTIF(spend > 0 AND date_dim BETWEEN DATE_SUB(a_end, INTERVAL 3 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS l3_pd,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, uniq_m8, alb_rev, alb_rev > 0 AS payer, b_rev, b_pd, l1_rev, l3_pd
  FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
act AS (
  SELECT p.album_id, p.user_id,
    COUNTIF(m.act AND m.date_dim <= DATE_SUB(p.a_end, INTERVAL 8 DAY)) AS b_ad,
    COUNTIF(m.act AND m.date_dim = DATE_SUB(p.a_end, INTERVAL 1 DAY)) AS l1_ad
  FROM pop p JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2
),
st AS (
  SELECT s.album_id, s.user_id, p.a_end, p.fin_d, s.sticker_collected_min_ts AS ts, s.sticker_collected_min_date AS d,
    IFNULL(s.collected_by_joker_flag, FALSE) AS wild, IFNULL(s.new_sticker_source, '') AS src,
    IFNULL(s.new_sticker_source, '') IN ('purchase', 'purchase_gift') AS paid
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND s.album_id IN (14,15)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal')
    AND s.sticker_collected_min_date <= p.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
stu0 AS (
  SELECT album_id, user_id,
    ARRAY_AGG(IF(d <= fin_d, STRUCT(wild, paid, src), NULL) IGNORE NULLS ORDER BY ts DESC LIMIT 1)[SAFE_OFFSET(0)] AS ls,
    LOGICAL_OR(wild AND paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_paid,
    LOGICAL_OR(wild AND NOT paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_game,
    LOGICAL_OR(wild AND paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND a_end) AS pkc_paid,
    LOGICAL_OR(wild AND NOT paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND a_end) AS pkc_game
  FROM st GROUP BY 1,2
),
stu AS (
  SELECT album_id, user_id, IFNULL(ls.wild, FALSE) AS ls_wild, IFNULL(ls.paid, FALSE) AS ls_paid, IFNULL(ls.src, '') AS ls_src,
    pk_paid, pk_game, pkc_paid, pkc_game
  FROM stu0
),
j AS (
  SELECT p.album_id, p.payer, p.alb_rev, p.uniq_m8, p.b_rev, p.b_pd, p.l1_rev, p.l3_pd,
    IFNULL(a.b_ad, 0) AS b_ad, IFNULL(a.l1_ad, 0) AS l1_ad,
    p.fin_d IS NOT NULL AS fin_new, p.fin_d < p.a_end AS fin_old,
    IFNULL(s.ls_wild, FALSE) AS ls_wild, IFNULL(s.ls_paid, FALSE) AS ls_paid, IFNULL(s.ls_src, '') AS ls_src,
    CASE WHEN s.pk_paid THEN 'bought' WHEN s.pk_game THEN 'gameplay' ELSE 'none' END AS route,
    CASE WHEN s.pkc_paid THEN 'bought' WHEN s.pkc_game THEN 'gameplay' ELSE 'none' END AS route_c
  FROM pop p LEFT JOIN act a USING (album_id, user_id) LEFT JOIN stu s USING (album_id, user_id)
),
lab AS (
  SELECT album_id, payer, alb_rev, b_rev, b_pd, l1_rev, l3_pd, b_ad, l1_ad, fin_new, fin_old, ls_wild, ls_paid, ls_src, label FROM j
  CROSS JOIN UNNEST(ARRAY_CONCAT(
    IF(fin_old AND payer, ['F_old_pay'], []), IF(fin_new AND payer, ['F_new_pay'], []),
    IF(fin_new AND NOT IFNULL(fin_old, FALSE) AND payer, ['F_close_pay'], []),
    IF(fin_old AND NOT payer, ['F_old_nonpay'], []), IF(fin_new AND NOT payer, ['F_new_nonpay'], []),
    IF(payer AND uniq_m8 BETWEEN 138 AND 140, [CONCAT('R46_', route), CONCAT('R46c_', route_c), 'R46_all'], []))) AS label
)
SELECT album_id, label, COUNT(*) AS n, ROUND(SUM(alb_rev)) AS rev,
  COUNTIF(fin_old) AS fin_old, COUNTIF(fin_new) AS fin_new,
  ROUND(COUNTIF(ls_wild) / COUNT(*), 4) AS last_joker, ROUND(COUNTIF(ls_wild AND ls_paid) / COUNT(*), 4) AS last_paid_joker,
  ROUND(COUNTIF(ls_wild AND ls_src = 'marketplace') / COUNT(*), 4) AS last_market_joker, ROUND(COUNTIF(ls_src = 'marketplace') / COUNT(*), 4) AS last_market,
  ROUND(SAFE_DIVIDE(SAFE_DIVIDE(SUM(l1_rev), SUM(l1_ad)), SAFE_DIVIDE(SUM(b_rev), SUM(b_ad))), 3) AS arpdau_d1_vs_base,
  ROUND(SAFE_DIVIDE(SUM(l3_pd) / 3, SUM(b_pd) / 7), 3) AS payrate_l3_vs_base,
  ROUND(SUM(b_pd) / (7 * COUNT(*)), 3) AS payrate_base, ROUND(SUM(l3_pd) / (3 * COUNT(*)), 3) AS payrate_l3
FROM lab GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DOMINO 20 two-Puzzle closers, old vs new (domino-dreams-dbt, 17.2 GB). Old rule reproduces 3,223 / 1,092 / 393 / $287K exactly =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-10-12'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
alb AS (SELECT album_id, ANY_VALUE(a_start) AS a_start, ANY_VALUE(a_end) AS a_end FROM ud GROUP BY 1),
u AS (
  SELECT user_id, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS rev_alb,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud WHERE album_id = 20 GROUP BY 1
),
pop0 AS (
  SELECT user_id, a_end, fin_d, rev_alb FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
tot AS (SELECT SUM(rev_alb) AS pop_rev FROM pop0),
pop AS (SELECT user_id, a_end, fin_d, rev_alb FROM pop0 WHERE fin_d IS NOT NULL),
prv_rev AS (
  SELECT u.user_id, SUM(u.spend) AS rev_prev FROM ud u JOIN alb a USING (album_id)
  WHERE u.album_id = 19 AND u.date_dim < a.a_end AND u.user_id IN (SELECT user_id FROM pop) GROUP BY 1
),
prv_act AS (
  SELECT m.user_id, COUNTIF(m.act) AS ad_prev FROM udm m JOIN alb a ON a.album_id = 19
  WHERE m.date_dim BETWEEN a.a_start AND DATE_SUB(a.a_end, INTERVAL 1 DAY) AND m.user_id IN (SELECT user_id FROM pop) GROUP BY 1
),
st AS (
  SELECT p.user_id, s.sticker_collected_min_ts AS ts, s.sticker_collected_min_date AS d, IFNULL(s.new_sticker_source, '') AS src
  FROM pop p JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = 20 AND s.user_id = p.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-08-01' AND DATE '2026-10-12' AND s.album_id = 20 AND s.user_collected_sticker_flag
    AND LOWER(s.sticker_type) IN ('common','golden','royal') AND s.sticker_collected_min_date <= p.fin_d
  QUALIFY ROW_NUMBER() OVER (PARTITION BY p.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
last2 AS (
  SELECT user_id, COUNTIF(src = 'Puzzle') AS puz2
  FROM (SELECT user_id, src FROM st QUALIFY ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY ts DESC) <= 2)
  GROUP BY 1
),
d AS (
  SELECT p.user_id, p.fin_d < p.a_end AS fin_old, p.rev_alb, p.rev_alb > 0 AS payer,
    IFNULL(SAFE_DIVIDE(r.rev_prev, a.ad_prev), 0) >= 5 AS strong,
    IFNULL(l.puz2, 0) = 2 AS both_puzzle
  FROM pop p LEFT JOIN prv_rev r USING (user_id) LEFT JOIN prv_act a USING (user_id) LEFT JOIN last2 l USING (user_id)
)
SELECT rule, COUNT(*) AS finishers, COUNTIF(both_puzzle) AS two_puzzle,
  COUNTIF(both_puzzle AND payer) AS two_puzzle_paid, COUNTIF(both_puzzle AND NOT payer) AS two_puzzle_nonpay,
  COUNTIF(both_puzzle AND strong) AS two_puzzle_strong, ROUND(SUM(IF(both_puzzle AND strong, rev_alb, 0))) AS strong_rev,
  ROUND(SUM(IF(both_puzzle, rev_alb, 0))) AS two_puzzle_rev, ROUND(ANY_VALUE(tot.pop_rev)) AS pop_rev
FROM d CROSS JOIN tot CROSS JOIN UNNEST(IF(fin_old, ['old', 'new'], ['new'])) AS rule
GROUP BY 1 ORDER BY 1
;
