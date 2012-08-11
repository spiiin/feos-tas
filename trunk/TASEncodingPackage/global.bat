:: feos, 2012 (cheers to Guga, Velitha and nanogyth)
:: This global batch is a part of "TAS Encoding Package":
:: http://tasvideos.org/EncodingGuide/HybridEncodeScript.html
:: Asks whether the console is TV based to autoset the SAR parameter.
:: Allows to select the encode to make.

@echo off
:: Restore AVS defaults ::
"./programs/replacetext" "encode.avs" "pass = 1" "pass = 0"
"./programs/replacetext" "encode.avs" "pass = 2" "pass = 0"
"./programs/replacetext" "encode.avs" "i444 = true" "i444 = false"
"./programs/replacetext" "encode.avs" "hd = true" "hd = false"

echo.
echo -----------------------
echo  Hybrid Encoding Batch 
echo -----------------------
echo.

: SAR OPTIONS
echo Is this a TV based console? (y/n)
set /p ANSWER=
if "%ANSWER%"=="y" goto TV sar
if "%ANSWER%"=="n" goto handheld sar
echo I'm not kidding!
goto SAR OPTIONS

: TV sar
"./programs/replacetext" "encode.avs" "handheld = true" "handheld = false"
"./programs/replacetext" "encode.avs" "pass = 0" "pass = 1"
"./programs/avs2pipemod" -info encode.avs > "./temp/info.txt"
for /f "tokens=2" %%G in ('FIND "width" "./temp/info.txt"') do (set width=%%G)
for /f "tokens=2" %%G in ('FIND "height" "./temp/info.txt"') do (set height=%%G)
set /a "SAR_w=4 * %height%"
set /a "SAR_h=3 * %width%"
set VAR=%SAR_w%:%SAR_h%
"./programs/replacetext" "encode.avs" "pass = 1" "pass = 0"
goto ENCODE OPTIONS

: handheld sar
set VAR=1:1
"./programs/replacetext" "encode.avs" "handheld = false" "handheld = true"
goto ENCODE OPTIONS

: ENCODE OPTIONS
echo.
echo What encode do you want to do?
echo.
echo Press 1 for Primary Downloadable.
echo Press 2 for 10-bit Downloadable.
echo Press 3 for 512kb Stream [Archive.org].
echo Press 4 for HD Stream [YouTube.com].
echo Press 5 for All of the above.

: Set choise
set /p EncodeChoice=
if "%EncodeChoice%"=="1" goto Timecodes
if "%EncodeChoice%"=="2" goto Timecodes
if "%EncodeChoice%"=="3" goto 512kb
if "%EncodeChoice%"=="4" goto HD
if "%EncodeChoice%"=="5" goto Timecodes
echo.
echo You better choose something real!
goto Set choise

: Timecodes
:: Audio for downloadables ::
"./programs/avs2pipemod" -wav encode.avs | "./programs/venc" -q2 - "./temp/audio.ogg"
echo.
echo ----------------------
echo  Generating timecodes 
echo ----------------------
echo.
"./programs/replacetext" "encode.avs" "pass = 0" "pass = 1"
"./programs/avs2pipemod" -benchmark encode.avs
"./programs/replacetext" "encode.avs" "pass = 1" "pass = 2"
if "%EncodeChoice%"=="1" goto Primary
if "%EncodeChoice%"=="2" goto 10bit444

: Primary
echo.
echo -------------------------------
echo  Encoding primary downloadable 
echo -------------------------------
echo.
:: Video ::
"./programs/x264" --threads auto --sar "%VAR%" --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me tesa --merange 64 --subme 11 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --range pc --input-range pc --colormatrix smpte170m --tcfile-in "./temp/times.txt" -o "./temp/video.mkv" encode.avs
:: Muxing ::
"./programs/mkvmerge" -o "./output/encode.mkv" --timecodes -1:"./temp/times.txt" "./temp/video.mkv" "./temp/audio.ogg"
if "%EncodeChoice%"=="1" goto Defaults

: 10bit444
echo.
echo --------------------------------
echo  Encoding 10bit444 downloadable 
echo --------------------------------
echo.
:: Video ::
"./programs/replacetext" "encode.avs" "i444 = false" "i444 = true"
"./programs/x264-10" --threads auto --sar "%VAR%" --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me tesa --merange 64 --subme 11 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --input-range pc --range pc --tcfile-in "./temp/times.txt" -o "./temp/video_10bit444.mkv" --colormatrix smpte170m --output-csp i444 encode.avs
:: Mixong ::
"./programs/mkvmerge" -o "./output/encode_10bit444.mkv" --timecodes -1:"./temp/times.txt" "./temp/video_10bit444.mkv" "./temp/audio.ogg"
if "%EncodeChoice%"=="2" goto Defaults

: 512kb
:: Audio ::
"./programs/avs2pipemod" -wav encode.avs | "./programs/sox" -t wav - -t wav - trim 4672s | "./programs/neroAacEnc" -q 0.25 -if - -of "./temp/audio.mp4"
echo -------------------------------
echo  Encoding Archive 512kb stream 
echo -------------------------------
echo.
:: Video ::
"./programs/replacetext" "encode.avs" "pass = 2" "pass = 0"
"./programs/replacetext" "encode.avs" "i444 = true" "i444 = false"
"./programs/x264" --threads auto --crf 20 --keyint 600 --ref 16 --no-fast-pskip --bframes 16 --b-adapt 2 --direct auto --me umh --merange 24 --subme 10 --trellis 2 --partitions all --rc-lookahead 250 --no-dct-decimate --range tv --input-range tv --colormatrix smpte170m -o "./temp/video_512kb.mp4" encode.avs
:: Muxong ::
"./programs/MP4Box" -hint -add "./temp/video_512kb.mp4" -add "./temp/audio.mp4" -new "./output/encode_512kb.mp4"
if "%EncodeChoice%"=="3" goto Defaults

: HD
:: Audio ::
"./programs/avs2pipemod" -wav encode.avs | "./programs/venc" -q10 - "./temp/audio_youtube.ogg"
echo.
echo ----------------------------
echo  Encoding YouTube HD stream 
echo ----------------------------
echo.
:: Video ::
"./programs/replacetext" "encode.avs" "hd = false" "hd = true"
"./programs/x264" --qp 0 --keyint 600 --output "./temp/video_youtube.mkv" encode.avs
"./programs/replacetext" "encode.avs" "hd = true" "hd = false"
:: Muxong ::
"./programs/mkvmerge" -o "./output/encode_youtube.mkv" --compression -1:none "./temp/video_youtube.mkv" "./temp/audio_youtube.ogg"

: Defaults
"./programs/replacetext" "encode.avs" "pass = 1" "pass = 0"
"./programs/replacetext" "encode.avs" "pass = 2" "pass = 0"
"./programs/replacetext" "encode.avs" "i444 = true" "i444 = false"
"./programs/replacetext" "encode.avs" "hd = true" "hd = false"