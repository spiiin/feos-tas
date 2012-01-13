AVISource("movie.avi").converttorgb32().Trim(0,-0)

converttorgb32 

e0=selectevery(4,0) 
o1=selectevery(4,1) 
e2=selectevery(4,2) 
o3=selectevery(4,3) 

i2=layer(e2,o1.mask(blinkmask.converttorgb32)) 
interleave(e0,o1,i2,o3) 
i2=layer(i2,o1.mask(shakemask.converttorgb32)) 

interleave(e0,i2) 

a = last

function blinkmask(clip c,int "ml"){ 
    ml=default(ml,128) 
    src=c.ConvertToYv12 
    super=MSuper(src, pel=1) 
    fvec =MAnalyse(super, isb=false, blksize=4) 
    bvec =MAnalyse(super, isb=true , blksize=4) 
    fmask=Mmask(src,fvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128) 
    bmask=Mmask(src,bvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128) 

    eo0_to =fmask.selectevery(4,1) 
    oe_from=bmask.selectevery(4,1) 
    front  =mt_logic(eo0_to,oe_from,mode="and") 

    oe_to  =fmask.selectevery(4,2) 
    eo_from=bmask.selectevery(4,2) 
    back   =mt_logic(oe_to,eo_from,mode="and") 

    ee_src=src.selecteven 
    ee_super=MSuper(ee_src, pel=1) 
    ee_fvec =MAnalyse(ee_super, isb=false, blksize=4) 
    ee_bvec =MAnalyse(ee_super, isb=true , blksize=4) 
    ee_fmask=Mmask(ee_src,ee_fvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128) 
    ee_bmask=Mmask(ee_src,ee_bvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128) 

    ee_to  =ee_fmask.selectevery(2,1) 
    ee_from=ee_bmask.selectevery(2,0) 
    ee     =mt_logic(ee_to,ee_from,mode="or") 

    oo_src=src.selectodd 
    oo_super=MSuper(oo_src, pel=1) 
    oo_fvec =MAnalyse(oo_super, isb=false, blksize=4) 
    oo_bvec =MAnalyse(oo_super, isb=true , blksize=4) 
    oo_fmask=Mmask(oo_src,oo_fvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128) 
    oo_bmask=Mmask(oo_src,oo_bvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128) 

    oo_to  =oo_fmask.selectevery(2,1) 
    oo_from=oo_bmask.selectevery(2,0) 
    oo     =mt_logic(oo_to,oo_from,mode="or") 

    #to e0-o1, from o1-e2, nothing e0-e2 
    unblink=mt_logic(front,ee.mt_invert,mode="and") 

    #to o1-e2, from e2-o3, nothing o1-o3 
    blink  =mt_logic(back,oo.mt_invert,mode="and") 

    return mt_logic(blink,unblink,mode="or") 
} 

function shakemask(clip c){ 
    e0=c.selectevery(4,0) 
    o1=c.selectevery(4,1) 
    e2=c.selectevery(4,2) 
    o3=c.selectevery(4,3) 
    e4=c.selectevery(4,4) 

    ee1=ng_same(e0,e2).mt_inpand 
    ee2=ng_same(e2,e4).mt_inpand 
    oo=ng_same(o1,o3).mt_inpand 

    mask=mt_logic(ee1,ee2,mode="or") 
    return mt_logic(mask,oo,mode="and") 
} 

function ng_same(clip A, clip B, int "thr"){ 
    thr=default(thr,0) 
    TAD=ng_TAD(A,B) 
    return mt_binarize(TAD, threshold=thr, upper=true) 
} 

function ng_TAD(clip A, clip B){ 
    R=ng_AD(A  .showRed("YV12"),B  .showRed("YV12")) 
    G=ng_AD(A.showGreen("YV12"),B.showGreen("YV12")) 
    B=ng_AD(A .showBlue("YV12"),B .showBlue("YV12")) 
    return ng_plus(R, ng_plus(G, B)) 
} 

function ng_AD(clip A, clip B){ 
    return mt_lutxy(A,B,"x y - abs") 
} 

function ng_plus(clip A, clip B){ 
    return mt_lutxy(A,B,"x y +") 
}

# Set this to true if this is a handheld console to disable aspect correction
handheld = false

function gcd(int x, int y)
{
  t = x % y
  x = y
  y = t
  return (y > 0) ? gcd(x, y) : x
}

(handheld) ? Eval("""
factor = (a.height > 540) ? 2 : \
         (a.height > 270) ? 4 : \
         (a.height > 180) ? 6 : 8
width = a.width * factor
height = a.height * factor

multi = factor
""") : Eval("""
w1 = a.height * 4
h1 = a.width * 3
thegcd = gcd(w1, h1)
w1 = w1 / thegcd
h1 = h1 / thegcd

width  = a.width  * w1
height = a.height * h1

multi = h1
""")

g = a.PointResize(width, height)

#Logo stuffs
handheld ? Eval("""
d = ImageSource(file="gba.png", start=0, end=60, fps=a.FrameRate).ConvertToRGB32()
""") : Eval("""
d = ImageSource(file="nes.png", start=0, end=60, fps=a.FrameRate).ConvertToRGB32()
""")
e = BlankClip(d, audio_rate=a.AudioRate, channels=a.AudioChannels)
f = AudioDub(d, e).Lanczos4Resize(g.width, g.height).AssumeFPS(a.FrameRateNumerator, a.FrameRateDenominator)

subff = 290 
height = 0
s = 90
al = 8
textcolor = $00ffffff
halocolor = $00000000

last = f + g 

Subtitle("NES Wolverine in 08:10.94", align=al, y=height, first_frame=subff, last_frame=subff+80, size=s, text_color=textcolor, halo_color=halocolor, lsp=1)
Subtitle("Played by goofydylan8", align=al, y=height, first_frame=subff+80+1, last_frame=subff+160+1, size=s, text_color=textcolor, halo_color=halocolor, lsp=1)
Subtitle("This is a tool-assisted\nemulator recording", align=al, y=height, first_frame=subff+170, last_frame=subff+250, size=s, text_color=textcolor, halo_color=halocolor, lsp=1)
Subtitle("For details, visit\nhttp://TASVideos.org/", align=al, y=height, first_frame=subff+250+1, last_frame=subff+330+1, size=s, text_color=textcolor, halo_color=halocolor, lsp=1)

ConvertToYV24(matrix="Rec709", chromaresample="point")
ConvertToYV12(matrix="Rec709", chromaresample="point")