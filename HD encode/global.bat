:: feos & Guga, 2012
:: Global batch to use along with Hybride Encode Script:
:: http://tasvideos.org/EncodingGuide/HybridEncodeScript.html
:: Uses MKV instead of MP4
:: Uses replacetext to edit the script directly and create all 3 encodes:
:: http://pastebin.com/bjpGndKv
:: Asks to specify SAR according to the platform:
:: http://tasvideos.org/EncodingGuide/Encoding.html

:: ::::::::::: ::
:: :: AUDIO :: ::
:: ::::::::::: ::

:: For DeDupped videos ::
venc -q2 audio.wav audio.ogg

:: For 512kb ::
sox audio.wav -t wav - trim 4672s | neroAacEnc -q 0.25 -if - -of audio.mp4

:: ::::::::::: ::
:: :: VIDEO :: ::
:: ::::::::::: ::

@echo off
echo Specify SAR please:
set /p INPUT=

:: Generate times ::
replacetext "encode.avs" "pass = 0" "pass = 1"
x264.exe --sar "%INPUT%" --keyint infinite --crf 0 --range pc --input-range pc -o NUL encode.avs --preset ultrafast
replacetext.vbs "encode.avs" "pass = 1" "pass = 2"

:: 10bit444 ::
replacetext.vbs "encode.avs" "i444 = false" "i444 = true"
x264-10 --threads auto --sar "%INPUT%" --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me umh --merange 64 --subme 10 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --input-range pc --range pc --tcfile-in times.txt -o video_10bit444.mkv --colormatrix smpte170m --output-csp i444 encode.avs

:: 512kb ::
replacetext.vbs "encode.avs" "pass = 2" "pass = 0"
replacetext.vbs "encode.avs" "i444 = true" "i444 = false"
x264.exe --threads auto --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me umh --merange 64 --subme 10 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --range tv --input-range tv --colormatrix smpte170m -o video_512kb.mp4 encode.avs

:: Primary downloadable ::
replacetext.vbs "encode.avs" "pass = 0" "pass = 2"
x264.exe --threads auto --sar "%INPUT%" --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me umh --merange 64 --subme 10 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --range pc --input-range pc --colormatrix smpte170m --tcfile-in times.txt -o video.mkv encode.avs

:: :::::::::::: ::
:: :: MUXING :: ::
:: :::::::::::: ::

:: Primary ::
mkvmerge -o encode.mkv --timecodes -1:times.txt video.mkv audio.ogg

:: 10bit444 ::
mkvmerge -o encode_10bit444.mkv --timecodes -1:times.txt video_10bit444.mkv audio.ogg

:: 512kb ::
MP4Box -add video_512kb.mp4 -add audio.mp4 -new encode_512kb.mp4

:: Restore AVS default ::
replacetext.vbs "encode.avs" "pass = 2" "pass = 0"

PAUSE