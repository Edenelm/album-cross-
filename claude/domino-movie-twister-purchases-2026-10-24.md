# Domino 20: payers who got a Joker from Movie Twister — did they buy, and above their habit / CZ? (2026-10-24)

Eden: did players who got a Joker from Movie Twister buy an offer in those two days, and how much above their habit (own average purchase last week, or comfort zone)? And what revenue share are they worth regardless?
SQL: `claude/domino_movie_twister_purchases_2026-10-24.sql` (domino-dreams-dbt, 4.3 GB).

## Definitions
- Population: Domino 20 standard-population payers (106,762). Group = got at least one Joker sticker with `new_sticker_source = 'MovieTwister'` (event AlbumMomentsTvTwister, 8–9 Oct = 4–3 days before close). Comparison = the other payers (not a control group).
- Purchases: `prod_10_staging.stg_purchase_completed_vw` (staging; Eden approved it for CZ on 2026-10-18), `usd_amount`, deduped. Event days = 8–9 Oct; habit week = 1–7 Oct.
- CZ = `smart_segments.cz_c` at the purchase. "Above own average" = the highest price paid in the 2 days > the player's average purchase price in the habit week (only players who bought in both).
- Revenue share = share of the standard-population payers' album 20 revenue.

## Results
| | Got a Movie Twister Joker | Other payers |
|---|---|---|
| Payers (% of payers) | 19,125 (18%) | 87,637 (82%) |
| % of album revenue | **31%** | 69% |
| Bought in the 2 event days | **60%** | 17% |
| Bought on the event days before getting the Joker | 54% | – |
| Spend per day in the 2 days vs own habit week | **×1.83** | ×0.67 |
| Highest price > own average price last week (buyers in both periods: 8,474 / 11,511) | 72% | 54% |
| Median highest price vs own average | ×1.46 | ×1.07 |
| Bought above CZ (buyers with a CZ: 11,377 / 15,073) | 52% | 31% |
| Median highest price vs CZ | ×1.05 | ×0.84 |
| Spent in the 2 days | $311,210 | $253,168 |

## Reading
- **Fact:** Movie Twister Joker players are 18% of payers and 31% of album revenue. In the two event days 60% bought, they spent 1.83× their own daily habit, and half bought above their CZ.
- **Fact:** 54% bought on the event days before they got the Joker. The Joker likely came after spending in the event, so "gameplay" (the validated paid rule) understates the paid part. Hypothesis until the event design is checked with the Domino team.
- **Caveat:** self-selection — the players who join the event are the more active payers; the other payers are not a control group.
- **Meaning for the closing-tool slide:** Domino's free-Joker peak is an event that also drives purchases above habit.
