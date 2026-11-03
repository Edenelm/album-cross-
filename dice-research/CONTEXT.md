# Dice album research — CONTEXT (verified knowledge)
Each line says how we know it: **[data]** measured in BigQuery (doc named), **[Eden]** stated by Eden, not checked in data, **[doc]** from team documentation in the repo, not checked. Paths are relative to the repo root.

## 1. Album mechanics
- 144 set stickers per album; Pixie stickers are outside the 144 [doc] `decisions-definitions-register.md`.
- The album opens at Kingdom 8. Of payers who paid in their first 7 days (installs Mar–Jun 2026), 70% reached the album by day 7, 84% by day 90 [data] `cross-game-comparison-framework.md` A2.
- Album IDs jump by 2 (…59, 61, 63, 65, 67); previous album = id − 2 [data].
- Album dates (2026): 55 = 02-02..03-23, 57 = 03-23..05-04, 59 = 05-04..06-22, 61 = 06-22..07-27, 63 = 07-27..09-07, 65 = 09-07..10-19, 67 = 10-19..11-30 (open) [data] `20_core.dim_album_season`, 2026-11-03. Its `days_in_album` counts the close day (59 = 50; earlier docs say 49 without it).
- Album 65 had the only flat end since April 2025; overall it is a regular album [Eden 2026-11-03]. Only end-of-album measures treat 65 as a case (base 59/61/63) [Eden 2026-11-02, narrowed 2026-11-03].
- Three stickers are locked until the end (2 Supers + 1 Golden). They reach 1% of holders only 3–6 days before close: 59 S143/S108/G141, 61 S143/S120/G142, 63 S143/S132/G129 [data] `claude/dice-completion-path-2026-11-02.md`. Locking is by design [Eden 2026-10-21].
- Stopping at 10 of 12 Supers is by design: the album brings players to 2 missing Supers [Eden 2026-10-17].
- Wild fills any sticker, including a locked one. Wild is sold from about 7 days before close [Eden 2026-10-15]. Free Wilds in the last week come in two bursts: Bonus Wheel close−8/−7 and Trail final reward from close−3; on close−6..−4 only a paid Wild exists [data] `claude/dice-wild-sources-2026-10-21.md`.
- Trail is a continuous chain of short campaigns (39 campaigns Jul 2–Sep 7, 1–2 days each); about half of new Supers come from Trail; the Trail final reward gives a Wild or a Super [data] `claude/dice65-pu-trail-2026-10-25.md`. Which layer gives the Wild and who is eligible: **unknown** (Dice team question). That the Trail is configured harder at album end: [Eden 2026-11-03], not checked.
- Difficulty segment Easy / Medium / Hard / Extreme from last-album spend normalised to 70 days (<$100 / $100–400 / $400–1,000 / ≥$1,000); players with no history start Easy [doc] `dice_album_user_segmentation.md`. What the segment changes in the album: **unknown**.
- "Album segment" in Eden's words = final-prize code `album_reward_code` 1–7 (top = 200K rolls), not Easy..Extreme [Eden 2026-10-19]. The code steps up after finishing or reaching a spend bar [doc].
- After 144: Fortune Wheel + Lava Quest ("Momentum Quest") [Eden 2026-10-19].
- About 20 stickers per active day all album; from 50 stickers on, 77–89% are duplicates [data] `claude/dice-entry-dups-rolls-2026-11-02.md` §3.
- Late joiners get more new stickers: at the same collection size and pack source, a late entrant's pack holds ~2x the new stickers (same stickers per pack) [data] `topics/t1-first-album/findings.md` 0-B. Pack event field `progression_balance_factor_value_golden/super` is much lower for them. No documented catch-up rule; field meaning unknown (Dice team question). Pity counter never fired in week 1.

## 2. Definitions (Dice)
Shared definitions live in `decisions-definitions-register.md`. Dice-specific points:
- **Finisher** = 144 unique set stickers by the end of the close day; count close-day finishers from the sticker table (the daily table does not update stickers on the close day).
- **Payer** = paid on any album day, close day included. **Album revenue** = daily-table spend, album start..close−1.
- **Revenue share denominator** = all in-game purchase revenue during the album (start..close−1), all players, exclusions removed. RV revenue separate.
- **First album** = no row in any earlier album in `user_daily_album` (history from 2023-11-07). Not `user_past_album_count` = 0 (it marks 19–22K returning payers as first-album) [Eden 2026-10-21].
- **First-album player (Topic 1)** = no record in any earlier album; not split by install date (Eden 2026-11-03, D-005).
- **Purchase-delivered sticker** = `sticker_source` = `purchase.source` and `sticker_mtx_campaign_id` = `campaign_id`, purchase ≤10 min before (94–98% match for offers, placebo 0–2%, album 63) [data] `claude/dice-sticker-source-vs-purchase-2026-11-02.md`. Replaces the `Pricing%` pack rule.
- Exclusions: `is_excluded`.

## 3. Data sources (project `dice-dreams-dbt`, checked 2026-11-03)
| Table | Grain | Use | Notes |
|---|---|---|---|
| `20_core.dim_album_season` | album | album dates | album 63 end date hard-coded (client sent year 2027) |
| `30_intermediate.album_pop` | user × album | album presence (first-album history), segment, reward code, LTV before album | `user_past_album_count` counts only albums with login ratio ≥ 0.15 (not a first-album flag). **`user_album_start_date` unreliable**: overwritten to the close day for 25–31% of rows in 63 / 65 (C-005); use `user_daily_album` for entry |
| `50_reporting.user_daily_album` | user × album × day | activity, gross spend, unique / total stickers (by type), sets, Wild received, kingdom, packs count, finish | partition `date_dim`; rows only from the first sticker; close-day stickers not updated |
| `50_reporting.user_daily_album_progression` | user × album × day, **spined** (active or not) | stickers remaining, revenue | excluded users absent |
| `10_staging.stg_album_pack_received_vw` | pack event | pack `source`, `pack_key`, stickers per pack, new stickers per pack (by type), `is_wild`, `mtx_campaign_id` | staging (Eden OK 2026-11-03); partition `pdate`; several fields marked "Investigate" in the event doc |
| `30_intermediate.fact_user_album_stickers` | new sticker (first copy) | source, pack key, Wild fill, timestamp | ~1.9 TB; partition `sticker_collected_date`; no duplicates |
| `30_intermediate.fact_user_daily_set_progression` / `40_mart.fact_user_set_progression` | user × album × set (× day) | set progress, FU flags | |
| `30_intermediate.user_daily_rolls_by_source` | user × day × roll type × source × campaign | rolls in by source; `source_rolls_group = 'album'` = set / album completed (± Pixie), Pixies, duplication exchange; `source_purchase_group` ≠ 'others' reaches 95–99% of players incl. non-payers, so it is **not** a payment marker; 'core wager' = rolls won back while rolling | partition `date_dim` |
| `30_intermediate.user_daily_rolls_in_out` | user × day | rolls in / out, balance | |
| `40_mart.fact_dynamic_resource_given` | resource grant | candidate for Wild receipt | not verified |
| `40_mart.user_daily_trail`, `50_reporting.fact_user_campaign_trail`, `20_core.dim_trail_campaign_event` | trail | Topic 3 | |
| `20_core.purchase_completed_vw` | purchase | time, gross amount, source, campaign | |
| `50_reporting.user_daily_metrics_agg` | user × day (view) | game activity, revenue, `install_date` | |
| `20_core.fact_user_installation` | user | install ts, attribution | |
| Offer exposure log | | offers shown | **not found** for Dice |

Access: BigQuery connector, `dice-dreams-dbt` can be queried (checked 2026-11-03).

## 4. Source log
For each source: what it adds, topic, effect on definitions or conclusions.
| Date | Source | Adds | Topic | Changes a definition / conclusion? |
|---|---|---|---|---|
| 2026-11-03 | Existing repo material (list in `topics/*/README.md` and §1–3 above) | Baseline knowledge | all | No; conflicts listed in `DECISIONS.md` |
| 2026-11-03 | Dice dbt catalogue (50/40/30/20 + pack staging view), `dim_album_season` | Album tables, pack-event fields, album roll sources, 2026 album dates | 1 (also 2, 3) | Adds sources; `days_in_album` includes the close day (no change to conclusions) |
| 2026-11-03 | Topic 1 queries (album_pop vs daily table; rolls by source; install age) | album_pop start-date bug; roll-source groups; first-album players are ~70% installed ≤7 days before entry, kingdom 5–6 at entry | 1 | Entry definition moved to `user_daily_album` (C-005); Kingdom-8 unlock in docs questioned (C-006) |
| 2026-11-03 | Pack event fields (`progression_balance_factor_*`, `is_pity_counter_triggered`, `unique_stickers`) | Pack content differs by entry timing at equal collection | 1 | Catch-up = hypothesis, not documented (C-006-style question for the Dice team) |
| 2026-11-03 | Topic 1 reopen (R1–R4): rolls tables per player, album reward days, next album A+2 | Per-player roll means are dominated by a few heavy players (use medians); album rolls ≈ 5–6% of a typical player's non-wager roll inflow; next album starts on the close day, so wait = days left | 1 | Medians required for roll metrics; two clocks in D-010 |
