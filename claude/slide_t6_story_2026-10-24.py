"""ALBUM END, finishers section rebuilt as an investigation (Eden 2026-10-24): sample slides 1, 2, 7. Measure A (3-album average).
Rules: title = what is plotted; one message per slide in the bottom line; context for analysts of other games in the subtitle.
s1 = total game revenue in the week after each close date (calendar). s2 = finishers' week after vs own pace, 3 albums per game.
s7 = payout change after close by spend level, paying finishers, album prizes included.
Data: topic6-game-revenue-after-close-2026-10-24.md (calendar section), topic6-calendar-neutral-return-2026-10-24.md (A),
topic6-payout-prizes-by-level-2026-10-24.md. Usage (from claude/): python3 slide_t6_story_2026-10-24.py <s1|s2|s2_size|s3|s4|s4f|s4s|s5|s6|s6s|s7|s8f|s8s|s9|s10|r1|r2|r3|r4|t7d|t7e|t7f|s9v|t7g|t7h|r5|dj1|v1|v2|notes> [insertionIndex]"""
import json, sys, importlib.util as u
s = u.spec_from_file_location('h', 'slide_t7_dice_prize_2026-10-25.py'); h = u.module_from_spec(s); s.loader.exec_module(h)
GAMES = [('Dice', h.BLUE), ('Domino', {'red': 0.961, 'green': 0.627, 'blue': 0.29}), ('Disney', {'red': 0.235, 'green': 0.784, 'blue': 0.706})]
LIGHT = {'red': 0.55, 'green': 0.55, 'blue': 0.55}

# s1: rows = games, cols = dates; value = total game revenue days 1-7 after the date / avg day of the 30 days before; True = own album close
DATES = ['Jul 27', 'Aug 24', 'Sep 7 (US Labor Day)', 'Oct 5', 'Oct 12']
CAL = {'Dice': [(112, True), (101, False), (92, True), (109, False), (103, False)],
       'Domino': [(94, False), (95, True), (90, False), (112, False), (110, True)],
       'Disney': [(93, False), (96, True), (85, False), (103, True), (99, False)]}

def s1(idx=None):
    S = 'a6s1_slide'
    msg = 'Early September was weak in every game, with or without an album close; October was strong. One album can mislead, so the next slides average 3 albums per game.'
    R = h.page(S, 'Total Game Revenue in the Week After Each Close Date vs the 30 Days Before',
               'All players\' purchase revenue a day in the 7 days after the date ÷ the 30 days before (100% = no change) · same measure in all three games',
               msg, msg_red='One album can mislead', idx=idx, msg_y=4.6)
    X0, CW, Y0, RH = 1.75, 1.55, 1.55, 0.72
    for c, d in enumerate(DATES):
        R += h.tbox(S, f'{S}_d{c}', X0 + c * CW, 1.2, CW - 0.1, 0.3, d, 10, h.WHITE, True, 'CENTER')
    for g, (name, col) in enumerate(GAMES):
        y = Y0 + g * RH
        R += h.tbox(S, f'{S}_g{g}', 0.6, y + 0.17, 1.1, 0.35, name, 14, h.WHITE, True)
        for c, (v, own) in enumerate(CAL[name]):
            x = X0 + c * CW
            R += h.rect(S, f'{S}_c{g}{c}', x, y, CW - 0.1, RH - 0.1, col if own else h.CARD)
            R += h.tbox(S, f'{S}_v{g}{c}', x, y + 0.12, CW - 0.1, 0.4, f'{v}%', 16, h.RED if v < 95 and not own else h.WHITE, True, 'CENTER')
    R += h.rect(S, f'{S}_k0', X0, 3.85, 0.22, 0.16, h.BLUE)
    R += h.tbox(S, f'{S}_k1', X0 + 0.3, 3.78, 6.5, 0.3, 'Colored cell = that game closed an album on that date · dark cell = no album close in that game', 9, h.GREY)
    return R

# s2: paying finishers $2-20 a day, week after vs own pace, per album (album, close date) and 3-album average
FIN = {'Dice': ([('59', 'Jun 22', 123), ('61', 'Jul 27', 129), ('63', 'Sep 7', 110)], 121),
       'Domino': ([('17', 'May 11', 117), ('19', 'Aug 24', 134), ('20', 'Oct 12', 140)], 131),
       'Disney': ([('12', 'Jun 22', 131), ('14', 'Aug 24', 135), ('15', 'Oct 5', 128)], 132)}

def s2(idx=None):
    S, BASE, PER = 'a6s2_slide', 3.72, 0.0105
    msg = 'Finishers spend above their usual pace after close in every game. On a 3-album average Dice is the lowest (121% vs 131% / 132%), but the order changes from album to album, so the gap is modest.'
    R = h.page(S, 'Finishers\' Spend in the Week After Close vs Their Usual Pace, 3 Albums per Game',
               'Paying finishers (all 144 stickers on the day before close), $2–20 a day · usual pace = own album spend per day before the last quarter = 100% · bars = albums, big number = 3-album average',
               msg, msg_red='On a 3-album average Dice is the lowest (121% vs 131% / 132%)', idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        albums, avg = FIN[name]
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.24, 2.85, 0.32, name, 14, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_m{g}', px, 1.52, 2.85, 0.42, f'avg {avg}%', 18, h.RED if g == 0 else h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.15, BASE - 100 * PER, 2.55, 0.012, h.GREY)
        for k, (alb, d, v) in enumerate(albums):
            x, hgt = px + 0.42 + k * 0.72, v * PER
            R += h.rect(S, f'{S}_b{g}{k}', x, BASE - hgt, 0.55, hgt, col)
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.15, BASE - hgt - 0.26, 0.85, 0.24, f'{v}%', 10.5, h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', x - 0.15, BASE + 0.03, 0.85, 0.36, f'album {alb}\n{d}', 7.5, h.GREY, False, 'CENTER')
    R += h.tbox(S, f'{S}_k', 2.98, BASE - 100 * PER - 0.1, 0.42, 0.18, '100%', 7, h.GREY)
    return R

# s7: payout change days 1-3 after close vs mid-album, album prizes included, whole group, paying finishers, latest album
PAY = {'Dice': ([-14, -10, -5, -2], -8), 'Domino': ([-18, -19, -16, -12], -16), 'Disney': ([-22, -20, -14, -8], -14)}
LEVELS = ['≤$2', '$2–5', '$5–20', '>$20']
ALB = {'Dice': 'Dice 63', 'Domino': 'Domino 20', 'Disney': 'Disney 15'}

def s7(idx=None):
    S, ZERO, PER = 'a6s7_slide', 1.95, 0.045
    msg = 'Every game gives finishers less back after close; Dice cuts the least at every spend level. Hypothesis (not tested): a smaller cut makes each purchase last longer, so Dice finishers rebuy less; only a test can tell.'
    R = h.page(S, 'Payout Change After Close by Spend Level, Paying Finishers',
               'Payout = coins / rolls won from the game (album prizes included) ÷ coins / rolls spent on play · days 1–3 of the next album vs mid-album · whole group · latest album',
               msg, msg_red='Dice cuts the least at every spend level', idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        vals, allv = PAY[name]
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.25, 2.85, 0.32, ALB[name], 14, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.12, ZERO, 2.61, 0.012, h.GREY)
        for k, chg in enumerate(vals):
            x, hgt = px + 0.2 + k * 0.66, abs(chg) * PER
            R += h.rect(S, f'{S}_b{g}{k}', x, ZERO, 0.46, hgt, col)
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.15, ZERO + hgt + 0.02, 0.76, 0.25, f'{chg:+d}%', 10.5, h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', x - 0.15, 3.42, 0.76, 0.22, LEVELS[k], 8.5, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_a{g}', px, 3.72, 2.85, 0.3, f'all finishers: {allv:+d}%', 12, h.RED if g == 0 else h.WHITE, True, 'CENTER')
    return R

# size lines (3 albums, $2-20 a day): players and share of album revenue (all standard-population payers) per album, as ranges
SIZE = {'fin': {'Dice': '6,964–9,579 players · 10–13% of album revenue', 'Domino': '2,498–4,106 players · 9–14% of album revenue',
                'Disney': '7,498–10,680 players · 7–8% of album revenue'},
        's12': {'Dice': '10,165–11,747 players · 12–13% of album revenue', 'Domino': '3,712–5,749 players · 10–14% of album revenue',
                'Disney': '10,190–16,546 players · 9–12% of album revenue'}}

def size_boxes(S, key):
    return sum((h.tbox(S, f'{S}_n{g}', 0.55 + g * 3.05, 1.93, 2.85, 0.22, SIZE[key][name], 7.5, h.GREY, False, 'CENTER')
                for g, (name, _) in enumerate(GAMES)), [])

def s2_size(idx=None):   # add the size line to the existing a6s2
    return size_boxes('a6s2_slide', 'fin')

# s3: album prize in days of the finisher's own play, median, by spend level, latest album (topic6-prize-vs-spend-2026-10-24.md)
PRZ = {'Dice': ([2.82, 2.23, 1.62, 0.88], '>$20: 1,457 players · 12% of album revenue'),
       'Domino': ([1.74, 1.40, 1.10, 0.70], '>$20: 908 players · 15% of album revenue'),
       'Disney': ([1.67, 1.35, 0.94, 0.39], '>$20: 1,889 players · 10% of album revenue')}

def s3(idx=None):
    S, BASE, PER = 'a6s3_slide', 3.45, 0.6
    msg = 'In every game, the more a finisher spends, the smaller the album prize is next to their own play. Over $20 a day it is less than one day of play (Dice 0.9, Domino 0.7, Disney 0.4); these players bring 10–15% of album revenue.'
    R = h.page(S, 'Album Prize in Days of the Finisher\'s Own Play, by Spend Level',
               'Paying finishers, latest album · album prize ÷ own average daily play in the album (Dice rolls, Domino / Disney coins) · median player · line = 1 day',
               msg, msg_red='Over $20 a day it is less than one day of play', idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        vals, big = PRZ[name]
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.25, 2.85, 0.32, ALB[name], 14, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.12, BASE - PER, 2.61, 0.012, h.GREY)
        for k, v in enumerate(vals):
            x, hgt = px + 0.2 + k * 0.66, v * PER
            R += h.rect(S, f'{S}_b{g}{k}', x, BASE - hgt, 0.46, hgt, col)
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.15, BASE - hgt - 0.26, 0.76, 0.24, f'{v:.1f}', 10.5, h.RED if v < 1 else h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', x - 0.15, BASE + 0.03, 0.76, 0.22, LEVELS[k], 8.5, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_a{g}', px, 3.85, 2.85, 0.3, big, 8.5, h.WHITE, False, 'CENTER')
    R += h.tbox(S, f'{S}_k', 2.98, BASE - PER - 0.1, 0.42, 0.18, '1 day', 7, h.GREY)
    return R

# s5: players 1-2 short, $2-20 a day, week after vs own pace, 3 albums per game (topic6-calendar-neutral-return-2026-10-24.md)
SHORT = {'Dice': ([('59', 'Jun 22', 98), ('61', 'Jul 27', 105), ('63', 'Sep 7', 90)], 98),
         'Domino': ([('17', 'May 11', 92), ('19', 'Aug 24', 110), ('20', 'Oct 12', 103)], 102),
         'Disney': ([('12', 'Jun 22', 113), ('14', 'Aug 24', 111), ('15', 'Oct 5', 108)], 111)}

def s5(idx=None):
    S, BASE, PER = 'a6s5_slide', 3.72, 0.0105
    msg = 'Players who end 1–2 stickers short go back to about their usual pace after close (98–111%), below finishers (121–132%) in every game. Dice is again the lowest on average, but the order changes from album to album.'
    R = h.page(S, '1–2 Short: Week-After Spend vs Usual Pace, 3 Albums per Game',
               'Paying players 1–2 stickers short on the day before close, $2–20 a day · usual pace = own album spend a day before the last quarter = 100% · bars = albums · big number = average',
               msg, msg_red='below finishers (121–132%) in every game', idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        albums, avg = SHORT[name]
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.24, 2.85, 0.32, name, 14, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_m{g}', px, 1.52, 2.85, 0.42, f'avg {avg}%', 18, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.15, BASE - 100 * PER, 2.55, 0.012, h.GREY)
        for k, (alb, d, v) in enumerate(albums):
            x, hgt = px + 0.42 + k * 0.72, v * PER
            R += h.rect(S, f'{S}_b{g}{k}', x, BASE - hgt, 0.55, hgt, col)
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.15, BASE - hgt - 0.26, 0.85, 0.24, f'{v}%', 10.5, h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', x - 0.15, BASE + 0.03, 0.85, 0.36, f'album {alb}\n{d}', 7.5, h.GREY, False, 'CENTER')
    R += h.tbox(S, f'{S}_k', 2.98, BASE - 100 * PER - 0.1, 0.42, 0.18, '100%', 7, h.GREY)
    return R + size_boxes(S, 's12')

# s4: week after vs own pace by spend level, finishers (solid) and players 1-2 short (light), 3-album average (topic6-calendar-neutral-return-2026-10-24.md)
LVL = {'Dice': ([229, 138, 114, 92], [161, 109, 93, 73], '>$20: 2,034–2,642 players · 18–20% of album revenue'),
       'Domino': ([296, 161, 124, 96], [189, 125, 94, 69], '>$20: 1,253–1,776 players · 19–21% of album revenue'),
       'Disney': ([333, 176, 122, 92], [234, 141, 102, 76], '>$20: 3,553–4,726 players · 16–18% of album revenue')}

def light(c): return {k: 0.55 * v + 0.45 * 0.35 for k, v in c.items()}

def s4(idx=None):
    S, BASE, PER = 'a6s4_slide', 3.5, 0.0058
    msg = 'The more a payer spends, the weaker the return after close. Over $20 a day, players spend less in the week after than they usually do: finishers 92–96%, players 1–2 short 69–76%. They bring 16–21% of album revenue.'
    R = h.page(S, 'Week-After Spend vs Usual Pace by Spend Level, 3-Album Average',
               'Paying players · bar = spend a day in the week after close, as % of the player\'s usual daily spend in the album (line = 100% = same) · solid = finishers, light = 1–2 stickers short',
               msg, msg_red='Over $20 a day, players spend less in the week after than they usually do', idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        fin, short, size = LVL[name]
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.24, 2.85, 0.32, name, 14, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.1, BASE - 100 * PER, 2.65, 0.012, h.GREY)
        for k in range(4):
            gx = px + 0.16 + k * 0.66
            for j, (v, c) in enumerate([(fin[k], col), (short[k], light(col))]):
                x, hgt = gx + j * 0.28, v * PER
                R += h.rect(S, f'{S}_b{g}{k}{j}', x, BASE - hgt, 0.26, hgt, c)
                R += h.tbox(S, f'{S}_v{g}{k}{j}', x - 0.1, BASE - hgt - 0.2, 0.46, 0.2, f'{v}%', 7.5, h.RED if (k == 3) else h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', gx - 0.05, BASE + 0.03, 0.64, 0.22, LEVELS[k], 8.5, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_a{g}', px, 3.85, 2.85, 0.3, size, 8, h.WHITE, False, 'CENTER')
    return R

# s6: album prize in days of own play by spend level, finishers (prize received, solid) and 1-2 short (prize missed, light), latest album
# 1-2 short: Dice = own album_reward_value; Domino / Disney = median prize of finishers in the same album_segment (estimate). topic6_prize_short12_2026-10-24.sql
PRZ2 = {'Dice': ([2.87, 2.27, 1.62, 0.86], [3.17, 2.68, 1.99, 1.10], '>$20: finishers 12% + 1–2 short 8% of album revenue'),
        'Domino': ([1.75, 1.40, 1.10, 0.70], [2.30, 1.89, 1.62, 0.95], '>$20: finishers 15% + 1–2 short 5% of album revenue'),
        'Disney': ([1.68, 1.34, 0.94, 0.39], [1.78, 1.38, 0.96, 0.44], '>$20: finishers 10% + 1–2 short 7% of album revenue')}

def s6(idx=None):
    S, BASE, PER = 'a6s6_slide', 3.5, 0.5
    msg = 'Over $20 a day the album prize is about one day of play or less, for finishers and for players 1–2 short alike (0.4–1.1 days). Players under $5 a day get 1.3–3.2 days.'
    R = h.page(S, 'Album Prize in Days of Own Play, Finishers and 1–2 Short',
               'Latest album · solid = finishers (prize received), light = 1–2 short (prize missed) · album prize ÷ own average daily play in the album · median · line = 1 day',
               msg, msg_red='Over $20 a day the album prize is about one day of play or less', idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        fin, short, size = PRZ2[name]
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.24, 2.85, 0.32, ALB[name], 14, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.1, BASE - PER, 2.65, 0.012, h.GREY)
        for k in range(4):
            gx = px + 0.16 + k * 0.66
            for j, (v, c) in enumerate([(fin[k], col), (short[k], light(col))]):
                x, hgt = gx + j * 0.28, v * PER
                R += h.rect(S, f'{S}_b{g}{k}{j}', x, BASE - hgt, 0.26, hgt, c)
                R += h.tbox(S, f'{S}_v{g}{k}{j}', x - 0.1, BASE - hgt - 0.2, 0.46, 0.2, f'{v:.1f}', 7.5, h.RED if k == 3 else h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', gx - 0.05, BASE + 0.03, 0.64, 0.22, LEVELS[k], 8.5, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_a{g}', px, 3.85, 2.85, 0.3, size, 8, h.WHITE, False, 'CENTER')
    return R

# Eden 2026-10-24: one population per slide. Single-bar-per-level slides split out of a6s4 / a6s6.
def lvl_slide(S, title, sub, msg, red, data, per, fmt, ref, idx=None):
    BASE = 3.45
    R = h.page(S, title, sub, msg, msg_red=red, idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        vals, size = data[name]
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.25, 2.85, 0.32, name, 14, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.12, BASE - ref * per, 2.61, 0.012, h.GREY)
        for k, v in enumerate(vals):
            x, hgt = px + 0.2 + k * 0.66, v * per
            R += h.rect(S, f'{S}_b{g}{k}', x, BASE - hgt, 0.46, hgt, col)
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.15, BASE - hgt - 0.26, 0.76, 0.24, fmt(v), 10.5, h.RED if k == 3 else h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', x - 0.15, BASE + 0.03, 0.76, 0.22, LEVELS[k], 8.5, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_a{g}', px, 3.85, 2.85, 0.3, size, 8, h.WHITE, False, 'CENTER')
    return R

PCT = lambda v: f'{v}%'
DAYS = lambda v: f'{v:.1f}'
RET_FIN = {'Dice': ([229, 138, 114, 92], '>$20: 1,098–1,457 players · 11–12% of album revenue'),
           'Domino': ([296, 161, 124, 96], '>$20: 772–1,271 players · 13–16% of album revenue'),
           'Disney': ([333, 176, 122, 92], '>$20: 1,889–2,118 players · 9–10% of album revenue')}
RET_S12 = {'Dice': ([161, 109, 93, 73], '>$20: 936–1,185 players · 7–8% of album revenue'),
           'Domino': ([189, 125, 94, 69], '>$20: 356–505 players · 5–6% of album revenue'),
           'Disney': ([234, 141, 102, 76], '>$20: 1,664–2,608 players · 7–9% of album revenue')}
PRZ_S12 = {'Dice': ([3.17, 2.68, 1.99, 1.10], '>$20: 1,185 players · 8% of album revenue'),
           'Domino': ([2.30, 1.89, 1.62, 0.95], '>$20: 356 players · 5% of album revenue'),
           'Disney': ([1.78, 1.38, 0.96, 0.44], '>$20: 1,664 players · 7% of album revenue')}
RET_SUB = 'bar = spend a day in the week after close, as % of the player\'s usual daily spend in the album (line = 100% = same) · average of 3 albums per game'

def s4f(idx=None):
    return lvl_slide('a6s4f_slide', 'Finishers: Week-After Spend vs Usual Pace, by Spend Level',
        'Paying finishers (144 stickers on the day before close) · ' + RET_SUB,
        'The more a finisher spends, the weaker the return after close. Over $20 a day, finishers spend less in the week after than they usually do (92–96%) in every game; they bring 9–16% of album revenue.',
        'Over $20 a day, finishers spend less in the week after than they usually do', RET_FIN, 0.0058, PCT, 100, idx)

def s4s(idx=None):
    return lvl_slide('a6s4s_slide', '1–2 Short: Week-After Spend vs Usual Pace, by Spend Level',
        'Paying players 1–2 short on the day before close · bar = week-after spend a day as % of usual daily spend in the album (line = 100%) · 3-album average',
        'Over $20 a day, players 1–2 short drop to 69–76% of their usual spend in the week after, the weakest return in every game. They bring 5–9% of album revenue.',
        'Over $20 a day, players 1–2 short drop to 69–76% of their usual spend', RET_S12, 0.0058, PCT, 100, idx)

def s6s(idx=None):
    return lvl_slide('a6s6s_slide', '1–2 Short: Missed Album Prize in Days of Own Play, by Spend Level',
        'Paying players 1–2 stickers short, latest album · prize they missed ÷ own average daily play in the album · median player · line = 1 day',
        'The prize these players missed is worth 1.4–3.2 days of play under $5 a day, but about one day or less over $20 (0.4–1.1 days).',
        'about one day or less over $20', PRZ_S12, 0.5, DAYS, 1, idx)

# Normal-week check (topic6-normal-week-check-2026-10-24.md): >$20 payers, normal mid-album week (days 21-27) vs week after close,
# both as % of usual pace over album days 0-20; 3-album average. One population per slide.
NW = {'fin': {'Dice': (99, 88, -11, '−19%, +1%, −15%'), 'Domino': (95, 91, -3, '−14%, −2%, +6%'), 'Disney': (93, 87, -6, '−6%, +5%, −16%')},
      's12': {'Dice': (89, 68, -23, '−29%, −12%, −27%'), 'Domino': (83, 62, -24, '−32%, −30%, −10%'), 'Disney': (86, 71, -17, '−16%, −16%, −20%')}}

def nw_slide(S, key, title, sub, msg, red, idx=None):
    BASE, PER = 3.3, 0.016
    R = h.page(S, title, sub, msg, msg_red=red, idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        mid, aft, chg, per_album = NW[key][name]
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.25, 2.85, 0.32, name, 14, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.15, BASE - 100 * PER, 2.55, 0.012, h.GREY)
        for j, (v, c, lab) in enumerate([(mid, LIGHT, 'normal week\n(album days 21–27)'), (aft, col, 'week after\nclose')]):
            x, hgt = px + 0.5 + j * 1.05, v * PER
            R += h.rect(S, f'{S}_b{g}{j}', x, BASE - hgt, 0.8, hgt, c)
            R += h.tbox(S, f'{S}_v{g}{j}', x - 0.1, BASE - hgt - 0.27, 1.0, 0.25, f'{v}%', 12, h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{j}', x - 0.15, BASE + 0.03, 1.1, 0.36, lab, 7.5, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_d{g}', px, 3.74, 2.85, 0.28, f'week after vs normal week: {chg:+d}%', 10, h.RED if key == 's12' else h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_e{g}', px, 4.0, 2.85, 0.22, f'by album: {per_album}', 7.5, h.GREY, False, 'CENTER')
    return R

NW_SUB = 'Paying {who}, over $20 a day · % of usual pace = own album spend a day in album days 0–20 (line = 100%) · average of 3 albums per game'

def s8f(idx=None):
    return nw_slide('a6s8f_slide', 'fin', 'Finishers Over $20 a Day: Normal Week vs Week After Close',
        NW_SUB.format(who='finishers'),
        'Over $20 a day, finishers already spend below their usual pace in a normal mid-album week (93–99%). The extra drop after close is small and changes by album (−19% to +6%), so for finishers it is mostly a return to normal, not the album end.',
        'mostly a return to normal, not the album end', idx)

def s8s(idx=None):
    return nw_slide('a6s8s_slide', 's12', '1–2 Short Over $20 a Day: Normal Week vs Week After Close',
        NW_SUB.format(who='players 1–2 stickers short on the day before close'),
        'Over $20 a day, players 1–2 short spend 17–24% less in the week after close than in their own normal week, in every game and in all 9 albums. This drop comes with the album end, not in a normal week.',
        'spend 17–24% less in the week after close than in their own normal week', idx)

def card(S, oid, x, y, w, hh, head, head_col, body):
    R = h.rect(S, oid + 'r', x, y, w, hh, h.CARD)
    R += h.tbox(S, oid + 'h', x + 0.15, y + 0.08, w - 0.3, 0.3, head, 12, head_col, True)
    R += h.tbox(S, oid + 'b', x + 0.15, y + 0.4, w - 0.3, hh - 0.45, body, 9.5, h.WHITE)
    return R

def s9(idx=None):
    S = 'a6s9_slide'
    R = h.page(S, 'After the Album: Problem, Size and Recommendation',
               'Paying players over $20 a day · 3 albums per game (Dice 59/61/63, Domino 17/19/20, Disney 12/14/15)',
               'Finishers are not the album-end problem. The problem is high spenders who end 1–2 stickers short: test helping them finish.',
               msg_red='test helping them finish', idx=idx, msg_y=4.6)
    R += card(S, S + '_k1', 0.55, 1.2, 4.45, 1.55, 'PROBLEM', h.RED,
              'Payers over $20 a day who end 1–2 stickers short spend 17–24% less in the week after close than in a normal mid-album week, in every game and all 9 albums. Finishers over $20 drop about as much as in a normal week.')
    R += card(S, S + '_k2', 5.1, 1.2, 4.45, 1.55, 'SIZE (ONE WEEK, PER ALBUM)', h.GOLD,
              'Dice $35,320–$76,845 · Domino $7,385–$33,947 · Disney $73,382–$93,247 below their normal week. They bring 4–9% of album revenue. This is the gap, not money sure to come back.')
    R += card(S, S + '_k3', 0.55, 2.85, 4.45, 1.55, 'WHY: NOT KNOWN YET', h.GREY,
              'Ruled out: stock left after close, free coins / rolls, payout after close, the calendar. Hypothesis (not tested): missing the album after spending a lot lowers the will to start the next one.')
    R += card(S, S + '_k4', 5.1, 2.85, 4.45, 1.55, 'RECOMMENDATION', h.GOLD,
              'TEST: help payers over $20 a day finish when they are 1–2 stickers short near the end (end goal per spend level). Main measure: spend in the week after close; guardrail: album revenue. DO NOT ADOPT: payout change after close; bigger prize for finishers.')
    return R

# s10: players 1-2 short, payout mid-album (close-18..-5) vs days 1-3 after close, up to $2 vs over $20, 3-album average
# (topic6-payout-3albums-2026-10-24.md + latest-album run topic6_payout_prizes_by_level_2026-10-24.sql)
PAY12 = {'Dice': [(91, 84, -8), (71, 70, -1)], 'Domino': [(85, 77, -9), (67, 64, -5)], 'Disney': [(83, 72, -14), (57, 53, -6)]}

def s10(idx=None):
    S, BASE, PER = 'a6s10_slide', 3.35, 0.014
    msg = 'Over $20 a day the game gives these players back much less than light spenders during the album (Dice 71% vs 91%), and after close their payout barely moves (−1% to −6%). So the payout after close does not explain their drop in spend.'
    R = h.page(S, 'Missing 1–2 Stickers: Payout Before and After Close, by Spend Level',
               'Payout = coins / rolls won (album prizes included) ÷ coins / rolls spent on play · whole group · mid-album = close−18..−5 · 3-album average · formulas differ by game: compare within a game',
               msg, msg_red='after close their payout barely moves (−1% to −6%)', idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.25, 2.85, 0.32, name, 14, h.WHITE, True, 'CENTER')
        for k, (lab, (mid, aft, chg)) in enumerate(zip(['up to $2 a day', 'over $20 a day'], PAY12[name])):
            gx = px + 0.3 + k * 1.3
            for j, (v, c) in enumerate([(mid, LIGHT), (aft, col)]):
                x, hgt = gx + j * 0.55, v * PER
                R += h.rect(S, f'{S}_b{g}{k}{j}', x, BASE - hgt, 0.5, hgt, c)
                R += h.tbox(S, f'{S}_v{g}{k}{j}', x - 0.1, BASE - hgt - 0.25, 0.7, 0.24, f'{v}%', 10, h.WHITE, True, 'CENTER')
                R += h.tbox(S, f'{S}_w{g}{k}{j}', x - 0.12, BASE + 0.02, 0.74, 0.34, ['mid-\nalbum', 'days 1–3\nafter'][j], 7, h.GREY, False, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', gx - 0.15, BASE + 0.38, 1.35, 0.22, lab, 9, h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_d{g}{k}', gx - 0.15, BASE + 0.6, 1.35, 0.22, f'change: {chg:+d}%', 9, h.RED if k == 1 else h.GREY, True, 'CENTER')
    return R

# Domino free finishers (Eden 2026-10-24): r1 share of finishers who did not pay; r3 paid before / after; r4 problem-size-recommendation.
NONPAY = {'Dice': [('59', 6), ('61', 5), ('63', 1)], 'Domino': [('17', 17), ('19', 30), ('20', 43)], 'Disney': [('12', 15), ('14', 8), ('15', 5)]}

def r1(idx=None):
    S, BASE, PER = 'd20r1_slide', 3.75, 0.042
    msg = 'Domino is the outlier and the share keeps growing: 17% → 30% → 43% of finishers did not pay during the album. In Dice and Disney it is 1–15%.'
    R = h.page(S, 'Finishers Who Did Not Pay During the Album, 3 Albums per Game',
               'All finishers (144 stickers by the end of the close day), standard population · did not pay = no purchase on any album day · bars = albums',
               msg, msg_red='17% → 30% → 43%', idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.25, 2.85, 0.32, name, 14, h.WHITE, True, 'CENTER')
        for k, (alb, v) in enumerate(NONPAY[name]):
            x, hgt = px + 0.42 + k * 0.72, max(v * PER, 0.03)
            R += h.rect(S, f'{S}_b{g}{k}', x, BASE - hgt, 0.55, hgt, col)
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.15, BASE - hgt - 0.27, 0.85, 0.25, f'{v}%', 11, h.RED if (name == 'Domino' and k == 2) else h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', x - 0.15, BASE + 0.03, 0.85, 0.22, f'album {alb}', 8, h.GREY, False, 'CENTER')
    R += h.tbox(S, f'{S}_n', 3.6, 1.6, 2.85, 0.3, 'Domino 20: 7,517 of 17,665 finishers', 9, h.WHITE, False, 'CENTER')
    return R

def big(S, oid, x, y, w, num, lab, col):
    return h.tbox(S, oid + 'n', x, y, w, 0.55, num, 30, col, True, 'CENTER') + h.tbox(S, oid + 'l', x, y + 0.58, w, 0.4, lab, 9, h.GREY, False, 'CENTER')

def r3(idx=None):
    S = 'd20r3_slide'
    msg = 'Domino finishers who did not pay are players who never pay: 2–3% paid in the month before the album and 1% in the week after. Finishing for free did not turn them into payers.'
    R = h.page(S, 'Domino Finishers Who Did Not Pay: Purchases Before and After the Album',
               'Domino finishers with no purchase during the album · before = 30 days before the album opened · after = 7 days from the close day',
               msg, msg_red='Finishing for free did not turn them into payers', idx=idx, msg_y=4.6)
    rows = [('17', '1,228', '3%', '1%'), ('19', '1,951', '3%', '1%'), ('20', '6,543', '2%', '1%')]
    for k, (alb, n, pre, post) in enumerate(rows):
        px = 0.55 + k * 3.05
        R += h.rect(S, f'{S}_p{k}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{k}', px, 1.25, 2.85, 0.32, f'Domino {alb}', 14, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_s{k}', px, 1.57, 2.85, 0.25, f'{n} players', 9, h.GREY, False, 'CENTER')
        R += big(S, f'{S}_a{k}', px, 2.0, 2.85, pre, 'paid in the 30 days\nbefore the album', h.WHITE)
        R += big(S, f'{S}_b{k}', px, 3.1, 2.85, post, 'paid in the week\nafter the close', h.RED)
    return R

def r4(idx=None):
    S = 'd20r4_slide'
    R = h.page(S, 'Domino Free Finishers: Problem, Size and Recommendation',
               'Domino album 20 · finishers with no purchase during the album · RV = rewarded video (watch an ad, get a reward)',
               'RV gives players who never pay a full free path to the album end. Test a cap on RV rewards; keep the easier end for payers.',
               msg_red='Test a cap on RV rewards', idx=idx, msg_y=4.6)
    R += card(S, S + '_k1', 0.55, 1.2, 4.45, 1.55, 'PROBLEM', h.RED,
              '43% of Domino 20 finishers (7,517) did not pay. They watched about 93 RVs a day. RV gave them sticker packs and Puzzle pieces, and the Puzzle Joker gave 60% of them the last sticker.')
    R += card(S, S + '_k2', 5.1, 1.2, 4.45, 1.55, 'SIZE', h.GOLD,
              'Ad revenue from them: $45,084 in album 20, 0.28% of game purchase revenue during the album. 98% did not pay in the month before; 1% paid in the week after.')
    R += card(S, S + '_k3', 0.55, 2.85, 4.45, 1.55, 'OPEN QUESTIONS', h.GREY,
              'About 93 views a day may include automated viewing: not checked, ask the Domino ads team. The RV flag on Puzzle pieces looks player-level, so RV gave 13–94% of their Puzzle pieces.')
    R += card(S, S + '_k4', 5.1, 2.85, 4.45, 1.55, 'RECOMMENDATION', h.GOLD,
              'TEST: cap RV views per day and per album, and take sticker packs and Puzzle pieces out of the RV badge in the last third of the album; keep coins and energy. Keep the Puzzle Jokers for payers. Measures: non-payer finish rate, payer conversion, ad revenue, next album 14 days.')
    return R

# r2: Domino non-paying finishers, what RV gave them, albums 17 / 19 / 20 (domino-rv-3albums-2026-10-24.md)
RVK = [('players (finishers who did not pay)', ['1,865', '2,953', '7,517']),
       ('watched RV', ['79%', '78%', '91%']),
       ('RV views per watcher (median)', ['4,002', '3,146', '2,887']),
       ('days with RV (average)', ['32', '34', '31']),
       ('sticker packs from RV per watcher', ['820', '758', '644']),
       ('new stickers from RV packs per player', ['30', '22', '18']),
       ('Puzzle pieces from RV per watcher', ['5,740', '5,930', '5,094']),
       ('new stickers from Puzzle Jokers per player', ['1.0', '1.0', '2.4'])]

def r2(idx=None):
    S = 'd20r2_slide'
    msg = 'In all three albums, Domino finishers who did not pay watched RV almost every day and got hundreds of sticker packs and thousands of Puzzle pieces. What changed in album 20 is the Puzzle Joker (2.4 new stickers each vs 1.0), and their number grew from 1,865 to 7,517.'
    R = h.page(S, 'Domino Finishers Who Did Not Pay: RV Views and What RV Gave Them',
               'Domino finishers (144 stickers by the end of the close day) with no purchase during the album · RV = rewarded video · albums 17 / 19 / 20',
               msg, msg_red='What changed in album 20 is the Puzzle Joker', idx=idx, msg_y=4.6)
    R += h.rect(S, f'{S}_bg', 0.55, 1.2, 9.0, 3.2, h.CARD)
    for c, t in enumerate(['album 17', 'album 19', 'album 20']):
        R += h.tbox(S, f'{S}_h{c}', 5.0 + c * 1.5, 1.27, 1.4, 0.3, t, 12, h.WHITE, True, 'CENTER')
    for r_, (lab, vals) in enumerate(RVK):
        y = 1.62 + r_ * 0.34
        R += h.tbox(S, f'{S}_l{r_}', 0.75, y, 4.2, 0.3, lab, 11, h.GREY)
        for c, v in enumerate(vals):
            red = (r_ == 7 and c == 2) or (r_ == 0 and c == 2)
            R += h.tbox(S, f'{S}_v{r_}{c}', 5.0 + c * 1.5, y, 1.4, 0.3, v, 12, h.RED if red else h.WHITE, True, 'CENTER')
    return R

# t7d: visual test slide (Eden 2026-10-24: no text, visual). Dice 200K tier, $2K+ album spend, prize = 2 days of own play.
def t7d(idx=None):
    S, BASE, PER = 't7d_slide', 3.95, 0.85
    R = h.page(S, 'Test: 2-Day Grand Prize for Dice $2K+ Payers',
               'Dice 200K tier, $2,000+ album spend · random 50/50 at album start · median player · albums 59 / 61 / 63',
               'Today the top payers get less than 1 day of their own play. Test 2 days; main measure: next-album spend over 14 days vs Control.',
               msg_red='Test 2 days', idx=idx, msg_y=4.6)
    R += h.rect(S, f'{S}_pc', 0.55, 1.2, 4.6, 3.15, h.CARD)
    R += h.tbox(S, f'{S}_pt', 0.55, 1.25, 4.6, 0.3, 'Prize in days of the player\'s own play', 12, h.WHITE, True, 'CENTER')
    R += h.rect(S, f'{S}_z', 0.8, BASE - PER, 4.1, 0.012, h.GREY)
    R += h.tbox(S, f'{S}_zl', 4.45, BASE - PER - 0.22, 0.6, 0.2, '1 day', 8, h.GREY)
    for k, (lab, v, sub, c) in enumerate([('Control (today)', 0.8, '200K rolls', LIGHT), ('Test', 2.0, 'about 500K rolls', h.GOLD)]):
        x, hgt = 1.15 + k * 1.95, v * PER
        R += h.rect(S, f'{S}_b{k}', x, BASE - hgt, 1.3, hgt, c)
        R += h.tbox(S, f'{S}_v{k}', x - 0.2, BASE - hgt - 0.55, 1.7, 0.32, f'{v:g} {"day" if v < 1.5 else "days"}', 18, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_s{k}', x - 0.2, BASE - hgt - 0.25, 1.7, 0.22, sub, 9, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_l{k}', x - 0.2, BASE + 0.05, 1.7, 0.25, lab, 10, h.WHITE, True, 'CENTER')
    tiles = [('~600', 'players per album · 7% of album revenue', h.WHITE),
             ('~300', 'finish the album and get the prize', h.WHITE),
             ('+110M–130M', 'extra rolls per album (cost)', h.GOLD)]
    for k, (num, lab, c) in enumerate(tiles):
        y = 1.2 + k * 1.07
        R += h.rect(S, f'{S}_t{k}', 5.3, y, 4.25, 0.97, h.CARD)
        R += h.tbox(S, f'{S}_tn{k}', 5.45, y + 0.08, 3.95, 0.5, num, 24, c, True)
        R += h.tbox(S, f'{S}_tl{k}', 5.45, y + 0.6, 3.95, 0.3, lab, 10, h.GREY)
    return R

# t7e: Eden 2026-10-24: not 500K; test 250K or 300K for Dice $2K+ payers in the 200K tier. Days = album 63 median (252,691 rolls a day).
def t7e(idx=None):
    S, BASE, PER = 't7e_slide', 3.95, 1.25
    R = h.page(S, 'Test Options: 250K or 300K Grand Prize for Dice $2K+ Payers',
               'Dice 200K tier, $2,000+ album spend · random split at album start · prize in days of own play = median player, album 63',
               'Today the top payers get 0.8 day of their own play. 250K or 300K brings it to about 1 day; the size is a management choice.',
               msg_red='250K or 300K', idx=idx, msg_y=4.6)
    R += h.rect(S, f'{S}_pc', 0.55, 1.2, 4.6, 3.15, h.CARD)
    R += h.tbox(S, f'{S}_pt', 0.55, 1.25, 4.6, 0.3, 'Prize in days of the player\'s own play', 12, h.WHITE, True, 'CENTER')
    bars = [('Control (today)', 0.8, '200K rolls', LIGHT), ('Option A', 1.0, '250K rolls', h.GOLD), ('Option B', 1.2, '300K rolls', h.GOLD)]
    for k, (lab, v, sub, c) in enumerate(bars):
        x, hgt = 0.95 + k * 1.4, v * PER
        R += h.rect(S, f'{S}_b{k}', x, BASE - hgt, 1.0, hgt, c)
        R += h.tbox(S, f'{S}_v{k}', x - 0.2, BASE - hgt - 0.55, 1.4, 0.32, f'{v:.1f} day' + ('' if v <= 1 else 's'), 16, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_s{k}', x - 0.2, BASE - hgt - 0.25, 1.4, 0.22, sub, 9, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_l{k}', x - 0.2, BASE + 0.05, 1.4, 0.25, lab, 10, h.WHITE, True, 'CENTER')
    tiles = [('~600', 'players per album · 7% of album revenue', h.WHITE),
             ('~300', 'finish the album and get the prize', h.WHITE),
             ('+10–15M / +21–31M', 'extra rolls per album: 250K / 300K', h.GOLD)]
    for k, (num, lab, c) in enumerate(tiles):
        y = 1.2 + k * 1.07
        R += h.rect(S, f'{S}_t{k}', 5.3, y, 4.25, 0.97, h.CARD)
        R += h.tbox(S, f'{S}_tn{k}', 5.45, y + 0.08, 3.95, 0.5, num, 24, c, True)
        R += h.tbox(S, f'{S}_tl{k}', 5.45, y + 0.6, 3.95, 0.3, lab, 10, h.GREY)
    return R

# t7f: fixed prize (topic7-fixed-prize-spend-2026-10-24.md). Cohort = album 63 200K tier, $2K+ album spend; same players in 59 / 61.
def t7f(idx=None):
    S, BASE, PER = 't7f_slide', 3.75, 0.00068
    R = h.page(S, '$2K+ Payers in the 200K Tier: Album Spend vs Grand Prize',
               'Dice · 591 players with the 200K prize and $2,000+ spend in album 63, followed back to albums 59 and 61 · median player',
               'The same players spend about $2,000–2,800 in every album and get the same 200K prize. Per dollar, the prize gives them 30–50 times less than a payer under $150 in the same tier.',
               msg_red='30–50 times less', idx=idx, msg_y=4.6)
    R += h.rect(S, f'{S}_pc', 0.55, 1.2, 4.6, 3.15, h.CARD)
    R += h.tbox(S, f'{S}_pt', 0.55, 1.25, 4.6, 0.3, 'Album spend, median player', 12, h.WHITE, True, 'CENTER')
    for k, (alb, v) in enumerate([('59', 2155), ('61', 2017), ('63', 2838)]):
        x, hgt = 1.0 + k * 1.35, v * PER
        R += h.rect(S, f'{S}_b{k}', x, BASE - hgt, 1.0, hgt, h.BLUE)
        R += h.tbox(S, f'{S}_v{k}', x - 0.2, BASE - hgt - 0.32, 1.4, 0.3, f'${v:,}', 15, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_l{k}', x - 0.2, BASE + 0.03, 1.4, 0.22, f'album {alb}', 9, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_g{k}', x - 0.2, BASE + 0.25, 1.4, 0.25, 'prize 200K', 10, h.GOLD, True, 'CENTER')
    tiles = [('~half', 'spent $2,000+ in each of the two albums before', h.WHITE),
             ('70–88', 'rolls of prize per $ spent: these players', h.RED),
             ('2,150–3,642', 'rolls of prize per $ spent: payers under $150, same 200K tier', h.GREY)]
    for k, (num, lab, c) in enumerate(tiles):
        y = 1.2 + k * 1.07
        R += h.rect(S, f'{S}_t{k}', 5.3, y, 4.25, 0.97, h.CARD)
        R += h.tbox(S, f'{S}_tn{k}', 5.45, y + 0.08, 3.95, 0.5, num, 24, c, True)
        R += h.tbox(S, f'{S}_tl{k}', 5.45, y + 0.6, 3.95, 0.3, lab, 10, h.GREY)
    return R

# a6s9v: visual version of a6s9 (Eden 2026-10-24). >$20 payers 1-2 short: week after close vs own normal week, 3-album average.
def s9v(idx=None):
    S, ZERO, PER = 'a6s9v_slide', 1.95, 0.068
    R = h.page(S, 'Missing 1–2 Stickers, Over $20: After Close vs Normal Week',
               'Paying players · week after close vs the same players\' normal mid-album week (album days 21–27) · average of 3 albums per game',
               'In every game and all 9 albums these payers spend 17–24% less after close than in a normal week. Test helping them finish.',
               msg_red='Test helping them finish', idx=idx, msg_y=4.6)
    R += h.rect(S, f'{S}_pc', 0.55, 1.2, 4.6, 3.15, h.CARD)
    R += h.tbox(S, f'{S}_pt', 0.55, 1.25, 4.6, 0.3, 'Week after close vs normal week', 12, h.WHITE, True, 'CENTER')
    R += h.rect(S, f'{S}_z', 0.8, ZERO, 4.1, 0.012, h.GREY)
    for k, ((name, col), v) in enumerate(zip(GAMES, [-23, -24, -17])):
        x, hgt = 1.05 + k * 1.35, abs(v) * PER
        R += h.rect(S, f'{S}_b{k}', x, ZERO, 1.0, hgt, col)
        R += h.tbox(S, f'{S}_v{k}', x - 0.2, ZERO + hgt + 0.03, 1.4, 0.32, f'{v}%', 16, h.RED, True, 'CENTER')
        R += h.tbox(S, f'{S}_l{k}', x - 0.2, ZERO - 0.3, 1.4, 0.25, name, 11, h.WHITE, True, 'CENTER')
    tiles = [('$7K–$93K', 'one-week gap per album (Dice $35K–77K · Domino $7K–34K · Disney $73K–93K)', h.WHITE),
             ('4–9%', 'of album revenue · under 1% of payers', h.WHITE),
             ('TEST', 'help them finish when they are 1–2 short near the end', h.GOLD)]
    for k, (num, lab, c) in enumerate(tiles):
        y = 1.2 + k * 1.07
        R += h.rect(S, f'{S}_t{k}', 5.3, y, 4.25, 0.97, h.CARD)
        R += h.tbox(S, f'{S}_tn{k}', 5.45, y + 0.08, 3.95, 0.5, num, 24, c, True)
        R += h.tbox(S, f'{S}_tl{k}', 5.45, y + 0.6, 3.95, 0.3, lab, 9, h.GREY)
    return R

# Simplified (Eden 2026-10-24: "too much partial info, simplify"). One chart, one message, details in notes.
def t7g(idx=None):   # replaces t7f
    S, BASE, PER = 't7g_slide', 3.9, 0.0007
    R = h.page(S, 'Dice 200K Tier: Album Spend and Prize, Top vs Light Payers',
               'Dice album 63 · players who finished and got the 200K grand prize · median player in each group',
               'Top payers spend about 40 times more than light payers, and get the same 200K prize.',
               msg_red='the same 200K prize', idx=idx, msg_y=4.6)
    R += h.rect(S, f'{S}_pc', 0.55, 1.2, 9.0, 3.15, h.CARD)
    for k, (lab, v, n) in enumerate([('Top payers ($2,000+)', 3078, '296 players · 3.8% of album revenue'), ('Light payers ($1–149)', 77, '2,183 players · 0.6% of album revenue')]):
        x, hgt = 1.6 + k * 4.0, max(v * PER, 0.04)
        R += h.rect(S, f'{S}_b{k}', x, BASE - hgt, 2.4, hgt, h.BLUE if k == 0 else LIGHT)
        R += h.tbox(S, f'{S}_v{k}', x - 0.3, BASE - hgt - 0.45, 3.0, 0.4, f'${v:,} album spend', 18, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_l{k}', x - 0.3, BASE + 0.05, 3.0, 0.25, f'{lab} · {n}', 10, h.GREY, False, 'CENTER')
        R += h.rect(S, f'{S}_c{k}', x + 0.45, BASE - hgt + 0.2 if k == 0 else BASE - hgt - 0.95, 1.5, 0.38, h.GOLD)
        R += h.tbox(S, f'{S}_cp{k}', x + 0.45, BASE - hgt + 0.23 if k == 0 else BASE - hgt - 0.92, 1.5, 0.32, 'prize 200K', 13, {'red': 0.13, 'green': 0.13, 'blue': 0.13}, True, 'CENTER')
    return R

def t7h(idx=None):   # replaces t7e
    S, BASE, PER = 't7h_slide', 3.9, 1.3
    R = h.page(S, 'Test: Bigger Grand Prize for Dice $2K+ Payers',
               'Prize in days of the player\'s own play · median $2K+ payer in the 200K tier, album 63',
               'Today the prize covers 0.8 day of a top payer\'s play. 250K or 300K brings it to 1–1.2 days. Test one size against today.',
               msg_red='Test one size against today', idx=idx, msg_y=4.6)
    R += h.rect(S, f'{S}_pc', 0.55, 1.2, 9.0, 3.15, h.CARD)
    for k, (lab, v, c) in enumerate([('Today: 200K', 0.8, LIGHT), ('Option A: 250K', 1.0, h.GOLD), ('Option B: 300K', 1.2, h.GOLD)]):
        x, hgt = 1.4 + k * 2.6, v * PER
        R += h.rect(S, f'{S}_b{k}', x, BASE - hgt, 1.8, hgt, c)
        R += h.tbox(S, f'{S}_v{k}', x - 0.2, BASE - hgt - 0.45, 2.2, 0.4, f'{v:.1f} day' + ('' if v <= 1 else 's'), 20, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_l{k}', x - 0.2, BASE + 0.05, 2.2, 0.25, lab, 11, h.WHITE, True, 'CENTER')
    return R

# d20r5: redesign of Eden's RV slide (h22531cc986c0856e_34_215) as a flow: one view (tiny) x 2,887 views -> free path to the end.
def arrow(S, oid, x, y, w, hh, c):
    return h.box(S, oid, x, y, w, hh, 'RIGHT_ARROW') + [{'updateShapeProperties': {'objectId': oid, 'shapeProperties': {'shapeBackgroundFill': {'solidFill': {'color': {'rgbColor': c}}}, 'outline': {'propertyState': 'NOT_RENDERED'}}, 'fields': 'shapeBackgroundFill.solidFill.color,outline.propertyState'}}]

def r5(idx=None):
    S = 'd20r5_slide'
    R = h.page(S, 'Domino 20 Free Finishers: What RV Gives, One View vs Album',
               'Domino album 20 · finishers with no purchase (7,517 players) · RV = rewarded video (watch an ad, get a small reward) · median player',
               'One view gives almost nothing, but about 93 views a day add up to a free path to the album end.',
               msg_red='a free path to the album end', idx=idx, msg_y=4.6)
    # step 1: one view
    R += h.rect(S, f'{S}_a', 0.55, 1.35, 2.3, 2.6, h.CARD)
    R += h.tbox(S, f'{S}_ah', 0.55, 1.45, 2.3, 0.3, 'ONE VIEW', 11, h.GREY, True, 'CENTER')
    for k, (num, lab) in enumerate([('0.18', 'sticker pack'), ('1.5', 'Puzzle pieces'), ('$0.002', 'ad revenue')]):
        y = 1.85 + k * 0.68
        R += h.tbox(S, f'{S}_an{k}', 0.55, y, 2.3, 0.4, num, 20, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_al{k}', 0.55, y + 0.37, 2.3, 0.22, lab, 9, h.GREY, False, 'CENTER')
    # multiplier
    R += arrow(S, f'{S}_x1', 2.95, 2.35, 1.5, 0.6, h.GREY)
    R += h.tbox(S, f'{S}_xn', 2.85, 1.7, 1.7, 0.45, '× 2,887', 22, h.RED, True, 'CENTER')
    R += h.tbox(S, f'{S}_xl', 2.85, 3.05, 1.7, 0.45, 'views in the album\n(about 93 a day)', 9, h.GREY, False, 'CENTER')
    # step 2: whole album, two paths
    R += h.rect(S, f'{S}_b', 4.55, 1.35, 2.5, 1.2, h.CARD)
    R += h.tbox(S, f'{S}_bn', 4.55, 1.45, 2.5, 0.45, '~640 packs', 20, h.WHITE, True, 'CENTER')
    R += h.tbox(S, f'{S}_bl', 4.55, 1.95, 2.5, 0.45, '18 new stickers each', 10, h.GREY, False, 'CENTER')
    R += h.rect(S, f'{S}_c', 4.55, 2.75, 2.5, 1.2, h.CARD)
    R += h.tbox(S, f'{S}_cn', 4.55, 2.85, 2.5, 0.45, '~5,100 pieces', 20, h.WHITE, True, 'CENTER')
    R += h.tbox(S, f'{S}_cl', 4.55, 3.35, 2.5, 0.45, 'Puzzle event pieces', 10, h.GREY, False, 'CENTER')
    R += arrow(S, f'{S}_x2', 7.15, 3.05, 0.6, 0.6, h.GREY)
    # step 3: the end
    R += h.rect(S, f'{S}_d', 7.85, 2.55, 1.7, 1.6, h.CARD)
    R += h.tbox(S, f'{S}_dn', 7.85, 2.65, 1.7, 0.5, '60%', 26, h.RED, True, 'CENTER')
    R += h.tbox(S, f'{S}_dl', 7.85, 3.2, 1.7, 0.85, 'got their last sticker from a Puzzle Joker', 9, h.GREY, False, 'CENTER')
    # action
    R += h.tbox(S, f'{S}_act', 0.55, 4.15, 9.0, 0.35, 'TEST: a daily RV cap, and RV rewards without sticker packs / Puzzle pieces · measure: payer conversion, retention, ad revenue', 10, h.GOLD, True)
    return R

# dj1: redesign of Eden's Disney Joker test slide (h22531cc986c0856e_0_118) as a timeline of the last 7 days.
def dj1(idx=None):
    S = 'dj1_slide'
    X0, CW = 2.35, 0.88
    days = ['−7', '−6', '−5', '−4', '−3', '−2', '−1']
    R = h.page(S, 'Disney Joker in the Last 7 Days: Today vs Two Tests',
               'Disney paying players · days before the album close · Joker = fills any missing sticker',
               'Today Disney payers can get a Joker only in the last 3 days. Test giving it earlier: on sale from day −7 (A), or as an event prize on days −4 to −3 (B).',
               msg_red='Test giving it earlier', idx=idx, msg_y=4.6)
    R += h.rect(S, f'{S}_bg', 0.55, 1.2, 9.0, 2.45, h.CARD)
    for k, d in enumerate(days):
        R += h.tbox(S, f'{S}_d{k}', X0 + k * CW, 1.28, CW, 0.25, f'day {d}', 9, h.GREY, False, 'CENTER')
    rows = [('Control (today)', [(4, 7, LIGHT, 'Joker on sale')]),
            ('Test A · sale', [(0, 7, h.GOLD, 'Joker on sale from day −7')]),
            ('Test B · event', [(3, 5, h.GOLD, 'event prize'), (5, 7, LIGHT, 'sale as today')])]
    for r_, (lab, segs) in enumerate(rows):
        y = 1.62 + r_ * 0.65
        R += h.tbox(S, f'{S}_l{r_}', 0.7, y + 0.1, 1.6, 0.3, lab, 12, h.WHITE if r_ == 0 else h.GOLD, True)
        for j, (a, b, c, t) in enumerate(segs):
            R += h.rect(S, f'{S}_s{r_}{j}', X0 + a * CW + 0.03, y, (b - a) * CW - 0.06, 0.48, c)
            R += h.tbox(S, f'{S}_t{r_}{j}', X0 + a * CW, y + 0.1, (b - a) * CW, 0.3, t, 10, {'red': 0.13, 'green': 0.13, 'blue': 0.13}, True, 'CENTER')
    # evidence strip
    R += h.rect(S, f'{S}_ev', 0.55, 3.75, 9.0, 0.7, h.CARD)
    R += h.tbox(S, f'{S}_evn', 0.7, 3.8, 1.3, 0.6, '×1.8', 26, h.GOLD, True)
    R += h.tbox(S, f'{S}_evl', 2.0, 3.85, 7.4, 0.55, 'Why B: in Domino 20, payers who got the event Joker spent 1.8× their usual pace in those 2 days (18% of payers, 31% of album revenue). Today only 0.1% of Disney payers a day get a Joker before day −3.', 10, h.GREY)
    return R

# Split of Eden's v144_slide (2 messages) into two one-message slides (lull-economy-disney15-2026-10-23.md).
TEAL = {'red': 0.235, 'green': 0.784, 'blue': 0.706}
def v1(idx=None):   # economy: revenue per day, quiet vs release window
    S, BASE, PER = 'v144a_slide', 3.9, 0.0000022
    R = h.page(S, 'Disney 15 Payers: Revenue per Day, Quiet vs Sticker-Release Days',
               'Disney album 15 · all paying players · days 10–13 (few new stickers) vs days 16–19 (many new stickers, high coin payout)',
               'When the game releases many stickers and pays out more coins, payers spend 11% less a day.',
               msg_red='11% less a day', idx=idx, msg_y=4.6)
    R += h.rect(S, f'{S}_pc', 0.55, 1.2, 9.0, 3.15, h.CARD)
    rows = [('Days 10–13 · quiet', 873249, '1 new sticker a day · payout 53%', LIGHT), ('Days 16–19 · release', 781517, '5 new stickers a day · payout 63%', TEAL)]
    for k, (lab, v, sub, c) in enumerate(rows):
        x, hgt = 1.6 + k * 4.0, v * PER
        R += h.rect(S, f'{S}_b{k}', x, BASE - hgt, 2.4, hgt, c)
        R += h.tbox(S, f'{S}_v{k}', x - 0.3, BASE - hgt - 0.45, 3.0, 0.4, f'${v:,} a day', 18, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_l{k}', x - 0.3, BASE + 0.03, 3.0, 0.22, lab, 10, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_s{k}', x - 0.5, BASE + 0.22, 3.4, 0.22, sub, 9, h.GREY, False, 'CENTER')
    R += h.tbox(S, f'{S}_d', 4.1, 2.2, 1.4, 0.4, '−11%', 22, h.RED, True, 'CENTER')
    return R

def v2(idx=None):   # who falls behind and when
    S, BASE, PER = 'v144b_slide', 3.85, 0.12
    R = h.page(S, 'Disney 15: Stickers Behind Finishers, Payers Who End 4+ Away',
               '263,164 paying players (81% of payers, 43% of album revenue) · gap = finishers\' stickers minus theirs, by album day',
               'Payers who end 4+ away fall behind gradually in every game; in Disney the gap gets bigger in the middle of the album (16–17 vs 9–12 in Dice and Domino).',
               msg_red='in Disney the gap gets bigger in the middle of the album', idx=idx, msg_y=4.6)
    R += h.rect(S, f'{S}_pc', 0.55, 1.2, 9.0, 3.15, h.CARD)
    pts = [('day 9', 10), ('day 13', 12), ('day 26', 17), ('day 31', 18)]
    for k, (lab, v) in enumerate(pts):
        x, hgt = 1.2 + k * 2.15, v * PER
        R += h.rect(S, f'{S}_b{k}', x, BASE - hgt, 1.3, hgt, TEAL)
        R += h.tbox(S, f'{S}_v{k}', x - 0.2, BASE - hgt - 0.4, 1.7, 0.36, f'{v}', 18, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_l{k}', x - 0.2, BASE + 0.03, 1.7, 0.22, lab, 10, h.GREY, False, 'CENTER')
    for k, (txt, c) in enumerate([('+0.5 a day', h.GREY), ('+0.4 a day', h.GREY), ('+0.2 a day', h.GREY)]):
        R += h.tbox(S, f'{S}_g{k}', 2.15 + k * 2.15, 1.3, 1.6, 0.25, txt, 10, c, True, 'CENTER')
    return R

NOTES = {
 'a6s1_slide': """Why this slide: the week after an album close is also a calendar week. Before comparing games we check how much the week itself moves revenue.
Measure: all players' purchase revenue a day in the 7 days after the date ÷ the average day of the 30 days before (excluded / cheater / test users out; deck-wide revenue definition). Taken at every game's close date in all three games, so each game also has weeks without its own close.
Early September (US Labor Day, back to school): Dice 92% (its album 63 closed), Domino 90% and Disney 85% (no close). October: 99–112% in all games. Summer weeks without a close: Domino 94%, Disney 93%.
So: the Dice 63 "weak return" (the earlier s6c slide) partly comes from the week. Comparing one album per game can mislead; the next slides use 3 albums per game (Dice 59/61/63, Domino 17/19/20, Disney 12/14/15).
SQL: claude/topic6_calendar_check_2026-10-24.sql. Doc: claude/topic6-game-revenue-after-close-2026-10-24.md.""",
 'a6s2_slide': """Who: paying finishers in the standard population (not first album, not excluded, login ratio ≥ 0.5, active the day before close), with all 144 stickers on the day before close, spending $2–20 a day (own pace).
Usual pace = the player's own album spend per day before the last quarter of the album. Week after = spend in the 7 days after close (next album) ÷ (7 × usual pace). Group totals.
Per album (close date): Dice 59 123% (Jun 22), 61 129% (Jul 27), 63 110% (Sep 7); Domino 17 117% (May 11), 19 134% (Aug 24), 20 140% (Oct 12); Disney 12 131% (Jun 22), 14 135% (Aug 24), 15 128% (Oct 5). Average: Dice 121%, Domino 131%, Disney 132%.
All spend levels: Dice 113%, Domino 115%, Disney 115% (3-album averages). Players 1–2 stickers short ($2–20): Dice 98%, Domino 102%, Disney 111%.
Order changes by album: Dice 59 (123%) is above Domino 17 (117%); Dice 61 (129%) is close to Domino 19 / Disney 14. Disney 13 (a 21-day mini album) and Domino 18 (up to 168 stickers) are not regular 144-sticker albums and are left out (agreed 3-album set).
Next question: why is Dice lower on average? Candidates tested next: prize size, stock, free coins/rolls, purchase size, payout.
Doc: claude/topic6-calendar-neutral-return-2026-10-24.md.""",
 'a6s7_slide': """Payout = what the game gives back ÷ what the player spends on play, whole group (sum ÷ sum, so heavy players weigh more), album prizes included (they are rolls / coins the player gets).
Dice: rolls won (without ads, timer, daily gifts, invites, deep links) minus bought rolls ÷ rolls bet. Domino and Disney: coins won ÷ coins spent on level starts and boosters. Levels are not comparable across games (different formulas); the change vs the same players' mid-album (days −18..−5) is.
Paying finishers, latest album (Dice 63, Domino 20, Disney 15), status on the day before close, by spend level (own pace): Dice −14 / −10 / −5 / −2%, Domino −18 / −19 / −16 / −12%, Disney −22 / −20 / −14 / −8%. All finishers: −8 / −16 / −14%.
Players 1–2 short: Dice −3%, Domino −12%, Disney −9% (smallest cut in Dice at every level too).
Evidence for the hypothesis: across games the smallest cut (Dice) goes with the lowest return (slide 2); Dice 61 cut more (−18%, end-of-close-day status) and came back better than Dice 63 (−12%).
Evidence against / open: inside each game, players whose own payout fell did not spend more; stock and free coins/rolls after close are the same in all games.
Recommendation: TEST in Dice — a tighter payout in days 1–3 of the new album for finishers and players 1–2 short, Control = today; measure spend vs own pace days 1–7; guardrails: next-album spend over 14 days, finish rate, churn.
Doc: claude/topic6-payout-prizes-by-level-2026-10-24.md."""
}

if __name__ == '__main__':
    if sys.argv[1] == 'notes': print(json.dumps(NOTES, ensure_ascii=False))
    else: print(json.dumps(globals()[sys.argv[1]](int(sys.argv[2]) if len(sys.argv) > 2 else None), ensure_ascii=False, separators=(',', ':')))
