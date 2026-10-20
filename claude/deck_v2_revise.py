import re, sys, os
sys.path.insert(0, os.path.dirname(__file__))
from lib import g, GOLD, RED, GREEN

SRC = sys.argv[1]
OUT = sys.argv[2]
SUBSTYLE = 'font-size:28px;color:#C8C8C0'


def revise(sid, title=None, sub=None, arrow=None, tag=None, aside=None, reps=(), aside_add=None):
    s = open(os.path.join(SRC, sid + ".html")).read()
    if title is not None:
        s, n = re.subn(r'(<h2[^>]*>).*?(</h2>)', lambda m: m.group(1) + title + m.group(2), s, count=1, flags=re.S)
        assert n == 1, sid
    if sub is not None:
        m = re.search(r'</h2>\s*<p style="font-size:28px;color:#C8C8C0">.*?</p>', s, re.S)
        new = f'</h2>\n<p style="{SUBSTYLE}">{sub}</p>'
        if m:
            s = s[:m.start()] + new + s[m.end():]
        else:
            s = s.replace('</h2>', new, 1)
    if arrow is not None:
        m = re.search(r'(<p[^>]*>)→.*?</p>', s, re.S)
        assert m, sid + " no arrow"
        s = s[:m.start()] + ((m.group(1) + arrow + '</p>') if arrow else '') + s[m.end():]
    if tag is not None:
        s, n = re.subn(r'(<p style="position:absolute;left:64px;bottom:40px;width:200px;[^"]*">)[^<]*(</p>)', lambda m: m.group(1) + tag + m.group(2), s, count=1)
    for old, new in reps:
        assert old in s, (sid, old)
        s = s.replace(old, new)
    # "short" -> "missing" in visible and note text
    s = re.sub(r'(?<=[0-9+)]) short\b', ' missing', s)
    s = s.replace('stickers short', 'stickers missing').replace('one sticker short', 'missing one sticker')
    if aside is not None:
        s = re.sub(r'<aside>.*?</aside>', f'<aside>{aside}</aside>', s, flags=re.S)
    if aside_add:
        s = s.replace('</aside>', ' ' + aside_add + '</aside>')
    open(os.path.join(OUT, sid + ".html"), "w").write(s)


C1, C2, C3, C4, C5, C6 = "Chapter 1", "Chapter 2", "Chapter 3", "Chapter 4", "Chapter 5", "Chapter 6"

revise("cover", reps=[("October 2026 · Draft", "October 2026 · Draft v2")])
# Chapter 1
revise("tenure", title=f"Each Game Earns From a Different {g('Tenure Mix')}", tag=C1,
       aside_add="Reading: Dice earns above its player share from players with 2–6 albums (25% of DAU, 35% of revenue); Disney from its newest players (first album 8% of DAU, 11.5% of revenue; highest payer rate of any group, 26%); Domino is even. Cross-section, not the same players over time.")
revise("album-shape", title=f"Dice and Domino {g('Peak')} in the Last 10%", tag=C1)
revise("end-growth", title=f"Disney's End Lift Was {g('Near Zero')} in Albums 11–14", tag=C1,
       arrow="→ Dice and Domino lifted at every album end (+6% to +33%). Disney's earlier lifts came from its launch album (3) and a holiday close (8).")
revise("album-curves", title=f"Revenue per Active Day: Dice {g('Up', GREEN)}, Disney {g('Down', RED)}", tag=C1,
       sub="Album revenue per active day in each 10% of album time · last 6 albums · grey = older, color = latest two · each panel its own scale",
       aside_add="Interpretation: in Disney, players in their 7th+ album grew from 19% to 44% of active days over albums 10–15 and spend less per day ($0.71–0.81 vs $0.90–1.11), so part of the fall may be player mix (not proven).")
# Chapter 2
revise("progression", title=f"Same Pace to 60%, Then the Games {g('Split')}", tag=C2,
       sub="Median paying player · new stickers per day in each 10% of album time · the median player ends 3 / 6 / 6 missing")
revise("goldens", title=f"Goldens {g('Split')} After 70% of the Album", tag=C2,
       arrow="→ All three hold ~60% of Goldens at 70% of the album. Dice ends at 94%; Domino and Disney stop at 83% (4–5 missing).")
# Chapter 3
revise("last3days", title=f"Most Finishers Finish in the {g('Last 3 Days')}", tag=C3,
       arrow="→ In every game completion is a timed event at the very end. Domino 17 is the only album with finishes spread over the week.",
       aside_add="Domino 20 (not in the chart): 31% on the last day, 85% in the last 3 days. Paying finishers per album: Dice 14.3K / 18.9K, Domino 7.8K / 5.3K (17/19), Disney 14.0K / 13.2K.")
revise("closing-week", title=f"Three Ways to Close: {g('Sell')}, Give, Open Late", tag=C3,
       arrow="→ Dice sells Wilds from 7 days out; Domino closes mostly with gameplay Jokers; Disney gives ~3K gameplay Jokers a day and sells from 2 days out.")
revise("half-completions", title=f"Same Starting Point, {g('Different')} Finish Rates", tag=C3,
       reps=[('<p style="font-size:26px;color:#FF0B47">', '<p style="font-size:26px">')] * 1,
       aside_add="Domino 17 / 19 group sizes: 2–3 missing 2,196 / 1,533; 4–6 missing 14,536 / 22,685; 7–10 missing 37,637 / 27,345. Dice group sizes not in the summary tables.")
revise("same-spend", title=f"Similar Players Change Spend the {g('Same Way')}", tag=C3,
       arrow="→ The games differ in how often similar players finish, not in how they change their spend in the last week.")
revise("domino-weeks", title=f"Domino's Last Three Albums Ended {g('Three Ways')}", tag=C3,
       reps=[("<p style=\"font-family:Oswald, sans-serif; font-size:28px; color:#c8c8c0\">Payer finishers who had already finished, by days before close (cumulative %) · finish rate in the legend</p>",
              "<p style=\"font-family:Oswald, sans-serif; font-size:28px; color:#c8c8c0\">Payer finishers who had already finished, by days before close (cumulative %) · finish rate in the legend · three albums, not a test</p>")],
       arrow="→ Album 17 sold paid Jokers from 7 days out and ran a Market; album 20's finishes rose from 4 days out, when the Puzzle event's Jokers arrived.")
revise("domino-easier", title=f"Domino 20: {g('Twice')} the Finishers, Spend Held", tag=C3,
       arrow="→ Finish rate rose in every group (all: 2.1% → 4.8%) and revenue per player did not fall. Two albums, not a test: other differences may explain part of it.")
revise("tangled", title=f"In Disney, Gate and Tool {g('Open Together')}", tag=C3,
       sub="Disney album 14, all players, per day · so the data cannot tell which one holds players back")
# Chapter 4
revise("far-revenue", title=f"At Close, {g('Middle Payers')} Hold Most Far Revenue", tag=C4,
       sub="Share of album revenue from payers who end 4+ stickers missing, by spend group (percentile of spend so far at the last-quarter start)",
       aside_add="Low payers who end far (P0–50) kept collecting into the last quarter (~95%) and end about 11 missing; they hold only 2.5–5% of revenue.")
revise("royal-dip", title=f"For Far Payers, New Rares {g('Stop Early')}", tag=C4,
       sub="Last 14 days · last new rare for middle payers who end far vs first day a Wild / Joker fills the gate sticker",
       reps=[("with nothing that moves the gate", "between last new rare and gate open")] * 1,
       aside_add="Caveat: in Disney the drought is partial (15 new Royals per 100 far middle payers in days 10–8 vs ~40 in Domino and Dice; about half the gap remains after normalising per rare). Dice and Domino Wild / Joker sale timing (from 7 days) was given by the studios; Disney from data. Paid vs free supply in these days is unknown, so 'not offered' and 'not bought' cannot be separated.")
revise("keep-playing", title=f"Far Players Stay Active {g('Longest')} in Disney", tag=C4,
       arrow="→ Near players stay active 93–94% of days. Far players show up half the days in Dice and Domino, 72% in Disney; all spend little (1–3%).")
revise("heavy-missers", title=f"Heavy Payers Who Just Miss: {g('Few')}, but Valuable", tag=C4)
revise("give-up", title=f"They Slow Down {g('Before')} Close", tag=C4,
       arrow="→ Win rate stays at 97–99%: they play fewer levels, not harder ones. Consistent with giving up on the album (interpretation).")
# Chapter 5
revise("finishers-hold", title=f"Finishers Return to {g('Usual Spend')} or Above", tag=C5,
       sub="Finishers' spend in days 1–7 after their own completion day vs their usual spend · one bar per album · 0 = no change",
       reps=[("No post-completion drop", "No drop after finishing"),
             ("Finishers spend the same or more in the next album’s first week.", "Against their own usual spend, with no comparison group: this does not show that post-completion content works.")],
       aside_add="Window: player's own completion day (window 1). Usual spend = album start to 5 days before close. Albums Dice 61/63, Domino 17/19, Disney 14/15; finishers 13,648 / 18,265, 7,618 / 5,183, 13,697 / 12,886.")
revise("staircase", title=f"From Close, Spend {g('Steps Down')} With Distance", tag=C5,
       sub="Spend in days 1–7 after the official close vs usual spend, by how the album ended · payers · 1.00 = no change (dashed)",
       reps=[("Missing is not proven to cause it", "The drop starts before close"),
             ("The drop starts before they miss.", "So this does not price the cost of missing.")],
       aside_add="Window 2 (official close). Share of payers / of album revenue: finished 9% / 25% (Dice), 5% / 26% (Domino), 4% / 18% (Disney); 1 missing 4% / 8%, 2% / 6%, 3% / 8%; 2 missing 11% / 15%, 5% / 10%, 4% / 11%; activity in days 1–7 89–94% in every group.")
revise("not-lost", title=f"Few Non-Paying Finishers {g('Paid')} the Week After", tag=C5,
       arrow="→ Without a comparison group, this does not show whether finishing changes conversion.",
       reps=[("of them paid in the week after close: finishing did not turn them into payers", "of them paid in the week after close")],
       aside_add="Non-paying finishers: Dice 1–7% of finishers, Domino 14% → 27% → 43% (17/19/20; 6,536 of 15,091 in album 20), Disney 5–14%.")
# Chapter 6
revise("groups", title=f"Stronger Payers {g('Finish More')} in Every Game", tag=C6,
       aside_add="Grouping shown here is by $ a day in the previous album, known at album start. Grouping by in-album spend up to the last-quarter start was checked and gives a very similar picture (finisher-targets doc); the recommended structure uses in-album spend.")
# Method
revise("weighting", title=f"Why Weight Targets by {g('Revenue')}", tag="Method",
       aside_add="Trade-off: weighting by revenue protects the money; the ≤$2 group (52% of payers) then barely moves the target, which is why the finish rate stays as a second goal.")
revise("predictor", title=f"Start From Last Album, Then {g('Switch')} to In-Album Spend", tag="Method",
       arrow="→ At 10% of the album, last album is as good or better (Dice 58% vs 50%). From 25%, spend so far wins in all three games (partly circular later on).",
       aside_add="Disney test: combining last album and current spend at day 5 placed 59% right, the best early result. Recommendation: start each album from last album's spend, switch to in-album spend from about a quarter in.")
revise("history", title=f"Dice's Pre-Album Level {g('Misses')} Many Payers", tag="Method")
revise("fixlist", tag="Method")
revise("open-checks", tag="Method")
# Appendix
revise("endlift-7", title=f"Long-Tenure Players Show the {g('Same')} End Pattern", tag="Appendix")
revise("routes", title=f"Players With a Wild / Joker {g('Spent More')} at the End", tag="Appendix",
       sub="Payers missing 4–6 stickers 8 days before close · last-week spend ÷ the week before · players chose their route, so this is not an effect")
revise("goldens-week", title=f"Dice Opens a {g('Golden Sale')} 7 Days Before Close", tag="Appendix")
revise("dice-gate", title=f"The Super Is Dice's Late Gate, {g('by Design')}", tag="Appendix")
revise("album-effect", title=f"The Album Can Move Results as Much as Spend {g('Group')}", tag="Appendix")
revise("puzzle-joker", title=f"Most Who Used Two Puzzle Jokers {g('Did Not Pay')}", tag="Appendix")
revise("nonpayer-share", title=f"In Domino 20, {g('43%')} of Finishers Did Not Pay", tag="Appendix")
revise("disney-finishers", title=f"Finishers Pay Alike Across Games; {g('Counts')} Differ", tag="Appendix")
revise("q-rejected", tag="Appendix")
revise("rejected", tag="Appendix",
       reps=[("Similar players change their spend the same way in all games; the gap is completions", "Similar players change their spend the same way; they differ in how often they finish"),
             ("Players with only gameplay Jokers kept their spend (0.99–1.05×)", "Not seen for players with only gameplay Jokers (0.99–1.05×); the cost of a second Puzzle Joker is open"),
             ("Revenue per player +3%; the lower spend per finisher is a change in mix", "No sign: revenue per player +3%; lower spend per finisher is a change in mix (two albums)")])
revise("length", tag="Appendix")
print("revised")
