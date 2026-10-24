"""Part 1 deck slide 24 fix (Eden 2026-10-24): copy p24 -> p24fix right after it; latest albums (Dice 63, Domino 20, Disney 15),
% of standard-population payers, same scale in all panels, label title. Data: claude/closing_week_pct_payers_2026-10-24.sql.
Usage: python3 slide_p24_fix_2026-10-24.py > requests.json"""
import json
S = 'p24fix'
N = 63
DAYS = [-7, -6, -5, -4, -3, -2, -1]
DATA = {  # % of payers per day d-7..-1: bought, gameplay
    'dice':   ([1.83, 3.31, 2.59, 3.66, 5.12, 5.63, 5.83], [1.31, 0.03, 0.00, 0.00, 1.89, 3.97, 3.54]),
    'domino': ([1.14, 0.63, 0.56, 1.27, 1.12, 0.96, 0.77], [1.38, 1.32, 2.42, 5.85, 11.26, 6.86, 3.96]),
    'disney': ([0.14, 0.11, 0.12, 0.05, 1.00, 1.15, 2.00], [0.03, 0.02, 0.02, 0.66, 0.60, 2.12, 4.17]),
}
OFF = {'dice': 0, 'domino': 3657600, 'disney': 7315200}
COL = {'dice': {'red': 0.435, 'green': 0.639, 'blue': 1}, 'domino': {'red': 0.961, 'green': 0.627, 'blue': 0.29}, 'disney': {'red': 0.235, 'green': 0.784, 'blue': 0.706}}
GRID = {'red': 0.3, 'green': 0.3, 'blue': 0.3}
X0, STEP = 1397000, 397933          # centre of d-7 label, step per day (from the day labels)
Y0, YMAX, VMAX = 5187950, 2584450, 12.0
def X(g, i): return OFF[g] + X0 + i * STEP
def Y(v): return Y0 - (Y0 - YMAX) * v / VMAX

def txt(oid, t):
    return [{'deleteText': {'objectId': oid, 'textRange': {'type': 'ALL'}}}, {'insertText': {'objectId': oid, 'text': t}}]
def seg(oid, x1, y1, x2, y2, c, w, dash):
    h = abs(y2 - y1); width = max(x2 - x1, 1)
    up = y2 < y1
    tr = {'scaleX': 1, 'scaleY': -1 if up else 1, 'shearX': 0, 'shearY': 0, 'translateX': x1, 'translateY': y1, 'unit': 'EMU'}
    R = [{'createLine': {'objectId': oid, 'category': 'STRAIGHT', 'elementProperties': {'pageObjectId': S,
          'size': {'width': {'magnitude': width, 'unit': 'EMU'}, 'height': {'magnitude': max(h, 1), 'unit': 'EMU'}}, 'transform': tr}}}]
    R += [{'updateLineProperties': {'objectId': oid, 'lineProperties': {'lineFill': {'solidFill': {'color': {'rgbColor': c}}},
           'weight': {'magnitude': w, 'unit': 'PT'}, 'dashStyle': dash}, 'fields': 'lineFill,weight,dashStyle'}}]
    return R
def dot(oid, x, y, c):
    r = 45720
    return [{'createShape': {'objectId': oid, 'shapeType': 'ELLIPSE', 'elementProperties': {'pageObjectId': S,
             'size': {'width': {'magnitude': 2 * r, 'unit': 'EMU'}, 'height': {'magnitude': 2 * r, 'unit': 'EMU'}},
             'transform': {'scaleX': 1, 'scaleY': 1, 'translateX': x - r, 'translateY': int(y) - r, 'unit': 'EMU'}}}},
            {'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': c}}}, 'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill.solidFill.color,outline.propertyState'}}]

def build():
    m = {'p24': S}; m.update({f'p24_i{i}': f'{S}_i{i}' for i in range(2, N + 1)})
    R = [{'duplicateObject': {'objectId': 'p24', 'objectIds': m}}]
    R += [{'deleteObject': {'objectId': f'{S}_i{i}'}} for i in (8, 28, 45)]          # old chart pictures (in the copy only)
    R += txt(f'{S}_i3', 'Payers Using the Wild / Joker per Day, Last 7 Days Before Close')
    R += txt(f'{S}_i4', '% of paying players per day · bought (solid) vs gameplay (dashed) · (last-day %) · same scale in all games')
    R += txt(f'{S}_i27', 'album 20') + txt(f'{S}_i44', 'album 15')
    for a, b in ((10, 11), (30, 31), (47, 48)):
        R += txt(f'{S}_i{a}', '6%') + txt(f'{S}_i{b}', '12%')
    R += txt(f'{S}_i20', '━ Wilds bought (6%)') + txt(f'{S}_i21', '- - Wilds from gameplay (4%)')
    R += txt(f'{S}_i40', '━ Jokers bought (1%)') + txt(f'{S}_i41', '- - Jokers from gameplay (4%)')
    R += txt(f'{S}_i57', '━ Jokers bought (2%)') + txt(f'{S}_i58', '- - Jokers from gameplay (4%)')
    R += txt(f'{S}_i59', 'Finding: Dice sells Wilds every day (2–6% of payers a day); Domino 20 gives Jokers free (11% three days out); Disney sells mostly in the last 3 days.')
    R += txt(f'{S}_i60', 'Why it matters: On days 6–4 a Dice payer can only buy a Wild. In Disney under 1% of payers a day get a Joker before 3 days out, so near payers wait.')
    for g in OFF:
        for k, v in enumerate((0, 6, 12)):
            R += seg(f'{S}_{g}_g{k}', OFF[g] + X0 - 120000, int(Y(v)), OFF[g] + X0 + 6 * STEP + 120000, int(Y(v)), GRID, 0.5, 'SOLID')
        for s, (vals, w, dash) in enumerate(((DATA[g][0], 2.5, 'SOLID'), (DATA[g][1], 1.75, 'DASH'))):
            for i in range(6):
                R += seg(f'{S}_{g}_{s}_{i}', X(g, i), int(Y(vals[i])), X(g, i + 1), int(Y(vals[i + 1])), COL[g], w, dash)
            R += dot(f'{S}_{g}_{s}_dot', X(g, 6), Y(vals[6]), COL[g])
    # Dice annotations, moved to the new scale
    R += [{'updatePageElementTransform': {'objectId': f'{S}_i22', 'applyMode': 'ABSOLUTE', 'transform': {'scaleX': 0.3556, 'scaleY': 0.0618, 'shearX': 0, 'shearY': 0, 'translateX': 927100, 'translateY': 4300000, 'unit': 'EMU'}}},
          {'updatePageElementTransform': {'objectId': f'{S}_i24', 'applyMode': 'ABSOLUTE', 'transform': {'scaleX': 0.3768, 'scaleY': 0.0618, 'shearX': 0, 'shearY': 0, 'translateX': 2844800, 'translateY': 3400000, 'unit': 'EMU'}}}]
    return R

if __name__ == '__main__':
    print(json.dumps(build(), ensure_ascii=False))
