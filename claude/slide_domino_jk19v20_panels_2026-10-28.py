# New slide jk1920: copy of "% Of All PU Get Wild / Joker Last 7 Days" with Domino 19 panel next to Domino 20 (Dice/Disney removed).
# Data: claude/domino-end-rares-jokers-19v20-2026-10-27.md. Prints batchUpdate requests JSON.
import json
P='h22531cc986c0856e_0_'; N='jk1920_'
ids={P[:-3]+'_0_0':N+'slide'}
ids={'h22531cc986c0856e_0_0':N+'slide'}
for i in list(range(2,55))+list(range(59,111)): ids[P+str(i)]=N+str(i)
R=[{'duplicateObject':{'objectId':'h22531cc986c0856e_0_0','objectIds':ids}},
   {'updateSlidesPosition':{'slideObjectIds':[N+'slide'],'insertionIndex':125}}]
dele=[5,20,21,22,60]+list(range(64,77))+list(range(39,55))+list(range(94,111))
R+=[{'deleteObject':{'objectId':N+str(i)}} for i in dele]
OR={'red':0.9607843,'green':0.627451,'blue':0.2901961}
x0,step,y0,pp=1047750,298449.75,3890962.5,162718.75
game=[3.6,2.2,1.5,1.5,3.7,7.3,11.6]; bought=[0,0.3,0.8,0.9,1.0,0.4,0.5]
def series(vals,tag,w,dash):
  out=[]
  for k in range(6):
    xa,ya=x0+k*step,y0-vals[k]*pp; yb=y0-vals[k+1]*pp; oid=f'{N}{tag}{k}'
    out.append({'createLine':{'objectId':oid,'category':'STRAIGHT','elementProperties':{'pageObjectId':N+'slide',
      'size':{'width':{'magnitude':3000000,'unit':'EMU'},'height':{'magnitude':3000000,'unit':'EMU'}},
      'transform':{'scaleX':step/3e6,'scaleY':(yb-ya)/3e6 if yb!=ya else 0.0001,'translateX':xa,'translateY':ya,'unit':'EMU'}}}})
    out.append({'updateLineProperties':{'objectId':oid,'lineProperties':{'lineFill':{'solidFill':{'color':{'rgbColor':OR}}},'weight':{'magnitude':w,'unit':'EMU'},'dashStyle':dash},'fields':'lineFill,weight,dashStyle'}})
  d=34329; oid=f'{N}{tag}dot'; yl=y0-vals[6]*pp
  out.append({'createShape':{'objectId':oid,'shapeType':'ELLIPSE','elementProperties':{'pageObjectId':N+'slide',
    'size':{'width':{'magnitude':3000000,'unit':'EMU'},'height':{'magnitude':3000000,'unit':'EMU'}},
    'transform':{'scaleX':0.0229,'scaleY':0.0229,'translateX':x0+6*step-d,'translateY':yl-d,'unit':'EMU'}}}})
  out.append({'updateShapeProperties':{'objectId':oid,'shapeProperties':{'shapeBackgroundFill':{'solidFill':{'color':{'rgbColor':OR}}},'outline':{'propertyState':'NOT_RENDERED'}},'fields':'shapeBackgroundFill,outline'}})
  return out
R+=series(game,'g',16675,'DASH')+series(bought,'b',23825,'SOLID')
# Domino logo copy for left panel
R.append({'duplicateObject':{'objectId':N+'24','objectIds':{N+'24':N+'logo19'}}})
R.append({'updatePageElementTransform':{'objectId':N+'logo19','applyMode':'RELATIVE','transform':{'scaleX':1,'scaleY':1,'translateX':-2743200,'translateY':0,'unit':'EMU'}}})
for oid,t in [(N+'6','album 19'),(N+'18','━ Jokers bought (1%)'),(N+'19','- - Jokers from gameplay (4%)')]:
  R+=[{'deleteText':{'objectId':oid,'textRange':{'type':'ALL'}}},{'insertText':{'objectId':oid,'text':t}}]
R+=[{'updateTextStyle':{'objectId':N+s,'textRange':{'type':'ALL'},'style':{'foregroundColor':{'opaqueColor':{'rgbColor':OR}}},'fields':'foregroundColor'}} for s in ('18','19')]
# center the two panels
dx=1371519
move=[str(i) for i in [4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,61,62,63]+list(range(23,39))+list(range(77,94))]+['logo19']
move+=[f'{t}{k}' for t in 'gb' for k in range(6)]+['gdot','bdot']
R+=[{'updatePageElementTransform':{'objectId':N+m,'applyMode':'RELATIVE','transform':{'scaleX':1,'scaleY':1,'translateX':dx,'translateY':0,'unit':'EMU'}}} for m in move]
# bottom line
R.append({'createShape':{'objectId':N+'bl','shapeType':'TEXT_BOX','elementProperties':{'pageObjectId':N+'slide',
  'size':{'width':{'magnitude':7900000,'unit':'EMU'},'height':{'magnitude':330000,'unit':'EMU'}},
  'transform':{'scaleX':1,'scaleY':1,'translateX':611975,'translateY':4330000,'unit':'EMU'}}}})
R.append({'insertText':{'objectId':N+'bl','text':"Same Joker wave in both albums (12% vs 11% of payers at the peak), but album 20's came 2 days earlier."}})
R.append({'updateTextStyle':{'objectId':N+'bl','textRange':{'type':'ALL'},'style':{'fontFamily':'Oswald','fontSize':{'magnitude':14,'unit':'PT'},'foregroundColor':{'opaqueColor':{'rgbColor':{'red':1,'green':0.8745,'blue':0.5216}}}},'fields':'fontFamily,fontSize,foregroundColor'}})
R.append({'createShape':{'objectId':N+'sub','shapeType':'TEXT_BOX','elementProperties':{'pageObjectId':N+'slide',
  'size':{'width':{'magnitude':7900000,'unit':'EMU'},'height':{'magnitude':300000,'unit':'EMU'}},
  'transform':{'scaleX':1,'scaleY':1,'translateX':611975,'translateY':900000,'unit':'EMU'}}}})
R.append({'insertText':{'objectId':N+'sub','text':'Domino · standard-population payers (album 19: 119,201 · album 20: 106,762, all album revenue) · % who got a new sticker through a Joker that day'}})
R.append({'updateTextStyle':{'objectId':N+'sub','textRange':{'type':'ALL'},'style':{'fontFamily':'Oswald','fontSize':{'magnitude':11,'unit':'PT'},'foregroundColor':{'opaqueColor':{'rgbColor':{'red':0.7,'green':0.7,'blue':0.7}}}},'fields':'fontFamily,fontSize,foregroundColor'}})
print(json.dumps(R))
