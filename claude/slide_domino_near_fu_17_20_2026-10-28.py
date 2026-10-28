# 2026-10-28 (Eden): bar slide after dlw_slide: payers near FU (missing 1-3) at close-4, % of payers and % of album revenue, Domino 17-20.
# Data: claude/domino-near-fu-c4-17-20-2026-10-28.md. Frame copied from dlw_slide.
import json, sys
NEW, P = 'nfu_slide', 'nfu_'
D = {17: (11, 28, '+4%'), 18: (20, 37, '+20%'), 19: (4, 26, '+4%'), 20: (22, 46, '+11%')}
COL = {17: {'red': 0.78, 'green': 0.49, 'blue': 1.0}, 18: {'red': 0.25, 'green': 0.8, 'blue': 0.75},
       19: {'red': 1, 'green': 0.043, 'blue': 0.278}, 20: {'red': 1, 'green': 0.875, 'blue': 0.522}}
GREY = {'red': 0.62, 'green': 0.62, 'blue': 0.62}
YB, YT, VT = 3799840, 1841500, 50
Y = lambda v: YB - v / VT * (YB - YT)
keep = {f'SLIDES_API1265877891_{i}': f'{P}{i}' for i in (5, 6, 7, 11, 12, 13)}
dl = [f'dlw_n{i}' for i in range(1, 54)] + ['dlw_shade', 'dlw_norm', 'dlw_xcap', 'dlw_shlab'] + [f'dlw_x{i}' for i in range(5)] + [f'dlw_e{a}' for a in D]
mp = {'dlw_slide': NEW, **keep, **{o: P + o[4:] for o in dl}}
R = [{'duplicateObject': {'objectId': 'dlw_slide', 'objectIds': mp}}]
R += [{'deleteObject': {'objectId': mp[o]}} for o in dl]
def rect(o, x, y, w, h, col, a=1.0):
    R.append({'createShape': {'objectId': P + o, 'shapeType': 'RECTANGLE', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': int(w), 'unit': 'EMU'}, 'height': {'magnitude': max(int(h), 1), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}}})
    R.append({'updateShapeProperties': {'objectId': P + o, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': col}, 'alpha': a}},
        'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill,outline'}})
def text(o, x, y, w, t, col, size=9, bold=False):
    R.append({'createShape': {'objectId': P + o, 'shapeType': 'TEXT_BOX', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': int(w), 'unit': 'EMU'}, 'height': {'magnitude': 230000, 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': int(x), 'translateY': int(y), 'unit': 'EMU'}}}})
    R.append({'insertText': {'objectId': P + o, 'text': t}})
    R.append({'updateTextStyle': {'objectId': P + o, 'style': {'fontFamily': 'Oswald', 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'bold': bold,
        'foregroundColor': {'opaqueColor': {'rgbColor': col}}}, 'fields': 'fontFamily,fontSize,bold,foregroundColor'}})
    R.append({'updateParagraphStyle': {'objectId': P + o, 'style': {'alignment': 'CENTER'}, 'fields': 'alignment'}})
BW = 380000
for k, a in enumerate((17, 19, 18, 20)):
    pp, pr, lift = D[a]; cx = 1700000 + k * 1600000; c = COL[a]
    rect(f'p{a}', cx - BW - 20000, Y(pp), BW, YB - Y(pp), c, 0.4)
    rect(f'r{a}', cx + 20000, Y(pr), BW, YB - Y(pr), c, 1.0)
    text(f'pl{a}', cx - BW - 120000, Y(pp) - 240000, BW + 200000, f'{pp}%', c, 10, True)
    text(f'rl{a}', cx - 80000, Y(pr) - 240000, BW + 200000, f'{pr}%', c, 10, True)
    text(f'a{a}', cx - 700000, YB + 30000, 1400000, f'Album {a} · end lift {lift}', c, 9, True)
text('leg', 5200000, 1560000, 2600000, 'light = % of payers · solid = % of album revenue', GREY, 8)
def rep(a, b): R.append({'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [NEW]}})
rep('Revenue per Active Payer vs a Normal Weekday, Last 14 Days: Domino 17–20', 'Payers Missing 1–3 Stickers 4 Days Before Close: Domino 17–20')
rep('Standard-population payers · each day ÷ the same weekday’s average up to 8 days before close · close day left out',
    'Standard-population payers · missing 1–3 set stickers at the end of close−4, not finished · % of payers and % of album revenue')
rep('Lift in the last 4 days', ' ')
rep('+50%', '50%'); rep('+20%', '25%'); rep('−10%', '0%')
rep('Albums 18 and 20 lift at the end; 17 and 19 barely move', 'The albums that lifted at the end (18, 20) had about twice as many payers near FU')
R.append({'updateSlidesPosition': {'slideObjectIds': [NEW], 'insertionIndex': int(sys.argv[1])}})
print(json.dumps(R, separators=(',', ':'), ensure_ascii=False))
