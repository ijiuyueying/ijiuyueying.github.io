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
    echo 当前目录不是 Git 仓库，请先按“本地