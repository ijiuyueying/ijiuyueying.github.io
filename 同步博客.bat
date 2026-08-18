@echo off
chcp 65001 >nul
cd /d "%~dp0"
setlocal EnableExtensions EnableDelayedExpansion

echo ========================================
echo 九月影博客 - 同步 GitHub 最新内容
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
echo [0/3] 检测系统代理...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_scripts\配置Git代理.ps1"

echo.
echo [1/3] 检查本地状态...
set "dirty="
for /f "delims=" %%i in ('git status --porcelain') do set "dirty=1"
if defined dirty (
    echo 检测到本地还有未提交的修改。
    echo 为避免同步时覆盖内容，请先运行“发布博客.bat”提交这些修改。
    pause
    exit /b 1
)

echo.
echo [2/3] 测试 GitHub 连接...
set "connected=0"
for /L %%i in (1,1,3) do (
    echo 第 %%i 次连接测试...
    git ls-remote origin >nul 2>nul
    if not errorlevel 1 (
        set "connected=1"
        goto :connected
    )
    timeout /t 2 /nobreak >nul
)

:connected
if "!connected!"=="0" (
    echo GitHub 连接失败。请检查网络、代理或加速器状态后再次双击本脚本。
    pause
    exit /b 1
)

echo GitHub 连接正常。

echo.
echo [3/3] 同步 GitHub 最新内容...
set "pulled=0"
for /L %%i in (1,1,3) do (
    git pull --rebase origin main
    if not errorlevel 1 (
        set "pulled=1"
        goto :pulled
    )
    echo 第 %%i 次同步失败，2 秒后重试...
    timeout /t 2 /nobreak >nul
)

:pulled
if "!pulled!"=="0" (
    echo 同步仍然失败。
    echo 若提示 CONFLICT，请不要随意删除文件，把窗口截图发给 ChatGPT。
    echo 若只是网络错误，网络恢复后再次双击本脚本即可。
    pause
    exit /b 1
)

echo.
echo 同步完成，可以打开 Typora 继续写笔记。
pause
