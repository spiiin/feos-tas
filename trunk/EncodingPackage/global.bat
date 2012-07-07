:: feos, 2012 (cheers to Guga, Velitha amd nanogyth)
:: This global batch is a part of "TAS Encoding Package":
:: http://tasvideos.org/EncodingGuide/HybridEncodeScript.html
:: Asks whether the console is TV based to autoset the SAR parameter.

:: Restore AVS defaults ::
"./programs/replacetext" "encode.avs" "pass = 1" "pass = 0"
"./programs/replacetext" "encode.avs" "pass = 2" "pass = 0"
"./programs/replacetext" "encode.avs" "i444 = true" "i444 = false"
"./programs/replacetext" "encode.avs" "hd = true" "hd = false"
"./programs/replacetext" "encode.avs" "ng_bighalo( \" "Subtitle( \"

: AUDIO
"./programs/avs2pipemod" -wav encode.avs | "./programs/venc" -q2 - "./temp/audio.ogg"
"./programs/avs2pipemod" -wav encode.avs | "./programs/sox" -t wav - -t wav - trim 4672s | "./programs/neroAacEnc" -q 0.25 -if - -of "./temp/audio.mp4"
"./programs/avs2pipemod" -wav encode.avs | "./programs/venc" -q10 - "./temp/audio_youtube.ogg"

@echo off
SET /P ANSWER=Is this a TV based console? (y/n)
if "%ANSWER%"=="n" (
SET VAR=1:1
"./programs/replacetext" "encode.avs" "handheld = false" "handheld = true"
goto VIDEO
)

:: Automatic SAR calculation ::
"./programs/replacetext" "encode.avs" "handheld = true" "handheld = false"
"./programs/replacetext" "encode.avs" "pass = 0" "pass = 1"
"./programs/avs2pipemod" -info encode.avs > "./temp/info.txt"
FOR /F "tokens=2" %%G IN ('FIND "width" "./temp/info.txt"') DO (SET width=%%G)
FOR /F "tokens=2" %%G IN ('FIND "height" "./temp/info.txt"') DO (SET height=%%G)
set /A "SAR_w=4 * %height%"
set /A "SAR_h=3 * %width%"
set VAR=%SAR_w%:%SAR_h%
"./programs/replacetext" "encode.avs" "pass = 1" "pass = 0"

: VIDEO
:: Generate times ::
"./programs/replacetext" "encode.avs" "pass = 0" "pass = 1"
"./programs/avs2pipemod" -benchmark encode.avs
"./programs/x264" --sar "%VAR%" --keyint infinite --crf 0 --range pc --input-range pc -o NUL encode.avs --preset ultrafast
"./programs/replacetext" "encode.avs" "pass = 1" "pass = 2"

:: Primary downloadable ::
"./programs/x264" --threads auto --sar "%VAR%" --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me umh --merange 64 --subme 10 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --range pc --input-range pc --colormatrix smpte170m --tcfile-in "./temp/times.txt" -o "./temp/video.mkv" encode.avs
PING -n 2 127.0.0.1>nul

:: 10bit444 downloadable ::
"./programs/replacetext" "encode.avs" "i444 = false" "i444 = true"
"./programs/x264-10" --threads auto --sar "%VAR%" --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me umh --merange 64 --subme 10 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --input-range pc --range pc --tcfile-in "./temp/times.txt" -o "./temp/video_10bit444.mkv" --colormatrix smpte170m --output-csp i444 encode.avs
PING -n 2 127.0.0.1>nul

:: Archive 512kb stream ::
"./programs/replacetext" "encode.avs" "pass = 2" "pass = 0"
"./programs/replacetext" "encode.avs" "i444 = true" "i444 = false"
"./programs/x264" --threads auto --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me umh --merange 64 --subme 10 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --range tv --input-range tv --colormatrix smpte170m -o "./temp/video_512kb.mp4" encode.avs
PING -n 2 127.0.0.1>nul

:: YouTube HD stream ::
"./programs/replacetext" "encode.avs" "hd = false" "hd = true"
"./programs/replacetext" "encode.avs" "Subtitle( \" "ng_bighalo( \"
"./programs/x264" --qp 0 --keyint 600 --output "./temp/video_youtube.mkv" encode.avs
"./programs/replacetext" "encode.avs" "hd = true" "hd = false"
"./programs/replacetext" "encode.avs" "ng_bighalo( \" "Subtitle( \"

: MUXING
"./programs/mkvmerge" -o "./output/encode.mkv" --timecodes -1:"./temp/times.txt" "./temp/video.mkv" "./temp/audio.ogg"
"./programs/mkvmerge" -o "./output/encode_10bit444.mkv" --timecodes -1:"./temp/times.txt" "./temp/video_10bit444.mkv" "./temp/audio.ogg"
"./programs/MP4Box" -add "./temp/video_512kb.mp4" -add "./temp/audio.mp4" -new "./output/encode_512kb.mp4"
"./programs/mkvmerge" -o "./output/encode_youtube.mkv" --compression -1:none "./temp/video_youtube.mkv" "./temp/audio_youtube.ogg"