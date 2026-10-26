-- 2026-10-25 Domino diagnosis, topics 2/4: where did the gate (joker-only) stickers come from, by day before close?
-- Gate stickers: album 19 = R107, R108, G101, G130; album 20 = R119, R120, G139 (domino_dx_gate_structure_2026-10-25.sql).
-- Source = new_sticker_mtx_campaign_name (first collection), grouped: puzzle / paid offer or store / momentum / other campaign / empty.
-- Paid rule as in endgame-s1-s4 (t_Offer except SeasonPass/DreamPass/Info/ecn_Rewa, t_Store, ActivePassToGetJoker, source purchase or 1+).
-- All collectors (not only payers): this is a mechanism check.
WITH g AS (
  SELECT s.album_id, s.sticker_id, s.sticker_collected_min_date AS dt,
    IF(s.album_id = 19, DATE '2026-08-24', DATE '2026-10-12') AS a_end,
    LOWER(IFNULL(s.new_sticker_mtx_campaign_name, '')) AS camp, LOWER(IFNULL(s.new_sticker_source, '')) AS src
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-06' AND DATE '2026-10-12'
    AND ((s.album_id = 19 AND s.sticker_id IN (107,108,101,130)) OR (s.album_id = 20 AND s.sticker_id IN (119,120,139)))
    AND s.user_collected_sticker_flag
)
SELECT album_id, DATE_DIFF(a_end, dt, DAY) AS days_before_close,
  CASE
    WHEN camp LIKE '%puzzle%' THEN 'puzzle'
    WHEN (camp LIKE '%t_offer%' AND NOT REGEXP_CONTAINS(camp, r'seasonpass|dreampass|info|ecn_rewa')) OR camp LIKE '%t_store%'
      OR camp LIKE '%activepasstogetjoker%' OR src = 'purchase' OR src LIKE '1+%' THEN 'paid'
    WHEN camp LIKE '%momentum%' THEN 'momentum'
    WHEN camp = '' THEN CONCAT('empty:', src)
    ELSE 'other_campaign' END AS route,
  COUNT(*) AS stickers, ANY_VALUE(camp) AS example_camp
FROM g
WHERE DATE_DIFF(a_end, dt, DAY) BETWEEN 0 AND 14
GROUP BY 1,2,3 ORDER BY 1,2 DESC,4 DESC
