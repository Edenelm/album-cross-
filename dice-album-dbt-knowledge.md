# Dice Dreams Album — dbt Model Knowledge (read 2026-10-05)

Project: `dice-dreams-dbt`. All facts below are from dbt table/column descriptions (describe_table).

## Lineage (bottom → top)
events (album_started / sticker_received / pack_received / album_completed) + purchase_completed_vw + user_daily_activity
→ 20 `dim_album_season`, `dim_album_pixie_season`, `dim_album_reward`
→ 30 `album_pop` (user × album population)
→ 30 `fact_user_album_stickers` (user × album × set × sticker)
→ 30 `fact_user_daily_set_progression` (user × album × set × day)
→ 40 `fact_user_set_progression` (latest per user × album × set)
→ 50 `user_daily_album` (user × album × day) → 50 `user_daily_album_progression` (exec panel)
Separate: 50 `user_daily_metrics_agg` (UDM, user × day)

## Tables
### 20_core.dim_album_season (21 albums)
- album_id, album_name, album_start/end_ts, album_start/end_date, days_in_album (inclusive: end − start + 1).
- Dates = MIN start / MAX end across 3 album events. Excludes 'test'/'superplay' names.
- Exception: album 63 end hardcoded 2026-09-07 12:00 UTC (client sent year 2027).

### 20_core.dim_album_pixie_season (Google Sheet)
- pixie_start/end_ts_utc, dates, pixie_number_of_days (inclusive).

### 20_core.dim_album_reward (7 rows)
- album_reward_code → album_reward_value.

### 30_intermediate.album_pop (≈37M rows) — best POPULATION base
- Population: any album event (started, sticker or pack). NOT sticker-filtered.
- user_album_start_ts/date (first album interaction), album_segment(_code) 1–4 Easy/Medium/Hard/Extreme (default 1/Easy if no match), album_super_segment_code (0 overloaded), album_difficulty_segment, album_reward_code/value.
- ltv_until_album_start; total_spent_in_album = SUM purchase_amount where ts BETWEEN album_start_ts AND album_end_ts (deduped).
- active_days_in_album = COUNT active days between album_start_date AND album_end_date (INCLUDES end day); album_login_ratio = active / current_days_in_album.
- user_past_album_count = prior albums with login ratio ≥ 0.15.
- is_excluded / excluded_reason are FLAGS (not filtered).

### 30_intermediate.fact_user_album_stickers (≈6.6B rows, ~1.9 TB; partition sticker_collected_date)
- Per sticker: sticker_type (common/golden/super/pixie), sticker_source, mtx campaign, pack ids, collected_from_wild, sticker_duplications, sticker_receiving_order_in_set, if_closed_set.
- Per user-album: sets_completed, is_finished_album_with_stickers, is_finished_album_with_event, is_pixie_finisher, is_album_pu (= first purchase in album < album_end_ts), user_first_purchase_ts_in_album.
- GOTCHA: user_album_finish_ts = LEAST(event_ts, sticker_ts) → NULL if either is missing. Use the two is_finished flags, not finish_ts, to define finishers.
- Filter: users with ≥1 non-pixie sticker.

### 30_intermediate.fact_user_daily_set_progression (≈6.6B rows, ~2.1 TB; partition date_dim)
- Daily per set: set_unique_*_today/_lt, set_missing_* (common/golden/super), cnt_stickers_to_complete_set (+ _wo_super), is_in_fu_1/2 (+ exclude_supers), is_set_complete, closed_set_date, set_total_wild_today.
- spent_in_album_today / spent_in_pixie_today = purchases by timestamp window (album_start_ts..album_end_ts).

### 40_mart.fact_user_set_progression (≈505M rows; partition set_last_sticker_received_date_including_dup)
- Latest state per user × album × set; LEFT JOIN emits rows for every user × set in population (NULL→0/FALSE).
- GOTCHA: is_album_pu, unique_album_stickers_lt, unique_pixie_lt use LAST_VALUE ordered by user_id → arbitrary row. Don't trust those 3 columns here; take them from user_daily_album / fact_user_album_stickers.

### 50_reporting.user_daily_album (≈1.57B rows, ~1 TB; partition date_dim; cluster user_id, album_id, segment)
- Filter: users with ≥1 sticker; rows from user_album_start_date onward.
- Calendar: day_in_album, percent_of_album_days (= day/album days), pixie day fields.
- Activity: is_active (daily), active_days_in_album (cumulative in album), album_login_ratio_until_this_day. activity_days = LIFETIME total (not in-album).
- Progress: unique_stickers_lt (+ by type), percent_of_stickers_received, percent_of_sets_completed, sets_completed_today/_lt, number_of_sets_in_fu_1/2 (+ excl supers), wild_received_today/_lt, packs_received_today/_lt, total_stickers (incl. dups), new_stickers_rate.
- Money: spent_in_album_today, total_spent_in_album(_until_this_date), spent_until/after_album_completion, is_pu_until_this_date, is_album_pu, total_spent_in_pixie, is_pixie_pu.
- Finish: is_album_finisher (stickers OR event), album_completed_source, user_album_finish_date (may be NULL — see LEAST gotcha), is_pixie_finisher.
- Segments: album_segment(_code), super segment, reward code/value, ltv_until_album_start, user_past_album_count, is_excluded flag.

### 50_reporting.user_daily_album_progression (exec "paying wallet" panel)
- SPINED: one row per user per every season day, incl. days before the user joined → always filter is_active = TRUE.
- units_to_finish (non-pixie stickers left), revenue_daily_usd_sum, feature_start/end_date, day_in_feature.
- is_excluded users removed.

### 50_reporting.user_daily_metrics_agg (VIEW)
- Excludes dim_excluded_users EXCEPT 'paying_cheater'.
- activity_days = cumulative lifetime. sessions_cnt, sessions_duration_sec_sum (daily). revenues_sum = SUM purchase_amount (gross IAP), net_revenues_sum, trx_cnt, ad_revenues, ltv, install_date, retention_day, kingdom_id_start/enday, platform, country.
- UDM source data starts 2026-01-01 (older loaded from pre-2026 table).

## Cross-cutting gotchas
1. Changeover day: album N end day = album N+1 start day. Purchases are attributed by timestamp window → the same purchase counts in BOTH albums. Never SUM album revenue across albums. Day 1 of an album is also a changeover day.
2. Exclusions are inconsistent: album tables carry an is_excluded flag (not filtered); UDM view removes excluded except paying cheaters; progression table removes them. → Always apply is_excluded = FALSE + join consistently.
3. Spined tables (user_daily_album_progression; user_daily_album from user start) → count users only with is_active = TRUE.
4. activity_days is lifetime everywhere → in-window active days = COUNTIF(is_active) over the window.
5. Large tables (fact_user_album_stickers, fact_user_daily_set_progression, user_daily_album) → always filter partition + album_id.

