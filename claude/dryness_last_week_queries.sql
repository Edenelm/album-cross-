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

-- ===== DICE 61/63 — payout around close by how the album ended (Eden 2026-10-20: "what does the payout look like the day after
-- for players who did not finish but were close"). Payout = free rolls in (30_intermediate.user_daily_rolls_in_out.rolls_in_sum;
-- purchased rolls are a separate column and are left out). Standard population payers; status at the end of the close day from the
-- sticker table: finished / 1 missing / 2-3 missing / 4+ missing. Per player: free rolls on day k ÷ own usual free rolls per day
-- (close-18..close-5); median by group. Also group ratio free rolls ÷ rolls played, players rolling 5M+ in a day left out.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5),
tot AS (SELECT album_id, SUM(alb_rev) AS pop_rev FROM pop0 GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop0 p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2
),
pop AS (
  SELECT p.album_id, p.user_id, p.a_end, p.alb_rev,
    CASE WHEN IFNULL(s.n_uniq,0) >= 144 THEN 'a_finished' WHEN 144 - IFNULL(s.n_uniq,0) = 1 THEN 'b_miss1'
         WHEN 144 - IFNULL(s.n_uniq,0) <= 3 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp
  FROM pop0 p LEFT JOIN st s USING (album_id, user_id) WHERE p.rev_c > 0
),
r AS (
  SELECT user_id, date_dim, IFNULL(rolls_in_sum,0) AS free_in, IFNULL(rolls_out_sum,0) AS played
  FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-12'
),
big AS (SELECT DISTINCT user_id FROM r WHERE played >= 5000000),
x AS (
  SELECT p.album_id, p.user_id, p.grp, DATE_DIFF(r.date_dim, p.a_end, DAY) AS dk, r.free_in, r.played
  FROM pop p JOIN r ON r.user_id = p.user_id AND r.date_dim BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 3 DAY)
  WHERE p.user_id NOT IN (SELECT user_id FROM big)
),
hab AS (SELECT album_id, user_id, SUM(IF(dk BETWEEN -18 AND -5, free_in, 0)) / 14 AS h FROM x GROUP BY 1,2),
dd AS (
  SELECT x.grp, x.dk, APPROX_QUANTILES(SAFE_DIVIDE(x.free_in, h.h), 2)[OFFSET(1)] AS med_idx,
    SAFE_DIVIDE(SUM(x.free_in), SUM(x.played)) AS grp_payout
  FROM x JOIN hab h USING (album_id, user_id) WHERE x.dk BETWEEN -3 AND 3 AND h.h > 0 GROUP BY 1,2
),
g AS (SELECT p.grp, COUNT(*) AS n, ROUND(SUM(p.alb_rev) / (SELECT SUM(pop_rev) FROM tot), 4) AS rev_share FROM pop p GROUP BY 1)
SELECT g.grp, g.n, g.rev_share,
  STRING_AGG(CONCAT(CAST(dd.dk AS STRING), ':', CAST(ROUND(dd.med_idx, 2) AS STRING), '/', CAST(ROUND(dd.grp_payout, 2) AS STRING)), ' ' ORDER BY dd.dk) AS series
FROM dd JOIN g USING (grp) GROUP BY 1,2,3 ORDER BY 1
;

-- ===== DICE 61/63 — daily PAYOUT around close by end status, Eden's Mixpanel definition (board 10105792, tile "Payout", 2026-10-20) =====
-- Mixpanel: Payout = (rolls in − purchased rolls in) ÷ (bet multiplier + prime cost on roll), rolls-in events of 1..750K,
--   rolls-in sources grouped as RV / Roll Timer / Daily Gift & Anti-Churn / Invite Friends / Deep Links / Pending Reward / DDJ left out;
--   players who held a roll balance above 1.2M left out.
-- BigQuery approximation (curated 20_core views): rolls in by raw source name (RV via 'rv' / 'advertisement reward'; daily gift via
--   rewardcalendar / 1plus6_welcomeback / 7_rewards_kingdoms_nocloseButton; DDJ and campaign-name rules not available);
--   purchased rolls from 20_core.purchase_completed_vw (rolls_amount, offer_type <> 'other'); rolls staked = rolls_out rolls_value.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_c,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop0 AS (SELECT album_id, user_id, a_end, alb_rev, rev_c FROM u WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5),
st AS (
  SELECT s.album_id, s.user_id, COUNT(DISTINCT s.sticker_id) AS n_uniq
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN pop0 p USING (album_id, user_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND s.album_id IN (61,63)
    AND s.sticker_type IN ('common','golden','super') AND IFNULL(s.is_sticker_collected, TRUE) AND s.sticker_collected_date <= p.a_end
  GROUP BY 1,2
),
pop AS (
  SELECT p.album_id, p.user_id, p.a_end,
    CASE WHEN IFNULL(s.n_uniq,0) >= 144 THEN 'a_finished' WHEN 144 - IFNULL(s.n_uniq,0) = 1 THEN 'b_miss1'
         WHEN 144 - IFNULL(s.n_uniq,0) <= 3 THEN 'c_miss2_3' ELSE 'd_miss4plus' END AS grp
  FROM pop0 p LEFT JOIN st s USING (album_id, user_id) WHERE p.rev_c > 0
),
ev AS (
  SELECT user_id, date_dim AS d, roll_type, LOWER(IFNULL(source,'')) AS src, rolls_value AS v, rolls_balance AS bal
  FROM `dice-dreams-dbt.20_core.rolls_in_out_vw`
  WHERE (pdate BETWEEN DATE '2026-07-09' AND DATE '2026-07-31' OR pdate BETWEEN DATE '2026-08-20' AND DATE '2026-09-11')
),
bigbal AS (SELECT DISTINCT user_id FROM ev WHERE bal > 1200000),
dayx AS (
  SELECT user_id, d,
    SUM(IF(roll_type = 'rolls_out', v, 0)) AS staked,
    SUM(IF(roll_type = 'rolls_in' AND v BETWEEN 1 AND 750000
           AND NOT (src IN ('roll timer','rolls timer','advertisement reward','invite friend','deeplinkreward','pendingrewards','','rewardcalendar','1plus6_welcomeback','7_rewards_kingdoms_noclosebutton')
                    OR REGEXP_CONTAINS(src, r'(^|_)rv($|_)')), v, 0)) AS rin
  FROM ev GROUP BY 1,2
),
pur AS (
  SELECT user_id, DATE(timestamp) AS d, SUM(IF(rolls_amount BETWEEN 1 AND 750000, rolls_amount, 0)) AS bought
  FROM `dice-dreams-dbt.20_core.purchase_completed_vw`
  WHERE DATE(timestamp) BETWEEN DATE '2026-07-09' AND DATE '2026-09-11' AND offer_type <> 'other'
  GROUP BY 1,2
),
x AS (
  SELECT p.grp, DATE_DIFF(dx.d, p.a_end, DAY) AS dk, dx.staked, dx.rin, IFNULL(pu.bought, 0) AS bought
  FROM pop p JOIN dayx dx ON dx.user_id = p.user_id AND dx.d BETWEEN DATE_SUB(p.a_end, INTERVAL 18 DAY) AND DATE_ADD(p.a_end, INTERVAL 3 DAY)
  LEFT JOIN pur pu ON pu.user_id = p.user_id AND pu.d = dx.d
  WHERE p.user_id NOT IN (SELECT user_id FROM bigbal)
)
SELECT m.grp, m.payout_mid_album,
  STRING_AGG(CONCAT(CAST(dd.dk AS STRING), ':', CAST(dd.payout AS STRING)), ' ' ORDER BY dd.dk) AS payout_by_day
FROM (SELECT grp, ROUND(100 * SAFE_DIVIDE(SUM(rin) - SUM(bought), SUM(staked)), 1) AS payout_mid_album FROM x WHERE dk BETWEEN -18 AND -5 GROUP BY 1) m
JOIN (SELECT grp, dk, ROUND(100 * SAFE_DIVIDE(SUM(rin) - SUM(bought), SUM(staked)), 1) AS payout FROM x WHERE dk BETWEEN -3 AND 3 GROUP BY 1,2) dd USING (grp)
GROUP BY 1,2 ORDER BY 1
;
