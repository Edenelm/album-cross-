# Topic 1: First-album experience, findings (2026-11-03)
Albums 57, 59, 61, 63, 65 (first album); next album 59–67. Project `dice-dreams-dbt`. Ranges = the five albums.
Population: players whose first album is this one (no earlier album record), with at least one sticker, excluded users removed. Reference = veterans (in the previous album) who entered in the first third.
Entry bands: **L14** = started in the last 14 days before close; otherwise T1 / T2 / T3 by share of album days. In 43- and 36-day albums the final third ≈ L14; only album 59 (50 days) has a separate T3.
Revenue = game gross revenue; revenue share = of all game revenue on album days start..close−1 (excluded users removed).
SQL: `queries/t1_s2_s4_core.sql`, `queries/t1_s3b_rolls_7d.sql`, `queries/t1_s5_composition.sql`. Results: `results/*.csv`.

## Data correction before any result (C-005)
`30_intermediate.album_pop.user_album_start_date` is overwritten to the close day for 25–31% of players in albums 63 and 65 (270,736 / 338,528 players; rows rebuilt after close). The first S2 run put ~250K veterans "entering at close" with 41–49% of revenue. Fix: entry = first row in `user_daily_album` (it equals that table's own start date for every player checked). Album 57 was not affected. `t1_s2_base.sql` is superseded.

## F1. Size
- **Observed:** first-album players = 201,022–270,286 per album = **18–23% of album players** and **10–15% of game revenue** during the album; 58,086–83,007 payers.
- **Validation:** matches the 11-02 table (19–22% / 10–15%, other base table); game-revenue denominator matches earlier docs (album 61 $25,341,831 vs $25,341,918; album 63 $30,302,513 vs $30,302,561).
- **Meaning:** a large group in players, mid-sized in money. Who they are: ~70% installed within 7 days before entry (median 3–5 days), 6–10% paid before. The first album is in practice the player's first week in the game.
- **Limit:** players with an album record but no sticker (1–4%) are not in the base.

## F2. A third of first-album players are gone by their second week; veterans lose 13–16%
- **Observed:** active in the game on days 7–13 after entry: **first-album 63–69%** (every entry band) vs **veterans 84–87%**. First-album players who start in the first third: 58–65% have no activity in the album's last 7 days (veterans 23–31%).
- **Validation:** same rate in all five albums and all entry bands; measured on game activity (not album activity), so it does not depend on the album being open.
- **Meaning:** early loss is the main first-album issue: it touches every first-album player, and it is about twice the veteran rate.
- **Limit:** the data cannot say how much of this loss the album causes. It looks like general new-player drop-off (see F4).

## F3. Late joiners progress fast and spend the same in their first week
- **Observed (L14 vs T1):**
  - L14 = 26–51% of first-album players, 1.3–3.1% of game revenue.
  - New stickers per active day: 10–12 vs 4.8–6.1.
  - Duplicates: 45–51% vs 70–76%.
  - Paying late joiners finish at 5–9% within about 7 days, vs 6–8% for first-third joiners over about 36 days.
  - First 7 days from entry: revenue per player $5.2–6.7 vs $4.9–6.7; payer rate 19–26% vs 20–26%; active days 4.5–4.9 vs 4.6–4.7.
- **Validation:** equal 7-day window for both groups. The groups look the same before entry: install age, prior payers (6–10%), kingdom 5–6 at entry.
- **Meaning:** the catch-up gives late joiners much faster progress. In week 1 they buy neither less nor more (H1 not supported).
- **Limit:** the catch-up rule is not documented; the week-1 window is short.

## F4. Same 2-week retention despite twice the progress
- **Observed:** active on days 7–13 after entry: L14 64–69% vs T1 64–66%, though L14 get about twice the new stickers per active day.
- **Validation:** same comparison in all five albums. Entry bands are similar before entry, so the comparison is fair.
- **Meaning:** faster album progress in the first days does not keep more new players at two weeks. This argues against "too little progress drives them away" (H2) and against "generous early rewards build engagement" (H3), at least over two weeks. It fits general new-player drop-off (H4).
- **Limit:** observational; covers two weeks, not long-term value. Album phase is not random (UA timing), but the composition check shows no difference.

## F5. "Late joiners retain better in the next album" is an elapsed-time artefact
- **Observed:** active in the game during the next album's first 14 days: L14 68–73% vs T1 33–39% (veterans 70–77%). Payers who pay again in those 14 days: 45–49% vs 21–25% (veterans 50–56%). Next-album revenue per player in those 14 days: L14 $7.2–11.0 vs T1 $3.7–6.0.
- **Validation:** the next album starts about 7 days after an L14 joiner enters, but about 36 days after a T1 joiner. At equal time since entry (F4) there is no gap.
- **Meaning:** do not compare entry groups with next-album metrics. Use time since entry. Late joiners are not "better players"; they are measured earlier in their life.
- **Limit:** the long-term revenue comparison at equal time since entry (days 0–60) is not done yet (backlog B-1).

## F6. Rolls: the album gives first-album players almost no rolls; their balance runs near empty
- **Observed (first 7 days, medians):**
  - Rolls from album rewards: 0 (album share of rolls received 0.3–3.5%).
  - Free rolls in: 2,053–4,197; rolls out: 2,734–6,033; balance at the end of the window: 9–26.
  - Veterans: free in 10,132–33,565, out 18,948–49,948, balance 60–85.
  - Late and early joiners do not differ in rolls.
- **Validation:** medians, because means are distorted by a few extreme players. The "purchase group" sources reach 95–99% of players, non-payers included, so they cannot mark paid rolls; that split is dropped.
- **Meaning:** first-album players do not have "generous rolls". The album's generosity to newcomers is in stickers (catch-up), not in rolls. H1 through rolls is not supported.
- **Limit:** the album gives rolls mainly for set and album completion, which newcomers rarely reach in week 1.

## Explanations: status
| Explanation | Status | Evidence |
|---|---|---|
| H1 Generous rewards delay buying | **Not supported** (week 1) | Fast catch-up, same week-1 payer rate and revenue (F3); rolls are not generous (F6) |
| H2 Too little progress drives players away | **Not supported** (2 weeks) | Twice the progress, same 2-week retention (F4); no "wall" before stopping (11-02 §6) |
| H3 Generous early rewards build engagement / value | **Not supported** (2 weeks); long-term undecided | F4; long-term at equal time since entry not measured (B-1) |
| H4 General new-player drop-off | **Fits best**, not proven | Same loss in every entry band; ~70% installed within 7 days; double the veteran rate (F2, F4) |
| H5 Artefacts | **Found and fixed** | album_pop start date (C-005); elapsed-time artefact in next-album metrics (F5) |

## Business meaning and next step
- **Keep the catch-up:** late joiners progress fast and do not spend less (Fact).
- **Do not expect album pace to fix early loss:** twice the progress did not change 2-week retention (Fact). Making the first album more generous is unlikely, by itself, to lift early retention (Hypothesis).
- **The lever is the first two weeks of every new player, not late entry.** Any change for first-album players is a **controlled test** (first-album players only, randomised). Main metric: active on days 7–13 after entry. Guardrail: revenue days 0–28 after entry.
- **Measurement rule:** compare entry groups by time since entry, never by next-album metrics.
- **Data fix:** report the album_pop start-date overwrite to the data team (C-005).

## Backlog (adjacent, not done)
- B-1 Revenue and activity at equal time since entry, days 0–60 (long-term H3), and time to next purchase (survival).
- B-2 Packs by source and type in the first album (staging pack events); pack-level duplicates by sticker type.
- B-3 Returning players (earlier album, not the previous one): 9–10% of players.
- B-4 Within-band dose-response: new stickers in the first 3 days vs 2-week retention at the same early spend.
- B-5 Spike of late first-album joiners in album 65 (127,844 = 12% of album players): UA campaign?
- B-6 Kingdom at entry is 5–6, while the docs say the album opens at Kingdom 8 (C-006).
