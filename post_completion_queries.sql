-- Post-completion analysis (2026-10-17). Dice: template with @params (albums 61,63; 2026-06-01..2026-09-07) + final AVG wrapper over res (see chat). Domino/Disney: as run.
-- ===== DICE =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td,
    IFNULL(user_past_album_count,0) AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(total_spent_in_album_until_this_date,0) AS cum_alb_spend,
    spent_until_album_completion AS sp_until_fin, DATE(user_album_finish_ts) AS flag_fin_d
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND album_id IN (61,63)
    AND date_dim < album_end_date
),
fin AS (SELECT album_id, user_id, MIN(date_dim) AS fin_d FROM ud WHERE uniq >= 144 GROUP BY 1,2),
cohort AS (
  SELECT album_id, user_id, 'F' AS grp, fin_d AS ref_d FROM fin
  UNION ALL
  SELECT f.album_id, f.user_id, 'FC', u.a_end FROM fin f
    JOIN ud u ON u.album_id = f.album_id AND u.user_id = f.user_id AND u.date_dim = DATE_SUB(u.a_end, INTERVAL 1 DAY)
  UNION ALL
  SELECT album_id, user_id, IF(uniq = 143, 'N1', 'N2'), a_end FROM ud
    WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq IN (142,143)
),
elig AS (
  SELECT c.album_id, c.user_id, c.grp, c.ref_d, u.a_start, u.a_end, u.cum_alb_spend AS cum_before,
    u.sp_until_fin, u.flag_fin_d
  FROM cohort c
  JOIN ud u ON u.album_id = c.album_id AND u.user_id = c.user_id AND u.date_dim = DATE_SUB(c.ref_d, INTERVAL 1 DAY)
  WHERE u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE_ADD(DATE '2026-09-07', INTERVAL 9 DAY)
),
pu AS (
  SELECT e.album_id, e.user_id, e.grp, e.ref_d, e.a_end, e.cum_before, e.sp_until_fin, e.flag_fin_d,
    SUM(IF(m.date_dim BETWEEN e.a_start AND DATE_SUB(e.ref_d, INTERVAL 1 DAY), m.rev, 0)) AS rev_base,
    COUNTIF(m.act AND m.date_dim BETWEEN e.a_start AND DATE_SUB(e.ref_d, INTERVAL 1 DAY)) AS ad_base,
    SUM(IF(m.date_dim BETWEEN e.a_start AND DATE_SUB(e.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb,
    COUNTIF(m.act AND m.date_dim BETWEEN e.a_start AND DATE_SUB(e.a_end, INTERVAL 1 DAY)) AS ad_alb,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(e.a_end, INTERVAL 4 DAY) AND DATE_SUB(e.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_l4,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(e.a_end, INTERVAL 4 DAY) AND DATE_SUB(e.a_end, INTERVAL 1 DAY)) AS ad_l4
  FROM elig e LEFT JOIN udm m ON m.user_id = e.user_id AND m.date_dim BETWEEN e.a_start AND e.a_end
  GROUP BY 1,2,3,4,5,6,7,8
),
payers AS (
  SELECT album_id, user_id, grp, ref_d, a_end, cum_before, sp_until_fin, flag_fin_d,
    rev_base, ad_base, rev_alb, ad_alb, rev_l4, ad_l4
  FROM pu WHERE rev_base > 0
),
allpop AS (
  SELECT u.album_id, u.user_id, u.a_end
  FROM ud u JOIN udm m ON m.user_id = u.user_id AND m.date_dim BETWEEN u.a_start AND DATE_SUB(u.a_end, INTERVAL 1 DAY)
  WHERE u.date_dim = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
  GROUP BY 1,2,3 HAVING SUM(m.rev) > 0
),
gday AS (
  SELECT a.album_id, d AS date_dim, DATE_DIFF(d, ANY_VALUE(a.a_end), DAY) AS k_close,
    COUNT(*) AS n_all, SUM(IFNULL(m.rev,0)) AS g_rev, COUNTIF(IFNULL(m.act,FALSE)) AS g_ad
  FROM allpop a CROSS JOIN UNNEST(GENERATE_DATE_ARRAY(DATE_SUB(a.a_end, INTERVAL 14 DAY), DATE_ADD(a.a_end, INTERVAL 8 DAY))) d
  LEFT JOIN udm m ON m.user_id = a.user_id AND m.date_dim = d
  GROUP BY 1,2
),
uk AS (
  SELECT p.album_id, p.grp, p.user_id, k, DATE_ADD(p.ref_d, INTERVAL k DAY) AS d,
    DATE_ADD(p.ref_d, INTERVAL k DAY) >= p.a_end AS next_alb,
    IFNULL(m.rev, 0) AS rev, IFNULL(m.act, FALSE) AS act,
    IF(k = 0 AND p.grp = 'F' AND p.flag_fin_d = p.ref_d, GREATEST(IFNULL(p.sp_until_fin,0) - p.cum_before, 0), NULL) AS d0_pre
  FROM payers p CROSS JOIN UNNEST(GENERATE_ARRAY(0,7)) k
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim = DATE_ADD(p.ref_d, INTERVAL k DAY)
),
res AS (
SELECT u.album_id, u.grp, CAST(u.k AS STRING) AS period, COUNT(*) AS n_players,
  ROUND(SAFE_DIVIDE(SUM(u.rev), COUNTIF(u.act)), 2) AS arpdau,
  ROUND(SAFE_DIVIDE(SUM(IF(u.act, SAFE_DIVIDE(g.g_rev, g.g_ad), 0)), COUNTIF(u.act)), 2) AS all_payers_arpdau_same_dates,
  ROUND(COUNTIF(u.act) / COUNT(*), 3) AS active_rate,
  ROUND(COUNTIF(u.rev > 0) / COUNT(*), 3) AS payer_rate,
  ROUND(SUM(u.rev) / COUNT(*), 2) AS rev_per_player,
  ROUND(COUNTIF(u.next_alb) / COUNT(*), 3) AS share_in_next_album,
  ROUND(SAFE_DIVIDE(SUM(u.d0_pre), SUM(IF(u.d0_pre IS NOT NULL, u.rev, 0))), 3) AS d0_share_before_completion
FROM uk u LEFT JOIN gday g ON g.album_id = u.album_id AND g.date_dim = u.d
GROUP BY 1,2,3
UNION ALL
SELECT p.album_id, p.grp, per.period, COUNT(*),
  ROUND(SAFE_DIVIDE(SUM(per.rev), SUM(per.ad)), 2), NULL, NULL,
  ROUND(COUNTIF(per.rev > 0) / COUNT(*), 3), ROUND(SUM(per.rev) / COUNT(*), 2), NULL, NULL
FROM payers p
CROSS JOIN UNNEST([
  STRUCT('base' AS period, p.rev_base AS rev, p.ad_base AS ad),
  STRUCT('album', p.rev_alb, p.ad_alb),
  STRUCT('last4', p.rev_l4, p.ad_l4)]) per
GROUP BY 1,2,3
UNION ALL
SELECT x.album_id, x.grp, 'd1_7', COUNT(*),
  ROUND(SAFE_DIVIDE(SUM(x.rev7), SUM(x.ad7)), 2),
  ROUND(SAFE_DIVIDE(SUM(x.g_w), SUM(x.ad7)), 2),
  ROUND(SUM(x.ad7) / (COUNT(*) * 7), 3),
  ROUND(COUNTIF(x.rev7 > 0) / COUNT(*), 3),
  ROUND(SUM(x.rev7) / COUNT(*), 2), NULL, NULL
FROM (SELECT u.album_id, u.grp, u.user_id, SUM(u.rev) AS rev7, COUNTIF(u.act) AS ad7,
        SUM(IF(u.act, SAFE_DIVIDE(g.g_rev, g.g_ad), 0)) AS g_w
      FROM uk u LEFT JOIN gday g ON g.album_id = u.album_id AND g.date_dim = u.d
      WHERE u.k BETWEEN 1 AND 7 GROUP BY 1,2,3) x
GROUP BY 1,2,3
UNION ALL
SELECT album_id, 'ALL', CAST(k_close AS STRING), ANY_VALUE(n_all),
  ROUND(SAFE_DIVIDE(SUM(g_rev), SUM(g_ad)), 2), NULL,
  ROUND(SUM(g_ad) / ANY_VALUE(n_all), 3), NULL, ROUND(SUM(g_rev) / ANY_VALUE(n_all), 2), NULL, NULL
FROM gday GROUP BY 1,3

)
SELECT grp, period, COUNT(*) AS n_albums, SUM(n_players) AS n_players,
  ROUND(AVG(arpdau),2) AS arpdau_avg, ROUND(MIN(arpdau),2) AS arpdau_min, ROUND(MAX(arpdau),2) AS arpdau_max,
  ROUND(AVG(active_rate),3) AS active_rate, ROUND(AVG(payer_rate),3) AS payer_rate,
  ROUND(AVG(share_in_next_album),3) AS next_album, ROUND(AVG(d0_share_before_completion),3) AS d0_pre
FROM res
WHERE (grp = 'ALL' AND SAFE_CAST(period AS INT64) BETWEEN 0 AND 7) OR (grp != 'ALL' AND (period != 'base' OR grp = 'F'))
GROUP BY 1,2 ORDER BY 1,2

-- ===== DOMINO (17,19) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td,
    IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl,
    IFNULL(album_spent_today,0) AS sp_alb
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE '2026-08-24' AND album_id IN (17,19)
    AND date_dim < album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
    IFNULL(sessions_today,0) > 0 AS act, IFNULL(suspected_cheater_flag,FALSE) AS bad
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-03-25' AND DATE_ADD(DATE '2026-08-24', INTERVAL 9 DAY)
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (SELECT album_id, user_id, MIN(date_dim) AS fin_d FROM ud WHERE uniq >= 144 GROUP BY 1,2),
cohort AS (
  SELECT album_id, user_id, 'F' AS grp, fin_d AS ref_d FROM fin
  UNION ALL
  SELECT f.album_id, f.user_id, 'FC', u.a_end FROM fin f
    JOIN ud u ON u.album_id = f.album_id AND u.user_id = f.user_id AND u.date_dim = DATE_SUB(u.a_end, INTERVAL 1 DAY)
  UNION ALL
  SELECT album_id, user_id, IF(uniq = 143, 'N1', 'N2'), a_end FROM ud
    WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq IN (142,143)
),
elig AS (
  SELECT c.album_id, c.user_id, c.grp, c.ref_d, u.a_start, u.a_end
  FROM cohort c
  JOIN ud u ON u.album_id = c.album_id AND u.user_id = c.user_id AND u.date_dim = DATE_SUB(c.ref_d, INTERVAL 1 DAY)
  WHERE u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND c.user_id NOT IN (SELECT user_id FROM bad_users)
),
pu AS (
  SELECT e.album_id, e.user_id, e.grp, e.ref_d, e.a_end,
    SUM(IF(m.date_dim BETWEEN e.a_start AND DATE_SUB(e.ref_d, INTERVAL 1 DAY), m.rev, 0)) AS rev_base,
    COUNTIF(m.act AND m.date_dim BETWEEN e.a_start AND DATE_SUB(e.ref_d, INTERVAL 1 DAY)) AS ad_base,
    SUM(IF(m.date_dim BETWEEN e.a_start AND DATE_SUB(e.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb,
    COUNTIF(m.act AND m.date_dim BETWEEN e.a_start AND DATE_SUB(e.a_end, INTERVAL 1 DAY)) AS ad_alb,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(e.a_end, INTERVAL 4 DAY) AND DATE_SUB(e.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_l4,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(e.a_end, INTERVAL 4 DAY) AND DATE_SUB(e.a_end, INTERVAL 1 DAY)) AS ad_l4
  FROM elig e LEFT JOIN udm m ON m.user_id = e.user_id AND m.date_dim BETWEEN e.a_start AND e.a_end
  GROUP BY 1,2,3,4,5
),
payers AS (SELECT album_id, user_id, grp, ref_d, a_end, rev_base, ad_base, rev_alb, ad_alb, rev_l4, ad_l4 FROM pu WHERE rev_base > 0),
val AS (
  SELECT p.album_id, SUM(u.sp_alb) AS sp_tbl, ANY_VALUE(0) AS z
  FROM payers p JOIN ud u ON u.album_id = p.album_id AND u.user_id = p.user_id
  WHERE p.grp IN ('FC','N1','N2') GROUP BY 1
),
valm AS (SELECT album_id, SUM(rev_alb) AS rev_m FROM payers WHERE grp IN ('FC','N1','N2') GROUP BY 1),
allpop AS (
  SELECT u.album_id, u.user_id, u.a_end
  FROM ud u JOIN udm m ON m.user_id = u.user_id AND m.date_dim BETWEEN u.a_start AND DATE_SUB(u.a_end, INTERVAL 1 DAY)
  WHERE u.date_dim = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1,2,3 HAVING SUM(m.rev) > 0
),
gday AS (
  SELECT a.album_id, d AS date_dim, DATE_DIFF(d, ANY_VALUE(a.a_end), DAY) AS k_close,
    COUNT(*) AS n_all, SUM(IFNULL(m.rev,0)) AS g_rev, COUNTIF(IFNULL(m.act,FALSE)) AS g_ad
  FROM allpop a CROSS JOIN UNNEST(GENERATE_DATE_ARRAY(a.a_end, DATE_ADD(a.a_end, INTERVAL 7 DAY))) d
  LEFT JOIN udm m ON m.user_id = a.user_id AND m.date_dim = d
  GROUP BY 1,2
),
uk AS (
  SELECT p.album_id, p.grp, p.user_id, k,
    DATE_ADD(p.ref_d, INTERVAL k DAY) >= p.a_end AS next_alb,
    IFNULL(m.rev, 0) AS rev, IFNULL(m.act, FALSE) AS act
  FROM payers p CROSS JOIN UNNEST(GENERATE_ARRAY(0,7)) k
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim = DATE_ADD(p.ref_d, INTERVAL k DAY)
),
res AS (
  SELECT album_id, grp, CAST(k AS STRING) AS period, COUNT(*) AS n_players,
    SAFE_DIVIDE(SUM(rev), COUNTIF(act)) AS arpdau, COUNTIF(act) / COUNT(*) AS active_rate,
    COUNTIF(rev > 0) / COUNT(*) AS payer_rate, COUNTIF(next_alb) / COUNT(*) AS next_album
  FROM uk GROUP BY 1,2,3
  UNION ALL
  SELECT p.album_id, p.grp, per.period, COUNT(*), SAFE_DIVIDE(SUM(per.rev), SUM(per.ad)), NULL, COUNTIF(per.rev > 0) / COUNT(*), NULL
  FROM payers p CROSS JOIN UNNEST([
    STRUCT('base' AS period, p.rev_base AS rev, p.ad_base AS ad),
    STRUCT('album', p.rev_alb, p.ad_alb), STRUCT('last4', p.rev_l4, p.ad_l4)]) per
  GROUP BY 1,2,3
  UNION ALL
  SELECT album_id, grp, 'd1_7', COUNT(*), SAFE_DIVIDE(SUM(rev7), SUM(ad7)), SUM(ad7) / (COUNT(*) * 7), COUNTIF(rev7 > 0) / COUNT(*), NULL
  FROM (SELECT album_id, grp, user_id, SUM(rev) AS rev7, COUNTIF(act) AS ad7 FROM uk WHERE k BETWEEN 1 AND 7 GROUP BY 1,2,3)
  GROUP BY 1,2,3
  UNION ALL
  SELECT album_id, 'ALL', CAST(k_close AS STRING), ANY_VALUE(n_all), SAFE_DIVIDE(SUM(g_rev), SUM(g_ad)), SUM(g_ad) / ANY_VALUE(n_all), NULL, NULL
  FROM gday GROUP BY 1,3
  UNION ALL
  SELECT v.album_id, 'VAL', 'rev_daily_metrics_vs_album_table', NULL, SAFE_DIVIDE(m.rev_m, v.sp_tbl), NULL, NULL, NULL
  FROM val v JOIN valm m USING (album_id)
)
SELECT grp, period, COUNT(*) AS n_albums, SUM(n_players) AS n_players,
  ROUND(AVG(arpdau),2) AS arpdau_avg, ROUND(MIN(arpdau),2) AS arpdau_min, ROUND(MAX(arpdau),2) AS arpdau_max,
  ROUND(AVG(active_rate),3) AS active_rate, ROUND(AVG(payer_rate),3) AS payer_rate, ROUND(AVG(next_album),3) AS next_album
FROM res
WHERE grp != 'F' OR period != 'base' OR TRUE
GROUP BY 1,2 ORDER BY 1,2

-- ===== DISNEY (14,15) =====
WITH ud AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_start, a.album_close_date AS a_end,
    IFNULL(a.unique_common_stickers_lt,0) + IFNULL(a.unique_golden_stickers_lt,0) + IFNULL(a.unique_royal_stickers_tl,0) AS uniq,
    a.login_ratio AS lr_td,
    IF(IFNULL(a.user_album_count,1) > 1, 1, 0) AS past,
    IFNULL(a.special_user_flag,FALSE) AS excl,
    IFNULL(a.album_spent_today,0) AS sp_alb
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND a.album_id IN (14,15)
    AND a.date_dim < a.album_close_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev,
    IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE_ADD(DATE '2026-10-05', INTERVAL 9 DAY)
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (SELECT album_id, user_id, MIN(date_dim) AS fin_d FROM ud WHERE uniq >= 144 GROUP BY 1,2),
cohort AS (
  SELECT album_id, user_id, 'F' AS grp, fin_d AS ref_d FROM fin
  UNION ALL
  SELECT f.album_id, f.user_id, 'FC', u.a_end FROM fin f
    JOIN ud u ON u.album_id = f.album_id AND u.user_id = f.user_id AND u.date_dim = DATE_SUB(u.a_end, INTERVAL 1 DAY)
  UNION ALL
  SELECT album_id, user_id, IF(uniq = 143, 'N1', 'N2'), a_end FROM ud
    WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq IN (142,143)
),
elig AS (
  SELECT c.album_id, c.user_id, c.grp, c.ref_d, u.a_start, u.a_end
  FROM cohort c
  JOIN ud u ON u.album_id = c.album_id AND u.user_id = c.user_id AND u.date_dim = DATE_SUB(c.ref_d, INTERVAL 1 DAY)
  WHERE u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND c.user_id NOT IN (SELECT user_id FROM bad_users)
),
pu AS (
  SELECT e.album_id, e.user_id, e.grp, e.ref_d, e.a_end,
    SUM(IF(m.date_dim BETWEEN e.a_start AND DATE_SUB(e.ref_d, INTERVAL 1 DAY), m.rev, 0)) AS rev_base,
    COUNTIF(m.act AND m.date_dim BETWEEN e.a_start AND DATE_SUB(e.ref_d, INTERVAL 1 DAY)) AS ad_base,
    SUM(IF(m.date_dim BETWEEN e.a_start AND DATE_SUB(e.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_alb,
    COUNTIF(m.act AND m.date_dim BETWEEN e.a_start AND DATE_SUB(e.a_end, INTERVAL 1 DAY)) AS ad_alb,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(e.a_end, INTERVAL 4 DAY) AND DATE_SUB(e.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_l4,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(e.a_end, INTERVAL 4 DAY) AND DATE_SUB(e.a_end, INTERVAL 1 DAY)) AS ad_l4
  FROM elig e LEFT JOIN udm m ON m.user_id = e.user_id AND m.date_dim BETWEEN e.a_start AND e.a_end
  GROUP BY 1,2,3,4,5
),
payers AS (SELECT album_id, user_id, grp, ref_d, a_end, rev_base, ad_base, rev_alb, ad_alb, rev_l4, ad_l4 FROM pu WHERE rev_base > 0),
val AS (
  SELECT p.album_id, SUM(u.sp_alb) AS sp_tbl, ANY_VALUE(0) AS z
  FROM payers p JOIN ud u ON u.album_id = p.album_id AND u.user_id = p.user_id
  WHERE p.grp IN ('FC','N1','N2') GROUP BY 1
),
valm AS (SELECT album_id, SUM(rev_alb) AS rev_m FROM payers WHERE grp IN ('FC','N1','N2') GROUP BY 1),
allpop AS (
  SELECT u.album_id, u.user_id, u.a_end
  FROM ud u JOIN udm m ON m.user_id = u.user_id AND m.date_dim BETWEEN u.a_start AND DATE_SUB(u.a_end, INTERVAL 1 DAY)
  WHERE u.date_dim = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5
    AND u.user_id NOT IN (SELECT user_id FROM bad_users)
  GROUP BY 1,2,3 HAVING SUM(m.rev) > 0
),
gday AS (
  SELECT a.album_id, d AS date_dim, DATE_DIFF(d, ANY_VALUE(a.a_end), DAY) AS k_close,
    COUNT(*) AS n_all, SUM(IFNULL(m.rev,0)) AS g_rev, COUNTIF(IFNULL(m.act,FALSE)) AS g_ad
  FROM allpop a CROSS JOIN UNNEST(GENERATE_DATE_ARRAY(a.a_end, DATE_ADD(a.a_end, INTERVAL 7 DAY))) d
  LEFT JOIN udm m ON m.user_id = a.user_id AND m.date_dim = d
  GROUP BY 1,2
),
uk AS (
  SELECT p.album_id, p.grp, p.user_id, k,
    DATE_ADD(p.ref_d, INTERVAL k DAY) >= p.a_end AS next_alb,
    IFNULL(m.rev, 0) AS rev, IFNULL(m.act, FALSE) AS act
  FROM payers p CROSS JOIN UNNEST(GENERATE_ARRAY(0,7)) k
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim = DATE_ADD(p.ref_d, INTERVAL k DAY)
),
res AS (
  SELECT album_id, grp, CAST(k AS STRING) AS period, COUNT(*) AS n_players,
    SAFE_DIVIDE(SUM(rev), COUNTIF(act)) AS arpdau, COUNTIF(act) / COUNT(*) AS active_rate,
    COUNTIF(rev > 0) / COUNT(*) AS payer_rate, COUNTIF(next_alb) / COUNT(*) AS next_album
  FROM uk GROUP BY 1,2,3
  UNION ALL
  SELECT p.album_id, p.grp, per.period, COUNT(*), SAFE_DIVIDE(SUM(per.rev), SUM(per.ad)), NULL, COUNTIF(per.rev > 0) / COUNT(*), NULL
  FROM payers p CROSS JOIN UNNEST([
    STRUCT('base' AS period, p.rev_base AS rev, p.ad_base AS ad),
    STRUCT('album', p.rev_alb, p.ad_alb), STRUCT('last4', p.rev_l4, p.ad_l4)]) per
  GROUP BY 1,2,3
  UNION ALL
  SELECT album_id, grp, 'd1_7', COUNT(*), SAFE_DIVIDE(SUM(rev7), SUM(ad7)), SUM(ad7) / (COUNT(*) * 7), COUNTIF(rev7 > 0) / COUNT(*), NULL
  FROM (SELECT album_id, grp, user_id, SUM(rev) AS rev7, COUNTIF(act) AS ad7 FROM uk WHERE k BETWEEN 1 AND 7 GROUP BY 1,2,3)
  GROUP BY 1,2,3
  UNION ALL
  SELECT album_id, 'ALL', CAST(k_close AS STRING), ANY_VALUE(n_all), SAFE_DIVIDE(SUM(g_rev), SUM(g_ad)), SUM(g_ad) / ANY_VALUE(n_all), NULL, NULL
  FROM gday GROUP BY 1,3
  UNION ALL
  SELECT v.album_id, 'VAL', 'rev_daily_metrics_vs_album_table', NULL, SAFE_DIVIDE(m.rev_m, v.sp_tbl), NULL, NULL, NULL
  FROM val v JOIN valm m USING (album_id)
)
SELECT grp, period, COUNT(*) AS n_albums, SUM(n_players) AS n_players,
  ROUND(AVG(arpdau),2) AS arpdau_avg, ROUND(MIN(arpdau),2) AS arpdau_min, ROUND(MAX(arpdau),2) AS arpdau_max,
  ROUND(AVG(active_rate),3) AS active_rate, ROUND(AVG(payer_rate),3) AS payer_rate, ROUND(AVG(next_album),3) AS next_album
FROM res
WHERE grp != 'F' OR period != 'base' OR TRUE
GROUP BY 1,2 ORDER BY 1,2

-- ===== נספח 3: מסיימים בלבד (q4m/q4b) — דייס; בדומינו/דיסני אותו מבנה עם טבלאות המשחק =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(total_spent_in_album_until_this_date,0) AS cum_alb, spent_until_album_completion AS sp_until_fin, DATE(user_album_finish_ts) AS flag_fin_d
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim < album_end_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act, FALSE AS bad
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE_ADD(DATE '2026-09-07', INTERVAL 9 DAY)
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (SELECT album_id, user_id, MIN(date_dim) AS fin_d FROM ud WHERE uniq >= 144 GROUP BY 1,2),
elig AS (
  SELECT f.album_id, f.user_id, f.fin_d, u.a_start, u.a_end, DATE_DIFF(u.a_end, f.fin_d, DAY) AS days_left,
    u.cum_alb AS cum_before, u.sp_until_fin, u.flag_fin_d
  FROM fin f JOIN ud u ON u.album_id = f.album_id AND u.user_id = f.user_id AND u.date_dim = DATE_SUB(f.fin_d, INTERVAL 1 DAY)
  WHERE u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5 AND f.user_id NOT IN (SELECT user_id FROM bad_users)
),
pu AS (
  SELECT e.album_id, e.user_id, e.fin_d, e.a_end, e.days_left, e.cum_before, e.sp_until_fin, e.flag_fin_d,
    DATE_DIFF(DATE_SUB(e.a_end, INTERVAL 5 DAY), e.a_start, DAY) + 1 AS days_base,
    SUM(IF(m.date_dim BETWEEN e.a_start AND DATE_SUB(e.a_end, INTERVAL 5 DAY), m.rev, 0)) AS rev_base,
    COUNTIF(m.act AND m.date_dim BETWEEN e.a_start AND DATE_SUB(e.a_end, INTERVAL 5 DAY)) AS ad_base,
    SUM(IF(m.date_dim BETWEEN e.a_start AND DATE_SUB(e.fin_d, INTERVAL 1 DAY), m.rev, 0)) AS rev_pre,
    COUNTIF(m.act AND m.date_dim BETWEEN e.a_start AND DATE_SUB(e.fin_d, INTERVAL 1 DAY)) AS ad_pre,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(e.a_end, INTERVAL 4 DAY) AND DATE_SUB(e.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_l4,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(e.a_end, INTERVAL 4 DAY) AND DATE_SUB(e.a_end, INTERVAL 1 DAY)) AS ad_l4
  FROM elig e LEFT JOIN udm m ON m.user_id = e.user_id AND m.date_dim BETWEEN e.a_start AND e.a_end
  GROUP BY 1,2,3,4,5,6,7,8,9
),
p AS (
  SELECT pu.*, SAFE_DIVIDE(rev_pre, ad_pre) AS pre_arpdau,
    CASE WHEN SAFE_DIVIDE(rev_pre, ad_pre) < 2 THEN 't1_lt2' WHEN SAFE_DIVIDE(rev_pre, ad_pre) < 5 THEN 't2_2_5'
         WHEN SAFE_DIVIDE(rev_pre, ad_pre) < 20 THEN 't3_5_20' ELSE 't4_20plus' END AS tier,
    CASE WHEN days_left >= 4 THEN 'c_4plus' ELSE CONCAT('c_', CAST(days_left AS STRING)) END AS timing
  FROM pu WHERE rev_pre > 0
),
uk AS (
  SELECT p.album_id, p.user_id, p.tier, p.timing, k, DATE_ADD(p.fin_d, INTERVAL k DAY) < p.a_end AS is_open,
    IFNULL(m.rev, 0) AS rev, IFNULL(m.act, FALSE) AS act,
    IF(k = 0 AND p.flag_fin_d = p.fin_d, GREATEST(IFNULL(p.sp_until_fin,0) - IFNULL(p.cum_before,0), 0), NULL) AS d0_pre
  FROM p CROSS JOIN UNNEST(GENERATE_ARRAY(0,7)) k
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim = DATE_ADD(p.fin_d, INTERVAL k DAY)
),
cum AS (SELECT album_id, user_id, k, SUM(rev) OVER (PARTITION BY album_id, user_id ORDER BY k) AS cum_rev, rev, act, is_open, d0_pre FROM uk)
SELECT album_id, CAST(k AS STRING) AS period, COUNT(*) AS n,
  ROUND(SAFE_DIVIDE(SUM(rev), COUNTIF(act)), 2) AS arpdau,
  ROUND(COUNTIF(act) / COUNT(*), 3) AS active_rate,
  ROUND(SUM(rev) / COUNT(*), 2) AS rev_per_player,
  ROUND(AVG(cum_rev), 2) AS cum_rev_per_player,
  ROUND(COUNTIF(is_open) / COUNT(*), 3) AS share_album_open,
  ROUND(SAFE_DIVIDE(SUM(IF(is_open, rev, 0)), COUNTIF(is_open AND act)), 2) AS arpdau_open,
  ROUND(SAFE_DIVIDE(SUM(IF(NOT is_open, rev, 0)), COUNTIF(NOT is_open AND act)), 2) AS arpdau_next,
  ROUND(SAFE_DIVIDE(COUNTIF(is_open AND act), COUNTIF(is_open)), 3) AS active_open,
  ROUND(SAFE_DIVIDE(COUNTIF(NOT is_open AND act), COUNTIF(NOT is_open)), 3) AS active_next,
  ROUND(SAFE_DIVIDE(SUM(d0_pre), SUM(IF(d0_pre IS NOT NULL, rev, 0))), 3) AS d0_share_pre
FROM cum GROUP BY 1,2
UNION ALL
SELECT album_id, 'd1_7', COUNT(DISTINCT user_id), ROUND(SAFE_DIVIDE(SUM(rev), COUNTIF(act)), 2), ROUND(COUNTIF(act) / COUNT(*), 3),
  ROUND(SUM(rev) / COUNT(DISTINCT user_id), 2), NULL, ROUND(COUNTIF(is_open) / COUNT(*), 3),
  ROUND(SAFE_DIVIDE(SUM(IF(is_open, rev, 0)), COUNTIF(is_open AND act)), 2),
  ROUND(SAFE_DIVIDE(SUM(IF(NOT is_open, rev, 0)), COUNTIF(NOT is_open AND act)), 2),
  ROUND(SAFE_DIVIDE(COUNTIF(is_open AND act), COUNTIF(is_open)), 3), ROUND(SAFE_DIVIDE(COUNTIF(NOT is_open AND act), COUNTIF(NOT is_open)), 3), NULL
FROM uk WHERE k BETWEEN 1 AND 7 GROUP BY 1
UNION ALL
SELECT album_id, per, COUNT(*), ROUND(SAFE_DIVIDE(SUM(r), SUM(a)), 2), ROUND(SAFE_DIVIDE(SUM(a), SUM(dd)), 3), ROUND(SUM(r) / COUNT(*), 2),
  NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM p CROSS JOIN UNNEST([STRUCT('base' AS per, rev_base AS r, ad_base AS a, days_base AS dd),
  STRUCT('pre_completion', rev_pre, ad_pre, NULL), STRUCT('last4', rev_l4, ad_l4, 4)])
GROUP BY 1,2
ORDER BY 1,2

WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(total_spent_in_album_until_this_date,0) AS cum_alb, spent_until_album_completion AS sp_until_fin, DATE(user_album_finish_ts) AS flag_fin_d
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim < album_end_date
),
udm AS (
  SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act, FALSE AS bad
  FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE_ADD(DATE '2026-09-07', INTERVAL 9 DAY)
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
fin AS (SELECT album_id, user_id, MIN(date_dim) AS fin_d FROM ud WHERE uniq >= 144 GROUP BY 1,2),
elig AS (
  SELECT f.album_id, f.user_id, f.fin_d, u.a_start, u.a_end, DATE_DIFF(u.a_end, f.fin_d, DAY) AS days_left,
    u.cum_alb AS cum_before, u.sp_until_fin, u.flag_fin_d
  FROM fin f JOIN ud u ON u.album_id = f.album_id AND u.user_id = f.user_id AND u.date_dim = DATE_SUB(f.fin_d, INTERVAL 1 DAY)
  WHERE u.past > 0 AND NOT u.excl AND u.lr_td >= 0.5 AND f.user_id NOT IN (SELECT user_id FROM bad_users)
),
pu AS (
  SELECT e.album_id, e.user_id, e.fin_d, e.a_end, e.days_left, e.cum_before, e.sp_until_fin, e.flag_fin_d,
    DATE_DIFF(DATE_SUB(e.a_end, INTERVAL 5 DAY), e.a_start, DAY) + 1 AS days_base,
    SUM(IF(m.date_dim BETWEEN e.a_start AND DATE_SUB(e.a_end, INTERVAL 5 DAY), m.rev, 0)) AS rev_base,
    COUNTIF(m.act AND m.date_dim BETWEEN e.a_start AND DATE_SUB(e.a_end, INTERVAL 5 DAY)) AS ad_base,
    SUM(IF(m.date_dim BETWEEN e.a_start AND DATE_SUB(e.fin_d, INTERVAL 1 DAY), m.rev, 0)) AS rev_pre,
    COUNTIF(m.act AND m.date_dim BETWEEN e.a_start AND DATE_SUB(e.fin_d, INTERVAL 1 DAY)) AS ad_pre,
    SUM(IF(m.date_dim BETWEEN DATE_SUB(e.a_end, INTERVAL 4 DAY) AND DATE_SUB(e.a_end, INTERVAL 1 DAY), m.rev, 0)) AS rev_l4,
    COUNTIF(m.act AND m.date_dim BETWEEN DATE_SUB(e.a_end, INTERVAL 4 DAY) AND DATE_SUB(e.a_end, INTERVAL 1 DAY)) AS ad_l4
  FROM elig e LEFT JOIN udm m ON m.user_id = e.user_id AND m.date_dim BETWEEN e.a_start AND e.a_end
  GROUP BY 1,2,3,4,5,6,7,8,9
),
p AS (
  SELECT pu.*, SAFE_DIVIDE(rev_pre, ad_pre) AS pre_arpdau,
    CASE WHEN SAFE_DIVIDE(rev_pre, ad_pre) < 2 THEN 't1_lt2' WHEN SAFE_DIVIDE(rev_pre, ad_pre) < 5 THEN 't2_2_5'
         WHEN SAFE_DIVIDE(rev_pre, ad_pre) < 20 THEN 't3_5_20' ELSE 't4_20plus' END AS tier,
    CASE WHEN days_left >= 4 THEN 'c_4plus' ELSE CONCAT('c_', CAST(days_left AS STRING)) END AS timing
  FROM pu WHERE rev_pre > 0
),
uk AS (
  SELECT p.album_id, p.user_id, p.tier, p.timing, k, DATE_ADD(p.fin_d, INTERVAL k DAY) < p.a_end AS is_open,
    IFNULL(m.rev, 0) AS rev, IFNULL(m.act, FALSE) AS act,
    IF(k = 0 AND p.flag_fin_d = p.fin_d, GREATEST(IFNULL(p.sp_until_fin,0) - IFNULL(p.cum_before,0), 0), NULL) AS d0_pre
  FROM p CROSS JOIN UNNEST(GENERATE_ARRAY(0,7)) k
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim = DATE_ADD(p.fin_d, INTERVAL k DAY)
),
dims AS (
  SELECT album_id, user_id, CONCAT('tier:', tier) AS seg FROM p UNION ALL
  SELECT album_id, user_id, CONCAT('timing:', timing) FROM p UNION ALL
  SELECT album_id, user_id, 'all' FROM p
),
per_user AS (
  SELECT album_id, user_id,
    SUM(IF(k = 0, rev, 0)) AS r0, COUNTIF(k = 0 AND act) AS a0,
    SUM(IF(k BETWEEN 1 AND 3, rev, 0)) AS r13, COUNTIF(k BETWEEN 1 AND 3 AND act) AS a13,
    SUM(IF(k BETWEEN 4 AND 7, rev, 0)) AS r47, COUNTIF(k BETWEEN 4 AND 7 AND act) AS a47,
    COUNTIF(k BETWEEN 1 AND 7 AND is_open) AS open_days
  FROM uk GROUP BY 1,2
)
SELECT d.album_id, d.seg, COUNT(*) AS n,
  ROUND(SAFE_DIVIDE(SUM(p.rev_base), SUM(p.ad_base)), 2) AS arpdau_base,
  ROUND(SAFE_DIVIDE(SUM(p.rev_l4), SUM(p.ad_l4)), 2) AS arpdau_last4,
  ROUND(SAFE_DIVIDE(SUM(u.r0), SUM(u.a0)), 2) AS arpdau_d0,
  ROUND(SAFE_DIVIDE(SUM(u.r13), SUM(u.a13)), 2) AS arpdau_d1_3,
  ROUND(SAFE_DIVIDE(SUM(u.r47), SUM(u.a47)), 2) AS arpdau_d4_7,
  ROUND(SAFE_DIVIDE(SUM(u.r13 + u.r47), SUM(u.a13 + u.a47)), 2) AS arpdau_d1_7,
  ROUND(SAFE_DIVIDE(SUM(p.ad_base), SUM(p.days_base)), 3) AS active_base,
  ROUND(SUM(u.a13 + u.a47) / (COUNT(*) * 7), 3) AS active_d1_7,
  ROUND(SUM(u.r13 + u.r47) / COUNT(*), 2) AS rev_pp_d1_7,
  ROUND(SUM(u.open_days) / (COUNT(*) * 7), 3) AS share_days_open
FROM dims d JOIN p USING (album_id, user_id) JOIN per_user u USING (album_id, user_id)
GROUP BY 1,2 ORDER BY 1,2

-- ===== נספח 4: חסרי 1/2/3 מיום הסגירה (q5) — דייס; דומינו/דיסני אותו מבנה =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND album_id IN (61,62,63) AND date_dim = DATE_SUB(album_end_date, INTERVAL 1 DAY)
),
udm AS (SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act, FALSE AS bad FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE_ADD(DATE '2026-09-07', INTERVAL 9 DAY)),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
c AS (
  SELECT album_id, user_id, a_start, a_end, IF(uniq >= 144, 'm0_fin', CONCAT('m', CAST(144 - uniq AS STRING))) AS coh
  FROM ud WHERE uniq >= 141 AND past > 0 AND NOT excl AND lr_td >= 0.5 AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pu AS (
  SELECT c.album_id, c.user_id, c.a_end, c.coh,
    DATE_DIFF(DATE_SUB(c.a_end, INTERVAL 5 DAY), c.a_start, DAY) + 1 AS days_base,
    SUM(IF(m.date_dim <= DATE_SUB(c.a_end, INTERVAL 5 DAY), m.rev, 0)) AS rev_base,
    COUNTIF(m.act AND m.date_dim <= DATE_SUB(c.a_end, INTERVAL 5 DAY)) AS ad_base,
    SUM(IF(m.date_dim < c.a_end, m.rev, 0)) AS rev_pre,
    COUNTIF(m.act AND m.date_dim < c.a_end) AS ad_pre,
    SUM(IF(m.date_dim >= DATE_SUB(c.a_end, INTERVAL 4 DAY) AND m.date_dim < c.a_end, m.rev, 0)) AS rev_l4,
    COUNTIF(m.act AND m.date_dim >= DATE_SUB(c.a_end, INTERVAL 4 DAY) AND m.date_dim < c.a_end) AS ad_l4
  FROM c LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN c.a_start AND DATE_SUB(c.a_end, INTERVAL 1 DAY)
  GROUP BY 1,2,3,4,5
),
p AS (
  SELECT album_id, user_id, a_end, coh, days_base, rev_base, ad_base, rev_l4, ad_l4,
    CASE WHEN SAFE_DIVIDE(rev_pre, ad_pre) < 2 THEN 't1_lt2' WHEN SAFE_DIVIDE(rev_pre, ad_pre) < 5 THEN 't2_2_5'
         WHEN SAFE_DIVIDE(rev_pre, ad_pre) < 20 THEN 't3_5_20' ELSE 't4_20plus' END AS tier
  FROM pu WHERE rev_pre > 0
),
uk AS (
  SELECT p.album_id, p.user_id, p.coh, k, IFNULL(m.rev, 0) AS rev, IFNULL(m.act, FALSE) AS act
  FROM p CROSS JOIN UNNEST(GENERATE_ARRAY(0,7)) k
  LEFT JOIN udm m ON m.user_id = p.user_id AND m.date_dim = DATE_ADD(p.a_end, INTERVAL k DAY)
),
cum AS (SELECT album_id, coh, k, SUM(rev) OVER (PARTITION BY album_id, user_id ORDER BY k) AS cum_rev, rev, act FROM uk),
per_user AS (
  SELECT album_id, user_id,
    SUM(IF(k = 0, rev, 0)) AS r0, COUNTIF(k = 0 AND act) AS a0,
    SUM(IF(k BETWEEN 1 AND 3, rev, 0)) AS r13, COUNTIF(k BETWEEN 1 AND 3 AND act) AS a13,
    SUM(IF(k BETWEEN 4 AND 7, rev, 0)) AS r47, COUNTIF(k BETWEEN 4 AND 7 AND act) AS a47
  FROM uk GROUP BY 1,2
),
dims AS (SELECT album_id, user_id, coh, 'all' AS seg FROM p UNION ALL SELECT album_id, user_id, coh, tier FROM p)
SELECT 'M' AS t, album_id, coh, CAST(k AS STRING) AS seg, COUNT(*) AS n,
  ROUND(SAFE_DIVIDE(SUM(rev), COUNTIF(act)), 2) AS arpdau, ROUND(COUNTIF(act) / COUNT(*), 3) AS active,
  ROUND(SUM(rev) / COUNT(*), 2) AS rev_pp, ROUND(AVG(cum_rev), 2) AS cum_pp,
  CAST(NULL AS FLOAT64) AS x1, CAST(NULL AS FLOAT64) AS x2, CAST(NULL AS FLOAT64) AS x3, CAST(NULL AS FLOAT64) AS x4, CAST(NULL AS FLOAT64) AS x5
FROM cum GROUP BY 1,2,3,4
UNION ALL
SELECT 'B', d.album_id, d.coh, d.seg, COUNT(*),
  ROUND(SAFE_DIVIDE(SUM(p.rev_base), SUM(p.ad_base)), 2),
  ROUND(SAFE_DIVIDE(SUM(p.rev_l4), SUM(p.ad_l4)), 2),
  ROUND(SAFE_DIVIDE(SUM(u.r0), SUM(u.a0)), 2),
  ROUND(SAFE_DIVIDE(SUM(u.r13), SUM(u.a13)), 2),
  ROUND(SAFE_DIVIDE(SUM(u.r47), SUM(u.a47)), 2),
  ROUND(SAFE_DIVIDE(SUM(u.r13 + u.r47), SUM(u.a13 + u.a47)), 2),
  ROUND(SAFE_DIVIDE(SUM(p.ad_base), SUM(p.days_base)), 3),
  ROUND(SUM(u.a13 + u.a47) / (COUNT(*) * 7), 3),
  ROUND(SUM(u.r13 + u.r47) / COUNT(*), 2)
FROM dims d JOIN p USING (album_id, user_id) JOIN per_user u USING (album_id, user_id)
GROUP BY 2,3,4
ORDER BY 1,2,3,4
-- ===== נספח 4ב: שווי 20$+ חסרי 2–3 (q6) — דייס; דומינו/דיסני אותו מבנה =====
WITH ud AS (
  SELECT album_id, user_id, album_start_date AS a_start, album_end_date AS a_end, IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_super_stickers_lt,0) AS uniq,
    album_login_ratio_until_this_day AS lr_td, IF(IFNULL(user_past_album_count,0) > 0, 1, 0) AS past, IFNULL(is_excluded,FALSE) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim = DATE_SUB(album_end_date, INTERVAL 1 DAY)
),
udm AS (SELECT user_id, date_dim, IFNULL(revenues_sum,0) AS rev, IFNULL(sessions_cnt,0) > 0 AS act, FALSE AS bad FROM `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` WHERE date_dim BETWEEN DATE '2026-06-01' AND DATE_ADD(DATE '2026-09-07', INTERVAL 9 DAY)),
alb AS (SELECT DISTINCT album_id, a_start, a_end FROM ud),
tot AS (
  SELECT a.album_id, SUM(IF(m.date_dim < a.a_end, m.rev, 0)) AS tot_alb,
    SUM(IF(m.date_dim > a.a_end, m.rev, 0)) AS tot_post7
  FROM alb a JOIN udm m ON m.date_dim BETWEEN a.a_start AND DATE_ADD(a.a_end, INTERVAL 7 DAY)
  GROUP BY 1
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
c AS (
  SELECT album_id, user_id, a_start, a_end, IF(uniq >= 144, 'm0_fin', CONCAT('m', CAST(144 - uniq AS STRING))) AS coh
  FROM ud WHERE uniq >= 141 AND past > 0 AND NOT excl AND lr_td >= 0.5 AND user_id NOT IN (SELECT user_id FROM bad_users)
),
pu AS (
  SELECT c.album_id, c.user_id, c.coh,
    DATE_DIFF(DATE_SUB(c.a_end, INTERVAL 5 DAY), c.a_start, DAY) + 1 AS days_base,
    SUM(IF(m.date_dim <= DATE_SUB(c.a_end, INTERVAL 5 DAY), m.rev, 0)) AS rev_base,
    SUM(IF(m.date_dim < c.a_end, m.rev, 0)) AS rev_alb,
    COUNTIF(m.act AND m.date_dim < c.a_end) AS ad_pre,
    SUM(IF(m.date_dim >= DATE_SUB(c.a_end, INTERVAL 4 DAY) AND m.date_dim < c.a_end, m.rev, 0)) AS rev_l4,
    SUM(IF(m.date_dim > c.a_end, m.rev, 0)) AS rev_post7
  FROM c LEFT JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN c.a_start AND DATE_ADD(c.a_end, INTERVAL 7 DAY)
  GROUP BY 1,2,3,4
),
p AS (
  SELECT album_id, coh, days_base, rev_base, rev_alb, rev_l4, rev_post7,
    IF(SAFE_DIVIDE(rev_alb, ad_pre) >= 20, 't4_20plus', 'lt20') AS tier
  FROM pu WHERE rev_alb > 0
)
SELECT p.album_id, p.coh, p.tier, COUNT(*) AS n,
  ROUND(SUM(p.rev_alb)) AS rev_album, ROUND(SUM(p.rev_l4)) AS rev_last4,
  ROUND(SUM(p.rev_post7)) AS rev_post7, ROUND(SUM(p.rev_base / p.days_base * 7)) AS expected_post7_at_base_pace,
  ROUND(ANY_VALUE(t.tot_alb)) AS game_rev_album, ROUND(ANY_VALUE(t.tot_post7)) AS game_rev_post7
FROM p JOIN tot t USING (album_id)
GROUP BY 1,2,3 ORDER BY 1,2,3
-- ===== נספח 5: מנגנון ירידה, דיסני (q7) =====
WITH ud AS (
  SELECT album_id, user_id, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-05' AND album_id IN (14,15) AND date_dim = DATE_SUB(album_close_date, INTERVAL 1 DAY)
),
udm AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, IFNULL(total_sessions_count,0) > 0 AS act, exclude_reason IS NOT NULL AS bad,
    cz_a, cz_discount, tier_num, startday_coins_balance AS coins_s, enday_coins_balance AS coins_e,
    IFNULL(out_of_coins_counter,0) AS ooc,
    IFNULL(levels_played_mode_1,0)+IFNULL(levels_played_mode_2,0)+IFNULL(levels_played_mode_3,0)+IFNULL(levels_played_mode_4,0) AS lp,
    IFNULL(levels_won_mode_1,0)+IFNULL(levels_won_mode_2,0)+IFNULL(levels_won_mode_3,0)+IFNULL(levels_won_mode_4,0) AS lw,
    IFNULL(wilds_used,0)+IFNULL(undos_used,0)+IFNULL(extra_stock_used,0) AS boosters_used
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-14'
),
bad_users AS (SELECT DISTINCT user_id FROM udm WHERE bad),
c AS (
  SELECT album_id, user_id, a_start, a_end,
    CASE WHEN uniq >= 144 THEN 'a_fin' WHEN uniq = 143 THEN 'b_m1' ELSE 'c_m2_3' END AS coh
  FROM ud WHERE uniq >= 141 AND past > 0 AND NOT excl AND lr_td >= 0.5 AND user_id NOT IN (SELECT user_id FROM bad_users)
),
cu AS (
  SELECT c.album_id, c.user_id, c.coh,
    CASE WHEN m.date_dim <= DATE_SUB(c.a_end, INTERVAL 5 DAY) THEN '1_base'
         WHEN m.date_dim < c.a_end THEN '2_last4'
         WHEN m.date_dim > c.a_end THEN '3_post7' END AS per,
    m.rev, m.act, m.cz_a, m.cz_discount, m.tier_num, m.coins_s, m.coins_e, m.ooc, m.lp, m.lw, m.boosters_used
  FROM c JOIN udm m ON m.user_id = c.user_id AND m.date_dim BETWEEN c.a_start AND DATE_ADD(c.a_end, INTERVAL 7 DAY) AND m.date_dim != c.a_end
),
tierq AS (
  SELECT album_id, user_id, IF(SAFE_DIVIDE(SUM(IF(per IN ('1_base','2_last4'), rev, 0)), COUNTIF(act AND per IN ('1_base','2_last4'))) >= 20, 't20plus', 'lt20') AS spend_tier
  FROM cu GROUP BY 1,2 HAVING SUM(IF(per IN ('1_base','2_last4'), rev, 0)) > 0
)
SELECT cu.album_id, cu.coh, t.spend_tier, cu.per, COUNT(DISTINCT cu.user_id) AS n,
  ROUND(SAFE_DIVIDE(SUM(rev), COUNTIF(act)), 2) AS arpdau,
  ROUND(AVG(IF(act, cz_a, NULL)), 2) AS cz_a_avg,
  ROUND(AVG(IF(act, cz_discount, NULL)), 2) AS cz_discount_avg,
  ROUND(AVG(IF(act, tier_num, NULL)), 2) AS tier_num_avg,
  APPROX_QUANTILES(IF(act, coins_e, NULL), 2)[OFFSET(1)] AS coins_end_median,
  ROUND(SAFE_DIVIDE(SUM(IF(act, coins_e - coins_s, 0)), COUNTIF(act))) AS coins_delta_per_active_day,
  ROUND(SAFE_DIVIDE(SUM(ooc), COUNTIF(act)), 2) AS out_of_coins_per_active_day,
  ROUND(SAFE_DIVIDE(SUM(lp), COUNTIF(act)), 1) AS levels_per_active_day,
  ROUND(SAFE_DIVIDE(SUM(lw), SUM(lp)), 3) AS win_rate,
  ROUND(SAFE_DIVIDE(SUM(boosters_used), COUNTIF(act)), 1) AS boosters_per_active_day,
  ROUND(SAFE_DIVIDE(SUM(lp), SUM(rev)), 1) AS levels_per_dollar
FROM cu JOIN tierq t USING (album_id, user_id)
GROUP BY 1,2,3,4 ORDER BY 1,2,3,4

