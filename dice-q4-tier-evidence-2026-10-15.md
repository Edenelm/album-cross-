# Dice — does difficulty add anything once the last-quarter tier is known? (run 2026-10-15)

Project `dice-dreams-dbt`, `50_reporting.user_daily_album`, albums 61 (35 days, checkpoint day 27) and 63 (42 days, checkpoint day 32). 5.4 GB.
Population: not excluded, not first album, album_login_ratio on last row before close ≥ 0.5 (standing rule, same as Disney/Domino), present before the checkpoint; close day excluded.
Tier = projected $/day = spend so far ÷ ONE pooled curve (other album: 0.745 for 61, 0.765 for 63) ÷ n — no difficulty involved. Reach = revenue share at close−4.
Calibration actual ÷ projected: 0.91–1.03 for tiers ≥ $1/day.

Revenue share ≤3 missing at close−4, album 61 / 63 (players in brackets):
| Difficulty | Tier ≤2 | 2–5 | 5–20 | 20–50 | >50 |
|---|---|---|---|---|---|
| Easy | 18 / 33 (94K/99K) | 30 / 42 (9.0K/8.4K) | 46 / 59 (2.4K/2.3K) | 62 / 61 (134/116) | 86 / 63 (13/21) |
| Medium | 20 / 38 (18K/19K) | 25 / 43 (16K/15K) | 36 / 51 (7.8K/6.7K) | 56 / 63 (270/250) | 71 / 64 (29/26) |
| Hard | 22 / 42 (1.5K/1.7K) | 23 / 43 (3.0K/3.7K) | 34 / 54 (7.6K/7.5K) | 48 / 60 (835/648) | 66 / 71 (53/49) |
| Extreme | 39 / 50 (197/245) | 28 / 47 (343/429) | 34 / 57 (2.3K/2.9K) | 47 / 67 (1.8K/1.9K) | 66 / 73 (642/562) |
≥10 Supers at close−4 gives the same picture (within ~3–7 points).

Reading:
- Known (album 63): at the same tier all difficulties reach within ~2–8 points (2–5: 42–47; 5–20: 51–59; 20–50: 60–67; >50: 63–73). Difficulty adds almost nothing once the tier is known.
- Known (album 61): at the same tier,