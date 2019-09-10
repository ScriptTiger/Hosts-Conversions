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

rem Only adjust the following variables if you know what you're doing
set CACHE=Hosts-Conversions
set CACHE=%TEMP%\!CACHE!
set CTEMP=!CACHE!\ctemp

if not exist "!CACHE!" md "!CACHE!"

rem Generate an index file of only domain names for faster cross-checking when removing subdomains
echo Generating domain index from "%~1"...
(
	rem List only domain names and enforce clean input
	for /f "tokens=1,2*" %%a in (
		'findstr /b "!FROM_BLACKHOLE:.=[.]!" "%~s1" ^| findstr /b /v /c:"0.0.0.0 0.0.0.0"'
	) do echo %%b
) > "!CTEMP!"

rem Cross-check all possible parent domains from each entry in the hosts file with exact matches from the index
rem If the entry is a subdomain of a parent domain already indexed, don't include the subdomain
echo Converting "%~1" to "%~dp0Reduced-FQDN-%~nx1"...
(
	rem Enforce clean input from only comment lines and domain name lines, everything else is removed
	for /f "tokens=1,2*" %%a in (
		'findstr /b "!FROM_BLACKHOLE:.=[.]! #" "%~s1" ^| findstr /b /v /c:"0.0.0.0 0.0.0.0"'
	) do (
		set LINE=%%a %%b %%c
		rem If the line is not a comment line, generate search strings for each parent domain to cross-check index
		rem If the line is a comment line and comments are enabled, the leading "#" is converted to a ";" and the comment is written to the file
		if not "!LINE:~,1!"=="#" (
			for /f "tokens=2,3,4,5,6,7,8,9* delims=." %%j in ("%%b") do (
				rem If the domain name is only a second-level domain, automatically write it and skip searching anything
				if "%%k"=="" (
					echo %%b
				) else (
					rem Rapidly generate search strings for all possible parent domains using as much known static data as possible to speed up the process
					set FINDSTR=
					if not "%%k"=="" set FINDSTR=%%j.%%k
					if not "%%l"=="" set FINDSTR=%%j.%%k.%%l %%k.%%l
					if not "%%m"=="" set FINDSTR=%%j.%%k.%%l.%%m %%k.%%l.%%m %%l.%%m
					if not "%%n"=="" set FINDSTR=%%j.%%k.%%l.%%m.%%n %%k.%%l.%%m.%%n %%l.%%m.%%n %%m.%%n
					if not "%%o"=="" set FINDSTR=%%j.%%k.%%l.%%m.%%n.%%o %%k.%%l.%%m.%%n.%%o %%l.%%m.%%n.%%o %%m.%%n.%%o %%n.%%o
					if not "%%p"=="" set FINDSTR=%%j.%%k.%%l.%%m.%%n.%%o.%%p %%k.%%l.%%m.%%n.%%o.%%p %%l.%%m.%%n.%%o.%%p %%m.%%n.%%o.%%p %%n.%%o.%%p %%o.%%p
					if not "%%q"=="" set FINDSTR=%%j.%%k.%%l.%%m.%%n.%%o.%%p.%%q %%k.%%l.%%m.%%n.%%o.%%p.%%q %%l.%%m.%%n.%%o.%%p.%%q %%m.%%n.%%o.%%p.%%q %%n.%%o.%%p.%%q %%o.%%p.%%q %%p.%%q
					rem If the domain contains 9 parent domains or more, build the search string dynamically
					if not "%%r"=="" (
						set PARENTS=%%r
						set FINDSTR=%%j %%k %%l %%m %%n %%o %%p %%q !PARENTS:.= !
						set PARENTS=
						for %%0 in (!FINDSTR!) do set PARENTS=%%0 !PARENTS!
						call :Parents !PARENTS!
					)
					rem Cross-check the index for any of the possible parent domains
					rem Although using /x for exact match is dramatically slower than partial matches, it's a necessity
					rem Phishing domains often stack domain names like XXX.com.YYY.com, and this could create problems for partial matches
					findstr /l /x /m "!FINDSTR!" "!CTEMP!" > nul
					rem If no parent domains are found in the index, write the domain to file
					if !errorlevel!==1 (
						echo %%b
					)
				)
			)
		) else if !COMMENTS!==1 echo !LINE!
	)
) > "%~dp0Reduced-FQDN-%~nx1"

rem Remove cache files
if exist "!CACHE!" (
	echo Cleaning temporary files...
	rmdir /s /q "!CACHE!"
)

echo "%1" converted to "%~dp0Reduced-FQDN-%~nx1"

pause

exit /b

rem Function for handling domains with 9 parents or more
:Parents
set PARENTS=%2.%1
set FINDSTR=%2.%1
shift
shift
:Parents2
shift
set PARENTS=%0.!PARENTS!
set FINDSTR=!PARENTS! !FINDSTR!
if not "%1"=="" goto Parents2
exit /b