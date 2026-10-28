# Domino 19/20: payers and album revenue by previous-album spend (2026-10-28)
SQL: `claude/domino_prev_spend_tiers_19v20_2026-10-28.sql` (domino-dreams-dbt, 11 GB). Standard-population payers; tier = spend in the previous album (18 for 19, 19 for 20); % of the album's standard payers / album revenue.
Question: which album are the "x% rev · y% payers" labels on slide "Same Spend, Different Gate" from?

| Tier | 19 % payers | 19 % rev | 20 % payers | 20 % rev | slide label (payers / rev) |
|---|---|---|---|---|---|
| <$100 | 75.1 | 30.1 | 76.7 | 31.0 | – |
| $100–200 | 10.6 | 13.1 | 10.6 | 14.4 | 7.6 / 11.2 |
| $200–250 | 2.8 | 4.7 | 2.6 | 5.3 | 2.0 / 4.1 |
| $250–300 | 2.1 | 4.2 | 1.8 | 4.0 | 1.5 / 3.5 |
| $300–350 | 1.5 | 3.7 | 1.4 | 3.7 | 1.1 / 3.1 |
| $350–400 | 1.2 | 3.1 | 1.1 | 3.3 | 0.8 / 2.6 |
| $400–600 | 2.9 | 9.7 | 2.5 | 9.4 | 2.1 / 8.3 |
| $600–1K | 2.2 | 10.7 | 1.9 | 10.8 | 1.5 / 8.9 |
| $1K+ | 1.8 | 20.8 | 1.5 | 18.1 | 1.4 / 17.7 |

- Finding: the labels match album 19 in shape — every label is ~0.72 × the standard-payer share (payers) and ~0.85 × (revenue), steady across tiers; album 20 ratios swing 0.77–0.98. So: album 19, with a larger denominator (probably all payers / game revenue, not standard payers). Not confirmed which denominator.
