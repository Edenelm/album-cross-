"""Domino Joker wave, album 19 vs 20 (Eden 2026-10-27): same measure as slide 54 ('% Of All PU Get Wild / Joker Last 7 Days Before Close'),
Domino only, album 19 next to album 20, one scale 0-12%. Data: claude/domino_end_rares_jokers_19v20_2026-10-27.sql.
Usage: python3 slide_domino_joker19v20_2026-10-27.py [insertion_index] -> JSON requests."""
import json, sys, os, importlib.util
spec = importlib.util.spec_from_file_location('ch', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
E, WHITE, GOLD, GREY, DGREY, OUTL = ch.E, ch.WHITE, ch.GOLD, ch.GREY, ch.DGREY, ch.OUTL
DAYS = [7, 6, 5, 4, 3, 2, 1]
DATA = {19: ([3.6, 2.2, 1.5, 1.5, 3.7, 7.3, 11.6], [0.0, 0.3, 0.8, 0.9, 1.0, 0.4, 0.5], 119201),   # gameplay, bought, payers
        20: ([1.4, 1.3, 2.4, 5.8, 11.3, 6.9, 4.0], [1.1, 0.6, 0.6, 1.3, 1.1, 1.0, 0.8], 106762)}
VMAX = 12.0

def line(S, x1, y1, x2, y2, col, w, dash='SOLID'):
    o = S.oid('l')
    up = y2 < y1
    S.R.append({'createLine': {'objectId': o, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': S.s,
        'size': {'width': {'magnitude': max(int((x2 - x1) * E), 1), 'unit': 'EMU'}, 'height': {'magnitude': max(int(abs(y2 - y1) * E), 1), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': -1 if up else 1, 'shearX': 0, 'shearY': 0, 'translateX': int(x1 * E), 'translateY': int(y1 * E), 'unit': 'EMU'}}}})
    S.R.append({'updateLineProperties': {'objectId': o, 'lineProperties': {'lineFill': {'solidFill': {'color': {'rgbColor': ch.rgb(col)}}},
        'weight': {'magnitude': w, 'unit': 'PT'}, 'dashStyle': dash}, 'fields': 'lineFill,weight,dashStyle'}})

def panel(S, x0, alb, peak_col):
    game, bought, n = DATA[alb]
    S.panel(x0, 1.1, 4.4, 3.45, f'Album {alb} · {n:,} payers')
    px, pw, py, ph = x0 + 0.55, 3.6, 1.6, 2.3      # plot area
    for v in (0, 6, 12):
        y = py + ph - ph * v / VMAX
        line(S, px, y, px + pw, y, OUTL, 0.5)
        S.text(px - 0.5, y - 0.11, 0.42, 0.22, f'{v}%', 8, DGREY, align='END')
    X = lambda i: px + i * pw / 6
    Y = lambda v: py + ph - ph * v / VMAX
    for i in range(6):
        line(S, X(i), Y(bought[i]), X(i + 1), Y(bought[i + 1]), GREY, 1.5)
        line(S, X(i), Y(game[i]), X(i + 1), Y(game[i + 1]), GOLD, 2.5)
    for i, d in enumerate(DAYS):
        S.text(X(i) - 0.2, py + ph + 0.04, 0.4, 0.2, str(d), 8, GREY, align='CENTER')
    S.text(px, py + ph + 0.22, pw, 0.2, 'days before close', 8, DGREY, align='CENTER')
    k = max(range(7), key=lambda i: game[i])
    S.text(X(k) - (1.0 if k == 6 else 0.6), Y(game[k]) - 0.3, 1.2, 0.24, f'{game[k]:.0f}% · {DAYS[k]} day{"s" if DAYS[k] > 1 else ""} out', 10, GOLD, bold=True, align='CENTER')

def build(idx):
    S = ch.Slide('dxjk_slide', idx)
    S.text(0.5, 0.12, 9.0, 0.5, '% of Payers Who Got a Joker Sticker per Day, Last 7 Days: Domino 19 vs 20', 20, WHITE, spans=[('Domino 19 vs 20', GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, 'Standard-population payers of each album · % who got a new sticker with a Joker that day · gold = from gameplay (events, puzzles, Market) · grey = bought with money', 10, GREY)
    panel(S, 0.5, 19, GOLD); panel(S, 5.1, 20, GOLD)
    S.text(0.5, 4.72, 8.6, 0.5, 'In album 20 the Joker wave peaked 3 days before close (11% of payers); in album 19 only on the last day (12%). Bought Jokers stayed at 0–1% a day in both.',
           11, WHITE, spans=[('3 days before close', GOLD), ('only on the last day', GOLD)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S

NOTES = ('Same measure as slide 54 (% Of All PU Get Wild / Joker Last 7 Days Before Close), Domino only, album 19 added next to album 20, one scale 0-12%. '
 'Population: standard-population payers of each album (not first album, not excluded or suspected cheater, login ratio >= 0.5 on the last row before close, row on close-1, paid on any album day incl. close): album 19 = 119,201, album 20 = 106,762. '
 'Line = % of them who got a new sticker through a Joker that day (first collection, collected_by_joker_flag). Bought = validated Domino paid-campaign rule; everything else = gameplay, Market included (Eden\'s rule).\n'
 'Days 7..1 before close, gameplay / bought %: album 19: 3.6/0.0, 2.2/0.3, 1.5/0.8, 1.5/0.9, 3.7/1.0, 7.3/0.4, 11.6/0.5. Album 20: 1.4/1.1, 1.3/0.6, 2.4/0.6, 5.8/1.3, 11.3/1.1, 6.9/1.0, 4.0/0.8.\n'
 'Fact: the gameplay Joker wave came 2 days earlier in album 20 (peak close-3, Movie Twister + Joker Puzzle) than in album 19 (peak close-1). Album 20 also had the GoldenKiosk at close-7/-6. Interpretation (correlation only): an earlier wave leaves time to use the Joker and pay for the rest before close; album 19 players got their Jokers when only one day was left.\n'
 'Source: claude/domino-end-rares-jokers-19v20-2026-10-27.md | SQL: claude/domino_end_rares_jokers_19v20_2026-10-27.sql | Script: claude/slide_domino_joker19v20_2026-10-27.py')

if __name__ == '__main__':
    print(json.dumps(build(int(sys.argv[1]) if len(sys.argv) > 1 else 107).R, ensure_ascii=False, separators=(',', ':')))
