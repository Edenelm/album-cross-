# Topic 4: where finishers' last stickers came from (bought / Market / free), 2026-10-22

**Status: not used (Eden, 2026-10-22).** Players can buy other offers and then get the sticker from gameplay, so sticker source does not show who paid. Also the Dice "bought" rule here includes `Pricing_CP` / `Pricing_DDJ`, which are not purchases (see `golden-purchase-revenue-2026-10-22.md`).

SQL: `topic4_market_split_{disney,domino,dice}.sql` (run 2026-10-22; scans: Disney 73 GB, Domino 31 GB, Dice 132 GB).

## Definitions
- **Population:** finishers (144 unique set stickers by end of close day) in the standard population (not first album, not excluded, login ratio ≥ 0.5 on the last row before close, row on close−1), payers (spent on any album day).
- **Group** = stickers missing on close−4 (last state in days 8–4): 1–3 / 4–6 / 7–10. Each player once.
- **New stickers** = first copy of a set sticker collected from close−3 to the player's finish day (post-finish days not counted).
- **Source** of each new sticker (first copy):
  - Dice: bought = `sticker_pack_key LIKE 'Pricing%'`.
  - Domino: bought = the validated campaign rule (t_Offer / t_Store / ActivePassToGetJoker / source purchase or 1+).
  - Disney: bought = `new_sticker_source` purchase / purchase_gift. Market = `marketplace` (Eden: a separate group).
  - Free = everything else.
- Albums: Dice 61/63 (`dice-dreams-dbt`), Domino 19/20 (`domino-dreams-dbt`), Disney 14/15 (`solitaire-dreams-411507`).

## Results: share of new stickers by source (albums side by side)
| Game | Group | Finishers | New / player | Bought | Market | Free | % players with ≥1 bought | % with ≥1 Market | % all free |
|---|---|---|---|---|---|---|---|---|---|
| Dice | 1–3 | 6,863 / 11,853 | 2.3 | 80% / 86% | – | 20% / 15% | 96% / 97% | – | 4% / 3% |
| Dice | 4–6 | 7,446 / 8,019 | 4.7 | 48% / 56% | – | 52% / 44% | 94% / 100% | – | 6% / 1% |
| Dice | 7–10 | 2,167 / 1,156 | 8.0 | 33% / 36% | – | 67% / 64% | 94% / 100% | – | 6% / 0% |
| Domino | 1–3 | 1,961 / 4,868 | 2.2 | 17% / 12% | – | 83% / 88% | 33% / 24% | – | 67% / 76% |
| Domino | 4–6 | 3,568 / 2,877 | 4.8 | 11% / 9% | – | 89% / 91% | 39% / 36% | – | 61% / 64% |
| Domino | 7–10 | 852 / 808 | 8.0 | 7% / 7% | – | 93% / 93% | 37% / 44% | – | 63% / 56% |
| Disney | 1–3 | 10,189 / 8,295 | 2.6 | 42% / 46% | 25% / 20% | 34% / 34% | 69% / 75% | 59% / 47% | 6% / 7% |
| Disney | 4–6 | 7,239 / 5,761 | 4.7 | 22% / 27% | 22% / 23% | 56% / 50% | 68% / 74% | 86% / 82% | 2% / 1% |
| Disney | 7–10 | 1,560 / 1,513 | 7.9 | 17% / 19% | 16% / 22% | 67% / 59% | 72% / 78% | 93% / 96% | 1% / 0% |

## Checks
- New stickers per player ≈ the group's missing count (2.3 / 4.7 / 8.0), as expected: finishers had to collect exactly what was missing on close−4.
- Market is 0 in Dice and Domino by design (Market split exists only in Disney).

## Fact / interpretation
- **Fact:** In Dice almost every late finisher bought (94–100%), and bought stickers are 80–86% of the last stickers of players who were 1–3 away. In Domino most late finishers (56–76%) finished with free stickers only; bought stickers are 7–17%. In Disney, bought + Market cover 66% of the last stickers of players 1–3 away and 33–41% of players 7–10 away; almost nobody finished all-free (0–7%).
- **Fact:** In all three games the farther the player was, the larger the free share of the new stickers (more stickers come from normal play over 4 days).
- **Interpretation (not tested):** the "bought" rules differ by game (pack key / campaign rule / source field), so levels across games are not fully comparable; the direction within each game is.
