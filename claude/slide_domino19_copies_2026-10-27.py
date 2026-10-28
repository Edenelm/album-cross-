"""Eden 2026-10-27: Domino 19 copies of 9 cross-game slides, same design: duplicate the original, keep only the Domino card, redraw album-19 data.
Each copy goes right after its original. Data: claude/domino19-set-2026-10-27.md. Usage: python3 ... <deck_json> <name> -> JSON requests."""
import json, sys, re
E = 914400
J = json.load(open(sys.argv[1])); J = J.get('content', J)
SL = {s['objectId']: s for s in J['slides']}
ORDER = [s['objectId'] for s in J['slides']]
DOM = {'red': 0.957, 'green': 0.62, 'blue': 0.302}; GRID = {'red': 0.267, 'green': 0.267, 'blue': 0.267}
GREYL = {'red': 0.6, 'green': 0.6, 'blue': 0.6}

def tx(e): return ''.join(z.get('textRun', {}).get('content', '') for z in ((e.get('shape') or {}).get('text') or {}).get('textElements', []))
def xy(e):
    tr = e.get('transform', {}); return tr.get('translateX', 0) / E, tr.get('translateY', 0) / E

class B:
    def __init__(s, src, new, pos_after=None):
        s.src, s.new, s.P, s.n, s.R = src, new, new.replace('_slide', '') + '_', 0, []
        ids = {src: new}; ids.update({e['objectId']: s.P + e['objectId'] for e in SL[src]['pageElements']})
        s.R.append({'duplicateObject': {'objectId': src, 'objectIds': ids}})
        s.R.append({'updateSlidesPosition': {'slideObjectIds': [new], 'insertionIndex': ORDER.index(pos_after or src) + 2}})  # +1 after source, +1 for g19_slide already inserted at 22
    def els(s): return SL[s.src]['pageElements']
    def dele(s, pred):
        for e in s.els():
            x, y = xy(e)
            if pred(e['objectId'], x, y, tx(e)): s.R.append({'deleteObject': {'objectId': s.P + e['objectId']}})
    def rep(s, a, b): s.R.append({'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [s.new]}})
    def line(s, x1, y1, x2, y2, col=DOM, w=2.25):
        s.n += 1; o = f'{s.P}n{s.n}'; up = y2 < y1
        s.R.append({'createLine': {'objectId': o, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': s.new,
            'size': {'width': {'magnitude': max(int((x2 - x1) * E), 1), 'unit': 'EMU'}, 'height': {'magnitude': max(int(abs(y2 - y1) * E), 1), 'unit': 'EMU'}},
            'transform': {'scaleX': 1, 'scaleY': -1 if up else 1, 'translateX': int(x1 * E), 'translateY': int(y1 * E), 'unit': 'EMU'}}}})
        s.R.append({'updateLineProperties': {'objectId': o, 'lineProperties': {'lineFill': {'solidFill': {'color': {'rgbColor': col}}}, 'weight': {'magnitude': w, 'unit': 'PT'}}, 'fields': 'lineFill,weight'}})
    def rect(s, x, y, w, h, col):
        s.n += 1; o = f'{s.P}n{s.n}'
        s.R.append({'createShape': {'objectId': o, 'shapeType': 'RECTANGLE', 'elementProperties': {'pageObjectId': s.new, 'size': {'width': {'magnitude': int(w * E), 'unit': 'EMU'}, 'height': {'magnitude': int(h * E), 'unit': 'EMU'}}, 'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x * E), 'translateY': int(y * E), 'unit': 'EMU'}}}})
        s.R.append({'updateShapeProperties': {'objectId': o, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': col}}}, 'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill,outline'}})
    def step(s, xs, ys, col=DOM, w=2.25):
        st = 0
        for i in range(1, len(xs)):
            if abs(ys[i] - ys[st]) > 1e-6 or i == len(xs) - 1:
                s.line(xs[st], ys[st], xs[i], ys[st], col, w)
                if abs(ys[i] - ys[st]) > 1e-6: s.line(xs[i], ys[st], xs[i], ys[i], col, w)
                st = i
    def poly(s, xs, ys, col=DOM, w=2.5):
        for i in range(len(xs) - 1): s.line(xs[i], ys[i], xs[i + 1], ys[i + 1], col, w)

side = lambda i, x, y, t: y > 1.0 and (x < 3.4 or x > 6.5) and 'SuperPlay' not in t
HELD144 = [6,20,28,33,39,43,49,54,58,62,65,69,73,77,80,82,84,88,90,91,94,98,102,104,107,110,112,115,117,119,121,122,124,125,126,127,128,128,129,130,131,132,134,135,135,136,136,137,137,138]
NEW = [6,7,3,2,2,1,6,3,2,2,2,2,2,1,2,0,0,1,0,0,2,2,2,1,0,1,1,1,1,1]+[0]*20
MEDG = [0,1,1,1,2,2,2,2,3,3,3,4,4,5,5,6,6,7,8,8,9,10,11,11,12,12,13,13,13,14,15,16,16,17,18,19,19,19,19,19,20,21,23,23,24,24,25,25,25,25]
MEDR = [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,4,4,4,5,5,5,5,5,5,6,6]

def stepchart(src, new, data, total, oldtxt, newtxt, del_pat=None, image=None):
    b = B(src, new)
    b.dele(side)
    if del_pat: b.dele(lambda i, x, y, t: re.match(del_pat, i) is not None)
    px, pw, y0, y100 = 3.999, 2.187, 4.156, 2.014
    if image:
        b.dele(lambda i, x, y, t: i == image)
        y0, y100 = 4.0, 2.02
        for v in (y0, (y0 + y100) / 2, y100): b.line(px, v, px + pw, v, GRID, 0.75)
    xs = [px + pw * i / 50 for i in range(51)]
    ys = [y0 - (y0 - y100) * v / total for v in data] + [y0 - (y0 - y100) * data[-1] / total]
    if total == 144: b.poly(xs[::2] + [xs[-1]], ys[::2] + [ys[-1]], DOM, 2.25)
    else: b.step(xs, ys)
    for a, c in zip(oldtxt, newtxt): b.rep(a, c)
    return b

def build(name):
    if name == 'curve':
        return stepchart('a144_slide', 'a19c_slide', HELD144, 144, ['Album 20', 'Longest wait: 6%'], ['Album 19', 'Longest wait: 4%'], r'a144_dom\d+$')
    if name == 'gold':
        return stepchart('g32_slide', 'g19s_slide', MEDG, 28, ['Album 20', 'Longest wait: 12%'], ['Album 19', 'Longest wait: 10%'], r'g32_dom_[hv]\d+$')
    if name == 'royal':
        return stepchart('h621288aadfa9fec0_0_2005', 'r19s_slide', MEDR, 9, ['Longest wait: 30%', 'Dice Never Leaves Players'], ['Longest wait: 26%', 'Domino 19 Leaves Players'], None, 'h621288aadfa9fec0_0_2023')
    if name == 'bars':
        b = B('w144_slide', 'w19_slide')
        b.dele(lambda i, x, y, t: ('dice' in i or 'dis' in i or i.startswith('w_dom_b') or 'band' in i or 'jump' in i or i in ('w_logo1', 'w_logo3')))
        base, g5 = 3.306 + 0.7, 3.306   # base = 5 units below the 5-line: bar height 0.1/unit (b1: 4 units = 0.4)
        base = 3.156 + 0.4
        for i, v in enumerate(NEW):
            if v: b.rect(1.833 + i * 0.1545, base - 0.05 * v, 0.111, 0.05 * v, DOM)
        b.rect(1.833 + 15 * 0.1545 - 0.02, base - 0.45, 5 * 0.1545, 0.45, {'red': 0.29, 'green': 0.13, 'blue': 0.15})
        b.rep('Album 20 · 49 days', 'Album 19 · 49 days')
        return b
    if name == 'gap':
        b = B('gl1_slide', 'gl19_slide')
        b.dele(lambda i, x, y, t: side(i, x, y, t) or re.match(r'gl1_slide_domino_(far|fin)', i) or 'gap' in i or i == 'h22531cc986c0856e_34_292')
        X = lambda d: 4.04 + 2.17 * (d - 1) / 48; Y = lambda v: 4.256 - (4.256 - 2.12) * v / 144
        FIN = {1:16.0,5:40.1,10:65.6,15:87.1,20:93.9,25:109.6,30:123.0,35:129.3,40:134.8,45:139.2,49:144.0}
        FAR = {1:13.1,5:35.7,10:59.1,15:77.5,20:87.1,25:102.4,30:114.1,35:121.5,40:126.3,45:130.8,49:132.6}
        b.poly([X(d) for d in FAR], [Y(v) for v in FAR.values()], GREYL, 2.25)
        b.poly([X(d) for d in FIN], [Y(v) for v in FIN.values()], DOM, 2.5)
        for d in (25, 35): b.line(X(d), Y(FIN[d]), X(d), Y(FAR[d]), {'red': 1, 'green': 1, 'blue': 1}, 1)
        b.rep('Album 20 · 49 days', 'Album 19 · 49 days'); b.rep('Finishers 8% · 4+ away 54%', 'Finishers 4% · 4+ away 83%')
        return b
    if name == 'goldeh':
        b = B('h621288aadfa9fec0_0_2399', 'ge19_slide')
        b.dele(lambda i, x, y, t: side(i, x, y, t) or re.match(r'gs_dom_(s\d|e\d|dice_d|dis_d|dot|edot)', i))
        X = lambda p: 4.04 + 2.17 * p; Y = lambda v: 4.26 - (4.26 - 2.12) * v
        E19 = [0, 1.43, 3.21, 5.84, 8.3, 10.61, 13.4, 16.31, 18.75, 21.64, 23.13]; H19 = [0, 1.58, 3.92, 7.92, 10.09, 11.91, 15.13, 17.64, 20.74, 23.83, 25.05]
        b.poly([X(i / 10) for i in range(11)], [Y(v / 28) for v in H19], DOM, 2.75)
        b.poly([X(i / 10) for i in range(11)], [Y(v / 28) for v in E19], {'red': 1, 'green': 0.875, 'blue': 0.522}, 2.75)
        b.rep('90%', '89%'); b.rep('82%', '83%')
        b.rep('Domino: Hard (orange, 8–10% of payers, 42–48% of album revenue) and Easy (gold, 90–92%, 52–58%), albums 17/19/20', 'Domino 19 · standard-population payers: Hard (orange, 11,425 · 10% of payers) and Easy (gold, 107,777 · 90%)')
        b.rep('Domino Easy payers trail Hard by about 7 points from early in the album (59% vs 66% at 70%); the gap is in Goldens and Royals, not commons.', 'Domino 19: Easy payers trail Hard all album (58% vs 63% of the Goldens at 70% of the album) and end at 83% vs 89%.')
        return b
    if name == 'when':
        b = B('h621288aadfa9fec0_0_2189', 'wh19_slide')
        b.dele(side)
        new = {'h621288aadfa9fec0_0_2214': 20, 'h621288aadfa9fec0_0_2217': 27, 'h621288aadfa9fec0_0_2220': 37, 'h621288aadfa9fec0_0_2223': 16}
        lab = {'h621288aadfa9fec0_0_2215': 20, 'h621288aadfa9fec0_0_2218': 27, 'h621288aadfa9fec0_0_2221': 37, 'h621288aadfa9fec0_0_2224': 16}
        for e in b.els():
            o = e['objectId']; tr = e['transform']
            if o in new:
                h0 = e['size']['height']['magnitude'] / E; tgt = new[o] * 1.14 / 27
                t = dict(tr); t['scaleY'] = tgt / h0; t['translateY'] = int((4.52 - tgt) * E); t.setdefault('unit', 'EMU')
                b.R.append({'updatePageElementTransform': {'objectId': b.P + o, 'transform': t, 'applyMode': 'ABSOLUTE'}})
            if o in lab:
                t = dict(tr); t['translateY'] = int((4.52 - lab[o] * 1.14 / 27 - 0.3) * E); t.setdefault('unit', 'EMU')
                b.R.append({'updatePageElementTransform': {'objectId': b.P + o, 'transform': t, 'applyMode': 'ABSOLUTE'}})
                b.R.append({'deleteText': {'objectId': b.P + o, 'textRange': {'type': 'ALL'}}}); b.R.append({'insertText': {'objectId': b.P + o, 'text': f'{lab[o]}%'}})
        b.rep('avg of 2 albums', 'Domino 19 · 5,083 payers 1–3 missing at close−4 · 39% of them finished · % of those who finished')
        return b
    if name == 'near':
        b = B('near7_slide', 'n19_slide')
        b.dele(lambda i, x, y, t: re.match(r'near7_(dice|dis|dom)_\d', i) or i in ('near7_e_dice', 'near7_e_dis', 'near7_s_dice', 'near7_s_dis'))
        X = lambda i: 1.386 + 6.255 * i / 6; Y = lambda v: 4.454 - (4.454 - 1.536) * v / 100
        vals = [19.8, 23.7, 27.0, 31.1, 37.8, 44.4, 51.5]
        b.poly([X(i) for i in range(7)], [Y(v) for v in vals], DOM, 3)
        b.rep('Domino 78%', 'Domino 19: 52%')
        for e in b.els():
            o = e['objectId']; t = dict(e['transform']); t.setdefault('unit', 'EMU')
            if o == 'near7_e_dom': t['translateY'] = int((Y(51.5) - 0.12) * E); b.R.append({'updatePageElementTransform': {'objectId': b.P + o, 'transform': t, 'applyMode': 'ABSOLUTE'}})
            if o == 'near7_s_dom':
                t['translateY'] = int((Y(19.8) - 0.12) * E); b.R.append({'updatePageElementTransform': {'objectId': b.P + o, 'transform': t, 'applyMode': 'ABSOLUTE'}})
                b.R.append({'insertText': {'objectId': b.P + o, 'text': '2', 'insertionIndex': 0}})
        b.rep('Dice 63, Domino 20, Disney 15', 'Domino 19')
        b.rep('Dice and Domino bring about 80% of revenue within 3 stickers by the last day; Disney only 57%.', 'In Domino 19 only 52% of album revenue was within 3 stickers by the last day (Domino 20: 78%).')
        return b

def rd(o):
    if isinstance(o, float): return round(o, 4)
    if isinstance(o, dict): return {k: rd(v) for k, v in o.items()}
    if isinstance(o, list): return [rd(v) for v in o]
    return o
print(json.dumps(rd(build(sys.argv[2]).R), ensure_ascii=False, separators=(',', ':')))
