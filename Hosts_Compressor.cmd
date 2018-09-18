@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/Hosts-Compressor
rem =====

setlocal ENABLEDELAYEDEXPANSION
if "%~1"=="" echo Please drag and drop a host file to be compressed&pause&exit




rem Blackhole address for source file
set FROM_BLACKHOLE=0.0.0.0

rem Blackhole address for resultant file
set TO_BLACKHOLE=0.0.0.0

rem Compression from 1 to 9 domains per line
set COMPRESSION=9






echo Compressing "%~1" to "%~dp0compressed-%~nx1"...
set TYPE=
set PTYPE=
set COUNT=0
set GLOB=
(for /f "tokens=1,2*" %%a in (
'findstr /b "!FROM_BLACKHOLE!" "%~s1" ^| findstr /v "0[.]0[.]0[.]0.[0-9][0-9]*[.][0-9][0-9]*[.][0-9][0-9]*[.][0-9][0-9]*"'
) do @(
set LINE=%%a
if "!LINE:~,1!"=="#" set TYPE=COMMENT
if "%%a"=="!FROM_BLACKHOLE!" set TYPE=DOMAIN
if not "!TYPE!"=="!PTYPE!" (
if "!GLOB:~,2!"==" #" (
echo !GLOB:~1!
) else (
if not "!GLOB!"=="" echo !TO_BLACKHOLE!!GLOB!
)
set COUNT=0
set GLOB=
)
if "!TYPE!"=="COMMENT" (
set GLOB=!GLOB! !LINE!
set COUNT=0
)
if "!TYPE!" == "DOMAIN" (
set GLOB=!GLOB! %%b
set /a COUNT=!COUNT!+1
if !COUNT!==!COMPRESSION! (
echo !TO_BLACKHOLE!!GLOB!
set GLOB=
set COUNT=0
)
)
set PTYPE=!TYPE!
set TYPE=
)
if "!PTYPE!"=="COMMENT" echo !GLOB:~1!
if "!PTYPE!"=="DOMAIN" echo !TO_BLACKHOLE!!GLOB!
) > "%~dp0compressed-%~nx1"
echo "%1" compressed to "%~dp0compressed-%~nx1"
pause