import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from lib import *
bars = [("Last album's<br>group", 56, "#7A7A7A", 1.0), ("This album<br>after 10%", 53, GOLD, 1.0), ("after 25%", 65, GOLD, 1.0),
        ("after 50%", 76, GOLD, 0.45), ("after 75%", 87, GOLD, 0.45)]
L0, T0, W, H = 128, 330, 1080, 520
base = T0 + H - 70
top = T0 + 40
out = [f'<div style="position:absolute;left:{L0}px;top:{T0}px;width:{W}px;height:{H}px;background:#262626;border:1px solid #3A3A3A;border-radius:20px"></div>']
slot = (W - 80) / len(bars)
for k, (lab, v, col, op) in enumerate(bars):
    cx = L0 + 40 + slot * (k + 0.5)
    bw = 120
    bh = v / 100 * (base - top)
    out.append(f'<div style="position:absolute;left:{cx-bw/2:.0f}px;top:{base-bh:.0f}px;width:{bw}px;height:{bh:.0f}px;background:{col};opacity:{op};border-radius:4px 4px 0px 0px"></div>')
    out.append(p(cx - 80, base - bh - 52, 160, f"{v}%", 40, "#F5F5F0", "center", 500))
    out.append(p(cx - slot / 2, base + 10, slot, lab, 24, "#C8C8C0", "center"))
out.append(f'<div style="position:absolute;left:{L0+40}px;top:{base}px;width:{W-80}px;height:2px;background:#6A6A6A"></div>')
# bracket over the partly-circular bars
out.append(p(L0 + 40 + slot * 3, T0 + 14, slot * 2, "partly measures itself", 22, "#9E9E9E", "center"))
side = (f'<div style="position:absolute;left:1260px;top:330px;width:532px;display:flex;flex-direction:column;gap:20px">'
        + card("How to read", "Each payer is put in a spend group ($ a day). A bar is the share of revenue put in the group the player actually ended the album in.", GREY)
        + card("Use", "Start the album from last album's group. Switch to this album's spend about a quarter in.", GOLD)
        + '</div>')
body = "\n".join(out) + side
html = section("predictor", f"Sort by This Album's Spend From a {g('Quarter')} In",
               "Share of revenue placed in the right spend group · average of the three games (they are almost identical)",
               body, "Method",
               "Question: to give each spend group its own target we must decide, during the album, which group a player belongs to. Two sources: the player's group in the last album (known at album start, stays the same), or the player's spend so far in this album, projected to the full album. Measure: share of album revenue whose player was placed in the group ($ a day: ≤2 / 2–5 / 5–20 / >20) they actually ended the album in. Values: last album Dice 58%, Domino 55%, Disney 56% (average 56%). Spend so far at 10 / 25 / 50 / 75% of album time: Dice 50 / 63 / 75 / 86%, Domino 53 / 66 / 77 / 87%, Disney 55 / 65 / 77 / 88%. Reading: at 10% of the album last album is as good or better; from about 25% this album's spend wins. After about a quarter the comparison is partly circular, because spend so far is part of the album total it is trying to predict (dimmed bars), so the fair window is 10–25%. Disney test: combining both at day 5 placed 59% right, the best early result. Standard population, not first album; Dice 61/63, Domino 19/20, Disney 14/15. SQL: claude/dice_predictor_queries.sql; Domino Dom6, Disney D5b.",
               gap=20)
open(os.path.join(sys.argv[1], "project/slides/predictor.html"), "w").write(html)
