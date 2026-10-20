# Cross-Game Album Benchmark — content pack for the deck (13 Oct 2026)

Paste into Claude Design (SuperPlay Design System) to build the deck.
Audience: all three studios (Dice Dreams, Domino Dreams, Disney Solitaire) + CRO.
Deck rules: minimal text, one conclusion title + one chart per slide, one takeaway line. Each studio section ends with its own findings and a status per item: **Recommendation (Test)** / **Do Not Adopt Yet** / **Fact only**. No causal claims; any lever = A/B test.
Game colors (use the design system's if it defines game colors): Dice = blue, Domino = orange, Disney = teal. One highlight color for "the conclusion".
Albums: Dice 61/63 (12 Supers), Domino 17/19 (8/9 Royals), Disney 14/15 (7 Royals). 144 set stickers in every album. Rare = Super (Dice) / Royal (Domino, Disney).
Population (unless noted): payers (PU), login ratio ≥ 0.5, close day excluded; rare-source work excludes players in their first album.

---

## Part A — Shared slides

### A1. Title
Cross-game album benchmark · Dice · Domino · Disney · draft 13 Oct 2026

### A2. Three things to know (big numbers)
1. **1.16–1.25×** — album-end ARPDAU lift in Dice (Domino 1.13–1.23×, Disney 0.98–1.06×).
2. **92–95%** — Dice payers one sticker short of a set are short a Super: the rare is the final gate.
3. **~50%** — share of new Dice Supers from one recurring event (Trail); Domino/Disney rely on rotating one-off events.

### A3. Status (small visual: 13 tiles, colored by state)
Done: T1 first exposure, T2 population + album-end, T4 rares, T5 sources, Dice Supers mechanism. Not started: T3 duration/ending, T6–T13.

### A4. Chart — Time to first album (Topic 1)
Title: "Domino payers reach the album on day 1; Dice and Disney on day 3"
Chart: horizontal range bar per game, active days install→first album, payers before exposure. Bar = P25→P75, tick = P50, dot = P90.
| Game | P25 | P50 | P75 | P90 | Within 3 active days | Within 7 |
|---|---|---|---|---|---|---|
| Dice (K8) | 2 | 3 | 6 | 23 | 60.5% | 79.5% |
| Domino (L35) | 1 | 1 | 2 | 3 | 94.5% | 99.4% |
| Disney (L100) | 2 | 3 | 5 | 8 | 51.4% | 87.8% |
Takeaway: faster exposure does not come with higher early retention (Domino D1–D14 lowest). Earlier gate = Do Not Adopt Yet.

### A5. Chart — Revenue share by albums experienced (Topic 2)
Title: "Veteran players (7+ albums) carry 37–57% of revenue"
Chart: 100% stacked bar per game, segments 1st / 2–3 / 4–6 / 7+ (Sept 2026 revenue share).
| Game | 1st | 2–3 | 4–6 | 7+ |
|---|---|---|---|---|
| Dice | 4.2% | 23.6% | 14.9% | 57.3% |
| Domino | 11.8% | 17.7% | 21.0% | 49.6% |
| Disney | 11.5% | 19.0% | 32.3% | 37.2% |
Note: old album counter — rerun under 18-month rule before final (Needs validation).

### A6. Chart — ARPDAU by albums experienced (Topic 2)
Title: "Per active day, Disney players spend less with every album; Dice peaks at 2–6"
Chart: line per game, x = 1st / 2–3 / 4–6 / 7+, y = daily ARPDAU (Sept 2026 daily average).
| Game | 1st | 2–3 | 4–6 | 7+ |
|---|---|---|---|---|
| Dice | 0.83 | 1.76 | 1.72 | 1.12 |
| Domino | 0.80 | 0.84 | 0.87 | 0.82 |
| Disney | 1.23 | 1.01 | 0.87 | 0.76 |

### A7. Chart — Album-end lift (Topic 2 follow-up)
Title: "The last four days lift ARPDAU in Dice and Domino; Disney stays flat"
Chart: line per game, x = player's album number 1…7+, y = ratio (last 4 full days ARPDAU ÷ whole-album ARPDAU), reference line at 1.0. Median across albums, installs since Apr 2025.
| Game | 1 | 2 | 3 | 4 | 5 | 6 | 7+ |
|---|---|---|---|---|---|---|---|
| Dice | 1.16 | 1.20 | 1.25 | 1.19 | 1.24 | 1.22 | 1.23 |
| Domino | 1.13 | 1.16 | 1.23 | 1.18 | 1.17 | 1.15 | 1.14 |
| Disney | 1.01 | 0.98 | 1.03 | 1.03 | 1.04 | 1.04 | 1.06 |
Takeaway: lift is album-specific (Dice 53/57, Domino 14/18, Disney only album 8). Disney is not front-loaded (first 25% of album = 24% of revenue in all games).

### A8. Chart — Rare collection curve (Topic 4)
Title: "Dice payers collect rares sooner and end closer to the full set"
Chart: line per game (one album per game or both, dashed for second), x = % of album time, y = median % of rares held.
| Album | 10% | 25% | 50% | 75% | 90% | 100% |
|---|---|---|---|---|---|---|
| Dice 61 | 8 | 17 | 33 | 50 | 67 | 75 |
| Dice 63 | 8 | 25 | 33 | 58 | 67 | 83 |
| Domino 17 | 0 | 13 | 25 | 50 | 63 | 75 |
| Domino 19 | 0 | 11 | 22 | 33 | 56 | 67 |
| Disney 14 | 0 | 14 | 29 | 57 | 57 | 71 |
| Disney 15 | 0 | 14 | 14 | 43 | 57 | 57 |
Side stats (small): first new rare day Dice 3–5 / Domino 8 / Disney 7–10; days between new rares 4–5 / 6–7 / 6–7; rares received incl. duplicates 14–18 / 7 / 5–6.

### A9. Chart — Where new rares come from, by album quarter (Topic 5)
Title: "Most new rares come from MTX events — one recurring Trail in Dice, rotating events elsewhere"
Chart: small multiples, one 100% stacked column set per album (Q1–Q4). Use the existing chart topic5_rare_sources_by_quarter_v4.png as reference; data in project doc claude/topic5-5d-v3-domino-first-royal-gift-2026-10-13.md.
Category share (Q1/Q2/Q3/Q4):
| Category | Dice 61 | Dice 63 | Domino 17 | Domino 19 | Disney 14 | Disney 15 |
|---|---|---|---|---|---|---|
| Trail event | 50/68/74/21 | 38/62/60/27 | 9/8/4/3 | 9/13/10/12 | 0/12/0/0 | 0/2/0/19 |
| One-off MTX events | 40/25/17/49 | 51/29/30/50 | 76/57/29/38 | 42/59/48/46 | 65/39/66/49 | 47/55/66/45 |
| Momentum | – | – | 6/5/12/9 | 9/14/24/7 | 0/9/4/8 | 11/2/2/4 |
| Long feature | 0/1/0/0 | 1/0/1/0 | 0/18/30/0 | 0 | 18/26/22/19 | 31/36/25/10 |
| Daily / free gift | 9/5/6/6 | 10/8/9/8 | 9/8/3/3 | 38/12/7/3 | 16/13/5/11 | 10/5/7/16 |
| Closing Market | – | – | 0/1/3/14 | 0 | 0/0/0/10 | 0/0/0/2 |
| Paid offer | 1/1/1/11 | 0/0/0/11 | 0/1/1/3 | 2/1/0/10 | 0/0/2/2 | 0/0/0/3 |
| Dup exchange | 0/0/0/12 | 0/0/0/3 | 0/0/18/30 | 0/0/11/23 | 0 | 0 |
Pending: event regrouping (Promo / Mini game / PB / MTX challenge / Quest / Other) — Disney done, Domino waiting for the Domino team.

### A10. Chart — The last quarter switches to closing mechanisms (Topic 5)
Title: "Every game ends the album with a closing mechanism — each a different one"
Chart: grouped bars, Q4 share of new rares by closing mechanism per album.
| Album | Paid / Wild offers | Dup exchange | Market |
|---|---|---|---|
| Dice 61 | 11 | 12 | – |
| Dice 63 | 11 | 3 | – |
| Domino 17 | 3 | 30 | 14 |
| Domino 19 | 10 | 23 | 0 |
| Disney 14 | 2 | 0 | 10 |
| Disney 15 | 3 | 0 | 2 |

---

## Part B — Per-studio sections

### B1. Dice Dreams
| Finding | Evidence | Status |
|---|---|---|
| Supers are the final completion gate | 92–95% of payers one sticker short are short a Super; 68–77% of finishers' last 3 stickers are Supers (baseline 8%); holding all 12 ≈ finishing (94–96%) | Fact only |
| The gate is closed through Wild offers | 78–84% of final Supers via Wild; last Super follows a purchase within 10 min for 63–70% (timing only, placebo pending) | Fact (needs validation) |
| A missing Super raises how many payers convert at the end, not the ticket | Missing Super at close−5: 82–84% pay in last 4 days vs 68% when a Golden is missing; revenue per paying day similar ($35–45 vs $33–48) | Fact only |
| Payers plateau at ~10 of 12 Supers; late receipts are duplicates | Median 9–10 of 12 at end; last-quarter new-rare rate 43–46% vs 51–68% earlier | Fact only |
| ~Half of new Supers come from one event (Trail) | Trail 38–74% of new Supers in Q1–Q3, 21–27% in Q4 | Fact only |
| More Super slots (12 → N) | Mechanism above; descriptive | **Recommendation: Test** (A/B, primary payer ARPDAU, guardrails finish rate + next-album retention) |
| Steadier free Super source (e.g. one Super in Daily calendar) | Dependence on Trail | **Proposal: Test** (not agreed with Dice team) |
| First-album players bring only 4.2% of revenue (11–12% in other games) | Topic 2 | Fact only (rerun pending) |
Charts for this section: (1) big-number row 92–95% / 68–77% / 78–84%; (2) bars "paid in last 4 days": Super-missers 82–84% vs Golden-missers 68%; (3) funnel diagram: steady accrual → plateau at 10/12 → duplicates → Super gate → Wild offer.

### B2. Domino Dreams
| Finding | Evidence | Status |
|---|---|---|
| Fastest first-album exposure (median 1 active day) | Topic 1 | Fact only |
| Strong album-end lift, peaks at album 3 (1.23×) | Topic 2 | Fact only |
| Royals come in pulses from rotating one-off events | One-off events 29–76% per quarter (Challenge 37% of Q1 album 17; Puzzle 31% of Q1 album 19; Blast 27% of Q4 album 19) | Fact only |
| Duplicate exchange is the main closing source | 23–30% of Q4 new Royals | Fact only |
| Momentum puts a Royal on ~3 of 4 album days | 30/39 and 38/49 days; peaks at 24% of Q3 new Royals (album 19) | Fact only |
| Royal Tower launch gift reached ~20% of veteran payers in album 19 | 23.5K gift Royals = 19% of Q1 new Royals | Needs validation (targeting) |
| Payers end with 67–75% of Royals; first Royal on day 8 | Topic 4 | Fact only |
| Is the Royal the final completion gate (as in Dice)? | Not measured | Missing → next analysis |
Charts: (1) Q4 closing mix (dup exchange vs Market vs paid); (2) event pulses timeline (top source per quarter); (3) Momentum Royal days calendar strip.

### B3. Disney Solitaire
| Finding | Evidence | Status |
|---|---|---|
| Album-end lift is near flat (0.98–1.06×) | Topic 2; only album 8 was strong (1.18–1.40×) | Fact only |
| Spend is not front-loaded | First 25% of album = 24% of revenue, same as Dice/Domino | Fact only |
| Ending-period lift from Dice/Domino | Album-specific, not tied to a mechanic | **Do Not Adopt Yet** → needs ending calendar (Topic 3), then A/B on the ending period |
| ARPDAU falls with every album group ($1.23 → $0.76) | Topic 2 | Fact only |
| First-album players: highest payer rate of any group (26.3%) | Topic 2 | Fact only (Hypothesis: L100 gate selects committed players) |
| Magical Friend is the steadiest Royal source | 18–36% of new Royals every quarter | Fact only |
| Event mix: Promo Wheel 31% of album 14; Mini games 41% of album 15 | Promo = 4 wheel campaigns (07-19, 07-28, 08-06, 08-20), none in album 15 | Fact only |
| Royals look release-gated | Narrow first-Royal window; album 15 jumps to 92% new at 50–75% | Hypothesis → needs Royal release calendar |
| Payers end with 57–71% of Royals; 2–3% end with none | Topic 4 | Fact only |
Disney event groups: Promo (black-friday-wheel) 31% / – · Mini game (gamified_8box, Sugar Rush, scrolling, merge event, trivia, art-studio, fortune_flight, mini_collection) 18.5% / 40.9% · PB (challenge) – / 4.7% · MTX challenge (blast, trails, mtx challenge, marketplace, farmers-market-chef) 7.6% / 11.6% · Other 4.0% / 4.1% (album 14 / 15).
Charts: (1) end-lift line vs Dice/Domino with 1.0 line; (2) donut or bar of event groups album 14 vs 15; (3) Royal collection curve with the album-15 mid-album step.

---

## Part C — Decision table (one slide, visual matrix)
| Mechanic | Studio | Evidence | Validation | Status |
|---|---|---|---|---|
| More Super slots (12 → N) | Dice | Super = final gate (descriptive) | A/B: ARPDAU + finish guardrail | Test |
| Steadier free Super source | Dice | ~half of Supers from Trail | A/B | Test (proposed) |
| Earlier first-album gate | Domino → Dice, Disney | No retention link | A/B on gate | Do Not Adopt Yet |
| Ending-period lift | Dice, Domino → Disney | Album-specific | Ending calendar, then A/B | Do Not Adopt Yet |
| "Disney has 7 rares" as rationale | — | Cross-game count, confounded | — | Do Not Adopt Yet |

## Part D — Next steps
Analysis: placebo for purchase → last Super timing; Topic 3 (album calendar, ending); Topics 6–13; Royal-as-gate for Domino/Disney.
Studio input: Domino event grouping + Royal Tower gift targeting; Disney Royal release calendar, Joker flag, paid events; Dice Super release calendar.
Data: rerun Topic 2 population table (18-month rule); revenue column check Domino/Disney; paid vs free inside MTX events.

