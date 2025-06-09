@echo off
echo Installing JIFFY CLI...
set JIFFY_DIR=C:\JIFFY

:: Create JIFFY directory
mkdir %JIFFY_DIR%

:: Download latest jiify.php (replace URL with actual hosted version)
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://yourserver.com/jiify.php', '%JIFFY_DIR%\jiify.php')"

:: Add JIFFY to system PATH
setx PATH "%PATH%;%JIFFY_DIR%"

:: Create version check command
echo @echo off > %JIFFY_DIR%\jiify_version.cmd
echo echo JIFFY CLI Version 1.0 > %JIFFY_DIR%\jiify_version.cmd

echo Installation complete! Try running `jiify -v` to verify.
exit
