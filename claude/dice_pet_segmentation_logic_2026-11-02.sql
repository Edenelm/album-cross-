-- Dice Pet segmentation logic for the NEXT season (shared by Eden 2026-11-02; source: Dice team). Not run by Claude.
-- Season used: HalloweenCat 2026-10-12..11-01. Order players by normalised cookies, cut into 6 tiers of equal pet revenue (1/6 each).
-- Notes: no is_excluded filter; normalisation (28/days since first pet day)^0.3; comment says seg 7 (new) users bring 0 revenue, but in Skunk seg 7 brought ~11% of game revenue.
WITH
first_pet AS (
  SELECT user_id, MIN(date_dim) AS first_pet_date
  FROM `dice-dreams-dbt.50_reporting.user_daily_pet`
  WHERE pet_season_id = 'HalloweenCat' AND date_dim BETWEEN '2026-10-12' AND '2026-11-01'
  GROUP BY user_id
),
bull AS (
  SELECT user_id, MAX(pet_segment_key) AS pet_segment_key,
    SUM(cookies_received_amount) AS bull_cookies, COALESCE(SUM(purchase_amount), 0) AS bull_revenue
  FROM `dice-dreams-dbt.50_reporting.user_daily_pet`
  WHERE pet_season_id = 'HalloweenCat' AND date_dim BETWEEN '2026-10-12' AND '2026-11-01'
  GROUP BY user_id
),
bull_norm AS (
  SELECT b.user_id, b.pet_segment_key, b.bull_cookies, b.bull_revenue,
    b.bull_cookies * POW(SAFE_DIVIDE(28.0, GREATEST(DATE_DIFF(DATE '2026-11-02', fp.first_pet_date, DAY) + 1, 1)), 0.30) AS norm_cookies
  FROM bull b LEFT JOIN first_pet fp USING (user_id)
),
cum AS (
  SELECT user_id, pet_segment_key, bull_cookies, norm_cookies, bull_revenue,
    SUM(bull_revenue) OVER (ORDER BY norm_cookies DESC, user_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_rev,
    SUM(bull_revenue) OVER () AS total_rev
  FROM bull_norm
)
SELECT user_id, pet_segment_key, bull_cookies, norm_cookies, bull_revenue,
  CASE WHEN cum_rev <= 1*total_rev/6 THEN 6 WHEN cum_rev <= 2*total_rev/6 THEN 5 WHEN cum_rev <= 3*total_rev/6 THEN 4
       WHEN cum_rev <= 4*total_rev/6 THEN 3 WHEN cum_rev <= 5*total_rev/6 THEN 2 ELSE 1 END AS poodle_seg
FROM cum;
