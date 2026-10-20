-- Cross-game album benchmark: query pack (2026-10-08). NOTE: spent_in_album_today / album_spent_today = game spend on album days (Dice check: ~total game revenue), not album-only revenue. Run each block with project= set to the studio project.
-- Window 2025-04-01..2026-10-06; albums closing 2025-10-01..2026-10-07; benchmark albums Dice 61/63, Domino 17/19, Disney 14/15.

-- ================= PARTICIPANTS =================
-- Dice (dice-dreams-dbt) :: participants per album with install-based eligibility (installed >= 2025-04-01) and cohort split
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MAX(album_end_date) AS a_end,
         COUNT(DISTINCT album_start_date) AS n_open_dates, COUNT(DISTINCT album_end_date) AS n_close_dates, MIN(date_dim) AS first_row_date
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' GROUP BY 1
  HAVING MAX(album_end_date) BETWEEN DATE '2025-10-01' AND DATE '2026-10-07'
),
inst AS (
  SELECT user_id FROM `dice-dreams-dbt.50_reporting.user_profile`
  WHERE install_date BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
),
ua AS (
  SELECT user_id, album_id, MIN(user_album_start_date) AS start_d,
         LOGICAL_OR(IFNULL(is_active, FALSE) AND date_dim < album_end_date) AS act,
         SUM(IF(date_dim < album_end_date, IFNULL(spent_in_album_today, 0), 0)) AS spend,
         LOGICAL_OR(IFNULL(is_excluded, FALSE)) AS excl
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
  GROUP BY 1, 2
),
seq AS (
  SELECT u.user_id, u.album_id, u.act, u.spend, u.excl, i.user_id IS NOT NULL AS elig,
         ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY u.start_d, u.album_id) AS n
  FROM ua u LEFT JOIN inst i ON i.user_id = u.user_id
)
SELECT a.album_id, a.a_start, a.a_end, DATE_DIFF(a.a_end, a.a_start, DAY) AS span_days,
  a.n_open_dates, a.n_close_dates, a.first_row_date,
  COUNT(*) AS participants_all, COUNTIF(s.elig) AS participants_eligible, COUNTIF(NOT s.elig) AS excluded_installed_before_window,
  COUNTIF(s.spend > 0) AS pu_all, COUNTIF(s.elig AND s.spend > 0) AS pu_eligible,
  COUNTIF(s.elig AND s.n = 1) AS cohort_1, COUNTIF(s.elig AND s.n BETWEEN 2 AND 3) AS cohort_2_3,
  COUNTIF(s.elig AND s.n BETWEEN 4 AND 6) AS cohort_4_6, COUNTIF(s.elig AND s.n >= 7) AS cohort_7plus
FROM alb a JOIN seq s ON s.album_id = a.album_id AND s.act AND NOT s.excl
GROUP BY 1, 2, 3, 4, 5, 6, 7 ORDER BY 1;
-- NOTE: for Disney the run also joined bi_prod.user_profile (exclude_reason IS NULL) to the participant universe, and for Domino
-- excluded suspected cheaters (user_daily_metrics) from the participant universe; the eligible-player logic above is identical.

-- Domino (domino-dreams-dbt) :: participants per album with install-based eligibility (installed >= 2025-04-01) and cohort split
WITH alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end,
         COUNT(DISTINCT album_open_date) AS n_open_dates, COUNT(DISTINCT album_close_date) AS n_close_dates, MIN(date_dim) AS first_row_date
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' GROUP BY 1
  HAVING MAX(album_close_date) BETWEEN DATE '2025-10-01' AND DATE '2026-10-07'
),
inst AS (
  SELECT user_id
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
  GROUP BY 1
  HAVING LOGICAL_OR(first_seen_date >= DATE '2025-04-01') AND NOT LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))
),
ua AS (
  SELECT user_id, album_id, MIN(user_album_start_date) AS start_d,
         LOGICAL_OR(IFNULL(active_flag, FALSE) AND date_dim < album_close_date) AS act,
         SUM(IF(date_dim < album_close_date, IFNULL(album_spent_today, 0), 0)) AS spend,
         LOGICAL_OR(IFNULL(special_user_flag, FALSE)) AS excl
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
  GROUP BY 1, 2
),
seq AS (
  SELECT u.user_id, u.album_id, u.act, u.spend, u.excl, i.user_id IS NOT NULL AS elig,
         ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY u.start_d, u.album_id) AS n
  FROM ua u LEFT JOIN inst i ON i.user_id = u.user_id
)
SELECT a.album_id, a.a_start, a.a_end, DATE_DIFF(a.a_end, a.a_start, DAY) AS span_days,
  a.n_open_dates, a.n_close_dates, a.first_row_date,
  COUNT(*) AS participants_all, COUNTIF(s.elig) AS participants_eligible, COUNTIF(NOT s.elig) AS excluded_installed_before_window,
  COUNTIF(s.spend > 0) AS pu_all, COUNTIF(s.elig AND s.spend > 0) AS pu_eligible,
  COUNTIF(s.elig AND s.n = 1) AS cohort_1, COUNTIF(s.elig AND s.n BETWEEN 2 AND 3) AS cohort_2_3,
  COUNTIF(s.elig AND s.n BETWEEN 4 AND 6) AS cohort_4_6, COUNTIF(s.elig AND s.n >= 7) AS cohort_7plus
FROM alb a JOIN seq s ON s.album_id = a.album_id AND s.act AND NOT s.excl
GROUP BY 1, 2, 3, 4, 5, 6, 7 ORDER BY 1;
-- NOTE: for Disney the run also joined bi_prod.user_profile (exclude_reason IS NULL) to the participant universe, and for Domino
-- excluded suspected cheaters (user_daily_metrics) from the participant universe; the eligible-player logic above is identical.

-- Disney (solitaire-dreams-411507) :: participants per album with install-based eligibility (installed >= 2025-04-01) and cohort split
WITH alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end,
         COUNT(DISTINCT album_open_date) AS n_open_dates, COUNT(DISTINCT album_close_date) AS n_close_dates, MIN(date_dim) AS first_row_date
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' GROUP BY 1
  HAVING MAX(album_close_date) BETWEEN DATE '2025-10-01' AND DATE '2026-10-07' AND album_id >= 7
),
inst AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' AND exclude_reason IS NULL
),
ua AS (
  SELECT user_id, album_id, MIN(user_album_start_date) AS start_d,
         LOGICAL_OR(IFNULL(active_flag, FALSE) AND date_dim < album_close_date) AS act,
         SUM(IF(date_dim < album_close_date, IFNULL(album_spent_today, 0), 0)) AS spend,
         LOGICAL_OR(IFNULL(special_user_flag, FALSE)) AS excl
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
  GROUP BY 1, 2
),
seq AS (
  SELECT u.user_id, u.album_id, u.act, u.spend, u.excl, i.user_id IS NOT NULL AS elig,
         ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY u.start_d, u.album_id) AS n
  FROM ua u LEFT JOIN inst i ON i.user_id = u.user_id
)
SELECT a.album_id, a.a_start, a.a_end, DATE_DIFF(a.a_end, a.a_start, DAY) AS span_days,
  a.n_open_dates, a.n_close_dates, a.first_row_date,
  COUNT(*) AS participants_all, COUNTIF(s.elig) AS participants_eligible, COUNTIF(NOT s.elig) AS excluded_installed_before_window,
  COUNTIF(s.spend > 0) AS pu_all, COUNTIF(s.elig AND s.spend > 0) AS pu_eligible,
  COUNTIF(s.elig AND s.n = 1) AS cohort_1, COUNTIF(s.elig AND s.n BETWEEN 2 AND 3) AS cohort_2_3,
  COUNTIF(s.elig AND s.n BETWEEN 4 AND 6) AS cohort_4_6, COUNTIF(s.elig AND s.n >= 7) AS cohort_7plus
FROM alb a JOIN seq s ON s.album_id = a.album_id AND s.act AND NOT s.excl
GROUP BY 1, 2, 3, 4, 5, 6, 7 ORDER BY 1;
-- NOTE: for Disney the run also joined bi_prod.user_profile (exclude_reason IS NULL) to the participant universe, and for Domino
-- excluded suspected cheaters (user_daily_metrics) from the participant universe; the eligible-player logic above is identical.


-- ================= ARPDAU RATIO / POOLED TABLE =================
-- Dice (dice-dreams-dbt) :: ARPDAU last 4 full album days vs whole album, pooled by album-experience cohort (eligible players: installed >= 2025-04-01)
-- Per-album rows: use the `cells` CTE (ratio = (end_rev/end_days)/(rev/act_days)). Cells with < 5,000 players are dropped from pooled/median results.
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' GROUP BY 1
  HAVING MAX(album_end_date) BETWEEN DATE '2025-10-01' AND DATE '2026-10-07'
),
inst AS (
  SELECT user_id FROM `dice-dreams-dbt.50_reporting.user_profile`
  WHERE install_date BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
),
ua AS (
  SELECT x.user_id, x.album_id, MIN(x.user_album_start_date) AS start_d,
         LOGICAL_OR(IFNULL(x.is_excluded, FALSE)) AS excl,
         SUM(IF(x.date_dim < x.album_end_date, IFNULL(x.spent_in_album_today, 0), 0)) AS spend
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x
  JOIN inst i ON i.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
  GROUP BY 1, 2
),
coh AS (
  SELECT u.user_id, u.album_id, u.start_d, u.spend > 0 AS pu,
         CASE WHEN u.n >= 7 THEN '7+' ELSE CAST(u.n AS STRING) END AS cohort
  FROM (SELECT user_id, album_id, start_d, excl, spend,
               ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY start_d, album_id) AS n FROM ua) u
  JOIN alb a ON a.album_id = u.album_id
  WHERE NOT u.excl
),
d AS (
  SELECT c.album_id, c.cohort, c.pu, x.user_id, DATE_DIFF(a.a_end, a.a_start, DAY) AS span,
         x.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 4 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY) AS endw,
         IFNULL(x.spent_in_album_today, 0) AS rev
  FROM coh c JOIN alb a ON a.album_id = c.album_id
  JOIN `dice-dreams-dbt.50_reporting.user_daily_album` x
    ON x.user_id = c.user_id AND x.album_id = c.album_id
   AND x.date_dim BETWEEN c.start_d AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' AND x.is_active
),
cells AS (
  SELECT album_id, cohort, ANY_VALUE(span) AS span,
    COUNT(DISTINCT user_id) AS players, COUNT(DISTINCT IF(pu, user_id, NULL)) AS pu_players,
    COUNT(*) AS act_days, SUM(rev) AS rev, COUNTIF(endw) AS end_days, SUM(IF(endw, rev, 0)) AS end_rev,
    COUNTIF(pu) AS pu_days, SUM(IF(pu, rev, 0)) AS pu_rev,
    COUNTIF(pu AND endw) AS pu_end_days, SUM(IF(pu AND endw, rev, 0)) AS pu_end_rev
  FROM d GROUP BY 1, 2
)
SELECT 'Dice' AS game, cohort, COUNT(*) AS albums, SUM(players) AS player_albums, SUM(pu_players) AS pu_player_albums,
  ROUND(SUM(end_rev) / SUM(end_days), 2) AS end_arpdau, ROUND(SUM(rev) / SUM(act_days), 2) AS whole_arpdau,
  ROUND(SAFE_DIVIDE(SUM(end_rev) / SUM(end_days), SUM(rev) / SUM(act_days)), 3) AS ratio,
  ROUND(SUM(pu_end_rev) / SUM(pu_end_days), 2) AS pu_end_arpdau, ROUND(SUM(pu_rev) / SUM(pu_days), 2) AS pu_whole_arpdau,
  ROUND(SAFE_DIVIDE(SUM(pu_end_rev) / SUM(pu_end_days), SUM(pu_rev) / SUM(pu_days)), 3) AS pu_ratio,
  ROUND(AVG(act_days / span)) AS avg_daily_players_whole, ROUND(AVG(end_days / 4)) AS avg_daily_players_end
FROM cells WHERE players >= 5000 GROUP BY cohort ORDER BY cohort;

-- Domino (domino-dreams-dbt) :: ARPDAU last 4 full album days vs whole album, pooled by album-experience cohort (eligible players: installed >= 2025-04-01)
-- Per-album rows: use the `cells` CTE (ratio = (end_rev/end_days)/(rev/act_days)). Cells with < 5,000 players are dropped from pooled/median results.
WITH alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' GROUP BY 1
  HAVING MAX(album_close_date) BETWEEN DATE '2025-10-01' AND DATE '2026-10-07'
),
inst AS (
  SELECT user_id
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
  GROUP BY 1
  HAVING LOGICAL_OR(first_seen_date >= DATE '2025-04-01') AND NOT LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))
),
ua AS (
  SELECT x.user_id, x.album_id, MIN(x.user_album_start_date) AS start_d,
         LOGICAL_OR(IFNULL(x.special_user_flag, FALSE)) AS excl,
         SUM(IF(x.date_dim < x.album_close_date, IFNULL(x.album_spent_today, 0), 0)) AS spend
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x
  JOIN inst i ON i.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
  GROUP BY 1, 2
),
coh AS (
  SELECT u.user_id, u.album_id, u.start_d, u.spend > 0 AS pu,
         CASE WHEN u.n >= 7 THEN '7+' ELSE CAST(u.n AS STRING) END AS cohort
  FROM (SELECT user_id, album_id, start_d, excl, spend,
               ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY start_d, album_id) AS n FROM ua) u
  JOIN alb a ON a.album_id = u.album_id
  WHERE NOT u.excl
),
d AS (
  SELECT c.album_id, c.cohort, c.pu, x.user_id, DATE_DIFF(a.a_end, a.a_start, DAY) AS span,
         x.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 4 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY) AS endw,
         IFNULL(x.album_spent_today, 0) AS rev
  FROM coh c JOIN alb a ON a.album_id = c.album_id
  JOIN `domino-dreams-dbt.prod_40_mart.user_daily_album` x
    ON x.user_id = c.user_id AND x.album_id = c.album_id
   AND x.date_dim BETWEEN c.start_d AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' AND x.active_flag AND x.special_user_flag = FALSE
),
cells AS (
  SELECT album_id, cohort, ANY_VALUE(span) AS span,
    COUNT(DISTINCT user_id) AS players, COUNT(DISTINCT IF(pu, user_id, NULL)) AS pu_players,
    COUNT(*) AS act_days, SUM(rev) AS rev, COUNTIF(endw) AS end_days, SUM(IF(endw, rev, 0)) AS end_rev,
    COUNTIF(pu) AS pu_days, SUM(IF(pu, rev, 0)) AS pu_rev,
    COUNTIF(pu AND endw) AS pu_end_days, SUM(IF(pu AND endw, rev, 0)) AS pu_end_rev
  FROM d GROUP BY 1, 2
)
SELECT 'Domino' AS game, cohort, COUNT(*) AS albums, SUM(players) AS player_albums, SUM(pu_players) AS pu_player_albums,
  ROUND(SUM(end_rev) / SUM(end_days), 2) AS end_arpdau, ROUND(SUM(rev) / SUM(act_days), 2) AS whole_arpdau,
  ROUND(SAFE_DIVIDE(SUM(end_rev) / SUM(end_days), SUM(rev) / SUM(act_days)), 3) AS ratio,
  ROUND(SUM(pu_end_rev) / SUM(pu_end_days), 2) AS pu_end_arpdau, ROUND(SUM(pu_rev) / SUM(pu_days), 2) AS pu_whole_arpdau,
  ROUND(SAFE_DIVIDE(SUM(pu_end_rev) / SUM(pu_end_days), SUM(pu_rev) / SUM(pu_days)), 3) AS pu_ratio,
  ROUND(AVG(act_days / span)) AS avg_daily_players_whole, ROUND(AVG(end_days / 4)) AS avg_daily_players_end
FROM cells WHERE players >= 5000 GROUP BY cohort ORDER BY cohort;

-- Disney (solitaire-dreams-411507) :: ARPDAU last 4 full album days vs whole album, pooled by album-experience cohort (eligible players: installed >= 2025-04-01)
-- Per-album rows: use the `cells` CTE (ratio = (end_rev/end_days)/(rev/act_days)). Cells with < 5,000 players are dropped from pooled/median results.
WITH alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' GROUP BY 1
  HAVING MAX(album_close_date) BETWEEN DATE '2025-10-01' AND DATE '2026-10-07' AND album_id >= 7
),
inst AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' AND exclude_reason IS NULL
),
ua AS (
  SELECT x.user_id, x.album_id, MIN(x.user_album_start_date) AS start_d,
         LOGICAL_OR(IFNULL(x.special_user_flag, FALSE)) AS excl,
         SUM(IF(x.date_dim < x.album_close_date, IFNULL(x.album_spent_today, 0), 0)) AS spend
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x
  JOIN inst i ON i.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
  GROUP BY 1, 2
),
coh AS (
  SELECT u.user_id, u.album_id, u.start_d, u.spend > 0 AS pu,
         CASE WHEN u.n >= 7 THEN '7+' ELSE CAST(u.n AS STRING) END AS cohort
  FROM (SELECT user_id, album_id, start_d, excl, spend,
               ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY start_d, album_id) AS n FROM ua) u
  JOIN alb a ON a.album_id = u.album_id
  WHERE NOT u.excl
),
d AS (
  SELECT c.album_id, c.cohort, c.pu, x.user_id, DATE_DIFF(a.a_end, a.a_start, DAY) AS span,
         x.date_dim BETWEEN DATE_SUB(a.a_end, INTERVAL 4 DAY) AND DATE_SUB(a.a_end, INTERVAL 1 DAY) AS endw,
         IFNULL(x.album_spent_today, 0) AS rev
  FROM coh c JOIN alb a ON a.album_id = c.album_id
  JOIN `solitaire-dreams-411507.bi_prod.user_daily_album` x
    ON x.user_id = c.user_id AND x.album_id = c.album_id
   AND x.date_dim BETWEEN c.start_d AND DATE_SUB(a.a_end, INTERVAL 1 DAY)
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' AND x.active_flag AND x.special_user_flag = FALSE
),
cells AS (
  SELECT album_id, cohort, ANY_VALUE(span) AS span,
    COUNT(DISTINCT user_id) AS players, COUNT(DISTINCT IF(pu, user_id, NULL)) AS pu_players,
    COUNT(*) AS act_days, SUM(rev) AS rev, COUNTIF(endw) AS end_days, SUM(IF(endw, rev, 0)) AS end_rev,
    COUNTIF(pu) AS pu_days, SUM(IF(pu, rev, 0)) AS pu_rev,
    COUNTIF(pu AND endw) AS pu_end_days, SUM(IF(pu AND endw, rev, 0)) AS pu_end_rev
  FROM d GROUP BY 1, 2
)
SELECT 'Disney' AS game, cohort, COUNT(*) AS albums, SUM(players) AS player_albums, SUM(pu_players) AS pu_player_albums,
  ROUND(SUM(end_rev) / SUM(end_days), 2) AS end_arpdau, ROUND(SUM(rev) / SUM(act_days), 2) AS whole_arpdau,
  ROUND(SAFE_DIVIDE(SUM(end_rev) / SUM(end_days), SUM(rev) / SUM(act_days)), 3) AS ratio,
  ROUND(SUM(pu_end_rev) / SUM(pu_end_days), 2) AS pu_end_arpdau, ROUND(SUM(pu_rev) / SUM(pu_days), 2) AS pu_whole_arpdau,
  ROUND(SAFE_DIVIDE(SUM(pu_end_rev) / SUM(pu_end_days), SUM(pu_rev) / SUM(pu_days)), 3) AS pu_ratio,
  ROUND(AVG(act_days / span)) AS avg_daily_players_whole, ROUND(AVG(end_days / 4)) AS avg_daily_players_end
FROM cells WHERE players >= 5000 GROUP BY cohort ORDER BY cohort;


-- ================= FRONT-LOADING BY ALBUM SLICE =================
-- Dice (dice-dreams-dbt) :: ARPDAU index by 5% slice of album time (eligible players), median across albums
WITH alb AS (
  SELECT album_id, MIN(album_start_date) AS a_start, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' GROUP BY 1
  HAVING MAX(album_end_date) BETWEEN DATE '2025-10-01' AND DATE '2026-10-07'
),
inst AS (
  SELECT user_id FROM `dice-dreams-dbt.50_reporting.user_profile`
  WHERE install_date BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
),
base AS (
  SELECT x.album_id, x.user_id, x.date_dim, x.is_active AS is_act, a.a_start, a.a_end,
         IFNULL(x.spent_in_album_today, 0) AS rev,
         SUM(IFNULL(x.spent_in_album_today, 0)) OVER (PARTITION BY x.user_id, x.album_id) > 0 AS pu
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x
  JOIN alb a ON a.album_id = x.album_id
  JOIN inst i ON i.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
    AND x.date_dim < a.a_end AND NOT IFNULL(x.is_excluded, FALSE)
),
d AS (
  SELECT album_id, pu, rev,
    LEAST(19, CAST(FLOOR(DATE_DIFF(date_dim, a_start, DAY) / DATE_DIFF(a_end, a_start, DAY) * 20) AS INT64)) AS b
  FROM base WHERE is_act
),
ab AS (
  SELECT album_id, b, COUNT(*) AS days_all, SUM(rev) AS rev_all,
         COUNTIF(pu) AS days_pu, SUM(IF(pu, rev, 0)) AS rev_pu
  FROM d GROUP BY 1, 2
),
ix AS (
  SELECT album_id, b,
    SAFE_DIVIDE(rev_all / days_all, SUM(rev_all) OVER (PARTITION BY album_id) / SUM(days_all) OVER (PARTITION BY album_id)) AS idx_all,
    SAFE_DIVIDE(rev_pu / days_pu, SUM(rev_pu) OVER (PARTITION BY album_id) / SUM(days_pu) OVER (PARTITION BY album_id)) AS idx_pu,
    rev_all / SUM(rev_all) OVER (PARTITION BY album_id) AS share_all
  FROM ab
)
SELECT DISTINCT 'Dice' AS game, b AS slice_5pct, COUNT(*) OVER (PARTITION BY b) AS albums,
  ROUND(PERCENTILE_CONT(idx_all, 0.5) OVER (PARTITION BY b), 3) AS median_index_all,
  ROUND(PERCENTILE_CONT(idx_pu, 0.5) OVER (PARTITION BY b), 3) AS median_index_pu,
  ROUND(PERCENTILE_CONT(share_all, 0.5) OVER (PARTITION BY b), 4) AS median_rev_share
FROM ix ORDER BY slice_5pct;

-- Domino (domino-dreams-dbt) :: ARPDAU index by 5% slice of album time (eligible players), median across albums
WITH alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' GROUP BY 1
  HAVING MAX(album_close_date) BETWEEN DATE '2025-10-01' AND DATE '2026-10-07'
),
inst AS (
  SELECT user_id
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
  GROUP BY 1
  HAVING LOGICAL_OR(first_seen_date >= DATE '2025-04-01') AND NOT LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))
),
base AS (
  SELECT x.album_id, x.user_id, x.date_dim, x.active_flag AS is_act, a.a_start, a.a_end,
         IFNULL(x.album_spent_today, 0) AS rev,
         SUM(IFNULL(x.album_spent_today, 0)) OVER (PARTITION BY x.user_id, x.album_id) > 0 AS pu
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x
  JOIN alb a ON a.album_id = x.album_id
  JOIN inst i ON i.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
    AND x.date_dim < a.a_end AND x.special_user_flag = FALSE
),
d AS (
  SELECT album_id, pu, rev,
    LEAST(19, CAST(FLOOR(DATE_DIFF(date_dim, a_start, DAY) / DATE_DIFF(a_end, a_start, DAY) * 20) AS INT64)) AS b
  FROM base WHERE is_act
),
ab AS (
  SELECT album_id, b, COUNT(*) AS days_all, SUM(rev) AS rev_all,
         COUNTIF(pu) AS days_pu, SUM(IF(pu, rev, 0)) AS rev_pu
  FROM d GROUP BY 1, 2
),
ix AS (
  SELECT album_id, b,
    SAFE_DIVIDE(rev_all / days_all, SUM(rev_all) OVER (PARTITION BY album_id) / SUM(days_all) OVER (PARTITION BY album_id)) AS idx_all,
    SAFE_DIVIDE(rev_pu / days_pu, SUM(rev_pu) OVER (PARTITION BY album_id) / SUM(days_pu) OVER (PARTITION BY album_id)) AS idx_pu,
    rev_all / SUM(rev_all) OVER (PARTITION BY album_id) AS share_all
  FROM ab
)
SELECT DISTINCT 'Domino' AS game, b AS slice_5pct, COUNT(*) OVER (PARTITION BY b) AS albums,
  ROUND(PERCENTILE_CONT(idx_all, 0.5) OVER (PARTITION BY b), 3) AS median_index_all,
  ROUND(PERCENTILE_CONT(idx_pu, 0.5) OVER (PARTITION BY b), 3) AS median_index_pu,
  ROUND(PERCENTILE_CONT(share_all, 0.5) OVER (PARTITION BY b), 4) AS median_rev_share
FROM ix ORDER BY slice_5pct;

-- Disney (solitaire-dreams-411507) :: ARPDAU index by 5% slice of album time (eligible players), median across albums
WITH alb AS (
  SELECT album_id, MIN(album_open_date) AS a_start, MAX(album_close_date) AS a_end
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' GROUP BY 1
  HAVING MAX(album_close_date) BETWEEN DATE '2025-10-01' AND DATE '2026-10-07' AND album_id >= 7
),
inst AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2025-04-01' AND DATE '2026-10-06' AND exclude_reason IS NULL
),
base AS (
  SELECT x.album_id, x.user_id, x.date_dim, x.active_flag AS is_act, a.a_start, a.a_end,
         IFNULL(x.album_spent_today, 0) AS rev,
         SUM(IFNULL(x.album_spent_today, 0)) OVER (PARTITION BY x.user_id, x.album_id) > 0 AS pu
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x
  JOIN alb a ON a.album_id = x.album_id
  JOIN inst i ON i.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2025-04-01' AND DATE '2026-10-06'
    AND x.date_dim < a.a_end AND x.special_user_flag = FALSE
),
d AS (
  SELECT album_id, pu, rev,
    LEAST(19, CAST(FLOOR(DATE_DIFF(date_dim, a_start, DAY) / DATE_DIFF(a_end, a_start, DAY) * 20) AS INT64)) AS b
  FROM base WHERE is_act
),
ab AS (
  SELECT album_id, b, COUNT(*) AS days_all, SUM(rev) AS rev_all,
         COUNTIF(pu) AS days_pu, SUM(IF(pu, rev, 0)) AS rev_pu
  FROM d GROUP BY 1, 2
),
ix AS (
  SELECT album_id, b,
    SAFE_DIVIDE(rev_all / days_all, SUM(rev_all) OVER (PARTITION BY album_id) / SUM(days_all) OVER (PARTITION BY album_id)) AS idx_all,
    SAFE_DIVIDE(rev_pu / days_pu, SUM(rev_pu) OVER (PARTITION BY album_id) / SUM(days_pu) OVER (PARTITION BY album_id)) AS idx_pu,
    rev_all / SUM(rev_all) OVER (PARTITION BY album_id) AS share_all
  FROM ab
)
SELECT DISTINCT 'Disney' AS game, b AS slice_5pct, COUNT(*) OVER (PARTITION BY b) AS albums,
  ROUND(PERCENTILE_CONT(idx_all, 0.5) OVER (PARTITION BY b), 3) AS median_index_all,
  ROUND(PERCENTILE_CONT(idx_pu, 0.5) OVER (PARTITION BY b), 3) AS median_index_pu,
  ROUND(PERCENTILE_CONT(share_all, 0.5) OVER (PARTITION BY b), 4) AS median_rev_share
FROM ix ORDER BY slice_5pct;


