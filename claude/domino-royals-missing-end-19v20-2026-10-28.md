# Domino 19 vs 20: Royals missing at the end, with revenue share (2026-10-28)
SQL: `claude/domino_royals_missing_end_19v20_2026-10-28.sql` (domino-dreams-dbt, 7.7 GB). Standard-population payers; Royals missing (of 9) at the end of close−1 (lifetime counter in user_daily_album); album rev = spend before the close day.

| Royals missing | 19 payers | % payers | % album rev | 20 payers | % payers | % album rev |
|---|---|---|---|---|---|---|
| 0 | 7,057 | 6% | 26% | 9,336 | 9% | 32% |
| 1 | 6,871 | 6% | 12% | 5,847 | 5% | 10% |
| 2 | 32,364 | 27% | 35% | 43,906 | 41% | 44% |
| 3+ | 72,909 | 61% | 28% ($3,751,897) | 47,673 | 45% | 15% ($1,894,654) |
| total | 119,201 | | $13,554,420 | 106,762 | | $12,824,543 |

- Fact: 3+ Royals missing at the end = 61% of payers / 28% of album rev in 19, 45% / 15% in 20.
- Fact: "exactly 2 missing" is the biggest revenue group in both (35% / 44% of rev) — stands out vs 1 missing (12% / 10%). Hypothesis (not checked): 2 = the gate Royals; check which Royals are missing.
- Revenue share is context for the group, not money to be won.
- Slide: jk1920_slide (after dxjk): Domino 19 vs 20 Joker panels + these 3+ labels. Script/requests: claude/slide_domino_jk19v20_panels_2026-10-28.py.
