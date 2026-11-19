"""Gera as imagens de fundo padrao do editor de QR Code (90x120 mm a 300 dpi).

Uso: python tools\\gerar_fundos.py background\\fundos
Requer Pillow (pip install --user pillow).
O centro de cada fundo e esbranquicado para o texto e o QR ficarem legiveis.
"""
import math, random, os, sys
OUT_DIR = sys.argv[1] if len(sys.argv) > 1 else '.'
os.makedirs(OUT_DIR, exist_ok=True)
from PIL import Image, ImageDraw, ImageFilter, ImageChops
W,H=1063,1417  # 90x120 mm @300dpi
S=2
def grad(c1,c2,diag=True):
    gv=Image.linear_gradient('L').resize((W*S,H*S))
    gh=Image.linear_gradient('L').rotate(90).resize((W*S,H*S))
    g=ImageChops.add(gv,gh,scale=2)
    a=Image.new('RGB',(W*S,H*S),c1); b=Image.new('RGB',(W*S,H*S),c2)
    return Image.composite(b,a,g)
def center_fade(base, strength=0.78):
    m=Image.radial_gradient('L').resize((W*S,int(H*S*1.05)))
    m=m.crop((0,0,W*S,H*S))
    m=Image.eval(m, lambda v: int(255-min(255,max(0,(255-v)*strength*1.25))))
    white=Image.new('RGB',base.size,(255,255,255))
    return Image.composite(base,white,m)
def layer(): return Image.new('RGBA',(W*S,H*S),(0,0,0,0))
def finish(base,ov,name,strength=0.78):
    base=base.convert('RGBA'); base.alpha_composite(ov)
    out=center_fade(base.convert('RGB'),strength).resize((W,H),Image.LANCZOS)
    out.save(os.path.join(OUT_DIR, name + '.png'),optimize=True)
R=random.Random(7)
X=lambda v:int(v*S)
# saude
b=grad((226,246,246),(206,234,247)); o=layer(); d=ImageDraw.Draw(o)
for _ in range(38):
    x,y=R.uniform(0,W),R.uniform(0,H); s=R.uniform(18,46); a=R.randint(40,90); c=(40,160,170,a)
    d.rounded_rectangle([X(x-s/6),X(y-s/2),X(x+s/6),X(y+s/2)],radius=X(s/12),fill=c)
    d.rounded_rectangle([X(x-s/2),X(y-s/6),X(x+s/2),X(y+s/6)],radius=X(s/12),fill=c)
for yb in (H*0.12,H*0.9):
    pts=[];x=0
    while x<W:
        pts+= [(x,yb),(x+40,yb),(x+52,yb-38),(x+66,yb+30),(x+78,yb-12),(x+90,yb),(x+150,yb)]; x+=150
    d.line([(X(a),X(c)) for a,c in pts],fill=(30,150,160,120),width=X(4),joint='curve')
finish(b,o,'fundo-saude')
# logistica
b=grad((255,244,224),(232,240,250)); o=layer(); d=ImageDraw.Draw(o)
for _ in range(26):
    x,y=R.uniform(0,W),R.uniform(0,H); s=R.uniform(40,90); a=R.randint(45,95); c=(190,130,50,a)
    d.rectangle([X(x),X(y),X(x+s),X(y+s*0.8)],outline=c,width=X(3))
    d.line([X(x+s/2),X(y),X(x+s/2),X(y+s*0.3)],fill=c,width=X(3))
    d.line([X(x),X(y+s*0.3),X(x+s),X(y+s*0.3)],fill=c,width=X(2))
for i in range(5):
    y0=R.uniform(0,H); y1=R.uniform(0,H); n=40
    for k in range(0,n,2):
        t0,t1=k/n,(k+1)/n
        p=lambda t:(W*t, y0+(y1-y0)*t+60*math.sin(t*6+i))
        d.line([tuple(map(X,p(t0))),tuple(map(X,p(t1)))],fill=(60,110,170,90),width=X(3))
finish(b,o,'fundo-logistica')
# empresa
b=grad((236,241,248),(222,230,242)); o=layer(); d=ImageDraw.Draw(o)
for i in range(-6,12):
    off=i*150
    d.polygon([(X(off),0),(X(off+60),0),(X(off+60-H*0.6),X(H)),(X(off-H*0.6),X(H))],fill=(70,100,160,22))
for gx in range(0,W,38):
    for gy in range(0,H,38):
        d.ellipse([X(gx-1.6),X(gy-1.6),X(gx+1.6),X(gy+1.6)],fill=(60,80,130,60))
d.rectangle([0,0,X(W),X(18)],fill=(40,70,130,150)); d.rectangle([0,X(H-18),X(W),X(H)],fill=(40,70,130,150))
finish(b,o,'fundo-empresa')
# teatro
b=grad((252,238,236),(246,228,214)); o=layer(); d=ImageDraw.Draw(o)
for side in (0,1):
    for k in range(7):
        xw=150; x0=k*xw/7
        xs=x0 if side==0 else W-x0-xw/7
        col=(150,30,45,140 if k%2==0 else 110)
        pts=[]
        for yy in range(0,H+1,20):
            sway=8*math.sin(yy/90+k)+(yy/H)*(-30 if side==0 else 30)*(k/7)
            pts.append((xs+sway,yy))
        pts2=[(x+xw/7,y) for x,y in reversed(pts)]
        d.polygon([tuple(map(X,p)) for p in pts+pts2],fill=col)
for k in range(12):
    cx=k*W/11; d.pieslice([X(cx-60),X(-50),X(cx+60),X(90)],0,180,fill=(150,30,45,170))
d.rectangle([0,0,X(W),X(26)],fill=(120,20,35,200))
for _ in range(30):
    x,y=R.uniform(170,W-170),R.uniform(120,H); r=R.uniform(4,9); a=R.randint(70,140)
    pts=[(x+ (r if j%2==0 else r/2.4)*math.cos(j*math.pi/5-math.pi/2), y+(r if j%2==0 else r/2.4)*math.sin(j*math.pi/5-math.pi/2)) for j in range(10)]
    d.polygon([tuple(map(X,p)) for p in pts],fill=(200,150,40,a))
finish(b,o,'fundo-teatro',0.7)
# educacao
b=grad((240,250,236),(226,242,232)); o=layer(); d=ImageDraw.Draw(o)
for yy in range(60,H,46): d.line([0,X(yy),X(W),X(yy)],fill=(70,140,200,60),width=X(2))
d.line([X(80),0,X(80),X(H)],fill=(220,80,80,110),width=X(3))
for _ in range(22):
    x,y=R.uniform(100,W),R.uniform(0,H); s=R.uniform(30,60); ang=R.uniform(0,math.pi)
    dx,dy=math.cos(ang)*s,math.sin(ang)*s
    d.line([X(x),X(y),X(x+dx),X(y+dy)],fill=(230,170,40,110),width=X(8))
    d.line([X(x+dx),X(y+dy),X(x+dx*1.15),X(y+dy*1.15)],fill=(90,70,50,120),width=X(4))
finish(b,o,'fundo-educacao')
# alimentacao
b=grad((255,242,228),(255,232,214)); o=layer(); d=ImageDraw.Draw(o)
for _ in range(20):
    x,y=R.uniform(0,W),R.uniform(0,H); r=R.uniform(25,60)
    d.ellipse([X(x-r),X(y-r),X(x+r),X(y+r)],outline=(220,120,60,90),width=X(3))
    d.ellipse([X(x-r*0.65),X(y-r*0.65),X(x+r*0.65),X(y+r*0.65)],outline=(220,120,60,60),width=X(2))
for _ in range(26):
    x,y=R.uniform(0,W),R.uniform(0,H); s=R.uniform(14,28); ang=R.uniform(0,360)
    leaf=Image.new('RGBA',(X(s*2),X(s*2)),(0,0,0,0)); ld=ImageDraw.Draw(leaf)
    ld.ellipse([X(s*0.6),0,X(s*1.4),X(s*2)],fill=(90,160,70,110)); leaf=leaf.rotate(ang,expand=True)
    o.alpha_composite(leaf,(max(0,X(x)),max(0,X(y))))
finish(b,o,'fundo-alimentacao')
# tecnologia
b=grad((232,244,255),(222,232,252)); o=layer(); d=ImageDraw.Draw(o)
for _ in range(45):
    x,y=R.choice([R.uniform(0,W*0.25),R.uniform(W*0.75,W)]),R.uniform(0,H)
    pts=[(x,y)]
    for k in range(4):
        x+=R.choice([-1,1])*R.uniform(30,90) if k%2==0 else 0; y+=R.uniform(30,90) if k%2 else 0
        pts.append((x,y))
    d.line([tuple(map(X,p)) for p in pts],fill=(40,110,200,90),width=X(3))
    ex,ey=pts[-1]; d.ellipse([X(ex-6),X(ey-6),X(ex+6),X(ey+6)],outline=(40,110,200,130),width=X(3))
finish(b,o,'fundo-tecnologia')
# eventos
b=grad((253,242,250),(240,238,255)); o=layer(); d=ImageDraw.Draw(o)
cols=[(240,90,120),(80,170,240),(250,190,50),(120,200,120),(170,110,230)]
for _ in range(160):
    x,y=R.uniform(0,W),R.uniform(0,H); c=R.choice(cols)+(R.randint(80,150),)
    if R.random()<0.5:
        r=R.uniform(4,9); d.ellipse([X(x-r),X(y-r),X(x+r),X(y+r)],fill=c)
    else:
        s=R.uniform(8,16); a=R.uniform(0,math.pi); dx,dy=math.cos(a)*s,math.sin(a)*s
        d.line([X(x),X(y),X(x+dx),X(y+dy)],fill=c,width=X(5))
finish(b,o,'fundo-eventos')
# neutro
b=grad((248,248,246),(236,238,240)); o=layer(); d=ImageDraw.Draw(o)
d.rectangle([X(14),X(14),X(W-14),X(H-14)],outline=(150,155,165,120),width=X(3))
d.rectangle([X(26),X(26),X(W-26),X(H-26)],outline=(150,155,165,70),width=X(2))
finish(b,o,'fundo-neutro',0.5)
