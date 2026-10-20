# Topic 5 — 5d v4: population = PU, NOT first album (all 3 games) + Domino First_Royal_Gift (2026-10-13)

Supersedes 5d table in `claude/topic5-rare-sources-2026-10-12.md` (that one included first-album players).
Decisions (Eden, 2026-10-13):
- Domino campaign `EV_Royal_Card_Popup%` (pack_key First_Royal_Gift) → B "Daily / free gift". Eden: First_Royal_Gift = first-time album experience (given when a player opens the album for the first time).
- Population for all three games = players for whom this is NOT their first album.
  - Dice: `50_reporting.user_daily_album.user_past_album_count > 0`
  - Domino: `prod_40_mart.user_daily_album.user_album_count > 1`
  - Disney: `bi_prod.user_daily_album.user_album_count > 1` (column undocumented — Needs Validation that 1 = first album)
Other filters unchanged: PU (album spend > 0 before close), login ratio on last row ≥0.5, exclusions (Dice is_excluded; Domino special_user + suspected_cheater; Disney special_user + exclude_reason), close day excluded, first receipt per user × rare (new rares only). Dice uses v2 blank-source fix (Puzzle/Merge Collection → Other events).
PU after filter: Dice 61 176,332 / 63 180,849 (was 219,418 / 220,287 → ~20% of PU were first-album); Domino 17 135,610 / 19 118,956; Disney 14 370,293 / 15 325,155.
Chart: topic5_rare_sources_by_quarter_v3.png (in chat).

| Category share (Q1/Q2/Q3/Q4) | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| Trail event | 50/68/74/21 | 38/62/60/27 | 9/8/4/3 | 9/13/10/12 | 0/12/0/0 | 0/2/0/19 |
| Other events | 40/25/17/49 | 51/29/30/50 | 76/57/29/38 | 42/59/48/46 | 65/39/66/49 | 47/55/66/45 |
| Momentum | – | – | 6/5/12/9 | 9/14/24/7 | 0/9/4/8 | 11/2/2/4 |
| Long feature | 0/1/0/0 | 1/0/1/0 | 0/18/30/0 | 0 | 18/26/22/19 | 31/36/25/10 |
| Daily / free gift | 9/5/6/6 | 10/8/9/8 | 9/8/3/3 | **38**/12/7/3 (incl. gift 19/0/0/0) | 16/13/5/11 | 10/5/7/16 |
| Closing Market | – | – | 0/1/3/14 | 0 | 0/0/0/10 | 0/0/0/2 |
| Paid offer | 1/1/1/11 | 0/0/0/11 | 0/1/1/3 | 2/1/0/10 | 0/0/2/2 | 0/0/0/3 |
| Dup exchange | 0/0/0/12 | 0/0/0/3 | 0/0/18/30 | 0/0/11/23 | 0 | 0 |
| Unknown/social | 0/0/2/0 | 0/1/0/0 | 0/2/0/0 | 0 | 1/1/1/1 | 1/1/1/1 |

Reading:
- Known: excluding first-album players changes shares by ≤2–4pp in Dice and Disney — the cross-game pattern holds (Dice: Trail backbone Q1–Q3, Q4 → paid Wild offers + dup exchange; Domino: Other events largest, dup exchange from Q3; Disney: Magical Friend steady, Q4 Market/daily).
- Known: Domino 17 — First_Royal_Gift disappears for non-first-album players (40 Royals) → matches Eden's definition.
- Known: Domino 19 — non-first-album players still got 23,522 gift Royals (19% of Q1 new Royals, ~20% of veteran PU), all in Q1. Album 19 opened 07-06 = gift start ("Royal Tower Launch Gift").
- Hypothesis: at the Royal Tower launch the gift also went to part of the veterans. Needs Validation (Domino team): why only ~20% of veteran PU; targeting rule.
- Needs Validation: Disney `user_album_count` semantics (undocumented).

SQL: same as 5d in topic5_rare_sources_queries.sql plus `user_past_album_count` / `user_album_count` in rows_ and `HAVING ... AND MIN(user_past_album_count) > 0` (Dice) / `MIN(user_album_count) > 1` (Domino, Disney); Domino CASE first line `WHEN IFNULL(new_sticker_mtx_campaign_name,'') LIKE 'EV_Royal_Card_Popup%' THEN 'B0 First Royal gift'`.

