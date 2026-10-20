# Disney segmentation — Step D5b: is the pre-album level needed? (run 2026-10-15)

Question (Eden): the pre-album level (Dice Easy/Medium/Hard/Extreme analogue, set once from the last album) — is it needed at all?
Project `solitaire-dreams-411507`, same population as D5 (not special, not excluded, user_album_count > 1, login ratio last row ≥ 0.5, close day excluded); per checkpoint only players present before the checkpoint day. Albums 14 / 15. Query text: Dis5b (shown and approved in chat 2026-10-15; 36 GB) — same CTEs as Dis5, checkpoints 10/25/50/75% (days 5/11/21/32), ONE pooled curve for all payers (other album).
Target = actual album level (album $/day, cuts ≤2 / 2–5 / 5–20 / >20).
Methods: 1 history only (level from last album) · 2 current only (spend so far ÷ curve ÷ n) · 3 combined (spent so far + history pace for the rest).

| Checkpoint | Revenue correctly classified (hist / cur / comb) | Top-level (3–4) revenue caught | Top precision | Movers-up revenue caught (cur) |
|---|---|---|---|---|
| Day 5 (10%) | 56 / 54–55 / 59 | 74–76 / 73–75 / 77–79 | 58–62 / 61 / 61–65 | 47–48% |
| Day 11 (25%) | 56 / 65 / 63–64 | 74–75 / 83–84 / 81–82 | 58–62 / 71–73 / 66–69 | 56–60% |
| Day 21 (50%) | 56 / 76–77 / 73 | 73–75 / 90–91 / 87–89 | 58–62 / 81–84 / 74–78 | 70–73% |
| Day 32 (75%) | 56 / 88 / 85–86 | 73–75 / 96 / 94–95 | 58–62 / 90–91 / 87–89 | 86% |
Players correctly classified: ~92% for all methods (90% of players are level 1 anyway — not informative). Among actual level 2+: history 43–44%; current 35–37% (day 5) → 50–51% (day 11) → 82% (day 32).

Reading:
- Known: history and current spend are about equal at day 5; combined is best there by 3–5 points.
- Known: from day 11 (25% of album) current spend alone beats history clearly (+9 revenue points, +9 top-revenue points) and keeps improving; history never improves.
- Known: history misses all movers-up by definition; current spend catches about half of their revenue already at day 5.
- Known: identical picture in both albums.
- Implication: the pre-album level is useful only as a starting point for roughly the first week (and to pick nothing else — one pooled curve was used here and worked). From ~day 11, a daily tier from current spend replaces it.
- Missing: whether Disney has any per-segment album content (difficulty / rewards). If not, the level has no in-game role.
- Not causal.

Options (Eden to decide):
1. Drop the level; daily tier from day ~11; first ~10 days everyone treated the same.
2. Level as a starting prior only: days 0–10 use combined (history + spend so far); from day 11 current spend only; goals by tier only (recommended by data).
3. Keep full Dice structure (level × tier).

