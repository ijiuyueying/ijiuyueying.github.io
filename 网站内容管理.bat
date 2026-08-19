@echo off
cd /d "%~dp0"
setlocal EnableExtensions

echo ========================================
echo Jiuyueying Blog - Content Manager
echo ========================================

where powershell >nul 2>nul
if errorlevel 1 (
    echo Windows PowerShell was not found.
    pause
    exit /b 1
)

if not exist "%~dp0blog-manager.ps1" (
    echo blog-manager.ps1 was not found.
    echo Run the sync script first.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0blog-manager.ps1"
set "exitcode=%errorlevel%"

if not "%exitcode%"=="0" (
    echo.
    echo ========================================
    echo Content manager stopped. Error code: %exitcode%
    echo Keep this window open and send the error.
    echo ========================================
    pause
    exit /b %exitcode%
)

exit /b 0
