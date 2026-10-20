-- Hypothesis (Eden, 2026-10-20): in Disney's last week free sticker supply does not dry up, so players who are still short
-- never feel "dry" and do not move to buying; in Dice / Domino the free supply dries up and buying takes over.
-- Results: claude/dryness-last-week-2026-10-20.md
-- Population: standard population payers (album-table spend > 0, start..close-1) missing 2-10 of 144 on the close-8 row,
--   split 2-3 (near) and 4-10 (far). Albums Dice 61/63, Domino 19/20, Disney 14/15 (pooled per game).
-- Per day k = close-14 .. close-1: share with >= 1 new FREE sticker (not bought with money; Market / events = free, Eden's rule),
--   free new stickers per player, share with >= 1 new BOUGHT sticker, pay rate (album-table spend > 0 that day).
-- Paid rule: Dice = sticker_pack_key 'Pricing%'; Domino = validated campaign rule (2026-10-15); Disney = purchase / purchase_gift.

-- ===== DISNEY 14/15 (solitaire-dreams-411507) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (
  SELECT album_id, user_id, a_end, uniq_m8, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev, IF(144 - uniq_m8 <= 3, 'near_2_3', 'far_4_10') AS grp
  FROM pop0 WHERE alb_rev > 0 AND 144 - uniq_m8 BETWEEN 2 AND 10
),
days AS (
  SELECT p.album_id, p.user_id, p.grp, k, DATE_SUB(p.a_end, INTERVAL k DAY) AS d FROM pop p, UNNEST(GENERATE_ARRAY(1, 14)) AS k
),
sp AS (
  SELECT d.album_id, d.user_id, d.k, IFNULL(x.spend, 0) > 0 AS paid_day
  FROM days d LEFT JOIN ud x ON x.album_id = d.album_id AND x.user_id = d.user_id AND x.date_dim = d.d
),
st AS (
  SELECT s.album_id, s.user_id, DATE_DIFF(p.a_end, s.sticker_collected_min_date, DAY) AS k,
    IFNULL(s.new_sticker_source, '') IN ('purchase', 'purchase_gift') AS bought
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND s.album_id IN (14,15)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal')
    AND s.sticker_collected_min_date BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY)
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
stk AS (
  SELECT album_id, user_id, k, COUNTIF(NOT bought) AS free_n, COUNTIF(bought) AS bought_n FROM st GROUP BY 1,2,3
),
x AS (
  SELECT d.album_id, d.grp, d.k, IFNULL(s.free_n, 0) AS free_n, IFNULL(s.bought_n, 0) AS bought_n, sp.paid_day
  FROM days d LEFT JOIN stk s USING (album_id, user_id, k) LEFT JOIN sp USING (album_id, user_id, k)
),
g AS (
  SELECT p.grp, COUNT(*) AS n_player_albums, ROUND(SUM(p.alb_rev) / (SELECT SUM(pop_rev) FROM tot), 4) AS rev_share_pooled
  FROM pop p GROUP BY 1
)
SELECT x.grp, x.k, ANY_VALUE(g.n_player_albums) AS n, ANY_VALUE(g.rev_share_pooled) AS rev_share,
  ROUND(AVG(IF(x.free_n > 0, 1, 0)), 3) AS got_free, ROUND(AVG(x.free_n), 2) AS free_per_player,
  ROUND(AVG(IF(x.bought_n > 0, 1, 0)), 3) AS got_bought, ROUND(AVG(IF(x.paid_day, 1, 0)), 3) AS pay_rate
FROM x JOIN g USING (grp)
GROUP BY 1,2 ORDER BY 1,2 DESC
;

-- ===== DICE 61/63 (dice-dreams-dbt) — same output =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (
  SELECT album_id, user_id, a_end, uniq_m8, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev, IF(144 - uniq_m8 <= 3, 'near_2_3', 'far_4_10') AS grp
  FROM pop0 WHERE alb_rev > 0 AND 144 - uniq_m8 BETWEEN 2 AND 10
),
days AS (
  SELECT p.album_id, p.user_id, p.grp, k, DATE_SUB(p.a_end, INTERVAL k DAY) AS d FROM pop p, UNNEST(GENERATE_ARRAY(1, 14)) AS k
),
sp AS (
  SELECT d.album_id, d.user_id, d.k, IFNULL(x.spend, 0) > 0 AS paid_day
  FROM days d LEFT JOIN ud x ON x.album_id = d.album_id AND x.user_id = d.user_id AND x.date_dim = d.d
),
st AS (
  SELECT s.album_id, s.user_id, DATE_DIFF(p.a_end, s.sticker_collected_date, DAY) AS k,
    IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' AS bought
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE)
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_ts) = 1
),
stk AS (
  SELECT album_id, user_id, k, COUNTIF(NOT bought) AS free_n, COUNTIF(bought) AS bought_n FROM st WHERE k BETWEEN 1 AND 14 GROUP BY 1,2,3
),
x AS (
  SELECT d.album_id, d.grp, d.k, IFNULL(s.free_n, 0) AS free_n, IFNULL(s.bought_n, 0) AS bought_n, sp.paid_day
  FROM days d LEFT JOIN stk s USING (album_id, user_id, k) LEFT JOIN sp USING (album_id, user_id, k)
),
g AS (
  SELECT p.grp, COUNT(*) AS n_player_albums, ROUND(SUM(p.alb_rev) / (SELECT SUM(pop_rev) FROM tot), 4) AS rev_share_pooled
  FROM pop p GROUP BY 1
)
SELECT x.grp, x.k, ANY_VALUE(g.n_player_albums) AS n, ANY_VALUE(g.rev_share_pooled) AS rev_share,
  ROUND(AVG(IF(x.free_n > 0, 1, 0)), 3) AS got_free, ROUND(AVG(x.free_n), 2) AS free_per_player,
  ROUND(AVG(IF(x.bought_n > 0, 1, 0)), 3) AS got_bought, ROUND(AVG(IF(x.paid_day, 1, 0)), 3) AS pay_rate
FROM x JOIN g USING (grp)
GROUP BY 1,2 ORDER BY 1,2 DESC
;

-- ===== DOMINO 19/20 (domino-dreams-dbt) — same output =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    MAX(IF(date_dim = DATE_SUB(a_end, INTERVAL 8 DAY), uniq, NULL)) AS uniq_m8,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (
  SELECT album_id, user_id, a_end, uniq_m8, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
pop AS (
  SELECT album_id, user_id, a_end, alb_rev, IF(144 - uniq_m8 <= 3, 'near_2_3', 'far_4_10') AS grp
  FROM pop0 WHERE alb_rev > 0 AND 144 - uniq_m8 BETWEEN 2 AND 10
),
days AS (
  SELECT p.album_id, p.user_id, p.grp, k, DATE_SUB(p.a_end, INTERVAL k DAY) AS d FROM pop p, UNNEST(GENERATE_ARRAY(1, 14)) AS k
),
sp AS (
  SELECT d.album_id, d.user_id, d.k, IFNULL(x.spend, 0) > 0 AS paid_day
  FROM days d LEFT JOIN ud x ON x.album_id = d.album_id AND x.user_id = d.user_id AND x.date_dim = d.d
),
st AS (
  SELECT s.album_id, s.user_id, DATE_DIFF(p.a_end, s.sticker_collected_min_date, DAY) AS k,
    (   (IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Offer%'
         AND NOT REGEXP_CONTAINS(IFNULL(s.new_sticker_mtx_campaign_name, ''), r'SeasonPass|DreamPass|Info|ecn_Rewa'))
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%t_Store%'
     OR IFNULL(s.new_sticker_mtx_campaign_name, '') LIKE '%ActivePassToGetJoker%'
     OR s.new_sticker_source = 'purchase' OR s.new_sticker_source LIKE '1+%') AS bought
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN pop p USING (album_id, user_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-01' AND DATE '2026-10-12' AND s.album_id IN (19,20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) IN ('common','golden','royal')
    AND s.sticker_collected_min_date BETWEEN DATE_SUB(p.a_end, INTERVAL 14 DAY) AND DATE_SUB(p.a_end, INTERVAL 1 DAY)
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
stk AS (
  SELECT album_id, user_id, k, COUNTIF(NOT bought) AS free_n, COUNTIF(bought) AS bought_n FROM st GROUP BY 1,2,3
),
x AS (
  SELECT d.album_id, d.grp, d.k, IFNULL(s.free_n, 0) AS free_n, IFNULL(s.bought_n, 0) AS bought_n, sp.paid_day
  FROM days d LEFT JOIN stk s USING (album_id, user_id, k) LEFT JOIN sp USING (album_id, user_id, k)
),
g AS (
  SELECT p.grp, COUNT(*) AS n_player_albums, ROUND(SUM(p.alb_rev) / (SELECT SUM(pop_rev) FROM tot), 4) AS rev_share_pooled
  FROM pop p GROUP BY 1
)
SELECT x.grp, x.k, ANY_VALUE(g.n_player_albums) AS n, ANY_VALUE(g.rev_share_pooled) AS rev_share,
  ROUND(AVG(IF(x.free_n > 0, 1, 0)), 3) AS got_free, ROUND(AVG(x.free_n), 2) AS free_per_player,
  ROUND(AVG(IF(x.bought_n > 0, 1, 0)), 3) AS got_bought, ROUND(AVG(IF(x.paid_day, 1, 0)), 3) AS pay_rate
FROM x JOIN g USING (grp)
GROUP BY 1,2 ORDER BY 1,2 DESC
;
