# Domino 17–20: revenue per active payer vs a normal weekday, last 14 days (2026-10-28)
SQL: claude/domino_end_arpdau_weekday_17_20_2026-10-28.sql (18 GB, domino-dreams-dbt). Standard-population payers. Index = day ARPDAU ÷ same-weekday average up to close−8; close day out.
| album | d−14..d−1 index | last 4 days avg |
|---|---|---|
| 17 | 1.02 1.08 1.07 1.15 1.11 0.96 1.03 1.03 1.00 0.94 1.09 0.99 1.04 1.03 | +4% |
| 18 | 1.01 0.96 0.96 1.01 1.09 1.08 1.02 1.06 1.10 1.42 1.25 1.21 1.10 1.24 | +20% |
| 19 | 1.03 0.99 1.05 1.06 1.03 1.03 1.05 1.00 0.91 0.99 1.02 1.05 1.04 1.07 | +4% |
| 20 | 0.99 1.01 1.14 1.18 1.11 1.15 1.14 1.03 1.00 0.99 1.08 1.08 1.13 1.14 | +11% |
Active payers per day ~90K (20) to ~120K (17).
- Fact: 18 and 20 lift at the end (+20%, +11%); 17 and 19 barely move (+4%).
- Caveat: 18 includes the July 4 sale (peak d−5, 1.42) — part of its lift is the sale.
- Hypothesis (Eden): albums where more payers are near FU at the end lift more (18+20 vs 17+19). Not checked here: needs share of payers at FU (141+) at close−4 per album.
Slide: dlw_slide (script claude/slide_domino_end_lift_weekday_2026-10-28.py), right after Eden's "daily rev vs weekday" slide (slide_ne9tatimndqg6jku).
