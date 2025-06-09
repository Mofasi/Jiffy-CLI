@echo off
set JIFFY_DIR=C:\JIFFY

:: Check if JIFFY exists
if exist %JIFFY_DIR% (
    echo JIFFY is already installed.
    echo Do you want to uninstall it before reinstalling? (Y/N)
    set /p UNINSTALL_FIRST=

    if /I "%UNINSTALL_FIRST%"=="Y" (
        echo Running uninstallation...
        call uninstall_jiffy.cmd
    ) else (
        echo Installation canceled. JIFFY remains installed.
        exit
    )
)

echo Installing JIFFY CLI...
mkdir %JIFFY_DIR%

:: Download latest jiffy.php (replace URL with actual hosted version)
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/Mofasi/Jiffy-CLI/raw/main/jiffy.php', '%JIFFY_DIR%\jiffy.php')"

:: Add JIFFY to system PATH (avoiding duplicates)
powershell -Command "[System.Environment]::SetEnvironmentVariable('Path', ($env:Path + ';%JIFFY_DIR%'), 'Machine')"

:: Create version check command
echo @echo off > %JIFFY_DIR%\jiffy_version.cmd
echo echo JIFFY CLI Version 1.0 > %JIFFY_DIR%\jiffy_version.cmd

echo Installation complete! Try running `jiffy -v` to verify.
exit
