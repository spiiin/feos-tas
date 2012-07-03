# The downloadable / HD encoding script. For more information, see:
# http://tasvideos.org/EncodingGuide/HybridEncodeScript.html

# The below filenames are the filenames of your logo, set one for handheld
# consoles and TV based consoles, be sure to keep the "" tags.
file = "logo.png"

# This sets the start time for the subtitles to start displaying, this is set
# as a frame number.
subff = 685 

# This controls how long the subtitles stay on the screen.
sublength = 300

# This sets the start time for the second set of subtitles to start displaying,
# this is set as a frame number. Make sure there's at least a delay of 1 frame
# in between this set and the previous one.
subff2 = subff + sublength + 1

# This controls how long the second set of subtitles stay on the screen.
sublength2 = sublength

# Below is the size for the subtitles, standard encodes use a size of 10.
subsize = 14

# Adjust the below items to adjust the subtitles.
# This is so that the movie will have the correct subtitles.
# All the required information will be on the movies submission page.
# Be sure to keep the quotes everywhere, even when branch is blank ("").
game = "High Seas Havoc"
branch = ""
author = "philipptr"
time = "19:52.22"
rerecords = "37170"

# Below is the values for the left, center, or right positioning for the
# subtitles below in the script, modification shouldn't be attempted unless you
# know what you're doing.
positionleft = 7
positioncenter = 8
positionright = 9

# This sets the position of the subtitles in terms of direction, it can be
# left, right, or center.
# Set positionleft for left, set positioncenter for center, set positionright
# for right.
# Setting this to positioncenter is considered standard practice, so other
# positions shouldn't be used unless it looks far better.
position = positioncenter

# This sets the y position for the subtitles, basically, how high or low they
# are up on the screen.
# The higher the number, the lower the subtitles.
ypos = 25

# Set this to true for HD encode resolutions.
# Don't forget adding the "yt:stretch=4:3" tag after you've uploaded the video.
hd = false

# Set this to true if this is a handheld console to disable aspect correction.
# If you are encoding in HD, you can ignore this.
handheld = false

# Set this to true to enable blend-based frame decimation for YouTube.  Flickering
# effects can be preserved, but filesize will suffer.  Has no effect if hd = false.
blend = false

# Set this to true to use the new advanced ng_deblink instead of TasBlend.
# Generally better.  Has no effect if blend = false or hd = false.
ngdb = true

# Set this to true for 10 bit 444 encodes. You additionally have to:
# 1) Use 10-bit version of x264.
# 2) Use command line option '--output-csp i444'.
i444 = false

# Passes for downloadable/streaming encodes:
# 0: audio extraction / streaming (archive.org 512kb; AR correction);
# 1: DupMC (no AR correction);
# 2: DeDup (no AR correction).
pass = 0

# This setting turns the audio/video desync fixer on/off using true/false.
# The below should always be set to false, barring the unusual occasion that it
# actually fixes the audio.
desyncfixer = false

sourcevideo = AVISource("movie.avi").Trim(0,500).ConvertToRGB32() #82415

# This setting adjusts the framerate for HD encodes when uploading to YouTube.
# This is to save space due to YouTube having a maximum framerate of 30 anyway.
# It is suggested to be at either 24 fps or 30fps for NTSC games (Depending on
# if they use alternating frame flicker or not).
# PAL games should generally be set to 30 fps, it can be set to 25 fps if there
# is no flickering, but it's difficult to notice the strobing effect in 30fps
# anyway. If you have ng_deblink enabled, you can ignore this.
hdframerate = 30

# THE BELOW CODE SHOULDN'T BE MODIFIED UNLESS YOU KNOW WHAT YOU ARE DOING!
# This automatically fixes length based audio/video desync if it exists inside
# the encode (eg. Many PCEngine games).
num = sourcevideo.AudioLengthF * sourcevideo.FrameRateNumerator
denom = sourcevideo.FrameCount * sourcevideo.FrameRateDenominator
fixedaudiorate = Round(num / denom)
(desyncfixer) ? last.AssumeSampleRate(fixedaudiorate) : 0

# This activates the frame dropper or the ng_deblink function for HD encodes.
# This depends on if the game simulates transperancy with alternating frame
# flicker. The frame dropper saves filesize without image loss, because YouTube
# caps at 30fps. The ng_deblink function, however, increases the filesize due to
# the frame blending, but optimizes the flicker effects for YouTube.

# blended = last.TASBlend()
# SelectEven()
#hd ? (tb ? TASBlend() : ChangeFPS(hdframerate)) : 0
#hd ? (ngdb ? ng_deblink.selecteven : ChangeFPS (hdframerate)) : 0
hd ? (blend ? (ngdb ? ng_deblink.selectodd : TasBlend()) : ChangeFPS(hdframerate)) : 0

# High Definition.
factor = hd ? 4 : 1

b = sourcevideo.PointResize( \
    sourcevideo.width * factor, sourcevideo.height * factor \
)

width = (b.width > b.height * 4 / 3) ? b.width : b.height * 4 / 3
width = (width % 4 == 1) ? width + 3 : \
        (width % 4 == 2) ? width + 2 : \
        (width % 4 == 3) ? width + 1 : width
height = (b.width > b.height * 4 / 3) ? b.width * 3 / 4 : b.height
height = (height % 4 == 1) ? height + 3 : \
         (height % 4 == 2) ? height + 2 : \
         (height % 4 == 3) ? height + 1 : height

c = handheld ? b : ( \
    hd ? b : b.LanczosResize(width, height, taps=2) \
)
g = hd ? c.PointResize(c.width * 2, c.height * 2) \
           : ((pass == 0) ? c : sourcevideo)
multi = g.height / 224
multi = (multi > (g.height / sourcevideo.height)) ? multi : (g.height / sourcevideo.height)

# Logo.
d = ImageSource( \
    file=file, start=0, end=int((sourcevideo.FrameRate * 2) - 1), \
    fps=sourcevideo.FrameRate \
).ConvertToRGB32().AssumeFPS( \
    sourcevideo.FrameRateNumerator, sourcevideo.FrameRateDenominator \
)
e = BlankClip( \
    d, audio_rate=sourcevideo.AudioRate, channels=sourcevideo.AudioChannels \
)
f = AudioDub(d, e).LanczosResize(g.width, g.height, taps=2)
last = f + g

# This is the first set of subtitles.
# This shouldn't be modified unless you know what you are doing
Subtitle( \
    game + "\n" + ( \
        (branch == "") ? "" : branch + "\n" \
    ) + "Played by " + author + "\nPlaying time: " + \
    time + "\nRerecord count: " + rerecords, y=(ypos * multi), \
    align=position, first_frame=subff, last_frame=(subff + sublength), \
    size=(subsize * multi), text_color=$00FFFFFF, halo_color=$00000000, lsp=2 \
)

# This is the second set of subtitles, do not modify unless necessary.
Subtitle( \
    "This is a tool-assisted\nemulator recording.\nFor details, visit\n" + \
    "http://TASVideos.org/", y=(ypos * multi), \
    align=position, first_frame=subff2, last_frame=(subff2 + sublength2), \
    size=(subsize * multi), text_color=$00FFFFFF, halo_color=$00000000, lsp=2 \
)

# Downloadable encodes need a resizing filter for the colourspace reduction.
# HD encodes need to be point resized to keep the colour information faithful.
ConvertToYV24(chromaresample="point", matrix=(hd ? "Rec709" : "PC.601"))
(pass == 1) ? ExactDedup( \
    firstpass=true, dupinfo="./temp/dup.txt", times="./temp/times.txt" \
) : last
(pass == 2) ? ExactDedup(firstpass=false, dupinfo="./temp/dup.txt") : last
i444 ? last : ConvertToYV12( \
        chromaresample=(hd ? "point" : "lanczos"), \
        matrix=(hd ? "Rec709" : (pass == 0 ? "Rec601" : "PC.601")) \
)

# Begin nanogyth's deblink code here

function ng_deblink(clip clp, float "ratio", int "level")  {
    ratio = default(ratio, 2.0 /3)
    assert(ratio >= 0.0 && 1.0 >= ratio,
    \      "[deblink4] 1.0 >= ratio >= 0.0, it was " + string(ratio))

    level = default(level, round(ratio * 257))
    assert(level >= 0 && 257 >= level,
    \      "[deblink4] 257 >= level >= 0, it was " + string(level))

    blink=clp.ng_blinkmask_new
    m01=mt_logic(blink.selectevery(4,0),blink.selectevery(4,1),mode="or").converttorgb32
    m23=mt_logic(blink.selectevery(4,2),blink.selectevery(4,3),mode="or").converttorgb32

    f0=layer(clp.selectevery(4,0),clp.selectevery(4,1).mask(m01),level=level)
    f1=layer(clp.selectevery(4,1),clp.selectevery(4,0).mask(m01),level=level)
    f2=layer(clp.selectevery(4,2),clp.selectevery(4,3).mask(m23),level=(257-level) )
    f3=layer(clp.selectevery(4,3),clp.selectevery(4,2).mask(m23),level=(257-level) )

    interleave(f0,f1,f2,f3)
}

function deblink3(clip clp){
    blink=clp.ng_blinkmask_new
    m01=mt_logic(blink.selectevery(4,0),blink.selectevery(4,1),mode="or").converttorgb32
    f0=layer(clp.selectevery(4,0),clp.selectevery(4,1).mask(m01))
    f1=layer(clp.selectevery(4,1),clp.selectevery(4,0).mask(m01))
    interleave(f0,f1,clp.selectevery(4,2),clp.selectevery(4,3))
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

# nanogyth's bighalo code

function ng_bighalo(
\ clip clp,
\ string text,
\ float "x",
\ float "y",
\ int "first_frame",
\ int "last_frame",
\ string "font",
\ float "size",
\ int "text_color",
\ int "halo_color",
\ int "align",
\ int "spc",
\ int "lsp",
\ float "font_width",
\ float "font_angle",
\ int "halo_radius"
\){
    x           = default(          x, -1)
    first_frame = default(first_frame, 0)
    last_frame  = default( last_frame, first_frame + 299)
    font        = default(       font, "Ariel")
    size        = default(       size, 18)
    y           = default(          y, size)
    text_color  = default( text_color, $20FFFFFF)
    halo_color  = default( halo_color, $20000000)
    align       = default(      align, 5)
    spc         = default(        spc, 0)
    lsp         = default(        lsp, 1)
    font_width  = default( font_width, 0)
    font_angle  = default( font_angle, 0)
    halo_radius = default(halo_radius, 8)

    invis=blankclip(clp, length=1, pixel_type="YV12")
    text_mask=subtitle(invis, text, x, y, 0, 0, font, size, $00FFFFFF,
\                      $80808080, align, spc, lsp, font_width, font_angle)
    halo_mask=mt_logic(text_mask,
\                      text_mask.mt_expand(mode=mt_circle(halo_radius)),
\                      mode="xor")

    h_alpha=(halo_color >= 0) ? 255 - halo_color/$01000000
\                             :  -(halo_color+1)/$01000000
    hc=blankclip(clp, length=1, color=halo_color)
    mm=hc.mask(mt_lut(halo_mask, string(h_alpha)+" x * 255 /").converttorgb32)
    clp2=clp.applyrange(first_frame, last_frame, "Layer", mm)

    t_alpha=(text_color >= 0) ? 255 - text_color/$01000000
\                             :  -(text_color+1)/$01000000
    tc=blankclip(clp, length=1, color=text_color)
    mm2=tc.mask(mt_lut(text_mask, string(t_alpha)+" x * 255 /").converttorgb32)
    clp2.applyrange(first_frame, last_frame, "Layer", mm2)
}

# This is the TASBlend function. It reduces framerate to 1/2 but leave
# flickering effects partly visible. Do not touch it.

function TASBlend(clip c, float "ratio") {
    # reduces framerate to 1/2 but leaves flicker effects partly visible
    # blends frame pairs with alternating opacity
    # The default for this is 2/3+1/3;1/3+2/3)
    # optional "ratio" is the opacity of the first frame out of the four
    ratio = default(ratio, 2.0 / 3)
    opacity1 = round((1 - ratio) * 257)
    opacity2 = round((ratio) * 257)
    c
    Interleave( \
        Layer(SelectEvery(4, 0), SelectEvery(4, 1), level=opacity1), \
        Layer(SelectEvery(4, 2), SelectEvery(4, 3), level=opacity2) \
    )
}

function Replace(clip c, int i, int j, clip d) {
    Assert(i >= 0, "Replace: parameter i is negative")
    Assert(j >= 0, "Replace: parameter j is negative")
    p1 = c.Trim(0, -i)
    p2 = d.Trim(i, j)
    p3 = c.Trim(j + 1, 0)
    p1 = (i == 0) ? c.Trim(0, -1).DeleteFrame(0) : p1
    p3 = (j == 0) ? c.Trim(0, -1).DeleteFrame(0) : p3
    p1 + p2 + p3
    return (c.HasAudio) ? last.AudioDub(c) : last
}

last
