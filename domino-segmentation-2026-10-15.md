# Domino — album segmentation from scratch (started 2026-10-15)

Question (Eden): without an agenda — how should Domino players be segmented (spend pace?), then a final recommendation per game.
Eden (2026-10-15): IGNORE the existing daily super segments. Easy/hard = based on revenue in the album that ended. Assume no content difference between easy and hard unless the data shows otherwise. Album 20 data is usable.
Project `domino-dreams-dbt`, table `prod_40_mart.user_daily_album`. Revenue = album_spent_today (gross, verified). Exclusions: special_user_flag, suspected_cheater_flag (prod_40_mart.user_daily_metrics).

## Dom1 — calendar (run 2026-10-15)
| Album | Open → close | Days | Players | Payers | Revenue (excl. close day) |
|---|---|---|---|---|---|
| 15 | 2026-01-05 → 02-16 | 42 | 1.69M | 273K | 19.1M |
| 16 | 02-16 → 04-02 | 45 | 1.79M | 295K | 22.3M |
| 17 | 04-02 → 05-11 | 39 | 1.35M | 226K | 17.1M |
| 18 | 05-11 → 07-06 | 56 | 1.27M | 242K | 22.4M |
| 19 | 07-06 → 08-24 | 49 | 1.00M | 200K | 17.4M |
| 20 | 08-24 → 10-12 | 49 | 0.90M | 176K | 16.1M |
| 21 (live) | 10-12 → 12-02 | 51 | – | – | – |
Existing columns: album_segment (easy/hard, names vary per album) and album_super_segment (ignored per Eden; note −9999 unassigned grew to ~26% of rows in albums 20–21, ~8% of album-20 revenue — data issue to flag).

## Dom3 — history $/day decision table, albums 19 / 20 (run 2026-10-15, 38.6 GB)
History = last album played (15..target−1), $/day = album spend (close day excluded) ÷ (close − open). Population: not special, not cheater, user_album_count > 1, login ratio last row ≥ 0.5, close day excluded. Reach = revenue share at ≤3 missing (144 − unique_album_stickers_lt) at close−4. Players 353K / 317K.

| History $/day | Players % | Revenue % | Same bin now | Within 1 bin | Lower now | Reach ≤3 at close−4 (19 / 20) | Hard share |
|---|---|---|---|---|---|---|---|
| 0 | 66 | 5 | 91 | 97 | – | 11 / 43 | 0% |
| ≤0.25 | 11–12 | 5 | 37 | 84–85 | 35–37 | 4 / 35 | 0% |
| 0.25–0.5 | 5 | 4 | 19–20 | 66 | 43–46 | 4 / 37 | 0% |
| 0.5–1 | 5 | 7 | 23 | 58–59 | 44–46 | 5 / 38 | 0% |
| 1–2 | 4.5 | 10 | 26–28 | 66–70 | 44–48 | 4 / 44 | 0% |
| 2–5 | 4.5–4.7 | 19–20 | 36–39 | 71–74 | 41–46 | 6 / 50 | ~1% |
| 5–10 | 2.0–2.1 | 16–17 | 31–34 | 75–78 | 48–53 | 41 / 58 | 63–84% |
| 10–20 | 1.0 | 14–15 | 33–35 | 74–79 | 50–54 | 56 / 65 | 100% |
| >20 | 0.5 | 19 | 53–55 | 78–80 | 45–47 | 69 / 71 | 100% |

Option C cuts (Disney): ≤2 / 2–5 / 5–20 / >20 → players 92 / 4.6 / 3.0 / 0.5%; revenue 31 / 19–20 / 31 / 19%; reach 19: 5 / 6 / 48 / 69, 20: 40 / 50 / 61 / 71.
Hard = 2.8–3.3% of players, 45–48% of revenue.

Same history bin, easy vs hard (reach ≤3 at close−4):
| Bin | Album 19 easy / hard | Album 20 easy / hard |
|---|---|---|
| 2–5 | 5% (15.6K) / 57% (187) | 50% (14.7K) / 61% (48) |
| 5–10 | 7% (1.1K) / 46% (6.2K) | 52% (2.4K) / 60% (4.0K) |

Reading:
- Known: hard ≈ history ≥ ~$5/day (0% hard below $2, ~1% at 2–5, 63–84% at 5–10, 100% above 10). Existing easy/hard ≈ a single cut at $5/day.
- Known: revenue concentration like Disney: players >$5/day = 3.5%, ~50% of revenue.
- Known: stability like Disney/Dice — about half of payers spend less than their history bin; fine bins unstable (19–55% exact).
- Known (FOUND A DIFFERENCE): in album 19, easy players almost never reached ≤3 missing by close−4 (4–11% revenue share at every bin, ≤2.4% of players) while hard reached 41–69%; at the SAME history bin hard reached 46–57% vs easy 5–7%. In album 20 the gradient is smooth (35 → 71%) and hard is only ~8–10 points above easy at the same bin. → In album 19 the easy and hard versions behaved like different albums (consistent with the late phase-6 Royal gate). Cause Needs Validation with the Domino team (release schedule / drop rates per version). Not causal.
- Implication: Domino's level is not only an analytics label — at least in album 19 it coincided with a different end-game for easy players.

