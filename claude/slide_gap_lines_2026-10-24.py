"""ALBUM END: extra slide at the end of the deck (Eden 2026-10-24) - the gap to finishers as a line chart per game, built like the
"Goldens Split After 70% of the Album" slide: 3 panels with logos, x = % of the album, last 30% shaded.
Lines = average unique set stickers by album day: finishers (144 on close-1) vs payers who end 4+ away (<=140 on close-1).
Data: claude/results/gap_by_day_3games_2026-10-24.csv (SQL claude/gap_by_day_3games_2026-10-24.sql, doc gap-by-day-3games-2026-10-24.md).
Usage (from claude/): python3 slide_gap_lines_2026-10-24.py <g1|notes> [insertionIndex]  -> prints update_presentation requests (JSON)."""
import csv, json, sys, importlib.util as u
s = u.spec_from_file_location('h', 'slide_t7_dice_prize_2026-10-25.py'); h = u.module_from_spec(s); s.loader.exec_module(h)
E = h.E
S = 'gl1_slide'
# Same colours / geometry as the Goldens Split slide (h621288aadfa9fec0_0_2399)
GAMES = [('Dice', '63', {'red': 0.435, 'green': 0.639, 'blue': 1}), ('Domino', '20', {'red': 0.961, 'green': 0.627, 'blue': 0.29}),
         ('Disney', '15', {'red': 0.235, 'green': 0.784, 'blue': 0.706})]
FAR = {'red': 0.62, 'green': 0.62, 'blue': 0.62}
PANEL, SHADE = {'red': 0.149, 'green': 0.149, 'blue': 0.149}, {'red': 0.208, 'green': 0.2, 'blue': 0.173}
GRID0, GRID = {'red': 0.4, 'green': 0.4, 'blue': 0.4}, {'red': 0.239, 'green': 0.239, 'blue': 0.239}
AXIS = {'red': 0.62, 'green': 0.62, 'blue': 0.62}
# Logos: contentUrl of the logo images on the Goldens Split slide (re-read them if the publish fails: the links expire)
LOGOS = sys.argv[3:6] if len(sys.argv) > 5 else [None, None, None]

def load():
    d = {}
    for r in csv.DictReader(open('results/gap_by_day_3games_2026-10-24.csv')):
        d.setdefault(r['game'], {'len': int(r['album_len'])}).setdefault(r['st'], {})[int(r['album_day'])] = (float(r['avg_uniq']), int(r['players']))
    return d

def seg(oid, x1, y1, x2, y2, c, w):
    x1, y1, x2, y2 = int(x1 * E), int(y1 * E), int(x2 * E), int(y2 * E)
    up = y2 < y1
    tr = {'scaleX': 1, 'scaleY': -1 if up else 1, 'translateX': x1, 'translateY': y1, 'unit': 'EMU'}
    return [{'createLine': {'objectId': oid, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': S,
             'size': {'width': {'magnitude': max(x2 - x1, 1), 'unit': 'EMU'}, 'height': {'magnitude': max(abs(y2 - y1), 1), 'unit': 'EMU'}}, 'transform': tr}}},
            {'updateLineProperties': {'objectId': oid, 'lineProperties': {'lineFill': {'solidFill': {'color': {'rgbColor': c}}},
             'weight': {'magnitude': w, 'unit': 'PT'}, 'dashStyle': 'SOLID'}, 'fields': 'lineFill,weight,dashStyle'}}]

def dot(oid, x, y, c, r=0.035):
    return h.box(S, oid, x - r, y - r, 2 * r, 2 * r, 'ELLIPSE') + [{'updateShapeProperties': {'objectId': oid, 'shapeProperties': {
        'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': c}}}, 'outline': {'propertyState': 'NOT_RENDERED'}},
        'fields': 'shapeBackgroundFill.solidFill.color,outline.propertyState'}}]

def g1(idx=None):
    d = load()
    msg = '→ In every game, payers who end 4+ away fall behind gradually. In Disney the gap is widest mid-album: 16 at 50% vs 9 in Dice and 12 in Domino.'
    R = h.page(S, 'Stickers Held by Album Day: Finishers vs Payers Who End 4+ Away',
               'Average paying player · unique set stickers of 144 · colored line = finishers, grey line = payers who end 4+ away · shaded = last 30%',
               msg, msg_red='In Disney the gap is widest mid-album', idx=idx, msg_y=4.72)
    for g, (name, alb, col) in enumerate(GAMES):
        k = name.lower()
        px = 0.67 + 3.0 * g
        X0, X1, Y0, Y1 = px + 0.37, px + 2.54, 4.256, 2.12   # chart area: x 0-100% of album, y 0-144 stickers
        R += h.box(S, f'{S}_{k}_pn', px, 1.54, 2.66, 3.12, 'ROUND_RECTANGLE') + [{'updateShapeProperties': {'objectId': f'{S}_{k}_pn', 'shapeProperties': {
            'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': PANEL}}},
            'outline': {'outlineFill': {'solidFill': {'color': {'rgbColor': {'red': 0.95, 'green': 0.95, 'blue': 0.95}}}}, 'weight': {'magnitude': 0.75, 'unit': 'PT'}}},
            'fields': 'shapeBackgroundFill.solidFill.color,outline.outlineFill.solidFill.color,outline.weight'}}]
        if LOGOS[g]:
            R += [{'createImage': {'objectId': f'{S}_{k}_logo', 'url': LOGOS[g], 'elementProperties': {'pageObjectId': S,
                   'size': {'width': {'magnitude': int(0.89 * E), 'unit': 'EMU'}, 'height': {'magnitude': int(0.31 * E), 'unit': 'EMU'}},
                   'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int((px + 0.12) * E), 'translateY': int(1.64 * E), 'unit': 'EMU'}}}}]
        L = d[name]['len']
        fin, far = d[name]['finished'], d[name]['far_4plus']
        R += h.tbox(S, f'{S}_{k}_hd', px + 0.99, 1.68, 1.55, 0.22, f'Album {alb} · {L} days', 8, h.GREY, False, 'END')
        R += h.rect(S, f'{S}_{k}_sh', X0 + 0.7 * (X1 - X0), Y1, 0.3 * (X1 - X0), Y0 - Y1, SHADE)
        for i, v in enumerate([0, 36, 72, 108, 144]):
            y = Y0 - v / 144 * (Y0 - Y1)
            R += seg(f'{S}_{k}_gr{i}', X0, y, X1, y, GRID0 if i == 0 else GRID, 0.75 if i == 0 else 0.5)
            R += h.tbox(S, f'{S}_{k}_yl{i}', px - 0.03, y - 0.1, 0.38, 0.2, str(v), 8, AXIS, False, 'END')
        for i, p in enumerate([0, 50, 100]):
            R += h.tbox(S, f'{S}_{k}_xl{i}', X0 + p / 100 * (X1 - X0) - 0.23, Y0 + 0.03, 0.46, 0.18, f'{p}%', 8, AXIS, False, 'CENTER')
        X = lambda day: X0 + day / L * (X1 - X0)
        Y = lambda v: Y0 - v / 144 * (Y0 - Y1)
        for st, series, c, w in [('far', far, FAR, 1.5), ('fin', fin, col, 2)]:
            days = sorted({1} | {round(L * i / 10) for i in range(1, 11)})   # day 1, then a point every 10% of the album (as the Goldens slide)
            for a, b in zip(days, days[1:]):
                R += seg(f'{S}_{k}_{st}{b}', X(a), Y(series[a][0]), X(b), Y(series[b][0]), c, w)
            R += dot(f'{S}_{k}_{st}_dot', X(L), Y(series[L][0]), c)
        # end labels and the gap at 50% of the album
        R += h.tbox(S, f'{S}_{k}_efin', X(L) - 0.55, Y(144) - 0.27, 0.6, 0.22, '144', 10, h.WHITE, True, 'END')
        R += h.tbox(S, f'{S}_{k}_efar', X(L) - 0.55, Y(far[L][0]) + 0.02, 0.6, 0.22, f'{far[L][0]:.0f}', 10, FAR, True, 'END')
        m = round(L / 2)
        gap = fin[m][0] - far[m][0]
        R += seg(f'{S}_{k}_gap', X(m), Y(fin[m][0]), X(m) + 0.0001, Y(far[m][0]), h.WHITE, 1)
        R += h.tbox(S, f'{S}_{k}_gapl', X(m) + 0.04, (Y(fin[m][0]) + Y(far[m][0])) / 2 - 0.11, 0.9, 0.22, f'gap {gap:.0f}', 10,
                    h.RED if name == 'Disney' else h.WHITE, True)
    return R

NOTES = {S: """What this shows: for each game, the average number of unique set stickers (of 144) that two groups of paying players held on each album day. Colored line = finishers (all 144 on the day before close). Grey line = payers who end 4 or more stickers away (140 or fewer on the day before close). X axis = share of the album's days, so albums of different length line up (a point every 10%). Shaded = last 30% of the album.
Example: in Disney 15, on day 21 (50% of the album) the average finisher held 103 stickers and the average far payer 87: 16 behind. On the last day before close: 144 vs 131 (13 behind).
Gap at 20% / 50% / 70% / last day: Dice 63: 7 / 9 / 11 / 12 · Domino 20: 7 / 12 / 12 / 12 · Disney 15: 10 / 16 / 17 / 13.
Fact: in all three games the far payers start a little behind and fall further behind gradually, so this is partly normal player difference. Fact: in Disney the gap opens faster and is wider mid-album (4–6 stickers more than Dice and Domino); by the end it narrows to 13, close to the others.
Interpretation (not proven): the extra mid-album gap fits Disney's wave release. Caveats: one album per game; Disney's far group is 81% of payers (a quarter to a half in the other games), so it includes weaker players.
Who: standard-population payers (not first album, not excluded, login ratio ≥ 0.5, active on close−1, paid during the album). Group size (finishers / far payers): Dice 20,966 / 69,251; Domino 8,548 / 57,958; Disney 13,184 / 262,515. Average over players with a row that day.
SQL: claude/gap_by_day_3games_2026-10-24.sql. Data: claude/results/gap_by_day_3games_2026-10-24.csv. Doc: claude/gap-by-day-3games-2026-10-24.md."""}

if __name__ == '__main__':
    if sys.argv[1] == 'notes': print(json.dumps(NOTES, ensure_ascii=False))
    else: print(json.dumps(globals()[sys.argv[1]](int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] != '-' else None), ensure_ascii=False, separators=(',', ':')))
