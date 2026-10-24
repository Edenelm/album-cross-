-- Eden 2026-10-25: the "Avg Arpdau Whole Album" and "Avg Arpdau Last 4 Days" slides — recompute with the player mix of the first album shown
-- (Dice 53, Domino 15, Disney 10), same method in all three games. Results: claude/mix-fixed-arpdau-2026-10-25.md
-- Population as the slides: all players who received the album, active days from the player's album start, close day excluded, game exclusions.
-- Groups = albums seen (1 / 2-3 / 4-6 / 7+) = distinct albums with rows up to and including this one (full table history).
-- Last 4 days = 4..1 days before close. Mix-fixed (done in the doc) = sum over groups of base-album share of active days x this album's group ARPDAU.

-- ===== DICE 53-63 (dice-dreams-dbt) =====
WITH ua AS (
  SELECT user_id, album_id FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-09-07' AND album_id <= 63 GROUP BY 1, 2),
nseen AS (SELECT user_id, album_id, COUNT(*) OVER (PARTITION BY user_id ORDER BY album_id) AS n FROM ua),
d AS (
  SELECT x.album_id, IFNULL(x.spent_in_album_today, 0) AS rev, x.date_dim >= DATE_SUB(x.album_end_date, INTERVAL 4 DAY) AS l4,
    CASE WHEN p.n = 1 THEN 'a_1' WHEN p.n <= 3 THEN 'b_2-3' WHEN p.n <= 6 THEN 'c_4-6' ELSE 'd_7+' END AS grp
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x
  JOIN nseen p ON p.user_id = x.user_id AND p.album_id = x.album_id
  WHERE x.date_dim BETWEEN DATE '2025-11-01' AND DATE '2026-09-07' AND x.album_id IN (53,55,57,59,61,63)
    AND x.date_dim < x.album_end_date AND x.date_dim >= x.user_album_start_date
    AND x.is_active AND NOT IFNULL(x.is_excluded, FALSE))
SELECT album_id, grp, COUNT(*) AS days, ROUND(SUM(rev)) AS rev, COUNTIF(l4) AS days_l4, ROUND(SUM(IF(l4, rev, 0))) AS rev_l4
FROM d GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DOMINO 15-20 (domino-dreams-dbt) =====
WITH cheat AS (
  SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics`
  WHERE date_dim BETWEEN DATE '2025-12-01' AND DATE '2026-10-12' GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
ua AS (
  SELECT user_id, album_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_album`
  WHERE date_dim BETWEEN DATE '2024-06-01' AND DATE '2026-10-12' AND album_id <= 20 GROUP BY 1, 2),
nseen AS (SELECT user_id, album_id, COUNT(*) OVER (PARTITION BY user_id ORDER BY album_id) AS n FROM ua),
d AS (
  SELECT x.album_id, IFNULL(x.album_spent_today, 0) AS rev, x.date_dim >= DATE_SUB(x.album_close_date, INTERVAL 4 DAY) AS l4,
    CASE WHEN p.n = 1 THEN 'a_1' WHEN p.n <= 3 THEN 'b_2-3' WHEN p.n <= 6 THEN 'c_4-6' ELSE 'd_7+' END AS grp
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` x
  JOIN nseen p ON p.user_id = x.user_id AND p.album_id = x.album_id
  LEFT JOIN cheat c ON c.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2025-12-01' AND DATE '2026-10-12' AND x.album_id BETWEEN 15 AND 20
    AND x.date_dim < x.album_close_date AND x.date_dim >= x.user_album_start_date
    AND x.active_flag AND x.special_user_flag = FALSE AND c.user_id IS NULL)
SELECT album_id, grp, COUNT(*) AS days, ROUND(SUM(rev)) AS rev, COUNTIF(l4) AS days_l4, ROUND(SUM(IF(l4, rev, 0))) AS rev_l4
FROM d GROUP BY 1, 2 ORDER BY 1, 2;

-- ===== DISNEY 10-15 (solitaire-dreams-411507) =====
WITH excl AS (
  SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile`
  WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
ua AS (
  SELECT user_id, album_id FROM `solitaire-dreams-411507.bi_prod.user_daily_album`
  WHERE date_dim BETWEEN DATE '2024-01-01' AND DATE '2026-10-05' AND album_id <= 15 GROUP BY 1, 2),
nseen AS (SELECT user_id, album_id, COUNT(*) OVER (PARTITION BY user_id ORDER BY album_id) AS n FROM ua),
d AS (
  SELECT x.album_id, IFNULL(x.album_spent_today, 0) AS rev, x.date_dim >= DATE_SUB(x.album_close_date, INTERVAL 4 DAY) AS l4,
    CASE WHEN p.n = 1 THEN 'a_1' WHEN p.n <= 3 THEN 'b_2-3' WHEN p.n <= 6 THEN 'c_4-6' ELSE 'd_7+' END AS grp
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` x
  JOIN nseen p ON p.user_id = x.user_id AND p.album_id = x.album_id
  LEFT JOIN excl e ON e.user_id = x.user_id
  WHERE x.date_dim BETWEEN DATE '2025-06-01' AND DATE '2026-10-05' AND x.album_id BETWEEN 10 AND 15
    AND x.date_dim < x.album_close_date AND x.date_dim >= x.user_album_start_date
    AND x.active_flag AND x.special_user_flag = FALSE AND e.user_id IS NULL)
SELECT album_id, grp, COUNT(*) AS days, ROUND(SUM(rev)) AS rev, COUNTIF(l4) AS days_l4, ROUND(SUM(IF(l4, rev, 0))) AS rev_l4
FROM d GROUP BY 1, 2 ORDER BY 1, 2;
