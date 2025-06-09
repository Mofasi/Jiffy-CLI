@echo off
setlocal enabledelayedexpansion

set "JIFFY_DIR=C:\JIFFY"
set "TEMP_CLONE=%TEMP%\Jiffy-CLI-Temp"
set "GITHUB_URL=https://github.com/Mofasi/Jiffy-CLI.git"

echo Checking for existing JIFFY installation...

:: Check if JIFFY installation exists
if exist "%JIFFY_DIR%" (
    echo JIFFY CLI is already installed.
    
    :: Check if JIFFY is in system PATH
    echo Checking system PATH...
    echo %PATH% | findstr /i /c:"%JIFFY_DIR%" >nul
    if %ERRORLEVEL% EQU 0 (
        echo JIFFY CLI is registered in system PATH.
    ) else (
        echo JIFFY CLI is missing from system PATH.
    )

    :: Prompt user for action
    choice /c YN /m "Do you want to overwrite the current installation? (Y/N)"
    if !errorlevel! EQU 2 (
        echo Installation canceled. JIFFY remains installed.
        echo To uninstall, run `uninstall_jiffy.cmd`.
        exit /b
    )
    
    echo Removing previous JIFFY installation...
    rmdir /s /q "%JIFFY_DIR%" 2>nul
    
    :: Remove from system PATH
    powershell -noprofile -command "$path = [Environment]::GetEnvironmentVariable('Path', 'Machine'); $newPath = $path -replace [regex]::Escape('%JIFFY_DIR%') -replace ';;',';'; [Environment]::SetEnvironmentVariable('Path', $newPath.Trim(';'), 'Machine')"
)

:: Clean temp clone directory
if exist "%TEMP_CLONE%" rmdir /s /q "%TEMP_CLONE%" 2>nul

:: Clone fresh repository to temp location
echo Cloning JIFFY CLI from GitHub...
git clone "%GITHUB_URL%" "%TEMP_CLONE%"

if not exist "%TEMP_CLONE%\jiffy.php" (
    echo ERROR: Repository clone failed or jiffy.php not found
    exit /b 1
)

:: Create installation directory
mkdir "%JIFFY_DIR%" 2>nul

:: Move files
move /y "%TEMP_CLONE%\jiffy.php" "%JIFFY_DIR%\" >nul

:: Create version command
echo @echo off > "%JIFFY_DIR%\jiffy_version.cmd"
echo echo JIFFY CLI Version 1.0 >> "%JIFFY_DIR%\jiffy_version.cmd"

:: Add to system PATH
powershell -noprofile -command "$path = [Environment]::GetEnvironmentVariable('Path', 'Machine'); if (-not $path.Contains('%JIFFY_DIR%')) { [Environment]::SetEnvironmentVariable('Path', ($path + ';%JIFFY_DIR%'), 'Machine') }"

:: Cleanup
rmdir /s /q "%TEMP_CLONE%" 2>nul

echo Installation complete! Try running `jiffy -v` to verify.
endlocal
