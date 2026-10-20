# Album Feature -- Knowledge Base & Monitoring Guide

## Table of Contents

1. [Feature Overview](#1-feature-overview)
2. [Album Lifecycle & Timeline](#2-album-lifecycle--timeline)
3. [Sub-Features](#3-sub-features)
4. [Segmentation & Rewards](#4-segmentation--rewards)
5. [Data Architecture (dbt Pipeline)](#5-data-architecture-dbt-pipeline)
6. [Key Tables & Columns Reference](#6-key-tables--columns-reference)
7. [Looker Dashboards -- KPI Mapping](#7-looker-dashboards----kpi-mapping)
8. [End-of-Season Analysis Template](#8-end-of-season-analysis-template)
9. [Goals Framework](#9-goals-framework)
10. [BigQuery Query Templates](#10-bigquery-query-templates)
11. [Business Glossary](#11-business-glossary)
12. [Album History](#12-album-history)
13. [References & Links](#13-references--links)

---

## 1. Feature Overview

The Album is a **cyclical sticker collection feature** in Dice Dreams. Players collect stickers, complete sets, and earn rewards. Each album season runs 35-79 days with a unique theme.

**Eligibility**: Kingdom >= 8

**Current Album**: Food (ID 57), 2026-03-23 to 2026-05-04 (42 days, 12 sets)

### Core Loop

1. Players receive **sticker packs** from gameplay (core, challenges, purchases, events)
2. Packs contain stickers of varying rarity: **Common**, **Golden**, **Super**
3. Stickers belong to **Sets** (12 sets per album, ~12 stickers each)
4. Completing a set earns a **set reward** (rolls)
5. Completing all sets earns the **Album Grand Prize**
6. Duplicate stickers feed the **Duplications Bar** exchange mechanism

---

## 2. Album Lifecycle & Timeline

A typical album follows this timeline:

```
Day 0          ~Day 21        ~Day 35          ~Day 42
  |               |               |               |
Album Start --> Pixie Opens --> Pixie Closes --> Album End
```

### Phases and Their Impact on ARPDAU

From past analyses, ARPDAU varies by phase:

| Phase | Duration |
|-------|----------|
| Start | First ~14 days |
| Pixie | ~12-23 days |
| End | Last 9-21 days |

---

## 3. Sub-Features

### 3.1 Regular Sticker Collection

- 12 sets per album, each with ~12 stickers
- Sticker types: **Common** (most frequent), **Golden** (medium rarity, for sale), **Super** (rare, only from gameplay)
- Total ~144 non-pixie stickers per album
- Stickers arrive via packs from: Core gameplay, Challenges, Purchases, Trail, Progress Bar, TileTwister, Tournament, etc.

### 3.2 Pixie Chase

- **Eligibility**: Kingdom >= 60, Experienced Pixie
- 12 Pixies, one per set
- Opens ~21 days into album, runs ~12-14 days
- Completing a Pixie doubles the set's rolls reward
- `pixies_album_reward_multiplier`: 1.2x-6x on Album Grand Prize if all pixies collected
- Pixie types: Non-Specific Pack, Specific Pack, Normal Pack with Pixie
- Not tradable

**Key metrics**: Pixie finishers count, % PU of finishers, revenue % by finishers

### 3.3 Pixie Second Chance

- Available from version 1.85
- Re-opens for players who didn't complete all Pixies during regular phase
- Excludes: already completed, or never reached Pixie
- Can be activated multiple times during an album

### 3.4 Heist / Seasonal Set

- **Eligibility**: Kingdom >= 60
- Time-limited mini-sets (1-3 sets, up to 12 stickers per set)
- Does NOT affect Album progression
- Sticker type: SEASONAL (not tradable)
- Cannot have Seasonal + Social active simultaneously
- Feature Flag: `seasonal_set_FF`

### 3.5 Social Set / Friends Set

- Cooperative sticker collection with Facebook friends or a bot
- Does NOT affect Album progression or segmentation
- Sticker type: SOCIAL (same appearance, different crowns)
- Token-based collection: `#socialtoken()` draw order function
- Up to 6 friends simultaneously
- Goals: ARPDAU increase + K-Factor (friend invitations)

### 3.6 Specific Sticker Pack

- Shows player exactly which sticker is inside before opening (from v1.53)
- `#SPECIFIC_STICKER:sticker_key` draw order
- From v1.69: Multiple stickers with missing-from-list logic
- Available in: Direct Purchase, Dynamic Template, Store Bundle, Progress Bar, Trail/Blast final chest, 1+1, Scrolling offer

### 3.7 Duplications Bar

- Exchange mechanism for duplicate stickers
- P50/P75/P90 tracked per type (Common, Golden, Super)
- Album 33 averages: 1,326 total duplications per user (1,184 common, 135 golden, 7 super)
- Daily duplicate rate: ~84-85%

---

## 4. Segmentation & Rewards

### 4.1 Segments

Based on spend in previous album (revenue adjusted to 70 days):

| Segment | Code | Condition |
|---------|------|-----------|
| Easy | 1 | Spent < $100 |
| Medium | 2 | Spent >= $100 |
| Hard | 3 | Spent >= $400 |
| Extreme | 4 | Spent >= $1,000 |

### 4.2 Super Segments

Matrix of segment x spend range (codes 0-5):

| Segment | SS 0 | SS 1 | SS 2 | SS 3 | SS 5 |
|---------|------|------|------|------|------|
| Easy | $0-100 | $100-300 | $300-600 | $600-1K | >=$1K |
| Medium | $0-200 | $200-400 | $400-700 | $700-1.2K | >=$1.2K |
| Hard | $0-400 | $400-700 | $700-1K | $1K-2K | >=$2K |
| Extreme | $0-700 | $700-1.5K | $1.5K-2.5K | $2.5K-6K | >=$6K |

### 4.3 Album Grand Prize

A player never sees a lower grand prize if they have already received that prize.

| Reward (Rolls) | Spend in Previous Album (adj. 70 days) |
|----------------|----------------------------------------|
| 25,000 | Default |
| 40,000 | >= $75, or finished the album |
| 65,000 | >= $150, or finished the album |
| 100,000 | >= $700, or finished the album |
| 125,000 | >= $700, or finished the album |
| 150,000 | >= $700, or finished the album |
| 200,000 | >= $700, or finished the album |

**Rules**:
- Users never see a reward lower than the highest rolls received in 14 days prior to album start (excl. PB, Album GP, Joker, Rolls from card, RPS, Mini games)
- Users never see a reward lower than previously seen

---

## 5. Data Architecture (dbt Pipeline)

### 5.1 Layer Overview

```
0_Raw (Events + External Sources)
  --> 10_Staging (Views + Light Transforms)
    --> 20_Core (Dimensions)
      --> 30_Intermediate (Facts + Population)
        --> 40_Mart (Snapshots)
          --> 50_Reporting (Main Tables + User Profile)
```

### 5.2 Source Events (Mixpanel)

| Event | Description |
|-------|-------------|
| `album_started` | User starts an album |
| `album_sticker_received` | User receives a sticker |
| `album_pack_received` | User receives a sticker pack |
| `album_completed` | User completes the album |

### 5.3 Staging Views (`stg_album_*_vw`)

12 staging views covering the full album event taxonomy:

- `stg_album_badge_tap_vw` -- UI interactions
- `stg_album_completed_vw` -- Album completion events
- `stg_album_duplication_bracket_start_vw` -- Duplication bar starts
- `stg_album_duplication_tier_completed_vw` -- Duplication tier completions
- `stg_album_duplication_tokens_earned_vw` -- Duplication tokens earned
- `stg_album_menu_item_tap_vw` -- Menu interactions
- `stg_album_onboarding_action_vw` -- Onboarding events
- `stg_album_pack_received_vw` -- Pack receipt events
- `stg_album_set_completed_vw` -- Set completion events
- `stg_album_started_vw` -- Album start events
- `stg_album_sticker_received_vw` -- Sticker receipt events (most used)
- `stg_album_video_watched_vw` -- Video watched events

### 5.4 External Sources

| Source | Description | Used By |
|--------|-------------|---------|
| `gs_album_pixie_season` | Pixie window dates (Google Sheet) | `dim_album_pixie_season` |
| `gs_album_reward` | Reward code-to-value mapping (Google Sheet) | `dim_album_reward`, `album_pop` |
| `album_stickers_profile` | Sticker catalog: set_id, sticker_id, type, crowns | Used everywhere |

### 5.5 Dependency Graph

```
gs_album_pixie_season ──> dim_album_pixie_season ──┐
gs_album_reward ──> stg_album_reward ──> dim_album_reward ──┤
                                                             │
stg_album_started_vw ──┐                                     │
stg_album_sticker_received_vw ──┤──> dim_album_season ───────┤
stg_album_pack_received_vw ──┘                               │
                                                             ▼
album_stickers_profile ──────────────────────> album_pop (user-album spine)
dim_excluded_users ──────────────────────────────┘    │
fact_purchase_completed ─────────────────────────┘    │
user_daily_activity ─────────────────────────────┘    │
smart_s_history ─────────────────────────────────┘    │
                                                      │
                    ┌─────────────────────────────────┤
                    ▼                                  ▼
          fact_user_album_stickers    fact_user_daily_set_progression
                    │                          │           │
                    │                          ▼           ▼
                    │              fact_user_set_progression
                    │                          │
                    │    stg_user_daily_set_progression_agg
                    │                          │
                    ▼                          ▼
              stg_user_daily_album_base ◄──────┘
                    │
          ┌─────────┼─────────┐
          ▼         ▼         ▼
  stg_user_daily  stg_user_daily  stg_user_daily
  _album_level   _album_metrics  _album_base
          │         │             │
          └─────────┼─────────────┘
                    ▼
           user_daily_album (MAIN TABLE)
                    │
                    ▼
              user_profile
```

---

## 6. Key Tables & Columns Reference

### 6.1 `album_pop` -- User-Album Population

**File**: `bi-models/30_intermediate/album/album_pop.sql`
**Grain**: `user_id x album_id`
**Filter**: Users with any album activity (started, received stickers, or received packs)

| Column | Type | Description |
|--------|------|-------------|
| `user_id` | STRING | User identifier (PK) |
| `album_id` | INT64 | Album identifier (PK) |
| `user_album_start_ts` | TIMESTAMP | When user first interacted with album |
| `user_album_start_date` | DATE | Date of first interaction |
| `album_difficulty_segment` | STRING | Segment from event data |
| `album_name` | STRING | Album theme name |
| `album_start_date` | DATE | Album season start |
| `album_end_date` | DATE | Album season end |
| `ltv_until_album_start` | FLOAT64 | Lifetime value before album |
| `total_spent_in_album` | FLOAT64 | Total spend during album |
| `total_spent_in_pixie` | FLOAT64 | Spend during pixie phase |
| `album_segment_code` | INT64 | 1=Easy, 2=Medium, 3=Hard, 4=Extreme |
| `album_segment` | STRING | Text label |
| `album_super_segment_code` | INT64 | Super segment 0-5 |
| `album_reward_code` | INT64 | Reward tier code |
| `album_reward_value` | INT64 | Reward rolls amount |
| `active_days_in_album` | INT64 | Days active during album |
| `album_login_ratio` | FLOAT64 | Active days / album days |
| `pixie_login_ratio` | FLOAT64 | Active days in pixie / pixie days |
| `user_past_album_count` | INT64 | Previous albums (login ratio >= 0.15) |
| `user_past_pixie_count` | INT64 | Previous pixie phases (login ratio >= 0.15) |
| `excluded_reason` | STRING | Why excluded from analytics |
| `is_excluded` | BOOLEAN | Exclusion flag |

**Segment logic**: Albums > 29 use `smart_s_history`; Albums <= 29 use `user_hist_album_segment`.

### 6.2 `fact_user_album_stickers` -- Sticker-Level Facts

**File**: `bi-models/30_intermediate/album/fact_user_album_stickers.sql`
**Grain**: `user_id x album_id x set_id x sticker_id`
**Filter**: Only users with >= 1 non-pixie sticker collected

| Column | Type | Description |
|--------|------|-------------|
| `user_id` | STRING | PK |
| `album_id` | INT64 | PK |
| `set_id` | INT64 | PK |
| `sticker_id` | INT64 | PK |
| `sticker_type` | STRING | common, golden, super, pixie |
| `sticker_key` | STRING | Sticker key identifier |
| `crowns` | INT64 | Crown count |
| `sticker_collected_ts` | TIMESTAMP | First collection timestamp |
| `sticker_collected_date` | DATE | First collection date |
| `sticker_source` | STRING | Where sticker came from |
| `sticker_pack_key` | STRING | Pack key that delivered it |
| `sticker_mtx_campaign_name` | STRING | Campaign name |
| `collected_from_wild` | BOOLEAN | Wild sticker flag |
| `sticker_duplications` | INT64 | Number of duplicates received |
| `sticker_receiving_order_in_set` | INT64 | Order within set |
| `is_sticker_collected` | BOOLEAN | Collection flag |
| `if_closed_set` | BOOLEAN | Did this sticker complete the set? |
| `sets_completed` | INT64 | Running sets completed count |
| `is_finished_album_with_stickers` | BOOLEAN | All sets done via stickers |
| `is_finished_album_with_event` | BOOLEAN | Album completed event received |
| `user_album_finish_ts` | TIMESTAMP | LEAST(event_ts, max_sticker_ts) |
| `is_pixie_finisher` | BOOLEAN | All pixies collected |
| `pixie_finish_ts` | TIMESTAMP | When all pixies collected |
| `is_album_pu` | BOOLEAN | Purchased during album |
| `login_ratio_when_receiving_sticker` | FLOAT64 | Login ratio at sticker time |

### 6.3 `fact_user_daily_set_progression` -- Daily Set Progression

**File**: `bi-models/30_intermediate/album/fact_user_daily_set_progression.sql`
**Grain**: `user_id x album_id x set_id x date_dim`
**Filter**: `total_sticker_collected_in_album > 0`

Key columns per set per day:
- `unique_stickers_today/lt` -- New unique stickers (today / lifetime)
- `total_stickers_today/lt` -- All stickers including duplicates
- `unique_common/golden/super_stickers_today/lt` -- By type
- `wild_received_today/lt` -- Wild stickers
- `unique_pixie_today/lt`, `total_pixie_today/lt` -- Pixie stickers
- `spent_in_album_today`, `spent_in_pixie_today` -- Daily spend
- `is_in_fu_1` -- Set missing 1 sticker to complete
- `is_in_fu_2` -- Set missing 2 stickers to complete
- `is_in_fu_1_exclude_supers` / `is_in_fu_2_exclude_supers` -- FU excluding super stickers
- `is_set_complete` / `is_set_complete_with_pixie` -- Completion flags
- `set_missing_common/golden/super` -- Missing count by type

### 6.4 `user_daily_album` -- Main Reporting Table

**File**: `bi-models/50_reporting/album/user_daily_album.sql`
**Grain**: `user_id x album_id x date_dim`
**Filters**: `is_any_sticker_collected_in_album = 1` AND `date_dim >= user_album_start_date`

This is the primary table behind all 3 Looker dashboards. Key column groups:

**Album Dimensions**: `album_start_date`, `album_end_date`, `album_number_of_days`, `day_in_album`, `percent_of_album_days`

**Pixie Dimensions**: `pixie_start_date`, `pixie_end_date`, `pixie_number_of_days`, `day_in_pixie`, `percent_of_pixie_days`

**User Segments**: `album_segment` (Easy/Medium/Hard/Extreme), `album_segment_code`, `album_super_segment_code`, `album_difficulty_segment`, `album_reward_code`, `album_reward_value`, `excluded_reason`, `is_excluded`

**Activity**: `is_active`, `active_days_in_album`, `kingdom_id_start_day`, `kingdom_id_end_day`, `album_login_ratio`, `album_login_ratio_until_this_day`, `pixie_login_ratio`, `is_pixie_user` (kingdom 60+)

**Spending**: `spent_in_album_today`, `total_spent_in_album`, `total_spent_in_album_until_this_date`, `is_pu_until_this_date`, `is_album_pu`, `total_spent_in_pixie`, `total_spent_in_pixie_until_this_date`, `is_pixie_pu`, `spent_after_album_completion`, `spent_until_album_completion`

**Sticker Progress**: `unique_stickers_today/lt`, `total_stickers_today/lt`, `unique_common/golden/super_stickers_today/lt`, `wild_received_today/lt`, `unique_pixies_today/lt`, `total_pixies_today/lt`, `new_stickers_rate_today/lt`, `new_pixie_rate_today/lt`, `percent_of_stickers_received`, `percent_of_pixies_received`

**Set Completion**: `sets_completed_today/lt`, `sets_completed_with_pixie_today/lt`, `percent_of_sets_completed`, `number_of_sets_in_fu_1/2`, `number_of_sets_in_fu_1/2_exclude_supers`

**Album Completion**: `is_album_finisher`, `album_completed_source`, `user_album_finish_ts`, `user_album_finish_date`, `is_pixie_finisher`, `user_pixie_finish_date`, `user_pixie_finish_ts`

**Packs**: `packs_received_today`, `packs_received_lt`

---

## 7. Looker Dashboards -- KPI Mapping

### 7.1 Dashboard 2143: Album Report (Daily Monitoring)

**URL**: `https://superplay.cloud.looker.com/dashboards/2143`
**Default Filters**: Album ID=57, Login Ratio>=0.5, Is Album PU=Yes, Percentile=P50

| Dashboard Section | KPI | Source Column(s) |
|-------------------|-----|------------------|
| New Sticker Received Yesterday | Sticker ID, Set ID, Type, Revshare, Usershare, Day-over-day change | `fact_user_album_stickers.sticker_id`, `sticker_type`, `sticker_source` |
| Sets Completed | P50 sets completed by day | `user_daily_album.sets_completed_lt` with PERCENTILE_CONT |
| Sets Completed With Pixie | P50 with pixie by day | `user_daily_album.sets_completed_with_pixie_lt` |
| Wild Received | Wilds by day, avg | `user_daily_album.wild_received_today`, `wild_received_lt` |
| Wild Sources | Source, Pack Key, Revshare | `fact_user_album_stickers` filtered to wild stickers |
| Set Distribution (Revshare) | Per set: sticker count vs revshare | `fact_user_daily_set_progression.unique_album_stickers_lt` per set |
| Most Wanted Common Stickers | Sticker ID, Set ID, Revshare, Usershare | `fact_user_set_progression` + missing sticker logic |
| Most Wanted Golden Stickers | Same | Same, filtered to golden |
| Most Wanted Super Stickers | Same | Same, filtered to super |
| Sticker Sources (Common/Golden/Super) | Source, Pack Key, Revshare, Usershare | `fact_user_album_stickers.sticker_source`, `sticker_pack_key` |
| Duplications Bar (P50/P75/P90) | By type (Common/Golden/Super) | Duplication events + `stg_album_duplication_*` views |

### 7.2 Dashboard 2128: Albums Comparison

**URL**: `https://superplay.cloud.looker.com/dashboards/2128`
**Default Filters**: Primary Album=57, Comparison Album=45, Login Ratio>=0.5, PU=Yes, Percentile=P50

| Dashboard Section | KPI | Source Column(s) |
|-------------------|-----|------------------|
| All Stickers Revshare & Usershare | Sticker bins (5-unit ranges) | `user_daily_album.unique_stickers_lt` binned |
| Commons Revshare & Usershare | Common bins | `user_daily_album.unique_common_stickers_lt` binned |
| Goldens Revshare & Usershare | Golden bins (2-unit ranges) | `user_daily_album.unique_golden_stickers_lt` binned |
| Supers Revshare & Usershare | Super unique count | `user_daily_album.unique_super_stickers_lt` |
| Sets Revshare & Usershare | Sets completed distribution | `user_daily_album.sets_completed_lt` |
| Sets Progression by Percentile | P50 sets by day-in-album | `user_daily_album.sets_completed_lt`, `day_in_album` |
| Total Stickers Progression | P50 stickers by day | `user_daily_album.unique_stickers_lt`, `day_in_album` |
| Common/Golden/Super Progression | P50 by type by day | `unique_common/golden/super_stickers_lt`, `day_in_album` |
| New Sticker Rate | P50 rate by day | `user_daily_album.new_stickers_rate_lt`, `day_in_album` |
| Packs Received | P50 packs by day | `user_daily_album.packs_received_lt`, `day_in_album` |
| Total Stickers by Percentile | Stickers per day | `user_daily_album.total_stickers_today` per day |

### 7.3 Dashboard 2091: Album FU - Sets & Stickers

**URL**: `https://superplay.cloud.looker.com/dashboards/2091`
**Default Filters**: Album ID=57, Login Ratio>=0, Excluded=Yes,No

| Dashboard Section | KPI | Source Column(s) |
|-------------------|-----|------------------|
| Number of Sets in FU 1/2 (Revshare) | Distribution by FU count | `user_daily_album.number_of_sets_in_fu_1/2` |
| Number of Sets in FU (Exclude Supers) | Same without super stickers | `user_daily_album.number_of_sets_in_fu_1/2_exclude_supers` |
| Sets in FU (per Set 1-12) | FU_3/FU_2/FU_1/Finishers with Revshare+Usershare | `fact_user_set_progression`: `is_in_fu_1`, `is_in_fu_2`, `is_set_complete` |
| Missing Stickers in Set | Per sticker: type, Revshare, Usershare | `fact_user_set_progression` missing sticker columns |
| Most Wanted Stickers (FU 1/2) | Set ID, Sticker ID, Type, Revenue, Users | `fact_user_album_stickers` joined with missing logic |
| Most Missing Stickers by Set | Per set breakdown | `fact_user_set_progression` per set |
| New Sticker Received Yesterday | Set, Sticker, Type, Revshare, Usershare | `fact_user_album_stickers` filtered to yesterday |

---

## 8. End-of-Season Analysis Template

Based on Album 33 and Album 37 analysis presentations.

### Standard Sections

#### 8.1 Album Overview
- **KPIs comparison table** (vs 3-4 previous albums):
  - Users in album, Percent of PU, Revenue (adjusted), Avg daily revenue, ARPDAU, ARPPU
- **Daily Revenue Trend** chart with event annotations (Pixie, Heist, Seasonal, Pet end, etc.)
- **ARPDAU Over Album Phases**: Start / Pixie / End breakdown
- **ARPDAU comparison** over full album timeline vs previous albums

#### 8.2 Pixie Analysis
- KPIs comparison: Users, %PU, Revenue, Avg daily revenue, ARPDAU, ARPPU
- **Finishers**: Count, %PU of finishers, Revenue % by finishers
- Finishers by day-in-pixie
- Accumulated finishers by day
- **Source of last 3 pixies** (PU & Non-PU breakdown):
  - Purchase + Purchase Treatment (~44%)
  - Core (~15%)
  - Challenge + Purchase Challenge (~39%)
  - Support/Treatment (~1%)
- **Pixie Goals vs Actual** by segment (see Goals Framework below)

#### 8.3 Heist Overview
- Comparison table: dates, balance/open dates, users, finishers, finishers revshare, %PU, ARPDAU

#### 8.4 Seasonal Sets Overview
- Per-season KPIs: dates, sets, stickers, users, %PU, revenue (adj.), ARPDAU, ARPPU
- Finishers overview per season
- Goals vs actual
- Seasonal for Album Finishers analysis (if applicable)

#### 8.5 Album End
- KPIs comparison: days, users, revenue (adj.), P50 daily revenue, ARPDAU, ARPPU
- **Final 9 days** ARPDAU comparison
- Seasonal for Finishers uplift analysis
- Finishers by days-from-album-end

#### 8.6 Album Finishers
- Finishers comparison: count, %PU, revenue (adj.), % of total revenue, ARPDAU, ARPPU
- **Source of last 3 stickers**: Purchase, Core, Challenge, Support/Treatment breakdown

#### 8.7 Tests
- Test overview, groups, metrics
- Revenue impact, finishers impact
- Statistical significance

#### 8.8 Sticker Duplications (optional)
- Avg duplications per user (total, common, golden, super)
- Cumulative duplications over album
- Daily duplicate rate (~84%)
- Daily packs (avg ~6.6-6.7)
- Avg stickers per pack (~4.9)
- New sticker rate in pack (~21%)
- All-duplicate packs rate (~61-63%)

#### 8.9 Conclusions & Recommendations

---

## 9. Goals Framework

### 9.1 Pixie Goals

Tracked by segment, by days-from-pixie-end, with columns for 0/1/3/5 pixies remaining.

**Template** (from Album 37):

| Date | Days from End | Pixies Collected | 1 remaining | 3 remaining | 5 remaining | Treatment |
|------|--------------|-----------------|-------------|-------------|-------------|-----------|
| - | 8 | 8 | Goal% | Goal% | Goal% | Core |
| - | 6 | 9 | Goal% | Goal% | Goal% | Core |
| - | 4 | 10 | Goal% | Goal% | Goal% | - |
| - | 2 | 11 | Goal% | Goal% | Goal% | - |
| - | 0 | 12 | Goal% | Goal% | Goal% | - |

Treatment levels: Core (no intervention), Free, Mid, Advanced

### 9.2 Album Goals

Tracked by segment, by days-from-album-end, with sticker targets and columns for 1/3/5 stickers remaining.

**Template** (from Album 37):

| Date | Days from End | Stickers | 1 left | 3 left | 5 left |
|------|--------------|----------|--------|--------|--------|
| - | 20 | 139 | 40% | 60% | 80% |
| - | 14 | 140 | 35% | 55% | 75% |
| - | 9 | 141 | 30% | 50% | 70% |
| - | 5 | 142 | - | - | - |
| - | 3 | 143 | - | - | - |
| - | 0 | 144 | 20% | 40% | 60% |

*Values shown are for Easy segment; Medium/Hard/Extreme have progressively higher targets.*

### 9.3 Treatment Levels

| Level | Description |
|-------|-------------|
| Free | No cost intervention -- free stickers/packs |
| Core | Standard gameplay (no intervention) |
| Mid | Medium-intensity offers |
| Advanced | High-intensity offers/push |

---

## 10. BigQuery Query Templates

### 10.1 Album Overview -- Current Album KPIs

```sql
SELECT
    album_id,
    COUNT(DISTINCT user_id) AS users_in_album,
    COUNT(DISTINCT CASE WHEN is_album_pu THEN user_id END) AS pu_users,
    SAFE_DIVIDE(
        COUNT(DISTINCT CASE WHEN is_album_pu THEN user_id END),
        COUNT(DISTINCT user_id)
    ) AS pct_pu,
    SUM(spent_in_album_today) AS total_revenue,
    SAFE_DIVIDE(SUM(spent_in_album_today), COUNT(DISTINCT date_dim)) AS avg_daily_revenue,
    SAFE_DIVIDE(
        SUM(spent_in_album_today),
        SUM(CASE WHEN is_active THEN 1 ELSE 0 END)
    ) AS arpdau,
    SAFE_DIVIDE(
        SUM(spent_in_album_today),
        SUM(CASE WHEN is_active AND is_pu_until_this_date THEN 1 ELSE 0 END)
    ) AS arppu
FROM `dice-dreams-dbt.50_reporting.user_daily_album`
WHERE album_id = 57
    AND album_login_ratio >= 0.5
    AND is_excluded = FALSE
GROUP BY album_id
```

### 10.2 Sticker Progression by Percentile (P50)

```sql
SELECT
    day_in_album,
    APPROX_QUANTILES(unique_stickers_lt, 100)[OFFSET(50)] AS p50_stickers,
    APPROX_QUANTILES(unique_common_stickers_lt, 100)[OFFSET(50)] AS p50_common,
    APPROX_QUANTILES(unique_golden_stickers_lt, 100)[OFFSET(50)] AS p50_golden,
    APPROX_QUANTILES(unique_super_stickers_lt, 100)[OFFSET(50)] AS p50_super,
    APPROX_QUANTILES(sets_completed_lt, 100)[OFFSET(50)] AS p50_sets
FROM `dice-dreams-dbt.50_reporting.user_daily_album`
WHERE album_id = 57
    AND album_login_ratio >= 0.5
    AND is_album_pu = TRUE
    AND is_excluded = FALSE
GROUP BY day_in_album
ORDER BY day_in_album
```

### 10.3 Album Finishers Analysis

```sql
SELECT
    album_id,
    COUNT(DISTINCT user_id) AS finishers,
    COUNT(DISTINCT CASE WHEN is_album_pu THEN user_id END) AS pu_finishers,
    SAFE_DIVIDE(
        COUNT(DISTINCT CASE WHEN is_album_pu THEN user_id END),
        COUNT(DISTINCT user_id)
    ) AS pct_pu_of_finishers,
    SUM(total_spent_in_album) / COUNT(DISTINCT user_id) AS avg_spend_per_finisher,
    SUM(spent_until_album_completion) AS revenue_until_completion,
    SUM(spent_after_album_completion) AS revenue_after_completion
FROM `dice-dreams-dbt.50_reporting.user_daily_album`
WHERE album_id = 57
    AND is_album_finisher = TRUE
    AND date_dim = user_album_finish_date
    AND is_excluded = FALSE
GROUP BY album_id
```

### 10.4 Pixie Finishers Analysis

```sql
SELECT
    album_id,
    COUNT(DISTINCT user_id) AS pixie_finishers,
    COUNT(DISTINCT CASE WHEN is_album_pu THEN user_id END) AS pu_pixie_finishers,
    SAFE_DIVIDE(
        COUNT(DISTINCT CASE WHEN is_album_pu THEN user_id END),
        COUNT(DISTINCT user_id)
    ) AS pct_pu_of_pixie_finishers
FROM `dice-dreams-dbt.50_reporting.user_daily_album`
WHERE album_id = 57
    AND is_pixie_finisher = TRUE
    AND date_dim = user_pixie_finish_date
    AND is_excluded = FALSE
GROUP BY album_id
```

### 10.5 Goals vs Actual -- Sticker Progression by Segment

```sql
SELECT
    album_segment,
    DATE_DIFF(album_end_date, date_dim, DAY) AS days_from_end,
    APPROX_QUANTILES(unique_stickers_lt, 100)[OFFSET(50)] AS p50_stickers,
    SAFE_DIVIDE(
        COUNTIF(unique_stickers_lt >= 191),
        COUNT(*)
    ) AS pct_1_sticker_remaining,
    SAFE_DIVIDE(
        COUNTIF(unique_stickers_lt >= 189),
        COUNT(*)
    ) AS pct_3_stickers_remaining,
    SAFE_DIVIDE(
        COUNTIF(unique_stickers_lt >= 187),
        COUNT(*)
    ) AS pct_5_stickers_remaining
FROM `dice-dreams-dbt.50_reporting.user_daily_album`
WHERE album_id = 57
    AND album_login_ratio >= 0.5
    AND is_album_pu = TRUE
    AND is_excluded = FALSE
    AND DATE_DIFF(album_end_date, date_dim, DAY) IN (20, 14, 9, 5, 3, 0)
GROUP BY album_segment, days_from_end, album_end_date
ORDER BY album_segment, days_from_end DESC
```

### 10.6 FU Analysis -- Sets Close to Completion

```sql
SELECT
    set_id,
    CASE
        WHEN is_set_complete THEN 'Finishers'
        WHEN set_missing_common + set_missing_golden + set_missing_super = 1 THEN 'FU_1'
        WHEN set_missing_common + set_missing_golden + set_missing_super = 2 THEN 'FU_2'
        ELSE 'FU_3'
    END AS fu_type,
    COUNT(DISTINCT user_id) AS users,
    SAFE_DIVIDE(COUNT(DISTINCT user_id), SUM(COUNT(DISTINCT user_id)) OVER (PARTITION BY set_id)) AS user_share
FROM `dice-dreams-dbt.40_mart.fact_user_set_progression`
WHERE album_id = 57
    AND unique_album_stickers_lt > 0
GROUP BY set_id, fu_type
ORDER BY set_id, fu_type
```

### 10.7 Cross-Album Comparison

```sql
SELECT
    album_id,
    COUNT(DISTINCT user_id) AS users,
    COUNT(DISTINCT CASE WHEN is_album_pu THEN user_id END) AS pu_users,
    SAFE_DIVIDE(
        COUNT(DISTINCT CASE WHEN is_album_pu THEN user_id END),
        COUNT(DISTINCT user_id)
    ) AS pct_pu,
    SUM(spent_in_album_today) AS total_revenue,
    SAFE_DIVIDE(SUM(spent_in_album_today), COUNT(DISTINCT date_dim)) AS avg_daily_revenue,
    SAFE_DIVIDE(
        SUM(spent_in_album_today),
        SUM(CASE WHEN is_active THEN 1 ELSE 0 END)
    ) AS arpdau
FROM `dice-dreams-dbt.50_reporting.user_daily_album`
WHERE album_id IN (45, 47, 49, 51, 53, 55, 57)
    AND album_login_ratio >= 0.5
    AND is_excluded = FALSE
GROUP BY album_id
ORDER BY album_id
```

### 10.8 Source of Last N Stickers for Finishers

```sql
WITH finisher_stickers AS (
    SELECT
        user_id,
        album_id,
        sticker_source,
        sticker_pack_key,
        sticker_type,
        sticker_receiving_order_in_set,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, album_id
            ORDER BY sticker_collected_ts DESC
        ) AS sticker_order_from_end
    FROM `dice-dreams-dbt.30_intermediate.fact_user_album_stickers`
    WHERE album_id = 57
        AND is_sticker_collected = TRUE
        AND sticker_type != 'pixie'
        AND sets_completed = (SELECT MAX(set_id) FROM UNNEST([12]))
)
SELECT
    sticker_source,
    sticker_pack_key,
    COUNT(*) AS occurrences,
    SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER ()) AS share
FROM finisher_stickers
WHERE sticker_order_from_end <= 3
GROUP BY sticker_source, sticker_pack_key
ORDER BY occurrences DESC
LIMIT 15
```

---

## 11. Business Glossary

| Term | Definition | Data Column |
|------|-----------|-------------|
| **ARPDAU** | Average Revenue Per Daily Active User | `SUM(revenue) / SUM(active_users)` |
| **ARPPU** | Average Revenue Per Paying User | `SUM(revenue) / COUNT(paying_users)` |
| **FU (Follow-Up)** | Sets with 1-2 stickers left to complete | `is_in_fu_1`, `is_in_fu_2` |
| **FU_1 / FU_2 / FU_3** | 1/2/3+ stickers missing from set | Derived from missing counts |
| **Finishers** | Users who completed all sets in album | `is_album_finisher = TRUE` |
| **Pixie Finishers** | Users who collected all 12 pixies | `is_pixie_finisher = TRUE` |
| **Revshare** | Revenue share: group revenue / total revenue | Calculated in Looker |
| **Usershare** | User share: group users / total users | Calculated in Looker |
| **Login Ratio** | Active days / album days (up to current) | `album_login_ratio` |
| **Album PU** | User who made >= 1 purchase during album | `is_album_pu` |
| **Day in Album** | Sequential day number (1-indexed from album start) | `day_in_album` |
| **Revenue Adjusted** | Revenue normalized to X days (70 or 77) for cross-album comparison | Calculated in presentations |
| **Treatment** | Intervention level for goals: Free/Core/Mid/Advanced | Used in goal tracking |
| **Super Segment** | Spend-based sub-segmentation (0-5) | `album_super_segment_code` |
| **Duplications Bar** | Exchange mechanism for duplicate stickers | `stg_album_duplication_*` events |
| **Wild** | Special sticker that fills any missing slot | `collected_from_wild` |
| **Pack** | Container delivering 1+ stickers | `stg_album_pack_received_vw` |
| **New Sticker Rate** | Unique stickers / total stickers received | `new_stickers_rate_today` |
| **Sticker Bins** | Bucketed ranges of sticker counts for distribution analysis | Calculated in Looker |

---

## 12. Album History

| Album Name | ID | Start | End | Days | Notes |
|------------|-----|-------|-----|------|-------|
| Food | 57 | 2026-03-23 | 2026-05-04 | 42 | **Current** - 12 Sets |
| Dangerous Love | 55 | 2026-02-02 | 2026-03-23 | 49 | 12 Sets |
| Winter | 53 | 2025-12-15 | 2026-02-02 | 49 | 12 Sets |
| Autumn | 51 | 2025-11-09 | 2025-12-15 | 36 | Short Album |
| Halloween | 49 | 2025-09-29 | 2025-11-09 | 41 | 12 Sets |
| Musicals | 47 | 2025-08-18 | 2025-09-29 | 42 | 12 Sets |
| Time Travel | 45 | 2025-07-14 | 2025-08-18 | 35 | Short, Sets Prizes Test |
| American Dream | 43 | 2025-06-10 | 2025-07-14 | 34 | Short, 100K+ Finishers |
| Candy Land | 41 | 2025-04-03 | 2025-06-10 | 68 | |
| Festivals | 37 | 2025-01-14 | 2025-04-03 | 79 | Less Stickers + Week 5 Tests |
| Holidays | 35 | 2024-12-10 | 2025-01-14 | 35 | Short, 100K+ Finishers |
| Myth | 33 | 2024-10-08 | 2024-12-10 | 63 | Golden Set Test |
| Back2School | 31 | 2024-08-06 | 2024-10-08 | 63 | |
| Summer | 29 | 2024-06-04 | 2024-08-06 | 63 | Takeover Poland |
| Love Stories | 27 | 2024-03-26 | 2024-06-04 | 70 | |
| Retro | 25 | 2024-01-10 | 2024-03-26 | 76 | Takeover US+UK |
| Winter Wonder | 22 | 2023-11-07 | 2024-01-10 | 64 | |
| Around the World | 18 | 2023-08-22 | 2023-11-07 | 77 | |

---

## 13. References & Links

### Looker Dashboards
- [Album Report (Daily)](https://superplay.cloud.looker.com/dashboards/2143) -- Dashboard 2143
- [Albums Comparison](https://superplay.cloud.looker.com/dashboards/2128) -- Dashboard 2128
- [Album FU - Sets & Stickers](https://superplay.cloud.looker.com/dashboards/2091) -- Dashboard 2091

### Confluence Documentation
- [Albums Info](https://superplaystudio.atlassian.net/wiki/spaces/DICE/pages/3551494177/Albums+Info) -- Feature overview, eligibility, history
- Pixie Chase -- Technical setup (16 pages)
- Pixie Second Chance -- Re-opening mechanism
- Friends Set (Social Set) -- Cooperative sticker collection (26 pages)
- Seasonal Set Event -- Time-limited mini-sets (13 pages)
- Specific Sticker Pack -- Targeted sticker delivery

### Monday.com
- [Features Tracking Board](https://superplay.monday.com/boards/6358507235) -- Album item with 10 sub-items of past analyses
- BA Owners: Inbar Granat, Talia Arbiv

### Key dbt Model Files
- `bi-models/30_intermediate/album/album_pop.sql` -- User-album population spine
- `bi-models/30_intermediate/album/fact_user_album_stickers.sql` -- Sticker-level facts
- `bi-models/30_intermediate/album/fact_user_daily_set_progression.sql` -- Daily set progression
- `bi-models/40_mart/album/fact_user_set_progression.sql` -- Latest set snapshot
- `bi-models/50_reporting/album/user_daily_album.sql` -- Main reporting table
- `bi-models/model_yaml/user_daily_album.yml` -- Column documentation

### Past Analyses (Google Slides)
- [Album 33 Analysis](https://docs.google.com/presentation/d/13LE7jT3uCLbJXZxD6ht8leYqzvMncrHieouTk5OJmQU/edit) -- End-of-season + Prizes Test
- [Album 37 Analysis](https://docs.google.com/presentation/d/1Fc1ZAGImXCTaD7u5Zf2N7UYyH9hs-0s5VaV5mmYumdM/edit) -- End-of-season + Less Stickers Test + New Super Segments

