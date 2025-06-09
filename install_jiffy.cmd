@echo off
setlocal enabledelayedexpansion

set "JIFFY_DIR=C:\JIFFY"
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
    
    :: Properly remove from system PATH
    echo Removing from system PATH...
    powershell -noprofile -command ^
        "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine');" ^
        "$newPath = ($oldPath -split ';' | Where-Object { $_ -ne '%JIFFY_DIR%' }) -join ';';" ^
        "$newPath = $newPath.Trim(';');" ^
        "[Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine');"
)

:: Create unique temp directory in %TEMP%
set "TEMP_CLONE=%TEMP%\Jiffy-CLI-%RANDOM%-%TIME::=_%"
set "TEMP_CLONE=%TEMP_CLONE: =0%"
mkdir "%TEMP_CLONE%" 2>nul

:: Download repository using PowerShell to avoid git directory issues
echo Downloading JIFFY CLI from GitHub...
powershell -noprofile -command ^
    "Set-Location '%TEMP_CLONE%';" ^
    "git clone '%GITHUB_URL%' . 2>&1 | Out-Null;" ^
    "if (-not (Test-Path 'jiffy.php')) { exit 1 }"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to download repository
    rmdir /s /q "%TEMP_CLONE%" 2>nul
    exit /b 1
)

:: Create installation directory
mkdir "%JIFFY_DIR%" 2>nul

:: Copy files to installation directory
echo Installing JIFFY CLI...
copy /y "%TEMP_CLONE%\jiffy.php" "%JIFFY_DIR%\" >nul

:: Create version command
echo @echo off > "%JIFFY_DIR%\jiffy_version.cmd"
echo echo JIFFY CLI Version 1.0 >> "%JIFFY_DIR%\jiffy_version.cmd"

:: Add to system PATH only if not present
echo Adding to system PATH...
powershell -noprofile -command ^
    "$path = [Environment]::GetEnvironmentVariable('Path', 'Machine');" ^
    "if (-not ($path -split ';' -contains '%JIFFY_DIR%')) {" ^
        "[Environment]::SetEnvironmentVariable('Path', ($path + ';%JIFFY_DIR%'), 'Machine');" ^
    "}"

:: Cleanup
rmdir /s /q "%TEMP_CLONE%" 2>nul

echo Installation complete!
echo JIFFY CLI has been installed to: %JIFFY_DIR%

:: Create uninstall script
echo @echo off > "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo echo Uninstalling JIFFY CLI... >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo rmdir /s /q "%JIFFY_DIR%" 2^>nul >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo powershell -noprofile -command "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine');$newPath = ($oldPath -split ';' ^| Where-Object { $_ -ne '%JIFFY_DIR%' }) -join ';';[Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine');" >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo echo JIFFY CLI has been uninstalled. >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo echo You may need to restart your terminal for changes to take effect. >> "%JIFFY_DIR%\uninstall_jiffy.cmd"

echo Try running `jiffy -v` to verify.
endlocal
