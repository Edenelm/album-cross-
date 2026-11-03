-- Dice linkage audit (Eden 2026-11-02): does the sticker's source also appear as a purchase source, so we can tell a sticker that came
-- from a purchase from one that came from gameplay?
-- Album 63 (07-27..09-07), all players, not excluded, new set stickers (common / golden / super, first copy). Project dice-dreams-dbt.
-- Tables: 30_intermediate.fact_user_album_stickers (sticker_source, sticker_pack_key, sticker_mtx_campaign_id, collected_from_wild),
--         20_core.purchase_completed_vw (source, subsource, campaign_id, purchase_amount, timestamp; partition pdate).
-- Method: per player, stickers and purchases in one time line; for each sticker take the NEAREST purchase before it
--   (gap, its source, its campaign_id). Linked ≤10 min = that purchase was ≤10 minutes before the sticker.
--   Source match = purchase.source = sticker_source; campaign match = purchase.campaign_id = sticker_mtx_campaign_id.
--   Placebo = the same sticker moved 24 h earlier: share with a purchase ≤10 min before that moment (base rate for a random moment).
-- Pack class: paid = sticker_pack_key LIKE 'Pricing%' except Pricing_CP / Pricing_DDJ (not purchases, golden-purchase-revenue-2026-10-22);
--   cp_ddj = Pricing_CP / Pricing_DDJ; other = everything else.
-- Results: claude/dice-sticker-source-vs-purchase-2026-11-02.md

-- ===== Q1: by sticker source =====
WITH st AS (
  SELECT user_id, sticker_collected_ts AS ts, IFNULL(NULLIF(sticker_source, ''), '(none)') AS src, sticker_mtx_campaign_id AS camp,
    IFNULL(collected_from_wild, FALSE) AS wild, sticker_type,
    CASE WHEN sticker_pack_key LIKE 'Pricing_CP%' OR sticker_pack_key LIKE 'Pricing_DDJ%' THEN 'cp_ddj'
         WHEN sticker_pack_key LIKE 'Pricing%' THEN 'paid' ELSE 'other' END AS pack_class
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers`
  WHERE sticker_collected_date BETWEEN DATE '2026-07-27' AND DATE '2026-09-07' AND album_id = 63
    AND is_sticker_collected AND sticker_type IN ('common','golden','super') AND NOT IFNULL(is_excluded, FALSE)),
pu AS (
  SELECT user_id, timestamp AS ts, IFNULL(NULLIF(source, ''), '(none)') AS psrc, IFNULL(campaign_id, -1) AS pcamp
  FROM `dice-dreams-dbt.20_core.purchase_completed_vw`
  WHERE pdate BETWEEN DATE '2026-07-25' AND DATE '2026-09-07' AND purchase_amount > 0),
psrc_set AS (SELECT DISTINCT psrc FROM pu),
ev AS (
  SELECT user_id, ts, 'S' AS kind, src, camp, wild, sticker_type, pack_class, CAST(NULL AS STRING) AS psrc, CAST(NULL AS INT64) AS pcamp FROM st
  UNION ALL
  SELECT user_id, TIMESTAMP_SUB(ts, INTERVAL 24 HOUR), 'X', src, camp, wild, sticker_type, pack_class, NULL, NULL FROM st
  UNION ALL
  SELECT user_id, ts, 'P', NULL, NULL, NULL, NULL, NULL, psrc, pcamp FROM pu),
w AS (
  SELECT kind, src, camp, wild, sticker_type, pack_class, ts,
    LAST_VALUE(IF(kind = 'P', ts, NULL) IGNORE NULLS) OVER u AS p_ts,
    LAST_VALUE(psrc IGNORE NULLS) OVER u AS p_src,
    LAST_VALUE(pcamp IGNORE NULLS) OVER u AS p_camp
  FROM ev
  WINDOW u AS (PARTITION BY user_id ORDER BY ts, kind ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)),
s AS (
  SELECT kind, src, camp, wild, sticker_type, pack_class, p_src, p_camp,
    p_ts IS NOT NULL AND TIMESTAMP_DIFF(ts, p_ts, SECOND) BETWEEN 0 AND 600 AS p10
  FROM w WHERE kind IN ('S', 'X'))
SELECT s.src, s.pack_class, COUNTIF(s.kind = 'S') AS new_stickers,
  ROUND(AVG(IF(s.wild, 1, 0)), 3) AS wild_share, ROUND(AVG(IF(s.sticker_type = 'super', 1, 0)), 3) AS super_share,
  ROUND(SAFE_DIVIDE(COUNTIF(s.kind = 'S' AND s.p10), COUNTIF(s.kind = 'S')), 3) AS purchase_le10,
  ROUND(SAFE_DIVIDE(COUNTIF(s.kind = 'X' AND s.p10), COUNTIF(s.kind = 'X')), 3) AS placebo_le10,
  ROUND(SAFE_DIVIDE(COUNTIF(s.kind = 'S' AND s.p10 AND s.p_src = s.src), COUNTIF(s.kind = 'S')), 3) AS source_match_le10,
  ROUND(SAFE_DIVIDE(COUNTIF(s.kind = 'S' AND s.p10 AND s.p_camp = s.camp), COUNTIF(s.kind = 'S')), 3) AS campaign_match_le10,
  LOGICAL_OR(ps.psrc IS NOT NULL) AS src_exists_in_purchases,
  APPROX_TOP_COUNT(IF(s.kind = 'S' AND s.p10, s.p_src, NULL), 3) AS top_purchase_src_le10
FROM s LEFT JOIN psrc_set ps ON ps.psrc = s.src
WHERE s.kind = 'S' OR s.kind = 'X'
GROUP BY 1, 2
HAVING COUNTIF(s.kind = 'S') >= 3000
ORDER BY new_stickers DESC;
