@echo off
cd /d "%~dp0"
setlocal EnableExtensions
set "BLOG_ROOT=%~dp0"

echo ========================================
echo Jiuyueying Blog - New Post
echo ========================================

if not exist "%~dp0_scripts\new-post.ps1" (
    echo New-post script was not found.
    echo Please run sync script first.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$p=Join-Path $env:BLOG_ROOT '_scripts\new-post.ps1'; $code=[IO.File]::ReadAllText($p,[Text.Encoding]::UTF8); Invoke-Expression $code"

if errorlevel 1 (
    echo.
    echo Failed to create the post.
    pause
    exit /b 1
)

exit /b 0
