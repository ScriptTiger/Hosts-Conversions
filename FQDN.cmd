@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/Hosts-Conversions
rem =====

rem Error if no input file given
if "%~1"=="" (
	echo Please drag and drop a host file to be converted
	pause
	exit
)

setlocal ENABLEDELAYEDEXPANSION

rem =====
rem Read the below section carefully and adjust any variables as neeeded

rem Blackhole address for source file
set FROM_BLACKHOLE=0.0.0.0

rem 0 to remove commments, 1 to keep them
set COMMENTS=0

rem =====

echo Converting "%~1" to "%~dp0FQDN-%~nx1"...

rem Capture all output to a single write operation data stream
rem Forcing a write operating each line is considerably slower when dealing with files of higher line counts
(
	rem Read from the source hosts file and enfore clean input
	for /f "tokens=1,2*" %%a in (
		'findstr /b "!FROM_BLACKHOLE:.=[.]! #" "%~s1" ^| findstr /b /v /c:"0.0.0.0 0.0.0.0"'
	) do (
		if "%%a"=="!FROM_BLACKHOLE!" (
			echo %%b
		) else (
			if !COMMENTS!==1 (
				set LINE=%%a %%b %%c
				if "!LINE:~,1!"=="#" echo !LINE!
			)
		)
	)
) > "%~dp0FQDN-%~nx1"
echo "%1" converted to "%~dp0FQDN-%~nx1"
pause