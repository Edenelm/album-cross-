import sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
from lib import *
vals = {"dice": [("53", 1.30), ("55", 1.30), ("57", 1.44), ("59", 1.37), ("61", 1.47), ("63", 1.58)],
        "domino": [("15", .93), ("16", .87), ("17", .90), ("18", 1.12), ("19", 1.00), ("20", 1.06)],
        "disney": [("10", 1.21), ("11", 1.15), ("12", 1.00), ("13", 1.03), ("14", .90), ("15", .98)]}
rows = {}
for k, lst in vals.items():
    col = {"dice": DICE, "domino": DOMINO, "disney": DISNEY}[k]
    rows[k] = [(a, v, col if i in (0, len(lst) - 1) else "#5A5A5A") for i, (a, v) in enumerate(lst)]
body = vbars_panels(rows, 1.7, lambda v: f"${v:.2f}", top=290, height=540, cat_size=24, val_size=24)
for i, (txt, col) in enumerate([("+22%  ·  $1.30 → $1.58", GREEN), ("+14%  ·  $0.93 → $1.06", GREEN), ("−19%  ·  $1.21 → $0.98", RED)]):
    body += p([128, 704, 1280][i], 846, 512, txt, 32, col, "center", 500)
body += p(128, 904, 1664, "Disney: more of its active days now come from 7th+ album players, who spend less per day, so part of the fall may be player mix (not proven).", 24, "#9E9E9E", "left", 300)
html = section("end-trend", f"Last 4 Days: Dice {g('Up', GREEN)}, Disney {g('Down', RED)}",
               "Revenue per active day in the last 4 days of each album · last 6 albums · same scale in all panels · first and latest album in color",
               body, "Chapter 1",
               "Last 4 days = 4 to 1 days before close (close day excluded). Population: all players who received the album, active days, game exclusions; revenue = album-table spend column (all in-game spend on album days). Albums: Dice 53–63 (Dec 2025–Sep 2026), Domino 15–20 (Jan–Oct 2026; album 18 had 14 sets), Disney 10–15 (Feb–Oct 2026; album 13 was 21 days). Values: Dice 1.30 / 1.30 / 1.44 / 1.37 / 1.47 / 1.58; Domino 0.93 / 0.87 / 0.90 / 1.12 / 1.00 / 1.06; Disney 1.21 / 1.15 / 1.00 / 1.03 / 0.90 / 0.98. Fact for the levels. Compare with the whole-album slide before: Dice's whole album rose +33%, its last 4 days +22%; Disney's whole album fell −18%, its last 4 days −19%. Interpretation: in Disney the share of active days from 7th+ album players grew from 19% to 44%; they spend less per day, which may explain part of the fall (not proven), but they also barely lift at the end (+2% to +8%, albums 11–15). Source: claude/album-timeline-7plus-end-2026-10-19.md and the album-trend query.", gap=20)
open(os.path.join(sys.argv[1], "project/slides/end-trend.html"), "w").write(html)
d = json.load(open(os.path.join(sys.argv[1], "project/deck.json")))
if "end-trend" not in d["order"]:
    d["order"].insert(d["order"].index("album-curves") + 1, "end-trend")
json.dump(d, open(os.path.join(sys.argv[1], "project/deck.json"), "w"), ensure_ascii=False)
print(d["order"][8:14])
