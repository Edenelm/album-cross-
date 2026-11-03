# Dice album research — CONTEXT (verified knowledge)
Each line says how we know it: **[data]** measured in BigQuery (doc named), **[Eden]** stated by Eden, not checked in data, **[doc]** from team documentation in the repo, not checked. Paths are relative to the repo root.

## 1. Album mechanics
- 144 set stickers per album; Pixie stickers are outside the 144 [doc] `decisions-definitions-register.md`.
- The album opens at Kingdom 8. Of payers who paid in their first 7 days (installs Mar–Jun 2026), 70% reached the album by day 7, 84% by day 90 [data] `cross-game-comparison-framework.md` A2.
- Album IDs jump by 2 (…59, 61, 63, 65, 67); previous album = id − 2 [data].
- Album dates: 59 = 05-04..06-22 (49 days), 61 = 06-22..07-27 (35), 63 = 07-27..09-07 (42), 65 = 09-07..10-19 (42), 67 open to 11-30 [data] `index/topic-dice-chapter.md`.
- Typical albums = 59/61/63. Album 65 is the only flat end since April 2025: a case, never the base [Eden 2026-11-02].
- Three stickers are locked until the end (2 Supers + 1 Golden). They reach 1% of holders only 3–6 days before close: 59 S143/S108/G141, 61 S143/S120/G142, 63 S143/S132/G129 [data] `claude/dice-completion-path-2026-11-02.md`. Locking is by design [Eden 2026-10-21].
- Stopping at 10 of 12 Supers is by design: the album brings players to 2 missing Supers [Eden 2026-10-17].
- Wild fills any sticker, including a locked one. Wild is sold from about 7 days before close [Eden 2026-10-15]. Free Wilds in the last week come in two bursts: Bonus Wheel close−8/−7 and Trail final reward from close−3; on close−6..−4 only a paid Wild exists [data] `claude/dice-wild-sources-2026-10-21.md`.
- Trail is a continuous chain of short campaigns (39 campaigns Jul 2–Sep 7, 1–2 days each); about half of new Supers come from Trail; the Trail final reward gives a Wild or a Super [data] `claude/dice65-pu-trail-2026-10-25.md`. Which layer gives the Wild and who is eligible: **unknown** (Dice team question). That the Trail is configured harder at album end: [Eden 2026-11-03], not checked.
- Difficulty segment Easy / Medium / Hard / Extreme from last-album spend normalised to 70 days (<$100 / $100–400 / $400–1,000 / ≥$1,000); players with no history start Easy [doc] `dice_album_user_segmentation.md`. What the segment changes in the album: **unknown**.
- "Album segment" in Eden's words = final-prize code `album_reward_code` 1–7 (top = 200K rolls), not Easy..Extreme [Eden 2026-10-19]. The code steps up after finishing or reaching a spend bar [doc].
- After 144: Fortune Wheel + Lava Quest ("Momentum Quest") [Eden 2026-10-19].
- About 20 stickers per active day all album; from 50 stickers on, 77–89% are duplicates [data] `claude/dice-entry-dups-rolls-2026-11-02.md` §3.
- Late joiners get catch-up: new stickers per active day rise with entry timing (new players 5–6 in the first third, 10–11 in the last third); "new kingdom" is the largest source for last-third joiners who finish (21%) [data] same doc §1–2. The catch-up rule itself is not documented.

## 2. Definitions (Dice)
Shared definitions live in `decisions-definitions-register.md`. Dice-specific points:
- **Finisher** = 144 unique set stickers by the end of the close day; count close-day finishers from the sticker table (the daily table does not update stickers on the close day).
- **Payer** = paid on any album day, close day included. **Album revenue** = daily-table spend, album start..close−1.
- **Revenue share denominator** = all in-game purchase revenue during the album (start..close−1), all players, exclusions removed. RV revenue separate.
- **First album** = no row in any earlier album in `user_daily_album` (history from 2023-11-07). Not `user_past_album_count` = 0 (it marks 19–22K returning payers as first-album) [Eden 2026-10-21].
- **New to the game** ≠ first album. Not yet defined; proposed in `topics/t1-first-album/PLAN.md` §2.
- **Purchase-delivered sticker** = `sticker_source` = `purchase.source` and `sticker_mtx_campaign_id` = `campaign_id`, purchase ≤10 min before (94–98% match for offers, placebo 0–2%, album 63) [data] `claude/dice-sticker-source-vs-purchase-2026-11-02.md`. Replaces the `Pricing%` pack rule.
- Exclusions: `is_excluded`.

## 3. Data sources (project `dice-dreams-dbt`)
| Table | Grain | Use | Notes |
|---|---|---|---|
| `50_reporting.user_daily_album` | user × album × day | entry date (`user_album_start_date`), activity, spend, unique/total stickers, packs (`packs_received_today`), sets, Wild received, segments | Rows only from the first sticker; close-day stickers not updated |
| `30_intermediate.fact_user_album_stickers` | new sticker (first copy) | source, pack key, Wild fill, timestamp | ~1.9 TB; partition `sticker_collected_date`; no duplicates |
| `30_intermediate.album_pop` | user × album | population incl. players with album events but no sticker | used once for population |
| `30_intermediate.user_daily_rolls_in_out`, `user_daily_rolls_by_source` | user × day | rolls in by source, out, balance | used in earlier docs; album-source mapping to verify |
| `40_mart.fact_dynamic_resource_given` | resource grant | candidate for Wild receipt | not verified |
| `20_core.purchase_completed_vw` | purchase | purchase time, source, campaign | |
| `50_reporting.user_daily_metrics_agg` | user × day (view) | `install_date`, game revenue | |
| `10_staging.stg_album_pack_received_vw` | pack event | pack types and sources | staging: ask Eden before use |
| Offer exposure log | — | offers shown | **not found** for Dice |

Access: the BigQuery connector lists `dice-dreams-dbt` with `can_query: true` (checked 2026-11-03).

## 4. Source log
For each source: what it adds, topic, effect on definitions or conclusions.
| Date | Source | Adds | Topic | Changes a definition / conclusion? |
|---|---|---|---|---|
| 2026-11-03 | Existing repo material (list in `topics/*/README.md` and §1–3 above) | Baseline knowledge | all | No; conflicts listed in `DECISIONS.md` |
