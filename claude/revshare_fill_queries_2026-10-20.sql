-- Revenue shares for deck populations that had none (Eden 2026-10-20: every population shows its share of album revenue).
-- Results: claude/revshare-fill-2026-10-20.md
-- Same populations as the slides: standard population (not first album, not excluded, login ratio >= 0.5 on the last row before close,
-- row on close-1); payer = album-table spend > 0, start..close-1 (as when the slides were built; the close-day payer rule adds 0.2-0.4%).
-- Share = group's album revenue (album-table spend, start..close-1) / revenue of the whole standard population.
-- Labels: M23 / M46 / M710 = payers missing 2-3 / 4-6 / 7-10 of 144 on the close-8 row (half-completions); M26 = 2-6 (Disney test 1);
-- SS = M46 and $5-15 per active day in days 14-8 (same-spend); R46_<route> = M46 by Wild / Joker route in close-7..close-1 (routes);
-- FIN = payer finishers, 144 by the end of the close day (Domino 17 row of domino-3albums); POP = whole population.

-- ===== DICE 61/63 (dice-dreams-dbt) =====
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
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8, SUM(spend) AS alb_rev,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 14 DAY) AND DATE_SUB(a_end, INTERVAL 8 DAY), spend, 0)) AS b_rev,
    ARRAY_AGG(STRUCT(lr, past, excl) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l, MAX(date_dim) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, uniq_m8, alb_rev, alb_rev > 0 AS payer, b_rev
  FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
act AS (
  SELECT p.album_id, p.user_id, COUNTIF(m.act) AS b_ad
  FROM pop p JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 8 DAY)
  WHERE p.payer AND 144 - p.uniq_m8 BETWEEN 4 AND 6
  GROUP BY 1,2
),
st AS (
  SELECT s.album_id, s.user_id, p.a_end, s.sticker_id, s.sticker_collected_date AS d,
    IFNULL(s.collected_from_wild, FALSE) AS wild, IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AS paid
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE)
    AND p.payer AND 144 - p.uniq_m8 BETWEEN 4 AND 6
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1
),
stu AS (
  SELECT album_id, user_id,
    LOGICAL_OR(wild AND paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_paid,
    LOGICAL_OR(wild AND NOT paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_game
  FROM st GROUP BY 1,2
),
fin AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2
),
j AS (
  SELECT p.album_id, p.payer, p.alb_rev, 144 - p.uniq_m8 AS miss8, IFNULL(f.n_uniq, 0) >= 144 AS fin,
    SAFE_DIVIDE(p.b_rev, a.b_ad) AS b_pad,
    CASE WHEN s.pk_paid THEN 'bought' WHEN s.pk_game THEN 'gameplay' ELSE 'none' END AS route
  FROM pop p LEFT JOIN act a USING (album_id, user_id) LEFT JOIN stu s USING (album_id, user_id) LEFT JOIN fin f USING (album_id, user_id)
),
lab AS (
  SELECT album_id, alb_rev, label FROM j
  CROSS JOIN UNNEST(ARRAY_CONCAT(['POP'],
    IF(payer AND miss8 BETWEEN 2 AND 3, ['M23'], []), IF(payer AND miss8 BETWEEN 4 AND 6, ['M46', CONCAT('R46_', route)], []),
    IF(payer AND miss8 BETWEEN 7 AND 10, ['M710'], []), IF(payer AND miss8 BETWEEN 2 AND 6, ['M26'], []),
    IF(payer AND miss8 BETWEEN 4 AND 6 AND b_pad BETWEEN 5 AND 15, ['SS'], []), IF(payer AND fin, ['FIN'], []))) AS label
),
t AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM j GROUP BY 1)
SELECT l.album_id, l.label, COUNT(*) AS n, ROUND(SUM(l.alb_rev)) AS rev, ROUND(SUM(l.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
FROM lab l JOIN t USING (album_id) GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DOMINO 17/19 (domino-dreams-dbt) — paid Joker = validated campaign rule (2026-10-15) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-09-10' AND album_id IN (17,19) AND date_dim <= album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-09-10'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    SUM(IF(date_dim BETWEEN DATE_SUB(a_end, INTERVAL 14 DAY) AND DATE_SUB(a_end, INTERVAL 8 DAY), spend, 0)) AS b_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, uniq_m8, alb_rev, alb_rev > 0 AS payer, b_rev
  FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
act AS (
  SELECT p.album_id, p.user_id, COUNTIF(m.act) AS b_ad
  FROM pop p JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 8 DAY)
  WHERE p.payer AND 144 - p.uniq_m8 BETWEEN 4 AND 6
  GROUP BY 1,2
),
st AS (
  SELECT s.album_id, s.user_id, p.a_end, s.sticker_collected_min_date AS d,
    IFNULL(s.collected_by_joker_flag, FALSE) AS wild,
    (   (IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Offer%'
         AND NOT REGEXP_CONTAINS(IFNULL(s.new_sticker_mtx_campaign_name, ''), r'SeasonPass|DreamPass|Info|ecn_Rewa'))
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Store%'
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%ActivePassToGetJoker%'
     OR s.new_sticker_source = 'purchase' OR s.new_sticker_source LIKE '1+%') AS paid
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-03-25' AND DATE '2026-09-10' AND s.album_id IN (17,19)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal')
    AND p.payer AND 144 - p.uniq_m8 BETWEEN 4 AND 6
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
stu AS (
  SELECT album_id, user_id,
    LOGICAL_OR(wild AND paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_paid,
    LOGICAL_OR(wild AND NOT paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_game
  FROM st GROUP BY 1,2
),
j AS (
  SELECT p.album_id, p.payer, p.alb_rev, 144 - p.uniq_m8 AS miss8, p.fin_d IS NOT NULL AS fin,
    SAFE_DIVIDE(p.b_rev, a.b_ad) AS b_pad,
    CASE WHEN s.pk_paid THEN 'bought' WHEN s.pk_game THEN 'gameplay' ELSE 'none' END AS route
  FROM pop p LEFT JOIN act a USING (album_id, user_id) LEFT JOIN stu s USING (album_id, user_id)
),
lab AS (
  SELECT album_id, alb_rev, label FROM j
  CROSS JOIN UNNEST(ARRAY_CONCAT(['POP'],
    IF(payer AND miss8 BETWEEN 2 AND 3, ['M23'], []), IF(payer AND miss8 BETWEEN 4 AND 6, ['M46', CONCAT('R46_', route)], []),
    IF(payer AND miss8 BETWEEN 7 AND 10, ['M710'], []), IF(payer AND miss8 BETWEEN 2 AND 6, ['M26'], []),
    IF(payer AND miss8 BETWEEN 4 AND 6 AND b_pad BETWEEN 5 AND 15, ['SS'], []), IF(payer AND fin, ['FIN'], []))) AS label
),
t AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM j GROUP BY 1)
SELECT l.album_id, l.label, COUNT(*) AS n, ROUND(SUM(l.alb_rev)) AS rev, ROUND(SUM(l.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
FROM lab l JOIN t USING (album_id) GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DISNEY 14/15 (solitaire-dreams-411507) — paid = purchase / purchase_gift; Market = gameplay =====
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
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, uniq_m8, alb_rev, alb_rev > 0 AS payer, b_rev
  FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
act AS (
  SELECT p.album_id, p.user_id, COUNTIF(m.act) AS b_ad
  FROM pop p JOIN udm m ON m.user_id = p.user_id AND m.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 8 DAY)
  WHERE p.payer AND 144 - p.uniq_m8 BETWEEN 4 AND 6
  GROUP BY 1,2
),
st AS (
  SELECT s.album_id, s.user_id, p.a_end, s.sticker_collected_min_date AS d,
    IFNULL(s.collected_by_joker_flag, FALSE) AS wild,
    IFNULL(s.new_sticker_source, '') IN ('purchase', 'purchase_gift') AS paid
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND s.album_id IN (14,15)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal')
    AND p.payer AND 144 - p.uniq_m8 BETWEEN 4 AND 6
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
stu AS (
  SELECT album_id, user_id,
    LOGICAL_OR(wild AND paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_paid,
    LOGICAL_OR(wild AND NOT paid AND d BETWEEN DATE_SUB(a_end, INTERVAL 7 DAY) AND DATE_SUB(a_end, INTERVAL 1 DAY)) AS pk_game
  FROM st GROUP BY 1,2
),
j AS (
  SELECT p.album_id, p.payer, p.alb_rev, 144 - p.uniq_m8 AS miss8, p.fin_d IS NOT NULL AS fin,
    SAFE_DIVIDE(p.b_rev, a.b_ad) AS b_pad,
    CASE WHEN s.pk_paid THEN 'bought' WHEN s.pk_game THEN 'gameplay' ELSE 'none' END AS route
  FROM pop p LEFT JOIN act a USING (album_id, user_id) LEFT JOIN stu s USING (album_id, user_id)
),
lab AS (
  SELECT album_id, alb_rev, label FROM j
  CROSS JOIN UNNEST(ARRAY_CONCAT(['POP'],
    IF(payer AND miss8 BETWEEN 2 AND 3, ['M23'], []), IF(payer AND miss8 BETWEEN 4 AND 6, ['M46', CONCAT('R46_', route)], []),
    IF(payer AND miss8 BETWEEN 7 AND 10, ['M710'], []), IF(payer AND miss8 BETWEEN 2 AND 6, ['M26'], []),
    IF(payer AND miss8 BETWEEN 4 AND 6 AND b_pad BETWEEN 5 AND 15, ['SS'], []), IF(payer AND fin, ['FIN'], []))) AS label
),
t AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM j GROUP BY 1)
SELECT l.album_id, l.label, COUNT(*) AS n, ROUND(SUM(l.alb_rev)) AS rev, ROUND(SUM(l.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS rev_share
FROM lab l JOIN t USING (album_id) GROUP BY 1,2 ORDER BY 1,2
;

-- ===== DOMINO 19/20 spend groups (domino-easier) =====
-- Reran unchanged: "GROUPS — DOMINO 19/20" in claude/finisher_recount_queries.sql (19.4 GB). Group share = payer_rev of the group / payer_rev of 'all'
-- (daily-metrics revenue in album days, all eligible players; non-payers add 0).
