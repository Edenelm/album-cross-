# Dice end lift: album 65 added, 7+ rerun with the fixed album count (2026-10-22)

Approved by Eden (topic 1 of the data-story review). SQL: `claude/dice_end_lift_65_7plus.sql` (95 GB) + completeness check below. Project `dice-dreams-dbt`, table `50_reporting.user_daily_album`.
Population and rule = `album-length-end-arpdau-2026-10-18.md` (all players who received the album, active days, close day excluded, is_excluded removed). 7+ new = at least 6 earlier albums with a row in the album table (history from 2023-11-07); 7+ old = `user_past_album_count` >= 6.

| Album | Close | Album ARPDAU | Last-4 ARPDAU | End lift (vs whole album) | Last 4 vs rest: all | 7+ old | 7+ new | 7+ share of revenue old → new |
|---|---|---|---|---|---|---|---|---|
| 55 | | $1.09 | $1.30 | +19% | +21% | +27% | +26% | 50% → 52% |
| 57 | | $1.09 | $1.44 | +33% | +37% | +45% | +45% | 52% → 53% |
| 59 | | $1.16 | $1.37 | +18% | +20% | +18% | +19% | 53% → 55% |
| 61 | | $1.28 | $1.47 | +15% | +18% | +17% | +16% | 49% → 52% |
| 63 | 2026-09-07 | $1.32 | $1.58 | +20% | +22% | +28% | +27% | 49% → 52% |
| **65** | **2026-10-19** | **$1.31** | **$1.35** | **+3%** | **+3%** | +3% | +3% | 51% → 56% |
- Check: 55–63 reproduce `album-length-end-arpdau-2026-10-18.md` and `album-timeline-7plus-end-2026-10-19.md` (+19 / +33 / +18 / +15 / +20%). Album 53 is left out here: the query window started 2026-01-01 and cut its first days (use the earlier docs for 53: +31%).
- 7+ fix: the 7+ end lift is the same with the fixed count (within 1 point); the group is a bit larger (7+ share of revenue +2–5 points). The endlift-7 slide does not change.

## Album 65 completeness check (fact)
Album-table spend vs total game revenue (`50_reporting.user_daily_metrics_agg`), per day, 2026-10-01..10-18: within 1% every day (e.g. 10-18 $750,230 vs $756,874). Active players steady (539–552K a day in the last 4 days). The data is complete; the flat end is real.
Daily album spend, last two weeks: 10-10 Sat $835,203 · 10-11 Sun $883,023 · 10-12 Mon $779,783 · 10-13 $649,316 · 10-14 $754,772 · then the last 4 days 10-15..10-18: $718,361 / $737,769 / $725,110 / $750,230.

## Reading
- Fact: Dice 65 is the first Dice album since April 2025 without an end lift (+3% vs +9% to +33% before).
- Its strongest days were 10-10..10-12 (8–9 days before close, a weekend), not the last 4 days.
- Hypothesis (not checked): something in the album or the event calendar moved spend earlier (for example the closing-week sources in `dice-wild-sources-2026-10-21.md`: bonus wheel 8–7 days before close). Question for the Dice team: what changed in album 65's last two weeks.
- One album only; do not call it a trend.
