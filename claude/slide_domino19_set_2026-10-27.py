"""Eden 2026-10-27: Domino 19 versions of 9 cross-game slides (grid, all-144 curve, new per day, finishers vs far, Goldens step,
Goldens Easy/Hard by % time, Royals step, finish timing of 1-3 at close-4, revenue within 3 by day). Standard-population payers album 19
(119,201; $13.55M album revenue). Data: claude/domino19-set-2026-10-27.md (queries in claude/domino19_set_2026-10-27.sql).
Usage: python3 slide_domino19_set_2026-10-27.py <name> <idx> -> JSON requests (compact)."""
import json, sys, os, importlib.util
spec = importlib.util.spec_from_file_location('ch', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
E, WHITE, GOLD, GREY, DGREY, RED, MID, OUTL, ORANGE = ch.E, ch.WHITE, ch.GOLD, ch.GREY, ch.DGREY, ch.RED, ch.MID, ch.OUTL, ch.ORANGE
DOM = '#f5a14d'; PURPLE = '#c846e6'; HELD = '#4a4a4a'; SHADE = '#3a2025'

def line(S, x1, y1, x2, y2, col, w):
    o = S.oid('l'); up = y2 < y1
    S.R.append({'createLine': {'objectId': o, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': S.s,
        'size': {'width': {'magnitude': max(int((x2 - x1) * E), 1), 'unit': 'EMU'}, 'height': {'magnitude': max(int(abs(y2 - y1) * E), 1), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': -1 if up else 1, 'translateX': int(x1 * E), 'translateY': int(y1 * E), 'unit': 'EMU'}}}})
    S.R.append({'updateLineProperties': {'objectId': o, 'lineProperties': {'lineFill': {'solidFill': {'color': {'rgbColor': ch.rgb(col)}}}, 'weight': {'magnitude': w, 'unit': 'PT'}}, 'fields': 'lineFill,weight'}})

def head(S, title, gold, sub, msg, spans=()):
    S.text(0.5, 0.12, 9.0, 0.5, title, 20, WHITE, spans=[(gold, GOLD)])
    S.text(0.5, 0.63, 9.0, 0.28, sub, 10, GREY)
    S.text(0.5, 4.72, 8.6, 0.5, msg, 11, WHITE, spans=list(spans))
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)

def axes(S, px, py, pw, ph, vmax, ticks, fmt='{}%', xl=None):
    Y = lambda v: py + ph - ph * v / vmax
    for v in ticks:
        line(S, px, Y(v), px + pw, Y(v), OUTL, 0.5)
        S.text(px - 0.55, Y(v) - 0.11, 0.48, 0.22, fmt.format(v), 9, DGREY, align='END')
    if xl:
        for x, t in xl: S.text(x - 0.3, py + ph + 0.05, 0.6, 0.2, t, 9, GREY, align='CENTER')
    return Y

def poly(S, xs, ys, col, w, step=False):
    if not step:
        for i in range(len(xs) - 1): line(S, xs[i], ys[i], xs[i + 1], ys[i + 1], col, w)
        return
    start = 0  # merge flat runs: one horizontal per run, one vertical per change
    for i in range(1, len(xs)):
        if abs(ys[i] - ys[start]) > 0.002 or i == len(xs) - 1:
            line(S, xs[start], ys[start], xs[i], ys[start], col, w)
            if abs(ys[i] - ys[start]) > 0.002: line(S, xs[i], ys[start], xs[i], ys[i], col, w)
            start = i

HELD144 = [6,20,28,33,39,43,49,54,58,62,65,69,73,77,80,82,84,88,90,91,94,98,102,104,107,110,112,115,117,119,121,122,124,125,126,127,128,128,129,130,131,132,134,135,135,136,136,137,137,138]
NEW = [6,7,3,2,2,1,6,3,2,2,2,2,2,1,2,0,0,1,0,0,2,2,2,1,0,1,1,1,1,1]+[0]*20
MEDG = [0,1,1,1,2,2,2,2,3,3,3,4,4,5,5,6,6,7,8,8,9,10,11,11,12,12,13,13,13,14,15,16,16,17,18,19,19,19,19,19,20,21,23,23,24,24,25,25,25,25]
MEDR = [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,4,4,4,5,5,5,5,5,5,6,6]
EASYG = {5:1.43,10:3.21,15:5.84,20:8.3,25:10.61,30:13.4,35:16.31,40:18.75,45:21.64,50:23.13}
HARDG = {5:1.58,10:3.92,15:7.92,20:10.09,25:11.91,30:15.13,35:17.64,40:20.74,45:23.83,50:25.05}
FIN = {1:16.0,5:40.1,10:65.6,15:87.1,20:93.9,25:109.6,30:123.0,35:129.3,40:134.8,45:139.2,49:144.0}
FAR = {1:13.1,5:35.7,10:59.1,15:77.5,20:87.1,25:102.4,30:114.1,35:121.5,40:126.3,45:130.8,49:132.6}

def build(name, idx):
    S = ch.Slide(f'd19{name}_slide', idx)
    if name == 'grid':
        head(S, 'What the P50 Paying Player Still Misses at Close: Domino 19', 'P50 Paying Player',
             'One square = one of the 144 set stickers · median paying player · standard-population payers (119,201)',
             'The median album-19 payer ends 6 stickers short: 3 Goldens and 3 Royals, no commons.', [('6 stickers short', RED)])
        x0, y0, c = 3.2, 1.15, 0.27
        S.rect(x0, y0, 12 * c, 12 * c, HELD)
        for i in range(1, 12):
            S.rect(x0 + i * c - 0.01, y0, 0.02, 12 * c, '#212121'); S.rect(x0, y0 + i * c - 0.01, 12 * c, 0.02, '#212121')
        for j, col in zip(range(6, 12), [GOLD] * 3 + [PURPLE] * 3):
            S.rect(x0 + j * c + 0.02, y0 + 11 * c + 0.02, c - 0.04, c - 0.04, col)
        S.text(6.7, 2.2, 2.6, 0.6, '6 missing', 32, RED, bold=True)
        S.text(6.7, 2.85, 2.6, 0.3, '3 Goldens · 3 Royals', 12, GREY)
        S.text(6.7, 3.25, 2.7, 0.5, 'average payer: 9.6 missing\nalbum 20 median: 4 missing', 9, DGREY)
    elif name == 'curve':
        head(S, 'Stickers Collected Throughout the Album: Domino 19', 'Domino 19',
             'Median paying player · standard-population payers (119,201) · 50 days, close day included · line = median stickers held at the end of each day',
             'Album 19 gives something new almost every day until about day 30; after that the median player adds 1 sticker a day or less.', [('after that', RED)])
        px, py, pw, ph = 1.3, 1.15, 7.2, 3.0
        Y = axes(S, px, py, pw, ph, 100, (0, 50, 100), xl=[(px, '1'), (px + pw * 24 / 49, 'day 25'), (px + pw, 'close')])
        ii = list(range(0, 50, 2)) + [49]
        poly(S, [px + pw * i / 49 for i in ii], [Y(HELD144[i] / 144 * 100) for i in ii], DOM, 3)
        S.text(px + pw - 1.2, Y(96) - 0.35, 1.2, 0.25, '138 of 144', 10, DOM, bold=True, align='END')
        S.text(px, py + ph + 0.3, pw, 0.25, 'Longest wait: 4% of the album (2 days)', 12, WHITE, align='CENTER', spans=[('4%', DOM)])
    elif name == 'bars':
        head(S, 'New Stickers per Day, Median Paying Player: Domino 19', 'Domino 19',
             'Median paying player · standard-population payers (119,201) · new = a set sticker the player did not have · album day 1–50',
             'A 5-day pause in the middle (days 16–20), then from day 31 the median payer gets nothing new for the last 20 days.',
             [('5-day pause', RED), ('nothing new for the last 20 days', RED)])
        px, py, pw, ph = 1.0, 1.3, 8.2, 2.7
        Y = axes(S, px, py, pw, ph, 8, (0, 4, 8), fmt='{}')
        bw = pw / 50
        S.rect(px + 15 * bw, py, 5 * bw, ph, SHADE); S.rect(px + 30 * bw, py, 20 * bw, ph, SHADE)
        S.text(px + 13 * bw, py - 0.25, 9 * bw, 0.22, 'pause · days 16–20', 9, RED, align='CENTER')
        S.text(px + 30 * bw, py - 0.25, 20 * bw, 0.22, 'day 31 to close: median 0 a day', 9, RED, align='CENTER')
        for i, v in enumerate(NEW):
            if v: S.rect(px + i * bw + 0.02, Y(v), bw - 0.04, py + ph - Y(v), DOM)
        for d in (1, 10, 20, 30, 40, 50): S.text(px + (d - 0.5) * bw - 0.25, py + ph + 0.05, 0.5, 0.2, str(d), 9, GREY, align='CENTER')
        S.text(px, py + ph + 0.25, pw, 0.2, 'album day', 9, DGREY, align='CENTER')
    elif name == 'gap':
        head(S, 'Stickers Held by Album Day: Finishers vs Payers Who End 4+ Away, Domino 19', 'Finishers vs Payers Who End 4+ Away',
             'Standard-population payers · average stickers held · finishers = 144 on the day before close (5,320 · 4% of payers) · 4+ away = 140 or fewer (98,427 · 83%)',
             'The far payers fall behind from the first days; the gap is 7–9 stickers through the album and 11 at the end.', [('from the first days', RED)])
        px, py, pw, ph = 1.3, 1.15, 7.2, 3.0
        Y = axes(S, px, py, pw, ph, 144, (0, 36, 72, 108, 144), fmt='{}', xl=[(px, '0%'), (px + pw / 2, '50%'), (px + pw, '100%')])
        S.rect(px + pw * 0.7, py, pw * 0.3, ph, '#2f2c22')
        X = lambda d: px + pw * (d - 1) / 48
        poly(S, [X(d) for d in FAR], [Y(v) for v in FAR.values()], MID, 2.5)
        poly(S, [X(d) for d in FIN], [Y(v) for v in FIN.values()], DOM, 3)
        for d, g in ((25, 7), (35, 8)):
            line(S, X(d), Y(FIN[d]), X(d), Y(FAR[d]), WHITE, 1); S.text(X(d) + 0.05, Y(FAR[d]) - 0.05, 0.8, 0.25, f'gap {g}', 11, WHITE, bold=True)
        S.text(X(49) - 0.9, Y(144) - 0.3, 0.9, 0.25, 'finishers', 10, DOM, bold=True, align='END')
        S.text(X(49) - 1.4, Y(132.6) + 0.05, 1.4, 0.25, '4+ away · 133', 10, GREY, bold=True, align='END')
    elif name == 'gold':
        head(S, 'Goldens Collected Throughout the Album: Domino 19', 'Goldens',
             'Median paying player · standard-population payers (119,201) · 28 Goldens · line = median Goldens held at the end of each day',
             'Goldens arrive steadily in album 19; the median payer ends with 25 of 28 (89%).', [('25 of 28', GOLD)])
        px, py, pw, ph = 1.3, 1.15, 7.2, 3.0
        Y = axes(S, px, py, pw, ph, 100, (0, 50, 100), xl=[(px, '1'), (px + pw * 24 / 49, 'day 25'), (px + pw, 'close')])
        poly(S, [px + pw * i / 49 for i in range(50)], [Y(v / 28 * 100) for v in MEDG], DOM, 2.5, step=True)
        S.text(px, py + ph + 0.3, pw, 0.25, 'Longest wait: 10% of the album (5 days, days 36–41)', 12, WHITE, align='CENTER', spans=[('10%', DOM)])
    elif name == 'goldeh':
        head(S, "% of the Album's Goldens Collected, by % of Album Time: Domino 19 Easy vs Hard", 'Goldens',
             'Average paying player · standard-population payers · Easy 107,777 (90% of payers) · Hard 11,425 (10%) · 28 Goldens',
             'Easy payers trail Hard all album and end at 83% of the Goldens vs 89%.', [('83%', RED)])
        px, py, pw, ph = 1.3, 1.15, 7.2, 3.0
        Y = axes(S, px, py, pw, ph, 100, (0, 25, 50, 75, 100), xl=[(px, '0%'), (px + pw / 2, '50%'), (px + pw, '100%')])
        S.rect(px + pw * 0.7, py, pw * 0.3, ph, '#2f2c22')
        xs = [px] + [px + pw * d / 50 for d in EASYG]
        poly(S, xs, [Y(0)] + [Y(v / 28 * 100) for v in HARDG.values()], ORANGE, 3)
        poly(S, xs, [Y(0)] + [Y(v / 28 * 100) for v in EASYG.values()], GOLD, 3)
        S.text(px + pw + 0.05, Y(89) - 0.22, 1.0, 0.25, 'Hard 89%', 11, ORANGE, bold=True)
        S.text(px + pw + 0.05, Y(83) - 0.02, 1.0, 0.25, 'Easy 83%', 11, RED, bold=True)
    elif name == 'royal':
        head(S, 'Royals Collected Throughout the Album: Domino 19', 'Royals',
             'Median paying player · standard-population payers (119,201) · 9 Royals · line = median Royals held at the end of each day',
             'The median payer waits 13 days (days 8–21) for a second Royal and ends with 6 of 9.', [('13 days', RED)])
        px, py, pw, ph = 1.3, 1.15, 7.2, 3.0
        Y = axes(S, px, py, pw, ph, 100, (0, 50, 100), xl=[(px, '1'), (px + pw * 24 / 49, 'day 25'), (px + pw, 'close')])
        poly(S, [px + pw * i / 49 for i in range(50)], [Y(v / 9 * 100) for v in MEDR], DOM, 2.5, step=True)
        S.text(px, py + ph + 0.3, pw, 0.25, 'Longest wait: 26% of the album (13 days)', 12, WHITE, align='CENTER', spans=[('26%', RED)])
    elif name == 'when':
        head(S, 'When Did Payers Finish? Payers Missing 1–3 Stickers with 4 Days Left: Domino 19', '1–3 Stickers',
             'Standard-population payers with 141–143 stickers at the end of close−4 (5,083 · 4% of payers) · % of those who finished, by finish day',
             'Only 39% of them finished, and most only in the last day or two.', [('39%', RED)])
        vals = [('3 days', 20), ('2 days', 27), ('1 day', 37), ('Close', 16)]
        base, sc = 4.1, 0.06
        for i, (lab, v) in enumerate(vals):
            x = 1.8 + i * 1.7
            S.rect(x, base - v * sc, 0.9, v * sc, DOM if i == 0 else MID)
            S.text(x - 0.2, base - v * sc - 0.35, 1.3, 0.3, f'{v}%', 18, WHITE, bold=True, align='CENTER')
            S.text(x - 0.2, base + 0.05, 1.3, 0.25, lab, 10, GREY, align='CENTER')
    elif name == 'near':
        head(S, 'Revenue Share Within 3 Stickers (141–144), by Day Before Close: Domino 19', '(141–144)',
             '% of album revenue from payers with 141–144 stickers that day · standard-population payers (119,201; $13.55M)',
             'In album 19 only half of the revenue was within 3 stickers on the last day (52%; album 20: 78%).', [('52%', RED)])
        px, py, pw, ph = 1.3, 1.15, 7.2, 3.0
        vals = [19.8, 23.7, 27.0, 31.1, 37.8, 44.4, 51.5]
        Y = axes(S, px, py, pw, ph, 100, (0, 25, 50, 75, 100), xl=[(px + pw * i / 6, str(7 - i)) for i in range(7)])
        poly(S, [px + pw * i / 6 for i in range(7)], [Y(v) for v in vals], DOM, 3)
        S.text(px + pw + 0.05, Y(51.5) - 0.12, 1.0, 0.25, '52%', 12, RED, bold=True)
        S.text(px - 0.6, Y(19.8) - 0.12, 0.5, 0.25, '20%', 10, DOM, bold=True, align='END')
        S.text(px, py + ph + 0.25, pw, 0.2, 'days before close', 9, DGREY, align='CENTER')
    return S

if __name__ == '__main__':
    def rd(o):
        if isinstance(o, float): return round(o, 3)
        if isinstance(o, dict): return {k: rd(v) for k, v in o.items() if not (k in ('shearX', 'shearY') and v == 0)}
        if isinstance(o, list): return [rd(v) for v in o]
        return o
    print(json.dumps(rd(build(sys.argv[1], int(sys.argv[2])).R), ensure_ascii=False, separators=(',', ':')))
