@echo off
echo Installing JIFFY CLI...
set JIFFY_DIR=C:\JIFFY

:: Create JIFFY directory
mkdir %JIFFY_DIR%

:: Download latest jiffy.php (replace URL with actual hosted version)
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://yourserver.com/jiffy.php', '%JIFFY_DIR%\jiffy.php')"

:: Add JIFFY to system PATH
setx PATH "%PATH%;%JIFFY_DIR%"

:: Create version check command
echo @echo off > %JIFFY_DIR%\jiffy_version.cmd
echo echo JIFFY CLI Version 1.0 > %JIFFY_DIR%\jiffy_version.cmd

echo Installation complete! Try running `jiffy -v` to verify.
exit
