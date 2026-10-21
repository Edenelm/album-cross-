-- 2026-10-21: Dice closing week — which source gives the Wilds each day (Eden's deck review, item 4: why gameplay Wilds appear, drop to ~0, then rise).
-- dice-dreams-dbt, 12.6 GB. Distinct players per day whose NEW sticker (first receipt) was filled by a Wild, d = date - album end, close day excluded.
-- Paid = sticker_pack_key LIKE 'Pricing%' (same rule as closing_week_split_golden_queries.sql). Results: claude/dice-wild-sources-2026-10-21.md
WITH alb AS (
  SELECT album_id, MAX(album_end_date) AS a_end
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE date_dim BETWEEN DATE '2026-06-15' AND DATE '2026-09-15' AND album_id IN (61, 63) GROUP BY 1),
st AS (
  SELECT s.album_id, s.user_id, DATE_DIFF(s.sticker_collected_date, a.a_end, DAY) AS d,
    CASE WHEN IFNULL(s.sticker_pack_key, '') LIKE 'Pricing%' THEN 'paid'
         ELSE CONCAT(IFNULL(s.sticker_source, '(null)'), ' | ', REGEXP_REPLACE(IFNULL(s.sticker_pack_key, '(null)'), r'[0-9]+', '#')) END AS k
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` s JOIN alb a USING (album_id)
  WHERE s.sticker_collected_date BETWEEN DATE '2026-06-15' AND DATE '2026-09-15' AND s.album_id IN (61, 63)
    AND s.is_sticker_collected AND IFNULL(s.collected_from_wild, FALSE) AND s.sticker_collected_date < a.a_end)
SELECT k, STRING_AGG(CONCAT(CAST(album_id AS STRING), ':', CAST(d AS STRING), '=', CAST(n AS STRING)), ' ' ORDER BY album_id, d) AS by_day
FROM (SELECT album_id, d, k, COUNT(DISTINCT user_id) AS n FROM st WHERE d BETWEEN -12 AND -1 GROUP BY 1, 2, 3 HAVING n >= 50)
GROUP BY k ORDER BY k;
