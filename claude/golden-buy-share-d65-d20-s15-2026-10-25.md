# Share of active payers who bought a new Golden, last 10 days — Dice 65, Domino 20, Disney 15 (2026-10-25)

Eden: rerun deck slide "Share of Active Payers Who Bought a New Golden, per Day, Last 10 Days" (was Dice 63 / Domino 19 / Disney 14) on Dice 65, Domino 20, Disney 15.
Definition (unchanged): active payers that day (paid on any album day, active that day) / of them, players who got a bought new Golden that day (first receipt of a Golden set sticker from a paid source; Dice Pricing% without CP/DDJ, Domino validated campaign rule, Disney purchase / purchase_gift). Days 10..1 before close. SQL: `golden_buy_share_d65_d20_s15_2026-10-25.sql` (Dice 9 GB, Domino 11 GB, Disney 35 GB).

| Days before close | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 |
|---|---|---|---|---|---|---|---|---|---|---|
| Dice 65 (`dice-dreams-dbt`) | 4.9% | 5.4% | 4.3% | 4.9% | 4.2% | 4.7% | 4.8% | 3.7% | 3.3% | 3.5% |
| Domino 20 (`domino-dreams-dbt`) | 4.3% | 4.2% | 2.8% | 2.7% | 2.8% | 2.3% | 3.8% | 4.3% | 3.7% | 3.3% |
| Disney 15 (`solitaire-dreams-411507`) | 1.3% | 2.0% | 2.2% | 1.1% | 2.0% | 2.9% | 2.6% | 3.7% | 4.6% | 5.5% |

Active payers per day: Dice 209–216K, Domino 114–117K, Disney 332–340K.
Top offers: Dice — "Pricing_Specific_*" (pick a specific sticker) every day, plus G2G and C4P; Domino — 8Box / 6Box offers and 1+N album offers; Disney — big offers drive the days: 1+3 Golden Deal (d−2: 6,171 buyers, d−1: 3,588), 1+2 Album (d−1: 6,595), 1+15 (d−8, d−4, d−1), 1+9 Anniversary (d−5).

- Fact: Dice 65 is steady at 3–5% a day (specific-sticker buy every day) and dips a little in the last 3 days (3.3–3.7%).
- Fact: Disney 15 is low (1–3%) until 5 days before close, then rises with big Golden offers to 5.5% on the last day — the highest of the three on the last 3 days.
- Fact: Domino 20 is 2–4%, with a dip 8–5 days before close.
- Compared with the old slide (Dice 63 / Domino 19 / Disney 14): Disney 14 peaked early (d−9, 1PO Triple Anniversary) and dipped to ~1% at d−6; Disney 15 peaks at the very end. Dice 63 rose toward the end; Dice 65 falls slightly.
- Interpretation: the "Disney goes up and down with the offer of the day" reading holds (1.1% to 5.5%); "Dice steady" holds. Which days are strong in Disney depends on that album's offer calendar.
