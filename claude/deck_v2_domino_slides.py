import sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
from lib import *
ROOT = sys.argv[1]

# --- last3days: two-album averages for every game (Domino = 19/20) ---
rows = [("Dice", DICE, 39, 86, "89%"), ("Domino", DOMINO, 44, 89, "95%"), ("Disney", DISNEY, 62, 99, "78%")]
W = 1000
body = ('<div style="display:flex;flex-direction:row;gap:40px;padding:0px 0px 0px 220px">'
        f'<p style="font-size:26px;color:#C8C8C0"><span style="color:{GOLD}">■</span> Last day</p>'
        '<p style="font-size:26px;color:#C8C8C0"><span style="color:#B39B4F">■</span> 2–3 days before</p>'
        '<p style="font-size:26px;color:#C8C8C0"><span style="color:#4A4A4A">■</span> Earlier</p>'
        '<p style="width:420px;font-size:26px;color:#C8C8C0;text-align:right">Last sticker via Wild / Joker</p></div>')
body += '<div style="flex:1;display:flex;flex-direction:column;justify-content:space-around">'
for name, col, d1, d3, pick in rows:
    w1 = round(W * d1 / 100); w2 = round(W * (d3 - d1) / 100); w3 = W - w1 - w2
    body += (f'<div style="display:flex;flex-direction:row;align-items:center;gap:24px">'
             f'<p style="width:196px;font-size:40px;font-weight:500;color:{col}">{name}</p>'
             f'<div style="width:{W}px;display:flex;flex-direction:row;height:84px">'
             f'<div style="width:{w1}px;background:{GOLD};display:flex;align-items:center;padding:0px 16px"><p style="font-size:34px;color:#212121">{d1}%</p></div>'
             f'<div style="width:{w2}px;background:#B39B4F;display:flex;align-items:center;padding:0px 16px"><p style="font-size:34px;color:#212121">{d3}% by 3 days</p></div>'
             f'<div style="width:{w3}px;background:#4A4A4A"></div></div>'
             f'<p style="width:200px;font-size:40px;text-align:right">{pick}</p></div>')
body += '</div>'
body += '<p style="font-size:30px;font-weight:300;line-height:1.35">→ In every game completion is a <span style="color:#FFDF85">timed event</span> at the very end.</p>'
S = {}
S["last3days"] = section("last3days", f"Most Finishers Finish in the {g('Last 3 Days')}",
                         "Paying finishers by the day they finished · average of two albums per game: Dice 61 / 63, Domino 19 / 20, Disney 14 / 15",
                         body, "Chapter 3",
                         "Fact. Paying finishers, standard population; finish day = first day with 144 unique stickers; close day excluded. Averages of two albums. By album: last day Dice 39% / 38%, Domino 57% / 31%, Disney 65% / 59%; by 3 days before close Dice 88% / 84%, Domino 93% / 85%, Disney 99% / 99%. Last sticker via Wild / Joker: Dice 90% / 87%, Domino 96% / 95% (album 20 run 2026-10-19: 94.8% of 8,548 paying finishers; album 19 rerun matched 95.5%), Disney 86% / 69%. Paying finishers per album: Dice 14.3K / 18.9K, Domino 5.3K / 8.5K, Disney 14.0K / 13.2K. Domino 17 was different: 39% on the last day, only 63% in the last 3 days, 45% via Joker; it is covered on the Domino slides that follow.",
                         gap=36)

# --- Domino three albums ---
hdr = ["Domino album", "17", "19", "20"]
trs = [["Album length (days)", "39", "49", "49"],
       ["How the end was closed", "Paid Joker from 7 days + Market", "Gameplay Jokers; paid from 5 days", "Two Puzzle event Jokers"],
       ["Payers who finished", "5.7%", "4.5%", "8.0%"],
       ["Finished by 4 days before close", "37%", "7%", "15%"],
       ["Finishers who did not pay", "14%", "27%", "43%"],
       ["Last sticker via Joker (paying finishers)", "45%", "96%", "95%"],
       ["Revenue per active day, whole album", "$0.80", "$0.86", "$0.89"],
       ["Revenue per active day, last 4 days", "$0.90", "$1.00", "$1.06"],
       ["Finishers' spend after completion vs usual", "+8%", "+16%", "not yet measured"]]
GN, YL = ("#D9EAD3", "#1E5631"), ("#FFF2CC", "#6B5A1E")
hl = {(2, 3): GN, (3, 1): GN, (4, 3): YL, (6, 3): GN, (7, 3): GN, (8, 3): ("#2A2A2A", "#9E9E9E")}
body = table(hdr, trs, [34, 22, 22, 22], 24, hl)
def mini(t, x):
    return (f'<div style="flex:1;display:flex;flex-direction:column;gap:6px;background:#2A2A2A;border-radius:14px;padding:16px 22px;border-left:6px solid {DOMINO}">'
            f'<p style="font-size:26px;font-weight:500;color:{DOMINO}">Album {t}</p><p style="font-size:24px;font-weight:300;line-height:1.3">{x}</p></div>')
body += row(mini("17", "Earliest tools: finishes spread over the week."),
            mini("19", "Late tools: finishing squeezed into the last days, fewest finishers."),
            mini("20", "Puzzle Jokers: most finishers, many non-payers; highest revenue per day."), gap=20)
S["domino-3albums"] = section("domino-3albums", f"Three Domino Endings, Three {g('Different Outcomes')}",
                              "Same game, three end designs · standard population · three albums, not a test",
                              body, "Chapter 3",
                              "Facts per album (standard population; payers = paid during the album). Payer finishers: 7,783 of 135,609 (17), 5,319 of 118,955 (19), 8,548 of 106,520 (20); all finishers 9,011 / 7,270 / 15,091. End design: album 17 sold paid Jokers from 7 days before close and ran a Market (days 7–5); album 19 sold paid Jokers from 5 days at small scale and closed mostly through gameplay Jokers (35.6K on the last day vs 961 paid); album 20's Puzzle event gave two Jokers (44% of finishers closed through it). Revenue per active day: all players who received the album (album-timeline doc); end lift vs rest of album +15% / +18% / +20%. Not comparable directly: album 17 is 10 days shorter and closed in May (19 in August, 20 in October); Domino's player base fell album to album (1.27M in 18, 1.0M in 19, 0.89M in 20), which can raise revenue per day without any design effect. Missing: total revenue and revenue per player for album 17 (the existing query covers 18–20). Last sticker via Joker: 17 from endgame-last-week (F-late payers); 19 / 20 from claude/domino_last_sticker_joker_19_20.sql (run 2026-10-19, 19 GB): 95.5% / 94.8%; last sticker type in 20: Royal 80%, Golden 18%. Post-completion for album 20 not yet run.",
                              gap=22)

for k, v in S.items():
    open(os.path.join(ROOT, f"project/slides/{k}.html"), "w").write(v)
d = json.load(open(os.path.join(ROOT, "project/deck.json")))
if "domino-3albums" not in d["order"]:
    d["order"].insert(d["order"].index("domino-weeks"), "domino-3albums")
json.dump(d, open(os.path.join(ROOT, "project/deck.json"), "w"), ensure_ascii=False)
print(d["order"][d["order"].index("same-spend"):d["order"].index("same-spend") + 5])
