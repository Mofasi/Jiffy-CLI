@echo off
setlocal enabledelayedexpansion

:: --- Configuration ---
set "JIFFY_DIR=C:\Jiffy-CLI"
set "GITHUB_URL=https://github.com/Mofasi/Jiffy-CLI"
set "TEMP_DIR=%TEMP%\JiffyInstall"

:: --- Prepare temp space ---
mkdir "%TEMP_DIR%" 2>nul
cd /d "%TEMP_DIR%"

:: --- Check existing installation ---
echo Checking for existing JIFFY installation...
if exist "%JIFFY_DIR%" (
    echo JIFFY CLI is already installed at %JIFFY_DIR%
    echo %PATH% | findstr /i /c:"%JIFFY_DIR%" >nul
    if %ERRORLEVEL% EQU 0 (
        echo JIFFY CLI is registered in system PATH.
    ) else (
        echo JIFFY CLI is missing from system PATH.
    )
    choice /c YN /m "Overwrite existing installation? (Y/N)"
    if !errorlevel! EQU 2 (
        echo Installation canceled. JIFFY remains installed.
        exit /b
    )
    echo Removing previous installation...
    :: Change to a safe directory before deleting the install folder.
    cd /d "%TEMP%"
    rmdir /s /q "%JIFFY_DIR%" 2>nul
    :: Remove from PATH
    powershell -noprofile -command "[Environment]::SetEnvironmentVariable('Path', (([Environment]::GetEnvironmentVariable('Path','Machine') -split ';' | Where-Object { $_ -ne '%JIFFY_DIR%' }) -join ';'), 'Machine')"
)

:: --- Clone the repository ---
echo Cloning JIFFY CLI from GitHub...
git clone %GITHUB_URL%.git "%JIFFY_DIR%"
if errorlevel 1 (
    echo ERROR: Git clone failed.
    exit /b
)

:: --- Verify jiffy.php exists ---
if not exist "%JIFFY_DIR%\jiffy.php" (
    echo ERROR: jiffy.php not found after clone.
    exit /b
)

:: --- Create wrapper command (jiffy.cmd) to run jiffy globally ---
echo @echo off > "%JIFFY_DIR%\jiffy.cmd"
echo php "%JIFFY_DIR%\jiffy.php" %%* >> "%JIFFY_DIR%\jiffy.cmd"

:: --- Add JIFFY CLI to system PATH ---
echo Registering JIFFY CLI in system PATH...
powershell -noprofile -command "[Environment]::SetEnvironmentVariable('Path', ((@([Environment]::GetEnvironmentVariable('Path','Machine') -split ';') + '%JIFFY_DIR%') | Where-Object { $_ -ne '' } | Select-Object -Unique) -join ';'), 'Machine')"

:: --- Create version command ---
echo @echo off > "%JIFFY_DIR%\jiffy_version.cmd"
echo echo JIFFY CLI Version 1.0 >> "%JIFFY_DIR%\jiffy_version.cmd"

:: --- Create uninstaller file ---
echo @echo off > "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo echo Uninstalling JIFFY CLI... >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo rmdir /s /q "%JIFFY_DIR%" >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo powershell -noprofile -command "[Environment]::SetEnvironmentVariable('Path', (([Environment]::GetEnvironmentVariable('Path','Machine') -split ';' | Where-Object { $_ -ne '%JIFFY_DIR%' }) -join ';'), 'Machine')" >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo echo JIFFY CLI has been uninstalled. >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo pause >> "%JIFFY_DIR%\uninstall_jiffy.cmd"

:: --- Final cleanup ---
cd /d %~dp0
rmdir /s /q "%TEMP_DIR%" 2>nul

echo.
echo ==============================================
echo ✅ JIFFY CLI successfully installed to %JIFFY_DIR%!
echo ✅ JIFFY CLI is available globally.
echo ==============================================
echo.
echo To verify installation:
echo   Open a NEW command prompt and run: jiffy -v
echo.
echo To uninstall: Run C:\Jiffy-CLI\uninstall_jiffy.cmd
echo.
endlocal
