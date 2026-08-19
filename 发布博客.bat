@echo off
cd /d "%~dp0"
setlocal EnableExtensions EnableDelayedExpansion

echo ========================================
echo Jiuyueying Blog - Publish
echo ========================================

where git >nul 2>nul
if errorlevel 1 (
    echo Git was not found. Please install Git for Windows first.
    pause
    exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>nul
if errorlevel 1 (
    echo Current folder is not a Git repository.
    pause
    exit /b 1
)

echo.
echo [0/5] Checking Windows proxy...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_scripts\configure-git-proxy.ps1"

echo.
echo [1/5] Checking local changes...
git status --short

git add -A
git diff --cached --quiet
if errorlevel 1 (
    set "msg="
    set /p msg=Enter commit message or press Enter for default: 
    if "!msg!"=="" set "msg=Update blog content"

    echo.
    echo [2/5] Creating local commit...
    git commit -m "!msg!"
    if errorlevel 1 (
        echo Commit failed. Check the Git message above.
        pause
        exit /b 1
    )
) else (
    echo No new working-tree changes. Existing local commits will still be checked.
)

echo.
echo [3/5] Testing GitHub connection...
set "connected=0"
for /L %%i in (1,1,3) do (
    echo Connection attempt %%i...
    git ls-remote origin >nul 2>nul
    if not errorlevel 1 (
        set "connected=1"
        goto :connected
    )
    timeout /t 2 /nobreak >nul
)

:connected
if "!connected!"=="0" (
    echo GitHub connection failed. Local commits are preserved; retry later.
    pause
    exit /b 1
)
echo GitHub connection OK.

echo.
echo [4/5] Pulling latest remote changes with rebase...
set "pulled=0"
for /L %%i in (1,1,3) do (
    git pull --rebase origin main
    if not errorlevel 1 (
        set "pulled=1"
        goto :pulled
    )
    echo Pull attempt %%i failed. Retrying in 2 seconds...
    timeout /t 2 /nobreak >nul
)

:pulled
if "!pulled!"=="0" (
    echo Pull failed.
    echo If Git reports CONFLICT, stop and send the conflict message to ChatGPT.
    echo Local commits are preserved.
    pause
    exit /b 1
)

echo.
echo [5/5] Pushing to GitHub...
set "pushed=0"
for /L %%i in (1,1,3) do (
    git push origin main
    if not errorlevel 1 (
        set "pushed=1"
        goto :pushed
    )
    echo Push attempt %%i failed. Retrying in 2 seconds...
    timeout /t 2 /nobreak >nul
)

:pushed
if "!pushed!"=="0" (
    echo Push failed. Local commits are preserved; retry later.
    pause
    exit /b 1
)

echo.
echo Publish completed. GitHub Pages will update automatically.
echo Site: https://ijiuyueying.github.io/
pause
