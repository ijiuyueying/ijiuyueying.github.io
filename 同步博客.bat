@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ========================================
echo 九月影博客 - 同步 GitHub 最新内容
echo ========================================

where git >nul 2>nul
if errorlevel 1 (
    echo 未检测到 Git，请先安装 Git for Windows。
    pause
    exit /b 1
)

set "dirty="
for /f "delims=" %%i in ('git status --porcelain') do set "dirty=1"
if defined dirty (
    echo 检测到本地还有未提交的修改。
    echo 请先发布这些修改，或确认不需要后再处理，避免覆盖内容。
    pause
    exit /b 1
)

echo 正在从 GitHub 获取最新内容...
git pull --rebase origin main
if errorlevel 1 (
    echo 同步失败，请查看上面的 Git 提示。
    pause
    exit /b 1
)

echo.
echo 同步完成，可以打开 Typora 继续写笔记。
pause
