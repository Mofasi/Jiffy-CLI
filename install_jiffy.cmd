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
    :: Prompt for overwrite
    choice /c YN /m "Overwrite existing installation? (Y/N)"
    if !errorlevel! EQU 2 (
        echo Installation canceled. JIFFY remains installed.
        exit /b
    )
    echo Removing previous installation...
    rmdir /s /q "%JIFFY_DIR%" 2>nul
    :: Remove from PATH using a one-liner PowerShell command
    powershell -noprofile -command "[Environment]::SetEnvironmentVariable('Path', (([Environment]::GetEnvironmentVariable('Path','Machine') -split ';' | Where-Object { $_ -ne '%JIFFY_DIR%' }) -join ';'), 'Machine')"
)

:: --- Create installation directory ---
mkdir "%JIFFY_DIR%" 2>nul

:: --- Download and extract ---
echo Downloading JIFFY CLI...
set "TEMP_FILE=%TEMP%\jiffy-cli.zip"
powershell -noprofile -command "Invoke-WebRequest '%GITHUB_URL%/archive/main.zip' -OutFile '%TEMP_FILE%'"
if not exist "%TEMP_FILE%" (
    echo ERROR: Failed to download JIFFY CLI archive.
    exit /b
)
echo Extracting files...
powershell -noprofile -command "Expand-Archive -Path '%TEMP_FILE%' -DestinationPath '%TEMP_DIR%'"

:: --- Locate the extracted folder (assumes GitHub names it Jiffy-CLI-main) ---
for /d %%i in ("%TEMP_DIR%\Jiffy-CLI-main") do set EXTRACTED_DIR=%%i

:: --- Move jiffy.php ---
if exist "%EXTRACTED_DIR%\jiffy.php" (
    move "%EXTRACTED_DIR%\jiffy.php" "%JIFFY_DIR%" /Y
) else (
    echo ERROR: jiffy.php not found in extracted folder.
    exit /b
)

:: --- Cleanup temp files ---
del /q "%TEMP_FILE%" 2>nul
rmdir /s /q "%EXTRACTED_DIR%" 2>nul

:: --- Create wrapper command (jiffy.cmd) to run jiffy.php globally ---
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
echo ✅ JIFFY CLI should now be available globally.
echo ==============================================
echo.
echo To verify installation:
echo   Open a NEW command prompt and run: jiffy -v
echo.
echo To uninstall: Run C:\Jiffy-CLI\uninstall_jiffy.cmd
echo.
endlocal
