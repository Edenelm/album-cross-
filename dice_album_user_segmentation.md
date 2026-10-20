# Dice Dreams Album: How Users Are Segmented

Every album user in Dice Dreams carries three labels:

| Label | Values | Set when | Based on | Used for |
|---|---|---|---|---|
| **Album segment** | 1 Easy, 2 Medium, 3 Hard, 4 Extreme | Once, at album start | Spend in the last album the user played | Album difficulty |
| **Album reward** | 1–7 (25K to 200K rolls) | Once, at album start | Reward history, last album spend or completion, max rolls received | Album completion prize |
| **Super segment** | 0, 1, 2, 3, 5 | Live, every day | Spend in the current album vs expected pace | Tracking and targeting during the album |

The first two are calculated between albums by the same query (Appendix B). The super segment is calculated daily during the album (Appendix A).

---

## 1. Album segment (difficulty)

The user's spend in the **last album they played** is normalized to a 70-day album and compared to fixed thresholds.

```
adjusted_spend = total_spent_in_album × 70 / (album_number_of_days − 1)
```

| Album segment | Adjusted spend in last album played |
|---|---|
| 1 Easy | under $100 |
| 2 Medium | $100 to under $400 |
| 3 Hard | $400 to under $1,000 |
| 4 Extreme | $1,000 or more |

Points to know:

- **"Last album played" is not the same as "previous album."** A user who skipped the most recent album is segmented on the last album they did play, however long ago.
- **Users with no album history default to Easy.**
- **"Played" means at least one sticker collected.** `user_daily_album` only includes users with at least one sticker, so an album where the user collected nothing doesn't count.
- **New spenders start in Easy.** Users who were small spenders last time, or are new to albums, play the easiest album even if they spend heavily in the current one. The super segment is what catches them.

---

## 2. Album reward (completion prize tier)

The reward tier is built in two steps.

### Step 1: Reward ladder

The starting point is the **highest reward code the user has ever had** (all albums, not just the last). The user moves up one step if, in their last album played, they finished the album or reached the spend bar (adjusted to 70 days):

| Highest reward so far | Spend bar to move up one step |
|---|---|
| 1 (25K) | $75 |
| 2 (40K) | $150 |
| 3 (65K) | $700 |
| 4 (100K) | $700 |
| 5 (125K) | $700 |
| 6 (150K) | $700 |
| 7 (200K) | Already the top tier |

### Step 2: Rolls floor

The tier can't be lower than what the user's maximum rolls received justify (`fact_user_max_rolls_recieved`, refreshed between albums):

| Max rolls received | Minimum reward tier |
|---|---|
| 150,000+ | 7 (200K) |
| 125,000+ | 6 (150K) |
| 100,000+ | 5 (125K) |
| 65,000+ | 4 (100K) |
| 40,000+ | 3 (65K) |
| 25,000+ | 2 (40K) |
| below 25,000 | 1 (25K) |

The final tier is the higher of the ladder result and the rolls floor.

Points to know:

- **Rewards only ratchet up.** Because the ladder starts from the all-time maximum, a user's tier never comes down, even after they stop spending. Tiers inflate over time.
- **Finishing an album is worth the same as hitting the spend bar.**

---

## 3. Super segment (live spend pace)

The super segment answers one question: **is the user spending ahead of or behind the expected pace for their album segment?** It is recalculated daily.

### Step 1: Expected share of album spend by today

A spend curve gives the share of a user's full-album spend that should be spent by a given day. The curves were fit on a 77-day album, so the current day is stretched onto that scale:

```
x = days_since_album_start × (77 / 42)
```

| Album segment | Curve (share of album spend expected by day x) |
|---|---|
| 1 Easy | 0.000000018·x⁴ − 0.000002·x³ + 0.000202·x² + 0.0014·x + 0.0016 |
| 2 Medium | 0.0000000185·x⁴ − 0.000002·x³ + 0.0001·x² + 0.0088·x + 0.01 |
| 3 Hard | 0.0000006·x³ − 0.00005·x² + 0.0135·x + 0.0041 |
| 4 Extreme | Same curve as Hard |

All curves reach about 1.0 (100%) at x = 77.

### Step 2: Tier budgets

Each album segment has a full-album budget per tier, scaled from a 77-day to a 42-day album:

```
threshold = curve(x) × budget × 42 / 77
```

| Album segment | SS0 budget | SS1 budget | SS2 budget | SS3 budget |
|---|---|---|---|---|
| 1 Easy | $100 | $300 | $600 | $1,000 |
| 2 Medium | $200 | $400 | $700 | $1,200 |
| 3 Hard | $400 | $700 | $1,000 | $2,000 |
| 4 Extreme | $700 | $1,500 | $2,500 | $6,000 |

### Step 3: Assignment

| Super segment | Spend in current album so far |
|---|---|
| 0 | No spend, or up to the SS0 threshold |
| 1 | Above SS0, up to SS1 |
| 2 | Above SS1, up to SS2 |
| 3 | Above SS2, up to SS3 |
| 5 | Above the SS3 threshold |

Points to know:

- **There is no super segment 4.** The codes are 0, 1, 2, 3, 5.
- **Thresholds rise every day** as the curve progresses, so a user who stops spending drifts down tiers.
- **The stored column can lag.** `album_super_segment_code` in `user_daily_album` is set once per day. Users who cross a threshold later that day only show the new tier in the live calculation.

---

## 4. Known issues and maintenance

| Issue | Why it matters | Suggested fix |
|---|---|---|
| Three different length bases | Album segments normalize to 70 days, the spend curve assumes 77 days, the budgets scale to 42 days | Confirm the intended base and align the factors |
| Hardcoded start date and `42` in the super-segment query | Must be edited every album; not every album runs 43 days | Read `album_start_date` and `album_number_of_days` from `user_daily_album` |
| `current_album` = max `album_id` in `dim_album_season` | If the next album is loaded before it starts, the query returns nothing | Filter on `CURRENT_DATE() BETWEEN album_start_date AND album_end_date` |
| Misleading column name | `model_output_ss5` is the ceiling of SS3, not SS5 | Rename threshold columns to the tier they cap |
| No `is_excluded` filter | Excluded users are counted | Add `AND NOT is_excluded` where needed |
| Two spend fields | `total_spent_in_album` and `total_spent_in_album_until_this_date` come from different sources and can disagree for some users | Pick one field and use it consistently |
| `CURRENT_DATE()` is UTC | Today's partition holds only part of the day's spend | Use yesterday's partition for stable reporting |
| Segment/reward query scans the full table | No `date_dim` filter on a ~1 TB table | Read per-user-album data from `30_intermediate.album_pop` instead |
| Rolls table is in another project | `dice-dreams.ba_prod.fact_user_max_rolls_recieved` is outside `dice-dreams-dbt` | Run that step in the BigQuery console; refresh the table between albums |

### Between-albums checklist

1. Refresh `fact_user_max_rolls_recieved`.
2. In the segment/reward query, set `album_id <=` to the album that just ended.
3. In the super-segment query, update the album start date and day count.

---

## 5. Tables used

| Table | What it holds |
|---|---|
| `dice-dreams-dbt.50_reporting.user_daily_album` | One row per user, album and day: spend, stickers, segments, completion. Partitioned by `date_dim`; only users with at least one sticker |
| `dice-dreams-dbt.20_core.dim_album_season` | One row per album: id, start and end dates, length |
| `dice-dreams-dbt.30_intermediate.album_pop` | One row per user and album: segment, reward, spend (source of the user-album fields above) |
| `dice-dreams.ba_prod.fact_user_max_rolls_recieved` | Max rolls received per user, refreshed between albums |

Key columns: `album_segment_code`, `album_super_segment_code`, `album_reward_code`, `total_spent_in_album`, `total_spent_in_album_until_this_date`, `is_album_finisher`, `album_number_of_days`, `is_excluded`.

---

## Appendix A: Super-segment query (as used)

```sql
WITH current_album AS (
  SELECT DISTINCT album_id
  FROM `dice-dreams-dbt.20_core.dim_album_season`
  ORDER BY 1 DESC
  LIMIT 1
),

current_album_status_per_user AS (
  SELECT DISTINCT user_id, album_segment_code, total_spent_in_album, unique_stickers_lt
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE album_id = (SELECT album_id FROM current_album) AND date_dim = CURRENT_DATE
),

model_calc AS (
  SELECT 1 AS album_segment_code,
    (0.000000018*POW(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42),4) + (-0.000002)*POW(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42),3) + 0.000202*POW(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42),2) + 0.0014*(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42)) + 0.0016) AS model_output
  UNION ALL
  SELECT 2,
    (0.0000000185*POW(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42),4) + (-0.000002)*POW(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42),3) + 0.0001*POW(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42),2) + 0.0088*(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42)) + 0.01)
  UNION ALL
  SELECT 3,
    (0.0000006*POW(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42),3) + (-0.00005)*POW(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42),2) + 0.0135*(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42)) + 0.0041)
  UNION ALL
  SELECT 4,
    (0.0000006*POW(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42),3) + (-0.00005)*POW(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42),2) + 0.0135*(DATE_DIFF(CURRENT_DATE(), "2026-09-07", DAY)*(77/42)) + 0.0041)
),

expected_spent_model AS (
  SELECT album_segment_code, model_output,
    CASE album_segment_code
      WHEN 1 THEN model_output * (100 * 42/77)
      WHEN 2 THEN model_output * (200 * 42/77)
      WHEN 3 THEN model_output * (400 * 42/77)
      WHEN 4 THEN model_output * (700 * 42/77)
    END AS model_output_ss0,
    CASE album_segment_code
      WHEN 1 THEN model_output * (300 * 42/77)
      WHEN 2 THEN model_output * (400 * 42/77)
      WHEN 3 THEN model_output * (700 * 42/77)
      WHEN 4 THEN model_output * (1500 * 42/77)
    END AS model_output_ss1,
    CASE album_segment_code
      WHEN 1 THEN model_output * (600 * 42/77)
      WHEN 2 THEN model_output * (700 * 42/77)
      WHEN 3 THEN model_output * (1000 * 42/77)
      WHEN 4 THEN model_output * (2500 * 42/77)
    END AS model_output_ss2,
    CASE album_segment_code
      WHEN 1 THEN model_output * (1000 * 42/77)
      WHEN 2 THEN model_output * (1200 * 42/77)
      WHEN 3 THEN model_output * (2000 * 42/77)
      WHEN 4 THEN model_output * (6000 * 42/77)
    END AS model_output_ss5  -- ceiling of SS3
  FROM model_calc
)

SELECT user_id,
  CASE
    WHEN total_spent_in_album IS NULL THEN 0
    WHEN total_spent_in_album <= model_output_ss0 THEN 0
    WHEN total_spent_in_album <= model_output_ss1 THEN 1
    WHEN total_spent_in_album <= model_output_ss2 THEN 2
    WHEN total_spent_in_album <= model_output_ss5 THEN 3
    ELSE 5
  END AS super_segment
FROM current_album_status_per_user
LEFT JOIN expected_spent_model USING (album_segment_code)
```

## Appendix B: Album segment and reward query (as used)

```sql
WITH user_data AS (
  SELECT DISTINCT user_id, album_id, total_spent_in_album, is_album_finisher, album_reward_code,
    total_spent_in_album * 70 / (album_number_of_days - 1) AS adjusted_spent_in_album,
    MAX(album_reward_code) OVER (PARTITION BY user_id) AS max_album_reward
  FROM `dice-dreams-dbt.50_reporting.user_daily_album`
  WHERE album_id <= 63  -- change to the album that just ended
  QUALIFY ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY album_id DESC) = 1  -- last album played
),

user_album_reward AS (
  SELECT DISTINCT user_id,
    CASE
      WHEN max_album_reward = 7 THEN 7
      WHEN max_album_reward = 6 AND (adjusted_spent_in_album >= 700 OR is_album_finisher) THEN 7
      WHEN max_album_reward = 6 THEN 6
      WHEN max_album_reward = 5 AND (adjusted_spent_in_album >= 700 OR is_album_finisher) THEN 6
      WHEN max_album_reward = 5 THEN 5
      WHEN max_album_reward = 4 AND (adjusted_spent_in_album >= 700 OR is_album_finisher) THEN 5
      WHEN max_album_reward = 4 THEN 4
      WHEN max_album_reward = 3 AND (adjusted_spent_in_album >= 700 OR is_album_finisher) THEN 4
      WHEN max_album_reward = 3 THEN 3
      WHEN max_album_reward = 2 AND (adjusted_spent_in_album >= 150 OR is_album_finisher) THEN 3
      WHEN max_album_reward = 2 THEN 2
      WHEN max_album_reward = 1 AND (adjusted_spent_in_album >= 75 OR is_album_finisher) THEN 2
      ELSE 1
    END AS reward
  FROM user_data
),

final_user_album_reward AS (
  SELECT DISTINCT user_id,
    CASE
      WHEN max_rolls >= 150000 OR reward = 7 THEN 7  -- 200K
      WHEN max_rolls >= 125000 OR reward = 6 THEN 6  -- 150K
      WHEN max_rolls >= 100000 OR reward = 5 THEN 5  -- 125K
      WHEN max_rolls >= 65000  OR reward = 4 THEN 4  -- 100K
      WHEN max_rolls >= 40000  OR reward = 3 THEN 3  -- 65K
      WHEN max_rolls >= 25000  OR reward = 2 THEN 2  -- 40K
      ELSE 1                                         -- 25K
    END AS album_reward
  FROM user_album_reward
  LEFT JOIN (
    SELECT DISTINCT user_id, max_rolls
    FROM `dice-dreams.ba_prod.fact_user_max_rolls_recieved`  -- refresh between albums
  ) USING (user_id)
)

SELECT DISTINCT user_id, album_reward,
  CASE
    WHEN adjusted_spent_in_album >= 1000 THEN 4  -- Extreme
    WHEN adjusted_spent_in_album >= 400  THEN 3  -- Hard
    WHEN adjusted_spent_in_album >= 100  THEN 2  -- Medium
    ELSE 1                                       -- Easy
  END AS album_segment
FROM user_data
LEFT JOIN final_user_album_reward USING (user_id)
```

