import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from lib import *
vals = {"dice": [("53", .99), ("55", 1.09), ("57", 1.09), ("59", 1.16), ("61", 1.28), ("63", 1.32)],
        "domino": [("15", .84), ("16", .82), ("17", .80), ("18", .85), ("19", .86), ("20", .89)],
        "disney": [("10", 1.11), ("11", 1.12), ("12", .97), ("13", 1.01), ("14", .91), ("15", .91)]}
rows = {}
for k, lst in vals.items():
    col = {"dice": DICE, "domino": DOMINO, "disney": DISNEY}[k]
    rows[k] = [(a, v, col if i in (0, len(lst) - 1) else "#5A5A5A") for i, (a, v) in enumerate(lst)]
body = vbars_panels(rows, 1.5, lambda v: f"${v:.2f}", top=290, height=540, cat_size=24, val_size=24)
for i, (txt, col) in enumerate([("+33%  ·  $0.99 → $1.32", GREEN), ("+6%  ·  $0.84 → $0.89", "#F5F5F0"), ("−18%  ·  $1.11 → $0.91", RED)]):
    body += p([128, 704, 1280][i], 846, 512, txt, 32, col, "center", 500)
body += p(128, 904, 1664, "Disney: players in their 7th+ album went from 19% to 44% of active days and spend less per day, so part of the fall may be player mix.", 24, "#9E9E9E", "left", 300)
html = section("album-curves", f"Revenue per Active Day: Dice {g('Up', GREEN)}, Disney {g('Down', RED)}",
               "Album revenue per active day, one bar per album · last 6 albums · same scale in all panels · first and latest album in color",
               body, "Chapter 1",
               "Population: all players who received the album, active days, close day excluded, game exclusions; revenue = album-table spend column (all in-game spend on album days). Albums: Dice 53–63 (Dec 2025–Sep 2026), Domino 15–20 (Jan–Oct 2026; album 18 had 14 sets), Disney 10–15 (Feb–Oct 2026; album 13 was 21 days). Values: Dice 0.99 / 1.09 / 1.09 / 1.16 / 1.28 / 1.32; Domino 0.84 / 0.82 / 0.80 / 0.85 / 0.86 / 0.89; Disney 1.11 / 1.12 / 0.97 / 1.01 / 0.91 / 0.91. Fact for the levels. Interpretation: in Disney the share of active days from 7th+ album players grew from 19% to 44% and they spend $0.71–0.81 per day vs $0.90–1.11 overall, so part of the fall may be mix (not proven). The within-album shape (each 10% of album time) is on the album-shape slide. Source: claude/album-timeline-7plus-end-2026-10-19.md.", gap=20)
open(sys.argv[1], "w").write(html)
