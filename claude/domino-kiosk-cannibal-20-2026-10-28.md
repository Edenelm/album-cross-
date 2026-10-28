# Domino 20: did GoldenKiosk replace Golden purchases? (2026-10-28)
SQL: claude/domino_kiosk_cannibal_20_2026-10-28.sql (12.8 GB, domino-dreams-dbt). Standard-population payers album 20. Kiosk user = got a new Golden from GoldenKiosk on d−7..d−5.
Spend per day: pre d−14..d−8, Kiosk window d−7..d−5, end d−4..d−1 (close day out). Tiers by pre spend/day, fixed before the Kiosk. % rev = share of album revenue (open..close−1).

| Pre tier | Kiosk | Payers | % album rev | $/day pre | $/day Kiosk days | $/day end | Kiosk days ÷ pre | End ÷ pre | Bought a new Golden in Kiosk days |
|---|---|---|---|---|---|---|---|---|---|
| $0 | no | 37,906 | 12% | 0.00 | 0.27 | 0.67 | – | – | 3% |
| $0 | yes | 12,675 | 5% | 0.00 | 1.23 | 1.30 | – | – | 8% |
| <$2 | no | 23,400 | 8% | 0.81 | 0.59 | 1.08 | 0.73 | 1.33 | 3% |
| <$2 | yes | 7,129 | 4% | 0.83 | 2.02 | 1.85 | 2.44 | 2.24 | 6% |
| $2–20 | no | 17,349 | 30% | 6.23 | 3.03 | 5.04 | 0.49 | 0.81 | 5% |
| $2–20 | yes | 5,550 | 13% | 6.26 | 9.03 | 7.71 | 1.44 | 1.23 | 14% |
| $20+ | no | 1,978 | 18% | 40.22 | 16.47 | 25.13 | 0.41 | 0.62 | 11% |
| $20+ | yes | 775 | 10% | 44.74 | 51.54 | 40.13 | 1.15 | 0.90 | 25% |

- Fact: at every spend level, Kiosk users spent MORE on the Kiosk days than their own pre level (×1.15 to ×2.44), while non-users dropped (×0.41 to ×0.73). Kiosk users also bought a new Golden 2–3× as often in those days. Same direction in the last 4 days.
- Not supported: "the Kiosk replaced Golden purchases". The data point the other way.
- Caveat: no control group. Players who chose the Kiosk were more engaged at that moment (pre spend is equal, but intent is not). The spend jump suggests the Kiosk itself may cost money or be tied to a purchase — not checked (need the Kiosk's price / currency from the Domino team).
- Size: Kiosk users 26,129 = 24% of payers, 32% of album revenue.
