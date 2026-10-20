-- DRAFT 2026-10-18: Domino 19 vs 20 — source of the last new sticker for ALL finishers, and revenue per finisher.
-- Finisher definition as before. Revenue = album_spent_today (album table) over album days (open .. last full day).
-- Last sticker source logic as in nonpayer_finishers_queries.sql (int_user_album_stickers, new_sticker_source, joker flag).
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_open_date AS a_start, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr_td, IF(IFNULL(user_album_count,1) > 1, 1, 0) AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim < album_close_date
),
bad_users AS (SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)),
fin AS (
  SELECT album_id, user_id, a_start, a_end FROM ud
  WHERE date_dim = DATE_SUB(a_end, INTERVAL 1 DAY) AND uniq >= 144 AND past > 0 AND NOT excl AND lr_td >= 0.5
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
rev AS (
  SELECT f.album_id, f.user_id, SUM(u.spend) AS rev_alb
  FROM fin f JOIN ud u USING (album_id, user_id) GROUP BY 1,2
),
first_st AS (
  SELECT f.album_id, f.user_id, s.sticker_collected_min_ts AS ts,
    COALESCE(NULLIF(s.new_sticker_source, ''), CONCAT('camp:', IFNULL(s.new_sticker_mtx_campaign_name, '(null)'))) AS src,
    IFNULL(s.collected_by_joker_flag, FALSE) AS joker
  FROM fin f JOIN `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s ON s.album_id = f.album_id AND s.user_id = f.user_id
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND s.album_id IN (19,20) AND s.user_collected_sticker_flag
    AND s.sticker_collected_min_date >= f.a_start AND s.sticker_collected_min_date < f.a_end
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.album_id, f.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1
),
last_st AS (
  SELECT album_id, user_id, src, joker FROM first_st
  QUALIFY ROW_NUMBER() OVER (PARTITION BY album_id, user_id ORDER BY ts DESC) = 1
),
j AS (
  SELECT r.album_id, r.user_id, r.rev_alb, IFNULL(l.src, '(none)') AS src, IFNULL(l.joker, FALSE) AS joker
  FROM rev r LEFT JOIN last_st l USING (album_id, user_id)
),
g AS (
  SELECT album_id, src, joker, COUNT(*) AS n, COUNTIF(rev_alb > 0) AS payers, SUM(rev_alb) AS rev,
    ROW_NUMBER() OVER (PARTITION BY album_id ORDER BY COUNT(*) DESC) AS rn
  FROM j GROUP BY 1,2,3
),
t AS (SELECT album_id, COUNT(*) AS fin_n, SUM(rev_alb) AS fin_rev, COUNTIF(rev_alb > 0) AS fin_payers FROM j GROUP BY 1)
SELECT g.album_id, IF(rn <= 10, src, 'Other') AS last_src, IF(rn <= 10, joker, NULL) AS joker,
  SUM(n) AS finishers, ROUND(100 * SUM(n) / ANY_VALUE(t.fin_n), 1) AS pct_of_finishers,
  ROUND(100 * SUM(payers) / SUM(n), 1) AS pct_payers,
  ROUND(SUM(rev)) AS album_rev, ROUND(SUM(rev) / SUM(n), 2) AS rev_per_finisher,
  ANY_VALUE(t.fin_n) AS all_finishers, ROUND(ANY_VALUE(t.fin_rev)) AS all_finishers_rev,
  ROUND(ANY_VALUE(t.fin_rev) / ANY_VALUE(t.fin_n), 2) AS all_rev_per_finisher,
  ROUND(100 * ANY_VALUE(t.fin_payers) / ANY_VALUE(t.fin_n), 1) AS all_pct_payers
FROM g JOIN t USING (album_id)
GROUP BY 1,2,3 ORDER BY 1, finishers DESC
