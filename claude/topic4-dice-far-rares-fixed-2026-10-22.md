# Topic 4: Dice far middle payers — last new rare vs gate open, fixed population (2026-10-22)

**Why:** slide "In Disney, Far Payers Stop Getting Rares a Week Before the Gate Opens" used the old Dice population (`user_past_album_count > 0`).
**Only change:** "not first album" = has a row in an earlier album of `user_daily_album` (history from 2023-11-01). Everything else = MidDice (`middle-payers-stall-2026-10-15.md`); added one column: revenue-weighted days before close of the last new rare.
**SQL:** `claude/topic4_middice_fixed_2026-10-22.sql`. Project `dice-dreams-dbt`, table `50_reporting.user_daily_album`; scan 118 GB.
**Population:** standard (not first album, not excluded, login ratio ≥ 0.5 on the last row before close, active before the last quarter); middle payers = P50–95 of spend before the last quarter; far = 4+ missing on the last row before close. Revenue = album spend to close−1. Game revenue: 61 $25,341,918 · 63 $30,302,561.

| Dice far middle payers (P50–95, 4+) | 61 | 63 |
|---|---|---|
| Players | 39,324 | 23,793 |
| Revenue | $3.75M | $2.56M |
| **Share of game revenue** (slide said 10%) | **15%** | **8%** |
| Last new rare, days before close (revenue-weighted) | 3.4 | 4.7 |
| Wild can fill the gate (studio: sale from 7 days) | 7 | 7 |
| **Days between last new rare and gate open** | **0** | **0** |
| Active on days after last new rare | 52% | 38% |
| Share of their revenue spent after last new rare | 1% | 1% |

By group (61 / 63): P50–80 last new rare 3.1 / 4.3 days before close, P80–95 3.7 / 5.0; active after 53% / 40% and 52% / 36%.

- **Fact:** Dice stays at 0 days: far middle payers still get new rares until 3–5 days before close, after the Wild opens at 7.
- **Change:** share of game revenue 10% → 15% (61) / 8% (63), same as the topic-2 rerun C. Active after last rare: album 61 52% (old ~51%); album 63 lower, 38%.
- Disney / Domino not rerun (their populations did not change).
