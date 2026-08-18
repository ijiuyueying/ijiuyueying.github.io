@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 九月影博客 - 新建文章

where powershell >nul 2>nul
if errorlevel 1 (
    echo 未检测到 Windows PowerShell，无法运行新建文章脚本。
    echo.
    pause
    exit /b 1
)

if not exist "%~dp0新建博客文章.ps1" (
    echo 找不到：新建博客文章.ps1
    echo 请先运行“同步博客.bat”获取完整文件。
    echo.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0新建博客文章.ps1"
set "exitcode=%errorlevel%"

if not "%exitcode%"=="0" (
    echo.
    echo ========================================
    echo 新建文章失败，错误代码：%exitcode%
    echo 请不要关闭此窗口，把上面的报错截图发给 ChatGPT。
    echo ========================================
    echo.
    pause
    exit /b %exitcode%
)

exit /b 0
