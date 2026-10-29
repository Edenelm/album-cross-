# Domino diagnosis "dx" chapter + Domino deck (10-25/26; merged to main via PRs #30/#31)
Eden's 7-topic Domino diagnosis for product decisions. Albums 19 (Jul 6–Aug 24) and 20 (Aug 24–Oct 12); 17/18 = trend check only (18 has 14 sets). Project `domino-dreams-dbt`. Older Domino work (easy end pays twice, 19 vs 20 of 10-18): index/topic-domino-cases.md.
**Deck:** Domino-focused Google Slides 1bVGI1Sb49fJ-a4Cp8AHs5hTOYjrTuQlJbW9vStaJr1o (map below).
## Key findings
- **Gate (from data):** album 20 = 3 Joker-only stickers (R119/R120/G139) for Easy and Hard; album 19 = Easy 5 / Hard 3; 17 none, 18 two Royals. Not stable across albums, no control group (domino-dx-map-2026-10-25).
- **Within the same spend level** 3 vs 4–5 missing at close−4 differ by only 1–3 pts in finish rate; 1–2 vs 3 by 20–30 pts (already got a Joker) (domino-dx-t1-t2-2026-10-25).
- **3 vs 4–5 effort:** "everyone reaches 3 by close−3" is not supported (25–44% of 4–5 stay 4+). 3-missing bring 13–19% more in close−3..−1, from more of them paying (domino-dx-t2-effort-3-vs-45-2026-10-26).
- **Two puzzle Jokers in 20** = JokerPuzzle (to close−4) + SummerFeverPuzzle (last 4 days, 60% used 2). 19 had one puzzle Joker (domino-dx-t4-2026-10-25).
- **Last 3 stickers of finishers, album 20:** 81% via a Joker from free end events; paid Joker offers 6%. Strong ends (18, 20) are the only albums with a JokerPuzzle from ~close−14 (domino-dx-last3-sources-2026-10-26).
- **Easy far:** 4+ missing at close−4 = 79.5% of Easy payers, 23.7% of game revenue (album 20). They are active and miss released rares, not commons (same doc §2).
- **End lift (game):** revenue +25.3 / +7.8 / +18.9% (18/19/20); active players fall in every end. Not attributable to the gate; the week before was as strong in 20 (domino-dx-end-lift-2026-10-26).
- **Easy ARPDAU end lift decomposition (17–20):** no single component; 17/19/20 = pricier album/Joker offers ($8–13), 18 = July 4 sale (domino-dx-easy-end-decomp-2026-10-26).
- **Story check:** album 20 = slight ARPDAU recovery from 19, not an improvement; revenue/day keeps falling with DAU (−10%) (domino-dx-t1-story-check-2026-10-26).
- **Test population (close−7, Easy, album 20):** 3–5 missing = 9,448 (10% of payers, 11.5% rev); 6–8 = 39,931 (41%, 20.7%). The 36,734 on the slide is the close−4 state (domino_dx_test_population_c7 → effort doc).
- **FU (10-27, dxfu_slide):** Easy payers who reached FU and did not finish = 36,348, 34% of payers, 29% of album revenue; $2–20/day 11,470 / 11% / 20%; finish rate from FU 14/17/27/58% by level (domino-easy-gate-stuck-2026-10-27).
- **GoldenKiosk (10-27, album 20, 10-05..07):** 34,506 standard payers got a new rare (32% of payers, 34% of album rev). Easy 6–10 missing at close−8: reached FU 68% vs 56%, finished 10% vs 8% (correlation, no control) (domino-goldenkiosk-std-2026-10-27).
- **19 vs 20 end supply (10-27):** Joker wave close−4/−3 in 20 vs close−2/−1 in 19; bought Goldens same (2–6%/day); album 19 had MORE gameplay rares on days −10..−6 → difference = timing, not amount (domino-end-rares-jokers-19v20-2026-10-27).
- **Hard check (10-27):** Hard gate 3 in both albums, yet Hard payers finished 22% → 32%, far on close−1 47% → 26%; Easy 4% → 8%, 87% → 57%. Gate size alone does not explain 19→20 (domino-19v20-by-segment-2026-10-27).
- **Base + correction (10-27):** whole chapter uses % of album revenue (standard-population payers), domino-chapter-album-rev-base-2026-10-27. Eden: puzzle Jokers were not free (very hard last tier, players paid to finish); RV finishers worth little revenue. Slide rules (CLAUDE.md on main) checked on all chapter slides.
- **FU18 A/B test (10-29, album 18 Easy, FU 3 vs 5 locked):** 3 locked did not cost album revenue (+0.16% after the pre-test gap); finishers 3.36% vs 1.27% (2.6×); under 5 locked 38% of Easy window revenue sat at 3–5 missing; one cost = ~4-pt spend dip in the 14 days after close (−5.36% vs usual −1.28%), gone by album 19 end; GP coins explain ~0%. Rec: back to 3 locked for Easy. Domino deck slides 135–138 (c/domino-fu18-ab-test-2026-10-29.md, SQL c/domino_fu18_ab_test_2026-10-29.sql). Cumulative 06-28..09-07: −2.7% [−5.6, +0.1], −1.6% net; the drop sits in players at FU before the test (1.3% of players, 16% of revenue): −9%, album 19 −13% (c/domino-fu18-cumulative-2026-10-29.md).
## Read in order
c/domino-dx-map-2026-10-25.md → c/domino-dx-t1-t2-2026-10-25.md → c/domino-dx-t2-effort-3-vs-45-2026-10-26.md → c/domino-dx-t4-2026-10-25.md → c/domino-dx-last3-sources-2026-10-26.md → c/domino-dx-end-lift-2026-10-26.md → c/domino-dx-easy-end-decomp-2026-10-26.md → c/domino-dx-t1-story-check-2026-10-26.md
## SQL (sql-catalog §Domino dx)
c/domino_dx_gate_structure · _close4_buckets · _t2_within_level · _gate_joker_source · _t1_mix_vs_behavior · _t4_puzzle_jokers (10-25) · _t2_effort_3_vs_45 · _t2_reach3_by_c3 · _test_population_c7 · _end_lift · _easy_end_decomp (Q6–Q8 = last3) · _t1_story_check (10-26)
## Chapter order (Domino deck, 2026-10-27, story: pain → improvement → still open → recommendation)
dxdiv_main → t5ad (pain + 19→20 improvement) → dxchg (what changed 19→20; Hard gate unchanged yet Hard improved) → dxsrc (how finishers closed in 20) → dxw (end lift, caveat) → dxfar (Easy still far) → ehline → ehlast → ehnear (Easy falls behind through the album) → dxrec → thanks → dxdiv_app → dxend, dxgate, old divider, dxdist, dxtest, dxmix. ehgap stays after the cross-game "Rare Gap Widens" slide.
Open: dxtest (3–5 missing, 9,448) vs dxrec (6–12 missing, 59,648) test audience not reconciled.
## Domino deck map (all rows **unverified, check live deck**; positions unknown)
| Code | Title | Source doc | Script |
|---|---|---|---|
| dxend_slide (≈ slide 101) | Easy end-of-album ARPDAU, 17–20 | domino-dx-easy-end-decomp (defs) | none in repo |
| dxgate_slide | End Gate by Segment: Album 19 vs Album 20 | domino-dx-map | c/deck_domino/dx_t1t2_slides.py |
| dxdist_slide | Finish Rate by Stickers Missing 4 Days Before Close, Same Spend Level | domino-dx-t1-t2 | same |
| dxmix_slide | Revenue per Player, Album 19 vs 20: Same Players vs Player Mix | domino-dx-t1-t2 | same |
| dxtest_slide | Test: Earlier First Gate Joker for Easy Players | domino-dx-t2-effort (sizes) | same |
| dxw_slide | Which End Worked Better? Easy ARPDAU in the Final 4 Days, 17–20 | domino-dx-easy-end-decomp | c/slide_domino_chapter_2026-10-26.py |
| dxsrc_slide | How Finishers Got Their Last 3 Stickers, 17–20 | domino-dx-last3-sources | same |
| dxfar_slide | Most Easy Payers Are Still Far 4 Days Before Close: Album 20 | domino-dx-last3-sources §2 | same |
| dxfu_slide (before dxrec) | Easy Payers Who Reached FU: % Who Finished, by Spend Level | domino-easy-gate-stuck-2026-10-27 | c/slide_domino_fu_2026-10-27.py |
| dxjk_slide (after dxchg) | % of Payers Who Got a Joker from Gameplay per Day: Domino 19 vs 20 (one chart, rebuilt 10-27) | domino-end-rares-jokers-19v20-2026-10-27 | c/slide_domino_end_wave_2026-10-27.py joker |
| dxgold_slide (after dxjk) | % of Missing Goldens Collected per Day, Last 10 Days: Domino 19 vs 20 | same (addendum) | c/slide_domino_end_wave_2026-10-27.py gold |
| dxrec_slide | What to Do in Domino: Keep One Thing, Test Two (rebuilt 10-27: KEEP Kiosk+Joker route, TEST 1 FU offer, TEST 2 earlier rares) | domino-goldenkiosk-std / domino-easy-gate-stuck 2026-10-27 | c/slide_domino_dxrec_2026-10-27.py |
| t5ad_slide (right after t5a_slide) | End Status of Payers by Spend Level: Domino 19, Domino 20, Dice 63 | end-status-d19-d20-dice63-2026-10-26 | c/slide_t5a_domino_2026-10-27.py (10-27) |
| ehgap_slide (after "The Rare Gap Widens in the Last 10%") | Royals Held at 90% of Album Time and at Close: Domino Easy vs Hard | domino-easy-hard-splits-2026-10-26 §1 | c/slide_domino_easy_hard_2026-10-27.py (10-27) |
| dxchg_slide (after t5ad) | What Changed at the End of the Album: Domino 19 vs 20 | domino-19v20-by-segment-2026-10-27 + map/t4/last3 | c/slide_domino_19v20_changes_2026-10-27.py (10-27) |
| ehline_slide (after ehgap_slide) | % of the Album's Royals Collected, by % of Album Time: Domino Easy vs Hard (album 20 lines + 3 panels) | domino-easy-hard-splits-2026-10-26 §1b | c/slide_domino_royals_line_2026-10-27.py (10-27) |
| ehlast_slide (after "Day of the Last New Rare") | Day of the Last New Royal, P50–95 Payers Who End Far: Domino Easy vs Hard | same §2 | same |
| ehnear_slide (after near7b_slide) | Revenue Share Within 3 Stickers, by Day Before Close: Domino Easy vs Hard (close−7/−4/−1; full series in notes) | same §3 | same |
Generators: `python3 c/slide_domino_chapter_2026-10-26.py <dxw|dxsrc|dxfar|dxrec> [idx]` (layoutId p12, no BLANK in this deck's master; inserted before the thank-you slide). `dx_t1t2_slides.py <revisionId> <idx>` uses predefined BLANK.
## Open
- Pixie (topic 5), prizes vs effort (6), Royals/Momentum (7) not done (map §ג). Questions for the Domino team in map §ד.
- Joker offer funnel needs staging approval (topic 3).
- **Superseded (10-27):** c/slide_domino_joker19v20_2026-10-27.py (two-panel dxjk) → c/slide_domino_end_wave_2026-10-27.py joker.
## Deck order (live, 2026-10-27, Eden approved)
104 dxdiv_main → 105 dxchg → 106 Eden: Easy rev by missing c−4 19v20 → 107 Eden: finishers per day → 108 dxgold → 109 dxjk → 110 Eden: daily rev vs weekday → 111 dxsrc → 112 Eden: same spend different gate → 113 dxtrans → 114 dxlast (c/slide_domino_far_last_royal_2026-10-27.py) → 115 dxfu → 116 dxrec → 117 thanks → 118 dxdiv_app → appendix: dxw, dxfar, ehlast, ehnear, dxend, dxgate, old divider, dxdist, dxtest, dxmix, ehgap.
- **10-28:** Domino 19 copies under cross-game slides = deck map §H. Album 19 fell behind 20 only after day 33 (m19). Domino 19 golden-buy share last day 2.3% (gb19).
- **10-28 story (19 vs 20):** buying of Goldens is the same in both; album 20 gave two FREE waves — wave 1 d−18..−12 (ColoringBook, Trail, events, +5 stickers a payer) put 21% of payers within 6 stickers by d−11 (vs 6%); wave 2 d−7..−3 (Kiosk, ColoringBook, Jokers, +2). Royals: same supply (~3 a payer in 20 days), same end per distance group → Royal gate is the remaining block (TEST 2). Kiosk users spent more, not less (no cannibalization seen; who saw it unknown). 18+20 (end lift +20%/+11%) had ~2x payers near FU at close−4 vs 17+19 (+4%). Slides: wv, gw, gsrc, ry (after dxgold), dlw, nfu. Docs: domino-sources-d20-d11, domino-19v20-golden-sources-by-day, domino-royal-sources, domino-royals-by-distance, domino-kiosk-cannibal-20, domino-near-fu-c4-17-20, domino-end-arpdau-weekday-17-20 (all 2026-10-28).

## Final deck review 2026-10-28 (deck 1gHkK8mNPg5pDKwlIe3FdMSqq2UqQx2bPihgu4ve_mks)
Slide-by-slide review of the Domino story done through slide 81 (live edits, Eden approved each). Deck pattern: each topic = 3-game slides then Domino 20 vs 19 — do not move slides across it.
Key changes: labels/denominators unified to album revenue (Easy 92% payers · 55% album rev); per-day sticker bars = mean; rares-by-time charts redrawn on latest album (Dice 80 / Domino 67 / Disney 61% at close); slide 64 Domino column (Royals not sold, main source rotating events); test audiences sized (Golden pick option C: Domino 20 14,417 · 13.5% · 37% rev; Steady Royal option C: Domino 20 19,723 · 18% · 20%, Disney 15 62,701 · 19% · 25%); tx_royal rebuilt for Domino (Control + Steady Royal / Royal Kiosk / Royal via Joker / Joker earlier).
Next: slide 82 ("In Brief") onward. Handoff: claude/next-session-prompt-2026-10-28.md.

## Final deck 2026-10-29 (Eden: this is the final Domino deck)
Eden reordered the deck (125 slides). Review of 113–120: proposed cutting fu1/fucase/fu4 as repeats; Eden deleted fucase and fu4 herself, kept fu1. Slide 3 agenda rebuilt to 10 chapters (map in deck.md §FINAL). Slide 124 Recommendations and Test Order rebuilt on what the deck now holds: Domino Easy 3 locked ADOPT first (only recommendation backed by a randomised test in Domino), album-20 end ADOPT, Dice post-album event, Domino/Disney Goldens and Royals (Golden pick 37%/11%, steady Royal 20%/25% of album revenue), near-finishers Disney first, Domino RV coins+energy, Dice One-Day Trail (Eden's row); Dice $2K+ prize row removed (its slides are gone). Notes + Source lines updated on both slides.


## FU Joker-offer pricing, album 20 (2026-10-29) — `claude/domino-fu-pricing-hypothesis-2026-10-29.md`
At FU the CZ price bands of 4 Joker offers (1+9 Album Joker, 1+12 Joker card, Buy Them All+, 1PO Joker) are narrower, so the price step is higher; puzzle offers have no FU price. Test 1591, randomised, 5–11.10 (`FU Pricing Joker Test`: Control = higher FU price, Test = smaller raise; 137,670 players = 15% of active, 73% of album revenue). Result: higher price → 15% fewer Joker-offer buyers, −10% $ on them, +0.17 points puzzle-offer buyers; total window spend, non-buyers and finish rate the same (±6%). Puzzle route to finish 1.52% vs 1.37%. Album 21 days 1–14: Test −3.5% vs own pre [−6.6%, −0.4%], same payers and activity, gap mostly in >$20 payers; not the test running on, not CZ → keep the usual raise. Slides p91a–d after fu6 (c/slide_test1591_2026-10-29.py). Open: FU rule, Jokers per offer (Domino team). SQL: domino_fu_pricing_mechanism / domino_fu_pricing_test (2026-10-29).
