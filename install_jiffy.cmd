@echo off
setlocal enabledelayedexpansion

:: --- Configuration ---
set "JIFFY_DIR=C:\JIFFY"
set "GITHUB_URL=https://github.com/Mofasi/Jiffy-CLI"
set "TEMP_DIR=%TEMP%\JiffyInstall"

:: --- Ensure we're not in a protected directory ---
mkdir "%TEMP_DIR%" 2>nul
cd /d "%TEMP_DIR%"

:: --- Check existing installation ---
echo Checking for existing JIFFY installation...
if exist "%JIFFY_DIR%" (
    echo JIFFY CLI is already installed at %JIFFY_DIR%
    
    :: Check PATH registration
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
    
    :: Remove existing installation
    echo Removing previous installation...
    rmdir /s /q "%JIFFY_DIR%" 2>nul
    
    :: Remove from PATH
    powershell -noprofile -command ^
        "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine');" ^
        "$newPath = ($oldPath -split ';' | Where-Object { $_ -ne '%JIFFY_DIR%' }) -join ';';" ^
        "$newPath = $newPath.Trim(';');" ^
        "[Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine');"
)

:: --- Create installation directory ---
mkdir "%JIFFY_DIR%" 2>nul

:: --- Download repository ---
echo Downloading JIFFY CLI...
set "TEMP_FILE=%TEMP%\jiffy-cli.zip"
powershell -noprofile -command ^
    "Invoke-WebRequest '%GITHUB_URL%/archive/main.zip' -OutFile '%TEMP_FILE%'"

:: --- Verify download success ---
if not exist "%TEMP_FILE%" (
    echo ERROR: Failed to download JIFFY CLI. Check GitHub URL.
    exit /b
)

:: --- Extract files ---
echo Extracting files...
powershell -noprofile -command ^
    "Expand-Archive -Path '%TEMP_FILE%' -DestinationPath '%TEMP_DIR%'"

:: --- Detect correct extracted folder ---
for /d %%i in ("%TEMP_DIR%\Jiffy-CLI*") do set EXTRACTED_DIR=%%i

:: --- Move jiffy.php to installation directory ---
if exist "%EXTRACTED_DIR%\jiffy.php" (
    move "%EXTRACTED_DIR%\jiffy.php" "%JIFFY_DIR%" /Y
) else (
    echo ERROR: jiffy.php not found in extracted files.
    exit /b
)

:: --- Cleanup temp files ---
del /q "%TEMP_FILE%" 2>nul
rmdir /s /q "%EXTRACTED_DIR%" 2>nul

:: --- Create version command ---
echo @echo off > "%JIFFY_DIR%\jiffy_version.cmd"
echo echo JIFFY CLI Version 1.0 >> "%JIFFY_DIR%\jiffy_version.cmd"

:: --- Add to PATH ---
echo Registering in system PATH...
powershell -noprofile -command ^
    "$path = [Environment]::GetEnvironmentVariable('Path', 'Machine');" ^
    "if (-not ($path -split ';' -contains '%JIFFY_DIR%')) {" ^
        "[Environment]::SetEnvironmentVariable('Path', ($path + ';%JIFFY_DIR%'), 'Machine');" ^
    "}"

:: --- Create uninstaller ---
echo @echo off > "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo echo Uninstalling JIFFY CLI... >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo echo Removing files... >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo rmdir /s /q "%JIFFY_DIR%" 2^>nul >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo echo Removing from PATH... >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo powershell -noprofile -command "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine');$newPath = ($oldPath -split ';' ^| Where-Object { $_ -ne '%JIFFY_DIR%' }) -join ';';[Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine');" >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo echo JIFFY CLI has been uninstalled. >> "%JIFFY_DIR%\uninstall_jiffy.cmd"
echo echo You may need to restart your terminal. >> "%JIFFY_DIR%\uninstall_jiffy.cmd"

:: --- Final cleanup ---
cd /d %~dp0
rmdir /s /q "%TEMP_DIR%" 2>nul

echo.
echo ==============================================
echo JIFFY CLI successfully installed to C:\JIFFY!
echo ==============================================
echo.
echo To verify installation:
echo   1. Open a NEW command prompt as administrator
echo   2. Run: jiffy
