# Decks overview (open the deck map row first, then only its source doc, SQL and script)
Slide numbers shift, so rows are keyed by the slide objectId or short code (s6a, t7a, p24fix…). Anything not confirmed in the repo files is marked **unverified, check live deck**.
| Deck | ID / link | Role now | Map |
|---|---|---|---|
| **ALBUM END** (Google Slides, Eden's working deck) | 1vtwRvOAocgcZfrxl8uBfpOzIt7wkGbkCtxEBgFB4FvM | Main deck for the topic-by-topic story (topics 3–9 built here; rule: add, never delete) | deck-album-end.md |
| "Copy of ALBUM END" | 1rUG2NSBJD2worjTyQyKf_iiprL6feUQUuaKAlsJyllE | Topics 0–3 slides 11–19 were built here on 10-22 (data-story-review). The relation to ALBUM END is **unverified** (conflicts C14) | deck-album-end.md §A |
| **Part 1** "Album Analysis Across Three Games, Part 1" | 1WS07a_8A_IDJ1HndTBG34qHD5-sJx8WNDzhVAkv3zwQ | Google Slides export of evidence deck v82, opening to chapter 7. Still being edited (p24fix, p24rec, slide 31) | deck-part1.md |
| Part 2 | 1CQVnRMrtzWG_j6MQebUKuErP5TDUYmQJaFG_FUvwJBg | v82 chapter 8, method, appendix (spec §10) | deck-part1.md §Part 2 |
| Evidence deck v82 (claude.ai artifact, 96 slides) | claude.ai/artifact/6UUb91x2vHULkaM4g73uQr | Appendix / evidence; not updated since the topic review (data-story-review §Topic 2) | deck-part1.md |
| Decision deck (22 slides) | claude.ai/artifact/F1nbGMJptGsz2LW96TQ2jf · GS 1706frcGaYkX013j2sxSpPaGvCDgMLtfLJqvIKKaA4TY | Eden 10-21: "NOT good yet". Reference only | – |
| **FINAL deck (Domino)** — Eden 2026-10-29: "the final Domino deck" | 1gHkK8mNPg5pDKwlIe3FdMSqq2UqQx2bPihgu4ve_mks | The deck being presented. Slide 3 = 10-chapter agenda, slide 124 = Recommendations and Test Order (both updated 10-29 to Eden's new order). Chapter map below | topic-domino-dx.md §Final deck |
| **Domino-focused deck** | 1bVGI1Sb49fJ-a4Cp8AHs5hTOYjrTuQlJbW9vStaJr1o | Domino diagnosis chapter (dxend, dxgate/dxdist/dxmix/dxtest, dxw/dxsrc/dxfar/dxrec). Merged to main 10-26; slide positions **unverified, check live deck** | topic-domino-dx.md §Domino deck map |
| Style guide / content v1 artifacts | 987682ea-… · 8ffefe07-… | Design reference | – |
| Stale | HH8Bto7Q… draft deck (stale); CBFJks… end-lift chart (valid) | per INDEX | – |

## FINAL Domino deck chapter map (2026-10-29, Eden's new order; 125 slides)
1 The three games 5–21 · 2 The album end 22–45 · 3 Golden and Rare stickers (incl. Domino 19 vs 20 Goldens, Royals, Jokers) 46–81 · 4 Who falls behind, by daily spend 82–93 · 5 How the album gets closed (free finishers, RV) 94–99 · 6 After the album 100–109 · 7 VIP 110–112 · 8 Domino tests: Royals and the album 18 FU (tx_royal, fu1, fu2, fu3, fu5, fu6) 113–118 · 9 Post-album event 119–122 · 10 Three lessons + test order 123–124. Dice prize slides are no longer in this deck. Rule: each topic = 3-game slides, then Domino 20 vs 19.

## Story order (current = data-story-review topic map 0–9)
0 definitions → 1 where the money is → 2 who finishes / who is far → 3 rare supply → 4 how the album closes → 5 left behind → 6 after the album → 7 three natural cases → 8 targets → 9 recommendations and test order.

Two older numberings exist; do not mix them with the topic numbers:
- storyline-v4-2026-10-20: opening + chapters 1–7.
- v82 / spec §4: chapters 1–8.

## Mechanics (c/next-session-prompt-2026-10-26.md, -10-23.md)
- **Shapes:** createShape stores shapes on a 3,000,000 EMU base, so set scale = real ÷ 3e6. Charts are replaced by native lines (createLine; scaleY −1 for rising segments; always pass scaleX 1).
- **Text:** in Part 1, replaceAllText resets the style, so re-apply Oswald size and colour.
- **Layout:** Part 1 has no BLANK layout; use layoutId p50.
- **Before writing:** re-read the slide before each batch, because Eden edits in parallel. The ALBUM END revision ID changes on every read, so the last writes went without the revision lock (Eden approved).
- **Thumbnails:** read_slide_page_thumbnail → curl to c/slides/*.png.
- **Generators:** each prints batchUpdate requests: `python3 c/slide_<x>.py <key|notes> [insertionIndex]`.
- **Old v82 artifact generators:** c/deck_v2_*.py and c/deck_gen_x3.py (project/deck.json + slides/<id>.html).
