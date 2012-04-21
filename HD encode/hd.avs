AVISource("movie.avi").Trim(0,-0)

function deblink4(clip clp, float "ratio", int "level")  {
    ratio = default(ratio, 2.0 /3)
    assert(ratio >= 0.0 && 1.0 >= ratio,
    \      "[deblink4] 1.0 >= ratio >= 0.0, it was " + string(ratio))

    level = default(level, round(ratio * 257))
    assert(level >= 0 && 257 >= level,
    \      "[deblink4] 257 >= level >= 0, it was " + string(level))

    blink=clp.ng_blinkmask_new
    m01=mt_logic(blink.selectevery(4,0),
\                blink.selectevery(4,1),
\                mode="or").converttorgb32
    m23=mt_logic(blink.selectevery(4,2),
\                blink.selectevery(4,3),
\                mode="or").converttorgb32

    f0=layer(clp.selectevery(4,0),
\            clp.selectevery(4,1).mask(m01),
\            level=level)
    f1=layer(clp.selectevery(4,1),
\            clp.selectevery(4,0).mask(m01),
\            level=level)
    f2=layer(clp.selectevery(4,2),
\            clp.selectevery(4,3).mask(m23),
\            level=(257-level) )
    f3=layer(clp.selectevery(4,3),
\            clp.selectevery(4,2).mask(m23),
\            level=(257-level) )

    interleave(f0,f1,f2,f3)
}

function deblink3(clip clp){
    blink=clp.ng_blinkmask_new
    m01=mt_logic(blink.selectevery(4,0),
\                blink.selectevery(4,1),
\                mode="or").converttorgb32
    f0=layer(clp.selectevery(4,0),
\            clp.selectevery(4,1).mask(m01))
    f1=layer(clp.selectevery(4,1),
\            clp.selectevery(4,0).mask(m01))
    interleave(f0,f1,
\              clp.selectevery(4,2),clp.selectevery(4,3))
}

function ng_blinkmask_new(clip c,int "ml"){
    ml=default(ml,128)
    src=c.ConvertToYv12
    super=MSuper(src, pel=1)
    fvec =MAnalyse(super, isb=false, blksize=4)
    bvec =MAnalyse(super, isb=true , blksize=4)
    fmask=Mmask(src,fvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128)
    bmask=Mmask(src,bvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128)

    eo0_to =fmask.selectevery(2,1)
    oe_from=bmask.selectevery(2,1)
    front  =mt_logic(eo0_to,oe_from,mode="and")

    oe_to  =fmask.selectevery(2,2)
    eo_from=bmask.selectevery(2,2)
    back   =mt_logic(oe_to,eo_from,mode="and")

    ee_src=src.selecteven
    ee_super=MSuper(ee_src, pel=1)
    ee_fvec =MAnalyse(ee_super, isb=false, blksize=4)
    ee_bvec =MAnalyse(ee_super, isb=true , blksize=4)
    ee_fmask=Mmask(ee_src,ee_fvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128)
    ee_bmask=Mmask(ee_src,ee_bvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128)

    ee_to  =ee_fmask.trim(1,0)
    ee_from=ee_bmask
    ee     =mt_logic(ee_to,ee_from,mode="or")

    oo_src=src.selectodd
    oo_super=MSuper(oo_src, pel=1)
    oo_fvec =MAnalyse(oo_super, isb=false, blksize=4)
    oo_bvec =MAnalyse(oo_super, isb=true , blksize=4)
    oo_fmask=Mmask(oo_src,oo_fvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128)
    oo_bmask=Mmask(oo_src,oo_bvec,kind=1,ml=ml).mt_binarize(u=-128,v=-128)

    oo_to  =oo_fmask.trim(1,0)
    oo_from=oo_bmask
    oo     =mt_logic(oo_to,oo_from,mode="or")

    #to e0-o1, from o1-e2, nothing e0-e2
    even_blink=mt_logic(front,ee.mt_invert,mode="and")

    #to o1-e2, from e2-o3, nothing o1-o3
    odd_blink =mt_logic(back,oo.mt_invert,mode="and")

    interleave(even_blink, odd_blink).selectevery(1,-1)
}

a = last.ConvertToRGB32().deblink4.selecteven

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

""") : Eval("""
w1 = a.height * 4
h1 = a.width * 3
thegcd = gcd(w1, h1)
w1 = w1 / thegcd
h1 = h1 / thegcd

width  = a.width  * w1
height = a.height * h1
""")

g = a.PointResize(width, height)

#Logo stuffs
handheld ? Eval("""
d = ImageSource(file="gen2.png", start=0, end=60, fps=a.FrameRate).ConvertToRGB32()
""") : Eval("""
d = ImageSource(file="nes.png", start=0, end=60, fps=a.FrameRate).ConvertToRGB32()
""")
e = BlankClip(d, audio_rate=a.AudioRate, channels=a.AudioChannels)
f = AudioDub(d, e).Lanczos4Resize(g.width, g.height).AssumeFPS(a.FrameRateNumerator, a.FrameRateDenominator)

subff = 249     
height = 1106
s = 90
al = 8
textcolor = $00ffff00
halocolor = $00000000

last = f + g

Subtitle("Chip 'n Dale 2\nin 15:48.17", align=al, y=height, first_frame=subff, last_frame=subff+80, size=s, text_color=textcolor, halo_color=halocolor, lsp=1)
Subtitle("Played by feos\nRerecord count: 41526", align=al, y=height, first_frame=subff+80+1, last_frame=subff+160+1, size=s, text_color=textcolor, halo_color=halocolor, lsp=1)
Subtitle("This is a tool-assisted\nemulator recording", align=al, y=height, first_frame=subff+170, last_frame=subff+250, size=s, text_color=textcolor, halo_color=halocolor, lsp=1)
Subtitle("For details, visit\nhttp://TASVideos.org/", align=al, y=height, first_frame=subff+250+1, last_frame=subff+330+1, size=s, text_color=textcolor, halo_color=halocolor, lsp=1)

ConvertToYV24(matrix="Rec709", chromaresample="point")
ConvertToYV12(matrix="Rec709", chromaresample="point")