-- Topic 4 gates rerun (Eden 2026-10-22). Results: claude/topic4-gates-2026-10-22.md
-- Same measures as the v82 'gates' slide (source endgame-last-week-2026-10-14), new populations:
--   Domino 19/20 (was 17/19), Dice 61/63 on the fixed first-album rule; payer = paid on any album day incl. close day.
-- Gate stickers: Dice 61 S143 / S120 / G142, Dice 63 S132 / S143 / G129, Domino 19 R107 / R108 / G101 (from the old slide);
--   Domino 20 R119 / R120 / G139 (new: the two scarcest Royals, 32K holders vs 126K+ for every other Royal, and the last
--   Golden released — same pattern as album 19). Top gate sticker = first listed.
-- Measures per album: (a) share of payers holding the top gate sticker by the end of close-2;
--   (b) near-finishers (1-3 missing at the end of the close day): share missing at least one gate sticker.
-- Revenue share = album-table spend start..close-1 / total game purchase revenue during the album (opening-facts-2026-10-20.md).

-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_close_date AS a_end,
    IFNULL(unique_common_stickers_lt,0) + IFNULL(unique_golden_stickers_lt,0) + IFNULL(unique_royal_stickers_tl,0) AS uniq,
    login_ratio AS lr, IFNULL(user_album_count,1) > 1 AS past, IFNULL(special_user_flag,FALSE) AS excl, IFNULL(album_spent_today,0) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND album_id IN (19,20) AND date_dim <= album_close_date
),
bad_users AS (
  SELECT DISTINCT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND IFNULL(suspected_cheater_flag,FALSE)
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end, MAX(uniq) AS uniq_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS lr,
    ARRAY_AGG(IF(date_dim < a_end, past, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS past,
    ARRAY_AGG(IF(date_dim < a_end, excl, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS excl
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT album_id, user_id, a_end, uniq_end, alb_rev FROM u0
  WHERE last_d = DATE_SUB(a_end, INTERVAL 1 DAY) AND past AND NOT excl AND lr >= 0.5 AND rev_all > 0
    AND user_id NOT IN (SELECT user_id FROM bad_users)
),
gate AS (
  SELECT 19 AS album_id, 107 AS sticker_id, TRUE AS top UNION ALL SELECT 19, 108, FALSE UNION ALL SELECT 19, 101, FALSE
  UNION ALL SELECT 20, 119, TRUE UNION ALL SELECT 20, 120, FALSE UNION ALL SELECT 20, 139, FALSE
),
gs AS (
  SELECT s.album_id, s.user_id, g.sticker_id, ANY_VALUE(g.top) AS top, MIN(s.sticker_collected_min_date) AS d1
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s JOIN gate g USING (album_id, sticker_id)
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-05-01' AND DATE '2026-10-12' AND s.album_id IN (19,20) AND s.user_collected_sticker_flag
  GROUP BY 1,2,3
),
pu AS (
  SELECT p.album_id, p.user_id, p.uniq_end, p.alb_rev,
    LOGICAL_OR(g.top AND g.d1 <= DATE_SUB(p.a_end, INTERVAL 2 DAY)) AS top_d2,
    COUNTIF(g.d1 <= p.a_end) AS gates_end
  FROM pop p LEFT JOIN gs g ON g.album_id = p.album_id AND g.user_id = p.user_id
  GROUP BY 1,2,3,4
),
game AS (SELECT 19 AS album_id, 17644426.0 AS game_rev UNION ALL SELECT 20, 16269671.0)
SELECT u.album_id, COUNT(*) AS payers, ROUND(SUM(u.alb_rev) / ANY_VALUE(g.game_rev), 4) AS sh_rev_payers,
  COUNTIF(IFNULL(u.top_d2, FALSE)) AS top_gate_d2, ROUND(COUNTIF(IFNULL(u.top_d2, FALSE)) / COUNT(*), 4) AS sh_top_gate_d2,
  ROUND(SUM(IF(IFNULL(u.top_d2, FALSE), u.alb_rev, 0)) / ANY_VALUE(g.game_rev), 4) AS sh_rev_top_gate_d2,
  COUNTIF(144 - u.uniq_end BETWEEN 1 AND 3) AS near, ROUND(SUM(IF(144 - u.uniq_end BETWEEN 1 AND 3, u.alb_rev, 0)) / ANY_VALUE(g.game_rev), 4) AS sh_rev_near,
  COUNTIF(144 - u.uniq_end BETWEEN 1 AND 3 AND u.gates_end < 3) AS near_missing_gate,
  ROUND(COUNTIF(144 - u.uniq_end BETWEEN 1 AND 3 AND u.gates_end < 3) / COUNTIF(144 - u.uniq_end BETWEEN 1 AND 3), 4) AS sh_near_missing_gate
FROM pu u JOIN game g USING (album_id)
GROUP BY 1 ORDER BY 1
;

-- ===== DICE 61/63 (dice-dreams-dbt) =====
WITH ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end,
    album_login_ratio_until_this_day AS lr, IFNULL(is_excluded,FALSE) AS excl, IFNULL(spent_in_album_today,0) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-22' AND DATE '2026-09-07' AND album_id IN (61,63) AND date_dim <= album_end_date
),
hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07'
  GROUP BY 1
),
stk1 AS (
  SELECT album_id, user_id, sticker_id, MIN(sticker_collected_date) AS d1
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers`
  WHERE sticker_collected_date BETWEEN DATE '2026-05-01' AND DATE '2026-09-07' AND album_id IN (61,63)
    AND sticker_type IN ('common','golden','super') AND IFNULL(is_sticker_collected, TRUE)
  GROUP BY 1,2,3
),
u0 AS (
  SELECT album_id, user_id, ANY_VALUE(a_end) AS a_end,
    SUM(IF(date_dim < a_end, spend, 0)) AS alb_rev, SUM(spend) AS rev_all,
    MAX(IF(date_dim < a_end, date_dim, NULL)) AS last_d,
    ARRAY_AGG(IF(date_dim < a_end, lr, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS lr,
    ARRAY_AGG(IF(date_dim < a_end, excl, NULL) IGNORE NULLS ORDER BY date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] AS excl
  FROM ud GROUP BY 1,2
),
pop AS (
  SELECT u.album_id, u.user_id, u.a_end, u.alb_rev FROM u0 u JOIN hist h USING (user_id)
  WHERE u.last_d = DATE_SUB(u.a_end, INTERVAL 1 DAY) AND h.first_album_seen < u.album_id AND NOT u.excl AND u.lr >= 0.5 AND u.rev_all > 0
),
gate AS (
  SELECT 61 AS album_id, 143 AS sticker_id, TRUE AS top UNION ALL SELECT 61, 120, FALSE UNION ALL SELECT 61, 142, FALSE
  UNION ALL SELECT 63, 132, TRUE UNION ALL SELECT 63, 143, FALSE UNION ALL SELECT 63, 129, FALSE
),
pu AS (
  SELECT p.album_id, p.user_id, p.alb_rev,
    COUNTIF(k.d1 <= p.a_end) AS uniq_end,
    LOGICAL_OR(g.top AND k.d1 <= DATE_SUB(p.a_end, INTERVAL 2 DAY)) AS top_d2,
    COUNTIF(g.sticker_id IS NOT NULL AND k.d1 <= p.a_end) AS gates_end
  FROM pop p LEFT JOIN stk1 k ON k.album_id = p.album_id AND k.user_id = p.user_id
  LEFT JOIN gate g ON g.album_id = k.album_id AND g.sticker_id = k.sticker_id
  GROUP BY 1,2,3
),
game AS (SELECT 61 AS album_id, 25342929.0 AS game_rev UNION ALL SELECT 63, 30317756.0)
SELECT u.album_id, COUNT(*) AS payers, ROUND(SUM(u.alb_rev) / ANY_VALUE(g.game_rev), 4) AS sh_rev_payers,
  COUNTIF(u.uniq_end >= 144) AS finishers,
  COUNTIF(IFNULL(u.top_d2, FALSE)) AS top_gate_d2, ROUND(COUNTIF(IFNULL(u.top_d2, FALSE)) / COUNT(*), 4) AS sh_top_gate_d2,
  ROUND(SUM(IF(IFNULL(u.top_d2, FALSE), u.alb_rev, 0)) / ANY_VALUE(g.game_rev), 4) AS sh_rev_top_gate_d2,
  COUNTIF(144 - u.uniq_end BETWEEN 1 AND 3) AS near, ROUND(SUM(IF(144 - u.uniq_end BETWEEN 1 AND 3, u.alb_rev, 0)) / ANY_VALUE(g.game_rev), 4) AS sh_rev_near,
  COUNTIF(144 - u.uniq_end BETWEEN 1 AND 3 AND u.gates_end < 3) AS near_missing_gate,
  ROUND(COUNTIF(144 - u.uniq_end BETWEEN 1 AND 3 AND u.gates_end < 3) / COUNTIF(144 - u.uniq_end BETWEEN 1 AND 3), 4) AS sh_near_missing_gate
FROM pu u JOIN game g USING (album_id)
GROUP BY 1 ORDER BY 1
;
