-- Eden 2026-10-24: v144a used standard-population payers' album spend ($873K/day). Re-run on total game revenue
-- (deck-wide definition: daily metrics gross revenue, all players, excluded users out), same windows of Disney album 15.
-- Album day = date - album open (2026-08-24) + 1. Windows: quiet 1 = days 10-13 (Sep 2-5), release 1 = 16-19 (Sep 8-11),
-- middle = 20-25, quiet 2 = 27-31, release 2 = 32-35. Calendar control: Dice and Domino revenue on the same dates (no Disney release there).
-- ===== DISNEY =====
WITH m AS (
  SELECT user_id, date_dim, IFNULL(gross_revenues,0) AS rev, exclude_reason IS NOT NULL AS bad
  FROM `solitaire-dreams-411507.bi_prod.solitaire_user_daily_metrics_agg_df`
  WHERE date_dim BETWEEN DATE '2026-08-24' AND DATE '2026-10-04'),
bad_users AS (SELECT DISTINCT user_id FROM m WHERE bad)
SELECT DATE_DIFF(date_dim, DATE '2026-08-24', DAY) + 1 AS album_day, date_dim, ROUND(SUM(rev)) AS rev
FROM m WHERE user_id NOT IN (SELECT user_id FROM bad_users) GROUP BY 1, 2 ORDER BY 1

-- ===== DOMINO calendar control (domino-dreams-dbt) =====
-- WITH m AS (SELECT user_id, date_dim, IFNULL(user_daily_inapp_purchase_amount,0) + IFNULL(user_daily_stripe_amount,0) AS rev,
--   IFNULL(special_user_flag,FALSE) OR IFNULL(suspected_cheater_flag,FALSE) AS bad
--   FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-08-31' AND DATE '2026-09-13'),
-- bad_users AS (SELECT DISTINCT user_id FROM m WHERE bad)
-- SELECT date_dim, ROUND(SUM(rev)) AS rev FROM m WHERE user_id NOT IN (SELECT user_id FROM bad_users) GROUP BY 1 ORDER BY 1
