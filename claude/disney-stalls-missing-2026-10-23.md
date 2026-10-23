# Disney stalls and what payers miss at close (2026-10-23)

**Question (Eden):** (A) why the Disney 15 all-144 step line stalls (days 10–13, 26–31) — sets released in waves or events? (B) which sticker types payers are missing at close — is Disney behind on Goldens too, not only Royals?
**Population:** standard population payers (paid on any album day incl. close), all players. Dice 61/63, Domino 19/20, Disney 14/15.
**SQL:** `claude/disney_stalls_missing_2026-10-23.sql` (Disney A 33 GB, Disney A2+B 63 GB, Domino B 17 GB, Dice B 89 GB). Projects `solitaire-dreams-411507`, `domino-dreams-dbt`, `dice-dreams-dbt`.

## A. Disney 15 stalls
- **Set open day** (first album day ≥5% of payers hold a sticker of the set; my threshold, to skip a few early outliers): album 15 sets 1–10 day 1, sets 11–12 day 7; album 14 sets 1–10 day 1–2, 11 day 3, 12 day 5. Phase column = 1 for all stickers.
- **Fact:** all sets are open by day 7, so the stalls are not sets waiting to open.
- New stickers per payer per day (all sources): day 9 2.5 → day 12 0.8 → day 14 2.5 → day 16 6.8; day 25 2.6 → days 26–31 1.3–2.3 → day 32 5.2.
- **Fact:** in both stalls the event sources go quiet at the same time:

| Source (new stickers per payer) | Days 1–8 | Stall 1, days 9–13 | Days 14–19 | Stall 2, days 26–31 | Days 32–35 |
|---|---|---|---|---|---|
| Blast | days 1–3 | none | days 16–19 | none | days 33–35 |
| Mini collection | 0.5–0.6 / day | 0.01–0.05 / day | 0.2–0.4 | 0.2–0.3 | 0.25–0.3 |
| Momentum | 0.3–1.5 | 0.25 → 0.01 | 0.03 → 1.0 | 0.15–0.47 | 0.4–1.0 |
| Race | days 3–4 | none | days 16–17 | none (ended day 25) | none |
| Flytext | days 4–10 | ends day 10 | from day 19 | none | from day 35 |
| Daily reward | 0.3–1.0 | 0.17–0.25 | 0.6–0.9 at days 14–16 | 0.11–0.19 | 0.46 at day 32 |
| MTX challenge | 1.0–3.3 | 0.25–0.57 | 1.1–2.0 at days 15–16 | 0.16–0.5 | 1.0 at day 32 |
| "Enough DR" | 0.2–0.5 | ≈0 | 0.4–0.7 | ≈0 | 1.16 at day 32 |

- **Interpretation:** Disney's sticker flow comes in waves set by the event calendar: when the events between waves pause, the median payer gets almost nothing new for 4–6 days; the next wave (days 14–16, day 32) brings a jump.
- **Hypothesis (not checked):** daily reward and MTX challenge jump on the same days (14, 32) as other sources — that looks like a booster / new event start rather than players playing more. The event calendar was not checked.

## B. Missing stickers at close, average per payer (all payers)

| Album | Commons missing | Goldens missing | Rares missing (Super / Royal) | Total missing | Goldens share of the missing |
|---|---|---|---|---|---|
| Dice 61 | 1.7 of 104 | 1.6 of 28 (6%) | 3.2 of 12 (27%) | 6.5 | 24% |
| Dice 63 | 1.3 of 104 | 2.0 of 28 (7%) | 2.4 of 12 (20%) | 5.7 | 34% |
| Domino 19 | 1.1 of 107 | 4.7 of 28 (17%) | 3.8 of 9 (42%) | 9.6 | 49% |
| Domino 20 | 1.1 of 107 | 2.9 of 28 (10%) | 3.0 of 9 (33%) | 7.0 | 41% |
| Disney 14 | 0.8 of 113 | 3.9 of 24 (16%) | 2.4 of 7 (34%) | 7.1 | 56% |
| Disney 15 | 3.2 of 113 | 4.2 of 24 (18%) | 2.7 of 7 (39%) | 10.1 | 42% |

Share of payers missing at least 1: Goldens Dice 76–80%, Domino 79–90%, Disney 91–93%; rares Dice 86–89%, Domino 90–93%, Disney 92–93%. Median missing Goldens: Dice 1, Domino 3 / 1, Disney 3 / 4.

- **Fact:** Disney payers end 16–18% short on Goldens vs 6–7% in Dice and 10% in Domino 20 (Domino 19: 17%, like Disney).
- **Fact:** in Disney the Goldens are the largest part of what is missing at close (42–56%), more than the Royals.
- **Fact:** Disney 15 also leaves commons missing (3.2 on average; 29% of payers miss ≥1 common vs 13% in Disney 14 and 14–19% in Dice and Domino).
- **Interpretation:** Eden is right: Disney is behind on Goldens too. Golden pace is normal (longest wait 9–14%, same as the others); the gap is how many Goldens arrive by the end.

## Updated wording (proposal, waiting for Eden)
- Old: "The long dry stretch in Domino and Disney is a rare (Royal) issue, not a Golden issue."
- New: "Disney payers end short on both Royals and Goldens. Royals come with long waits (28–35% of the album without a new one); Goldens come at a normal pace but too few by the end — the typical payer misses 4 of 24 Goldens at close, vs 1–2 of 28 in Dice."
- New (all 144): "Disney's sticker flow comes in waves set by events: two 4–6 day lulls when events pause, then a jump when the next one starts. Dice and Domino flow steadily."
