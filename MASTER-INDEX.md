# MASTER-INDEX — album cross-studio analysis (router; read this first, then ONE topic card)
Updated 2026-10-26 (Asia/Jerusalem), patched after the 10-26 main pull (PRs #30/#31). English. Replaces INDEX.md for routing.

**Snapshot.** Sticker-album end analysis for Dice Dreams (Dice), Domino Dreams (Domino), Disney Solitaire (Disney): 144 set stickers each. Eden reviews the story topic by topic (0–9) in `claude/data-story-review-2026-10-21.md`. Topics 0–5 are closed, topic 6 was rebuilt on 10-24, topic 7 is not reviewed, and topics 8–9 have not started (`claude/next-session-prompt-2026-10-26.md`). Eden's working deck is the Google Slides deck **ALBUM END**; there is also a Part 1 deck and a Domino-focused deck (dx diagnosis chapter, merged 10-26). Branch `claude/albums-seen-october` merged 10-27 (PR #28). Not in main: 2 uncommitted payer-time files (see `index/files-catalog.md` worktree section). Comparison albums: Dice 61/63, Domino 19/20, Disney 14/15. Topic 6 uses a 3-album set (Dice 59/61/63, Domino 17/19/20, Disney 12/14/15). The headline: few payers finish (11/8/5%), and they bring 19/23/17% of game revenue against a target of about 10% finishing and 20/23/24% of revenue (`claude/final-analysis-spec-2026-10-21.md` §6).

**Definitions:** `decisions-definitions-register.md` (wins every conflict). Work rules: `CLAUDE.md`.

## Routing rules
1. Find the question's keywords below and open **one** topic card. Open only the files that card lists, in its order.
2. Questions about queries, SQL, tables or columns → `index/sql-catalog.md`.
3. Questions about the deck or a slide → `index/deck.md`, then its row in `index/deck-album-end.md` or `index/deck-part1.md`. Then open only that row's doc, SQL and script.
4. Questions about a definition or rule → the register. Questions about a conflict or a decision → `index/conflicts-and-decisions.md`.
5. Questions about a file's status → `index/files-catalog.md`.
6. Never open `.claude/worktrees/`, the worktree copies, the old `INDEX.md`, root old-pack files (10-07..10-17) or files marked Superseded, unless Eden asks for history.

## Routing table
| Keywords (EN / HE) | Card |
|---|---|
| definitions, denominator, standard population, finisher rule, payer, first album / מכנה, מסיימים, משלמים, הגדרה | index/topic-t0-definitions.md |
| end lift, ARPDAU, last 4 days, Dice 65 flat, mix / ליפט, סוף אלבום | index/topic-t1-end-lift.md |
| who finishes, far 4+, strength p95, Wild/Joker reach / רחוקים, קרובים | index/topic-t2-finishers-far.md |
| rare, Royal, Super, Golden, sources, dry wait / רויאל, סופר, גולדן, נדירים | index/topic-t3-rare-supply.md |
| close, gate, locked stickers, closing tool, Joker, Wild, Movie Twister, stalls / ג'וקר, וויילד, שער, סגירה | index/topic-t4-album-close.md |
| left behind, ≤3 at close−4, spend tiers, end goal / נשארים מאחור, יעד סוף | index/topic-t5-left-behind.md |
| after the album, week after, payout, stock, post-album events, Deluxe, Legendary / אחרי האלבום, פייאאוט | index/topic-t6-after-album.md |
| Dice prize, 200K, grand prize, $2K+ / פרס, פרס גדול | index/topic-t7-dice-prize.md |
| Domino easy/hard rule, album 19 vs 20 background, Puzzle Jokers (older case notes) / דומינו רקע | index/topic-domino-cases.md |
| Domino chapter (current work), Domino diagnosis, dx, dxw/dxsrc/dxfar/dxrec, gate 3 vs 5, last 3 stickers, SummerFever, Domino deck / אבחון דומינו, שער, 3 חסרים, מצגת דומינו, פרק דומינו | index/topic-domino-dx.md |
| non-payers, RV, ad farming / לא משלמים, RV | index/topic-nonpayers-rv.md |
| targets, tests, test sizes, recommendations / יעדים, טסט | index/topic-targets-tests.md |
| VIP, VIP gift | index/topic-vip.md |
| segmentation, spend levels, Easy/Hard, album segment / סגמנט, רמות הוצאה | index/topic-segmentation.md |
| tenure, albums seen, new vs veteran, cohort / ותק | index/topic-tenure.md |
| benchmarks, old pack, knowledge bases, dbt | index/topic-benchmarks-reference.md |
| deck, slide, story order (ALBUM END, Part 1, Domino deck) / מצגת, שקף | index/deck.md |
