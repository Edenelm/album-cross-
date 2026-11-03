"""Dice chapter, topic 2 (completion path) charts, 2026-11-02. Base = typical albums 59/61/63 (Eden: do not focus on 65); dc4 shows 65 as the exception. Draft PNGs for the chapter doc; not inserted into any deck.
Source: claude/dice-completion-path-2026-11-02.md | SQL: claude/dice_completion_path_2026-11-02.sql | data: claude/results/dice_completion_path_59_61_2026-11-02.csv + dice_completion_path_2026-11-02.csv
Usage: python3 claude/dice_chapter_charts_2026-11-02.py  -> writes claude/slides/dice/dc1.png .. dc4.png"""
import csv, os, textwrap
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.text as mtext
_init = mtext.Text.__init__
mtext.Text.__init__ = lambda self, *a, **k: _init(self, *a, **{'parse_math': False, **k})   # labels use '$' as dollars, not math

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'slides', 'dice')
os.makedirs(OUT, exist_ok=True)
BG, WHITE, GREY, MUTED, GOLD, RED = '#212121', '#F5F5F5', '#BDBDBD', '#5A5A5A', '#FFDF85', '#FF0B47'
plt.rcParams.update({'font.family': ['Oswald', 'DejaVu Sans'], 'text.color': WHITE, 'axes.edgecolor': MUTED})

R = []
for f in ('dice_completion_path_59_61_2026-11-02.csv', 'dice_completion_path_2026-11-02.csv'):
    R += list(csv.DictReader(open(os.path.join(HERE, 'results', f))))
AL = (59, 61, 63)   # typical albums; 65 only in dc4
for r in R:
    for k in r:
        if k not in ('tier', 'c4_bucket', 'outcome'):
            r[k] = float(r[k])
S = lambda L, k: sum(r[k] for r in L)
TIERS = [('t1_le2', '≤$2 a day'), ('t2_2_5', '$2–5'), ('t3_5_20', '$5–20'), ('t4_gt20', '>$20')]

def base(fig, title, sub, msg):
    fig.patch.set_facecolor(BG)
    fig.text(0.06, 0.93, title, fontsize=16, color=WHITE)
    fig.text(0.06, 0.905, textwrap.fill(sub, 160), fontsize=8, color=GREY, va='top')
    fig.text(0.06, 0.05, msg, fontsize=12, color=WHITE)
    fig.text(0.86, 0.015, 'SuperPlay 2026', fontsize=7, color=GREY)

def axis(ax):
    ax.set_facecolor(BG)
    for s in ('top', 'right', 'left'):
        ax.spines[s].set_visible(False)
    ax.tick_params(colors=WHITE, length=0)
    ax.set_yticks([])

def dc1():   # % of near payers (1–3 missing at close−4) who did NOT finish, by spend level, 63 vs 65
    fig = plt.figure(figsize=(10, 5.63)); ax = fig.add_axes([0.06, 0.22, 0.88, 0.55]); axis(ax)
    base(fig, 'Payers 1–3 Short Before the Final Weekend Who Did Not Finish',
         'Dice 59, 61, 63 (typical albums) · standard-population payers 1–3 missing at close−4 (Thursday) · spend level = album $ a day in the first 75% of the album · finish = 144 by the end of the close day',
         'Even the strongest near payers mostly stay short: 59–62% of >$20 and 70–74% of $5–20, in every album.')
    for i, (t, lab) in enumerate(TIERS):
        for j, a in enumerate(AL):
            A = [r for r in R if r['album_id'] == a]; N, REV = S(A, 'players'), S(A, 'alb_rev')
            G = [r for r in A if r['tier'] == t and r['c4_bucket'] == 'm1_3']
            NF = [r for r in G if r['outcome'] == 'c_not']
            v = S(NF, 'players') / S(G, 'players')
            x = i * 3.0 + j * 0.85
            c = RED if t in ('t3_5_20', 't4_gt20') else MUTED
            ax.bar(x, v, 0.75, color=c, alpha=(0.55, 0.75, 1)[j])
            ax.text(x, v + 0.02, f'{v:.0%}', ha='center', fontsize=12, color=WHITE)
            ax.text(x, -0.07, f'Album {a}', ha='center', fontsize=8, color=GREY)
            ax.text(x, -0.16, f'{S(NF,"players"):,.0f}\n{S(NF,"players")/N:.1%} pay.\n{S(NF,"alb_rev")/REV:.1%} rev.', ha='center', va='top', fontsize=6.5, color=GREY)
        ax.text(i * 3.0 + 0.85, 1.02, lab, ha='center', fontsize=13, color=WHITE)
    ax.set_ylim(0, 1.1); ax.set_xticks([]); ax.set_xlim(-0.6, 3 * 3.0 + 2.3)
    fig.savefig(os.path.join(OUT, 'dc1.png'), dpi=150, facecolor=BG); plt.close(fig)

def dc2():   # $5+ near payers: finished late vs did not finish — what they did in the end window (2-album values)
    fig = plt.figure(figsize=(10, 5.63)); ax = fig.add_axes([0.06, 0.2, 0.88, 0.58]); axis(ax)
    base(fig, 'What $5+ Payers 1–3 Short Did in the Final Days',
         'Dice 59 | 61 | 63 · payers at $5+ a day, 1–3 missing at close−4 · bought a Wild or sticker = a new set sticker from a paid Wild or a paid sticker, close−3..close (fill date) · spend vs own pace = close−3..−1 $ a day ÷ first-75% $ a day',
         'Finishers bought the closer (a paid Wild or sticker, 1–2 each); 85–87% of those who stayed short did not buy it.')
    groups = [('b_late', 'Finished'), ('c_not', 'Did not finish')]
    metrics = [('Paid anything in the final weekend', lambda G: S(G, 'paid_in_end_window') / S(G, 'players'), MUTED),
               ('Bought a Wild or sticker for the album', lambda G: S(G, 'bought_album_item_end') / S(G, 'players'), GOLD),
               ('Final-weekend spend vs own pace', lambda G: S(G, 'end_rev') / S(G, 'end_rev_at_own_pace'), MUTED)]
    for m, (mlab, f, c) in enumerate(metrics):
        for g, (o, glab) in enumerate(groups):
            vals = []
            for a in AL:
                G = [r for r in R if r['album_id'] == a and r['tier'] in ('t3_5_20', 't4_gt20') and r['c4_bucket'] == 'm1_3' and r['outcome'] == o]
                vals.append(f(G))
            v = sum(vals) / len(vals)
            x = m * 3.2 + g * 1.15
            ax.bar(x, min(v, 2.2), 1.0, color=c if g == 0 else (RED if c == GOLD else MUTED), alpha=1 if g == 0 else 0.8)
            ax.text(x, min(v, 2.2) + 0.05, ' | '.join(f'{u:.0%}' for u in vals), ha='center', fontsize=10, color=WHITE)
            ax.text(x, -0.1, glab, ha='center', va='top', fontsize=8, color=GREY)
        ax.text(m * 3.2 + 0.575, 2.45, mlab, ha='center', fontsize=12, color=WHITE)
    fin = [r for r in R if r['tier'] in ('t3_5_20', 't4_gt20') and r['c4_bucket'] == 'm1_3']
    ax.axhline(1.0, xmin=0.67, xmax=0.98, color=GREY, lw=0.6, ls=':')
    ax.set_ylim(0, 2.7); ax.set_xticks([]); ax.set_xlim(-0.7, 2 * 3.2 + 1.85)
    lines = []
    for o, lab in groups:
        p = []
        for a in AL:
            A = [r for r in R if r['album_id'] == a]
            G = [r for r in A if r['tier'] in ('t3_5_20', 't4_gt20') and r['c4_bucket'] == 'm1_3' and r['outcome'] == o]
            p.append(f"{S(G,'players'):,.0f} ({S(G,'players')/S(A,'players'):.1%} of payers, {S(G,'alb_rev')/S(A,'alb_rev'):.0%} of album rev.)")
        lines.append(f"{lab}: " + ' | '.join(p))
    fig.text(0.06, 0.095, '\n'.join(lines), fontsize=7.5, color=GREY)
    fig.savefig(os.path.join(OUT, 'dc2.png'), dpi=150, facecolor=BG); plt.close(fig)

def dc3():   # share of payers vs share of final-weekend revenue, by outcome
    fig = plt.figure(figsize=(10, 5.63)); ax = fig.add_axes([0.06, 0.2, 0.88, 0.58]); axis(ax)
    base(fig, 'Share of Payers and of Final-Weekend Revenue, by How the Album Ended',
         'Dice 59 | 61 | 63 · standard-population payers · final weekend = close−3..−1 (Fri–Sun) · early = 144 by close−4 · late = 144 on close−3..close day',
         'Late finishers are 9–11% of payers but bring about half of the final-weekend revenue.')
    outs = [('a_early', 'Finished early'), ('b_late', 'Finished late'), ('c_not', 'Did not finish')]
    for i, (o, lab) in enumerate(outs):
        for j, (k, klab) in enumerate((('players', 'of payers'), ('end_rev', 'of final-weekend revenue'))):
            vals = []
            for a in AL:
                A = [r for r in R if r['album_id'] == a]
                vals.append(S([r for r in A if r['outcome'] == o], k) / S(A, k))
            v = sum(vals) / len(vals)
            x = i * 2.8 + j * 1.1
            c = GOLD if (o == 'b_late' and k == 'end_rev') else MUTED
            ax.bar(x, v, 0.95, color=c, alpha=1 if j == 1 else 0.6)
            ax.text(x, v + 0.02, ' | '.join(f'{u:.0%}' for u in vals), ha='center', fontsize=10, color=WHITE)
            ax.text(x, -0.03, klab, ha='center', va='top', fontsize=8, color=GREY)
        ax.text(i * 2.8 + 0.55, 0.98, lab, ha='center', fontsize=13, color=WHITE)
    sizes = []
    for o, lab in outs:
        p = []
        for a in AL:
            A = [r for r in R if r['album_id'] == a]; O = [r for r in A if r['outcome'] == o]
            p.append(f"{S(O,'players'):,.0f} ({S(O,'alb_rev')/S(A,'alb_rev'):.0%} of album rev.)")
        sizes.append(f"{lab}: {' | '.join(p)}")
    fig.text(0.06, 0.13, '\n'.join(sizes), fontsize=7.5, color=GREY, va='center')
    ax.set_ylim(0, 1.05); ax.set_xticks([]); ax.set_xlim(-0.7, 2 * 2.8 + 1.8)
    fig.savefig(os.path.join(OUT, 'dc3.png'), dpi=150, facecolor=BG); plt.close(fig)

def dc4():   # the exception: final-weekend spend vs own pace, all payers, 59/61/63 vs 65
    fig = plt.figure(figsize=(10, 5.63)); ax = fig.add_axes([0.06, 0.2, 0.88, 0.58]); axis(ax)
    base(fig, 'Final-Weekend Spend vs Own Pace, All Payers: Dice 59–65',
         'Standard-population payers with spend in the first 75% of the album · final weekend = close−3..−1 (Fri–Sun) · own pace = first-75% $ a day · 100% = same as usual',
         'Typical Dice albums end 7–16% above the usual pace; 65 is the only one below it (93%).')
    for i, a in enumerate((59, 61, 63, 65)):
        A = [r for r in R if r['album_id'] == a and r['tier'] != 't0_0']
        v = S(A, 'end_rev') / S(A, 'end_rev_at_own_pace')
        ax.bar(i, v, 0.6, color=RED if a == 65 else MUTED)
        ax.text(i, v + 0.02, f'{v:.0%}', ha='center', fontsize=14, color=WHITE)
        E = [r for r in R if r['album_id'] == a]
        ax.text(i, -0.05, f'Album {a}', ha='center', va='top', fontsize=11, color=WHITE)
        ax.text(i, -0.13, f"final weekend =\n{S(E,'end_rev')/S(E,'alb_rev'):.1%} of album revenue", ha='center', va='top', fontsize=8, color=GREY)
    ax.axhline(1.0, color=GREY, lw=0.6, ls=':')
    ax.set_ylim(0, 1.3); ax.set_xticks([]); ax.set_xlim(-0.6, 3.6)
    fig.savefig(os.path.join(OUT, 'dc4.png'), dpi=150, facecolor=BG); plt.close(fig)

if __name__ == '__main__':
    dc1(); dc2(); dc3(); dc4()
    print('written:', sorted(os.listdir(OUT)))
