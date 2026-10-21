# All players by number of albums seen (Sept 2026), 2026-10-21

Question (Eden): the "albums experienced" slide puts players installed before Apr 2025 in one grey bucket. How many albums did they see? Show all players by number of albums.

Population and definitions: unchanged from tenure-population-rerun-2026-10-17 (players active in Sept 2026, at least one album started by 30 Sep, excluded users removed). Revenue = Sept 2026 in-game revenue. Only change: albums are counted over the whole `user_daily_album` history, not from 2025-04-01. SQL: `albums-all-players-2026-10-21.sql`.

History limit (fact, from the data): Dice album history starts 2023-11-07 (at most 21 albums visible); Domino starts 2024-06-10 (at most 15). Players who were playing before those dates saw more albums than shown: their count is a floor. Domino `user_album_count` equals the history count for 98–99% of players, so it does not go further back.

Check: the post-Apr-2025 rows match the 2026-10-17 numbers (Dice 1st album 109,626 players / $803,454; Domino totals $9.52M).

## Dice (`dice-dreams-dbt`) — 960,644 players, $20,279,833
| Albums seen | Players | Share of players | Revenue | Share of revenue | Installed before Apr 2025 |
|---|---|---|---|---|---|
| 1 | 124,171 | 13% | $851,368 | 4% | 12% |
| 2–3 | 202,154 | 21% | $4,796,169 | 24% | 16% |
| 4–6 | 124,879 | 13% | $3,029,021 | 15% | 27% |
| 7–12 | 110,196 | 11% | $2,399,029 | 12% | 54% |
| 13–21 (history max) | 399,244 | 42% | $9,204,246 | 45% | 98% |

## Domino (`domino-dreams-dbt`) — 833,158 players, $9,516,272
| Albums seen | Players | Share of players | Revenue | Share of revenue | Installed before Apr 2025 |
|---|---|---|---|---|---|
| 1 | 181,045 | 22% | $1,121,403 | 12% | 3% |
| 2–3 | 177,194 | 21% | $1,684,812 | 18% | 7% |
| 4–6 | 161,284 | 19% | $1,994,853 | 21% | 14% |
| 7–12 | 172,246 | 21% | $2,524,391 | 27% | 56% |
| 13–15 (history max) | 141,389 | 17% | $2,190,813 | 23% | 100% |

Disney (`solitaire-dreams-411507`): unchanged (no pre-Apr-2025 bucket; uses `user_album_count`).

Interpretation: most of the old grey bucket are long-tenure players (Dice: 390K of 529K are at 13+), but some returned after a break and show only 1–6 albums in the history. "1 album" for an old installer = first album seen in the history, not their first album ever.
