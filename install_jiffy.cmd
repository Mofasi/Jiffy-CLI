@echo off
set JIFFY_DIR=C:\JIFFY
set REPO_DIR=%CD%\Jiffy-CLI
set GITHUB_URL=https://github.com/Mofasi/Jiffy-CLI.git

echo Checking for existing JIFFY installation...

:: Check if JIFFY directory exists
if exist %JIFFY_DIR% (
    echo JIFFY CLI is already installed.
    
    :: Check if JIFFY is still in the system PATH
    echo Checking system PATH...
    echo %PATH% | findstr /C:"%JIFFY_DIR%" >nul
    if %ERRORLEVEL% EQU 0 (
        echo JIFFY CLI is registered in system PATH.
    ) else (
        echo JIFFY CLI is missing from system PATH. It will be re-added.
    )

    :: Prompt user for action
    echo Do you want to overwrite the current installation and path? (Y/N)
    set /p OVERWRITE=

    if /I "%OVERWRITE%"=="Y" (
        echo Removing previous JIFFY installation...
        rmdir /s /q %JIFFY_DIR%
        
        :: Remove old system PATH entry
        powershell -Command "[System.Environment]::SetEnvironmentVariable('Path', ($env:Path -replace ';%JIFFY_DIR%'), 'Machine')"
    ) else (
        echo Installation canceled. JIFFY remains installed.
        echo If you want to uninstall first, run `uninstall_jiffy.cmd`.
        exit
    )
)

:: Clone fresh JIFFY repository
echo Cloning JIFFY CLI from GitHub...
if exist %REPO_DIR% (
    echo Existing repository found. Removing Jiffy-CLI repo...
    rmdir /s /q %REPO_DIR%
)
git clone %GITHUB_URL%

:: Move JIFFY into correct system directory
echo Installing JIFFY CLI...
mkdir %JIFFY_DIR%
move Jiffy-CLI\jiffy.php %JIFFY_DIR%\jiffy.php

:: Add JIFFY to system PATH (ensuring no duplicates)
powershell -Command "[System.Environment]::SetEnvironmentVariable('Path', ($env:Path + ';%JIFFY_DIR%'), 'Machine')"

:: Create version check command
echo @echo off > %JIFFY_DIR%\jiffy_version.cmd
echo echo JIFFY CLI Version 1.0 > %JIFFY_DIR%\jiffy_version.cmd

echo Installation complete! 
echo Jiffy installed Globally and added to path, Try running `php jiffy -v` to verify.
exit
