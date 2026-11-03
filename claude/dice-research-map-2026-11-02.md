# Dice album — research map and initial story outline (2026-11-02)

**Central question (Eden):** how do players progress through the Dice album, what brings them to completion, and where do we lose momentum or miss an opportunity?
**Scope of this step:** existing material only. No new queries, no slides. Gaps are marked **MISSING**, not filled.
**Base albums:** typical albums 59 / 61 / 63 (Eden 2026-11-02). Album 65 is a one-album exception (flat end), used only as a case. 67 is open until 11-30.
**Cross-game material** is used only where a comparison answers a Dice question.

## Denominators used below
- **Payers** = standard-population payers: not first album (fixed rule = has a row in an earlier album), not excluded, login ratio ≥ 0.5 on the last row before close, row on close−1, spent on any album day. About 196–203K per album (59/61/63).
- **% of album revenue** = share of those payers' album-table spend, album start..close−1. Album revenue = $24.2M / $19.8M / $24.6M (59/61/63). These payers hold 78–82% of total game revenue during the album (61/63).
- **% of game revenue** = share of all in-game purchase revenue during the album, all players, exclusions removed.
- Album-table spend = **all** in-game spend on album days. Spend that can be **attributed to the album mechanism** (a purchase that delivered a sticker or Wild) is a different, smaller number. It is linked by timing only (see §0).

---

## 0. What the data can and cannot link (applies to every topic)
| Link | What exists | Status | Source |
|---|---|---|---|
| Final sticker → its direct source | `fact_user_album_stickers`: `sticker_source`, `sticker_pack_key`, `collected_from_wild`, timestamp. Holds new stickers (first copies) only | **Identified directly** | dice65-end-2026-10-24; dice-wild-sources-2026-10-21 |
| Paid vs free source | Pack rule `Pricing%` except `Pricing_CP` / `Pricing_DDJ` — **superseded 2026-11-02**: misses ≈265K offer stickers with CP/DDJ or other packs and includes ≈95K Journey stickers that were not bought. Use the source + campaign + ≤10 min rule | Rule replaced | dice-sticker-source-vs-purchase-2026-11-02 |
| Purchase → sticker | **Offers: two keys + time.** `sticker_source` = `purchase.source` and `sticker_mtx_campaign_id` = `campaign_id`, purchase ≤10 min before: 94–98% of offer stickers, placebo 0–2% (album 63, 2026-11-02). Gameplay/event sources never appear as a purchase source | **Identified for offers** (1.4% of new stickers, 38% of Wild fills); **proximity only** for gameplay fuelled by bought rolls | dice-sticker-source-vs-purchase-2026-11-02; earlier timing: onepager §5a |
| Wild: day received vs day used | Sticker table gives the **fill** date. Whether Wild receipt is logged separately: **MISSING** (candidates: `40_mart.fact_dynamic_resource_given`, used for the VIP gift) | Unknown | vip-review-2026-10-24 |
| Trail progress → reward | `50_reporting.fact_user_campaign_trail`: campaigns, top layer reached, payers. Trail is a continuous chain (39 campaigns Jul 2–Sep 7, 1–2 days each) | Layers identified; **which layer gives the Wild: MISSING** (config) | open-checks-2026-10-21 §2 |
| Purchase → Trail progress (boosters) | Not identified. Question to the studio: what share of Trail-reward winners bought a booster on the way | **MISSING** | open-checks-2026-10-21 §3 |
| Sets completed in sequence | `fact_user_daily_set_progression` exists (used once, 10-12) | Possible; not used for sequences yet | dice-supers-mechanism-onepager |
| Offer exposure (saw an offer, did not buy) | **MISSING** for Dice. Domino has `mtx_event_triggered` logs; Dice equivalent not checked | Unknown | domino-fu-pricing-hypothesis-2026-10-29 (Domino only) |

**Update 2026-11-02:** the linkage audit for purchase → sticker is done (album 63). Remaining items of the audit: Wild receipt log, Trail layer timestamps, offer exposure.

**Meaning:** a journey "purchase → Trail → reward → Wild → completion" can be **reconstructed in time order** per player, and the purchase → sticker step can be **validated with a placebo**. It cannot be proven with IDs. Any "role of each step" claim is a description of sequences, not a cause.

---

## 1. How progression begins and develops (start of the album, first album)
**Business question:** do players get a meaningful start, and do new players reach the album early enough to experience progress? It matters because the first album sets up the next ones. Dice revenue per active day rises from album 1 ($1.33) to album 3–4 ($1.74) for players who stay (cohort-end-lift-pooled-2026-10-25).

**Existing findings**
- **Unlock:** the album opens at Kingdom 8. Of payers who paid in their first 7 days (installs Mar–Jun 2026), 70% reached the album by day 7 and 84% by day 90. 16% never did; they mostly stopped playing early (median 2 active days) (cross-game-comparison-framework A2, root).
- **Median days from install to first album, payers:** 2 (payer-time-to-first-album v2; **uncommitted**, sits in another worktree — status D-W3).
- **Size:** first-album players are 13% of players and 4% of revenue in September (all players active in Sept; albums-all-players-2026-10-21). Real first-album **payers** in the standard population: 21,465 (61) / 16,989 (63), 8% / 7% of game revenue, finish rate 15% / 12% (first-album-finish-rate-2026-10-21).
- **Spend:** new first-album players spend $1.10 per active day vs the album average of $0.97–0.98. 22% of them pay in album 1 (31–32% of those who stay 7 albums) (cohort-end-lift-2026-10-22).
- **End lift in album 1:** +30% vs the rest of the album, for players who stayed 7 albums (survivors only) (cohort-end-lift-pooled).
- **Rares:** Dice rares arrive steadily for the population; median gap 4 days (rare-timeline-2026-10-20). Not split by first album.

**MISSING**
- Entry day relative to album start, and days left when the player joins.
- First Super and first Wild: when and from which source.
- First meaningful barrier (first stall in new stickers).
- First purchase vs album entry (before, same day, after).
- What first-album players complete (sets / album), by entry timing.
- Behaviour in the next album, for **all** first-album players, not only survivors.

**Challenge to the hypothesis:** the evidence so far does **not** show first-album players doing worse. Their finish rate (12–15%) is at or above veterans, and they spend more per active day than the average. Two cautions before reading that as "fine": (1) the standard population keeps only players with login ratio ≥ 0.5 and a row on close−1, so it drops those who joined and left; (2) "first album" in Dice has a floor problem (history starts 2023-11-07). The real question may be **mid-album joiners**, not first-album players as a whole.

**Next check (focused):** first-album players of 59/61/63 by entry timing (first / second half of the album): days left, new stickers per active day in the first 7 days, day of first Super and first Wild + source, first purchase day, finish / sets completed, and presence + spend in the next album. Compare with veterans **at the same days-left and spend level**. Agree the definitions with Eden first.

**Journey link:** this is the start of the story ("how players enter"). It decides whether the first album needs its own design (shorter goals, a starter path) or not.

---

## 2. What sustains progression and what creates barriers (middle of the album)
**Business question:** where does progress slow, and is the slowdown by design (locked stickers) or a supply gap?

**Existing findings**
- **Supply is steady:** median 4 days between new rares (7 in Domino and Disney). Longest wait = 14% of album time vs 26–35% (rare-timeline-2026-10-20; golden-timeline-2026-10-23).
- **Trail is always on** and is the main source of Supers: about 50% of new Supers come from Trail (open-checks-2026-10-21 §3, from topic-5 mapping). Trail chest gives regular new stickers; Trail final reward gives a Wild or a Super (dice65-pu-trail-2026-10-25 Q4).
- **Supers are the gate:** of payers one sticker short of a set, 92–95% miss a Super. Holding all 12 Supers ≈ finishing (94–96%); 10–11 Supers finish at 2–12% (dice-supers-mechanism-onepager §1–2; old population and old finish rule — directions hold, levels approximate).
- **Locked stickers:** 3 stickers per album (2 Supers + 1 Golden) reach 1% of holders only 3–6 days before close: 59 S143/S108/G141, 61 S143/S120/G142, 63 S143/S132/G129 (dice65-end; dice-completion-path-2026-11-02).
- **Difficulty depends on a pre-album segment:** Easy / Medium / Hard / Extreme from last-album spend (normalised to 70 days: <$100 / $100–400 / $400–1,000 / ≥$1,000). Players with no history start Easy (dice_album_user_segmentation.md, root). **What "difficulty" changes in the album: MISSING** (drop rates? sticker counts? not documented).
- **Free Wild gap:** in the last week free Wilds come in two bursts (Bonus Wheel close−8/−7, Trail final reward from close−3); on close−6..−4 only a paid Wild is available (dice-wild-sources-2026-10-21).

**MISSING**
- Daily new-sticker curve by player type and its stall points (exists for Domino only).
- What the difficulty segment changes, and whether Hard/Extreme players reach the gate at the same time as Easy.
- Trail layer reached vs purchases (boosters) — studio question.

**Next check:** only after topics 4 and 5; most of this topic is already known for the population. The open part is per player type (strong, first album).

**Journey link:** the "engine" chapter. Likely a **keep** message: steady supply, Trail always on.

---

## 3. How players reach a position from which completion is attainable
**Business question:** who is within reach before the final weekend, and how did they get there?

**Existing findings** (dice-completion-path-2026-11-02 §0; dice65-end-2026-10-24)
| Within 3 stickers at close−4 (Thursday before the final weekend) | 59 | 61 | 63 |
|---|---|---|---|
| % of payers | 35% | 16% | 30% |
| % of album revenue held by them (to close−4; 61/63 from dice65-end) | – | 39% | 54% |
- **By spend level** (album $ a day in the first 75% of the album; 63): ≤$2 = 65% of payers / 15% of revenue; $2–5 = 16% / 18%; $5–20 = 11% / 36%; >$20 = 2% / 31%. Within 3 at close−4 rises with level (63: 24% / 38% / 49% / 62%) (dice65-end).
- **Within-3 jumps when the lock opens:** Dice 6% → 30% of payers between close−6 and close−4 (topic5-sensitivity-2026-10-24).
- Far payers still get new rares until 3–5 days before close (10–13 in Domino/Disney) (far-rare-gate-gap-2026-10-23).

**MISSING**
- The path into "within 3": which sources and purchases moved a player from 6–10 missing to 1–3 (close−14..−4).
- Why 61 is so much lower (16%) — shorter album (35 days) or a different release calendar. Not checked.

**Next check:** part of the topic-4 journey reconstruction (below), with the window starting at close−14.

**Journey link:** the "approach" chapter between progression and the closing run.

---

## 4. Which journeys lead to completion  ← recommended start
**Business question:** what is the sequence that ends in 144, and what role does each step play (purchase, Trail, event reward, Wild)? This decides what to keep and where a lever could sit.

**Existing findings**
- **Late finishers buy the closer:** 9–11% of payers finish on close−3..close; 90–96% of them got a new sticker from a paid Wild or a paid sticker in those days (1–2 each); they bring 47–53% of final-weekend revenue (dice-completion-path-2026-11-02 §0).
- **Locked stickers of finishers** came from paid Wild 54–68%, bought directly 15–20%, Trail final reward Wild 9–15%, Blast grand prize 0–5% (61/63/65) (dice65-end Q2).
- **Final sticker:** a Super for 70–81% of finishers, via a Wild for 87–90%; the closing run starts at close−4/−3 (endgame-last-week-dice-2026-10-14 findings 1–2; old population).
- **Purchase timing:** 55–59% of finishers' new Supers in the last week arrive ≤10 min after a purchase vs 11–14% for Commons; placebo ≤0.9% (endgame finding 4).
- **Spend not tied to a sticker:** among near-finishers, 40–50% of purchases are not followed by any new sticker within 10 minutes; only 14–25% of their spend is followed by a new Super (onepager §5).
- Early finishers (144 by close−4) are 1–2% of payers and 5–7% of album revenue; they had the same pace as late finishers and did not make the end jump (63).

**MISSING**
- The **sequence** before the last sticker: Trail layers reached, event rewards, purchases (offer name, price), Wild fills, set completions — in time order, per finisher.
- Whether the paid-Wild step follows a Trail/event step (one journey) or replaces it (separate routes).
- Differences by pre-album segment, by album, and by finish timing (early / late).

**Challenge to the hypothesis ("purchase → Trail → reward → Wild → completion is one journey"):**
- For the **final** stickers the data points to a short route: a direct purchase of a Wild pack in the last 3 days (paid Wild 54–68% of locked stickers; Trail final reward 9–15%). Trail looks central **earlier** (≈50% of new Supers over the album), not at the finish.
- So there may be two journeys in sequence: Trail and events build the position (topic 3); a paid Wild closes it (topic 4). Whether a Trail booster purchase sits inside the first part is **MISSING**.

**Next check (the first one to run):**
1. **Linkage audit (cheap):** confirm which tables and fields exist for Wild receipt, Trail layer timestamps, purchase offer names and any Dice offer-exposure log. One album (63).
2. **Journey reconstruction:** for finishers of 59/61/63 and for the $5+ near payers who did not finish, list per player the last 5 new stickers and the 72 hours before each: purchases (time, offer, price), Trail layer reached, event reward, Wild fill. Label each link as "same offer name ≤10 min" / "≤60 min" / "same day only", with the placebo base rate. Group into a few journey types and size them (players, % of payers, % of album revenue).

**Journey link:** the core chapter. It also answers the open question from the completion path: why 85–87% of $5+ near payers do not buy the closer (did they buy something else, at what price, did a Wild offer exist).

---

## 5. Who almost finishes or remains far away, and how they behave
**Business question:** who pays and plays but stays behind, and how much revenue sits there?

**Existing findings** (dice-completion-path-2026-11-02 §0, base 59/61/63)
| Group (state at close−4) | Players · % of payers · % of album revenue | Behaviour |
|---|---|---|
| $5+ a day, 1–3 missing, did not finish | 7,974 / 5,995 / 8,803 · 4.0 / 3.1 / 4.3% · 22 / 16 / 21% | only 13–15% bought a Wild or sticker; 56–58% paid for something; spend 61–65% of own pace; miss 2.3 stickers, 2.0–2.3 locked |
| Not finished from 1–3, by level ≤2 / 2–5 / 5–20 / >20 | – | 83–88 / 74–78 / 70–74 / 59–62% |
| 4–6 missing (63) | 42.6% of payers · 34% | 9% finish; mostly ≤$2 |
| 11+ missing (63) | 17% · 7% | 2% finish |
- **Scenario (not a result):** 10% of the $5+ near group behaving like finishers ≈ $70K an album ≈ 0.3% of album revenue (assumptions in dice-completion-path §0ב).
- After close, >$20 payers who ended 1–2 short spend 23% below their normal week ($35K–77K a week, 0.1–0.3% of album revenue) (topic-t6).

**MISSING**
- Why the $5+ near group does not buy the closer (price, no offer shown, gave up earlier).
- High spenders who stay far: >$20 with 4+ missing at close−4 = 1,230 / 2,263 / 1,734 players (0.6 / 1.2 / 0.9% of payers, 7.5 / 12.8 / 9.8% of album revenue; 59/61/63); 16% of them finish. Known only from the completion-path CSVs; their history, pace and why they are far: not checked.

**Next check:** covered by topic 4 (journey reconstruction includes this group as the comparison).

**Journey link:** the "left behind" chapter; may stand alone as a finding even if topic 4 explains it.

---

## 6. After completion and the move to the next album
**Business question:** does finishing pay off after the album, and how do players start the next one?

**Existing findings**
- **Prize size in days of play:** half of Dice paying finishers get a prize worth 2+ days of their own play (Domino 1 in 4, Disney 1 in 7). The same 200K prize = 5 days for a ≤$2 payer, 1 day for >$20 (topic6-finisher-prize-2026-10-24; topic7-dice-prize-2026-10-25).
- **Return after close (finishers, $2–20):** Dice lowest of the three games in every album and level on the calendar-neutral index (1.50 vs 1.71 / 1.74) (topic6-calendar-neutral-return-2026-10-24). Stock at close < 0.1 day → not the reason. Payout test withdrawn.
- **>$20 finishers:** next-album start at 96% / 84% / 95% of own pace (61/63/65); the 63 dip is a one-album effect (topic7-top-payers-2026-10-24).
- **After 144 Dice gives:** Fortune Wheel + Lava Quest (rolls). Payers who finish 2+ days early = 6.5% of payers, 19% of album revenue (63) (early-finishers-event-2026-10-24). Proposal on file: TEST a post-album collection event (ev1/ev2).
- **Reward ladder:** the next album's prize code steps up if the player finished or reached the spend bar; code 7 (200K) is the top (dice_album_user_segmentation). Segment-7 $700+ finishers = 0.3% of players, 10–12% of album revenue; the prize lasts them 1.4 days (seg7-top-payers-2026-10-20).

**MISSING**
- What happens to **first-album** finishers and non-finishers in album 2.
- Whether players at the top reward code have any further album goal (ladder is capped).

**Next check:** none now. Revisit inside topic 7 (strong players at the reward cap) and topic 1 (first album → second).

**Journey link:** the closing chapter; partly done in the cross-game work.

---

## 7. Player types across the journey

### 7a. Very strong players (define strength BEFORE the album)
**Business question:** does the album give the strongest players goals and reasons to buy through the whole album, or do they finish on what they would play anyway?

**Existing findings**
- **Pre-album measures available:** album segment (last-album spend, Easy..Extreme) and reward code (1–7), both set at album start. History predicts the in-album spend group right for ~58% of revenue at 10% of the album (Dice 59% vs 50% for current spend); current spend wins from 25% of the album (approved-batch-2026-10-18 §2). ~15% of Easy payers (~18K per album) spend like Medium or higher (dice-segmentation-validation-2026-10-14).
- **In-album measures (a different question):** >$20 a day (first 75%) = 2–2.3% of payers, 31% of album revenue; finish 35% (63). Above p95 ($13.4 a day) = 33–35% of game revenue, finish 25–31% (dice-topic2-reruns-2026-10-22).
- **They finish earlier:** >$20 already at 144 by close−4: 6.4% (63), 14.9% (65) (dice65-end).
- **They still hit the gate:** 59–62% of >$20 who were 1–3 short at close−4 did not finish (59/61/63).
- **Not all their spend is album-linked:** see topic 4 (14–25% of near-finishers' spend is followed by a new Super).

**MISSING**
- Cross-tab of pre-album segment × in-album level: how many "historically strong" are strong now, and the reverse.
- Pace of progress (stickers by % of album time) for strong vs others; whether they reach the locked stickers earlier.
- Strong players who spend heavily but stay far (see topic 5).
- Share of their album-period spend that is followed by a sticker or Wild (album-linked) vs other spend, by week of the album.

**Challenge:** "strong players reach the same gates as everyone else" — yes for the locked stickers (fixed per album). But the difficulty segment may give them a different album, which is undocumented. Ask the Dice team what the segment changes before reading any strong-vs-easy comparison.

**Next check (second in order):** pre-album segment (Hard + Extreme) on 59/61/63: size (players, % of payers, % of album revenue), in-album level, finish rate and timing, progress curve, album-linked share of spend by week (timing rule from topic 4).

### 7b. First-album players → topic 1.

### 7c. Light payers (≤$2) — context only
65% of payers, 14–15% of album revenue (63). Most of the far group. Low revenue weight; keep as context unless a first-album finding points here.

---

## 8. Priority grid: stage × player type
| Stage ↓ / Player → | All payers (base) | Strong, pre-album (Hard/Extreme, code 7) | First album | $5+ near, not finished |
|---|---|---|---|---|
| 1 Start & first progress | known (supply) | low | **HIGH** (topic 1) | – |
| 2 Middle: sustain / barriers | known | medium (what difficulty changes) | medium (first stall) | – |
| 3 Reaching the position | partly known | medium | medium | – |
| 4 Journeys to completion | **HIGH** (topic 4) | **HIGH** (topic 7a) | low (few finish) | **HIGH** (comparison group) |
| 5 Almost / far | known (completion path) | medium (heavy spend, still far) | – | known; *why* = topic 4 |
| 6 After & next album | known (topic 6) | medium (reward cap) | **HIGH** (album 2) | low |
Bold = recommended combinations. Others stay as context.

---

## 9. Initial story outline (to be shaped by the evidence)
1. **The Dice album is a steady machine** — rares every 4 days, Trail always on, the end lifts revenue in every typical album. (Known; keep.)
2. **Progress builds through Trail and events; three locked stickers open in the last 3–6 days.** (Known.)
3. **Reaching the final weekend within 3 stickers:** 16–35% of payers. (Known; the path into it is open.)
4. **The closing journey:** a paid Wild over the final weekend closes the album for 90–96% of late finishers. Is it one journey with Trail, or a separate final step? (Topic 4, open.)
5. **Who stays behind:** $5+ payers near the end who rarely buy the closer — 3–4% of payers, 16–22% of album revenue. (Known; why is open.)
6. **Two special journeys:** strong players (pre-album) and first-album players. (Open chapters.)
7. **After the album:** big prizes for light payers, a capped ladder for the strongest, and the weakest return of the three games. (Known; first-album and cap angles open.)
- **Standalone findings to keep:** early finishers move spend earlier rather than lose it (63); album 65 as a one-album exception; the Dice first-album label fix (19–22K returning payers were missing).

---

## 10. Recommended research order
1. **Topic 4 — journey to completion (start here).** First a short linkage audit, then the journey reconstruction for finishers and the $5+ near group, 59/61/63.
   - *Why first:* it answers the central question directly, it covers the group with the most revenue at stake (late finishers 21–25% of album revenue; near non-finishers 16–22%), the building blocks exist (timing rule, placebo, locked stickers, completion path), and the linkage audit tells us what every later topic can claim.
   - *What it unlocks:* the role of Trail vs purchase vs Wild; why the near group does not buy; whether a closing offer or a free-Wild change in close−6..−4 is worth a test; the method for topics 7a and 1.
2. **Topic 7a — strong players defined before the album.**
   - *Why second:* 31% of album revenue; uses the journey method; tests "do they buy to finish or finish anyway".
   - *What it unlocks:* whether the album gives them goals through the run (reward cap, difficulty segment) — a possible design change rather than an offer.
3. **Topic 1 — first album (definitions with Eden first, can be agreed in parallel).**
   - *Why third:* 7–8% of game revenue now, but it feeds every later album; the current evidence does not show a problem yet, so the first check should be descriptive (entry timing, first rares, album 2).
   - *What it unlocks:* whether new players need a different first album; the album-2 transition (topic 6 for new players).
- **Not now:** topic 2 (mostly known), topic 6 (known; revisit inside 7a and 1), light payers.

## Questions for the Dice team (would change what we can claim)
1. What does the difficulty segment (Easy..Extreme) change in the album?
2. Which Trail layer gives the Wild, and who is eligible?
3. Is there a log of offers shown (exposure) in Dice?
4. Is Wild receipt logged separately from Wild use?
5. Are Trail boosters sold, and can a purchase be tied to a Trail campaign?
