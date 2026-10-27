-- Eden 2026-10-25: Dice 65 vs 63 — (1) were there enough paying users (PU) in the last days? (2) was the Trail as a sticker source at the same level?
-- Results: claude/dice65-pu-trail-2026-10-25.md

-- ===== Q1. PU per day, days 14..1 before close (dice-dreams-dbt) =====
-- Population: standard-population payers (topic-5 rules). PU = spent > 0 that day; PU rate = PU / population; ARPPU = spend / PU.
WITH hist AS (
  SELECT user_id, MIN(album_id) AS first_album_seen FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2023-11-01' AND DATE '2026-10-19' GROUP BY 1),
ud AS (
  SELECT album_id, user_id, date_dim, album_end_date AS a_end, IFNULL(album_login_ratio,-1) AS lr, IFNULL(is_excluded,FALSE) AS excl,
    IFNULL(spent_in_album_today,0) AS spend, IFNULL(is_active,FALSE) AS act
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-19' AND album_id IN (63,65) AND date_dim <= album_end_date),
pop AS (
  SELECT a.album_id, a.user_id FROM ud a JOIN hist h ON h.user_id = a.user_id GROUP BY 1,2
  HAVING MAX(IF(a.date_dim < a.a_end, a.date_dim, NULL)) = DATE_SUB(ANY_VALUE(a.a_end), INTERVAL 1 DAY)
    AND ARRAY_AGG(IF(a.date_dim < a.a_end, a.lr, NULL) IGNORE NULLS ORDER BY a.date_dim DESC LIMIT 1)[SAFE_OFFSET(0)] >= 0.5
    AND MAX(h.first_album_seen) < a.album_id AND NOT LOGICAL_OR(a.excl) AND SUM(a.spend) > 0),
n AS (SELECT album_id, COUNT(*) AS n FROM pop GROUP BY 1),
dl AS (
  SELECT d.album_id, DATE_DIFF(d.date_dim, d.a_end, DAY) AS dtc, FORMAT_DATE('%a', d.date_dim) AS dow,
    COUNTIF(d.spend > 0) AS pu, COUNTIF(d.act) AS dau, SUM(d.spend) AS rev
  FROM ud d JOIN pop USING (album_id, user_id)
  WHERE d.date_dim < d.a_end AND DATE_DIFF(d.date_dim, d.a_end, DAY) >= -14 GROUP BY 1, 2, 3)
SELECT dl.album_id, dtc, dow, n.n AS payers, pu, ROUND(pu / n.n, 3) AS pu_rate, ROUND(dau / n.n, 3) AS active_rate,
  ROUND(rev / pu, 2) AS arppu, ROUND(rev) AS rev
FROM dl JOIN n USING (album_id) ORDER BY 1, 2;

-- ===== Q2. Trail as a sticker source, days 14..1 before close, all players (dice-dreams-dbt) =====
-- Every sticker row with sticker_source LIKE 'Trail%' (first copies and duplicates, Wild-filled included); players = distinct users that day.
WITH alb AS (
  SELECT album_id, MAX(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-10-19' AND album_id IN (63,65) GROUP BY 1),
s AS (
  SELECT s.album_id, DATE_DIFF(s.sticker_collected_date, a.a_end, DAY) AS dtc, s.user_id, s.sticker_source AS src,
    IFNULL(s.collected_from_wild, FALSE) AS wild
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-08-20' AND DATE '2026-10-19' AND s.album_id IN (63,65)
    AND s.is_sticker_collected AND s.sticker_source LIKE 'Trail%'
    AND s.sticker_collected_date < a.a_end AND s.sticker_collected_date >= DATE_SUB(a.a_end, INTERVAL 14 DAY))
SELECT album_id, src, STRING_AGG(FORMAT('%d:%d/%d', dtc, players, stickers), ' ' ORDER BY dtc) AS players_stickers_by_day,
  SUM(stickers) AS stickers_14d, SUM(wild_st) AS wild_filled_14d
FROM (SELECT album_id, src, dtc, COUNT(DISTINCT user_id) AS players, COUNT(*) AS stickers, COUNTIF(wild) AS wild_st FROM s GROUP BY 1,2,3)
GROUP BY 1, 2 ORDER BY 2, 1;

-- ===== Q3 (Eden 2026-10-25: "not the same number of players — show a normalised measure"): Trail chest per active player =====
-- Denominator = active players in the album that day (user_daily_album is_active, not excluded). Numerator = players getting >=1 Trail chest sticker that day.
WITH alb AS (
  SELECT album_id, MAX(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-10-19' AND album_id IN (63,65) GROUP BY 1),
act AS (
  SELECT x.album_id, DATE_DIFF(x.date_dim, a.a_end, DAY) AS dtc, COUNT(DISTINCT x.user_id) AS active
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` x JOIN alb a USING (album_id)
  WHERE x.date_dim BETWEEN DATE '2026-08-20' AND DATE '2026-10-19' AND x.album_id IN (63,65)
    AND x.is_active AND NOT IFNULL(x.is_excluded, FALSE) AND x.date_dim < a.a_end AND x.date_dim >= DATE_SUB(a.a_end, INTERVAL 10 DAY)
  GROUP BY 1, 2),
tr AS (
  SELECT s.album_id, DATE_DIFF(s.sticker_collected_date, a.a_end, DAY) AS dtc, COUNT(DISTINCT s.user_id) AS trail_players, COUNT(*) AS trail_stickers
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-08-20' AND DATE '2026-10-19' AND s.album_id IN (63,65)
    AND s.is_sticker_collected AND s.sticker_source = 'Trail – Chest'
    AND s.sticker_collected_date < a.a_end AND s.sticker_collected_date >= DATE_SUB(a.a_end, INTERVAL 10 DAY)
  GROUP BY 1, 2)
SELECT album_id, STRING_AGG(FORMAT('%d:%.1f%%', dtc, 100 * trail_players / active), ' ' ORDER BY dtc) AS pct_active_getting_trail,
  STRING_AGG(FORMAT('%d:%.2f', dtc, trail_stickers / active), ' ' ORDER BY dtc) AS trail_stickers_per_active, STRING_AGG(FORMAT('%d:%d', dtc, active), ' ' ORDER BY dtc) AS active
FROM act JOIN tr USING (album_id, dtc) GROUP BY 1 ORDER BY 1;

-- ===== Q4 (Eden 2026-10-25: "which stickers did they get from the Trail? are you talking about Wilds?") =====
-- Every Trail sticker row in days 10..1 before close, by source (chest / final reward), sticker type, Wild-filled or not,
-- and NEW (the player's first copy of that sticker in the album) vs duplicate. Final weekend = days 3..1.
WITH alb AS (
  SELECT album_id, MAX(album_end_date) AS a_end FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-07-20' AND DATE '2026-10-19' AND album_id IN (63,65) GROUP BY 1),
tr AS (
  SELECT s.album_id, s.user_id, s.sticker_id, s.sticker_type AS typ, s.sticker_source AS src, IFNULL(s.collected_from_wild, FALSE) AS wild,
    s.sticker_collected_ts AS ts, DATE_DIFF(s.sticker_collected_date, a.a_end, DAY) AS dtc
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-08-20' AND DATE '2026-10-19' AND s.album_id IN (63,65)
    AND s.is_sticker_collected AND s.sticker_source LIKE 'Trail%'
    AND s.sticker_collected_date < a.a_end AND s.sticker_collected_date >= DATE_SUB(a.a_end, INTERVAL 10 DAY)),
first_copy AS (
  SELECT s.album_id, s.user_id, s.sticker_id, MIN(s.sticker_collected_ts) AS ts1
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s
  JOIN (SELECT DISTINCT album_id, user_id, sticker_id FROM tr) t USING (album_id, user_id, sticker_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-01' AND DATE '2026-10-19' AND s.album_id IN (63,65) AND s.is_sticker_collected
  GROUP BY 1,2,3)
SELECT t.album_id, IF(t.dtc >= -3, 'final weekend', 'days 10-4') AS win, t.src, t.typ, t.wild, t.ts = f.ts1 AS is_new, COUNT(*) AS stickers, COUNT(DISTINCT t.user_id) AS players
FROM tr t JOIN first_copy f USING (album_id, user_id, sticker_id)
GROUP BY 1,2,3,4,5,6 HAVING stickers >= 500 ORDER BY 1,2,3,4,5,6;

-- ===== Q5 (Eden 2026-10-25): PU / PAU = share of ACTIVE payers who paid that day; days 11-5 vs final weekend (days 3-1). 83 GB =====
-- Same hist / ud / pop CTEs as Q1; then:
-- dl AS (SELECT album_id, DATE_DIFF(date_dim, a_end, DAY) AS dtc, COUNTIF(spend > 0) AS pu, COUNTIF(act) AS pau
--        FROM ud JOIN pop USING (album_id, user_id) WHERE date_dim < a_end AND DATE_DIFF(date_dim, a_end, DAY) >= -11 GROUP BY 1, 2)
-- SELECT album_id, SUM(pu in -11..-5)/SUM(pau in -11..-5) AS pu_pau_d11_5, SUM(pu in -3..-1)/SUM(pau in -3..-1) AS pu_pau_weekend,
--        STRING_AGG(dtc:pu/pau) AS by_day FROM dl GROUP BY 1
