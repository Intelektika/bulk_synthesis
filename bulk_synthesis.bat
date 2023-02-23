@echo off

rem DOS batch script to be launched from command prompt in Windows
rem Assumes 'curl' is installed (Windows 10, version 1803 or later)
rem
rem key   <- personal service key 
rem voice <- selected voice [astra, lina, laimis, vytautas]
rem speed <- 1 - normal, 0.75 - faster, 1.5 - slower
rem ext   <- extension of an audio filename [mp3, m4a]

set key=USER_SERVICE_KEY
set voice=laimis
set speed=1
set ext=m4a
    
rem save current code page to the `_chcp` variable
for /F "tokens=2 delims=:" %%G in ('chcp') do set "_chcp=%%G"
chcp 65001>nul      

goto START

rem SUBROUTINE 'print_syntax' -------------------------------------------------
:print_syntax
  echo.
  echo Command syntax: bulk_synthesis.bat list [filenames], where
  echo.
  echo   list      is a list of sentences (UTF-8 encoded) to by synthesized
  echo   filenames is an optional list of filenames given for each sentence.
  echo             It must have the same number of lines as the 'list'.
  echo             If 'filenames' is missing, the sentence itself will be
  echo             taken as a filename.
  echo.
  echo   e.g. bulk_synthesis.bat sentences.txt
  echo. 
  echo   or   bulk_synthesis.bat sentences.txt filenames.txt
  echo.
  exit /b

rem SUBROUTINE 'process_sentence' -------------------------------------------------
:process_sentence
  rem %1 - text
  rem %2 - filename

  echo %1

  rem remove separators [:?!.] from the filename
  set fname=%2
  set fname=%fname::=%
  set fname=%fname:?=%
  set fname=%fname:!=%
  set fname=%fname:.=%

  echo {"text":%1, "outputFormat":"%ext%", "outputTextFormat":"none", "speed":%speed%, "voice":"%voice%"} > tmp.json

  curl -s -X POST https://sinteze.intelektika.lt/synthesis.service/prod/synthesize ^
  -H "Accept: application/json" ^
  -H "Content-Type: application/json; charset=utf-8" ^
  -H "Authorization: Key %key%" ^
  -d @tmp.json | jq-win64.exe -r ."audioAsString" > tmp.txt
  certutil -f -v -decode tmp.txt %fname%."%ext%" >nul
  del tmp.json tmp.txt
  exit /b

:START

if [%1]==[] (
    echo The file containing the list of sentences must given as an argument.
    call :print_syntax
    pause
    exit /b -1
)

if not exist "%1" (
    echo File '%1' cannot be found.
    pause
    exit /b -1
)

if not [%2]==[] (
  if not exist "%2" (
    echo File '%2' cannot be found.
    pause
    exit /b -1
  )
)

if not exist jq-win64.exe (
    echo File 'jq-win64.exe' must be present in the current folder.
    pause
    exit /b -1
)

setlocal ENABLEDELAYEDEXPANSION
rem Load filename list if it is specified by %2 
if exist "%2" (
  set count=0
  for /F "tokens=*" %%L in (%2) do (
    set /a count+=1
    set fnames[!count!]=%%L
  )
)

rem iterate over the sentence list specified by %1
set count=0
for /F "tokens=*" %%L in (%1) do (
  set /a count+=1
  if [%fnames[!count!]%]==[] ( 
    rem Use the content of a sentence as a filename
    call :process_sentence "%%L" "%%L"
  ) else (
    rem Use a different filename
    call :process_sentence "%%L" %%fnames[!count!]%%
  )
)

rem Set active code page back to previously saved value
chcp %_chcp%>nul

pause
exit /b 0
