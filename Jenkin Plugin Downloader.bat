@echo off
setlocal EnableDelayedExpansion
SETLOCAL 
set outDir=downloaded
set message=../ListOfPlugins.txt

if not exist %outDir% mkdir %outDir%

cd %outDir%
for /f %%a in (%message%) do ( 
	echo Downloading %%a
	CALL :downloadPlugins %%a
)
cd ..

EXIT /B %ERRORLEVEL%

:downloadPlugins

REM download plugin

..\curl https://updates.jenkins-ci.org/latest/%~1.hpi -k -O -L

REM check dependencies
D:\Programs\7-Zip\7z e %~1.hpi META-INF/MANIFEST.MF -aoa
set dependencies=
for /F "delims=" %%a in ('findstr "Dependencies" MANIFEST.MF') do (
	set "dependencies=%%a"
) 

IF "%dependencies%"=="" (
	echo no mores
) ELSE (
	set dependencies=%dependencies:~21,-1%
	echo Dependencies are: !dependencies!
	for %%A in (!dependencies!) do (
		for /F "tokens=1* delims=:" %%B in ("%%A") do (
			CALL :downloadPlugins %%B
		)
	)
)


REM return to main folder
EXIT /B 0

