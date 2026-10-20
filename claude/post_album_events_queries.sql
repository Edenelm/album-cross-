-- 2026-10-19 PROPOSED, NOT RUN: post-album events for finishers (completion day -> album close; close day = next album day 1).
-- Eden's events: Domino = Deluxe album event; Dice = Fortune Wheel + Momentum Quest (album finishers); Disney = Legendary set.
-- Discovery so far:
--   Domino: domino-dreams-dbt.prod_50_reporting.user_deluxe_album_last_state (user x album; deluxe stickers, wheel tiers, deluxe_album_spent_lt = spend from Deluxe start).
--           Entrants, all users, no filters: album 17 = 7,304 (first start 04-27), 18 = 32,789, 19 = 12,701 (08-13), 20 = 23,357 (09-27).
--   Dice:   finisher campaigns in dice-dreams-dbt.20_core.dim_campaign:
--           album 61: 92071 220726_ExtraLayer_AlbumFinishers_Curtains_FortuneWheel; 92120 220726_Quest2_PackRushWorldChampeons_ALBUMFINISHERS_VerticalQuest
--           album 63: 93719 020926_TopLayer_AlbumFinishers_FortuneWheel
--           album 65: 95366 151026_TopLayer_Albumfinishers_Curtains_Fortunewheelforalbumfinishers
--           No campaign named "Momentum Quest" for finishers found (needs Eden). No purchases are tagged with these campaigns
--           (fact_purchase_completed, 07-18..07-28 and 08-29..09-08) -> revenue = participants' spend in the window, not event-attributed.
--           Participation source: dice-dreams-dbt.40_mart.fact_dynamic_resource_given (campaign_id), dry run up to 155 GB (clustered on campaign_name).
--   Disney: no Legendary table in solitaire-dreams-411507.bi_prod. Options: extra sets (13+) in user_daily_album (Magic Sets are extra sets too),
--           or bi_prod.fact_user_mtx_campaign_daily by campaign name (lookup dry run 260 GB). Needs Eden's identifier.
-- Metrics (same for all games): standard population (not first album, login ratio >= 0.5 on last row before close, not special, not cheater).
--   finishers (144 unique set stickers before close); participants; % of finishers / players / payers;
--   participants' album revenue share; spend after completion day up to close-1 as % of album revenue; full days left after completion.

-- ===== DOMINO (dry run 16.36 GB) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND album_id IN (17,19,20) AND date_dim < album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d, SUM(spend) AS alb_rev,
    ARRAY_AGG(STRUCT(lr, past, excl) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l, MAX(date_dim) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
post AS (
  SELECT p.album_id, p.user_id, SUM(IF(x.date_dim > p.fin_d, x.spend, 0)) AS post_rev
  FROM pop p JOIN ud x ON x.album_id = p.album_id AND x.user_id = p.user_id
  WHERE p.fin_d IS NOT NULL GROUP BY 1,2
),
dlx AS (
  SELECT album_id, user_id, deluxe_album_stickers_lt AS dst, tiers_completed_lt AS dtiers, deluxe_album_spent_lt AS dspend
  FROM `domino-dreams-dbt.prod_50_reporting.user_deluxe_album_last_state`
  WHERE album_close_date BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND album_id IN (17,19,20)
)
SELECT p.album_id,
  COUNT(*) AS pop_all, COUNTIF(p.alb_rev > 0) AS pop_payers, ROUND(SUM(p.alb_rev)) AS pop_rev,
  COUNTIF(p.fin_d IS NOT NULL) AS fin_all, COUNTIF(p.fin_d IS NOT NULL AND p.alb_rev > 0) AS fin_payers, ROUND(SUM(IF(p.fin_d IS NOT NULL, p.alb_rev, 0))) AS fin_rev,
  COUNTIF(p.fin_d IS NOT NULL AND DATE_DIFF(p.a_end, p.fin_d, DAY) >= 2) AS fin_with_full_day_after,
  ROUND(AVG(IF(p.fin_d IS NOT NULL, DATE_DIFF(p.a_end, p.fin_d, DAY) - 1, NULL)), 2) AS avg_full_days_after,
  COUNTIF(d.user_id IS NOT NULL) AS dlx_all, COUNTIF(d.user_id IS NOT NULL AND p.alb_rev > 0) AS dlx_payers,
  COUNTIF(d.dst > 0) AS dlx_with_sticker, COUNTIF(d.dtiers > 0) AS dlx_with_tier,
  ROUND(SUM(IF(d.user_id IS NOT NULL, p.alb_rev, 0))) AS dlx_alb_rev,
  ROUND(SUM(IFNULL(d.dspend, 0))) AS dlx_spend_from_start,
  ROUND(SUM(IFNULL(t.post_rev, 0))) AS fin_post_rev,
  ROUND(SUM(IF(d.user_id IS NOT NULL, IFNULL(t.post_rev, 0), 0))) AS dlx_post_rev
FROM pop p LEFT JOIN post t USING (album_id, user_id) LEFT JOIN dlx d USING (album_id, user_id)
GROUP BY 1 ORDER BY 1;

-- ===== DICE (dry run 18.22 GB) — Eden 2026-10-19: the finisher "Momentum Quest" = Lava Quest =====
-- Candidate campaigns by date next to the finisher Fortune Wheel (same launch day):
--   album 61 (close 07-27): 92071 FW finishers; 92120 VerticalQuest ALBUMFINISHERS; 92025 220726_LavaQuest_Generic_Lavaquest
--   album 63 (close 09-07): 93719 FW finishers; 93565 020926 SwampSprint LavaQuest; also 93561 (31-08), 93756 (03-09), 93520 (27-08 Generic)
-- Per-campaign rows show what share of each campaign's users are finishers, to confirm which Lava Quest is the finisher one.
-- Participation = got any resource from the campaign (40_mart.fact_dynamic_resource_given). Revenue = album-table spend (no purchases are tagged to these campaigns).
-- Same population rules as post_completion_queries.sql.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim < album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d, SUM(spend) AS alb_rev,
    ARRAY_AGG(STRUCT(lr, past, excl) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l, MAX(date_dim) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
post AS (
  SELECT p.album_id, p.user_id, SUM(IF(x.date_dim > p.fin_d, x.spend, 0)) AS post_rev
  FROM pop p JOIN ud x ON x.album_id = p.album_id AND x.user_id = p.user_id
  WHERE p.fin_d IS NOT NULL GROUP BY 1,2
),
dr AS (
  SELECT IF(date_dim <= DATE '2026-07-27', 61, 63) AS album_id, user_id, campaign_name,
    IF(REGEXP_CONTAINS(LOWER(campaign_name), r'lava'), 'Lava Quest', IF(REGEXP_CONTAINS(LOWER(campaign_name), r'fortunewheel'), 'Fortune Wheel', 'Other finisher quest')) AS ev,
    MIN(date_dim) AS first_d
  FROM `dice-dreams-dbt.40_mart.fact_dynamic_resource_given`
  WHERE (date_dim BETWEEN DATE '2026-07-18' AND DATE '2026-07-27' OR date_dim BETWEEN DATE '2026-08-27' AND DATE '2026-09-07')
    AND campaign_name IN ('220726_ExtraLayer_AlbumFinishers_Curtains_FortuneWheel', '220726_Quest2_PackRushWorldChampeons_ALBUMFINISHERS_VerticalQuest',
      '220726_LavaQuest_Generic_Lavaquest', '020926_TopLayer_AlbumFinishers_FortuneWheel', '020926_TopLayer_SwampSprint_LavaQuest',
      '310826_TopLayer_SwampSprint_LavaQuest', '030926_TopLayer_SwampSprint_LavaQuest', '270826_TopLayer_Generic_LavaQuest')
  GROUP BY 1,2,3,4
),
camp AS (
  SELECT d.album_id, d.campaign_name AS grp, COUNT(DISTINCT d.user_id) AS dr_users,
    COUNT(DISTINCT p.user_id) AS in_pop, COUNT(DISTINCT IF(p.fin_d IS NOT NULL, p.user_id, NULL)) AS pop_finishers,
    COUNT(DISTINCT IF(p.fin_d IS NOT NULL AND d.first_d >= p.fin_d, p.user_id, NULL)) AS fin_joined_after_completion
  FROM dr d LEFT JOIN pop p USING (album_id, user_id) GROUP BY 1,2
),
fe AS (
  SELECT album_id, user_id, LOGICAL_OR(ev = 'Fortune Wheel') AS fw, LOGICAL_OR(ev = 'Lava Quest') AS lava, LOGICAL_OR(ev = 'Other finisher quest') AS oq
  FROM dr GROUP BY 1,2
),
alb AS (
  SELECT p.album_id, 'ALBUM' AS grp,
    COUNT(*) AS pop_all, COUNTIF(p.alb_rev > 0) AS pop_payers, ROUND(SUM(p.alb_rev)) AS pop_rev,
    COUNTIF(p.fin_d IS NOT NULL) AS fin_all, COUNTIF(p.fin_d IS NOT NULL AND p.alb_rev > 0) AS fin_payers, ROUND(SUM(IF(p.fin_d IS NOT NULL, p.alb_rev, 0))) AS fin_rev,
    COUNTIF(p.fin_d IS NOT NULL AND DATE_DIFF(p.a_end, p.fin_d, DAY) >= 2) AS fin_with_full_day_after,
    ROUND(AVG(IF(p.fin_d IS NOT NULL, DATE_DIFF(p.a_end, p.fin_d, DAY) - 1, NULL)), 2) AS avg_full_days_after,
    ROUND(SUM(IFNULL(t.post_rev, 0))) AS fin_post_rev,
    COUNTIF(p.fin_d IS NOT NULL AND e.fw) AS fin_fw, COUNTIF(p.fin_d IS NOT NULL AND e.lava) AS fin_lava, COUNTIF(p.fin_d IS NOT NULL AND e.oq) AS fin_other_q,
    COUNTIF(p.fin_d IS NOT NULL AND (e.fw OR e.lava)) AS fin_fw_or_lava,
    COUNTIF(p.fin_d IS NULL AND e.lava) AS nonfin_lava, COUNTIF(p.fin_d IS NULL AND e.fw) AS nonfin_fw,
    ROUND(SUM(IF(p.fin_d IS NOT NULL AND (e.fw OR e.lava), p.alb_rev, 0))) AS part_alb_rev,
    ROUND(SUM(IF(p.fin_d IS NOT NULL AND (e.fw OR e.lava), IFNULL(t.post_rev, 0), 0))) AS part_post_rev,
    COUNTIF(p.fin_d IS NOT NULL AND (e.fw OR e.lava) AND p.alb_rev > 0) AS part_payers
  FROM pop p LEFT JOIN post t USING (album_id, user_id) LEFT JOIN fe e USING (album_id, user_id)
  GROUP BY 1,2
)
SELECT album_id, grp, dr_users, in_pop, pop_finishers, fin_joined_after_completion,
  NULL AS pop_all, NULL AS pop_payers, NULL AS pop_rev, NULL AS fin_all, NULL AS fin_payers, NULL AS fin_rev, NULL AS fin_with_full_day_after, NULL AS avg_full_days_after, NULL AS fin_post_rev,
  NULL AS fin_fw, NULL AS fin_lava, NULL AS fin_other_q, NULL AS fin_fw_or_lava, NULL AS nonfin_lava, NULL AS nonfin_fw, NULL AS part_alb_rev, NULL AS part_post_rev, NULL AS part_payers
FROM camp
UNION ALL
SELECT album_id, grp, NULL, NULL, NULL, NULL, pop_all, pop_payers, pop_rev, fin_all, fin_payers, fin_rev, fin_with_full_day_after, avg_full_days_after, fin_post_rev,
  fin_fw, fin_lava, fin_other_q, fin_fw_or_lava, nonfin_lava, nonfin_fw, part_alb_rev, part_post_rev, part_payers
FROM alb
ORDER BY 1, 2;

-- ===== DISNEY (dry run 22.02 GB) — Legendary set =====
-- Legendary = Magic event with 1 set / 12 stickers for album completers (Mixpanel: custom event "Magic Sticker Collected"; boards "Legendary Set (Album 11, ID=14)" / "(Album 12, ID=15)").
-- bi_prod.magic_event_configuration: album 14 -> magic_event_id 43560 (08-20..08-25), album 15 -> 50303 (10-01..10-06).
--   (The 2-set / 24-sticker events 39770 and 45283 are the mid-album Magic Sets, ~1.3-1.5M users.)
-- All users, not special: 43560 = 26,546 users / 1,342 completed / $360K magic spend; 50303 = 22,950 / 2,466 / $457K.
-- Not in user_daily_album: no player has more than 144 stickers or sets 13+ (checked albums 14, 15).
-- Background: T113 Legendary Set test (Feb 2026, deployed): DiD revenue +15.85% during Legendary, +0.91% whole period, -0.2% 2 weeks after.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim < album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d, SUM(spend) AS alb_rev,
    ARRAY_AGG(STRUCT(lr, past, excl) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS l, MAX(date_dim) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
post AS (
  SELECT p.album_id, p.user_id, SUM(IF(x.date_dim > p.fin_d, x.spend, 0)) AS post_rev
  FROM pop p JOIN ud x ON x.album_id = p.album_id AND x.user_id = p.user_id
  WHERE p.fin_d IS NOT NULL GROUP BY 1,2
),
leg AS (
  SELECT IF(magic_event_id = 43560, 14, 15) AS album_id, user_id, MAX(magic_stickers_lt) AS lst,
    LOGICAL_OR(magic_event_completed_flag) AS lcomp, SUM(magic_spent_lt) AS lspend
  FROM `solitaire-dreams-411507.bi_prod.user_magic_event_last_state`
  WHERE magic_event_start_date BETWEEN DATE '2026-08-15' AND DATE '2026-10-05' AND magic_event_id IN (43560, 50303)
  GROUP BY 1,2
)
SELECT p.album_id,
  COUNT(*) AS pop_all, COUNTIF(p.alb_rev > 0) AS pop_payers, ROUND(SUM(p.alb_rev)) AS pop_rev,
  COUNTIF(p.fin_d IS NOT NULL) AS fin_all, COUNTIF(p.fin_d IS NOT NULL AND p.alb_rev > 0) AS fin_payers, ROUND(SUM(IF(p.fin_d IS NOT NULL, p.alb_rev, 0))) AS fin_rev,
  COUNTIF(p.fin_d IS NOT NULL AND DATE_DIFF(p.a_end, p.fin_d, DAY) >= 2) AS fin_with_full_day_after,
  ROUND(AVG(IF(p.fin_d IS NOT NULL, DATE_DIFF(p.a_end, p.fin_d, DAY) - 1, NULL)), 2) AS avg_full_days_after,
  ROUND(SUM(IFNULL(t.post_rev, 0))) AS fin_post_rev,
  COUNTIF(g.user_id IS NOT NULL) AS leg_all, COUNTIF(g.user_id IS NOT NULL AND p.fin_d IS NOT NULL) AS leg_finishers,
  COUNTIF(g.user_id IS NOT NULL AND p.fin_d IS NULL) AS leg_nonfinishers_in_pop,
  COUNTIF(g.lst > 0 AND p.fin_d IS NOT NULL) AS leg_fin_with_sticker, COUNTIF(g.lcomp AND p.fin_d IS NOT NULL) AS leg_fin_completed,
  COUNTIF(g.user_id IS NOT NULL AND p.fin_d IS NOT NULL AND p.alb_rev > 0) AS leg_fin_payers,
  ROUND(SUM(IF(g.user_id IS NOT NULL AND p.fin_d IS NOT NULL, p.alb_rev, 0))) AS leg_fin_alb_rev,
  ROUND(SUM(IF(p.fin_d IS NOT NULL, IFNULL(g.lspend, 0), 0))) AS leg_fin_magic_spend,
  ROUND(SUM(IF(g.user_id IS NOT NULL AND p.fin_d IS NOT NULL, IFNULL(t.post_rev, 0), 0))) AS leg_fin_post_rev
FROM pop p LEFT JOIN post t USING (album_id, user_id) LEFT JOIN leg g USING (album_id, user_id)
GROUP BY 1 ORDER BY 1;

-- ===== RECOVERY — final versions run 2026-10-19 (Eden approved; finisher = 144 by end of close day) =====

-- ----- DICE recovery (dice-dreams-dbt, 11.06 GB) -----
-- Recovery after completion, DICE albums 61, 63. Payer finishers in the standard population.
-- Finisher = 144 unique set stickers by the end of the close day (album table 144 sum, or the album completion timestamp, which also covers close-day finishes).
-- Habit = close-18 .. close-5 (14 days). Day 0 = completion day; follow days 1..14.
-- Play = rolls spent; balance = start_rolls_balance of the mtx day (first roll after 12:00 UTC); free in = rolls_in (not purchases); paid in = rolls from purchases.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, DATE(user_album_finish_ts) AS flag_fin_d
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    NULLIF(LEAST(IFNULL(MIN(IF(uniq >= 144, date_dim, NULL)), DATE '2099-01-01'), IFNULL(MIN(IF(flag_fin_d <= a_end, flag_fin_d, NULL)), DATE '2099-01-01')), DATE '2099-01-01') AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
tot AS (SELECT album_id, COUNT(*) AS pop_all, SUM(alb_rev) AS pop_rev, COUNTIF(fin_d IS NOT NULL AND alb_rev > 0) AS n_fin_pay FROM pop GROUP BY 1),
fin AS (SELECT album_id, user_id, a_end, fin_d, alb_rev FROM pop WHERE fin_d IS NOT NULL AND alb_rev > 0),
m AS (
  SELECT COALESCE(a.user_id, r.user_id) AS user_id, COALESCE(a.date_dim, r.date_dim) AS d,
    IFNULL(a.revenues_sum,0) AS rev, IFNULL(a.sessions_cnt,0) > 0 AS act,
    IFNULL(r.rolls_out_sum,0) AS play, IFNULL(r.rolls_in_sum,0) AS free_in, IFNULL(r.rolls_amount_from_purchase,0) AS paid_in
  FROM (SELECT user_id, date_dim, revenues_sum, sessions_cnt FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
        WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-22') a
  FULL JOIN (SELECT user_id, date_dim, rolls_out_sum, rolls_in_sum, rolls_amount_from_purchase FROM `dice-dreams-dbt.30_intermediate.user_daily_rolls_in_out`
        WHERE date_dim BETWEEN DATE '2026-07-01' AND DATE '2026-09-22') r
  ON a.user_id = r.user_id AND a.date_dim = r.date_dim
),
bal AS (
  SELECT user_id, mtx_day AS d, start_rolls_balance AS bal FROM `dice-dreams-dbt.40_mart.user_daily_mtx_brut_rolls`
  WHERE mtx_day BETWEEN DATE '2026-07-01' AND DATE '2026-09-22'
),
maxd AS (SELECT MAX(date_dim) AS md FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-09-01' AND DATE '2026-09-22'),
x AS (
  SELECT f.album_id, f.user_id, f.a_end, f.fin_d, f.alb_rev, DATE_DIFF(m.d, f.fin_d, DAY) AS k,
    m.d >= DATE_SUB(f.a_end, INTERVAL 18 DAY) AND m.d <= DATE_SUB(f.a_end, INTERVAL 5 DAY) AS in_base,
    m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 4 DAY) AND DATE_SUB(f.a_end, INTERVAL 1 DAY) AS in_l4,
    m.rev, m.act, m.play, m.free_in, m.paid_in, b.bal
  FROM fin f
  JOIN m ON m.user_id = f.user_id AND m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_ADD(f.fin_d, INTERVAL 14 DAY)
  LEFT JOIN bal b ON b.user_id = f.user_id AND b.d = m.d
),
pu AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, ANY_VALUE(fin_d) AS fin_d, ANY_VALUE(alb_rev) AS alb_rev,
    SUM(IF(in_base, rev, 0)) AS b_rev, COUNTIF(in_base AND rev > 0) AS b_pay_days, COUNTIF(in_base AND act) AS b_act,
    SUM(IF(in_base, play, 0)) / 14 AS b_play_pd, AVG(IF(in_base, bal, NULL)) AS b_bal,
    SUM(IF(in_base, free_in, 0)) / 14 AS b_free_pd, SUM(IF(in_base, paid_in, 0)) AS b_paid_in, SUM(IF(in_base, free_in, 0)) AS b_free_in,
    SUM(IF(in_l4, rev, 0)) AS l4_rev,
    MAX(IF(k = 0, bal, NULL)) AS bal0, MAX(IF(k = 1, bal, NULL)) AS bal1, SUM(IF(k = 0, free_in, 0)) AS free0,
    ARRAY_AGG(STRUCT(k, rev, act, play, bal) ORDER BY k) AS days
  FROM x GROUP BY 1,2
),
ev AS (
  SELECT p.album_id, p.user_id, p.fin_d, p.alb_rev, p.bal1, p.free0, p.b_bal, p.b_free_pd,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.play >= 0.8 * p.b_play_pd AND p.b_play_pd > 0) AS play_back_k,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.rev > 0) AS buy_k,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.bal IS NOT NULL AND dd.bal <= p.b_bal) AS bal_back_k,
    SAFE_DIVIDE(p.b_pay_days, 14) AS p_day,
    CASE DATE_DIFF(p.fin_d, p.a_end, DAY) WHEN 0 THEN 'a_close_day' WHEN -1 THEN 'b_d-1' WHEN -2 THEN 'c_d-2_3' WHEN -3 THEN 'c_d-2_3' ELSE 'd_d-4plus' END AS timing,
    CASE WHEN p.b_rev = 0 THEN 'e0_no_habit_spend' WHEN (p.l4_rev / 4) / (p.b_rev / 14) < 1.5 THEN 'e1_lt1.5x'
         WHEN (p.l4_rev / 4) / (p.b_rev / 14) < 3 THEN 'e2_1.5_3x' ELSE 'e3_3x_plus' END AS end_lift,
    CASE WHEN p.b_rev = 0 OR p.b_act = 0 THEN 't0_no_habit_spend' WHEN p.b_rev / p.b_act < 2 THEN 't1_lt2'
         WHEN p.b_rev / p.b_act < 5 THEN 't2_2_5' WHEN p.b_rev / p.b_act < 20 THEN 't3_5_20' ELSE 't4_20plus' END AS tier,
    CASE WHEN p.b_paid_in + p.b_free_in = 0 THEN 's0_none' WHEN p.b_paid_in / (p.b_paid_in + p.b_free_in) >= 0.5 THEN 's2_mostly_bought' ELSE 's1_mostly_free' END AS bal_source
  FROM pu p
),
sg AS (
  SELECT e.album_id, e.user_id, e.fin_d, e.alb_rev, e.bal1, e.free0, e.b_bal, e.b_free_pd, e.play_back_k, e.buy_k, e.bal_back_k, e.p_day,
    s.seg_type, s.seg, mx.md
  FROM ev e
  CROSS JOIN UNNEST([STRUCT('all' AS seg_type, 'all' AS seg), STRUCT('timing', e.timing), STRUCT('end_lift', e.end_lift),
                     STRUCT('tier', e.tier), STRUCT('bal_source', e.bal_source)]) s
  CROSS JOIN maxd mx
)
SELECT g.album_id, g.seg_type, g.seg,
  COUNT(*) AS n_seg,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 4) AS share_of_payer_finishers,
  ROUND(COUNT(*) / ANY_VALUE(t.pop_all), 5) AS share_of_players,
  ROUND(SUM(g.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS album_rev_share,
  COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md) AS n_obs_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS play_back_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS play_back_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS play_back_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS play_back_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS bought_1,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md, 1 - POW(1 - g.p_day, 1), NULL)), 3) AS exp_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS bought_3,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md, 1 - POW(1 - g.p_day, 3), NULL)), 3) AS exp_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bought_7,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, 1 - POW(1 - g.p_day, 7), NULL)), 3) AS exp_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS bought_14,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md, 1 - POW(1 - g.p_day, 14), NULL)), 3) AS exp_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS bal_back_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS bal_back_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bal_back_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS bal_back_14,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(g.bal1, g.b_bal), 2)[OFFSET(1)], 2) AS med_bal_day1_vs_habit,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(g.free0, g.b_free_pd), 2)[OFFSET(1)], 2) AS med_free_in_day0_vs_habit,
  ROUND(AVG(g.p_day), 3) AS habit_pay_day_rate
FROM sg g JOIN tot t USING (album_id)
GROUP BY 1,2,3
ORDER BY 1,2,3


-- ----- DOMINO recovery (domino-dreams-dbt, ran 78.13 GB incl. staging stg_coins_in_vw; estimate was 12.86 GB before the staging CTE) -----
-- Recovery after completion, DOMINO albums 19, 20. Payer finishers in the standard population (cheaters excluded).
-- Finisher = 144 unique set stickers or the game's album-finished flag, by the end of the close day. Habit = close-18 .. close-5. Day 0 = completion day; days 1..14 (album 20 truncated at last data day, see n_obs).
-- Play = coins spent in allowance units; balance = end-of-day coins balance in allowance units.
-- Coins in (staging stg_coins_in_vw, allowance units): paid = source 'purchase' or MTX campaign name with offer/store (except 'ad reward' = RV); free = the rest.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, IFNULL(album_finished_flag,FALSE) AS ff
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144 OR ff, date_dim, NULL)) AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
tot AS (SELECT album_id, COUNT(*) AS pop_all, SUM(alb_rev) AS pop_rev, COUNTIF(fin_d IS NOT NULL AND alb_rev > 0) AS n_fin_pay FROM pop GROUP BY 1),
fin AS (SELECT album_id, user_id, a_end, fin_d, alb_rev FROM pop WHERE fin_d IS NOT NULL AND alb_rev > 0),
ci AS (
  SELECT user_id, pdate AS d, SUM(IF(paid, 0, units)) AS free_in, SUM(IF(paid, units, 0)) AS paid_in
  FROM (
    SELECT user_id, pdate, SAFE_DIVIDE(COALESCE(amount, coins), coins_allowance) AS units,
      (source = 'purchase' OR (REGEXP_CONTAINS(LOWER(IFNULL(mtx_campaign_name, '')), r'offer|store') AND IFNULL(source, '') != 'ad reward')) AS paid
    FROM `domino-dreams-dbt.prod_10_staging.stg_coins_in_vw`
    WHERE pdate BETWEEN DATE '2026-08-06' AND DATE '2026-09-07' OR pdate BETWEEN DATE '2026-09-24' AND DATE '2026-10-27'
  ) GROUP BY 1,2
),
m AS (
  SELECT a.user_id, a.date_dim AS d,
    IFNULL(a.user_daily_inapp_purchase_amount,0) + IFNULL(a.user_daily_stripe_amount,0) AS rev, IFNULL(a.sessions_today,0) > 0 AS act,
    IFNULL(c.spent_in_allowance,0) AS play, IFNULL(ci.free_in,0) AS free_in, IFNULL(ci.paid_in,0) AS paid_in
  FROM (SELECT user_id, date_dim, user_daily_inapp_purchase_amount, user_daily_stripe_amount, sessions_today FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
        WHERE date_dim BETWEEN DATE '2026-08-01' AND DATE '2026-10-27') a
  LEFT JOIN (SELECT user_id, date_dim, spent_in_allowance FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_spent`
        WHERE date_dim BETWEEN DATE '2026-08-01' AND DATE '2026-10-27') c
  ON a.user_id = c.user_id AND a.date_dim = c.date_dim
  LEFT JOIN ci ON ci.user_id = a.user_id AND ci.d = a.date_dim
),
bal AS (
  SELECT user_id, date_dim AS d, coins_balance_in_allowance_end_day AS bal FROM `domino-dreams-dbt.prod_30_intermediate.int_rv_user_daily_coins_balance`
  WHERE date_dim BETWEEN DATE '2026-08-01' AND DATE '2026-10-27'
),
maxd AS (SELECT MAX(date_dim) AS md FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-10-01' AND DATE '2026-10-27'),
x AS (
  SELECT f.album_id, f.user_id, f.a_end, f.fin_d, f.alb_rev, DATE_DIFF(m.d, f.fin_d, DAY) AS k,
    m.d >= DATE_SUB(f.a_end, INTERVAL 18 DAY) AND m.d <= DATE_SUB(f.a_end, INTERVAL 5 DAY) AS in_base,
    m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 4 DAY) AND DATE_SUB(f.a_end, INTERVAL 1 DAY) AS in_l4,
    m.rev, m.act, m.play, m.free_in, m.paid_in, b.bal
  FROM fin f
  JOIN m ON m.user_id = f.user_id AND m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_ADD(f.fin_d, INTERVAL 14 DAY)
  LEFT JOIN bal b ON b.user_id = f.user_id AND b.d = m.d
),
pu AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, ANY_VALUE(fin_d) AS fin_d, ANY_VALUE(alb_rev) AS alb_rev,
    SUM(IF(in_base, rev, 0)) AS b_rev, COUNTIF(in_base AND rev > 0) AS b_pay_days, COUNTIF(in_base AND act) AS b_act,
    SUM(IF(in_base, play, 0)) / 14 AS b_play_pd, AVG(IF(in_base, bal, NULL)) AS b_bal,
    SUM(IF(in_base, free_in, 0)) / 14 AS b_free_pd, SUM(IF(in_base, paid_in, 0)) AS b_paid_in, SUM(IF(in_base, free_in, 0)) AS b_free_in,
    SUM(IF(in_l4, rev, 0)) AS l4_rev,
    MAX(IF(k = 0, bal, NULL)) AS bal0, MAX(IF(k = 1, bal, NULL)) AS bal1, SUM(IF(k = 0, free_in, 0)) AS free0,
    ARRAY_AGG(STRUCT(k, rev, act, play, bal) ORDER BY k) AS days
  FROM x GROUP BY 1,2
),
ev AS (
  SELECT p.album_id, p.user_id, p.fin_d, p.alb_rev, p.bal1, p.free0, p.b_bal, p.b_free_pd,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.play >= 0.8 * p.b_play_pd AND p.b_play_pd > 0) AS play_back_k,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.rev > 0) AS buy_k,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.bal IS NOT NULL AND dd.bal <= p.b_bal) AS bal_back_k,
    SAFE_DIVIDE(p.b_pay_days, 14) AS p_day,
    CASE DATE_DIFF(p.fin_d, p.a_end, DAY) WHEN 0 THEN 'a_close_day' WHEN -1 THEN 'b_d-1' WHEN -2 THEN 'c_d-2_3' WHEN -3 THEN 'c_d-2_3' ELSE 'd_d-4plus' END AS timing,
    CASE WHEN p.b_rev = 0 THEN 'e0_no_habit_spend' WHEN (p.l4_rev / 4) / (p.b_rev / 14) < 1.5 THEN 'e1_lt1.5x'
         WHEN (p.l4_rev / 4) / (p.b_rev / 14) < 3 THEN 'e2_1.5_3x' ELSE 'e3_3x_plus' END AS end_lift,
    CASE WHEN p.b_rev = 0 OR p.b_act = 0 THEN 't0_no_habit_spend' WHEN p.b_rev / p.b_act < 2 THEN 't1_lt2'
         WHEN p.b_rev / p.b_act < 5 THEN 't2_2_5' WHEN p.b_rev / p.b_act < 20 THEN 't3_5_20' ELSE 't4_20plus' END AS tier,
    CASE WHEN p.b_paid_in + p.b_free_in = 0 THEN 's0_none' WHEN p.b_paid_in / (p.b_paid_in + p.b_free_in) >= 0.5 THEN 's2_mostly_bought' ELSE 's1_mostly_free' END AS bal_source
  FROM pu p
),
sg AS (
  SELECT e.album_id, e.user_id, e.fin_d, e.alb_rev, e.bal1, e.free0, e.b_bal, e.b_free_pd, e.play_back_k, e.buy_k, e.bal_back_k, e.p_day,
    s.seg_type, s.seg, mx.md
  FROM ev e
  CROSS JOIN UNNEST([STRUCT('all' AS seg_type, 'all' AS seg), STRUCT('timing', e.timing), STRUCT('end_lift', e.end_lift),
                     STRUCT('tier', e.tier), STRUCT('bal_source', e.bal_source)]) s
  CROSS JOIN maxd mx
)
SELECT g.album_id, g.seg_type, g.seg,
  COUNT(*) AS n_seg,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 4) AS share_of_payer_finishers,
  ROUND(COUNT(*) / ANY_VALUE(t.pop_all), 5) AS share_of_players,
  ROUND(SUM(g.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS album_rev_share,
  COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md) AS n_obs_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS play_back_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS play_back_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS play_back_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS play_back_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS bought_1,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md, 1 - POW(1 - g.p_day, 1), NULL)), 3) AS exp_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS bought_3,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md, 1 - POW(1 - g.p_day, 3), NULL)), 3) AS exp_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bought_7,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, 1 - POW(1 - g.p_day, 7), NULL)), 3) AS exp_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS bought_14,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md, 1 - POW(1 - g.p_day, 14), NULL)), 3) AS exp_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS bal_back_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS bal_back_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bal_back_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS bal_back_14,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(g.bal1, g.b_bal), 2)[OFFSET(1)], 2) AS med_bal_day1_vs_habit,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(g.free0, g.b_free_pd), 2)[OFFSET(1)], 2) AS med_free_in_day0_vs_habit,
  ROUND(AVG(g.p_day), 3) AS habit_pay_day_rate
FROM sg g JOIN tot t USING (album_id)
GROUP BY 1,2,3
ORDER BY 1,2,3


-- ----- DISNEY recovery, run version (solitaire-dreams-411507, 29.15 GB, no staging coins-in) -----
-- Recovery after completion, DISNEY albums 14, 15. Payer finishers in the standard population (excluded users removed).
-- Finisher = 144 unique set stickers or the game's album-finished flag, by the end of the close day. Habit = close-18 .. close-5. Day 0 = completion day; days 1..14.
-- Play = levels played (all modes); balance = end-of-day coins balance.
-- Variant without the staging coins-in split (190 GB). free_in / paid_in set to 0; bal_source segment removed.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, IFNULL(album_finished_flag,FALSE) AS ff
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144 OR ff, date_dim, NULL)) AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
tot AS (SELECT album_id, COUNT(*) AS pop_all, SUM(alb_rev) AS pop_rev, COUNTIF(fin_d IS NOT NULL AND alb_rev > 0) AS n_fin_pay FROM pop GROUP BY 1),
fin AS (SELECT album_id, user_id, a_end, fin_d, alb_rev FROM pop WHERE fin_d IS NOT NULL AND alb_rev > 0),
m AS (
  SELECT a.user_id, a.date_dim AS d, IFNULL(a.gross_revenues,0) AS rev, IFNULL(a.total_sessions_count,0) > 0 AS act,
    IFNULL(a.levels_played_mode_1,0) + IFNULL(a.levels_played_mode_2,0) + IFNULL(a.levels_played_mode_3,0) + IFNULL(a.levels_played_mode_4,0) AS play,
    0 AS free_in, 0 AS paid_in
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` a
  WHERE a.date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-19'
),
bal AS (
  SELECT user_id, date_dim AS d, enday_coins_balance AS bal FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-19'
),
maxd AS (SELECT MAX(date_dim) AS md FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-10-01' AND DATE '2026-10-19'),
x AS (
  SELECT f.album_id, f.user_id, f.a_end, f.fin_d, f.alb_rev, DATE_DIFF(m.d, f.fin_d, DAY) AS k,
    m.d >= DATE_SUB(f.a_end, INTERVAL 18 DAY) AND m.d <= DATE_SUB(f.a_end, INTERVAL 5 DAY) AS in_base,
    m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 4 DAY) AND DATE_SUB(f.a_end, INTERVAL 1 DAY) AS in_l4,
    m.rev, m.act, m.play, m.free_in, m.paid_in, b.bal
  FROM fin f
  JOIN m ON m.user_id = f.user_id AND m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_ADD(f.fin_d, INTERVAL 14 DAY)
  LEFT JOIN bal b ON b.user_id = f.user_id AND b.d = m.d
),
pu AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, ANY_VALUE(fin_d) AS fin_d, ANY_VALUE(alb_rev) AS alb_rev,
    SUM(IF(in_base, rev, 0)) AS b_rev, COUNTIF(in_base AND rev > 0) AS b_pay_days, COUNTIF(in_base AND act) AS b_act,
    SUM(IF(in_base, play, 0)) / 14 AS b_play_pd, AVG(IF(in_base, bal, NULL)) AS b_bal,
    SUM(IF(in_base, free_in, 0)) / 14 AS b_free_pd, SUM(IF(in_base, paid_in, 0)) AS b_paid_in, SUM(IF(in_base, free_in, 0)) AS b_free_in,
    SUM(IF(in_l4, rev, 0)) AS l4_rev,
    MAX(IF(k = 0, bal, NULL)) AS bal0, MAX(IF(k = 1, bal, NULL)) AS bal1, SUM(IF(k = 0, free_in, 0)) AS free0,
    ARRAY_AGG(STRUCT(k, rev, act, play, bal) ORDER BY k) AS days
  FROM x GROUP BY 1,2
),
ev AS (
  SELECT p.album_id, p.user_id, p.fin_d, p.alb_rev, p.bal1, p.free0, p.b_bal, p.b_free_pd,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.play >= 0.8 * p.b_play_pd AND p.b_play_pd > 0) AS play_back_k,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.rev > 0) AS buy_k,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.bal IS NOT NULL AND dd.bal <= p.b_bal) AS bal_back_k,
    SAFE_DIVIDE(p.b_pay_days, 14) AS p_day,
    CASE DATE_DIFF(p.fin_d, p.a_end, DAY) WHEN 0 THEN 'a_close_day' WHEN -1 THEN 'b_d-1' WHEN -2 THEN 'c_d-2_3' WHEN -3 THEN 'c_d-2_3' ELSE 'd_d-4plus' END AS timing,
    CASE WHEN p.b_rev = 0 THEN 'e0_no_habit_spend' WHEN (p.l4_rev / 4) / (p.b_rev / 14) < 1.5 THEN 'e1_lt1.5x'
         WHEN (p.l4_rev / 4) / (p.b_rev / 14) < 3 THEN 'e2_1.5_3x' ELSE 'e3_3x_plus' END AS end_lift,
    CASE WHEN p.b_rev = 0 OR p.b_act = 0 THEN 't0_no_habit_spend' WHEN p.b_rev / p.b_act < 2 THEN 't1_lt2'
         WHEN p.b_rev / p.b_act < 5 THEN 't2_2_5' WHEN p.b_rev / p.b_act < 20 THEN 't3_5_20' ELSE 't4_20plus' END AS tier,
    CASE WHEN p.b_paid_in + p.b_free_in = 0 THEN 's0_none' WHEN p.b_paid_in / (p.b_paid_in + p.b_free_in) >= 0.5 THEN 's2_mostly_bought' ELSE 's1_mostly_free' END AS bal_source
  FROM pu p
),
sg AS (
  SELECT e.album_id, e.user_id, e.fin_d, e.alb_rev, e.bal1, e.free0, e.b_bal, e.b_free_pd, e.play_back_k, e.buy_k, e.bal_back_k, e.p_day,
    s.seg_type, s.seg, mx.md
  FROM ev e
  CROSS JOIN UNNEST([STRUCT('all' AS seg_type, 'all' AS seg), STRUCT('timing', e.timing), STRUCT('end_lift', e.end_lift),
                     STRUCT('tier', e.tier)]) s
  CROSS JOIN maxd mx
)
SELECT g.album_id, g.seg_type, g.seg,
  COUNT(*) AS n_seg,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 4) AS share_of_payer_finishers,
  ROUND(COUNT(*) / ANY_VALUE(t.pop_all), 5) AS share_of_players,
  ROUND(SUM(g.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS album_rev_share,
  COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md) AS n_obs_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS play_back_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS play_back_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS play_back_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS play_back_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS bought_1,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md, 1 - POW(1 - g.p_day, 1), NULL)), 3) AS exp_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS bought_3,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md, 1 - POW(1 - g.p_day, 3), NULL)), 3) AS exp_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bought_7,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, 1 - POW(1 - g.p_day, 7), NULL)), 3) AS exp_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS bought_14,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md, 1 - POW(1 - g.p_day, 14), NULL)), 3) AS exp_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS bal_back_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS bal_back_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bal_back_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS bal_back_14,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(g.bal1, g.b_bal), 2)[OFFSET(1)], 2) AS med_bal_day1_vs_habit,
  ROUND(AVG(g.p_day), 3) AS habit_pay_day_rate
FROM sg g JOIN tot t USING (album_id)
GROUP BY 1,2,3
ORDER BY 1,2,3


-- ----- DISNEY recovery WITH staging coins-in split (190.25 GB, NOT run — waiting for Eden) -----
-- Recovery after completion, DISNEY albums 14, 15. Payer finishers in the standard population (excluded users removed).
-- Finisher = 144 unique set stickers or the game's album-finished flag, by the end of the close day. Habit = close-18 .. close-5. Day 0 = completion day; days 1..14.
-- Play = levels played (all modes); balance = end-of-day coins balance.
-- Coins in (staging resource_in_stg_vw, raw coins): paid = MTX campaign name contains offer/store (Eden's Mixpanel rule); free = the rest. View has no source column.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend, IFNULL(album_finished_flag,FALSE) AS ff
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim <= album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144 OR ff, date_dim, NULL)) AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
tot AS (SELECT album_id, COUNT(*) AS pop_all, SUM(alb_rev) AS pop_rev, COUNTIF(fin_d IS NOT NULL AND alb_rev > 0) AS n_fin_pay FROM pop GROUP BY 1),
fin AS (SELECT album_id, user_id, a_end, fin_d, alb_rev FROM pop WHERE fin_d IS NOT NULL AND alb_rev > 0),
ci AS (
  SELECT user_id, pdate AS d,
    SUM(IF(REGEXP_CONTAINS(LOWER(IFNULL(mtx_campaign_name, '')), r'offer|store'), 0, coins)) AS free_in,
    SUM(IF(REGEXP_CONTAINS(LOWER(IFNULL(mtx_campaign_name, '')), r'offer|store'), coins, 0)) AS paid_in
  FROM `solitaire-dreams-411507.bi_mp_prod_stg_vw.resource_in_stg_vw`
  WHERE (pdate BETWEEN DATE '2026-08-06' AND DATE '2026-09-07' OR pdate BETWEEN DATE '2026-09-17' AND DATE '2026-10-19') AND IFNULL(coins, 0) > 0
  GROUP BY 1,2
),
m AS (
  SELECT a.user_id, a.date_dim AS d, IFNULL(a.gross_revenues,0) AS rev, IFNULL(a.total_sessions_count,0) > 0 AS act,
    IFNULL(a.levels_played_mode_1,0) + IFNULL(a.levels_played_mode_2,0) + IFNULL(a.levels_played_mode_3,0) + IFNULL(a.levels_played_mode_4,0) AS play,
    IFNULL(ci.free_in,0) AS free_in, IFNULL(ci.paid_in,0) AS paid_in
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` a
  LEFT JOIN ci ON ci.user_id = a.user_id AND ci.d = a.date_dim
  WHERE a.date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-19'
),
bal AS (
  SELECT user_id, date_dim AS d, enday_coins_balance AS bal FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-19'
),
maxd AS (SELECT MAX(date_dim) AS md FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df` WHERE date_dim BETWEEN DATE '2026-10-01' AND DATE '2026-10-19'),
x AS (
  SELECT f.album_id, f.user_id, f.a_end, f.fin_d, f.alb_rev, DATE_DIFF(m.d, f.fin_d, DAY) AS k,
    m.d >= DATE_SUB(f.a_end, INTERVAL 18 DAY) AND m.d <= DATE_SUB(f.a_end, INTERVAL 5 DAY) AS in_base,
    m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 4 DAY) AND DATE_SUB(f.a_end, INTERVAL 1 DAY) AS in_l4,
    m.rev, m.act, m.play, m.free_in, m.paid_in, b.bal
  FROM fin f
  JOIN m ON m.user_id = f.user_id AND m.d BETWEEN DATE_SUB(f.a_end, INTERVAL 18 DAY) AND DATE_ADD(f.fin_d, INTERVAL 14 DAY)
  LEFT JOIN bal b ON b.user_id = f.user_id AND b.d = m.d
),
pu AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, ANY_VALUE(fin_d) AS fin_d, ANY_VALUE(alb_rev) AS alb_rev,
    SUM(IF(in_base, rev, 0)) AS b_rev, COUNTIF(in_base AND rev > 0) AS b_pay_days, COUNTIF(in_base AND act) AS b_act,
    SUM(IF(in_base, play, 0)) / 14 AS b_play_pd, AVG(IF(in_base, bal, NULL)) AS b_bal,
    SUM(IF(in_base, free_in, 0)) / 14 AS b_free_pd, SUM(IF(in_base, paid_in, 0)) AS b_paid_in, SUM(IF(in_base, free_in, 0)) AS b_free_in,
    SUM(IF(in_l4, rev, 0)) AS l4_rev,
    MAX(IF(k = 0, bal, NULL)) AS bal0, MAX(IF(k = 1, bal, NULL)) AS bal1, SUM(IF(k = 0, free_in, 0)) AS free0,
    ARRAY_AGG(STRUCT(k, rev, act, play, bal) ORDER BY k) AS days
  FROM x GROUP BY 1,2
),
ev AS (
  SELECT p.album_id, p.user_id, p.fin_d, p.alb_rev, p.bal1, p.free0, p.b_bal, p.b_free_pd,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.play >= 0.8 * p.b_play_pd AND p.b_play_pd > 0) AS play_back_k,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.rev > 0) AS buy_k,
    (SELECT MIN(dd.k) FROM UNNEST(p.days) dd WHERE dd.k >= 1 AND dd.bal IS NOT NULL AND dd.bal <= p.b_bal) AS bal_back_k,
    SAFE_DIVIDE(p.b_pay_days, 14) AS p_day,
    CASE DATE_DIFF(p.fin_d, p.a_end, DAY) WHEN 0 THEN 'a_close_day' WHEN -1 THEN 'b_d-1' WHEN -2 THEN 'c_d-2_3' WHEN -3 THEN 'c_d-2_3' ELSE 'd_d-4plus' END AS timing,
    CASE WHEN p.b_rev = 0 THEN 'e0_no_habit_spend' WHEN (p.l4_rev / 4) / (p.b_rev / 14) < 1.5 THEN 'e1_lt1.5x'
         WHEN (p.l4_rev / 4) / (p.b_rev / 14) < 3 THEN 'e2_1.5_3x' ELSE 'e3_3x_plus' END AS end_lift,
    CASE WHEN p.b_rev = 0 OR p.b_act = 0 THEN 't0_no_habit_spend' WHEN p.b_rev / p.b_act < 2 THEN 't1_lt2'
         WHEN p.b_rev / p.b_act < 5 THEN 't2_2_5' WHEN p.b_rev / p.b_act < 20 THEN 't3_5_20' ELSE 't4_20plus' END AS tier,
    CASE WHEN p.b_paid_in + p.b_free_in = 0 THEN 's0_none' WHEN p.b_paid_in / (p.b_paid_in + p.b_free_in) >= 0.5 THEN 's2_mostly_bought' ELSE 's1_mostly_free' END AS bal_source
  FROM pu p
),
sg AS (
  SELECT e.album_id, e.user_id, e.fin_d, e.alb_rev, e.bal1, e.free0, e.b_bal, e.b_free_pd, e.play_back_k, e.buy_k, e.bal_back_k, e.p_day,
    s.seg_type, s.seg, mx.md
  FROM ev e
  CROSS JOIN UNNEST([STRUCT('all' AS seg_type, 'all' AS seg), STRUCT('timing', e.timing), STRUCT('end_lift', e.end_lift),
                     STRUCT('tier', e.tier), STRUCT('bal_source', e.bal_source)]) s
  CROSS JOIN maxd mx
)
SELECT g.album_id, g.seg_type, g.seg,
  COUNT(*) AS n_seg,
  ROUND(COUNT(*) / ANY_VALUE(t.n_fin_pay), 4) AS share_of_payer_finishers,
  ROUND(COUNT(*) / ANY_VALUE(t.pop_all), 5) AS share_of_players,
  ROUND(SUM(g.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS album_rev_share,
  COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md) AS n_obs_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS play_back_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS play_back_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS play_back_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.play_back_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS play_back_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS bought_1,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md, 1 - POW(1 - g.p_day, 1), NULL)), 3) AS exp_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS bought_3,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md, 1 - POW(1 - g.p_day, 3), NULL)), 3) AS exp_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bought_7,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md, 1 - POW(1 - g.p_day, 7), NULL)), 3) AS exp_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.buy_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS bought_14,
  ROUND(AVG(IF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md, 1 - POW(1 - g.p_day, 14), NULL)), 3) AS exp_14,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 1 AND DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 1 DAY) <= g.md)), 3) AS bal_back_1,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 3 AND DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 3 DAY) <= g.md)), 3) AS bal_back_3,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 7 AND DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 7 DAY) <= g.md)), 3) AS bal_back_7,
  ROUND(SAFE_DIVIDE(COUNTIF(g.bal_back_k <= 14 AND DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md), COUNTIF(DATE_ADD(g.fin_d, INTERVAL 14 DAY) <= g.md)), 3) AS bal_back_14,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(g.bal1, g.b_bal), 2)[OFFSET(1)], 2) AS med_bal_day1_vs_habit,
  ROUND(APPROX_QUANTILES(SAFE_DIVIDE(g.free0, g.b_free_pd), 2)[OFFSET(1)], 2) AS med_free_in_day0_vs_habit,
  ROUND(AVG(g.p_day), 3) AS habit_pay_day_rate
FROM sg g JOIN tot t USING (album_id)
GROUP BY 1,2,3
ORDER BY 1,2,3


-- ----- DICE live spend (dice-dreams-dbt, 13.33 GB) -----
-- Dice: purchases made while the finisher campaign (Fortune Wheel / finisher Lava Quest) was live for the player.
-- Window per player = first day they got a resource from the campaign .. last day the campaign gave any resource. Daily grain. Dry run 13.33 GB.
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr, IFNULL(user_past_album_count,0) > 0 AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
u AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MIN(IF(uniq >= 144, date_dim, NULL)) AS fin_d,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev,
    ARRAY_AGG(IF(date_dim < a_end, STRUCT(lr, past, excl), NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS l,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, fin_d, alb_rev FROM u
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND l.past AND NOT l.excl AND l.lr >= 0.5
),
tot AS (SELECT album_id, COUNT(*) AS pop_all, SUM(alb_rev) AS pop_rev FROM pop GROUP BY 1),
dr AS (
  SELECT IF(date_dim <= DATE '2026-07-27', 61, 63) AS album_id, user_id, campaign_name,
    IF(REGEXP_CONTAINS(LOWER(campaign_name), r'lava'), 'lava', 'fw') AS ev, MIN(date_dim) AS first_d, MAX(date_dim) AS last_d
  FROM `dice-dreams-dbt.40_mart.fact_dynamic_resource_given`
  WHERE (date_dim BETWEEN DATE '2026-07-18' AND DATE '2026-07-29' OR date_dim BETWEEN DATE '2026-08-29' AND DATE '2026-09-09')
    AND campaign_name IN ('220726_ExtraLayer_AlbumFinishers_Curtains_FortuneWheel', '220726_LavaQuest_Generic_Lavaquest',
      '020926_TopLayer_AlbumFinishers_FortuneWheel', '030926_TopLayer_SwampSprint_LavaQuest')
  GROUP BY 1,2,3,4
),
cend AS (SELECT campaign_name, MAX(last_d) AS c_end FROM dr GROUP BY 1),
win AS (
  SELECT d.album_id, d.user_id, MIN(d.first_d) AS w_start, MAX(c.c_end) AS w_end,
    LOGICAL_OR(d.ev = 'fw') AS in_fw, LOGICAL_OR(d.ev = 'lava') AS in_lava
  FROM dr d JOIN cend c USING (campaign_name) GROUP BY 1,2
),
pur AS (
  SELECT user_id, date_dim, SUM(purchase_amount) AS amt FROM `dice-dreams-dbt.30_intermediate.fact_purchase_completed`
  WHERE (date_dim BETWEEN DATE '2026-07-18' AND DATE '2026-07-29' OR date_dim BETWEEN DATE '2026-08-29' AND DATE '2026-09-09')
  GROUP BY 1,2
),
uw AS (
  SELECT w.album_id, w.user_id, w.w_start, w.w_end, w.in_fw, w.in_lava, SUM(IFNULL(p.amt,0)) AS live_spend
  FROM win w LEFT JOIN pur p ON p.user_id = w.user_id AND p.date_dim BETWEEN w.w_start AND w.w_end
  GROUP BY 1,2,3,4,5,6
)
SELECT p.album_id,
  CASE WHEN p.fin_d IS NULL THEN 'not_finisher' WHEN p.fin_d = p.a_end THEN 'finished_close_day' ELSE 'finished_before_close' END AS grp,
  COUNT(*) AS n_in_pop, COUNTIF(w.user_id IS NOT NULL) AS participants, COUNTIF(w.in_fw) AS in_fw, COUNTIF(w.in_lava) AS in_lava,
  ROUND(SUM(p.alb_rev)) AS grp_album_rev, ROUND(SUM(IFNULL(w.live_spend,0))) AS spend_while_live,
  ROUND(SUM(IFNULL(w.live_spend,0)) / ANY_VALUE(t.pop_rev), 4) AS spend_while_live_share_of_album_rev,
  ROUND(SUM(p.alb_rev) / ANY_VALUE(t.pop_rev), 4) AS grp_album_rev_share,
  ROUND(AVG(IF(w.user_id IS NOT NULL, DATE_DIFF(w.w_end, w.w_start, DAY) + 1, NULL)), 2) AS avg_live_days,
  MIN(w.w_start) AS first_start, MAX(w.w_end) AS last_end
FROM pop p LEFT JOIN uw w USING (album_id, user_id) JOIN tot t USING (album_id)
WHERE p.fin_d IS NOT NULL OR w.user_id IS NOT NULL
GROUP BY 1,2 ORDER BY 1,2;

