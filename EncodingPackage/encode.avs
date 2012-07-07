# The downloadable / HD encoding script. For more information, see:
# http://tasvideos.org/EncodingGuide/HybridEncodeScript.html

#################
# USER SETTINGS #
#################

# Replace "-0" with a framenumber to trim the source video after
AVISource("movie.avi").Trim(0, -0).ConvertToRGB32()

# The below filename is the filename of your logo, be sure to keep the "" tags.
# Several methods prevent the logo distortion:
# 1) Separate logo for each aspect ratio the console has, except if it's TV based.
# 2) 4:3 aspect ratio for TV based consoles.
# 3) Logo resolution above 720.
# file = "logo.png"

# Edit the below items to adjust the subtitles text.
# All the required information will be on the movie's submission page.
# Be sure to keep the quotes everywhere, even when branch is blank ("").
game = "Metroid Fusion"
branch = "100%"
author = "BioSpark"
time = "1:35:19.3"
rerecords = "143141"

# This sets the start time for the subtitles to start displaying.
# A good choise is the beginning of the first level.
# This is set as a frame number.
subff = 400

# This sets the y position for the subtitles,
# basically, how high or low they are up on the screen.
# The higher the number, the lower the subtitles.
# Make sure the subtitles don't obstruct any important action
ypos = 2

####################
# DEFAULT SETTINGS #
####################

# This setting turns the audio/video desync fixer on/off using true/false.
# The below should always be set to false, barring the unusual occasion that it
# actually fixes the audio.
desyncfixer = false

# Below is the size for the subtitles, standard encodes use a size of 10.
subsize = 10

# This controls how long the subtitles stay on the screen.
sublength = 300

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

# If you are sure, there's no frame altering flickering in the movie,
# or the game runs at half normal framerate, you can set this to false
# Has no effect if hd = false.
blend = true

# Set this to true to use the new advanced ng_deblink instead of TasBlend.
# Generally better.  Has no effect if blend = false or hd = false.
ngdb = true

# This setting adjusts the framerate for HD encodes when uploading to YouTube.
# This is to save space due to YouTube having a maximum framerate of 30 anyway.
# It is suggested to be at either 24 fps or 30fps for NTSC games (Depending on
# if they use alternating frame flicker or not).
# PAL games should generally be set to 30 fps, it can be set to 25 fps if there
# is no flickering, but it's difficult to notice the strobing effect in 30fps
# anyway. If you have ng_deblink enabled, you can ignore this.
hdframerate = 30

######################
# AUTOMATED SETTINGS #
######################

LoadPlugin("./programs/ExactDedup.dll")
LoadPlugin("./programs/mvtools2.dll")
LoadPlugin("./programs/mt_masktools-26.dll")

# Batch sets this flag for HD encodings.
# After uploading to YouTube, add "yt:stretch=4:3" tag to resulting video
# to correct the aspect ratio for TV consoles (not for handhelds)
hd = false

file = hd ? "hdlogo.png" :"logo.png"

# Batch sets this flag for handhelds, computers and arcade machines.
handheld = false

# Autoadjust the timing due to HD framerate reduction
subff = hd ? subff / 2 + 1 : subff
sublength = hd ? sublength / 2 : sublength

# This sets the start time for the second set of subtitles to start displaying,
# this is set as a frame number. Make sure there's at least a delay of 1 frame
# in between this set and the previous one.
subff2 = subff + sublength + 1

# This controls how long the second set of subtitles stay on the screen.
sublength2 = sublength

# Batch sets this flag for 10 bit 444 encodes.
i444 = false

# Batch sets a pass for downloadable/streaming encodes:
# 0: audio extraction / streaming (archive.org 512kb; AR correction);
# 1: DupMC (no AR correction);
# 2: DeDup (no AR correction).
pass = 0

# THE BELOW CODE SHOULDN'T BE MODIFIED UNLESS YOU KNOW WHAT YOU ARE DOING!
# This automatically fixes length based audio/video desync if it exists inside
# the encode (eg. Many PCEngine games).
num = last.AudioLengthF * last.FrameRateNumerator
denom = last.FrameCount * last.FrameRateDenominator
fixedaudiorate = Round(num / denom)
(desyncfixer) ? last.AssumeSampleRate(fixedaudiorate) : 0

# blended = last.TASBlend()
hd ? (blend ? (ngdb ? ng_deblink.selectodd : TasBlend()) : ChangeFPS(hdframerate)) : 0

# someone really likes these nonsensical clip names, so they shall remain untouched
sourcevideo = last

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

# This is set of subtitles.
# This shouldn't be modified unless you know what you are doing
Subtitle( \
    game + "\n" + ( \
        (branch == "") ? "" : branch + "\n" \
    ) + "Played by " + author + "\nPlaying time: " + \
    time + "\nRerecord count: " + rerecords, y=(ypos * multi), \
    align=position, first_frame=subff, last_frame=(subff + sublength), \
    size=(subsize * multi), text_color=$00FFFFFF, halo_color=$00000000, lsp=2 \
)

Subtitle( \
    "This is a tool\nassisted recording.\nFor details, visit\n" + \
    "http://TASVideos.org/", y=(ypos * multi), \
    align=position, first_frame=subff2, last_frame=(subff2 + sublength2), \
    size=(subsize * multi), text_color=$00FFFFFF, halo_color=$00000000, lsp=2 \
)

# Downloadable encodes need a resizing filter for the colourspace reduction.
# HD encodes need to be point resized to keep the colour information faithful.
ConvertToYV24(chromaresample="point", matrix=(hd ? "Rec709" : "PC.601") )
(pass == 1) ? ExactDedup( \
    firstpass=true, dupinfo="./temp/dup.txt", times="./temp/times.txt" \
) : last
(pass == 2) ? ExactDedup(firstpass=false, dupinfo="./temp/dup.txt") : last
i444 ? last : ConvertToYV12( \
        chromaresample=(hd ? "point" : "lanczos"), \
        matrix=(hd ? "Rec709" : (pass == 0 ? "Rec601" : "PC.601")) \
)

####################
# CUSTOM FUNCTIONS #
####################

# nanogyth's deblink.
function ng_deblink(clip clp,
\ float "ratio",
\ int "level",
\ clip "blinkmask"
\){
#Version 10 2012.04.22

    blink = default(blinkmask, clp.ng_blinkmask())

    ratio = default(ratio, 2.0 /3)
    assert(ratio >= 0.0 && 1.0 >= ratio,
    \      "[ng_deblink] 1.0 >= ratio >= 0.0, it was " + string(ratio))

    level = default(level, round(ratio * 257))
    assert(level >= 0 && 257 >= level,
    \      "[ng_deblink] 257 >= level >= 0, it was " + string(level))

    m01=mt_logic(blink.SelectEvery(4,0),
\                blink.SelectEvery(4,1),
\                mode="or").ConvertToRGB32()
    m23=mt_logic(blink.SelectEvery(4,2),
\                blink.SelectEvery(4,3),
\                mode="or").ConvertToRGB32()

    f0=Layer(clp.SelectEvery(4,0),
\            clp.SelectEvery(4,1).Mask(m01),
\            level=level)
    f1=Layer(clp.SelectEvery(4,1),
\            clp.SelectEvery(4,0).Mask(m01),
\            level=level)
    f2=Layer(clp.SelectEvery(4,2),
\            clp.SelectEvery(4,3).Mask(m23),
\            level=(257-level) )
    f3=Layer(clp.SelectEvery(4,3),
\            clp.SelectEvery(4,2).Mask(m23),
\            level=(257-level) )

    Interleave(f0,f1,f2,f3)
}

function ng_blinkmask(clip clp,
\ bool "TEST",
\ bool "STABILIZE",
\ bool "SHARP",
\ bool "HYSTER",
\ int "inpand",
\ int "expand",
\ int "ml"
\){
#Version 10 2012.04.22

#BLINK
# Blinking is a block that alternates on/off each frame
# SelectEven would only see either the on or the off

#FLASH
# Flashing is a block that is only on for a single frame
# SelectEven might miss the flash

#SHAKE
# Shaking is a block that moves back/forth each frame
# SelectEven would only see one position

# The goal of this function is to make a blink mask for use with
# ng_deblink. For overly complicated scenes where a clean blinkmask
# can't be found, just use TASBlend. Uniform softness looks better
# than sharp artifacts.

# This function calculates flash and shake info for the test script,
# but those effects should be handled in different ways.
# Flash - choose frames to make sure the flash is in your final clip.
# Shake - SelectEvery(4,0,2,1,3) or SelectEvery(4,1,0,2,3)
# SelectEvery doesn't generally work because it messes with the fluidity
# of motion. But that won't be noticable on a shaking screen.
# Be careful if 2 frame blinking is present, as the selectevery can turn
# it into 1 frame blinking.

    TEST      = default(     TEST, false)
    STABILIZE = default(STABILIZE, true)
    SHARP     = default(    SHARP, true)
    HYSTER    = default(   HYSTER, false)
    inpand    = default(   inpand, 1)
    expand    = default(   expand, 1)
    ml        = default(       ml, 128)

# The functions used to make the masks work in the YV12 colorspace. Once
# the masks are created they can be used in the RGB32 colorspace direcly
    src=clp.ConvertToYV12()

# Blinking is located by looking for blocks that don't exist in
# consecutive frames. The motion vector will match blocks that exist in
# both frames. The blocks that aren't in both will end up with huge
# values that are picked out by the motion mask.
    super = MSuper(src, pel=1)
    fvec  = MAnalyse(super, isb=false, blksize=4)
    bvec  = MAnalyse(super, isb=true , blksize=4)
    fmask = Mmask(src, fvec, kind=1, ml=ml).mt_binarize()
    bmask = Mmask(src, bvec, kind=1, ml=ml).mt_binarize()
    blink = mt_logic(fmask, bmask, mode="and")

# Blinking usually occurs against a stable background. This is found
# by looking at blocks 2 frames apart. This distinguishes a blink from
# blocks that are just changing every frame.
    ee_src   = src.SelectEven()
    ee_super = MSuper(ee_src, pel=1)
    ee_fvec  = MAnalyse(ee_super, isb=false, blksize=4)
    ee_bvec  = MAnalyse(ee_super, isb=true , blksize=4)
    ee_fmask = Mmask(ee_src, ee_fvec, kind=1, ml=ml).mt_binarize()
    ee_bmask = Mmask(ee_src, ee_bvec, kind=1, ml=ml).mt_binarize()

    oo_src   = src.SelectOdd()
    oo_super = MSuper(oo_src, pel=1)
    oo_fvec  = MAnalyse(oo_super, isb=false, blksize=4)
    oo_bvec  = MAnalyse(oo_super, isb=true , blksize=4)
    oo_fmask = Mmask(oo_src, oo_fvec, kind=1, ml=ml).mt_binarize()
    oo_bmask = Mmask(oo_src, oo_bvec, kind=1, ml=ml).mt_binarize()

    fmask_2   = Interleave(ee_fmask, oo_fmask)
    bmask_2   = Interleave(ee_bmask, oo_bmask)
    background = mt_logic(fmask_2.SelectEvery(1,1),
\                         bmask_2.SelectEvery(1,-1),
\                         mode="or")
    stable_blink = mt_hysteresis(background.mt_invert, blink)
    blink2 = (STABILIZE) ? stable_blink : blink

# Shrinking the blink mask can get rid of noise,
# too much will lose signal as well.
    blink3 = blink2.mt_inpand(mode=mt_diamond(inpand))
    
# Using just pixels that changed helps sharpen the mask
    diff   = ng_diff(clp.SelectEvery(1,-1), clp)
    diff_2 = mt_logic(diff, diff.SelectEvery(1,1), mode="and")

#Hysteresis
# Matches continuous blocks of pixels.
# Use with care, will match the whole screen on fades.
    hyster_blink = mt_hysteresis(blink3, diff_2)

# Expand the mask to make up for shrinking it (or just use hysteresis)
    blink4 = blink3.mt_expand(mode=mt_circle(expand))
    sharp_blink = mt_logic(blink4, diff_2, mode="and")

    blink5 = (HYSTER) ? hyster_blink :
\            (SHARP)  ? sharp_blink  : blink4

    
# A flash won't match blocks 1 or 2 frames away.
    sub_flash = mt_logic(fmask_2, bmask_2, mode="and")
    flash     = mt_logic(blink, sub_flash, mode="and")
    
# A shake changes in one frame and changes back in the next.
# This isn't detected by the motion vectors because the blocks exist in
# both frames, they are just shifting around.
    same   = ng_same(clp.SelectEvery(1,-1), clp.SelectEvery(1,1))
    shake  = mt_logic(same, diff_2, mode="and")

    (TEST) ? stackhorizontal(clp, mergeRGB(blink5, flash, shake))
\          : blink5.GreyScale()
}

function ng_diff(clip A, clip B, int "thr"){
    thr=default(thr,0)
    TAD=ng_TAD(A,B)
    return mt_binarize(TAD, threshold=thr)
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

# nanogyth's big halo subtitles for HD.
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
\ int "halo_radius",
\ string "memo"
\){

#Version 7
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

    invis=BlankClip(clp, length=1, pixel_type="YV12")
    text_mask=Subtitle(invis, text, x, y, 0, 0, font, size, $00FFFFFF,
\                      $80808080, align, spc, lsp, font_width, font_angle)
    halo_mask=mt_logic(text_mask,
\                      text_mask.mt_expand(mode=mt_circle(halo_radius)),
\                      mode="xor")

    hc=BlankClip(clp, length=1, color=halo_color)
    tc=Subtitle(hc, text, x, y, 0, 0, font, size, text_color,
\               $FF000000, align, spc, lsp, font_width, font_angle)


    h_alpha=(halo_color >= 0) ? 255 - halo_color/$01000000
\                             :  -(halo_color+1)/$01000000
    t_alpha=(text_color >= 0) ? 255 - text_color/$01000000
\                             :  -(text_color+1)/$01000000

    lut_str=string(h_alpha)+" x * 255 / "+string(t_alpha)+" y * 255 / max"
    mm3=tc.Mask(mt_lutxy(halo_mask, text_mask, lut_str).ConvertToRGB32())

    mm4=Defined(memo) ? (
\       Exist(memo+"0.bmp") ? ImageSource(memo+"0.bmp")
\                        : mm3.ImageWriter(memo+"%d.bmp")
\                   ) : mm3

    clp.ApplyRange(first_frame, last_frame, "Layer", mm4)
}

# TASBlend.
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

# Replace for partial blending.
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
