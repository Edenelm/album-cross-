-- Topic 1 / E3: rapid progress and purchase timing (eligible population, D-009). Project dice-dreams-dbt. First albums 57-65.
-- Rapid = eligible first-album player with 4+ sets completed in days 0-6 (all inside album A).
-- Reward event = timestamp of the 4th set completion in album A (fact_user_album_stickers.if_closed_set, new set stickers);
--   each set completion pays album rolls (source 'set_completed', see CONTEXT). Album rolls by day: user_daily_rolls_by_source.
-- Purchases: purchase_completed_vw, amount > 0, deduped on user + timestamp + external_order_id.
-- Purchase-delivered sticker (validated rule, claude/dice-sticker-source-vs-purchase-2026-11-02.md): a purchase with the same source
--   as sticker_source within 10 minutes before the sticker.
-- After the reward event: next purchase time, spend in the 7 x 24 h after, active game days on the 7 calendar days after the event day.
--   Follow-up: event + 7 days is before 2026-11-02 for every eligible player (first albums close by 2026-10-19).
WITH alb AS (
  SELECT album_id, album_start_date AS a_start, album_end_date AS a_end, days_in_album AS n_days
  FROM `dice-dreams-dbt.20_core.dim_album_season` WHERE album_id BETWEEN 57 AND 65),
hist AS (SELECT user_id, album_id FROM `dice-dreams-dbt.30_intermediate.album_pop` GROUP BY 1, 2),
first_alb AS (SELECT user_id, MIN(album_id) AS first_album FROM hist GROUP BY 1),
excl AS (SELECT DISTINCT user_id FROM `dice-dreams-dbt.20_core.dim_excluded_users`),
d AS (
  SELECT u.user_id, u.album_id, u.date_dim, IFNULL(u.sets_completed_today, 0) AS sets, IFNULL(u.is_excluded, FALSE) AS ex
  FROM `dice-dreams-dbt.50_reporting.user_daily_album` u JOIN alb a USING (album_id)
  WHERE u.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-19' AND u.album_id BETWEEN 57 AND 65 AND u.date_dim <= a.a_end),
p AS (SELECT user_id, album_id, MIN(date_dim) AS entry, LOGICAL_OR(ex) AS ex FROM d GROUP BY 1, 2),
bb AS (
  SELECT p.user_id, p.album_id, p.entry,
    CASE WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days <= 1/3 THEN 'EARLY'
         WHEN (DATE_DIFF(p.entry, a.a_start, DAY) + 1) / a.n_days > 2/3 THEN 'LATE' END AS grp
  FROM p JOIN alb a USING (album_id) JOIN first_alb f USING (user_id)
  WHERE f.first_album = p.album_id AND NOT p.ex AND p.user_id NOT IN (SELECT user_id FROM excl)
    AND p.entry <= DATE_SUB(a.a_end, INTERVAL 7 DAY)),
s7 AS (
  SELECT bb.user_id, bb.album_id, bb.entry, bb.grp, SUM(d.sets) AS sets7
  FROM bb JOIN d ON d.user_id = bb.user_id AND d.album_id = bb.album_id AND d.date_dim BETWEEN bb.entry AND DATE_ADD(bb.entry, INTERVAL 6 DAY)
  WHERE bb.grp IS NOT NULL GROUP BY 1, 2, 3, 4),
rp AS (SELECT * FROM s7 WHERE sets7 >= 4),
st AS (
  SELECT f.user_id, f.album_id, f.sticker_collected_ts AS ts, IFNULL(f.if_closed_set, FALSE) AS closed,
    IFNULL(NULLIF(f.sticker_source, ''), '(none)') AS src
  FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` f JOIN rp ON rp.user_id = f.user_id AND rp.album_id = f.album_id
  WHERE f.sticker_collected_date BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND f.album_id BETWEEN 57 AND 65
    AND f.sticker_collected_date BETWEEN rp.entry AND DATE_ADD(rp.entry, INTERVAL 6 DAY)
    AND f.is_sticker_collected AND f.sticker_type IN ('common', 'golden', 'super')),
rw AS (
  SELECT user_id, album_id, ARRAY_AGG(ts ORDER BY ts LIMIT 4)[SAFE_OFFSET(3)] AS reward_ts, MIN(ts) AS first_set_ts
  FROM st WHERE closed GROUP BY 1, 2),
pu AS (
  SELECT x.user_id, x.ts, x.amt, x.psrc FROM (
    SELECT c.user_id, c.timestamp AS ts, c.purchase_amount AS amt, IFNULL(NULLIF(c.source, ''), '(none)') AS psrc,
      ROW_NUMBER() OVER (PARTITION BY c.user_id, c.timestamp, c.external_order_id ORDER BY c.timestamp) AS rn
    FROM `dice-dreams-dbt.20_core.purchase_completed_vw` c
    WHERE c.pdate BETWEEN DATE '2026-03-23' AND DATE '2026-11-01' AND c.purchase_amount > 0
      AND c.user_id IN (SELECT user_id FROM rp)) x WHERE x.rn = 1),
lk AS (
  SELECT DISTINCT st.user_id, st.album_id, st.ts, st.src
  FROM st JOIN pu ON pu.user_id = st.user_id AND pu.psrc = st.src AND pu.ts BETWEEN TIMESTAMP_SUB(st.ts, INTERVAL 600 SECOND) AND st.ts),
link AS (
  SELECT st.user_id, st.album_id, COUNT(*) AS new_stickers7, COUNTIF(lk.user_id IS NOT NULL) AS bought_stickers7
  FROM st LEFT JOIN lk USING (user_id, album_id, ts, src) GROUP BY 1, 2),
pp AS (
  SELECT rp.user_id, rp.album_id, rp.grp, rp.entry, rw.reward_ts, rw.first_set_ts,
    DATE_DIFF(DATE(rw.reward_ts), rp.entry, DAY) AS reward_day,
    COUNTIF(pu.ts < rw.reward_ts AND DATE(pu.ts) >= rp.entry) AS n_before, SUM(IF(pu.ts < rw.reward_ts AND DATE(pu.ts) >= rp.entry, pu.amt, 0)) AS amt_before,
    COUNTIF(DATE(pu.ts) BETWEEN rp.entry AND DATE_ADD(rp.entry, INTERVAL 6 DAY)) AS n_d0_6,
    SUM(IF(DATE(pu.ts) BETWEEN rp.entry AND DATE_ADD(rp.entry, INTERVAL 6 DAY), pu.amt, 0)) AS amt_d0_6,
    MIN(IF(pu.ts > rw.reward_ts, pu.ts, NULL)) AS next_ts,
    SUM(IF(pu.ts > rw.reward_ts AND pu.ts <= TIMESTAMP_ADD(rw.reward_ts, INTERVAL 168 HOUR), pu.amt, 0)) AS amt_after7,
    COUNTIF(pu.ts > rw.reward_ts AND pu.ts <= TIMESTAMP_ADD(rw.reward_ts, INTERVAL 168 HOUR)) AS n_after7,
    MAX(IF(pu.ts < rw.reward_ts AND DATE(pu.ts) >= rp.entry, pu.ts, NULL)) AS last_before_ts
  FROM rp JOIN rw USING (user_id, album_id) LEFT JOIN pu ON pu.user_id = rp.user_id
    AND pu.ts BETWEEN TIMESTAMP(rp.entry) AND TIMESTAMP_ADD(TIMESTAMP(DATE_ADD(rp.entry, INTERVAL 7 DAY)), INTERVAL 168 HOUR)
  GROUP BY 1, 2, 3, 4, 5, 6),
act AS (
  SELECT pp.user_id, pp.album_id, COUNTIF(m.date_dim BETWEEN DATE_ADD(DATE(pp.reward_ts), INTERVAL 1 DAY) AND DATE_ADD(DATE(pp.reward_ts), INTERVAL 7 DAY)) AS act_after7
  FROM pp JOIN `dice-dreams-dbt.50_reporting.user_daily_metrics_agg` m
    ON m.user_id = pp.user_id AND m.date_dim BETWEEN DATE_ADD(DATE(pp.reward_ts), INTERVAL 1 DAY) AND DATE_ADD(DATE(pp.reward_ts), INTERVAL 7 DAY)
  WHERE m.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-11-02'
  GROUP BY 1, 2),
ral AS (
  SELECT pp.user_id, pp.album_id,
    SUM(IF(s.date_dim <= DATE(pp.reward_ts), s.rolls_value_sum, 0)) AS ralb_to_reward_day,
    SUM(s.rolls_value_sum) AS ralb7
  FROM pp JOIN `dice-dreams-dbt.30_intermediate.user_daily_rolls_by_source` s
    ON s.user_id = pp.user_id AND s.date_dim BETWEEN pp.entry AND DATE_ADD(pp.entry, INTERVAL 6 DAY)
  WHERE s.date_dim BETWEEN DATE '2026-03-23' AND DATE '2026-10-18' AND s.roll_type = 'rolls_in' AND s.source_rolls_group = 'album'
  GROUP BY 1, 2),
tp AS (
  SELECT rp.grp, APPROX_TOP_SUM(pu.psrc, pu.amt, 6) AS top_src_before
  FROM rp JOIN rw USING (user_id, album_id) JOIN pu ON pu.user_id = rp.user_id AND DATE(pu.ts) >= rp.entry AND pu.ts < rw.reward_ts
  GROUP BY 1),
t AS (
  SELECT pp.*, IFNULL(a.act_after7, 0) AS act_after7, IFNULL(l.new_stickers7, 0) AS new_stickers7, IFNULL(l.bought_stickers7, 0) AS bought_stickers7,
    IFNULL(r.ralb_to_reward_day, 0) AS ralb_to_reward_day, IFNULL(r.ralb7, 0) AS ralb7,
    CASE WHEN pp.n_before > 0 THEN 'a_paid_before_reward' WHEN pp.amt_d0_6 > 0 THEN 'b_paid_after_reward_in_wk1' ELSE 'c_no_pay_wk1' END AS seq
  FROM pp LEFT JOIN act a USING (user_id, album_id) LEFT JOIN link l USING (user_id, album_id) LEFT JOIN ral r USING (user_id, album_id))
SELECT grp, seq, COUNT(*) AS players,
  APPROX_QUANTILES(reward_day, 2)[OFFSET(1)] AS med_reward_day,
  ROUND(AVG(n_before), 2) AS avg_purchases_before, ROUND(AVG(IF(n_before > 0, amt_before, NULL)), 2) AS avg_amt_before_payers,
  APPROX_QUANTILES(IF(n_before > 0, amt_before, NULL), 2)[OFFSET(1)] AS med_amt_before_payers,
  APPROX_QUANTILES(IF(n_before > 0, TIMESTAMP_DIFF(reward_ts, last_before_ts, MINUTE), NULL), 4) AS q_min_last_purchase_to_reward,
  ROUND(SAFE_DIVIDE(SUM(bought_stickers7), SUM(new_stickers7)), 3) AS share_new_stickers_bought_d0_6,
  ROUND(AVG(IF(bought_stickers7 > 0, 1, 0)), 3) AS share_with_bought_stickers,
  APPROX_QUANTILES(ralb_to_reward_day, 2)[OFFSET(1)] AS med_album_rolls_to_reward_day, APPROX_QUANTILES(ralb7, 2)[OFFSET(1)] AS med_album_rolls_d0_6,
  ROUND(AVG(IF(next_ts IS NOT NULL AND next_ts <= TIMESTAMP_ADD(reward_ts, INTERVAL 168 HOUR), 1, 0)), 3) AS share_buy_within7d_after,
  APPROX_QUANTILES(IF(next_ts IS NOT NULL, TIMESTAMP_DIFF(next_ts, reward_ts, HOUR), NULL), 4) AS q_hours_to_next_purchase,
  ROUND(AVG(amt_after7), 2) AS avg_spend_7d_after, APPROX_QUANTILES(IF(amt_after7 > 0, amt_after7, NULL), 2)[OFFSET(1)] AS med_spend_7d_after_payers,
  ROUND(AVG(act_after7), 2) AS avg_active_days_7d_after, ROUND(AVG(IF(act_after7 >= 5, 1, 0)), 3) AS share_active_5plus_of_7
  , ANY_VALUE(tp.top_src_before) AS top_src_before_by_amount
FROM t LEFT JOIN tp USING (grp) GROUP BY grp, seq ORDER BY grp, seq;
