# Revenue from Golden purchases in the last 10 days before close (2026-10-22)

**Question (Eden):** in the last 10 days, how much revenue came from Golden purchases? Any route counts (pack, specific-sticker offer, bought Wild / Joker).
**SQL:** `claude/golden_purchase_revenue_2026-10-22.sql` (Dice corrected version below). Scans: Dice 19 GB, Domino 21 GB, Disney 54 GB, Dice check 10 GB.
**Scope:** all players (same as the goldens-week slide), days 10–1 before close (close day out). Albums Dice 61/63, Domino 19/20, Disney 14/15.
**Bought Golden** = first copy of a Golden set sticker from a paid source. Dice: pack key `Pricing%` **except `Pricing_CP` and `Pricing_DDJ`** (see check). Domino: validated campaign rule. Disney: purchase / purchase_gift (Market not counted).
**Revenue:** no ID links a purchase to a sticker, and one purchase can hold coins, rolls and several stickers, so these are revenue of purchases that gave a Golden, not the price of the Golden:
- *10-min* = purchases followed by a bought new Golden within 10 minutes (Dice, Domino; Disney has no purchase timestamps).
- *same day* = all purchases of the player on a day they got a bought Golden (all games; upper bound).
Denominator = all purchase revenue in the same 10 days (Dice `20_core.purchase_completed_vw`, Domino `prod_20_core.core_purchase`, Disney `bi_prod.fact_purchase_channels`).

## Results
| Album | Revenue, 10 days | Payers | Golden buyers (% of payers) | 10-min revenue (% of 10-day revenue) | Same-day revenue (%) |
|---|---|---|---|---|---|
| Dice 61 | $7.92M | 190,935 | 68,613 (36%) | $1.33M (**17%**) | $2.12M (27%) |
| Dice 63 | $7.79M | 173,370 | 65,647 (38%) | $1.54M (**20%**) | $2.39M (31%) |
| Domino 19 | $3.69M | 94,234 | 39,887 (42%) | $0.57M (**15%**) | $1.00M (27%) |
| Domino 20 | $3.71M | 91,430 | 40,730 (45%) | $0.42M (**11%**) | $0.71M (19%) |
| Disney 14 | $11.73M | 280,073 | 93,043 (33%) | – | $3.18M (**27%**) |
| Disney 15 | $10.75M | 254,563 | 80,584 (32%) | – | $2.29M (**21%**) |

## Check that changed the Dice rule
First run with all `Pricing%` keys: Dice "Golden buyers" 332K / 209K, more than all payers in the window (191K / 173K) — impossible. Dice 63, last 10 days, Goldens by key:
| Key | Goldens | Purchase ≤10 min before | Paid at all in the album |
|---|---|---|---|
| Pricing_CP | 122,681 | 7% | 43% |
| Pricing_DDJ | 82,449 | 27% | 40% |
| Pricing_Specific (incl. via Wild), G2G, C3P–C5P, Bundle, Random | ~119K | 88–100% | 92–100% |
- CP and DDJ are not purchases (most of their players never paid in the album). After removing them, 97–99% of Dice Golden buyers have a purchase ≤10 min before.
- Domino 20: 76% of Golden buyers link to a purchase in 10 min (others 98–99%); part of its "bought" Goldens may not be purchases. Not checked further.

## Impact on the goldens-week slide ("Opens a Golden Sale 7 Days Before Close")
Bought-Golden players per day, Dice 63, days 10→1, old rule (all Pricing) vs corrected:
- old: 19.5K 13.4K 12.3K **44.7K** 30.7K 24.3K 43.5K 29.7K 18.8K 15.8K
- corrected: 7.4K 6.5K 5.7K **7.1K** 7.6K 10.4K 10.3K 8.8K 9.0K 8.6K (3–9% of Golden takers)
- Dice 61 corrected: 4.9K 4.2K 5.4K 7.5K 8.6K 10.3K 11.7K 9.6K 9.3K 10.7K (old jumped to 71K at d−7 and 72K at d−4)
- **Fact:** the d−7 and d−4 jumps were `Pricing_CP` / `Pricing_DDJ` packs, not purchases. With the corrected rule Dice has no Golden sale jump; bought Goldens rise slowly to 8–11K a day, 3–9% of Golden takers, similar to Domino (3–8%) and Disney (1–7%). The slide's message does not hold.
- Not affected: Dice bought Wilds (`Pricing%` Wilds were validated 99.5–100% purchase-linked, `Pricing_Specific` Wilds 99.6% here).
