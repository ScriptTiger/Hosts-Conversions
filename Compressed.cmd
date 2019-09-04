@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/Hosts-Conversions
rem =====

rem Error if no input file given
if "%~1"=="" (
	echo Please drag and drop a host file to be compressed
	pause
	exit
)

setlocal ENABLEDELAYEDEXPANSION

rem =====
rem Read the below section carefully and adjust any variables as neeeded

rem Blackhole address for source file
set FROM_BLACKHOLE=0.0.0.0

rem Blackhole address for resultant file
set TO_BLACKHOLE=0.0.0.0

rem Compression from 1 to 9 domains per line
set COMPRESSION=9

rem 0 to remove commments, 1 to keep them
set COMMENTS=0

rem =====

echo Compressing "%~1" to "%~dp0compressed-%~nx1"...

rem (De-)initialize iterating variables
set TYPE=
set PTYPE=
set COUNT=0
set GLOB=

rem Capture all output to a single write operation data stream
rem Forcing a write operating each line is considerably slower when dealing with files of higher line counts
(
	rem Read from the source hosts file and enfore clean input
	for /f "tokens=1,2*" %%a in (
		'findstr /b "!FROM_BLACKHOLE:.=[.]! #" "%~s1" ^| findstr /b /v /c:"0.0.0.0 0.0.0.0"'
	) do (
		set LINE=%%a
		set SKIP=0
		rem Identify comment lines and handle accordingly
		if "!LINE:~,1!"=="#" (
			rem If comments should be removed, ignore and skip handling them altogether
			if !COMMENTS!==0 (set SKIP=1) else set TYPE=COMMENT
		)
		if !SKIP!==0 (
			if "%%a"=="!FROM_BLACKHOLE!" set TYPE=DOMAIN
			rem If comments are removed, handling for transitions and comments are not needed
			if !COMMENTS!==1 (
				rem Handle transitions from comments to domain names and vice versa
				if not "!TYPE!"=="!PTYPE!" (
					if "!GLOB:~,2!"==" #" (
						echo !GLOB:~1!
					) else if not "!GLOB!"=="" echo !TO_BLACKHOLE!!GLOB!
					set COUNT=0
					set GLOB=
				)
				rem Handle comments
				if "!TYPE!"=="COMMENT" (
					set GLOB=!GLOB! %%a %%b %%c
					set COUNT=0
				)
			)
			rem Handle domain names
			if "!TYPE!"=="DOMAIN" (
				set GLOB=!GLOB! %%b
				set /a COUNT=!COUNT!+1
				if !COUNT!==!COMPRESSION! (
					echo !TO_BLACKHOLE!!GLOB!
					set GLOB=
					set COUNT=0
				)
			)
		)
		rem Remember current type to identify if there is a transition next iteration
		rem If comments are removed, ignore types altogether as domains are assumed
		if !COMMENTS!==1 (
			set PTYPE=!TYPE!
			set TYPE=
		)
	)
	rem Dump the final globs
	if !COMMENTS!==1 (
		if "!PTYPE!"=="COMMENT" echo !GLOB:~1!
		if "!PTYPE!"=="DOMAIN" echo !TO_BLACKHOLE!!GLOB!
	) else if not "!GLOB!"=="" echo !TO_BLACKHOLE!!GLOB!
) > "%~dp0compressed-%~nx1"
echo "%1" compressed to "%~dp0compressed-%~nx1"
pause