@echo off
set JIFFY_DIR=C:\JIFFY
set REPO_DIR=%CD%\Jiffy-CLI
set GITHUB_URL=https://github.com/Mofasi/Jiffy-CLI.git

echo Checking for existing JIFFY installation...

:: Remove JIFFY directory if it exists
if exist %JIFFY_DIR% (
    echo Removing existing JIFFY installation...
    rmdir /s /q %JIFFY_DIR%
)

:: Check if Jiffy-CLI repo exists and delete it
if exist %REPO_DIR% (
    echo Existing repository found. Removing Jiffy-CLI...
    rmdir /s /q %REPO_DIR%
)

:: Remove JIFFY from system PATH if it is still set
for /f "tokens=1* delims=;" %%a in ("%PATH%") do (
    if "%%a"=="%JIFFY_DIR%" (
        echo Removing outdated PATH entry...
        powershell -Command "[System.Environment]::SetEnvironmentVariable('Path', ($env:Path -replace ';%JIFFY_DIR%'), 'Machine')"
    )
)

:: Clone the repository fresh
echo Cloning JIFFY CLI from GitHub...
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

echo Installation complete! Try running `jiffy -v` to verify.
exit
