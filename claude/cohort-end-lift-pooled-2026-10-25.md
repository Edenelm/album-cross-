# Same players, 1st to 7th album: end lift vs the rest of the album, groups pooled (2026-10-25)

Eden's change to deck slide 16 ("Arpdau Lift of Players Who Stayed All 7+ Albums"): compare the last 4 days with the **rest of the album** (not the whole album, which includes those 4 days), and **pool the two join groups** so a bigger group weighs more (before: simple average of two groups; Disney groups are 50,866 vs 166,270 players).
Population, panels and revenue: unchanged from `cohort-end-lift-2026-10-22.md` (panel = played all 7 albums from the first; active days; close day excluded; exclusions; revenue = album-table spend). SQL: `cohort_end_lift_pooled_vs_rest_2026-10-25.sql`.
Lift = ARPDAU close−4..close−1 ÷ ARPDAU player start..close−5 − 1, each = total revenue ÷ total active days of both groups.

| Album since joining | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| Dice lift vs rest (`dice-dreams-dbt`) | +30% | +31% | +24% | +16% | +23% | +15% | +12% |
| Dice ARPDAU whole album | $1.33 | $1.69 | $1.74 | $1.74 | $1.63 | $1.58 | $1.56 |
| Domino lift vs rest (`domino-dreams-dbt`) | +27% | +24% | +7% | +4% | +15% | +26% | +18% |
| Domino ARPDAU whole album | $1.00 | $1.25 | $1.22 | $1.14 | $1.09 | $1.05 | $1.00 |
| Disney lift vs rest (`solitaire-dreams-411507`) | +9% | −1% | +2% | +1% | +2% | +3% | +2% |
| Disney ARPDAU whole album | $1.34 | $1.32 | $1.17 | $0.99 | $0.96 | $0.88 | $0.88 |

For comparison, pooled lift vs the whole album: Dice +23/+27/+22/+14/+21/+13/+11%; Domino +22/+22/+6/+4/+14/+24/+17%; Disney +7/−1/+2/+1/+2/+3/+2%.
Disney album 1 by group (vs rest): album-8 group (New Year album) +31%, album-9 group +3%.

Old slide (vs whole album, simple average of groups): Dice 26/27/21/16/20/15/13; Domino 21/21/5/4/16/22/17; Disney 13/−1/4/2/2/2/2.

Reading (fact): message unchanged — the same Dice and Domino players lift at the end in every album (Dice +12% to +31%, Domino +4% to +27%), the same Disney players barely do after their first album (−1% to +3%). Disney's first-album bar falls from +13% to +9% once the bigger album-9 group gets its weight.
