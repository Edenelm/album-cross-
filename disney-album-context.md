# Disney Solitaire Album — Context (added by Eden, 2026-10-07)

Source docs in project: "Daily Album Report - Disney", "DISENY ANAYSIS " (two copies, same content).

## Live dashboard
- Looker 1862 — Daily Album Report (Disney): https://superplay.cloud.looker.com/dashboards/1862?Album+ID=15&Special+User+Flag+%28Yes+%2F+No%29=No&Login+Ratio=%5B0.5%2C1%5D&User+Login+Ratio=%5B0%2C1%5D&Date+Dim+Date=after+2026%2F08%2F24&Is+Finisher+%28Yes+%2F+No%29=Yes%2CNo
- Saved filters: Album ID 15, Special User = No, Login Ratio 0.5–1, User Login Ratio 0–1, Date after 2026-08-24, Is Finisher = Yes, No.

## Past analyses (Google Slides)
- Albums 3, 4, 5, 6 deep dive: https://docs.google.com/presentation/d/1UHcifjSik4nl4FQRP68bw6YNwFw_4gvo8ldDWDw1YJ4/edit
- Albums 9 & 10 short summary: https://docs.google.com/presentation/d/1Hy-69F_TEobot7STNhjumYIbC-hwuOek7TyS6fVw25Y/edit
- Album 8: https://docs.google.com/presentation/d/1XYjcccNi96_i_oNstQHfXxYLgNCvqYHYotaNObrysA8/edit
- Album 7: https://docs.google.com/presentation/d/1HzORLmzMLEek3PKgflrNOpoauxxNNrkrN7QyTfrv6gM/edit
- Album 1 (from Domino onboarding guide): https://docs.google.com/presentation/d/1ijsHTD53q50aAX7MkD5gunJuemLY9xvUK8g2ZzymXzQ/edit

## Config & tests
- Album configuration sheet (set structure, sticker / set numbering): https://docs.google.com/spreadsheets/d/1m950ZROvGu4xbISHuBE4C9vtuS6WiRwEoWe-yZefjGk/edit
- Potion bonus test (still live): https://mixpanel.com/s/2HuEgv
- Legendary Set test analysis: https://docs.google.com/presentation/d/1eQVrW24bW9gZd4axM_KDQ2Mop4yzLZN9raDPfrKKFrI/edit
- Early album-end test: aborted, no analysis. Dashboard link given is the SAME URL as the Legendary Set deck — likely a copy error; correct link still needed.

## Data
- Project: solitaire-dreams-411507 (confirmed by Eden 2026-10-07). No numbered dbt layers; curated datasets are bi_prod / ba_prod.
- Main table: `solitaire-dreams-411507.bi_prod.user_daily_album` — user × album × day, ~905M rows, partitioned by date_dim, clustered by album_id, album_segment.
  - Population: special_user_flag, login_ratio, user_login_ratio, login_ratio_filter (STRING), active_flag, active_day_in_album, album_open_date, album_close_date, user_album_start_date.
  - Revenue: album_spent_today, album_spent_lt.
  - Completion: album_finished_flag, album_finish_date, is_Nth_set_completed_flag (1–20), is_Nth_set_completed_by_joker_flag.
  - Tiers: common_*, royal_* (unique_royal_stickers_tl, missing_royal_stickers_today), golden_* (unique_golden_stickers_lt, missing_golden_stickers_today); jokers: number_of_jokers_today/_lt.
  - Note: column naming mirrors Domino's user_daily_album (incl. the `_tl` typo on royal).
- Album structure (albums 14 & 15): 12 regular sets (album_max_regular_set = 12), 144 unique stickers (12 × 12) — same shape as Dice. Max unique Royals observed = 7 per album (→ likely 7 Royal stickers per album).
- Data quirk: ~10% of album_finished_flag users end with < 144 unique stickers (14: 2,521; 15: 2,329), mostly at 142–143. To ask BI (joker completion?).
- Other candidate: ba_prod.disney_user_day_enriched (not opened).

### Login-ratio columns (verified 2026-10-07, album 15, date_dim 2026-09-20 — exact match on all rows)
- `login_ratio` = active_day_in_album ÷ day_in_album (from album open; cumulative to date, changes daily).
- `user_login_ratio` = active_day_in_album ÷ day_in_album_by_user_start (from user's own start; lenient to late joiners — 77% of rows that day were late joiners).
- `login_ratio_filter` = text bucket of login_ratio: "greater than 0.5" (≥0.5) / "greater than 0" (<0.5).
- `active_day_in_album` matches COUNT(DISTINCT active_flag days) for every user in albums 14–15 (0 mismatches).

## Album calendar (user_daily_album, date_dim >= 2026-04-01, special_user_flag = FALSE; run 2026-10-07)
| album | open | close | days | users (unfiltered) |
|---|---|---|---|---|
| 10 | 2026-02-16 | 2026-04-06 | 50 | 3.17M (partial, date filter) |
| 11 | 2026-04-06 | 2026-05-11 | 36 | 2.76M |
| 12 | 2026-05-11 | 2026-06-22 | 43 | 2.85M |
| 13 | 2026-06-22 | 2026-07-13 | 22 | 2.26M |
| 14 | 2026-07-13 | 2026-08-24 | 43 | 2.44M |
| 15 | 2026-08-24 | 2026-10-05 | 43 | 2.14M |
| 16 | 2026-10-05 | 2026-11-16 | 43 | 1.21M (live) |
- close date = next album's open date (changeover day shared, like Dice).
- Album 13 only 22 days — possibly the aborted early-album-end test (unconfirmed).

## Decisions
- (2026-10-07) Disney's Super/Royal equivalent = **Royal** (unique_royal_stickers_tl). Golden treated as a separate tier.
- (2026-10-07) Benchmark albums = **14 & 15** (both 43 days). Album 15 closed 2026-10-05 — recheck last-day data settled before locking numbers.
- (2026-10-07) Engaged = per-user, fixed, same as Dice & Domino: MAX(active_day_in_album) ÷ (close − open + 1) ≥ 0.5 (= end-of-album login_ratio). Not row-level.
- (2026-10-07) Revenue = SUM(album_spent_today). Payer = SUM(album_spent_today) > 0 in album window.
- (2026-10-07) ARPDAU = engaged revenue ÷ engaged active_flag user-days. Full = whole album incl. close day; Final = close−3 … close−1 (14: Aug 21–23; 15: Oct 2–4).
- (2026-10-07) Report template (Eden, from Dice report): Scorecard, Where players stop, End state, Last 7 days, Players who got the last 3 stickers.
  - Last 7 days = close−7 … close−1. "Got the 3 stickers" = users missing 1–3 stickers at end of close−8 (not finished) who finished by close.
  - Report is run twice: all engaged players (#3) and engaged payers only (#4, payer = SUM(album_spent_today) > 0).
  - (Eden) "Where players stop" also by uneven sticker bins on final unique stickers: 1–36, 37–72, 73–108, 109–132, 133–141, 142, 143, 144 (#5).
  - (Eden) Scorecard includes "Median day of first royal" next to "Median day of first set" (first day_in_album with unique_royal_stickers_tl ≥ 1, among users who got one).
- Filters: album_id IN (14,15), date_dim 2026-07-13 → 2026-10-05, special_user_flag = FALSE.

## Results log
### #1 Population sizing (2026-10-07)
| | Album 14 | Album 15 |
|---|---|---|
| Users in table | 2,444,023 | 2,141,794 |
| Engaged (≥0.5) | 1,288,472 (52.7%) | 1,126,616 (52.6%) |
| Engaged payers | 408,921 (31.7%) | 345,264 (30.6%) |
| Engaged revenue | $44.82M | $39.39M |
| Engaged finishers | 25,710 (2.0%) | 21,431 (1.9%) |

### #2 ARPDAU / finishers (2026-10-07)
| | Album 14 | Album 15 | Dice 61 / 63 |
|---|---|---|---|
| ARPDAU full | $0.929 | $0.927 | $1.346 / $1.401 |
| ARPDAU final 3 days | $0.941 (+1%) | $0.980 (+6%) | $1.584 / $1.741 (+18% / +24%) |
| Finishers % of engaged | 2.0% | 1.9% | 4.85% / 5.81% |
| Payers who finished | 5.8% | 5.9% | 11.6% / 13.6% |
| Finishers' revenue share | 23.3% | 25.5% | 30.8% / 34.0% |

### #3 Full report — all engaged players (2026-10-07)
Scorecard
| Metric | 14 | 15 |
|---|---|---|
| Players | 1,288,472 | 1,126,616 |
| Completion | 2.0% | 1.9% |
| Avg sets / median | 6.69 / 7 | 6.40 / 7 |
| ≥1 / ≥3 / ≥6 / ≥9 sets | 99.6 / 94.6 / 69.6 / 26.2% | 99.3 / 93.2 / 66.3 / 20.4% |
| 11 sets, not finished | 2.7% | 1.3% |
| Payer rate | 31.7% | 30.6% |
| Spend / per player / per payer | $44.82M / $34.79 / $109.61 | $39.39M / $34.96 / $114.08 |
| Finishers' spend share | 23.3% | 25.5% |
| Avg active days | 37.4 | 37.7 |
| Median day first set | 5 | 3 |
| Median day first royal | 7 | 10 |
| Got ≥1 royal / median royals at end (of 7) | 95.1% / 4 | 93.6% / 3 |
| Median finish day | 42 | 42 |

Where players stop (share / payer rate / spend share)
| Progress | 14 | 15 |
|---|---|---|
| 0–25% (<3) | 5.4% / 6.8% / 0.2% | 6.8% / 6.8% / 0.2% |
| 25–50% (3–5) | 25.0% / 15.3% / 2.1% | 26.9% / 16.3% / 3.2% |
| 50–75% (6–8) | 43.5% / 30.6% / 20.8% | 45.9% / 29.0% / 17.4% |
| 75–99% (9–11) | 24.2% / 51.4% / 53.7% | 18.5% / 57.7% / 53.6% |
| Finished | 2.0% / 92.0% / 23.3% | 1.9% / 94.9% / 25.5% |

End state (share / payer rate / spend share)
| End state | 14 | 15 |
|---|---|---|
| Finished | 2.0% / 92.0% / 23.3% | 1.9% / 94.9% / 25.5% |
| 1 sticker left | 1.1% / 73.2% / 6.9% | 0.7% / 84.2% / 6.3% |
| 2–3 left | 7.8% / 63.8% / 28.9% | 5.0% / 78.1% / 27.8% |
| 11 sets, >3 short | 0.1% / 60.5% / 0.4% | 0.05% / 76.5% / 0.3% |
| Farther back | 88.9% / 27.0% / 40.6% | 92.4% / 26.3% / 40.1% |

Last 7 days (close−7 … close−1)
| Metric | 14 | 15 |
|---|---|---|
| Share of album spend | 14.9% | 15.0% |
| Share of finishers who finished in those 7 days | 71.6% | 78.4% |
| Avg daily actives | 1,083,500 | 951,944 |
| Actives as share of players | 84.1% | 84.5% |

Players who got the last 3 stickers (missing 1–3 entering last 7 days)
| Metric | 14 | 15 |
|---|---|---|
| Users missing 1–3 | 18,772 | 26,591 |
| Got them (finished) | 25.5% | 23.4% |
| Paid in last 7 days | 75.0% | 70.9% |

### #4 Full report — engaged PAYERS only (2026-10-07)
Scorecard
| Metric | 14 | 15 |
|---|---|---|
| Payers | 408,921 | 345,264 |
| Completion | 5.8% | 5.9% |
| Avg sets / median | 8.0 / 8 | 7.8 / 8 |
| ≥1 / ≥3 / ≥6 / ≥9 sets | 99.99 / 98.8 / 86.8 / 44.9% | 99.96 / 98.5 / 84.2 / 40.7% |
| 11 sets, not finished | 5.9% | 3.5% |
| Spend | $44.82M | $39.39M |
| Spend per payer (avg / median) | $109.61 / $29.91 | $114.08 / $29.21 |
| Finishers' spend share | 23.3% | 25.5% |
| Avg active days | 38.1 | 38.4 |
| Median day first set | 4 | 2 |
| Median day first royal | 7 | 9 |
| Got ≥1 royal / median royals at end (of 7) | 98.1% / 5 | 97.1% / 4 |
| Median finish day | 42 | 42 |

Where payers stop (share / spend per payer / spend share)
| Progress | 14 | 15 |
|---|---|---|
| 0–25% (<3) | 1.2% / $13.67 / 0.2% | 1.5% / $17.58 / 0.2% |
| 25–50% (3–5) | 12.0% / $19.50 / 2.1% | 14.3% / $25.48 / 3.2% |
| 50–75% (6–8) | 41.9% / $54.28 / 20.8% | 43.5% / $45.63 / 17.4% |
| 75–99% (9–11) | 39.1% / $150.48 / 53.7% | 34.8% / $175.96 / 53.6% |
| Finished | 5.8% / $440.75 / 23.3% | 5.9% / $494.12 / 25.5% |

End state (share / spend per payer / spend share)
| End state | 14 | 15 |
|---|---|---|
| Finished | 5.8% / $440.75 / 23.3% | 5.9% / $494.12 / 25.5% |
| 1 sticker left | 2.6% / $287.21 / 6.9% | 2.0% / $361.44 / 6.3% |
| 2–3 left | 15.7% / $200.97 / 28.9% | 12.7% / $250.70 / 27.8% |
| 11 sets, >3 short | 0.2% / $242.79 / 0.4% | 0.1% / $248.14 / 0.3% |
| Farther back | 75.7% / $58.86 / 40.6% | 79.3% / $57.62 / 40.1% |

Last 7 days
| Metric | 14 | 15 |
|---|---|---|
| Share of album spend | 14.9% | 15.0% |
| Share of finishers who finished in those 7 days | 72.5% | 78.1% |
| Avg daily active payers | 354,378 | 301,208 |
| As share of payers | 86.7% | 87.2% |

Payers who got the last 3 stickers
| Metric | 14 | 15 |
|---|---|---|
| Payers missing 1–3 entering last 7 days | 17,684 | 24,746 |
| Got them (finished) | 26.6% | 24.8% |
| Paid in last 7 days | 79.6% | 76.2% |

### #5 Where players stop — by sticker bins (final MAX(unique_album_stickers_lt); 2026-10-07)
All engaged (share / payer rate / finished / spend per player / spend share)
| Stickers | 14 | 15 |
|---|---|---|
| 0 | 4 users | 4 users |
| 1–36 | 0.1% / 2.6% / 0.1% / $0.87 / 0.0% | 0.2% / 2.2% / 0.1% / $0.56 / 0.0% |
| 37–72 | 0.6% / 2.7% / 0.1% / $0.65 / 0.0% | 1.6% / 2.9% / 0.0% / $0.59 / 0.0% |
| 73–108 | 4.4% / 7.5% / 0.0% / $1.72 / 0.2% | 10.6% / 10.9% / 0.0% / $2.88 / 0.9% |
| 109–132 | 28.8% / 16.8% / 0.0% / $4.97 / 4.1% | 34.1% / 19.9% / 0.0% / $6.79 / 6.6% |
| 133–141 | 60.8% / 36.8% / 0.1% / $31.76 / 55.5% | 49.8% / 38.7% / 0.1% / $37.26 / 53.0% |
| 142 | 2.3% / 68.5% / 1.7% / $162.67 / 10.9% | 1.3% / 83.8% / 3.1% / $246.95 / 8.9% |
| 143 | 1.2% / 74.5% / 7.6% / $224.51 / 7.9% | 0.8% / 85.4% / 11.5% / $321.08 / 7.5% |
| 144 | 1.8% / 92.2% / 99.9% / $411.25 / 21.3% | 1.7% / 95.2% / 99.9% / $474.18 / 23.0% |

Payers only (share / finished / spend per payer / spend share)
| Stickers | 14 | 15 |
|---|---|---|
| 1–36 | 0.0% / 0.0% / $32.96 / 0.0% | 0.0% / 0.0% / $25.69 / 0.0% |
| 37–72 | 0.1% / 1.6% / $24.43 / 0.0% | 0.2% / 0.4% / $20.32 / 0.0% |
| 73–108 | 1.0% / 0.3% / $22.86 / 0.2% | 3.8% / 0.2% / $26.38 / 0.9% |
| 109–132 | 15.2% / 0.1% / $29.66 / 4.1% | 22.2% / 0.1% / $34.07 / 6.6% |
| 133–141 | 70.6% / 0.2% / $86.27 / 55.5% | 62.9% / 0.3% / $96.17 / 53.0% |
| 142 | 5.0% / 2.2% / $237.37 / 10.9% | 3.4% / 3.5% / $294.65 / 8.9% |
| 143 | 2.9% / 9.3% / $301.31 / 7.9% | 2.3% / 12.8% / $376.14 / 7.5% |
| 144 | 5.2% / 99.9% / $445.86 / 21.3% | 5.3% / 99.9% / $498.04 / 23.0% |

- 133–141 stickers = 61% / 50% of players (71% / 63% of payers) and ~54% of spend, yet median sets is only 7 → players hold 92–98% of stickers but are missing ~1 sticker in many sets. Supports "one rare per set is the blocker" hypothesis.

Key findings
- Completion is back-loaded: median finish day 42 of 43; 72–78% of finishers finish in the last 7 days.
- Near-misses are the money: 1–3 stickers short at close = 8.9% / 5.7% of players (18.3% / 14.7% of payers) but ~35% / 34% of spend.
- Near-miss payers spend $200–360 each yet don't finish; finishers spend $440–494.
- ~94% of near-miss users entering last week are payers; ~78% of them pay again in the last week, only ~25% finish → paying but blocked. Hypothesis: last stickers are Royal (not sold). Next: check missing_royal_stickers_today for near-miss users.
- Royals: first royal arrives day 7–10 (median), 2–7 days after first set; median player ends with 3–4 of 7 royals (payers 4–5). Album 15 royals came ~3 days later than album 14.

## Open
- Sanity-check engaged revenue vs a known Disney revenue source.
- album_finished_flag users with < 144 stickers (~10% of finishers) — ask BI.
- Confirm 7 Royals per album in config sheet.
- Correct link for the early-album-end test dashboard; is album 13 the early-end test?

