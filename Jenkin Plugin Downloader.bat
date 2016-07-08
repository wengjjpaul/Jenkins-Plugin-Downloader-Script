@echo off
setlocal EnableDelayedExpansion
SETLOCAL 
set outDir=downloaded
set message=../ListOfPlugins.txt

if not exist %outDir% mkdir %outDir%

cd %outDir%
for /f %%a in (%message%) do ( 
	
	CALL :downloadPlugins %%a
)
cd ..

EXIT /B %ERRORLEVEL%

:downloadPlugins
IF NOT EXIST %~1.hpi (
	echo Downloading %~1
	..\curl https://updates.jenkins-ci.org/latest/%~1.hpi -k -O -L -s
)

echo check %~1.hpi dependencies
D:\Programs\7-Zip\7z e %~1.hpi META-INF/MANIFEST.MF -aoa > nul
set foundDependencies=false
set dependencies=
for /F "tokens=*" %%a in (MANIFEST.MF) do (
	set text=%%a
	IF %foundDependencies%==false (
		If NOT "!text!"=="!text:Dependencies=!" (
	   		set foundDependencies=true
		)
	)
	IF !foundDependencies!==true (
		IF NOT "!text!"=="!text:Long-Name=!" (
			set foundDependencies=false
		) ELSE (
			IF NOT "!text!"=="!text:Plugin-Developers=!" (
				set foundDependencies=false
			) ELSE (				
				set dependencies=!dependencies!!text!
			)
		)
	)
)

IF NOT "%dependencies%"=="" (
	set dependencies=%dependencies:~21%
	echo Dependencies are: !dependencies!
	for %%A in (!dependencies!) do (
		for /F "tokens=1* delims=:" %%B in ("%%A") do (
			set temp=%%A
			if "!temp!"=="!temp:resolution=!" (
				if "!temp!"=="!temp:optional=!" (
					CALL :downloadPlugins %%B
				)
			)
			
		)
	)
)
REM return to main folder
EXIT /B 0

