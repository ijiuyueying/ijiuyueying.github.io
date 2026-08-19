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

set "branch="
for /f "delims=" %%b in ('git branch --show-current') do set "branch=%%b"
if /I not "!branch!"=="main" (
    echo Current branch is "!branch!", not "main".
    echo Switch back to main before publishing.
    pause
    exit /b 1
)

echo.
echo [0/6] Checking Windows proxy...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_scripts\configure-git-proxy.ps1"

echo.
echo [1/6] Checking local changes...
git status --short

git add -A
git diff --cached --quiet
if errorlevel 1 (
    set "msg="
    set /p msg=Enter commit message or press Enter for default: 
    if "!msg!"=="" set "msg=Update blog content"

    echo.
    echo [2/6] Creating local commit...
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
echo [3/6] Testing GitHub connection...
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
    echo GitHub connection failed. Local commits are preserved; retry later.
    pause
    exit /b 1
)
echo GitHub connection OK.

echo.
echo [4/6] Fetching and rebasing latest remote main...
set "synced=0"
for /L %%i in (1,1,3) do (
    echo Sync attempt %%i...
    git fetch origin main:refs/remotes/origin/main
    if not errorlevel 1 (
        git rebase origin/main
        if not errorlevel 1 (
            set "synced=1"
            goto :synced
        )

        echo.
        echo Rebase conflict detected. Aborting rebase to keep your local commit safe.
        git rebase --abort >nul 2>nul
        echo Nothing was deleted. Send the conflict message to ChatGPT before retrying.
        pause
        exit /b 1
    )

    echo Fetch attempt %%i failed. Retrying in 2 seconds...
    timeout /t 2 /nobreak >nul
)

:synced
if "!synced!"=="0" (
    echo Failed to refresh remote main. Local commits are preserved.
    pause
    exit /b 1
)

echo.
echo [5/6] Pushing to GitHub...
set "pushed=0"
for /L %%i in (1,1,3) do (
    echo Push attempt %%i...
    git push origin HEAD:main
    if not errorlevel 1 (
        set "pushed=1"
        goto :pushed
    )

    echo Remote main changed while publishing. Refreshing and retrying...
    git fetch origin main:refs/remotes/origin/main
    if errorlevel 1 (
        echo Refresh failed. Retrying in 2 seconds...
    ) else (
        git rebase origin/main
        if errorlevel 1 (
            echo.
            echo Rebase conflict detected during retry. Aborting rebase.
            git rebase --abort >nul 2>nul
            echo Your local commit is preserved. Send the conflict message to ChatGPT.
            pause
            exit /b 1
        )
    )
    timeout /t 2 /nobreak >nul
)

:pushed
if "!pushed!"=="0" (
    echo Push failed after 3 attempts. Local commits are preserved; retry later.
    pause
    exit /b 1
)

echo.
echo [6/6] Verifying published commit...
git fetch origin main:refs/remotes/origin/main >nul 2>nul
if errorlevel 1 (
    echo Publish succeeded, but final verification could not refresh origin/main.
    echo You can check GitHub manually; your push already succeeded.
) else (
    git merge-base --is-ancestor HEAD origin/main
    if errorlevel 1 (
        echo Verification failed: remote main does not contain the local commit yet.
        echo Do not create another commit. Retry this publish script once.
        pause
        exit /b 1
    )
)

echo.
echo Publish completed successfully.
echo GitHub Pages will update automatically.
echo Site: https://ijiuyueying.github.io/
pause
