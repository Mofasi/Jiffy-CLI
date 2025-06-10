@echo off
set JIFFY_DIR=C:\JIFFY

:: Check if JIFFY is installed
if not exist %JIFFY_DIR% (
    echo JIFFY CLI is not installed.
    echo To install, run `install_jiffy.cmd`.
    exit
)

:: Prompt user for confirmation
echo JIFFY is installed. Do you want to uninstall it? (Y/N)
set /p CONFIRM_UNINSTALL=

if /I "%CONFIRM_UNINSTALL%"=="Y" (
    echo Uninstalling JIFFY CLI...
    rmdir /s /q %JIFFY_DIR%

    :: Remove JIFFY from system PATH
    powershell -Command "[System.Environment]::SetEnvironmentVariable('Path', ($env:Path -replace ';%JIFFY_DIR%'), 'Machine')"

    echo ==============================================
    echo ✅ JIFFY CLI has been successfully removed!
    echo ==============================================
    echo You may need to restart your terminal for changes to take effect.
) else (
    echo ==============================================
    echo ❌ Uninstallation canceled. JIFFY CLI remains installed.
    echo ==============================================
)
exit
