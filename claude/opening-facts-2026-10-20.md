# Opening sections: structure, revenue by experience, end ARPDAU by experience, denominator (2026-10-20)

SQL: `claude/opening_facts_queries.sql`. Projects: `dice-dreams-dbt`, `domino-dreams-dbt`, `solitaire-dreams-411507`.

## Deck-wide revenue denominator (Eden, 2026-10-20)
- **Total game purchase revenue during the album window** = all players' in-game purchases, album start .. close−1, cheaters / test users excluded.
  Dice `50_reporting.user_daily_metrics_agg.revenues_sum` (gross IAP) minus `20_core.dim_excluded_users`; Domino `prod_40_mart.user_daily_metrics` in-app + Stripe minus special / suspected-cheater; Disney `bi_prod.solitaire_user_daily_metrics_agg_df.gross_revenues` minus `exclude_reason`. Ad (RV) revenue shown separately.

| Game · album | Game purchase revenue | Ad revenue (separate) | Standard-population album revenue | Factor (old share × factor = new share) |
|---|---|---|---|---|
| Dice 61 | $25,342,929 | $1,676,790 | $16,986,906 | 0.67 |
| Dice 63 | $30,317,756 | $1,769,194 | $20,799,106 | 0.69 |
| Domino 19 | $17,644,426 | $419,345 | $13,554,420 | 0.77 |
| Domino 20 | $16,269,671 | $548,703 | $12,824,543 | 0.79 |
| Disney 14 | $51,554,638 | $323,224 | $40,371,383 | 0.78 |
| Disney 15 | $44,887,998 | $494,777 | $36,513,467 | 0.81 |
- Old deck shares = share of the standard population's album revenue (album-table spend, start..close−1). New share = old share × factor (exact for any population inside the standard population).

## A. Album structure (configuration: Dice `external_sources.album_stickers_profile`, Domino `prod_50_reporting.album_sticker_progression`, Disney `bi_entity_prod.album_sticker_progression`; opening day = first day ≥1,000 players got that sticker)
| | Dice (63) | Domino (20) | Disney (15) |
|---|---|---|---|
| Length | 42 days (35–49 in the year) | 49 days (39–63) | 42 days (21–49) |
| Set stickers | 144 in 12 sets | 144 in 12 sets | 144 in 12 sets |
| Common / Golden / Rare | 104 / 28 / 12 Supers | 107 / 28 / 9 Royals (album 19: 8–9) | 113 / 24 / 7 Royals |
| Rare share | 8% | 6% | 5% |
| Outside the sets | Pixie 12 | – | Magic 36 (3 sets) |
| How content unlocks | 130 open from day 0; 14 locked: 4 commons day 1–2, 7 goldens day 16–34, 3 Supers day 31–36 | 6 release phases: 65 stickers day 0, 32 by day ~8, 19 by ~19, 13 by ~24, 8 by ~34, last 7 (phase 6) day 13–24 | One phase in config; Royals open by day 1 (median), last Royal day 31; 2 goldens (141, 142) open in the last week (day 35–37) |
| End gate | 2 Supers + 1 Golden | Phase-6 stickers (2 Royals + golden / 5 goldens) | Royal 131 + 2 goldens |
| End tool | Wild (mostly paid offers) | Joker | Joker (mostly from the Market) |
| Album unlock | Kingdom 8 | Level 35 | Level 100 |

## B. September revenue by album experience (reused: `tenure-population-rerun-2026-10-17.md`; Disney from `cross-game-comparison-framework.md` Topic 2)
Aggregation: players active ≥1 day in Sept 2026, albums experienced = distinct albums started by 30 Sep (since 2025-04-01); players installed before 2025-04-01 = own row (Dice, Domino). Revenue = all in-game purchases in September.
| Experience | Dice: players / revenue | Domino: players / revenue | Disney: players / revenue |
|---|---|---|---|
| 1st album | 11% / 4% | 21% / 12% | 11% / 12% |
| 2–3 | 18% / 22% | 20% / 17% | 20% / 19% |
| 4–6 | 10% / 13% | 17% / 19% | 34% / 32% |
| 7+ | 6% / 9% | 9% / 14% | 35% / 37% |
| Installed before Apr 2025 | 55% / 53% | 33% / 38% | – (all installed since) |

## C. End-of-album ARPDAU by album experience (player's Nth album, not the album ID) — average of Dice 61/63, Domino 19/20, Disney 14/15
Rule = earlier analysis (framework Topic 2 follow-up): last 4 full days (close−4..−1) vs whole album (player's start..close−1), album-table spend ÷ active player-days.
| Experience | Dice: last-4 ARPDAU · ×album · % game rev | Domino | Disney |
|---|---|---|---|
| 1st album | $1.88 · ×1.19 · 11% | $1.00 · ×1.08 · 12% | $1.40 · ×1.02 · 11% |
| 2–3 | $2.02 · ×1.13 · 21% | $1.04 · ×1.20 · 18% | $1.04 · ×0.98 · 23% |
| 4–6 | $1.89 · ×1.20 · 11% | $1.06 · ×1.16 · 20% | $0.90 · ×1.02 · 33% |
| 7+ | $1.59 · ×1.17 · 5% | $1.14 · ×1.19 · 12% | $0.78 · ×1.04 · 30% |
| Installed before Apr 2025 | $1.29 · ×1.19 · 50% | $0.99 · ×1.20 · 36% | – |
- Fact: in Dice and Domino every experience group ends 8–20% above its album average; in Disney all groups end about flat (−2% to +4%). Disney 14 was below 1 for 1st and 2–3 (×0.97 / ×0.94), album 15 above (×1.07 / ×1.01).
- Fact: in Disney the newest players pay the most per day ($1.37 album ARPDAU in their 1st album vs $0.75 at 7+); in Dice and Domino ARPDAU is flatter by experience.
- Checks: Disney 14 1st-album players 349,528 = framework table; ratios match the framework (0.97). Shares sum to ~97–98% of game purchase revenue (rest = players without the album, unknown install).
