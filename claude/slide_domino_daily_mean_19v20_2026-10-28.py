# Rebuild bars on deck slide h34db989847609537_0_966 ("New Stickers per Day ... Domino 19 vs 20") as the daily MEAN
# (new set stickers per standard-population payer per album day 1-49). Data: claude/domino_19v20_daily_mean_2026-10-28.sql. Prints batchUpdate JSON.
import json
s19="1:10.50 2:9.90 3:5.77 4:4.31 5:4.91 6:3.86 7:8.24 8:4.80 9:3.68 10:3.36 11:3.31 12:4.87 13:4.37 14:3.33 15:3.24 16:1.84 17:1.72 18:2.41 19:2.00 20:1.54 21:4.20 22:3.74 23:3.23 24:2.36 25:2.02 26:2.86 27:2.77 28:2.55 29:1.99 30:1.77 31:1.67 32:1.88 33:1.46 34:1.05 35:1.20 36:1.31 37:0.95 38:0.80 39:0.94 40:0.91 41:0.99 42:1.14 43:1.11 44:0.76 45:0.54 46:0.43 47:0.54 48:0.57 49:0.56"
s20="1:10.80 2:9.72 3:7.63 4:4.81 5:3.54 6:2.11 7:4.22 8:4.88 9:4.35 10:3.51 11:2.67 12:2.49 13:2.69 14:3.88 15:4.22 16:2.78 17:2.92 18:2.76 19:2.79 20:2.06 21:1.49 22:3.14 23:4.05 24:4.87 25:4.06 26:2.68 27:2.80 28:2.65 29:1.73 30:1.56 31:1.77 32:1.79 33:1.74 34:1.24 35:2.18 36:2.12 37:2.24 38:1.64 39:0.99 40:0.57 41:0.60 42:0.60 43:0.45 44:0.74 45:1.03 46:1.18 47:0.90 48:0.60 49:0.55"
P='h34db989847609537_0_'; PG=P+'966'
R=[{'deleteObject':{'objectId':P+str(i)}} for i in list(range(982,1007))+list(range(1012,1056))]
U=45720; X0=1676400; DX=140970; W=101700
for tag,ser,base,col in [('m19',s19,3609648,{'red':1,'green':0.0431,'blue':0.2784}),('m20',s20,2359338,{'red':1,'green':0.8745,'blue':0.5216})]:
  for kv in ser.split():
    d,v=kv.split(':'); d=int(d); h=max(float(v)*U,2000); oid=f'{tag}_{d}'
    R.append({'createShape':{'objectId':oid,'shapeType':'RECTANGLE','elementProperties':{'pageObjectId':PG,'size':{'width':{'magnitude':W,'unit':'EMU'},'height':{'magnitude':round(h),'unit':'EMU'}},'transform':{'scaleX':1,'scaleY':1,'translateX':X0+(d-1)*DX,'translateY':round(base-h),'unit':'EMU'}}}})
    R.append({'updateShapeProperties':{'objectId':oid,'shapeProperties':{'shapeBackgroundFill':{'solidFill':{'color':{'rgbColor':col}}},'outline':{'propertyState':'NOT_RENDERED'}},'fields':'shapeBackgroundFill,outline'}})
R.append({'replaceAllText':{'containsText':{'text':'Median paying player (paid on any album day), all players · new = a set sticker the player did not have','matchCase':True},'replaceText':'Average per standard-population payer (album 19: 119,201 · album 20: 106,762) · new = a set sticker the player did not have','pageObjectIds':[PG]}})
R.append({'replaceAllText':{'containsText':{'text':'New Stickers per Day, Median Paying Player: Domino 19 vs 20','matchCase':True},'replaceText':'New Stickers per Payer per Day: Domino 19 vs 20','pageObjectIds':[PG]}})
R.append({'replaceAllText':{'containsText':{'text':'pause · 0–1 a day','matchCase':True},'replaceText':'pause · ~2 a day','pageObjectIds':[PG]}})
print(json.dumps(R,separators=(',',':')))
