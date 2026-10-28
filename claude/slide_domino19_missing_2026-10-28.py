# 2026-10-28: Domino "stickers still missing" slide, album 19 vs 20, median std-population payer, days 20-close.
# Data: domino_19v20_daily_pauses_2026-10-26.sql (m_held series). Built as a copy of a19c_slide, placed right after it.
import json, sys
SRC, NEW, P = 'a19c_slide', 'm19_slide', 'm19_'
H19 = [6,20,28,33,39,43,49,54,58,62,65,69,73,77,80,82,84,88,90,91,94,98,102,104,107,110,112,115,117,119,121,122,124,125,126,127,128,128,129,130,131,132,134,135,135,136,136,137,137,138]
H20 = [8,20,30,36,40,42,45,49,54,57,60,62,65,69,73,76,79,82,85,87,88,91,95,100,104,107,110,113,115,117,119,122,124,125,127,129,132,134,134,135,135,136,136,136,137,138,139,140,140,140]
D0, D1, YMAX = 20, 50, 60
X0, XW, Y0, YT = 3656330, 2000000, 3799840, 1841500
ids = ['SLIDES_API976784972_144','a144_2007','a144_2008','SLIDES_API976784972_151','a144_2022','SLIDES_API976784972_152','SLIDES_API976784972_153','SLIDES_API976784972_154','SLIDES_API976784972_155','a144_2029','SLIDES_API976784972_161','a144_dom_grid0','a144_dom_grid1','a144_dom_grid2','a144_dom_T'] + [f'n{i}' for i in range(1,26)]
m = {SRC: NEW}; m.update({f'a19c_{i}': P + i for i in ids})
R = [{'duplicateObject': {'objectId': SRC, 'objectIds': m}}, {'updateSlidesPosition': {'slideObjectIds': [NEW], 'insertionIndex': 31}}]
R += [{'deleteObject': {'objectId': P + i}} for i in ids if i.startswith('n') or i == 'a144_dom_T']
px = lambda d: X0 + (d - D0) / (D1 - D0) * XW
py = lambda miss: Y0 - miss / YMAX * (Y0 - YT)
k = [0]
def line(x1, y1, x2, y2, col, w):
    k[0] += 1; o = f'{P}L{k[0]}'; up = y2 < y1
    R.append({'createLine': {'objectId': o, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': max(int(x2 - x1), 1), 'unit': 'EMU'}, 'height': {'magnitude': max(int(abs(y2 - y1)), 1), 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': -1 if up else 1, 'translateX': int(x1), 'translateY': int(y1), 'unit': 'EMU'}}}})
    R.append({'updateLineProperties': {'objectId': o, 'lineProperties': {'lineFill': {'solidFill': {'color': {'rgbColor': col}}}, 'weight': {'magnitude': w, 'unit': 'PT'}}, 'fields': 'lineFill,weight'}})
def text(o, x, y, w, t, col, size=9, bold=False):
    R.append({'createShape': {'objectId': P + o, 'shapeType': 'TEXT_BOX', 'elementProperties': {'pageObjectId': NEW,
        'size': {'width': {'magnitude': w, 'unit': 'EMU'}, 'height': {'magnitude': 200000, 'unit': 'EMU'}},
        'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': x, 'translateY': y, 'unit': 'EMU'}}}})
    R.append({'insertText': {'objectId': P + o, 'text': t}})
    R.append({'updateTextStyle': {'objectId': P + o, 'style': {'fontFamily': 'Oswald', 'fontSize': {'magnitude': size, 'unit': 'PT'}, 'bold': bold,
        'foregroundColor': {'opaqueColor': {'rgbColor': col}}}, 'fields': 'fontFamily,fontSize,bold,foregroundColor'}})
GREY = {'red': 0.62, 'green': 0.62, 'blue': 0.62}; DOM = {'red': 0.957, 'green': 0.62, 'blue': 0.302}
for H, col, w in ((H20, GREY, 1.75), (H19, DOM, 2.5)):
    for d in range(D0, D1, 2):
        line(px(d), py(144 - H[d - 1]), px(d + 2), py(144 - H[d + 1]), col, w)
text('l19', px(D1) + 30000, int(py(6)) - 140000, 700000, 'Album 19: 6 missing', DOM, 9, True)
text('l20', px(D1) + 30000, int(py(4)) - 10000, 700000, 'Album 20: 4 missing', GREY, 9)
text('dx', X0 - 60000, Y0 + 20000, 500000, 'Day 20', GREY, 8)
def rep(a, b): R.append({'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [NEW]}})
rep('Stickers Collected by Players Throughout the Album ', 'Stickers Still Missing, Album 19 vs Album 20 (Day 20 to Close)')
rep('Album 19 · 144 stickers', 'Stickers missing of 144')
rep('100%', '60'); rep('50%', '30'); rep('0%', '0')
rep('Longest wait: 4%', 'Even until day 33. Then album 19 slowed:'); rep(' of the album', ' at day 38 it missed 16, album 20 missed 10')
json.dump(R, open(sys.argv[1], 'w'))
print(len(R))
