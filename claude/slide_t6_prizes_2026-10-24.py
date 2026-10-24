"""ALBUM END: payout WITH album prizes (Eden 2026-10-24) + total game revenue after close.
t6k = finishers by spend level, t6l = payers 1-2 short by spend level: payout change days 1-3 vs mid-album (whole group, album prizes included) + week after vs own pace.
tg1 = total game revenue in the week after close vs the last 30 days, two albums per game.
t6j_edit = in-place update of t6j to the with-prize numbers (no deletes: text replace + bar transforms).
Data: claude/topic6-payout-prizes-by-level-2026-10-24.md, claude/topic6-game-revenue-after-close-2026-10-24.md.
Usage (from claude/): python3 slide_t6_prizes_2026-10-24.py <t6k|t6l|tg1|t6j_edit|notes> [insertionIndex]"""
import json, sys, importlib.util as u
s = u.spec_from_file_location('h', 'slide_t7_dice_prize_2026-10-25.py'); h = u.module_from_spec(s); s.loader.exec_module(h)
GAMES = [('Dice 63', h.BLUE), ('Domino 20', {'red': 0.961, 'green': 0.627, 'blue': 0.29}), ('Disney 15', {'red': 0.235, 'green': 0.784, 'blue': 0.706})]
LIGHT = {'red': 0.55, 'green': 0.55, 'blue': 0.55}
LEVELS = ['≤$2', '$2–5', '$5–20', '>$20']
# (payout change % days 1-3 vs mid-album, whole group, prizes in; week after % of own pace), by spend level
FIN = {'Dice 63': [(-14, 201), (-10, 123), (-5, 105), (-2, 85)],
       'Domino 20': [(-18, 279), (-19, 167), (-16, 134), (-12, 101)],
       'Disney 15': [(-22, 334), (-20, 172), (-14, 119), (-8, 86)]}
SHORT = {'Dice 63': [(-6, 146), (-5, 100), (-2, 86), (2, 68)],
         'Domino 20': [(-13, 180), (-13, 119), (-11, 96), (-9, 71)],
         'Disney 15': [(-14, 238), (-11, 138), (-9, 100), (-5, 76)]}

def by_level(S, data, title, sub, msg, red, idx):
    ZERO, PER = 1.95, 0.045
    R = h.page(S, title, sub, msg, msg_red=red, idx=idx, msg_y=4.6)
    for g, (name, col) in enumerate(GAMES):
        px = 0.55 + g * 3.05
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.25, 2.85, 0.32, name, 14, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_z{g}', px + 0.12, ZERO, 2.61, 0.012, h.GREY)
        for k, (chg, after) in enumerate(data[name]):
            x = px + 0.2 + k * 0.66
            hgt = max(abs(chg) * PER, 0.02)
            y = ZERO - hgt if chg >= 0 else ZERO
            R += h.rect(S, f'{S}_b{g}{k}', x, y, 0.46, hgt, col)
            ly = y - 0.27 if chg >= 0 else ZERO + hgt + 0.02
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.15, ly, 0.76, 0.25, f'{chg:+d}%', 10.5, h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', x - 0.15, 3.42, 0.76, 0.22, LEVELS[k], 8.5, h.GREY, False, 'CENTER')
            R += h.tbox(S, f'{S}_a{g}{k}', x - 0.15, 3.66, 0.76, 0.3, f'{after}%', 13, h.RED if after < 100 else h.WHITE, True, 'CENTER')
        R += h.tbox(S, f'{S}_al{g}', px, 3.98, 2.85, 0.22, 'week after, % of own pace', 8, h.GREY, False, 'CENTER')
    return R

def t6k(idx=None):
    return by_level('t6k_slide', FIN, 'Finishers by Spend Level: Payout After Close and Week After',
        'Latest album · paying finishers · bars = payout in days 1–3 of the next album vs mid-album, album prizes included (whole group) · numbers = week-after spend vs own pace',
        'At every spend level finishers get less back after close in all three games. Dice cuts the least and its finishers come back the least.',
        'Dice cuts the least and its finishers come back the least.', idx)

def t6l(idx=None):
    return by_level('t6l_slide', SHORT, '1–2 Short by Spend Level: Payout After Close and Week After',
        'Latest album · paying players 1–2 short on close−1 · bars = payout days 1–3 vs mid-album, prizes included (whole group) · numbers = week after vs own pace',
        'Same pattern for players 1–2 short: Dice cuts the least (−6% to +2%) and they come back the least at every spend level.',
        'Dice cuts the least (−6% to +2%) and they come back the least', idx)

# total game revenue, days 1-7 after close / average day close-30..-1: (previous album, latest album)
REV = {'Dice': (('61', 112), ('63', 92)), 'Domino': (('19', 95), ('20', 110)), 'Disney': (('14', 96), ('15', 103))}

def tg1(idx=None):
    S, BASE, PER = 'tg1_slide', 3.9, 0.015
    msg = 'Week after close vs the last month: Dice was the best close in album 61 (112%) and the worst in album 63 (92%). Over two albums the three games are about equal.'
    R = h.page(S, 'Total Game Revenue in the Week After Close vs the Last 30 Days',
               'Two albums per game · all players\' purchase revenue a day, close+1..+7 ÷ close−30..−1 (close day left out) · excluded users out',
               msg, msg_red='the worst in album 63 (92%)', idx=idx, msg_y=4.6)
    for g, ((name, vals), (_, col)) in enumerate(zip(REV.items(), GAMES)):
        px = 0.55 + g * 3.05
        R += h.rect(S, f'{S}_p{g}', px, 1.2, 2.85, 3.15, h.CARD)
        R += h.tbox(S, f'{S}_g{g}', px, 1.25, 2.85, 0.32, name, 14, h.WHITE, True, 'CENTER')
        R += h.rect(S, f'{S}_l{g}', px + 0.2, BASE - 100 * PER, 2.45, 0.012, h.GREY)
        R += h.tbox(S, f'{S}_k{g}', px + 0.12, BASE - 100 * PER - 0.22, 0.6, 0.2, '100%', 7.5, h.GREY)
        for k, (alb, v) in enumerate(vals):
            x, hgt = px + 0.55 + k * 1.05, v * PER
            R += h.rect(S, f'{S}_b{g}{k}', x, BASE - hgt, 0.7, hgt, LIGHT if k == 0 else col)
            vy = BASE - hgt + 0.03 if v < 100 else BASE - hgt - 0.3   # under 100%: label inside the bar (clear of the 100% line)
            R += h.tbox(S, f'{S}_v{g}{k}', x - 0.2, vy, 1.1, 0.28, f'{v}%', 13, h.WHITE, True, 'CENTER')
            R += h.tbox(S, f'{S}_c{g}{k}', x - 0.2, BASE + 0.04, 1.1, 0.22, f'album {alb}', 9, h.GREY, False, 'CENTER')
    return R

# t6j in place: all paying finishers, payout with album prizes (whole group), week after vs own pace
T6J = [(-8, 103), (-16, 124), (-14, 107)]
OLD_V, OLD_A = ['+5% payout', '-18% payout', '-12% payout'], ['110%', '140%', '128%']
BX = [1389888, 4178807, 6967727]; VX = [1074423, 3858768, 6647688]

def t6j_edit(idx=None):
    S, ZERO, PER, E = 't6j_slide', 2.35, 0.03, h.E
    R = []
    rep = lambda a, b: {'replaceAllText': {'containsText': {'text': a, 'matchCase': True}, 'replaceText': b, 'pageObjectIds': [S]}}
    R.append(rep('payout in days 1–3 of the next album vs the same player mid-album (median player)',
                 'all paying finishers · payout in days 1–3 of the next album vs mid-album, album prizes included (whole group)'))
    for g, (chg, after) in enumerate(T6J):
        R.append(rep(OLD_V[g], f'{chg:+d}% payout'))
        R.append(rep(OLD_A[g], f'{after}%'))
        hgt = abs(chg) * PER
        R.append({'updatePageElementTransform': {'objectId': f'{S}_b{g}', 'applyMode': 'ABSOLUTE', 'transform': {
            'scaleX': 0.2743, 'scaleY': round(hgt * E / 3000000, 6), 'shearX': 0, 'shearY': 0, 'translateX': BX[g], 'translateY': int(ZERO * E), 'unit': 'EMU'}}})
        R.append({'updatePageElementTransform': {'objectId': f'{S}_v{g}', 'applyMode': 'ABSOLUTE', 'transform': {
            'scaleX': 0.4877, 'scaleY': 0.0975, 'shearX': 0, 'shearY': 0, 'translateX': VX[g], 'translateY': int((ZERO + hgt + 0.02) * E), 'unit': 'EMU'}}})
    msg = 'After close, finishers get less back in every game. Dice cuts the least (−8% vs −16% / −14%) and its finishers come back the slowest.'
    R.append({'deleteText': {'objectId': f'{S}_ms', 'textRange': {'type': 'ALL'}}})
    R.append({'insertText': {'objectId': f'{S}_ms', 'text': msg}})
    R.append({'updateTextStyle': {'objectId': f'{S}_ms', 'textRange': {'type': 'ALL'}, 'style': {'fontFamily': 'Oswald', 'bold': False, 'fontSize': {'magnitude': 11, 'unit': 'PT'}, 'foregroundColor': {'opaqueColor': {'rgbColor': h.WHITE}}}, 'fields': 'fontFamily,bold,fontSize,foregroundColor'}})
    R += h.red_part(f'{S}_ms', msg, 'Dice cuts the least (−8% vs −16% / −14%)')
    return R

NOTES = {
 't6j_slide': """All paying finishers (144 stickers on close−1, standard population), latest album: Dice 63 (19,688 · 28% of album revenue), Domino 20 (8,071 · 31%), Disney 15 (12,613 · 18%).
Bar = payout in days 1–3 of the next album vs mid-album (close−18..−5), album prizes INCLUDED (Eden 2026-10-24: prizes are rolls/coins the player gets from the game), whole group = sum won ÷ sum spent on play (Mixpanel style). Dice: rolls in without RV / timer / gifts − bought ÷ rolls bet; Domino: coins won ÷ level start + boosters; Disney: coins won ÷ level start + boosters. Dice −8%, Domino −16%, Disney −14%.
Week after = spend close+1..+7 vs own album pace: Dice 103%, Domino 124%, Disney 107%.
Bottom line = payout level in days 1–3 after close, all paying players (t6i): finishers vs all players of the same game. Compare levels only within a game (different formulas).
Earlier version of this slide used the median player without album prizes (Dice +5%, Domino −18%, Disney −12%). With prizes and the whole group, Dice also drops, but it is still the smallest drop, at every spend level (t6k).
Same pattern for payers 1–2 short (t6l): Dice −3%, Domino −12%, Disney −9%; week after 87% / 104% / 98%.
Previous album: Dice 61 finishers dropped more (−18%, status at the end of the close day) and came back better (129%) than Dice 63 (−12%, 110%). This fits the payout story, but it is two albums.
Caveat: inside each game, players whose own payout fell did not spend more (topic6-short-payers, payout split), and stock, free inflow and the share who buy are the same across games (topic6-stock / free-inflow / buyers docs). The cross-game pattern is a lead, not proof.
Recommendation: TEST in Dice: a tighter payout in days 1–3 of the new album for finishers and players 1–2 short (closer to Domino / Disney), Control = today. Main measure: spend vs own pace in days 1–7; guardrails: next-album spend over 14 days, finish rate, churn. Re-check with Dice 65 after 2026-10-27 before starting.""",
 't6k_slide': """Paying finishers (144 on close−1), latest album, by spend level (album $ a day before the last quarter). Bars = payout days 1–3 after close vs mid-album (close−18..−5), album prizes included, whole group. Numbers = week-after spend vs own pace (close+1..+7).
Dice 63: ≤$2 −14% · 201% (8,652 · 3% of album revenue); $2–5 −10% · 123% (5,007 · 4%); $5–20 −5% · 105% (4,572 · 9%); >$20 −2% · 85% (1,457 · 12%).
Domino 20: ≤$2 −18% · 279% (3,138 · 2%); $2–5 −19% · 167% (1,673 · 3%); $5–20 −16% · 134% (2,352 · 11%); >$20 −12% · 101% (908 · 15%).
Disney 15: ≤$2 −22% · 334% (3,226 · 0.7%); $2–5 −20% · 172% (2,904 · 2%); $5–20 −14% · 119% (4,594 · 6%); >$20 −8% · 86% (1,889 · 10%).
Fact: at every spend level Dice has the smallest payout drop and the lowest week after. Fact: inside every game the drop is smaller for heavier payers, who also come back less (different players, not cause and effect).
Revenue % = share of all paying players' album revenue (album start to close−1). SQL: claude/topic6_payout_prizes_by_level_2026-10-24.sql.""",
 't6l_slide': """Paying players 1–2 stickers short on close−1 (142–143), latest album, by spend level. Same measures as t6k.
Dice 63: ≤$2 −6% · 146% (16,811 · 3% of album revenue); $2–5 −5% · 100% (6,201 · 4%); $5–20 −2% · 86% (5,546 · 10%); >$20 +2% · 68% (1,185 · 8%).
Domino 20: ≤$2 −13% · 180% (7,582 · 3%); $2–5 −13% · 119% (3,147 · 4%); $5–20 −11% · 96% (2,602 · 10%); >$20 −9% · 71% (356 · 5%).
Disney 15: ≤$2 −14% · 238% (5,329 · 0.9%); $2–5 −11% · 138% (4,278 · 2%); $5–20 −9% · 100% (5,912 · 7%); >$20 −5% · 76% (1,664 · 7%).
All spend levels: Dice −3% · 87%, Domino −12% · 104%, Disney −9% · 98%.
Fact: Dice has the smallest drop and the lowest week after at every spend level. Within each game the earlier player-level split found no link (topic6-short-payers), so this is a cross-game lead only.""",
 'tg1_slide': """Total game revenue = all players' purchase revenue a day from daily metrics (deck-wide definition, game_revenue_rebase_queries.sql), excluded / cheater / test users out. Base = average day close−30..close−1 (close day left out, half day).
Days 1–7 after close: Dice 61 112% / 63 92%; Domino 19 95% / 20 110%; Disney 14 96% / 15 103%. Two-album average: Dice 102%, Domino 102%, Disney 99%.
Days 1–3: Dice 99% / 85%; Domino 85% / 94%; Disney 80% / 96%. Last week before close: Dice 105% / 107%; Domino 98% / 108%; Disney 91% / 96%.
Base $ a day: Dice $732K / $707K; Domino $358K / $328K; Disney $1.21M / $1.06M. Close dates: Dice 2026-07-27 / 09-07; Domino 08-24 / 10-12; Disney 08-24 / 10-05.
Fact: Dice swings from best to worst between two albums. All finisher slides that follow use the latest album (Dice 63, the weak close).
Hypothesis (not tested): Dice 63 closed on US Labor Day (Monday 2026-09-07); other live events may also differ. In Dice 61 finishers' payout dropped more after close (−18% vs −12%), which fits the payout lead on t6j–t6l.
SQL: claude/topic6_game_revenue_after_close_2026-10-24.sql."""
}

if __name__ == '__main__':
    if sys.argv[1] == 'notes': print(json.dumps(NOTES, ensure_ascii=False))
    else: print(json.dumps(globals()[sys.argv[1]](int(sys.argv[2]) if len(sys.argv) > 2 else None), ensure_ascii=False, separators=(',', ':')))
