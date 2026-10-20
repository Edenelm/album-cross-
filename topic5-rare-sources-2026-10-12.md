# Topic 5 — Where new Supers / Royals come from over the album (run 2026-10-12)

Population: PU (album spend > 0 before close), not excluded, login ratio on last row before close ≥ 0.5. Albums Dice 61/63, Domino 17/19, Disney 14/15. Close date excluded. Quarter = share of album time (Q1 0–25% … Q4 75–100%).
Unit: **new rares only** (first collection of each Super/Royal per player). Duplicates by source are not in curated tables (only `10_staging`).
Tables: Dice `dice-dreams-dbt.30_intermediate.fact_user_album_stickers` (`sticker_source`, raw names; `collected_from_wild`); Domino `domino-dreams-dbt.prod_30_intermediate.int_user_album_stickers` (`new_sticker_source`, grouped by a CASE on campaign name; `collected_by_joker_flag`); Disney `solitaire-dreams-411507.bi_entity_prod.dim_user_album_stickers` (same as Domino). SQL: `claude/topic5_rare_sources_queries.sql`.
QA: Disney album 14 has duplicate rows in `dim_user_album_stickers` (8.08M rows vs 5.21M user-sticker pairs) → deduped to the earliest row per user × sticker in all games. After dedup, new rares per PU ≈ P50 from Topic 4 (Dice 8.6, Domino 5.2–5.3, Disney 4.1–4.4). `sticker_type` is 'Royal' (capitalised) in Domino/Disney.

## Dice — new Supers
| Source | 61 share | 63 share | % of PU with ≥1 | Q1 / Q2 / Q3 / Q4 (61) | Q1 / Q2 / Q3 / Q4 (63) |
|---|---:|---:|---|---|---|
| Trail – Chest | 36% | 31% | 96% | 35 / 51 / 57 / 8% | 31 / 34 / 41 / 19% |
| Trail – Final Reward | 15% | 14% | 74–76% | 14 / 16 / 15 / 13% | 7 / 26 / 19 / 9% |
| RewardCalendar | 6% | 7% | 45–57% | 8 / 4 / 5 / 6% | 8 / 6 / 7 / 7% |
| Duel / VerticalQuest / Frankys / DeepDive (event-specific) | 2–6% | 2–4% | 15–38% | single-quarter spikes (Duel Q1 22%) | VerticalQuest Q3 15% |
| PropChase_Hunt / Generic_Reward / Duplication exchange | 4% / 4% / 4% | – / 4% / 1% | 30–35% | Q4: 15% / 14% / 12% | Q4: – / 5% / 3% |
| (null source) | 0% | 14% | 87% (63) | – | 34% of Q1 — data gap |
| Other | 18% | 19% | | 13 / 14 / 16 / 26% | 10 / 16 / 8 / 38% |
| Via Wild (flag) | 5.4% | 4.9% | | 0 / 0 / 1 / 18% | 0 / 1 / 0 / 17% |

## Domino — new Royals
| Source | 17 share | 19 share | Peak quarter |
|---|---:|---:|---|
| Challenge | 14% | 2% | 17: Q1 36% |
| pixie_reward | 13% | – | 17: Q3 27% |
| duplicates (exchange) | 11% | 11% | Q4: 30% (17) / 22% (19) |
| Momentum | 8% | 8% | 19: Q3 23% |
| Puzzle | 6% | 7% | 19: Q1 29% |
| days_milestone | 5% | 8% | Q1 9–18% |
| Blast | – | 11% | 19: Q4 26% |
| conveyor_belt / PiñataParty | 6% / – | – / 5% | Q2 22–23% |
| Trail (+ grand reward) | 6% | 8% | spread |
| Other | 18% | 32% | |
| Joker flag (ever) | 2.9% | 6.3% | Q4 12–16% |

## Disney — new Royals
| Source | 14 share | 15 share | Peak quarter |
|---|---:|---:|---|
| mf tier completed (Magical Friend) | 19% | 23% | steady Q1–Q3 (17–33%) |
| black-friday-wheel | 32% | – | 14: Q1 48% (name looks wrong for Jul–Aug — Needs Validation) |
| gamified_8box | 10% | 15% | Q3: 21% (14) / 35% (15) |
| daily_reward | 10% | 9% | spread, Q4 10–15% |
| enough DR | 1% | 10% | 15: Q3–Q4 16–17% |
| scrolling (offer) | 4% | 7% | 14: Q4 16%; 15: Q1 31% |
| momentum / mini_collection | 5% / 4% | 5% / 7% | |
| marketplace / lightyear-trail / mtx challenge | 2% / – / 3% | – / 5% / 2% | Q4 10% (14) / Q4 18% (15) |
| Other | 8% | 13% | |
| Joker flag (ever) | 1.8% | 2.1% | Q4 8% |

## Reading
- Known: Dice has one backbone — the Trail (Chest + Final Reward ≈ 45–51% of new Supers; 96% of PU got a Super from Trail Chest). It carries Q1–Q3 and fades in Q4 (8–19%).
- Known: Domino and Disney have no single backbone. Royals come from rotating events, each strong in one quarter (Domino: Challenge, pixie_reward, Puzzle, Blast; Disney: black-friday-wheel, gamified_8box, lightyear-trail). Disney's most stable source is Magical Friend tiers (19–23%).
- Known: in all three games the last quarter shifts to "closing" sources — Wild/Joker (Dice 17–18%, Domino 12–16%, Disney 8% of Q4 new rares), duplicate exchange (Dice 61 12%, Domino 22–30%; not visible in Disney), and offers/late events (Dice PropChase/Generic_Reward, Disney scrolling/marketplace/lightyear-trail).
- Known: Disney 15's Q3 spike in gamified_8box (35% of Q3 new Royals) lines up with the 92% new-rare rate at 50–75% found in Topic 4d.
- Hypothesis: Domino/Disney gate Royals behind time-limited events (supply arrives in pulses), while Dice drips Supers through an always-on Trail and leaves the end to Wild/offers.
- Not shown: which sources are paid vs free (Missing — needs a source mapping). Duplicates by source (Missing — staging only). Joker flag = "ever via Joker", not this receipt (not comparable 1:1 with Dice Wild).
- Needs Validation: Dice 63 `(null)` source = 14% of new Supers (34% of Q1); Disney 'black-friday-wheel' label; Domino/Disney grouping comes from a CASE on campaign names.

## 5b. Source → category mapping (v2, after Eden's corrections 2026-10-12)
Eden confirmed: Magical Friend (Disney) = like Pets in Dice — not permanent, a longer-running feature (season) · Momentum (Domino/Disney) = central daily layer, recurs every day, hard to complete, few players reach top tier; Royal (when included) is in the LAST tier, and not every day's Momentum includes a Royal · pixie_reward (Domino) = Pixie feature completion reward → long-running feature · Dice 2Day_Trail = recurring MTX campaign event (every few days, like Blast) → event, not feature · Disney marketplace = central end-of-album event that gives Wild/Joker · Disney 'enough DR' = Sugar Rush (on-top monetization collection event, runs once to a few times a week; DR = dr-sugar-spin; stickers via Rainbow Candy surprise, milestones, Final Prize ×2 with 1 RC) → C. Source: Confluence 'Sugar Rush' (DSC space).

Categories: A long-running feature / season (Pets / Pixie / Magical Friend) · B daily/weekly reward · L daily Momentum layer · C-Trail recurring Trail event · C other time-limited/MTX events · D paid offer/pass · E duplicate exchange · M end-of-album Market · F social · ? unknown.
Population = PU, login ratio ≥0.5, close day excluded, new rares only (first receipt). Sources ≥0.1% share.

| Category | Dice 61 / 63 | Domino 17 / 19 | Disney 14 / 15 |
|---|---|---|---|
| A long-running feature | 0.3% / 0.4% | 13% / 0 | 20% / 24% |
| B daily | 6% / 8% | 5% / 8% | 10% / 9% |
| L Momentum (daily layer) | – | 8% / 13% | 5% / 5% |
| C-Trail | **51% / 45%** | 6% / 11% | 2% / 5% |
| C other events | 34% / 28% | 48% / 48% | 59% / 55% |
| D paid offer | 4% / 3% | 1% / 4% | 1% / 1% |
| E dup exchange | 4% / 1% | 11% / 11% | 0 / 0 |
| M closing Market | – | 4% / 0 | 2% / 1% |
| ? unknown | 0 / 14% | 2% / 5% | 0 / 0 |

- Known: in all 3 games most rares come from time-limited events (Dice 73–85%, Domino 54–58%, Disney 60–61%; excl. Momentum). The difference is concentration: in Dice one recurring event (Trail) gives ~half of all new Supers; in Domino/Disney supply is spread over many events.
- Known: Disney has a long-running feature (Magical Friend) giving 20–24% of new Royals; Dice Pets gives <0.5% of Supers.
- Known: Dice paid offers deliver Supers 100% via Wild, 100% in Q4.
- Known: Momentum (daily, hard layer) gives 8–13% of new Royals in Domino and ~5% in Disney; Dice has no equivalent source in the list.
- Needs Validation: Domino Market (AlbumBonusKiosk, 64% in Q4) mapped to M like Disney marketplace. Domino pixie_reward appears only in album 17. Dice 63 (null) = 14%.
- Missing: paid vs free split — several C events are MTX events.

## 5c. Days per album where Momentum gave a Royal (2026-10-13)
Tables: Disney bi_entity_prod.dim_user_album_stickers, Domino prod_30_intermediate.int_user_album_stickers; source LIKE '%momentum%', sticker_type Royal, first receipt only (new Royals). All players (no PU filter). Day counted if ≥100 players got a new Royal from Momentum that day; open→close−1.

| Album | Album days | Days with Momentum Royal | Median receivers/day | Pattern |
|---|---|---|---|---|
| Disney 14 | 42 | 16 (38%) | 11.9K | mostly 2-day pairs, ~weekly |
| Disney 15 | 42 | 19 (45%) | 6.2K | 2-day pairs early/mid, daily in last 6 days (09-29→10-04) |
| Domino 17 | 39 | 30 (77%) | 4.2K | near-daily |
| Domino 19 | 49 | 38 (78%) | 3.7K | near-daily |

- Known: Domino puts a Royal in Momentum on ~3 of 4 album days; Disney on ~2 of 5 days, usually in 2-day windows.
- Needs Validation: counts only days with NEW Royals — a Momentum day whose Royal was a duplicate for most players is undercounted. The release calendar from the Disney team (question 16) would confirm.

## 5d. Category by album quarter — cross-game chart (2026-10-13)
Chart: topic5_rare_sources_by_quarter.png (shared in chat). Same population/tables as 5b; mapping v2 applied as CASE (queries appended to topic5_rare_sources_queries.sql). Share = new rares in category / all new rares in that album-quarter.

| Category share | Dice 61 Q1→Q4 | Dice 63 Q1→Q4 | Domino 17 Q1→Q4 | Domino 19 Q1→Q4 | Disney 14 Q1→Q4 | Disney 15 Q1→Q4 |
|---|---|---|---|---|---|---|
| Trail event | 49/67/73/21 | 38/60/60/28 | 8/8/5/3 | 8/12/10/11 | 0/12/1/0 | 0/2/0/18 |
| Other events | 40/27/19/47 | 52/32/30/49 | 73/57/30/37 | 41/59/49/46 | 66/40/67/50 | 48/55/66/45 |
| Momentum | – | – | 6/5/12/9 | 9/14/24/7 | 0/10/5/8 | 11/2/2/4 |
| Long feature | 0/1/0/0 | 1/0/1/0 | 0/17/27/0 | 0/0/0/0 | 18/25/20/19 | 31/35/25/11 |
| Daily reward | 8/4/5/6 | 9/7/8/8 | 8/7/3/3 | 18/10/7/3 | 16/12/5/10 | 10/5/6/15 |
| Closing Market | – | – | 0/1/4/14 | 0/0/0/0 | 0/0/0/10 | 0/1/0/2 |
| Paid offer | 1/1/1/12 | 0/0/0/11 | 0/1/1/4 | 2/2/0/10 | 0/0/2/2 | 0/0/0/3 |
| Dup exchange | 0/0/1/12 | 0/0/0/3 | 0/0/17/30 | 0/0/11/22 | 0 | 0 |
| Unknown/social | 0/0/1/0 | 0/1/0/0 | 5/5/0/0 | 22/4/0/0 | 1/1/1/1 | 1/1/1/1 |

- Known: Dice — Trail carries Q1–Q3 (38–73%) and drops in Q4 (21–28%); in Q4 paid offers (11–12%, all via Wild) and duplicate exchange (3–12%) appear.
- Known: Domino — other events are the largest block in every quarter; from Q3 duplicate exchange grows (11–30%); Closing Market 14% of album 17 Q4; Momentum peaks in Q3 (12–24%).
- Known: Disney — Magical Friend is steady across the album (11–35% each quarter); no duplicate exchange; Q4 adds Market (album 14: 10%) and daily reward (album 15: 15%); paid offers ≤3% (Joker flag semantics unconfirmed).
- Known: in all three games the source mix changes in Q4 toward "closing" mechanisms (Dice paid Wild offers, Domino duplicate exchange + Market, Disney Market). No causal claim.
- Resolved (Eden, 2026-10-13): Dice blank sticker_source ('' not NULL, no campaign) = Puzzle Collection / Merge Collection, identified by sticker_pack_key: HGP_* = feature high tiers (~97%, mostly 'Super 1C Treat Tipul', one per user), GP_* = last tier (~6K, mostly 'Super 3C Treat Tipul'). 283,340 of 2,071,923 Supers in album 63 PU population (34% of Q1, 16% of Q4). Mapped to 'Other events' (collections, same as Domino/Disney puzzle/mini_collection). Rule: COALESCE(NULLIF(sticker_source,''), CASE pack-key prefix → puzzle/merge_collection_high/last_tier).
- Found (2026-10-13): Domino 19 null-source Royals (PU pop) = 35,072 from campaign 'EV_Royal_Card_Popup_Since_250310' (exactly 1 per user, 35,007 users, 07-06→08-08, 27 days, 4 sets, joker 0.2%) + 46 from BonusDishItalian. int_user_album_stickers has no pack-key column; new_sticker_source is a CASE on campaign name that does not cover this campaign. Raw staging (prod_10_staging.stg_album_sticker_collected, approved by Eden) shows: raw source = '' , pack_key = 'First_Royal_Gift', pack_type = 'royal', mtx_event_name = 'Royal Tower Launch Gift' (all players: 394K rows / 392K users, 07-06→08-24). = one-time free first-Royal gift at Royal Tower launch. Category pending Eden (proposed: free gift, with B Daily). Avo (Domino Dreams Analytics, event 'album sticker collected') has source/pack_key/pack_type that int_user_album_stickers drops.
- Needs Validation: Disney 15 Q4 Trail 18% = lightyear-trail.

