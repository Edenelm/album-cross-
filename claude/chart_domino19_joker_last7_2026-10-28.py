# Domino 19 only: % of all standard payers who got a new sticker via Joker, last 7 days (bought vs gameplay)
# Data: claude/domino-end-rares-jokers-19v20-2026-10-27.md (SQL domino_end_rares_jokers_19v20_2026-10-27.sql)
import matplotlib.pyplot as plt
days=[7,6,5,4,3,2,1]
game=[3.6,2.2,1.5,1.5,3.7,7.3,11.6]; bought=[0,0.3,0.8,0.9,1.0,0.4,0.5]
BG='#212121'; C='#F2A04A'
plt.rcParams['font.family']='Oswald'
f,a=plt.subplots(figsize=(6.4,5.2),facecolor=BG); a.set_facecolor(BG)
a.plot(days,bought,color=C,lw=2.5,label=f'Jokers bought ({round(sum(bought)/7)}%)')
a.plot(days,game,color=C,lw=2.5,ls='--',label='Jokers from gameplay (4%)')
a.scatter([1,1],[game[-1],bought[-1]],color=C,zorder=3)
a.set_xlim(7.3,0.7); a.set_ylim(0,12.5); a.set_yticks([0,6,12]); a.set_yticklabels(['0','6%','12%'])
a.grid(axis='y',color='#444'); [s.set_visible(False) for s in a.spines.values()]
a.tick_params(colors='#bbb',labelsize=13,length=0); a.set_xlabel('days before close',color='#bbb',fontsize=12,loc='right')
a.legend(frameon=False,labelcolor=C,fontsize=13,loc='upper left')
a.set_title('Domino Dreams · album 19',color='#ddd',fontsize=15,loc='right')
plt.tight_layout(); plt.savefig('claude/png/domino19_joker_last7_2026-10-28.png',dpi=160,facecolor=BG)
