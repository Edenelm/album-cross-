"""ehgapday_slide: gl1_slide design for Domino 20 Easy payers only: finishers vs payers who end 4+ away, % of each sticker type held by % of album time.
Source: claude/domino-easy-gap-by-day-2026-10-27.md | SQL: claude/domino_easy_gap_by_day_2026-10-27.sql
Usage: python3 claude/slide_domino_easy_gap_2026-10-27.py <insertion_index>"""
import json, sys, importlib.util
spec = importlib.util.spec_from_file_location('ch', __file__.replace('slide_domino_easy_gap_2026-10-27.py', 'slide_domino_chapter_2026-10-26.py'))
ch = importlib.util.module_from_spec(spec); spec.loader.exec_module(ch)
spec2 = importlib.util.spec_from_file_location('rl', __file__.replace('slide_domino_easy_gap_2026-10-27.py', 'slide_domino_royals_line_2026-10-27.py'))
rl = importlib.util.module_from_spec(spec2); spec2.loader.exec_module(rl)
WHITE, GOLD, GREY, DGREY, ORANGE, RED = ch.WHITE, ch.GOLD, ch.GREY, ch.DGREY, ch.ORANGE, ch.RED
N = {'Commons': 107, 'Goldens': 28, 'Royals': 9}
# album days 1,5,10,...,49 = start, 10%..100% (49-day album); finisher, far
D = {'Commons': ([14.1, 37.4, 55.0, 69.9, 80.0, 92.3, 99.5, 103.3, 106.0, 106.7, 107.0], [12.5, 33.8, 50.3, 63.5, 74.8, 85.4, 91.9, 96.7, 101.2, 103.4, 104.8]),
     'Goldens': ([0.53, 1.63, 3.01, 4.82, 7.35, 12.67, 15.26, 18.13, 23.07, 24.26, 28.0], [0.46, 1.40, 2.55, 3.54, 5.53, 9.81, 12.48, 15.60, 19.83, 20.96, 22.98]),
     'Royals': ([0.28, 0.40, 0.93, 1.56, 1.86, 3.21, 4.0, 4.88, 5.82, 6.3, 9.0], [0.25, 0.33, 0.58, 0.84, 0.99, 1.92, 2.38, 2.89, 3.67, 4.11, 4.66])}
def build(idx):
    S = ch.Slide('ehgapday_slide', idx)
    S.text(0.5, 0.2, 9.0, 0.5, '% of Each Sticker Type Held by Album Time: Easy Finishers vs Easy Payers Who End 4+ Away', 20, WHITE)
    S.text(0.5, 0.68, 9.0, 0.28, 'Domino 20 · Easy, standard-population payers · average player · finishers = 144 on close−1 · far = 140 or fewer on close−1', 9.5, GREY)
    S.rect(0.6, 1.08, 0.3, 0.05, ORANGE); S.text(0.95, 0.98, 3.6, 0.25, 'Easy finishers · 6,092 · 6% of payers · 10% of album revenue', 8.5, GREY)
    S.rect(4.75, 1.08, 0.3, 0.05, '#9e9e9e'); S.text(5.1, 0.98, 4.4, 0.25, 'Easy payers who end 4+ away · 55,712 · 52% of payers · 15% of album revenue', 8.5, GREY)
    for k, (name, (fin, far)) in enumerate(D.items()):
        px0 = 0.5 + k * 3.05
        S.panel(px0, 1.35, 2.85, 2.9, f'{name} · {N[name]} in the album')
        X0, X1, YB, YT = px0 + 0.35, px0 + 2.6, 3.85, 1.85
        S.rect(X0 + (X1 - X0) * 0.7, YT - 0.05, (X1 - X0) * 0.3, YB - YT + 0.05, '#2e2b26', tag='sh')
        def px(t): return X0 + (X1 - X0) * t / 100
        def py(v): return YB - (YB - YT) * v / 100
        for v in (0, 100):
            rl.line(S, X0, py(v), X1, py(v), '#333333', 0.5)
            S.text(px0 + 0.02, py(v) - 0.1, 0.32, 0.2, f'{v}%', 7, DGREY, align='END')
        for t, lab in ((0, 'Start'), (50, '50%'), (100, 'Close')):
            S.text(px(t) - 0.3, YB + 0.03, 0.6, 0.2, lab, 7, DGREY, align='CENTER')
        for vals, col in ((far, '#9e9e9e'), (fin, ORANGE)):
            p = [100 * v / N[name] for v in vals]
            K = (0, 1, 3, 5, 7, 9, 10)  # start, 10/30/50/70/90%, close
            for a_, b_ in zip(K, K[1:]):
                rl.line(S, px(a_ * 10), py(p[a_]), px(b_ * 10), py(p[b_]), col, 2)
        for t, i in ((50, 5), (100, 10)):
            a, b = 100 * fin[i] / N[name], 100 * far[i] / N[name]
            rl.line(S, px(t), py(a), px(t), py(b), WHITE, 1)
            g = round(a - b)
            S.text(px(t) - (0.62 if t == 100 else -0.04), (py(a) + py(b)) / 2 - 0.1, 0.6, 0.22, f'{g} pts', 9,
                   RED if (name != 'Commons' and t == 100) else WHITE, bold=True, align='END' if t == 100 else 'START')
    S.text(0.5, 4.45, 9.0, 0.5, 'Easy payers who end far fall behind from the first days; they catch up on commons (98% held), but the Golden and Royal gap keeps growing to the end.', 11, WHITE,
           spans=[('fall behind from the first days', GOLD), ('the Golden and Royal gap keeps growing to the end', RED)])
    S.text(7.78, 5.25, 1.72, 0.25, 'SuperPlay 2026', 8, DGREY)
    return S
if __name__ == '__main__':
    S = build(int(sys.argv[1]))
    def rnd(o):
        if isinstance(o, float): return round(o, 3)
        if isinstance(o, dict): return {k: rnd(v) for k, v in o.items() if not (k in ('shearX', 'shearY') and v == 0)}
        if isinstance(o, list): return [rnd(v) for v in o]
        return o
    print(json.dumps(rnd(S.R), separators=(',', ':'), ensure_ascii=False))
