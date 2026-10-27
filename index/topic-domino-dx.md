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
## Read in order
c/domino-dx-map-2026-10-25.md → c/domino-dx-t1-t2-2026-10-25.md → c/domino-dx-t2-effort-3-vs-45-2026-10-26.md → c/domino-dx-t4-2026-10-25.md → c/domino-dx-last3-sources-2026-10-26.md → c/domino-dx-end-lift-2026-10-26.md → c/domino-dx-easy-end-decomp-2026-10-26.md → c/domino-dx-t1-story-check-2026-10-26.md
## SQL (sql-catalog §Domino dx)
c/domino_dx_gate_structure · _close4_buckets · _t2_within_level · _gate_joker_source · _t1_mix_vs_behavior · _t4_puzzle_jokers (10-25) · _t2_effort_3_vs_45 · _t2_reach3_by_c3 · _test_population_c7 · _end_lift · _easy_end_decomp (Q6–Q8 = last3) · _t1_story_check (10-26)
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
Generators: `python3 c/slide_domino_chapter_2026-10-26.py <dxw|dxsrc|dxfar|dxrec> [idx]` (layoutId p12, no BLANK in this deck's master; inserted before the thank-you slide). `dx_t1t2_slides.py <revisionId> <idx>` uses predefined BLANK.
## Open
- Pixie (topic 5), prizes vs effort (6), Royals/Momentum (7) not done (map §ג). Questions for the Domino team in map §ד.
- Joker offer funnel needs staging approval (topic 3).
- **Superseded (10-27):** c/slide_domino_joker19v20_2026-10-27.py (two-panel dxjk) → c/slide_domino_end_wave_2026-10-27.py joker.
