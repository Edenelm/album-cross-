"""ALBUM END: topic 6 point 1 (Eden 2026-10-24) — finishers come back at different levels: prize size or game?
t6e = paying finishers by prize size in days of own play, three games. t6f = last week -> week after for finishers with a small prize (<2 days).
t6g (point 2) = payers 1-2 short on close-1, last week -> week after by spend level. Data: claude/topic6-short-payers-2026-10-24.md.
Data: claude/topic6-finisher-prize-2026-10-24.md (SQL claude/topic6_finisher_prize_2026-10-24.sql).
Usage (from claude/): python3 slide_t6_finisher_prize_2026-10-24.py <e|f|g|notes> [insertionIndex]"""
import json, sys, importlib.util as u
s = u.spec_from_file_location('h', 'slide_t7_dice_prize_2026-10-25.py'); h = u.module_from_spec(s); s.loader.exec_module(h)
GAMES = [('Dice 63', h.BLUE), ('Domino 20', {'red': 0.961, 'green': 0.627, 'blue': 0.29}), ('Disney 15', {'red': 0.235, 'green': 0.784, 'blue': 0.706})]
LIGHT = {'red': 0.55, 'green': 0.55, 'blue': 0.55}
# share of paying finishers with a recorded prize: <2 / 2-4 / 4+ days; right label = 2+ days players, % of album revenue
SPLIT = {'Dice 63': ((46, 35, 19), '2+ days: 10,606 players\n7% of album revenue'),
         'Domino 20': ((74, 23, 3), '2+ days: 2,007 players\n3% of album revenue'),
         'Disney 15': ((85, 14, 1), '2+ days: 1,926 players\n1% of album revenue')}
# prize under 2 days: (last week, week after) % of own pace, and who
SMALL = {'Dice 63': [((303, 135), '2,178 · 2% of rev.'), ((209, 110), '2,864 · 6% of rev.')],
         'Domino 20': [((309, 169), '1,158 · 2% of rev.'), ((201, 136), '1,887 · 9% of rev.')],
         'Disney 15': [((291, 175), '2,325 · 1% of rev.'), ((169, 119), '4,300 · 6% of rev.')]}

def split(idx):
    S, X0, W = 't6e_slide', 2.0, 5.5
    msg = 'Half of Dice paying finishers get a prize worth 2+ days of their own play. Domino: 1 in 4. Disney: 1 in 7.'
    R = h.page(S, 'Paying Finishers by Prize Size in Days of Their Own Play',
               'Latest album · prize ÷ the player\'s own play per day in the album (Dice: rolls; Domino, Disney: coins) · % of paying finishers',
               msg, msg_red='Half of Dice paying finishers', idx=idx)
    cols, caps = (LIGHT, h.BLUE, h.RED), ('under 2 days', '2–4 days', '4+ days')
    for k, (c, cap) in enumerate(zip(cols, caps)):
        R += h.rect(S, f'{S}_k{k}', X0 + k * 1.45, 1.27, 0.16, 0.16, c) + h.tbox(S, f'{S}_kt{k}', X0 + 0.2 + k * 1.45, 1.2, 1.2, 0.28, cap, 10, h.GREY)
    for g, (name, _) in enumerate(GAMES):
        y = 1.7 + g * 0.92
        shares, right = SPLIT[name]
        R += h.tbox(S, f'{S}_g{g}', 0.55, y + 0.07, 1.4, 0.36, name, 14, h.WHITE, True)
        x = X0
        for k, v in enumerate(shares):
            w = W * v / 100
            R += h.rect(S, f'{S}_b{g}{k}', x, y, w, 0.5, cols[k])
            if w > 0.4:
                R += h.tbox(S, f'{S}_v{g}{k}', x, y + 0.07, w, 0.36, f'{v}%', 14, h.WHITE, True, 'CENTER')
            x += w
        R += h.tbox(S, f'{S}_r{g}', X0 + W + 0.12, y + 0.02, 1.9, 0.5, right, 9, h.RED if g == 0 else h.GREY)
    return R

def small(idx):
    S, BASE, PER = 't6f_slide', 3.95, 0.0074
    msg = 'With a small prize too, Dice finishers come back the lowest, so the prize is only part of the gap.'
    R = h.page(S, 'Finishers with a Small Prize: Spend per Day Before and After Close',
               'Latest album · paying finishers whose prize is under 2 days of their own play · % of own album pace · grey = last week before close · colour = week after',
               msg, msg_red='Dice finishers come back the lowest', idx=idx, msg_y=4.78)
    levels = ['$2–5 a day', '$5–20 a day']
    for g, (name, col) in enumerate(GAMES):
        px = 0.85 + g * 2.95
        for k, ((last, after), who) in enumerate(SMALL[name]):
            gx = px + k * 1.3
            for j, (v, c) in enumerate(((last, LIGHT), (after, col))):
                x, hgt = gx + j * 0.5, v * PER
                R += h.rect(S, f'{S}_b{g}{k}{j}', x, BASE - hgt, 0.44, hgt, c)
                R += h.tbox(S, f'{S}_v{g}{k}{j}', x - 0.2, BASE - hgt - 0.28, 0.84, 0.26, f'{v}%', 10.5, h.RED if (g == 0 and j == 1) else h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', gx - 0.15, BASE + 0.02, 1.25, 0.22, levels[k], 9.5, h.WHITE, False, 'CENTER')
            R += h.tbox(S, f'{S}_n{g}{k}', gx - 0.15, BASE + 0.2, 1.25, 0.2, who, 7.5, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_g{g}', px - 0.1, BASE + 0.4, 2.5, 0.3, name, 13, h.WHITE, True, 'CENTER')
    y = BASE - 100 * PER
    R += h.rect(S, f'{S}_base', 0.7, BASE, 8.35, 0.012, h.GREY) + h.rect(S, f'{S}_ref', 0.7, y, 8.35, 0.012, h.GOLD)
    R += h.tbox(S, f'{S}_reft', 9.08, y - 0.2, 0.9, 0.4, 'album pace\n= 100%', 8.5, h.GOLD)
    return R

# payers 1-2 short on close-1: (last week, week after) % of own pace, who; spend levels low -> high ($2-5, $5-20, >$20)
SHORT = {'Dice 63': [((159, 100), '6,202 · 4% rev.'), ((125, 86), '5,546 · 10% rev.'), ((85, 68), '1,185 · 8% rev.')],
         'Domino 20': [((153, 119), '3,147 · 4% rev.'), ((107, 96), '2,602 · 10% rev.'), ((68, 71), '356 · 5% rev.')],
         'Disney 15': [((217, 138), '4,278 · 2% rev.'), ((134, 100), '5,912 · 7% rev.'), ((90, 76), '1,664 · 7% rev.')]}

def short(idx):
    S, BASE, PER = 't6g_slide', 3.95, 0.0105
    msg = 'Over $20 a day, payers 1–2 short slow down further after close in Dice and Disney: 7–8% of album revenue.'
    R = h.page(S, 'Payers 1–2 Stickers Short: Spend per Day Before and After Close',
               'Latest album · paying players 1–2 stickers short the day before close · % of own album pace · grey = last week before close · colour = week after',
               msg, msg_red='slow down further after close in Dice and Disney', idx=idx, msg_y=4.78)
    levels = ['$2–5', '$5–20', '>$20']
    for g, (name, col) in enumerate(GAMES):
        px = 0.75 + g * 2.8
        for k, ((last, after), who) in enumerate(SHORT[name]):
            gx = px + k * 0.85
            for j, (v, c) in enumerate(((last, LIGHT), (after, col))):
                x, hgt = gx + j * 0.36, v * PER
                R += h.rect(S, f'{S}_b{g}{k}{j}', x, BASE - hgt, 0.32, hgt, c)
                red = j == 1 and k == 2 and g != 1
                R += h.tbox(S, f'{S}_v{g}{k}{j}', x - 0.2, BASE - hgt - 0.27, 0.74, 0.25, f'{v}%', 9.5, h.RED if red else h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', gx - 0.13, BASE + 0.02, 0.94, 0.22, levels[k], 9.5, h.WHITE, False, 'CENTER')
            R += h.tbox(S, f'{S}_n{g}{k}', gx - 0.13, BASE + 0.2, 0.94, 0.2, who, 7, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_g{g}', px - 0.15, BASE + 0.4, 2.7, 0.3, name, 13, h.WHITE, True, 'CENTER')
    y = BASE - 100 * PER
    R += h.rect(S, f'{S}_base', 0.7, BASE, 8.35, 0.012, h.GREY) + h.rect(S, f'{S}_ref', 0.7, y, 8.35, 0.012, h.GOLD)
    R += h.tbox(S, f'{S}_reft', 9.08, y - 0.2, 0.9, 0.4, 'album pace\n= 100%', 8.5, h.GOLD)
    return R

# slide-36 measure by close status (close-1), latest album: payout change % (days 1-3 vs mid-album, median player), week after % of own pace
STATUS = {'Dice 63': [(5, 103), (5, 87), (4, 75), (6, 55)],
          'Domino 20': [(-18, 124), (-12, 104), (-8, 92), (-4, 62)],
          'Disney 15': [(-11, 107), (-5, 98), (1, 77), (4, 66)]}

def status(idx):
    S, ZERO, PER = 't6h_slide', 2.35, 0.045
    msg = 'In Domino and Disney the payout drops most for finishers, who come back the best. Players far from 144 get little or no drop and come back the worst.'
    R = h.page(S, 'Payout After Close and Spend in the Week After, by Close Status',
               'Latest album · paying players · bars = payout in days 1–3 after close vs mid-album (median player) · numbers = week-after spend vs own pace',
               msg, msg_red='Players far from 144 get little or no drop and come back the worst.', idx=idx, msg_y=4.6)
    caps = ['Finished', '1–2 short', '3 short', '4+ short']
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.25, 2.85, 0.32, name, 14, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.12, ZERO, 2.61, 0.012, h.GREY)
        for k, (chg, after) in enumerate(STATUS[name]):
            x = px + 0.2 + k * 0.66
            hgt = max(abs(chg) * PER, 0.02)
            y = ZERO - hgt if chg >= 0 else ZERO
            R += h.rect(S, f'{S}_b{g}{k}', x, y, 0.46, hgt, col)
            ly = y - 0.27 if chg >= 0 else ZERO + hgt + 0.02
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.15, ly, 0.76, 0.25, f'{chg:+d}%', 10.5, h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', x - 0.15, 3.48, 0.76, 0.22, caps[k], 8.5, h.GREY, False, 'CENTER')
            red = after < 80
            R += h.tbox(S, f'{S}_a{g}{k}', x - 0.15, 3.72, 0.76, 0.3, f'{after}%', 13, h.RED if red else h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_al{g}', px, 4.02, 2.85, 0.22, 'week after, % of own pace', 8, h.GREY, False, 'CENTER')
    return R

# payout LEVEL in days 1-3 after close, whole group (sum won / sum spent on play, all sources), by close status, latest album
LEVEL = {'Dice 63': [77, 83, 88, 88], 'Domino 20': [64, 68, 71, 73], 'Disney 15': [59, 65, 72, 78]}

def level(idx):
    S, BASE, PER = 't6i_slide', 3.45, 0.019
    msg = 'After close, finishers get the least back from the game in all three games, and still spend the most (t6h).'
    R = h.page(S, 'Payout in Days 1–3 After Close, by Close Status',
               'Latest album · paying players · whole group: coins won ÷ coins spent on play (Dice: rolls) · each game has its own formula: compare within a game',
               msg, msg_red='finishers get the least back from the game', idx=idx, msg_y=4.6)
    caps = ['Finished', '1–2 short', '3 short', '4+ short']
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.2, 2.85, 0.3, name, 14, h.WHITE, True, 'CENTER')
        for k, v in enumerate(LEVEL[name]):
            x, hgt = px + 0.2 + k * 0.66, v * PER
            R += h.rect(S, f'{S}_b{g}{k}', x, BASE - hgt, 0.46, hgt, col)
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.15, BASE - hgt - 0.27, 0.76, 0.25, f'{v}%', 11, h.RED if k == 0 else h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', x - 0.15, BASE + 0.05, 0.76, 0.22, caps[k], 8.5, h.GREY, False, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.12, BASE, 2.61, 0.012, h.GREY)
    return R

# finishers $2-20 a day: payout change days 1-3 vs own mid-album (median player), week after vs own pace (s6c), payout level after close (all paying: finishers vs all)
STORY = {'Dice 63': (5, 110, 77, 84), 'Domino 20': (-18, 140, 64, 70), 'Disney 15': (-12, 128, 59, 73)}

def story(idx):
    S, ZERO, PER = 't6j_slide', 2.35, 0.03
    msg = 'Dice finishers get more back from the game after close and come back the slowest; in Domino and Disney they get less and come back faster.'
    R = h.page(S, 'Finishers: Payout After Close and Spend in the Week After',
               'Latest album · paying finishers, $2–20 a day · bar = payout in days 1–3 of the next album vs the same player mid-album (median player)',
               msg, msg_red='come back the slowest', idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        chg, after, lv_f, lv_all = STORY[name]
        px = 0.55 + g * 3.05
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.22, 2.85, 0.3, name, 14, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.4, ZERO, 2.05, 0.012, h.GREY)
        hgt = abs(chg) * PER
        y = ZERO - hgt if chg >= 0 else ZERO
        R += h.rect(S, f'{S}_b{g}', px + 0.97, y, 0.9, hgt, col)
        ly = y - 0.33 if chg >= 0 else ZERO + hgt + 0.02
        R += h.tbox(S, f'{S}_v{g}', px + 0.62, ly, 1.6, 0.32, f'{chg:+d}% payout', 13, h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_a{g}', px, 3.3, 2.85, 0.42, f'{after}%', 24, h.RED if g == 0 else h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_al{g}', px, 3.7, 2.85, 0.22, 'spend in the week after, % of own pace', 8.5, h.GREY, False, 'CENTER')
        R += h.tbox(S, f'{S}_lv{g}', px, 3.98, 2.85, 0.3, f'Payout after close: finishers {lv_f}% · all players {lv_all}%', 8.5, h.GREY, False, 'CENTER')
    return R

NOTES = {
 't6e_slide': """Paying finishers (standard population, 144 stickers on close−1), latest album: Dice 63 (19,688), Domino 20 (8,071), Disney 15 (12,613).
Prize in days of own play = the album prize ÷ the player's own play per day in the album (album start to close−1). Dice: album_reward_value (rolls) ÷ rolls played per day. Domino and Disney: 'album completed' coins ÷ coins spent per day (Mixpanel coins in / out, staging views). Same measure in all three games; the cut-offs 2 and 4 days are my choice (round numbers, as in t7b).
Median prize: Dice 2.2 days, Domino 1.3, Disney 1.1. Album 61 / 19: Dice 2.2, Domino 1.0 (same picture).
2+ days: Dice 63 10,606 players = 5% of paying players, 7% of album revenue (2–4 days: 6,884 · 5%; 4+: 3,722 · 2%). Domino 20: 2,007 = 2% of payers, 3% of revenue. Disney 15: 1,926 = 0.6% of payers, 0.7% of revenue.
% shown = of paying finishers with a recorded prize. No prize found: Domino 20 443 (5%), Disney 15 58, Dice 0.
Why Dice is different: the Dice prize is a fixed ladder (25K–200K rolls) set from past spend and never goes down (game rule). Domino and Disney (data): the prize is about 1 day of play for most paying finishers (median 1.3 / 1.1 days).
Revenue % = share of all paying players' album revenue (album start to close−1).""",
 't6f_slide': """Paying finishers whose prize is under 2 days of their own play (so the prize cannot explain a slow return). Spend per day as % of own album pace (album $ a day before the last quarter): last week = close−7..close−1, week after = close+1..close+7 (next album days 2–8). Group totals.
$2–5 a day: Dice 63 303% → 135% (2,178 players, 1.7% of album revenue); Domino 20 309% → 169% (1,158, 2.0%); Disney 15 291% → 175% (2,325, 1.2%).
$5–20 a day: Dice 63 209% → 110% (2,864, 6.1%); Domino 20 201% → 136% (1,887, 9.2%); Disney 15 169% → 119% (4,300, 5.9%).
Bought in the week after ($2–5 / $5–20): Dice 70% / 80%, Domino 75% / 86%, Disney 76% / 86%.
Previous album: Dice 61 309% → 158% and 210% → 119%; Domino 19 355% → 181% and 207% → 127%. Dice is below Domino at $2–5 and $5–20 in both albums (Disney 14 not run: 490 GB); at $5–20 Dice 61 equals Disney 15 (119%). Album 63 was weak at every spend level (topic7-top-payers-2026-10-24.md), so part of the 63 gap is that album.
Fact: same push in the last week, smaller return in Dice, also without a big prize. Interpretation: something in how Dice starts the next album (not tested here) adds to the prize effect. Hypothesis only; next step = compare the first days of the next album (gates, roll stock, offers) across games.
Big prize (2+ days) inside Dice: see t7b (fewer buyers the bigger the prize, ≤$5 a day payers).""",
 't6g_slide': """Paying players 1–2 stickers short on the day before close (142–143 stickers on close−1), standard population, latest album. Spend per day as % of own album pace (album $ a day before the last quarter): last week = close−7..close−1, week after = close+1..close+7 (next album days 2–8). Group totals.
All spend levels, latest album: Dice 63 29,743 players (15% of payers, 24% of album revenue), Domino 20 13,687 (13%, 22%), Disney 15 17,183 (5%, 17%). Week after: Dice 87%, Domino 104%, Disney 98% of pace.
≤$2 a day (not shown, 1–3% of revenue): Dice 63 270% → 146%, Domino 20 236% → 180%, Disney 15 418% → 238%.
>$20 a day, previous album: Dice 61 84% → 80%, Domino 19 84% → 73%, Disney 14 87% → 80%. Domino 20 (68% → 71%) is the exception.
Close day: only 7–11% of them finish on the close day (Dice 63 9%, Domino 20 7%, Disney 15 11%). Their week after is about the same as those who stay short (Dice 84% vs 87%, Domino 106% vs 103%; Disney 109% vs 96%).
Payout after close (Part 1, slide 36, median player, days 1–3 of the next album vs mid-album): 1–2 short (status at the end of the close day there) get Dice +2% to +5%, Domino −4% to −12%, Disney −3% to −12%. Dice has no payout drop but the weakest return, so across games the lower payout does not line up with a weaker return. Within-game check (run 2026-10-24): week after for payout lower / same / higher (days 1–3 vs mid-album, own payout): Dice 87% / 111% / 70%, Domino 108% / 113% / 95%, Disney 107% / 107% / 82%. The group whose payout rose spends the least in every game, so a lower payout does not go with lower spend; the ratio moves with how the player plays. Only a test can isolate the payout effect. Soft landing for this group: do not adopt.
Not the same cut as Part 1 slide 34 ($20+ payers 2–3 short at the end of the close day, last 4 days vs usual spend): there the week after is a partial recovery from the last 4 days; here it is lower than the last 7 days. Both can be true (the last 4 days are the lowest).
Revenue % = share of all paying players' album revenue (album start to close−1).""",
 't6h_slide': """Same measure as Part 1 slide 36 for every close status: own payout in days 1–3 of the next album ÷ own payout mid-album (close−18..−5), album prizes left out, median across players who played in both windows (Dice: rolls; Domino, Disney: coins; Mixpanel definitions as in slide 36). Status on the day before close (as s6c/s6d), latest album, all paying players. Week after = spend close+1..close+7 vs own album pace.
Payout change (finished / 1–2 / 3 / 4+ short): Dice 63 +5 / +5 / +4 / +6%; Domino 20 −18 / −12 / −8 / −4%; Disney 15 −11 / −5 / +1 / +4%. Share of players whose payout fell: Domino 82 / 73 / 66 / 57%, Disney 72 / 60 / 48 / 41%, Dice 38 / 36 / 36 / 36%.
Week after: Dice 103 / 87 / 75 / 55%; Domino 124 / 104 / 92 / 62%; Disney 107 / 98 / 77 / 66%.
$2–20 a day only: same pattern (payout Domino −18 / −12 / −7 / −5%, Disney −12 / −5 / +1 / +7%, Dice +5% everywhere).
Check: finishers match slide 36 (status at end of close day there): Dice 1.05 vs 1.04, Domino 0.82 vs 0.81, Disney 0.89 vs 0.87.
Players: Dice 19,688 / 29,743 / 76,491 / 65,898; Domino 8,071 / 13,687 / 24,642 / 53,515; Disney 12,613 / 17,183 / 29,956 / 245,055.
Fact: in Domino and Disney the payout drop after close is largest for finishers and shrinks with distance from 144; the groups with the biggest drop come back the best. Dice has no drop in any group.
Interpretation: the drop is real (the payout level after close is the lowest for finishers, t6i; mid-album the groups were close), but it does not slow them: they spend the most. It does not explain the weak return of players far from 144 (they had already slowed before close, s6d). Soft landing after close: no support as a revenue lever from this data; only a test can tell.""",
 't6i_slide': """Payout level (not the change) in days 1–3 of the next album, whole group: everything won from the game ÷ everything spent on play (Mixpanel definitions as slide 36; all sources incl. album prizes, which are almost zero in those days). Status on the day before close, latest album, paying players who played in those days.
Group level (finished / 1–2 / 3 / 4+ short): Dice 63 77 / 83 / 88 / 88%; Domino 20 64 / 68 / 71 / 73%; Disney 15 59 / 65 / 72 / 78%. All groups together: Dice 84%, Domino 70%, Disney 73%.
Median player: Dice 88 / 89 / 90 / 90% (flat; the group gap comes from heavy players); Domino 59 / 62 / 65 / 66%; Disney 61 / 67 / 74 / 74%.
Mid-album, same groups (close−18..−5, all sources): Dice 84 / 86 / 89 / 89%; Domino 76 / 78 / 78 / 79%; Disney 68 / 71 / 73 / 76%. So in Domino the groups were about equal mid-album and the gap opens after close; in Disney finishers were a little lower mid-album and the gap widens.
$2–20 a day: same order (Domino 64 / 66 / 68 / 68%, Disney 61 / 66 / 71 / 73%, Dice 80 / 83 / 87 / 85%).
Levels are not comparable across games (each game's payout formula is different).
Fact: after close the players who finished get the lowest payout of all groups, most clearly in Domino and Disney, and they still spend the most in the week after (t6h). Why finishers get less is not tested (hypothesis: they play differently at the start of the new album, e.g. bigger stakes or more boosters).""",
 't6j_slide': """Paying finishers (144 on close−1), $2–20 a day, latest album. Bar = median player's own payout in days 1–3 of the next album ÷ own payout mid-album (close−18..−5), album prizes left out (Part 1 slide 36 measure): Dice +5%, Domino −18%, Disney −12%. This change is comparable across games because each player is compared with himself.
Week after = spend close+1..close+7 vs own album pace (s6c): Dice 110%, Domino 140%, Disney 128% (last week before close: 229% / 217% / 188%).
Bottom line in each panel = payout level in days 1–3 after close, all paying players (t6i): finishers vs all players of the same game. Compare only within a game: each game's payout formula is different, so Dice 77% is not "more" than Domino 64%.
Same direction for payers 1–2 short: payout Dice +5%, Domino −12%, Disney −5%; week after ($2–20) 90% / 103% / 108%.
Fact: the game with no payout drop after close (Dice) has the slowest return; the two games with a drop have a faster return. Two albums of data per game would be stronger; this is the latest album only.
Interpretation (hypothesis, not tested): in Dice the player keeps getting a lot back after close, so the roll stock lasts longer and the next purchase waits. Domino and Disney make the start of the new album tighter, so players burn their stock and buy sooner.
Caveat: inside each game, players whose payout fell did not spend more (topic6-short-payers, payout split). So the cross-game pattern is a lead, not proof.
Recommendation: TEST in Dice: a tighter payout in days 1–3 of the new album for finishers and players 1–2 short (closer to Domino / Disney), Control = today. Main measure: % who buy and spend vs own pace in the first 7 days; guardrails: next-album spend over 14 days, finish rate, churn. Do not adopt without the test."""
}

if __name__ == '__main__':
    if sys.argv[1] == 'notes': print(json.dumps(NOTES, ensure_ascii=False))
    else: print(json.dumps({'e': split, 'f': small, 'g': short, 'h': status, 'i': level, 'j': story}[sys.argv[1]](int(sys.argv[2]) if len(sys.argv) > 2 else None), ensure_ascii=False, separators=(',', ':')))
