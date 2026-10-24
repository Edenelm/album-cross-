"""ALBUM END: rebuild of slide 59 (s6a) as two slides (Eden 2026-10-24): finishers / non-finishers,
spend per day as % of own album pace: last 7 days before close and 7 days after close. $2-20 a day payers, latest albums.
Data: claude/topic6-before-after-2026-10-24.md (SQL claude/topic6_before_after_2026-10-24.sql)."""
import json, sys, importlib.util as u
s = u.spec_from_file_location('h', 'slide_t7_dice_prize_2026-10-25.py'); h = u.module_from_spec(s); s.loader.exec_module(h)
GAMES = [('Dice 63', h.BLUE), ('Domino 20', {'red': 0.961, 'green': 0.627, 'blue': 0.29}), ('Disney 15', {'red': 0.235, 'green': 0.784, 'blue': 0.706})]
LIGHT = {'red': 0.55, 'green': 0.55, 'blue': 0.55}
FIN = {'Dice 63': (229, 110), 'Domino 20': (217, 140), 'Disney 15': (188, 128)}
NOT = {'Dice 63': [(135, 90), (51, 75), (29, 52)], 'Domino 20': [(120, 103), (65, 88), (24, 49)], 'Disney 15': [(150, 108), (82, 84), (44, 59)]}

def ref(S, y, x0, x1, lx, ly, lw, align):
    return h.rect(S, f'{S}_ref', x0, y, x1 - x0, 0.012, h.GOLD) + h.tbox(S, f'{S}_reft', lx, ly, lw, 0.24, 'album pace = 100%', 9, h.GOLD, False, align)

def finishers(idx):
    S, BASE, PER = 's6c_slide', 3.75, 0.0095
    msg = 'Finishers spend about 2× their pace in the last week, then start the next album above it. Dice is the lowest (110%).'
    R = h.page(S, 'Finishers: Spend per Day Before and After Close, $2–20 a Day Payers',
               'Latest album · % of each player\'s own album pace (before the last quarter) · last week = 7 days before close · week after = next album days 2–8',
               msg, msg_red='Dice is the lowest (110%).', idx=idx)
    for g, (name, col) in enumerate(GAMES):
        gx = 0.95 + g * 2.95
        last, after = FIN[name]
        for j, (v, c, cap) in enumerate(((last, LIGHT, 'last week'), (after, col, 'week after'))):
            x, hgt = gx + j * 0.95, v * PER
            R += h.rect(S, f'{S}_b{g}{j}', x, BASE - hgt, 0.8, hgt, c)
            R += h.tbox(S, f'{S}_v{g}{j}', x - 0.2, BASE - hgt - 0.36, 1.2, 0.32, f'{v}%', 15, h.RED if (g == 0 and j == 1) else h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{j}', x - 0.2, BASE + 0.04, 1.2, 0.22, cap, 9, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_g{g}', gx - 0.1, BASE + 0.28, 1.95, 0.3, name, 13, h.WHITE, True, 'CENTER')
    R += h.rect(S, f'{S}_base', 0.7, BASE, 8.0, 0.012, h.GREY) + ref(S, BASE - 100 * PER, 0.7, 8.7, 8.74, BASE - 100 * PER - 0.11, 1.2, 'START')
    return R

def nonfinishers(idx):
    S, BASE, PER = 's6d_slide', 3.75, 0.0135
    msg = 'Payers who end 4+ away had already dropped to a quarter to half of their pace in the last week; after close they stay low.'
    R = h.page(S, 'Payers Who Did Not Finish: Spend per Day Before and After Close, $2–20 a Day',
               'Latest album · % of each player\'s own album pace · grey = last week before close · colour = week after close (next album days 2–8)',
               msg, msg_red='after close they stay low.', idx=idx)
    caps = ['1–2', '3', '4+']
    for g, (name, col) in enumerate(GAMES):
        px = 0.85 + g * 2.95
        for k, (last, after) in enumerate(NOT[name]):
            gx = px + k * 0.9
            for j, (v, c) in enumerate(((last, LIGHT), (after, col))):
                x, hgt = gx + j * 0.37, v * PER
                R += h.rect(S, f'{S}_b{g}{k}{j}', x, BASE - hgt, 0.33, hgt, c)
                R += h.tbox(S, f'{S}_v{g}{k}{j}', x - 0.2, BASE - hgt - 0.27, 0.73, 0.25, f'{v}%', 9.5, h.RED if (k == 2 and j == 1) else h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', gx - 0.1, BASE + 0.03, 0.9, 0.22, caps[k], 10, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_g{g}', px - 0.1, BASE + 0.27, 2.75, 0.3, name + ' · stickers missing', 12, h.WHITE, True, 'CENTER')
    R += h.rect(S, f'{S}_base', 0.7, BASE, 8.6, 0.012, h.GREY) + ref(S, BASE - 100 * PER, 0.7, 9.3, 8.3, BASE - 100 * PER - 0.26, 1.0, 'END')
    return R

if __name__ == '__main__':
    f = {'fin': finishers, 'not': nonfinishers}[sys.argv[1]]
    print(json.dumps(f(int(sys.argv[2])), ensure_ascii=False, separators=(',', ':')))
