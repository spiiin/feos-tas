:: feos, 1012 (cheers to Guga and Velitha)
:: Global batch to use along with Hybride Encode Script:
:: http://tasvideos.org/EncodingGuide/HybridEncodeScript.html
:: Uses replacetext to edit the script directly and create all 3 encodes:
:: http://pastebin.com/bjpGndKv
:: Asks to specify SAR according to the platform:
:: http://tasvideos.org/EncodingGuide/Encoding.html

:: Restore AVS defaults ::
"./programs/replacetext" "encode.avs" "pass = 1" "pass = 0"
"./programs/replacetext" "encode.avs" "pass = 2" "pass = 0"
"./programs/replacetext" "encode.avs" "i444 = true" "i444 = false"

:: AUDIO ::
"./programs/venc" -q2 audio.wav "./temp/audio.ogg"
"./programs/sox" audio.wav -t wav - trim 4672s | "./programs/neroAacEnc" -q 0.25 -if - -of "./temp/audio.mp4"

:: VIDEO ::
@echo off
echo.
echo Specify SAR please:
set /p INPUT=

:: Generate times ::
"./programs/replacetext" "encode.avs" "pass = 0" "pass = 1"
"./programs/x264" --sar "%INPUT%" --keyint infinite --crf 0 --range pc --input-range pc -o NUL encode.avs --preset ultrafast
"./programs/replacetext" "encode.avs" "pass = 1" "pass = 2"

:: Primary downloadable ::
"./programs/x264" --threads auto --sar "%INPUT%" --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me umh --merange 64 --subme 10 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --range pc --input-range pc --colormatrix smpte170m --tcfile-in "./temp/times.txt" -o "./temp/video.mkv" encode.avs
PING -n 2 127.0.0.1>nul

:: 10bit444 downloadable ::
"./programs/replacetext" "encode.avs" "i444 = false" "i444 = true"
"./programs/x264-10" --threads auto --sar "%INPUT%" --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me umh --merange 64 --subme 10 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --input-range pc --range pc --tcfile-in "./temp/times.txt" -o "./temp/video_10bit444.mkv" --colormatrix smpte170m --output-csp i444 encode.avs
PING -n 2 127.0.0.1>nul

:: Archive 512kb stream ::
"./programs/replacetext" "encode.avs" "pass = 2" "pass = 0"
"./programs/replacetext" "encode.avs" "i444 = true" "i444 = false"
"./programs/x264.exe --threads auto --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me umh --merange 64 --subme 10 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --range tv --input-range tv --colormatrix smpte170m -o "./temp/video_512kb.mp4" encode.avs
PING -n 2 127.0.0.1>nul

:: MUXING ::
mkvmerge -o "./output/encode.mkv" --timecodes -1:"./temp/times.txt" "./temp/video.mkv" "./temp/audio.ogg"
mkvmerge -o "./output/encode_10bit444.mkv" --timecodes -1:"./temp/times.txt" "./temp/video_10bit444.mkv" "./temp/audio.ogg"
"./programs/MP4Box" -add "./temp/video_512kb.mp4" -add "./temp/audio.mp4" -new "./output/encode_512kb.mp4"