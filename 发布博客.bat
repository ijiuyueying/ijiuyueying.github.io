@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ========================================
echo 九月影博客 - 一键发布
echo ========================================

where git >nul 2>nul
if errorlevel 1 (
    echo 未检测到 Git，请先安装 Git for Windows。
    pause
    exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>nul
if errorlevel 1 (
    echo 当前目录不是 Git 仓库，请先按“本地使用说明.md”完成首次克隆。
    pause
    exit /b 1
)

echo.
echo [1/4] 检查本地变更...
git status --short
git add -A
git diff --cached --quiet
if not errorlevel 1 (
    echo.
    echo 没有需要发布的新内容。
    pause
    exit /b 0
)

set "msg="
set /p msg=请输入本次更新说明（直接回车使用“更新学习笔记”）：
if "%msg%"=="" set "msg=更新学习笔记"

echo.
echo [2/4] 创建本地提交...
git commit -m "%msg%"
if errorlevel 1 (
    echo 提交失败，请查看上面的 Git 提示。
    pause
    exit /b 1
)

echo.
echo [3/4] 同步 GitHub 最新内容...
git pull --rebase origin main
if errorlevel 1 (
    echo 同步失败，可能存在冲突。请先不要继续操作，把窗口截图发给 ChatGPT。
    pause
    exit /b 1
)

echo.
echo [4/4] 推送到 GitHub...
git push origin main
if errorlevel 1 (
    echo 推送失败，请查看上面的 Git 提示。
    pause
    exit /b 1
)

echo.
echo 发布成功！GitHub Pages 会自动更新。
echo 网站：https://ijiuyueying.github.io/
pause
