"""Domino Easy vs Hard splits (Eden list item 2, 2026-10-27): 3 slides in the Domino deck, each right after its cross-game slide.
ehgap  -> after "The Rare Gap Widens in the Last 10%" ; ehlast -> after "Day of the Last New Rare" ; ehnear -> after near7b_slide.
Source: claude/domino-easy-hard-splits-2026-10-26.md | SQL: claude/domino_easy_hard_splits_2026-10-26.sql
Usage: python3 claude/slide_domino_easy_hard_2026-10-27.py <ehgap|ehlast|ehnear> <insertion_index>"""
import json, sys, importlib.util
spec = importlib.util.spec_from_file_location('ch', __file__.replace('slide_domino_easy_hard_2026-10-27.py', 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
Slide, WHITE, GOLD, GREY, DGREY, ORANGE, RED, PANEL, OUTL, BLUE, MID = ch.Slide, ch.WHITE, ch.GOLD, ch.GREY, ch.DGREY, ch.ORANGE, ch.RED, ch.PANEL, ch.OUTL, ch.BLUE, ch.MID
EASY, HARD = ORANGE, BLUE

def ehgap(idx):
    S = Slide('ehgap_slide', idx)
    S.frame('Royals Held at 90% of Album Time and at Close: Domino Easy vs Hard',
            "Average paying player · % of the album's Royals held · standard-population payers · albums 17, 19, 20",
            'Hard payers already hold 15–18 pts more Royals at 90% of the album; the last 10% adds as much or more for Hard (+4 to +11 pts vs +4 to +9).',
            msg_spans=[('15–18 pts more Royals at 90% of the album', GOLD)])
    rows = [(17, 'Easy', 63, 66, 4, '92% of payers · 58% of revenue'), (17, 'Hard', 81, 84, 4, '8% · 42%'),
            (19, 'Easy', 51, 56, 5, '90% · 52%'), (19, 'Hard', 66, 74, 8, '10% · 48%'),
            (20, 'Easy', 57, 66, 9, '92% · 55%'), (20, 'Hard', 70, 81, 11, '8% · 45%')]  # add = pts from the doc (unrounded difference)
    x0, W, y, h = 2.0, 5.2, 1.15, 0.36
    for i, (alb, seg, a90, acl, add, who) in enumerate(rows):
        yy = y + i * 0.5 + (i // 2) * 0.18
        if i % 2 == 0: S.text(0.5, yy + 0.1, 0.8, 0.4, f'Album {alb}', 12, WHITE, bold=True)
        S.text(1.3, yy, 0.7, h, seg, 11, EASY if seg == 'Easy' else HARD, bold=True, valign='MIDDLE')
        S.rect(x0, yy, W * a90 / 100, h, EASY if seg == 'Easy' else HARD)
        S.rect(x0 + W * a90 / 100, yy, W * (acl - a90) / 100, h, GOLD)
        S.text(x0 + W * acl / 100 + 0.08, yy, 1.4, h, f'{a90}% → {acl}%  (+{add} pts)', 10, WHITE, valign='MIDDLE')
        S.text(x0 + W * acl / 100 + 1.45, yy, 1.2, h, who, 7.5, DGREY, valign='MIDDLE')
    S.rect(2.0, 4.42, 0.15, 0.12, MID); S.text(2.2, 4.36, 1.6, 0.25, 'held at 90% of album time', 8, GREY)
    S.rect(3.9, 4.42, 0.15, 0.12, GOLD); S.text(4.1, 4.36, 1.6, 0.25, 'added in the last 10%', 8, GREY)
    return S

def ehlast(idx):
    S = Slide('ehlast_slide', idx)
    S.frame('Day of the Last New Royal, P50–95 Payers Who End Far: Domino Easy vs Hard',
            'Middle payers (P50–95 by spend at 75% of the album) who end 4+ stickers missing · days before close, median (revenue-weighted)',
            'In both segments the last new Royal arrives 8–12 days before close; Hard is at most one day later. The pause before the end is Domino-wide, not one segment.',
            msg_spans=[('8–12 days before close', GOLD)])
    tiles = [(19, 'Easy', 8, 10, '34,868', '32%', '50%'), (19, 'Hard', 9, 12, '3,754', '33%', '11%'),
             (20, 'Easy', 9, 12, '13,898', '14%', '18%'), (20, 'Hard', 10, 12, '1,472', '17%', '5%')]
    for i, (alb, seg, med, wtd, n, pp, pr) in enumerate(tiles):
        x = 0.5 + i * 2.2
        S.panel(x, 1.15, 2.0, 3.0)
        S.text(x + 0.15, 1.22, 1.7, 0.3, f'Album {alb} · {seg}', 12, EASY if seg == 'Easy' else HARD, bold=True)
        S.text(x, 1.7, 2.0, 0.8, f'{med}', 40, WHITE, bold=True, align='CENTER')
        S.text(x, 2.5, 2.0, 0.3, 'days before close (median)', 9, GREY, align='CENTER')
        S.text(x, 2.8, 2.0, 0.3, f'revenue-weighted: {wtd} days', 9, GREY, align='CENTER')
        S.text(x + 0.15, 3.3, 1.7, 0.8, f'{n} far payers\n{pp} of segment payers\n{pr} of segment revenue', 9, WHITE)
    return S

def mix(a, b, t):
    ha, hb = ch.rgb(a), ch.rgb(b)
    return '#' + ''.join(f'{int(round((ha[k] + (hb[k] - ha[k]) * t) * 255)):02x}' for k in ('red', 'green', 'blue'))

def cell(S, x, y, w, h, fill, t, bold):
    o = S.oid('c'); rgb = ch.rgb
    S.R.append({'createShape': {'objectId': o, 'shapeType': 'RECTANGLE', 'elementProperties': {'pageObjectId': S.s, 'size': ch.size(w, h), 'transform': ch.tf(x, y)}}})
    S.R.append({'updateShapeProperties': {'objectId': o, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': rgb(fill)}}}, 'outline': {'propertyState': 'NOT_RENDERED'}, 'contentAlignment': 'MIDDLE'}, 'fields': 'shapeBackgroundFill,outline,contentAlignment'}})
    S.R.append({'insertText': {'objectId': o, 'text': t}})
    S.R.append({'updateTextStyle': {'objectId': o, 'textRange': {'type': 'ALL'}, 'style': {'fontFamily': 'Oswald', 'fontSize': {'magnitude': 10, 'unit': 'PT'}, 'bold': bold, 'foregroundColor': {'opaqueColor': {'rgbColor': rgb(WHITE)}}}, 'fields': 'fontFamily,fontSize,bold,foregroundColor'}})
    S.R.append({'updateParagraphStyle': {'objectId': o, 'textRange': {'type': 'ALL'}, 'style': {'alignment': 'CENTER'}, 'fields': 'alignment'}})

def ehnear(idx):
    S = Slide('ehnear_slide', idx)
    S.frame("Revenue Share Within 3 Stickers, by Day Before Close: Domino Easy vs Hard",
            "% of the segment's album revenue from payers with 141–144 stickers that day · standard-population payers",
            'Hard reaches the end earlier in every album; in album 19, 40% of Hard revenue was within 3 a week before close vs 1% of Easy.',
            msg_spans=[('40% of Hard revenue', GOLD), ('1% of Easy', GOLD)])
    rows = [(17, 'Easy', [18, 26, 30, 33, 37, 41, 47]), (17, 'Hard', [38, 50, 55, 59, 63, 67, 72]),
            (19, 'Easy', [1, 2, 3, 6, 14, 23, 32]), (19, 'Hard', [40, 47, 53, 59, 63, 68, 72]),
            (20, 'Easy', [2, 7, 21, 45, 61, 68, 72]), (20, 'Hard', [8, 19, 41, 67, 79, 83, 86])]
    x0, cw, rh, y0 = 2.6, 1.9, 0.42, 1.4
    KEEP = (0, 3, 6)  # close-7, close-4, close-1 (full daily table in the notes)
    rows = [(a, sg, [v[k] for k in KEEP]) for a, sg, v in rows]
    for j, d in enumerate((7, 4, 1)):
        S.text(x0 + j * cw, 1.05, cw, 0.3, f'close−{d}', 9, GREY, align='CENTER')
    for i, (alb, seg, vals) in enumerate(rows):
        yy = y0 + i * rh + (i // 2) * 0.1
        if i % 2 == 0: S.text(0.5, yy + 0.2, 0.9, 0.4, f'Album {alb}', 12, WHITE, bold=True)
        S.text(1.4, yy, 0.8, rh, seg, 11, EASY if seg == 'Easy' else HARD, bold=True, valign='MIDDLE')
        base = EASY if seg == 'Easy' else HARD
        for j, v in enumerate(vals):
            cell(S, x0 + j * cw + 0.02, yy + 0.02, cw - 0.04, rh - 0.04, mix('#2b2b2b', base, v / 100), f'{v}%', v >= 40)
    S.text(0.5, 4.2, 8.6, 0.3, 'Easy = 90–92% of payers and 52–58% of album revenue; Hard = 8–10% of payers and 42–48%.', 8.5, GREY)
    return S

if __name__ == '__main__':
    S = {'ehgap': ehgap, 'ehlast': ehlast, 'ehnear': ehnear}[sys.argv[1]](int(sys.argv[2]))
    def rnd(o):
        if isinstance(o, float): return round(o, 3)
        if isinstance(o, dict): return {k: rnd(v) for k, v in o.items() if not (k in ('shearX', 'shearY') and v == 0)}
        if isinstance(o, list): return [rnd(v) for v in o]
        return o
    print(json.dumps(rnd(S.R), separators=(',', ':'), ensure_ascii=False))
