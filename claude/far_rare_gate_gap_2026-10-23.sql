-- Eden 2026-10-23 (option A): rerun "far payers: days between last new rare and gate open" on Disney 14/15 and Domino 19/20, one gate definition.
-- Population = MidDis / MidDom (middle-payers-stall-2026-10-15.md): standard population, middle payers P50-95 of spend so far at 75% of the album, far = 4+ missing at close-1.
-- Last new rare = day the player reached the final Royal count (r_st), days before close, revenue-weighted (as the slide) + median.
-- Gate = Royal(s) within 1.5x of the scarcest at close. Tool opening read from daily Joker fills of the gate in the whole standard population; far payers' own fill share shown too.
-- Joker fill = new gate sticker with collected_by_joker_flag (flag = ever from a Joker pack; approximation).
-- Results: claude/far-rare-gate-gap-2026-10-23.md

-- ===== DISNEY 14/15 (solitaire-dreams-411507) =====
WITH excluded AS (SELECT user_id FROM `solitaire-dreams-411507.bi_prod.user_profile` WHERE install_date BETWEEN DATE '2020-01-01' AND DATE '2026-10-05' AND exclude_reason IS NOT NULL),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_open, a.album_close_date AS a_close,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d, DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend,
    IFNULL(a.unique_common_stickers_lt, 0) AS uc, IFNULL(a.unique_golden_stickers_lt, 0) AS ug, IFNULL(a.unique_royal_stickers_tl, 0) AS ur
  FROM `solitaire-dreams-411507.bi_prod.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND a.album_id IN (14, 15)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
r1 AS (SELECT r0.*, MAX(uc) OVER w AS uc_end, MAX(ug) OVER w AS ug_end, MAX(ur) OVER w AS ur_end FROM r0 WINDOW w AS (PARTITION BY album_id, user_id)),
r2 AS (SELECT r1.*, MIN(IF(ur = ur_end, d, NULL)) OVER (PARTITION BY album_id, user_id) AS r_st FROM r1),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, ANY_VALUE(a_close) AS a_close, SUM(spend) AS total, MIN(d) AS first_d,
    SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far,
    144 - (ANY_VALUE(uc_end) + ANY_VALUE(ug_end) + ANY_VALUE(ur_end)) AS m_end, ANY_VALUE(r_st) AS r_st,
    ARRAY_AGG(IFNULL(login_ratio, -1) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS lr_last, ARRAY_AGG(IFNULL(user_album_count, 0) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS uac_last
  FROM r2 GROUP BY 1, 2),
tgt AS (SELECT * FROM ua WHERE lr_last >= 0.5 AND IFNULL(uac_last, 0) > 1 AND first_d <= CAST(CEIL(0.75 * n) AS INT64) - 1),
p AS (SELECT tgt.*, IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr FROM tgt),
far AS (SELECT album_id, user_id, n, a_close, total, r_st FROM p WHERE so_far > 0 AND pr >= 0.5 AND pr < 0.95 AND m_end >= 4),
st AS (
  SELECT s.album_id, s.user_id, s.sticker_id, s.sticker_collected_min_date AS dt, IFNULL(s.collected_by_joker_flag, FALSE) AS jk
  FROM `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` s
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-13' AND DATE '2026-10-04' AND s.album_id IN (14, 15)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
-- gate = scarcest Royal(s) at close in the standard population (method that found Domino 20 R119/R120)
holders AS (SELECT st.album_id, st.sticker_id, COUNT(*) AS h FROM st JOIN tgt t USING (album_id, user_id) JOIN (SELECT album_id, ANY_VALUE(a_close) AS a_close FROM tgt GROUP BY 1) c USING (album_id)
            WHERE st.dt <= c.a_close GROUP BY 1, 2),
gate AS (SELECT album_id, sticker_id, h FROM holders QUALIFY h <= 1.5 * MIN(h) OVER (PARTITION BY album_id)),  -- scarcest Royal(s): within 1.5x of the scarcest
fills AS (SELECT f.album_id, DATE_DIFF(f.a_close, st.dt, DAY) AS dbc, COUNT(DISTINCT f.user_id) AS k
          FROM far f JOIN st USING (album_id, user_id) JOIN gate g USING (album_id, sticker_id)
          WHERE st.jk AND DATE_DIFF(f.a_close, st.dt, DAY) BETWEEN 0 AND 14 GROUP BY 1, 2),
fills_all AS (SELECT t.album_id, DATE_DIFF(t.a_close, st.dt, DAY) AS dbc, COUNT(DISTINCT t.user_id) AS k
          FROM tgt t JOIN st USING (album_id, user_id) JOIN gate g USING (album_id, sticker_id)
          WHERE st.jk AND DATE_DIFF(t.a_close, st.dt, DAY) BETWEEN 0 AND 14 GROUP BY 1, 2),
na AS (SELECT album_id, COUNT(*) AS n_all FROM tgt GROUP BY 1),
fa AS (SELECT fl.album_id, STRING_AGG(FORMAT('%d:%d', fl.dbc, fl.k), ' ' ORDER BY fl.dbc DESC) AS joker_gate_fills_all_by_dbc
       FROM fills_all fl GROUP BY 1),
nf AS (SELECT album_id, COUNT(*) AS n_far, ROUND(SUM(total)) AS rev, ROUND(SUM(total * (n - r_st)) / SUM(total), 1) AS last_royal_dbc,
         APPROX_QUANTILES(n - r_st, 2)[OFFSET(1)] AS last_royal_dbc_median FROM far GROUP BY 1),
gs AS (SELECT album_id, STRING_AGG(FORMAT('%d(%d holders)', sticker_id, h), ' ') AS gate_stickers FROM gate GROUP BY 1),
fx AS (SELECT fl.album_id, MAX(IF(fl.k >= 0.01 * nf.n_far, fl.dbc, NULL)) AS gate_open_dbc,
         STRING_AGG(FORMAT('%d:%.1f%%', fl.dbc, 100 * fl.k / nf.n_far), ' ' ORDER BY fl.dbc DESC) AS joker_gate_fill_by_dbc
       FROM fills fl JOIN nf USING (album_id) GROUP BY 1)
SELECT nf.album_id, nf.n_far, nf.rev, nf.last_royal_dbc, nf.last_royal_dbc_median, gs.gate_stickers, na.n_all, fa.joker_gate_fills_all_by_dbc, fx.joker_gate_fill_by_dbc AS far_fill_share_by_dbc
FROM nf LEFT JOIN gs USING (album_id) LEFT JOIN fx USING (album_id) LEFT JOIN na USING (album_id) LEFT JOIN fa USING (album_id) ORDER BY 1;

-- ===== DOMINO 19/20 (domino-dreams-dbt) =====
WITH excluded AS (SELECT user_id FROM `domino-dreams-dbt.prod_40_mart.user_daily_metrics` WHERE date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' GROUP BY 1 HAVING LOGICAL_OR(IFNULL(suspected_cheater_flag, FALSE))),
r0 AS (
  SELECT a.album_id, a.user_id, a.date_dim, a.album_open_date AS a_open, a.album_close_date AS a_close,
    DATE_DIFF(a.date_dim, a.album_open_date, DAY) AS d, DATE_DIFF(a.album_close_date, a.album_open_date, DAY) AS n,
    a.login_ratio, a.user_album_count, IFNULL(a.album_spent_today, 0) AS spend,
    IFNULL(a.unique_common_stickers_lt, 0) AS uc, IFNULL(a.unique_golden_stickers_lt, 0) AS ug, IFNULL(a.unique_royal_stickers_tl, 0) AS ur
  FROM `domino-dreams-dbt.prod_40_mart.user_daily_album` a LEFT JOIN excluded e ON e.user_id = a.user_id
  WHERE a.date_dim BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND a.album_id IN (19, 20)
    AND a.special_user_flag = FALSE AND e.user_id IS NULL AND a.date_dim < a.album_close_date),
r1 AS (SELECT r0.*, MAX(uc) OVER w AS uc_end, MAX(ug) OVER w AS ug_end, MAX(ur) OVER w AS ur_end FROM r0 WINDOW w AS (PARTITION BY album_id, user_id)),
r2 AS (SELECT r1.*, MIN(IF(ur = ur_end, d, NULL)) OVER (PARTITION BY album_id, user_id) AS r_st FROM r1),
ua AS (
  SELECT album_id, user_id, ANY_VALUE(n) AS n, ANY_VALUE(a_close) AS a_close, SUM(spend) AS total, MIN(d) AS first_d,
    SUM(IF(d <= CAST(CEIL(0.75 * n) AS INT64) - 1, spend, 0)) AS so_far,
    144 - (ANY_VALUE(uc_end) + ANY_VALUE(ug_end) + ANY_VALUE(ur_end)) AS m_end, ANY_VALUE(r_st) AS r_st,
    ARRAY_AGG(IFNULL(login_ratio, -1) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS lr_last, ARRAY_AGG(IFNULL(user_album_count, 0) ORDER BY date_dim DESC LIMIT 1)[OFFSET(0)] AS uac_last
  FROM r2 GROUP BY 1, 2),
tgt AS (SELECT * FROM ua WHERE lr_last >= 0.5 AND IFNULL(uac_last, 0) > 1 AND first_d <= CAST(CEIL(0.75 * n) AS INT64) - 1),
p AS (SELECT tgt.*, IF(so_far > 0, PERCENT_RANK() OVER (PARTITION BY album_id, so_far > 0 ORDER BY so_far), NULL) AS pr FROM tgt),
far AS (SELECT album_id, user_id, n, a_close, total, r_st FROM p WHERE so_far > 0 AND pr >= 0.5 AND pr < 0.95 AND m_end >= 4),
st AS (
  SELECT s.album_id, s.user_id, s.sticker_id, s.sticker_collected_min_date AS dt, IFNULL(s.collected_by_joker_flag, FALSE) AS jk
  FROM `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` s
  WHERE s.sticker_collected_min_date BETWEEN DATE '2026-07-06' AND DATE '2026-10-11' AND s.album_id IN (19, 20)
    AND s.user_collected_sticker_flag AND LOWER(s.sticker_type) = 'royal'
  QUALIFY ROW_NUMBER() OVER (PARTITION BY s.album_id, s.user_id, s.sticker_id ORDER BY s.sticker_collected_min_ts) = 1),
-- gate = scarcest Royal(s) at close in the standard population (method that found Domino 20 R119/R120)
holders AS (SELECT st.album_id, st.sticker_id, COUNT(*) AS h FROM st JOIN tgt t USING (album_id, user_id) JOIN (SELECT album_id, ANY_VALUE(a_close) AS a_close FROM tgt GROUP BY 1) c USING (album_id)
            WHERE st.dt <= c.a_close GROUP BY 1, 2),
gate AS (SELECT album_id, sticker_id, h FROM holders QUALIFY h <= 1.5 * MIN(h) OVER (PARTITION BY album_id)),  -- scarcest Royal(s): within 1.5x of the scarcest
fills AS (SELECT f.album_id, DATE_DIFF(f.a_close, st.dt, DAY) AS dbc, COUNT(DISTINCT f.user_id) AS k
          FROM far f JOIN st USING (album_id, user_id) JOIN gate g USING (album_id, sticker_id)
          WHERE st.jk AND DATE_DIFF(f.a_close, st.dt, DAY) BETWEEN 0 AND 14 GROUP BY 1, 2),
nf AS (SELECT album_id, COUNT(*) AS n_far, ROUND(SUM(total)) AS rev, ROUND(SUM(total * (n - r_st)) / SUM(total), 1) AS last_royal_dbc,
         APPROX_QUANTILES(n - r_st, 2)[OFFSET(1)] AS last_royal_dbc_median FROM far GROUP BY 1),
gs AS (SELECT album_id, STRING_AGG(FORMAT('%d(%d holders)', sticker_id, h), ' ') AS gate_stickers FROM gate GROUP BY 1),
fx AS (SELECT fl.album_id, MAX(IF(fl.k >= 0.01 * nf.n_far, fl.dbc, NULL)) AS gate_open_dbc,
         STRING_AGG(FORMAT('%d:%.1f%%', fl.dbc, 100 * fl.k / nf.n_far), ' ' ORDER BY fl.dbc DESC) AS joker_gate_fill_by_dbc
       FROM fills fl JOIN nf USING (album_id) GROUP BY 1)
SELECT nf.album_id, nf.n_far, nf.rev, nf.last_royal_dbc, nf.last_royal_dbc_median, gs.gate_stickers, na.n_all, fa.joker_gate_fills_all_by_dbc, fx.joker_gate_fill_by_dbc AS far_fill_share_by_dbc
FROM nf LEFT JOIN gs USING (album_id) LEFT JOIN fx USING (album_id) LEFT JOIN na USING (album_id) LEFT JOIN fa USING (album_id) ORDER BY 1;
