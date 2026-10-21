-- Open check (deck slide open-checks / closing-week): Dice Trail campaigns around the album 61 / 63 closes (2026-07-27 / 2026-09-07)
-- and who reaches the top tier (the final reward that gives the free Wild in the last 3 days). Results: claude/open-checks-2026-10-21.md
-- Source: dice-dreams-dbt.50_reporting.fact_user_campaign_trail (per user-campaign-event; partition campaign_start_ts). No dedicated event-calendar
-- table exists in 50_reporting or external_sources (listed 2026-10-21); campaign dates come from this fact table.
-- "Reached top" = tier_completed equals the campaign's highest observed tier (my reading of 'final reward'; the config tier count was not checked).
-- event_rank = 1 keeps one row per user-campaign (first event; challenge trails collapse events 1-3 into rank 1). 3.7 GB.
WITH t AS (
  SELECT campaign_id, campaign_name, trail_type, campaign_start_ts, campaign_end_ts, campaign_length, user_id, event_rank, tier_completed, purchase_amount, excluded_reason
  FROM `dice-dreams-dbt.50_reporting.fact_user_campaign_trail`
  WHERE campaign_start_ts BETWEEN TIMESTAMP '2026-07-01' AND TIMESTAMP '2026-09-08'
),
c AS (SELECT campaign_id, MAX(tier_completed) AS top_tier FROM t GROUP BY 1)
SELECT t.campaign_id, ANY_VALUE(t.campaign_name) AS campaign_name, ANY_VALUE(t.trail_type) AS trail_type,
  DATE(MIN(t.campaign_start_ts)) AS start_d, DATE(MAX(t.campaign_end_ts)) AS end_d, ANY_VALUE(t.campaign_length) AS len_days,
  ANY_VALUE(c.top_tier) AS top_tier,
  COUNT(DISTINCT t.user_id) AS players,
  COUNT(DISTINCT IF(t.tier_completed >= c.top_tier, t.user_id, NULL)) AS reached_top,
  ROUND(COUNT(DISTINCT IF(t.tier_completed >= c.top_tier, t.user_id, NULL)) / COUNT(DISTINCT t.user_id), 4) AS sh_reached_top,
  COUNT(DISTINCT IF(t.purchase_amount > 0, t.user_id, NULL)) AS payers_in_trail,
  COUNT(DISTINCT IF(t.tier_completed >= c.top_tier AND t.purchase_amount > 0, t.user_id, NULL)) AS reached_top_payers
FROM t JOIN c USING (campaign_id)
WHERE t.excluded_reason IS NULL AND t.event_rank = 1
GROUP BY 1 ORDER BY start_d
;
