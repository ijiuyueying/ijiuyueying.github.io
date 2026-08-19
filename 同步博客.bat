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
echo [0/5] Checking Windows proxy...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_scripts\configure-git-proxy.ps1"

echo.
echo [1/5] Checking local changes...
set "dirty="
for /f "delims=" %%i in ('git status --porcelain') do set "dirty=1"
if defined dirty (
    echo Local uncommitted changes were found.
    echo Publish or save these changes before syncing.
    echo.
    echo Uncommitted files:
    git status --short
    echo.
    pause
    exit /b 1
)

echo.
echo [2/5] Testing GitHub connection...
set "connected=0"
for /L %%i in (1,1,3) do (
    echo Connection attempt %%i...
    git ls-remote origin refs/heads/main >nul 2>nul
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
echo [3/5] Refreshing remote main...
git fetch origin main:refs/remotes/origin/main
if errorlevel 1 (
    echo Failed to fetch origin/main.
    pause
    exit /b 1
)

echo.
echo [4/5] Switching to main...
set "branch="
for /f "delims=" %%b in ('git branch --show-current') do set "branch=%%b"
if /I not "!branch!"=="main" (
    echo Current branch is "!branch!". Switching to main automatically...
    git show-ref --verify --quiet refs/heads/main
    if errorlevel 1 (
        git switch -c main --track origin/main
    ) else (
        git switch main
    )
    if errorlevel 1 (
        echo Could not switch to main. No files were deleted.
        echo Send this window to ChatGPT.
        pause
        exit /b 1
    )
)

echo.
echo [5/5] Updating local main...
git rebase origin/main
if errorlevel 1 (
    echo Sync found a rebase conflict. Aborting to keep the local repository safe.
    git rebase --abort >nul 2>nul
    echo No files were intentionally deleted. Send the conflict message to ChatGPT.
    pause
    exit /b 1
)

echo.
set "finalBranch="
for /f "delims=" %%b in ('git branch --show-current') do set "finalBranch=%%b"
echo Sync completed successfully.
echo Current branch: !finalBranch!
echo You can continue editing or publishing.
pause
