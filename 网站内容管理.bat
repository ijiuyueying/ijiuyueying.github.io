@echo off
cd /d "%~dp0"
setlocal EnableExtensions
set "BLOG_ROOT=%~dp0"

echo ========================================
echo Jiuyueying Blog - Content Manager
echo ========================================

where powershell >nul 2>nul
if errorlevel 1 (
    echo Windows PowerShell was not found.
    pause
    exit /b 1
)

if not exist "%~dp0content-manager.ps1" (
    echo Content-manager PowerShell script was not found.
    echo Run the sync script first.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$p=Join-Path $env:BLOG_ROOT 'content-manager.ps1'; $code=[IO.File]::ReadAllText($p,[Text.Encoding]::UTF8); Invoke-Expression $code"
set "exitcode=%errorlevel%"

if not "%exitcode%"=="0" (
    echo.
    echo ========================================
    echo Content manager stopped. Error code: %exitcode%
    echo Keep this window open and send the error to ChatGPT.
    echo ========================================
    pause
    exit /b %exitcode%
)

exit /b 0
