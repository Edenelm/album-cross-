# Domino 20: where new Goldens came from, last 10 days (2026-10-28)
Question (Eden): what was offered each day to get a new Golden; is there a gap 8–5 days before close?
Query: int_user_album_stickers, album 20, first receipt of each Golden, all players (not only payers), source = mtx campaign name or new_sticker_source; top 8 sources per day by players (9.9 GB, domino-dreams-dbt). Shows sources players got Goldens from, not the offer catalog.

| Days before close | Top sources of a new Golden (players) |
|---|---|
| 10 | ChefMerge 20,986 · Blast 14,965 · area completed 10,599 · FairyFlight 8,193 · Trails · CollectorsQuest |
| 9 | ChefMerge 23,959 · BallonRise 21,916 · CollectorsQuest 17,720 · ChefTrail 12,257 |
| 8 | ChefMerge 24,399 · ChefTrail 22,089 · CollectorsQuest 17,400 · ChefTrailUnder800 16,126 |
| 7 | **GoldenKiosk 27,799** · GoldenFlamingFeast 17,796 · GardenBlast 12,530 · GoldenTemple 7,738 |
| 6 | **GoldenKiosk 62,662** · AlbumColoringBook 41,894 · GoldenTemple 18,556 · CollectorsCardTrail 17,738 |
| 5 | AlbumColoringBook 94,621 · **GoldenKiosk 30,867** · CollectorsCardTrail 26,512 · AdventureWheel JokerPuzzle 14,287 |
| 4 | AlbumColoringBook 101,857 · FlamingFeast 27,210 · MergeWonders 26,540 · MovieTwister 18,337 · SummerFeverPuzzle 11,652 |
| 3 | MergeWonders 34,725 · AlbumColoringBook 31,037 · MovieTwister 30,841 · SummerFeverPuzzle 13,815 |
| 2 | MergeWonders 35,320 · AlbumMissions 23,910 · MergeTwister 18,586 |
| 1 | PacksForGifts (StepByStamp) 46,585 · MergeWonders 25,475 · BalloonRise 19,104 · RoadToGlory 16,269 |

- Fact: the pick-your-Golden GoldenKiosk ran 7–5 days before close (28K / 63K / 31K players got a new Golden from it), plus GoldenTemple and AlbumColoringBook — the same days the bought-Golden share dipped (2.7 / 2.8 / 2.3% of active payers).
- Fact: the top sources every day are events/gameplay (Merge, Trail, Momentum, ColoringBook), not paid offers.
- Correction: the "no way to pick a Golden in the d−8..d−5 dip" reading was wrong; a pick existed (Kiosk) on d−7..d−5.
- Hypothesis: the Kiosk and ColoringBook gave Goldens for free or for in-game currency and replaced Golden purchases on those days (dip in buying = supply from elsewhere, not missing demand). Not checked: Kiosk cost and whether Kiosk users bought less.
