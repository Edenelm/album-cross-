"""Compute the two measures from results/topic6_calendar_neutral_return_2026-10-24.csv (Eden 2026-10-24).
A = week after vs own pace, simple average of 3 albums. B = index = group's week after vs own pace / all NON-finishers' week after vs own pace,
same game, album and spend level; then averaged over 3 albums. Also last week (A and B)."""
import csv, collections, sys
rows = list(csv.DictReader(open(sys.argv[1] if len(sys.argv) > 1 else 'results/topic6_calendar_neutral_return_2026-10-24.csv')))
LV = {'le2': ['t1_le2'], '2_5': ['t2_2_5'], '5_20': ['t3_5_20'], 'gt20': ['t4_gt20'], '2_20': ['t2_2_5', 't3_5_20'], 'all': ['t1_le2', 't2_2_5', 't3_5_20', 't4_gt20']}
GR = {'fin': ['a_finished'], 's12': ['b_1_2'], 's3': ['c_3'], 's4': ['d_4plus'], 'nonfin': ['b_1_2', 'c_3', 'd_4plus']}
def agg(g, a, lv, gr, col):
    rs = [r for r in rows if r['game'] == g and r['album'] == a and r['level'] in LV[lv] and r['status'] in GR[gr]]
    return sum(float(r[col]) for r in rs) / 7 / sum(float(r['pace']) for r in rs)
albums = collections.OrderedDict((g, sorted({r['album'] for r in rows if r['game'] == g}, key=int)) for g in ['Dice', 'Domino', 'Disney'])
def table(gr, lv, col='after7'):
    out = {}
    for g, al in albums.items():
        a = [agg(g, x, lv, gr, col) for x in al]
        b = [agg(g, x, lv, gr, col) / agg(g, x, lv, 'nonfin', col) for x in al]
        out[g] = (a, b)
    return out
if __name__ == '__main__':
    for gr in ['fin', 's12']:
        for lv in ['2_20', 'all', 'le2', '2_5', '5_20', 'gt20']:
            t = table(gr, lv)
            print(gr, lv, ' | '.join(f"{g}: A {[round(x*100) for x in a]} avg {round(sum(a)/3*100)}% · B {[round(x,2) for x in b]} avg {sum(b)/3:.2f}" for g, (a, b) in t.items()))
    print('nonfin week after (2_20):', {g: [round(agg(g, x, '2_20', 'nonfin', 'after7')*100) for x in al] for g, al in albums.items()})
    for gr in ['fin']:
        t = table(gr, '2_20', 'last7'); print('last7', gr, {g: (round(sum(a)/3*100), round(sum(b)/3, 2)) for g, (a, b) in t.items()})
