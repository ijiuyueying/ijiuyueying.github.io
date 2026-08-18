@echo off
chcp 65001 >nul
cd /d "%~dp0"
setlocal EnableExtensions EnableDelayedExpansion

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
echo [0/5] 检测系统代理...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_scripts\配置Git代理.ps1"

echo.
echo [1/5] 检查本地变更...
git status --short

git add -A
git diff --cached --quiet
if errorlevel 1 (
    set "msg="
    set /p msg=请输入本次更新说明（直接回车使用“更新学习笔记”）：
    if "!msg!"=="" set "msg=更新学习笔记"

    echo.
    echo [2/5] 创建本地提交...
    git commit -m "!msg!"
    if errorlevel 1 (
        echo 提交失败，请查看上面的 Git 提示。
        pause
        exit /b 1
    )
) else (
    echo 没有新的未提交文件，将继续检查是否存在上次未推送的提交。
)

echo.
echo [3/5] 测试 GitHub 连接...
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
    echo 已创建的本地提交不会丢失，下次运行会继续上传。
    pause
    exit /b 1
)

echo GitHub 连接正常。

echo.
echo [4/5] 同步 GitHub 最新内容...
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
    echo 同步失败。若提示 CONFLICT，请不要随意删除文件，把窗口截图发给 ChatGPT。
    echo 若只是网络错误，网络恢复后再次双击本脚本即可继续。
    pause
    exit /b 1
)

echo.
echo [5/5] 推送到 GitHub...
set "pushed=0"
for /L %%i in (1,1,3) do (
    git push origin main
    if not errorlevel 1 (
        set "pushed=1"
        goto :pushed
    )
    echo 第 %%i 次推送失败，2 秒后重试...
    timeout /t 2 /nobreak >nul
)

:pushed
if "!pushed!"=="0" (
    echo 推送仍然失败。本地提交已经保存，网络恢复后再次双击本脚本即可继续。
    pause
    exit /b 1
)

echo.
echo 发布成功！GitHub Pages 会自动更新。
echo 网站：https://ijiuyueying.github.io/
pause
