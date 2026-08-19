@echo off
cd /d "%~dp0"
setlocal EnableExtensions EnableDelayedExpansion

echo ========================================
echo Jiuyueying Blog - Sync
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
echo [0/3] Checking Windows proxy...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_scripts\configure-git-proxy.ps1"

echo.
echo [1/3] Checking local changes...
set "dirty="
for /f "delims=" %%i in ('git status --porcelain') do set "dirty=1"
if defined dirty (
    echo Local uncommitted changes were found.
    echo Please run the publish script first so these changes are committed and uploaded.
    echo.
    echo Uncommitted files:
    git status --short
    echo.
    pause
    exit /b 1
)

echo.
echo [2/3] Testing GitHub connection...
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
    echo GitHub connection failed. Check network or proxy, then retry.
    pause
    exit /b 1
)
echo GitHub connection OK.

echo.
echo [3/3] Pulling latest changes...
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
    echo Sync failed.
    echo If Git reports CONFLICT, stop and send the conflict message to ChatGPT.
    echo If this is only a network error, retry after the network recovers.
    pause
    exit /b 1
)

echo.
echo Sync completed. You can continue editing in Typora.
pause
