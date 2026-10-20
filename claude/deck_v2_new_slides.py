import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from lib import *

S = {}

# ---------------- OPENING ----------------
cards = [
    ("Ch 1", "×1.23 / ×1.16 / ×1.06", "Last 10% of the album vs an average album day (Dice / Domino / Disney)"),
    ("Ch 2", "3 / 6 / 6", "Stickers the median payer is missing at close. Dice keeps adding new stickers in the last third"),
    ("Ch 3", "84–99%", "of paying finishers finish in the last 3 days in the albums compared (Domino 17: 64%)"),
    ("Ch 3", "2×", "Domino 20 vs 19: finishers doubled, revenue per player held (+3%). Two albums, not a test"),
    ("Ch 4", "~56%", "of revenue is 4+ stickers away 4 days before close, in all three games"),
    ("Ch 4", "15–28%", "of album revenue sits with middle payers who end far. The closing tool barely reaches them"),
    ("Ch 5", "−1% to +16%", "Finishers' spend in the week after finishing vs their own usual spend"),
    ("Ch 6", "9 / 6 / 4%", "of payers finish, vs a 10% album goal. Targets should be read per spend group"),
]
cells = []
for ch, big, txt in cards:
    cells.append(f'<div style="display:flex;flex-direction:column;gap:10px;background:#2A2A2A;border-radius:18px;padding:24px 26px">'
                 f'<p style="font-size:22px;color:#9E9E9E;letter-spacing:1px">{ch.upper()}</p>'
                 f'<p style="font-size:52px;font-weight:500;line-height:1;color:{GOLD}">{big}</p>'
                 f'<p style="font-size:24px;font-weight:300;line-height:1.3;color:#E0E0D8">{txt}</p></div>')
body = ('<div style="flex:1;display:grid;grid-template-columns:1fr 1fr 1fr 1fr;grid-template-rows:1fr 1fr;gap:24px">' + "".join(cells) + '</div>')
S["summary"] = section("summary", f"What We {g('Found')}", "The strongest findings, each shown in the chapter on its card. All are observational unless a test is named.",
                       body, "All games",
                       "Opening summary so the room knows what to listen for. Every card is proven later: Ch 1 album-shape; Ch 2 progression (median payer, 3 albums per game); Ch 3 last3days and domino-easier (observational, two albums); Ch 4 stand4 (close−4, existing studio goal definition) and far-revenue (middle payers P50–95, at close); Ch 5 finishers-hold (vs own baseline, no comparison group); Ch 6 target slide (payers, 2 albums per game). Finish rates: Dice 61/63 average 9.3%, Domino 19/20 average 6.3%, Disney 14/15 average 4.0%.")

qs = [("1", "What role does the album play in each game?"),
      ("2", "How do players progress, and where do they get stuck?"),
      ("3", "How does progress turn into purchases and completions?"),
      ("4", "Who stays behind, and what is it worth?"),
      ("5", "What happens after completion and in the next album?"),
      ("6", "What should each game measure, change or test?")]
rows_html = "".join(f'<div style="display:flex;flex-direction:row;align-items:center;gap:32px;background:#262626;border-radius:14px;padding:14px 28px">'
                    f'<p style="width:70px;font-size:48px;font-weight:500;color:{GOLD}">{n}</p><p style="font-size:36px;font-weight:300">{q}</p></div>' for n, q in qs)
S["questions"] = section("questions", f"Six {g('Questions')}", "Each chapter answers one question. Depth follows the strength of the evidence, not equal space per game.",
                         f'<div style="flex:1;display:flex;flex-direction:column;justify-content:space-between">{rows_html}</div>', "All games",
                         "Agenda. Chapters have their own local story; they are not one causal chain. Method details for targets and segments sit after the closing slide, then the appendix and the questions the data rejected.")

legend = "".join(f'<div style="display:flex;flex-direction:row;align-items:center;gap:16px"><div style="width:48px;height:16px;background:{c};border-radius:4px"></div><p style="font-size:28px">{n}</p></div>' for _, n, c, _, _ in GAMES)
body = (row(card("Who", "Standard population: not in their first album, logged in on at least half the album days, test and special users removed, close day left out. Payer = paid during the album.", DICE),
            card("Which albums", "Dice 61 / 63 · Domino 19 / 20 (17 where noted) · Disney 14 / 15. Trend slides use every album since April 2025.", DOMINO),
            card("What we count", "Finisher = all 144 unique stickers before close. Missing = stickers still missing of 144. Revenue = all in-game spend on album days, not revenue from the album alone.", DISNEY))
        + row(card("How sure", f"{g('Fact')}: measured directly. {g('Comparison')}: two albums or self-chosen groups, describes what happened, not why. {g('Hypothesis')}: needs a test.", GOLD),
              f'<div style="flex:1;display:flex;flex-direction:column;gap:18px;justify-content:center;background:#2A2A2A;border-radius:18px;padding:28px"><p style="font-size:32px;font-weight:500">Game colors</p>{legend}</div>'))
S["read"] = section("read", f"How to Read the {g('Numbers')}", None, f'<div style="flex:1;display:flex;flex-direction:column;gap:28px">{body}</div>', "All games",
                    "Definitions used on every slide. The album table's spend column is all spend in the game on album days (checked against total game revenue within 1%), so 'album revenue' here is not revenue caused by the album. Population filters use the login ratio on the last row before close, which favors players who stayed; noted where it matters.")

# ---------------- CHAPTER 1 ----------------
S["q1"] = question("q1", "Chapter 1", f"What Role Does the {g('Album')}<br>Play in Each Game?", None,
                   "Same 144-sticker frame in three games. Who pays during the album, when revenue arrives, and how the album end behaves.", "Chapter 1",
                   "Context chapter: structure, tenure mix, revenue shape over the album, the end lift and what it is worth.")

hdr = ["", "Dice", "Domino", "Disney"]
rows = [["Album length (days)", "35–42", "39–49", "42"],
        ["Commons / Goldens / Rares", "104 / 28 / 12", "107 / 28 / 8–9", "113 / 24 / 7"],
        ["Last stickers (studio design)", "2 Supers + Golden", "Hard: 2 Royals + Golden<br>Easy: 2 Royals + 3 Goldens", "Royal + 2 Goldens"],
        ["Closing tool", "Wild", "Joker", "Joker"],
        ["Duplicate exchange", "Yes", "Yes", "None"],
        ["Completion prize", "25K–200K rolls, by last album", "150 / 250 coins (Easy / Hard)", "To confirm"],
        ["Content after completion", "Challenge", "Deluxe album", "Mini-album (to confirm)"],
        ["Payout to non-finishers", "Data pending", "Data pending", "Data pending"]]
hl = {(4, 3): ("#F4CCCC", "#8A1530"), (5, 3): ("#FFF2CC", "#6B5A1E"), (6, 3): ("#FFF2CC", "#6B5A1E"),
      (7, 1): ("#FFF2CC", "#6B5A1E"), (7, 2): ("#FFF2CC", "#6B5A1E"), (7, 3): ("#FFF2CC", "#6B5A1E")}
S["structure"] = section("structure", f"Same 144 Stickers, Different {g('Tools')}", "What each game puts around the same album",
                         table(hdr, rows, [31, 23, 23, 23], 26, hl), "Chapter 1",
                         "Sources: studio documents (Dice segmentation and prize ladder, Domino album onboarding), cross-game framework 4a, decisions register. Late-sticker design is as given by the studios; the Dice design was confirmed (the album brings players to 2 missing Supers on purpose). Disney completion prize, Disney mini-album and payout to non-finishers in all three games are not yet documented: marked pending, to be added when the data arrives. Yellow = to confirm. Red = the mechanic is absent.")

S["end-worth"] = section("end-worth", f"Today's End Lift Is About {g('2%')} of Revenue", "An illustration of size, not a cap on what a change to the end can do",
                         centered(row(card(None, "Extra revenue per day on 4 of ~42 days when the last days earn 1.2× an average day", GOLD, "≈2%"),
                             card(None, "Disney album revenue if its end lifted like Dice's (illustration)", DISNEY, "≈$0.7M", DISNEY),
                             card("Not a cap", "A change to the end can also move how many players finish, spend earlier in the album and spend in the next album. Those effects are not in this number.", GREEN, None),
                             gap=28)),
                         "Chapter 1",
                         "Fact: arithmetic on today's lift (0.2 extra × 4 days ÷ ~42 days ≈ 2%). Interpretation: the end matters mostly as a sign of how completions happen, which later chapters cover. It is not an upper bound: a different end design could change completions, earlier spend or next-album spend, which this number does not include. Disney $0.7M per album = Disney album revenue × the same arithmetic; illustration only.")

# ---------------- CHAPTER 2 ----------------
S["q2"] = question("q2", "Chapter 2", f"How Do Players Progress,<br>and Where Do They {g('Get Stuck')}?",
                   "the album frame is shared, but revenue patterns and the album end differ by game.",
                   "Collection pace, sticker types, sources and the last stickers of each album. Also how much albums differ inside one game.", "Chapter 2",
                   "Progression chapter. Population for pace slides: payers in the standard population, 3 albums per game (Dice 59/61/63, Domino 17/19/20, Disney 12/14/15): Dice 171–196K, Domino 103–136K, Disney 319–382K payers per album.")

xs = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
rare = {"Dice": [0, 8, 15, 22, 28, 35, 42, 49, 55, 64, 76],
        "Domino": [0, 5, 10, 15, 19, 28, 36, 42, 51, 58, 64],
        "Disney": [0, 5, 12, 16, 19, 24, 41, 49, 54, 61, 65]}
ser = [("Dice", DICE, xs, rare["Dice"]), ("Domino", DOMINO, xs, rare["Domino"]), ("Disney", DISNEY, xs, rare["Disney"])]
xt = [(0, "Start"), (25, "25%"), (50, "50%"), (75, "75%"), (100, "Close")]
yt = [0, 20, 40, 60, 80]
chart = line_chart(128, 300, 1150, 600, ser, 0, 100, 0, 85, xt, yt, lambda v: f"{v:g}%", shade=70)
side = (f'<div style="position:absolute;left:1340px;top:300px;width:452px;display:flex;flex-direction:column;gap:20px">'
        + card("First new rare", f"Day {g('3–5', DICE)} · {g('8', DOMINO)} · {g('7–10', DISNEY)}", None)
        + card("Days between new rares", f"{g('4–5', DICE)} · {g('6–7', DOMINO)} · {g('6–7', DISNEY)}", None)
        + card("Rares in the album", f"{g('12 Supers', DICE)} · {g('8–9 Royals', DOMINO)} · {g('7 Royals', DISNEY)}", None)
        + '</div>')
S["rares-cum"] = section("rares-cum", f"Dice Players Get Rares {g('More Often')}", "Average paying player · % of the album's rares collected, by % of album time · shaded = last 30%",
                         chart + side, "Chapter 2",
                         "Fact. Y = unique rares held ÷ rares in the album (Dice Supers, Domino and Disney Royals); X = % of album time. Average paying player, standard population, 3 albums per game (Dice 59/61/63, Domino 17/19/20, Disney 12/14/15); averages add up by type, medians do not. Side cards (first new rare, days between new rares) are medians for paying players including first-album payers (Dice 61/63, Domino 17/19, Disney 14/15), not rerun on the standard population. Disney's jump between 50% and 60% (24% to 41%) is likely album 15's mid-album Royal release; a per-album split is pending. Main source of new rares: Dice one Trail (about half), Domino and Disney rotating events. Source: claude/sticker-progression-p50-payers-2026-10-18.md, rares-pace.")

chart2 = line_chart(128, 300, 1150, 600, ser, 0, 100, 0, 85, xt, yt, lambda v: f"{v:g}%", shade=90, dim_before=90)
side2 = (f'<div style="position:absolute;left:1340px;top:330px;width:452px;display:flex;flex-direction:column;gap:20px;background:#2A2A2A;border-radius:20px;padding:32px;border-left:8px solid {GOLD}">'
         f'<p style="font-size:30px;color:#C8C8C0">Rares added in the last 10% of the album</p>'
         f'<p style="font-size:80px;font-weight:500;line-height:1;color:{DICE}">+12 <span style="font-size:30px;font-weight:300;color:#F5F5F0">pts Dice</span></p>'
         f'<p style="font-size:80px;font-weight:500;line-height:1;color:{DOMINO}">+6 <span style="font-size:30px;font-weight:300;color:#F5F5F0">pts Domino</span></p>'
         f'<p style="font-size:80px;font-weight:500;line-height:1;color:{DISNEY}">+4 <span style="font-size:30px;font-weight:300;color:#F5F5F0">pts Disney</span></p>'
         f'<p style="font-size:24px;font-weight:300;color:#C8C8C0">In Dice this is the planned gate: the last Supers are released at the end.</p></div>')
S["rares-end"] = section("rares-end", f"The Rare Gap {g('Widens')} in the Last 10%", "Same chart · everything before 90% of the album dimmed",
                         chart2 + side2, "Chapter 2",
                         "Emphasis copy of the previous slide. From 90% of album time to close the average paying player adds 12 points of the album's rares in Dice (64% → 76%), 6 in Domino (58% → 64%), 4 in Disney (61% → 65%). In Dice the last 2 Supers are released at the end by design (studio). In Domino and Disney the late release is seen in the data; whether those stickers are locked by config is not confirmed.")

hdr = ["New rares in the last quarter", "Dice", "Domino", "Disney"]
rows = [["Paid offer / Wild", "11%", "3–10%", "2–3%"],
        ["Duplicate exchange", "3–12%", "23–37%", "None"],
        ["Market", "–", "0–14%", "2–10%"],
        ["Events and other gameplay", "Most of the rest", "Most of the rest", "Most of the rest"]]
hl = {(0, 1): ("#D9EAD3", "#1E5631"), (1, 2): ("#D9EAD3", "#1E5631")}
S["sources"] = section("sources", f"Each Game Fills the Last Quarter {g('Differently')}", "Share of new rares in the last quarter of the album, by source · standard population, two albums per game",
                       table(hdr, rows, [40, 20, 20, 20], 32, hl) +
                       row(card("Dice sells", "Paid offers and Wilds bring the largest paid share of late rares.", DICE),
                           card("Domino trades", "Duplicate exchange brings a quarter to a third of late rares. Disney has no duplicate exchange.", DOMINO),
                           card("Unknown", "Whether most event sources are paid or free is not known in any game.", GOLD)),
                       "Chapter 2",
                       "Fact for the shares (Dice 61/63, Domino 17/19 and 20 for the 37% exchange share, Disney 14/15). Missing: paid vs free for most event sources; the mtx campaign name is filled on almost all gate stickers, so it cannot serve as a paid flag. Classification rule (Eden): bought with money = paid; Market and event rewards = gameplay.")

def gatecard(color, logo, alt, design, big, bigtxt, status):
    return (f'<div style="flex:1;display:flex;flex-direction:column;gap:16px;background:#2A2A2A;border-radius:20px;padding:30px;border-top:8px solid {color}">'
            f'<img src="{logo}" alt="{alt}" style="width:200px;height:70px;object-fit:contain">'
            f'<p style="font-size:30px;font-weight:500">{design}</p>'
            f'<p style="font-size:80px;font-weight:500;line-height:1;color:{color}">{big}</p>'
            f'<p style="font-size:26px;font-weight:300;line-height:1.35">{bigtxt}</p>'
            f'<p style="font-size:22px;color:#9E9E9E">{status}</p></div>')
S["gates"] = section("gates", f"Each Album Ends on a Few {g('Late Stickers')}", "What the last stickers are, and how few payers hold them near the end",
                     centered(row(gatecard(DICE, GAMES[0][3], GAMES[0][4], "2 Supers + 1 Golden", "47%", "of payers ended album 63 with exactly 10 of 12 Supers", "Late by design (studio)"),
                         gatecard(DOMINO, GAMES[1][3], GAMES[1][4], "Last release phase: 7 Goldens / Royals", "9–10%", "of payers held the last Royals at close (album 19)", "Late in data · lock not confirmed"),
                         gatecard(DISNEY, GAMES[2][3], GAMES[2][4], "Royal + 2 Goldens", "2–6%", "of payers held Royal 131 two days before close (albums 14 / 15)", "Late in data · lock not confirmed"),
                         )),
                     "Chapter 2",
                     "Facts: Dice 92–95% of payers one sticker short of a set are missing a Super; 68–77% of finishers' last 3 stickers are Supers. Domino: the last phase changes type by album (album 17 Golden: 83% of last stickers; album 19 Royal: 51%). Disney 14/15: 2.0% / 5.5% of payers held Royal 131 by two days before close; the gate is a Royal plus 2 Goldens, not always Royal 131. Only the Dice design is confirmed by the studio; Domino and Disney release dates are not in the config we have, so 'locked' is not claimed.")

swing_rows = {"dice": [("61", 62, "#7A7A7A"), ("63", 47)], "domino": [("19", 69, "#7A7A7A"), ("20", 45)], "disney": [("14", 56, "#7A7A7A"), ("15", 57)]}
body = vbars_panels(swing_rows, 80, lambda v: f"{v:g}%", top=300, height=520, cat_size=26, val_size=34)
for i, (txt, col) in enumerate([("−15 pts · finish 8.1% → 10.5%", "#F5F5F0"), ("−24 pts · finish 4.5% → 8.0%", "#F5F5F0"), ("+1 pt · finish 3.8% → 4.1%", "#F5F5F0")]):
    body += p([128, 704, 1280][i], 836, 512, txt, 26, col, "center", 500)
S["album-swings"] = section("album-swings", f"Albums Differ a Lot {g('Within')} Dice and Domino", "% of payers' revenue still 4+ stickers away 4 days before close · two albums per game · below: payer finish rate",
                            body, "Chapter 2",
                            "Fact (standard population; revenue from album start to close−4; close−4 is the existing studio goal day). Dice 61: 62.4%, 63: 47.1%; Domino 19: 69.2%, 20: 45.4%; Disney 14: 55.9%, 15: 56.7%. Payers: Dice 172K / 178K, Domino 117K / 105K, Disney 365K / 320K. Also: Domino 19 easy version reached 5% vs 57% for the hard version at $2–5 a day. The cause of each swing is not known (events, release timing, version). Meaning: inside Dice and Domino the album design is a large lever; comparing games needs the same albums.")

# ---------------- CHAPTER 3 ----------------
S["q3"] = question("q3", "Chapter 3", f"How Does Progress Turn Into<br>Purchases and {g('Completions')}?",
                   "Dice keeps giving new stickers to the end; Domino and Disney fill early. Albums inside one game can differ a lot.",
                   "When players finish, how the closing tool is sold or given, who uses it, and what happened when Domino changed its end.", "Chapter 3",
                   "Conversion chapter.")

reach = {"dice": [("Far 4+", 7, "#7A7A7A"), ("Near 1–3", 40)], "domino": [("Far 4+", 9, "#7A7A7A"), ("Near 1–3", 92)], "disney": [("Far 4+", 2, "#7A7A7A"), ("Near 1–3", 23)]}
S["tool-reach"] = section("tool-reach", f"The Closing Tool Reaches {g('Near-Finishers')}", "Wild / Joker fills per 100 middle payers in the last 4 days, by how far they end · middle payers = 45% of payers, ~51% of revenue",
                          vbars_panels(reach, 100, lambda v: f"{v:g}", top=300, height=560, cat_size=26, val_size=40), "Chapter 3",
                          "Fact. Middle payers = P50–95 of spend so far at the start of the last quarter (45% of payers by definition; about 51% of album revenue: P50–80 ~19%, P80–95 ~32%). Far = end 4+ missing, near = 1–3 missing. Per 100 = stickers filled by a Wild / Joker per 100 players in the group, last 4 days before close. Albums Dice 61/63, Domino 19/20, Disney 14/15. Interpretation: the closing tool is a near-finisher tool in every game; far players need something earlier. Disney near-finishers use it less (23), consistent with its tool opening 2–3 days before close (not tested). Source: middle-payers-stall EndWin.")

def readcol(title, color, pts):
    li = "".join(f'<div style="display:flex;flex-direction:row;gap:14px"><p style="font-size:30px;color:{color}">●</p><p style="font-size:32px;font-weight:300;line-height:1.35">{t}</p></div>' for t in pts)
    return (f'<div style="flex:1;display:flex;flex-direction:column;gap:18px;background:#2A2A2A;border-radius:20px;padding:32px;border-top:8px solid {color}">'
            f'<p style="font-size:34px;font-weight:500">{title}</p>{li}</div>')
S["jokers"] = section("jokers", f"Did Free Jokers {g('Cost Purchases')}?", "Two readings of Domino 19 → 20 · eligible players 352,951 → 317,155",
                      centered(row(readcol("Reading A: the free end cost purchases", RED,
                                  ["Revenue per finisher fell from $419 to $261",
                                   "43% of finishers did not pay (27% in album 19)",
                                   "3,223 finishers (21%) closed with two Puzzle stickers; 1,092 of them paid"]),
                          readcol("Reading B: no sign of lost spend", GREEN,
                                  ["Within each spend group, revenue per finisher held ($283 → $285 at $2–5 a day)",
                                   "Revenue per player rose 5–11% in every paying group",
                                   "In albums 17 / 19, players with only gameplay Jokers kept their spend (×0.99–1.05)"]),
                          ), gap=28) +
                      '<p style="font-size:30px;font-weight:300">→ Both fit the data. Reading A is mostly about <span style="color:#FFDF85">who</span> finished; Reading B about <span style="color:#FFDF85">how much</span> payers spent.</p>',
                      "Chapter 3",
                      "Observational, two albums. Reading A sources: domino-19-vs-20-last-sticker-cost (finisher revenue $3.05M → $3.94M; 73% → 57% of finishers paid), nonpayer-finishers. Reading B sources: domino-19-vs-20-strength-mix (finish rate up in every group: $5–20 12.0% → 19.5%, $20+ 30.1% → 39.3%), domino-album-total-rev (revenue per player +3% all, +5% to +11% in paying groups), endgame round 3 (gameplay-only Joker players 0.99–1.05× last week vs baseline; no-Joker players 0.34–0.49×). Also: 87–98% of non-paying finishers did not pay in the month before the album. Total album revenue fell 8% with 10% fewer players. Spend group = $ a day in the previous album.")

S["jokers-test"] = section("jokers-test", f"Only a {g('Test')} Can Settle It", "What the two albums cannot show, and what a test would cost and measure",
                           centered(row(card("What we cannot see", "Album 20 with one Puzzle Joker. Other differences between 19 and 20 (events, season). 10% fewer players in album 20, possibly the stronger ones stayed.", GREY),
                               card("What is at stake", "Extra revenue if the 393 strong closers ($5+ a day) had to buy the last sticker. Hypothesis.", GOLD, "$10–20K", GOLD),
                               card("What would settle it", "A/B: one vs two Puzzle Jokers. Judge by paying finishers and revenue per player; guardrail: finish rate.", GREEN),
                               )),
                           "Chapter 3",
                           "Hypothesis sizing from domino-strong-puzzle-closers: the 393 strong closers spent $287K in the album (1.8% of album revenue); that is their total spend, not money at risk. 89% of them bought an offer above their CZ in the last week. Realistic extra with one Joker ≈ $10–20K per album. The test is worth running only if that stake matters to the Domino team.")

dc = centered(row(card(None, "of final Supers came through a Wild", DICE, "78–84%", DICE),
         card(None, "of finishing stickers were a paid Wild", DICE, "58–69%", DICE),
         card(None, "players a day getting a Golden once the Golden sale opens, 7 days before close", DICE, "12K → 45K", DICE)))
S["dice-close"] = section("dice-close", f"Dice Closes Mostly Through {g('Paid Wilds')}", "Dice 61 / 63 · payers including first album, about 219K per album",
                          dc + '<p style="font-size:30px;font-weight:300">→ Whether the paid gate adds revenue or moves it earlier is <span style="color:#FFDF85">untested</span>.</p>',
                          "Chapter 3",
                          "Facts from the Dice supers mechanism work and closing-week split: 78–84% of the last Supers via Wild; 58–69% of finishing stickers were Wilds from a Pricing pack (paid); the Golden sale raised daily Golden takers from about 12K to 45K at 7 days before close (album 63; album 61 13K → 71K). Missing a Super goes with more payers paying in the last 4 days (82–84% vs 68% for those missing a Golden), but Super-missers already spent more before ($18 vs $13 a day): selection, not an effect. Population includes first-album payers; not rerun on the standard population.")

# ---------------- CHAPTER 4 ----------------
S["q4"] = question("q4", "Chapter 4", f"Who {g('Stays Behind')},<br>and What Is It Worth?",
                   "players finish at the very end, mostly with a closing tool that reaches those already close.",
                   "Where payers stand 4 days before close (the studios' goal day), who ends far, and what they do after their rares stop.", "Chapter 4",
                   "Population chapter. Close−4 is the existing goal definition used by the studios; it is kept as is.")

# stand at close-4 by group
raw = {"dice": [(121329 + 126143, 79, 15), (28304 + 28744, 67, 19), (19365 + 19601, 55, 37), (3485 + 3533, 35, 29)],
       "domino": [(88014 + 77153, 87, 16), (16304 + 15345, 75, 19), (10980 + 10548, 56, 37), (2016 + 1895, 30, 28)],
       "disney": [(260539 + 228230, 91, 15), (56101 + 49457, 77, 18), (40647 + 35882, 54, 39), (7342 + 6642, 27, 28)]}
allf = {"dice": 55, "domino": 57, "disney": 56}
labs = ["≤$2", "$2–5", "$5–20", "$20+"]
rowsd = {}
notes_share = []
for k, lst in raw.items():
    tot = sum(x[0] for x in lst)
    rr = []
    for lab, (n, far, rev) in zip(labs, lst):
        rr.append((lab, far))
    rr.append(("All", allf[k], GOLD))
    rowsd[k] = rr
    notes_share.append(f"{k}: " + ", ".join(f"{lab} {round(100*n/tot)}% of payers" for lab, (n, _, _) in zip(labs, lst)))
S["stand4"] = section("stand4", f"4 Days Out, {g('~56%')} of Revenue Is 4+ Away", "% of each group's revenue from payers missing 4+ stickers at close−4 · group = $ a day so far · payers per album: Dice 175K · Domino 111K · Disney 342K",
                      vbars_panels(rowsd, 100, lambda v: f"{v:g}%", top=290, height=560, cat_size=24, val_size=30) + p(128, 866, 1664, "Share of payers / of revenue: ≤$2 71–74% / 15–16% · $2–5 14–16% / 18–19% · $5–20 10–11% / 37–39% · $20+ 2% / 28–29%", 26, "#C8C8C0", "left", 300), "Chapter 4",
                      "Fact. Existing studio goal day (close−4): goal = revenue share of players 3 or fewer missing; here we show its complement (4+ missing). Standard population, albums Dice 61/63, Domino 19/20, Disney 14/15, averages of two albums. Revenue = album-table spend from album start to close−4. Payers per album: Dice 172K / 178K, Domino 117K / 105K, Disney 365K / 320K. Group shares of payers: " + "; ".join(notes_share) + ". Payers 4+ away: Dice 84% / 70%, Domino 95% / 77%, Disney 84% / 88%. The $5–20 group holds the most far revenue, about 20% of all revenue in each game. Current revenue, not potential. Source: claude/stand-close4-2026-10-18.md.")

ser = [("Dice", DICE, [0, 1], [55, 41]), ("Domino", DOMINO, [0, 1], [57, 47]), ("Disney", DISNEY, [0, 1], [56, 53])]
chart = line_chart(228, 290, 1000, 600, ser, 0, 1, 30, 65, [(0, "4 days before close"), (1, "3 days before close")], [30, 40, 50, 60], lambda v: f"{v:g}%")
side = (f'<div style="position:absolute;left:1340px;top:330px;width:452px;display:flex;flex-direction:column;gap:20px;background:#2A2A2A;border-radius:20px;padding:32px">'
        f'<p style="font-size:30px;color:#C8C8C0">Points of revenue that moved from 4+ to 3 or fewer in one day</p>'
        f'<p style="font-size:80px;font-weight:500;line-height:1;color:{DICE}">−14 <span style="font-size:30px;font-weight:300;color:#F5F5F0">Dice</span></p>'
        f'<p style="font-size:80px;font-weight:500;line-height:1;color:{DOMINO}">−10 <span style="font-size:30px;font-weight:300;color:#F5F5F0">Domino</span></p>'
        f'<p style="font-size:80px;font-weight:500;line-height:1;color:{DISNEY}">−3 <span style="font-size:30px;font-weight:300;color:#F5F5F0">Disney</span></p></div>')
S["stand-move"] = section("stand-move", f"Dice and Domino {g('Close More')} in the Next Day", "% of payers' revenue 4+ stickers away · 4 vs 3 days before close · same population",
                          chart + side, "Chapter 4",
                          "Fact. Same population and albums as the previous slide; close−3 numbers from claude/stand_close3_queries.sql. By album at close−3: Dice 52% / 30%, Domino 63% / 31%, Disney 53% / 53%. Interpretation: in Dice and Domino the closing tool is already open at close−4; in Disney it opens 2–3 days before close. This timing fits the gap but has not been tested. The goal definition stays at close−4.")

# ---------------- CHAPTER 5 ----------------
S["q5"] = question("q5", "Chapter 5", f"What Happens After {g('Completion')}?",
                   "about half of revenue is far from finishing 4 days out, and heavy payers who just miss slow down before close.",
                   "Spend after a player's own completion day, the move into the next album, and spend from the official close by how the album ended.", "Chapter 5",
                   "After-completion chapter. Two different windows; they are not mixed.")

def tl(top, label, color, steps):
    out = [p(128, top - 54, 1600, label, 32, color, "left", 500),
           f'<div style="position:absolute;left:128px;top:{top+38}px;width:1664px;height:4px;background:#4A4A4A"></div>']
    for x, w, title, txt, hl in steps:
        bg = "#3A3420" if hl else "#2A2A2A"
        bd = f"border:2px solid {GOLD};" if hl else ""
        out.append(f'<div style="position:absolute;left:{x}px;top:{top}px;width:{w}px;display:flex;flex-direction:column;gap:6px;background:{bg};{bd}border-radius:14px;padding:16px 20px">'
                   f'<p style="font-size:26px;font-weight:500">{title}</p><p style="font-size:22px;font-weight:300;color:#C8C8C0">{txt}</p></div>')
    return "\n".join(out)
body = (tl(340, "1 · From the player's own completion day (finishers only)", GOLD,
           [(128, 420, "Usual spend", "Album start to 5 days before close", False),
            (588, 300, "Last 4 days", "Spend rises ×1.6–2.4", False),
            (928, 320, "Completion day", "$42–45 spike", True),
            (1288, 504, "Days 1–7 after", "vs own usual spend", True)])
        + tl(660, "2 · From the official close (everyone, by how the album ended)", DISNEY,
             [(128, 420, "Usual spend", "Album start to 5 days before close", False),
              (588, 300, "Last 4 days", "Already falling for 3 missing", False),
              (928, 320, "Close day", "Same date for all", True),
              (1288, 504, "Days 1–7 after", "Finished vs 1, 2, 3 missing", True)]))
S["two-windows"] = section("two-windows", f"Two Windows, Two {g('Questions')}", "Window 1: do finishers keep paying? Window 2: what happens to those who did and did not finish?",
                           body, "Chapter 5",
                           "Window 1 (personal completion day) is used on the next three slides; window 2 (official close) on the step-down slide. Payers in the standard population; daily metrics tables (not album-dependent) so the switch day is not counted twice. No comparison group in either window: results describe each group against its own usual spend.")

nxt = {"dice": [("Day 1", 38), ("Day 3", 86)], "domino": [("Day 1", 48), ("Day 3", 78)], "disney": [("Day 1", 62), ("Day 3", 99)]}
S["next-album"] = section("next-album", f"Most Days After Finishing Are in the {g('Next Album')}", "% of finishers already in the next album, days after their own completion · finishers who paid, two albums per game",
                          vbars_panels(nxt, 110, lambda v: f"{v:g}%", top=300, height=520, cat_size=26, val_size=36) +
                          p(128, 840, 1664, "→ Content for finishers in the old album reaches only 7–29% of their next 7 days. Domino 17 is the exception: 37% finished early and had a Deluxe album.", 26, "#C8C8C0", "left", 300),
                          "Chapter 5",
                          "Fact. Finishers per album: Dice 13,648 / 18,265, Domino 7,618 / 5,183 (17/19), Disney 13,697 / 12,886. Share of follow-up days in the open (old) album: Dice 16–18%, Domino 29% / 10%, Disney 7%. Domino 17 early finishers held +9% after completion, with a Deluxe album available; whether the Deluxe album caused it is not known.")

ld = {"dice": [("61", 0.88), ("63", 0.74)], "domino": [("17", 0.90), ("19", 0.96)], "disney": [("14", 0.95), ("15", 1.00)]}
S["dice-lastday"] = section("dice-lastday", f"Dice Last-Day Finishers {g('Start Slower')}", "Spend in days 1–3 after completing on the last day, vs their own usual spend · 1.00 = usual (gold line)",
                            vbars_panels(ld, 1.25, lambda v: f"×{v:.2f}", top=300, height=540, cat_size=26, val_size=34, ref=1.0, ref_label="usual"),
                            "Chapter 5",
                            "Fact, finishers who completed the day before close (Dice 39% / 38% of finishers, Domino 39% / 56%, Disney 65% / 59%); all of them are already in the next album in days 1–3. Dice recovers in days 4–7 in album 61, only partly in 63. Hypothesis for a test: a completion reward delivered at the next album's opening for Dice last-day finishers.")

S["payout"] = section("payout", f"Payout to Non-Finishers: {g('Data Pending')}", "What players who did not finish receive at close, and what it is worth",
                      centered(row(card("Will show", "What each game gives at close (stickers, duplicates, album currency), the conversion rate, the value per player and the share of players who receive it.", GOLD),
                          card("Why it matters", "It sets what missing costs a player, and so how hard the end feels in each game.", GREY),
                          card("Status", "Not analysed yet in any game. Will be added when the payout data is shared.", RED),
                          )),
                      "Chapter 5",
                      "Placeholder by request. Topic 11 of the cross-game framework (post-album payout for non-finishers) has not been analysed; no numbers are shown until the data arrives.")

# ---------------- CHAPTER 6 ----------------
S["q6"] = question("q6", "Chapter 6", f"What Should Each Game<br>Measure, Change or {g('Test')}?",
                   "finishing does not lower a payer's spend, and most post-completion time is spent in the next album.",
                   "First the decisions the analysis supports, then what each game teaches, the tests and the targets.", "Chapter 6",
                   "Decision chapter. Method details (multipliers, segmentation) follow the closing slide.")

def lst(items, color):
    return "".join(f'<div style="display:flex;flex-direction:row;gap:16px"><p style="font-size:28px;color:{color}">→</p><p style="font-size:27px;font-weight:300;line-height:1.35">{t}</p></div>' for t in items)
S["decisions"] = section("decisions", f"What the Analysis {g('Supports')}", "Measurement changes need no test. Product changes do.",
                         row(f'<div style="flex:1;display:flex;flex-direction:column;gap:16px;background:#2A2A2A;border-radius:20px;padding:32px;border-top:8px solid {GREEN}"><p style="font-size:34px;font-weight:500;color:{GREEN}">Measure now</p>'
                             + lst(["Count a finisher as 144 unique stickers, not the in-game flag",
                                    "Read finisher targets at close; keep the 4-days-before-close goal as the in-album signal",
                                    "Use one structure in all games: 5 groups by $ a day of in-album spend",
                                    "Compare albums inside a game before comparing games",
                                    "Fix the data first: Dice stored segment, Domino −9999, Dice Easy spend curve"], GREEN) + '</div>',
                             f'<div style="flex:1;display:flex;flex-direction:column;gap:16px;background:#2A2A2A;border-radius:20px;padding:32px;border-top:8px solid {GOLD}"><p style="font-size:34px;font-weight:500;color:{GOLD}">Test before changing</p>'
                             + lst(["Disney: open the closing window earlier",
                                    "Disney, Domino: more Royals / Goldens 14–8 days before close",
                                    "Disney, then Dice: a completion path for $20+ payers 2–3 missing",
                                    "Dice: a next-album opener for last-day finishers",
                                    "Domino: one vs two Puzzle Jokers, only if the stake matters"], GOLD) + '</div>'),
                         "Chapter 6",
                         "Measurement: the in-game finish flag overstates finishers (Dice 11–14% vs 8–11% by 144 unique stickers; Disney ~10% of flagged finishers are below 144). One 5-group structure (0 / ≤2 / 2–5 / 5–20 / >20 $ a day) was decided on 2026-10-15; shadow-run for one album. Data issues: Dice stored segment column matches the team's query for 24–53% of upper levels (album 61); Domino daily segment −9999 on ~26% of rows (~8% of revenue); Dice Easy spend curve is off. Product changes are on the tests slide with populations and metrics.")

def gcol(color, logo, alt, works, limits, unknown):
    def blk(h, items, c):
        return f'<p style="font-size:26px;font-weight:500;color:{c}">{h}</p>' + "".join(f'<p style="font-size:23px;font-weight:300;line-height:1.3">· {t}</p>' for t in items)
    return (f'<div style="flex:1;display:flex;flex-direction:column;gap:10px;background:#2A2A2A;border-radius:20px;padding:26px;border-top:8px solid {color}">'
            f'<img src="{logo}" alt="{alt}" style="width:190px;height:64px;object-fit:contain">'
            + blk("Works", works, GREEN) + blk("Limits", limits, RED) + blk("Unknown", unknown, GOLD) + '</div>')
S["per-game"] = section("per-game", f"What Each Game {g('Teaches')}", None,
                        row(gcol(DICE, GAMES[0][3], GAMES[0][4],
                                 ["Steady rare pace to the end", "A late gate that sells (Wild from 7 days)", "Highest finish rate (9.3%)"],
                                 ["Far payers fade (51% active)", "Weakest spend after finishing", "Pre-album level misses many payers"],
                                 ["Whether the paid gate adds or moves revenue"]),
                            gcol(DOMINO, GAMES[1][3], GAMES[1][4],
                                 ["Duplicate exchange and gameplay Jokers", "47% of payers 2–3 missing finish", "Album 20: more finishers, revenue per player held"],
                                 ["Large swings between albums", "Easy version in album 19", "Daily segment gaps (−9999)"],
                                 ["What free Jokers cost, if anything"]),
                            gcol(DISNEY, GAMES[2][3], GAMES[2][4],
                                 ["Stable from album to album", "Far payers stay active (72%)", "Finishers spend +10–16% after"],
                                 ["Gate and closing tool open late, together", "Fewest finishers (4.0%)", "Revenue per active day falling (part mix)"],
                                 ["Can a Joker pick the gate Royal earlier?", "Are Market tokens paid?"]),
                            extra="flex:1"),
                        "Chapter 6",
                        "Same frame for every game: what works, what limits, what is unknown. Depth follows the evidence. Sources: progression, gates, tool-reach, half-completions, keep-playing, finishers-hold, album-swings, domino-easier, history, fixlist. 'Finishers spend +10–16% after' is vs their own usual spend, with no comparison group; it does not show that Disney's post-completion content works.")

hdr = ["Change to test", "Game", "Who · players · share of payers · share of revenue", "Judge by"]
rows = [["1 · Open the closing window earlier", "Disney", "Payers ≤6 missing 8 days out · 74–105K · 23–28% · missing", "Finish rate, revenue per player"],
        ["2 · More Royals / Goldens 14–8 days before close", "Disney, Domino", "Middle payers (P50–95) · 45% · ~51%", "Missing at close, revenue per player"],
        ["3 · Completion path before the last 4 days", "Disney, then Dice", "$20+ payers 2–3 missing · 2.9–3.3K / 1.6–1.7K · <1% · 8–9% / 7–8%", "Spend in last 4 days and week after"],
        ["4 · Next-album opener for last-day finishers", "Dice", "Last-day finishers · 5.3–6.9K · 38–39% of finishers · missing", "First-week spend, next album"],
        ["5 · One vs two Puzzle Jokers", "Domino", "Puzzle event players · stake $10–20K", "Paying finishers, revenue per player"]]
S["tests"] = section("tests", f"Test These {g('Product Changes')} First", "Ordered by size of the gap and how clean the test is · all sizes are current revenue, not upside",
                     table(hdr, rows, [30, 14, 36, 20], 24), "Chapter 6",
                     "Test 1 precondition: confirm a Joker can pick Royal 131 before its release (Disney team); otherwise the test must also move Royal sources to 14–8 days before close. Test 1 population revenue share is not yet measured. Test 2: middle payers who end far hold 28% (Disney) and 22% (Domino) of album revenue at close. Test 3: Disney 3,314 / 2,866 players, 8.1% / 8.6% of album revenue; Dice 1,563 / 1,684, 7.4% / 7.8%. Test 4: 39% / 38% of Dice finishers complete on the last day. Test 5 stake is a hypothesis. A 'more Super slots' test for Dice stays low priority.")

hdr = ["Target", "What it is for", "Status", "Today: Dice · Domino · Disney"]
rows = [["Revenue share of players ≤3 missing, 4 days before close, per group", "In-album signal for injections", "Existing studio definition, kept", "45% · 43% · 44%"],
        ["About 10% of payers finish (album goal 10–15%)", "Finishers should be payers who worked to finish", "Business target", "9.3% · 6.3% · 4.0%"],
        ["Finishers bring ≥30% of revenue (goal 30–35%)", "Finishers should be the stronger payers", "Business target", "26% · 26% · 18%"],
        ["Per-group targets: each group's own past × one multiplier", "Stronger groups keep finishing more", "Proposed method, to review", "Method section"]]
hl = {(3, 2): ("#FFF2CC", "#6B5A1E")}
S["targets"] = section("targets", f"Targets: Set, Measured, {g('Proposed')}", "Three measures with different jobs · today's values from the standard population, two albums per game",
                       table(hdr, rows, [36, 24, 18, 22], 25, hl), "Chapter 6",
                       "Measured values: ≤3 missing at close−4 = 100% − the far share (55% / 57% / 56%). Finish rate and finishers' revenue share: Dice 61/63, Domino 19/20, Disney 14/15, averages. Finisher = 144 unique stickers before close. The 10–15% / 30–35% album goal is treated as the set business target. Proposing to move the in-album goal from 4 to 3 days before close would need its own case; it is not proposed here. Revenue share at higher finish rates is not estimated, because new finishers may spend differently from today's.")

fin = [("Dice", 9.3, DICE), ("Domino", 6.3, DOMINO), ("Disney", 4.0, DISNEY)]
rev = [("Dice", 26, DICE), ("Domino", 26, DOMINO), ("Disney", 18, DISNEY)]
h1, y1 = hbars(128, 420, 820, fin, 12, bar_h=96, gap=44, label_w=170, fmt=lambda v: f"{v:g}%", target=10, target_label="goal 10%", size=36, inside=True)
h2, y2 = hbars(1010, 420, 780, rev, 36, bar_h=96, gap=44, label_w=170, fmt=lambda v: f"{v:g}%", target=30, target_label="goal 30%", size=36, inside=True)
body = (p(128, 300, 820, "Payers who finish", 34, "#F5F5F0", "left", 500) + p(1010, 300, 780, "Finishers' share of payer revenue", 34, "#F5F5F0", "left", 500)
        + h1 + h2 + p(128, 860, 1664, "→ Dice is closest on both. In Domino and Disney finishers spend 4.3–4.5× the average payer, so their revenue share is closer to goal than their finish rate.", 28, "#C8C8C0", "left", 300))
S["target"] = section("target", f"No Game Meets {g('Both')} Finisher Goals", "Standard population · average of two albums per game · finisher = 144 unique stickers before close",
                      body, "Chapter 6",
                      "By album: finish rate Dice 8.1% / 10.5% (61/63), Domino 4.5% / 8.0% (19/20), Disney 3.8% / 4.1% (14/15); finishers' revenue share Dice 23% / 28%, Domino 22% / 31%, Disney 17% / 18%. Ratio of revenue share to finisher share: Dice ~2.7, Domino ~4.3, Disney ~4.5. The 10% / 30% pair implies a ratio of ~3, close to Dice's shape. We do not assume today's ratio holds for new finishers.")

S["closing"] = (f'<section id="closing" data-transition="fade" style="background:radial-gradient(ellipse at 50% 40%, #3A2448 0%, #2A1F2E 35%, #212121 70%);color:#F5F5F0;font-family:\'Oswald\', sans-serif;padding:128px 160px;display:flex;flex-direction:column;justify-content:center;align-items:center;gap:40px">\n{FOOTER}\n'
                f'<img src="{STICKER}" alt="" style="position:absolute;left:160px;top:140px;width:140px;height:140px;object-fit:contain;transform:rotate(-20deg)">\n'
                f'<h1 style="font-size:84px;font-weight:500;line-height:1.1;text-align:center">Same Frame, {g("Three Lessons")}</h1>\n'
                + row(card("Dice", "A late gate that sells, and a cost in far players who fade.", DICE),
                      card("Domino", "The most end designs and a natural experiment in album 20.", DOMINO),
                      card("Disney", "Steady albums and engaged players, with a late gate and closing tool.", DISNEY), extra="width:1600px")
                + f'\n<p style="font-size:38px;font-weight:300;text-align:center">Measure the same way in every game. <span style="color:{GOLD}">Test</span> changes to the end before adopting them.</p>\n'
                + tagbar(None) + '<aside>The message to leave the room with. Findings are observational unless a test is named. Next: measurement decisions now; tests 1–3 planned with each studio. Method details for targets follow.</aside>\n</section>\n')

S["q-method"] = question("q-method", "Method", f"How to Set Targets<br>{g('per Group')}", None,
                         "Back-up for the target decisions: why revenue weighting, which spend measure to group by, and how per-group targets are derived.", "Method",
                         "Method section, kept after the closing slide so the decision story ends cleanly.")

mrow = row(card("Today → 10%", "Domino 6.3% → 10%", DOMINO, "×1.6", DOMINO),
           card("Today → 10%", "Disney 4.0% → 10%", DISNEY, "×2.6", DISNEY),
           card("Today → 10%", "Dice 9.3% → 10%. Base of ×1.19 being checked", DICE, "×1.1–1.2", DICE))
mrow2 = row(card("How", "Each group's own past finish rate × one multiplier per game, so stronger groups keep finishing more.", GREEN),
            card("Rejected", "Two multipliers (low vs high groups): lowered targets for strong groups and broke the order.", RED),
            card("Not assumed", "That new finishers spend like today's finishers. Their revenue share is not estimated.", GOLD))
S["multiplier"] = section("multiplier", f"One {g('Multiplier')} per Game Keeps Group Order", "Multiplier needed to reach 10% of payers finishing, applied to every spend group",
                          f'<div style="flex:1;display:flex;flex-direction:column;gap:28px">{mrow}{mrow2}</div>', "Method",
                          "Method agreed with Eden (2026-10-18). Domino ×1.6 and Disney ×2.6 to reach 10% finishers. The Dice ×1.19 in the targets doc does not match a 9.3% average (10 ÷ 9.3 = ×1.08); it may come from a different base (group-weighted rate); shown as a range until checked. Earlier versions estimated revenue share at 10% finishers (43–45% in Domino/Disney); that estimate assumed today's finisher spend ratio holds and is no longer shown. Weighting across games (equal vs by payers) is still open.")

S["q-more"] = question("q-more", "Appendix", f"Supporting {g('Detail')}", None,
                       "Analyses that support the chapters, kept for questions.", "Appendix",
                       "Appendix: detail behind chapter slides.")

if __name__ == "__main__":
    out = sys.argv[1]
    for k, v in S.items():
        open(os.path.join(out, f"{k}.html"), "w").write(v)
    print(len(S), "new slides")
