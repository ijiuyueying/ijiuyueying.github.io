@echo off
cd /d "%~dp0"
setlocal EnableExtensions
set "BLOG_ROOT=%~dp0"

echo ========================================
echo Jiuyueying Blog - New Post
echo ========================================

where powershell >nul 2>nul
if errorlevel 1 (
    echo Windows PowerShell was not found.
    pause
    exit /b 1
)

rem If the tracked PowerShell file was accidentally deleted locally, restore it from local Git HEAD first.
if not exist "%~dp0新建博客文章.ps1" (
    where git >nul 2>nul
    if not errorlevel 1 (
        git rev-parse --is-inside-work-tree >nul 2>nul
        if not errorlevel 1 (
            git cat-file -e "HEAD:新建博客文章.ps1" >nul 2>nul
            if not errorlevel 1 (
                echo Repairing missing new-post script from local Git...
                git restore --worktree -- "新建博客文章.ps1" >nul 2>nul
            )
        )
    )
)

if not exist "%~dp0新建博客文章.ps1" (
    echo New-post PowerShell script was not found locally.
    echo GitHub main contains this file, so run the sync script first.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$p=Join-Path $env:BLOG_ROOT '新建博客文章.ps1'; $code=[IO.File]::ReadAllText($p,[Text.Encoding]::UTF8); Invoke-Expression $code"
set "exitcode=%errorlevel%"

if not "%exitcode%"=="0" (
    echo.
    echo ========================================
    echo Failed to create the post. Error code: %exitcode%
    echo Keep this window open and send the error to ChatGPT.
    echo ========================================
    pause
    exit /b %exitcode%
)

exit /b 0
