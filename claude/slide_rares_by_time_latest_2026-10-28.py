# Redraw deck chart "% of the album's Rares Collected, by % of Album Time" natively on the latest album (Dice 63, Domino 20, Disney 15).
# Data: claude/rares-by-time-latest-album-2026-10-28.md. Usage: python3 this.py <pageId> <prefix> <x0> <x100> <y0> <y80> [dim]  -> batchUpdate JSON
import json, sys
page, pre, x0, x100, y0, y80 = sys.argv[1], sys.argv[2], *map(float, sys.argv[3:7])
dim = len(sys.argv) > 7
S = {'dice': ([0,12.3,18.2,24.5,31.1,36.3,43.8,52.8,61.2,69.5,80.0], {'red':0.4235,'green':0.6196,'blue':1}),
     'domino': ([0,3.7,7.7,12.2,14.5,27.3,34.6,43.6,52.5,58.1,66.9], {'red':0.9608,'green':0.6275,'blue':0.2902}),
     'disney': ([0,5.0,8.6,14.0,17.0,24.9,37.0,41.4,49.7,56.7,61.0], {'red':0.2353,'green':0.7843,'blue':0.7059})}
GRID = {'red':0.27,'green':0.27,'blue':0.27}
X = lambda k: x0 + (x100 - x0) * k / 10
Y = lambda v: y0 - (y0 - y80) * v / 80
R = []
def line(oid, xa, ya, xb, yb, col, w):
    R.append({'createLine': {'objectId': oid, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': page,
        'size': {'width': {'magnitude': 3000000, 'unit': 'EMU'}, 'height': {'magnitude': 3000000, 'unit': 'EMU'}},
        'transform': {'scaleX': max(xb - xa, 1) / 3e6, 'scaleY': (yb - ya) / 3e6 if yb != ya else 0.00001, 'translateX': xa, 'translateY': ya, 'unit': 'EMU'}}}})
    R.append({'updateLineProperties': {'objectId': oid, 'lineProperties': {'lineFill': {'solidFill': {'color': {'rgbColor': col}}}, 'weight': {'magnitude': w, 'unit': 'EMU'}}, 'fields': 'lineFill,weight'}})
def rect(oid, x, y, w, h, col, alpha=1):
    R.append({'createShape': {'objectId': oid, 'shapeType': 'RECTANGLE', 'elementProperties': {'pageObjectId': page,
        'size': {'width': {'magnitude': w, 'unit': 'EMU'}, 'height': {'magnitude': h, 'unit': 'EMU'}}, 'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': x, 'translateY': y, 'unit': 'EMU'}}}})
    R.append({'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': col}, 'alpha': alpha}}, 'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill,outline'}})
# band: last 30% (normal) or last 10% (dim mode)
b0 = X(9) if dim else X(7)
rect(pre + 'band', b0, Y(85), X(10) - b0, Y(0) - Y(85), {'red':0.33,'green':0.31,'blue':0.22}, 0.35)
for i, v in enumerate([0, 20, 40, 60, 80]):
    line(f'{pre}g{i}', X(0), Y(v), X(10), Y(v), GRID, 4775)
for g, (vals, col) in S.items():
    for k in range(10):
        c = col if (not dim or k == 9) else {kk: vv * 0.45 + 0.13 for kk, vv in col.items()}
        line(f'{pre}{g}{k}', X(k), Y(vals[k]), X(k + 1), Y(vals[k + 1]), c, 28575 if (not dim or k == 9) else 15875)
    d = 70000
    R.append({'createShape': {'objectId': f'{pre}{g}dot', 'shapeType': 'ELLIPSE', 'elementProperties': {'pageObjectId': page,
        'size': {'width': {'magnitude': d, 'unit': 'EMU'}, 'height': {'magnitude': d, 'unit': 'EMU'}}, 'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': X(10) - d/2, 'translateY': Y(vals[10]) - d/2, 'unit': 'EMU'}}}})
    R.append({'updateShapeProperties': {'objectId': f'{pre}{g}dot', 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': col}}}, 'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill,outline'}})
print(json.dumps(R, separators=(',', ':')))
