# Finish rate with and without first-album players (2026-10-21)

Question (Eden, topic 0 of the data-story review): the finish rate and the finishers' revenue share are counted on the standard population, which drops first-album players. Show both: with and without them.
SQL: `claude/first_album_finish_rate_queries.sql` (one query per game) + the Dice label check below. Projects: `dice-dreams-dbt`, `domino-dreams-dbt`, `solitaire-dreams-411507`.
Albums: Dice 61/63, Domino 19/20 (Eden 2026-10-21: Domino base = 19/20, album 20 shown separately when it differs; 17 also run), Disney 14/15.

## Definitions
- Population: not excluded, login ratio >= 0.5 on the last row before close, has a row on close-1 (the standard-population filters). Only the first-album filter changes.
- First album: Dice `user_past_album_count` = 0 or null; Domino / Disney `user_album_count` <= 1 (same columns the standard population uses).
- Payer = album-table spend > 0 from album start to the end of the close day (Eden 2026-10-20). Revenue = album-table spend start..close-1.
- Finisher = 144 unique set stickers by the end of the close day (Dice: sticker table).
- Revenue share = share of total game purchase revenue during the album (all players, start..close-1, excluded removed).

## Results
| Game · album | First-album payers (share of payers · share of game revenue) | First-album finish rate | Finish rate without → with | Finisher revenue share without → with |
|---|---|---|---|---|
| Dice 61 | 40,274 (19% · 19%) | 13% | 9.9% → 10.5% | 18% → 24% |
| Dice 63 | 39,182 (18% · 20%) | 11% | 12.5% → 12.3% | 21% → 28% |
| Domino 17 | 15,933 (10% · 7%) | 9% | 6.9% → 7.1% | 24% → 27% |
| Domino 19 | 11,575 (9% · 6%) | 6% | 5.9% → 5.9% | 20% → 22% |
| Domino 20 | 8,102 (7% · 5%) | 15% | 9.5% → 9.9% | 27% → 29% |
| Disney 14 | 40,464 (10% · 8%) | 5% | 5.2% → 5.2% | 16% → 18% |
| Disney 15 | 21,200 (6% · 5%) | 6% | 5.2% → 5.2% | 18% → 20% |

Counts (without / first album): Dice 61 finishers 17,466 / 5,209; Dice 63 22,818 / 4,472; Domino 17 9,367 / 1,363; Domino 19 7,039 / 708; Domino 20 10,148 / 1,174; Disney 14 19,376 / 1,924; Disney 15 16,855 / 1,237.

## Checks
- "Without" payers and payer revenue match earlier docs: Dice 61 175,794 payers (new payer rule, `decisions-definitions-register.md`), $16,986,906; Domino / Disney payer revenue = standard-population revenue in `opening-facts-2026-10-20.md`.
- Finishers are slightly above `finisher-recount-2026-10-19` (Dice 61 17,466 vs 17,347) because payers now include the close day (expected +39–128).
- Game revenue: Domino and Disney exact; Dice 61 $25,341,918 vs $25,342,929 and Dice 63 $30,302,561 vs $30,317,756 (-0.05%; data refreshed since 2026-10-20). Does not move any share.

## Dice: "first album" label is not reliable (fact, checked 2026-10-21)
Check: album-63 players with `user_past_album_count` = 0, and whether they also have rows in album 61 (`50_reporting.user_daily_album`, 3 GB).
| Past album count | Players | Payers | Album-63 spend | Also in album 61 | Payers also in 61 | Their spend |
|---|---|---|---|---|---|---|
| 0 | 315,880 | 82,745 | $7,457,738 | 91,193 (29%) | 30,320 (37%) | $4,400,439 (59%) |
| > 0 | 771,145 | 224,626 | $23,036,592 | 684,947 | 214,613 | $22,516,368 |
- The column description says "number of previous albums the user participated in", but 29% of the "0" players were in album 61 and hold 59% of that group's spend. Only album 61 was checked, so the real share of returning players is at least this.
- So in Dice, "first album" mixes new players with returning players, and the Dice standard population has been leaving out those returning players in every Dice number of the analysis. Domino / Disney `user_album_count` was not checked the same way.
- This explains why first-album payers look so large in Dice (19–20% of game revenue) while in September first-album players are only 4% of Dice revenue (`albums-all-players-2026-10-21.md`).

## Reading (interpretation, not tested)
- Finish rate barely moves when first-album players are added (all games within 0.6 points), because they finish at about the same rate as the rest (Domino 20 is the exception: 15% vs 9.5%, 1,174 finishers).
- The finisher revenue share moves more: +6–7 points in Dice (with the label problem above), +1–3 in Domino and Disney.
- Open: decide whether the deck population keeps excluding first-album players; fix the Dice first-album definition first (e.g. first album = no row in any earlier album in `user_daily_album`).

## Dice fix: first album = no row in any earlier album (Eden approved, 2026-10-21)
New rule: a Dice player is in their first album when `50_reporting.user_daily_album` has no row for them in any earlier album (history from 2023-11-07; a player whose last album was before that looks new, so "returning" is a floor). Replaces `user_past_album_count` = 0. SQL: last block of `first_album_finish_rate_queries.sql` (152 GB).
Label agreement: of the payers the old column calls "first album", 18,816 (61) / 22,210 (63) were in an earlier album; only 7 / 17 payers go the other way.

| Dice · album | Standard payers old → new | Payers' share of game revenue old → new | Finish rate old → new | Finishers' share of game revenue old → new |
|---|---|---|---|---|
| 61 | 175,794 → 194,603 | 67% → 78% | 9.9% → 10.0% | 18% → 21% |
| 63 | 182,700 → 204,893 | 69% → 82% | 12.5% → 12.3% | 21% → 26% |

End status, share of game revenue (new standard population): 61 finished 21% · 1 missing 6% · 2 missing 11% · 3 missing 18% · 4+ 23%; 63: 26% · 6% · 12% · 24% · 14%. Share of payers by end status is unchanged (61: 10 / 4 / 10 / 23 / 53%; 63: 12 / 4 / 11 / 39 / 33%).
Real first-album payers (new rule): 21,465 (61) / 16,989 (63), 8% / 7% of game revenue; finish rate 15% / 12%.

What it means:
- Fact: the returning players who were left out behave like the rest (same finish rate, same end-status mix); adding them raises every Dice revenue share by about x1.16 (61) / x1.19 (63), because the population now holds more of the game revenue.
- Dice payers now hold 78–82% of game revenue, in line with Domino (77–79%) and Disney (78–81%). The old Dice factor (0.67–0.69) was low because of this label.
- Every Dice revenue share in the decks that uses the standard population is about 3–5 points too low (finishers 19% → 23% on average). Rates and end-status player mixes do not change. Shares for sub-groups (spend groups, $20+ near-missers) need their own rerun; the x1.16–1.19 factor is only a guide for them.
- Domino and Disney first-album columns (`user_album_count`) were not checked the same way.
