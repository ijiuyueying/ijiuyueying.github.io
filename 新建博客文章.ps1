$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot
$postsDir = Join-Path $repoRoot '_posts'

if (-not (Test-Path $postsDir)) {
    New-Item -ItemType Directory -Path $postsDir | Out-Null
}

Write-Host '========================================' -ForegroundColor Cyan
Write-Host '九月影博客 - 新建文章' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''
Write-Host '请选择文章分类：'
Write-Host '1. 银行监管报送      bank'
Write-Host '2. 制造业数仓        manufacturing'
Write-Host '3. 电商数据分析      ecommerce'
Write-Host '4. SQL / Hive        sql-hive'
Write-Host '5. Python            python'
Write-Host '6. Git / GitHub      git'
Write-Host ''

$choice = Read-Host '请输入 1-6'
$categoryMap = @{
    '1' = 'bank'
    '2' = 'manufacturing'
    '3' = 'ecommerce'
    '4' = 'sql-hive'
    '5' = 'python'
    '6' = 'git'
}

if (-not $categoryMap.ContainsKey($choice)) {
    Write-Host '分类输入无效，已取消。' -ForegroundColor Red
    Read-Host '按回车退出'
    exit 1
}

$category = $categoryMap[$choice]
$title = Read-Host '请输入文章标题'
if ([string]::IsNullOrWhiteSpace($title)) {
    Write-Host '文章标题不能为空，已取消。' -ForegroundColor Red
    Read-Host '按回车退出'
    exit 1
}

$slug = Read-Host '请输入文件名（建议英文，如 g01-overview；直接回车则自动生成）'
if ([string]::IsNullOrWhiteSpace($slug)) {
    $slug = 'post-' + (Get-Date -Format 'HHmmss')
}

$slug = $slug.Trim()
$slug = [regex]::Replace($slug, '[\\/:*?"<>|\s]+', '-')
$slug = $slug.Trim('-')
if ([string]::IsNullOrWhiteSpace($slug)) {
    $slug = 'post-' + (Get-Date -Format 'HHmmss')
}

$datePrefix = Get-Date -Format 'yyyy-MM-dd'
$fileName = "$datePrefix-$slug.md"
$filePath = Join-Path $postsDir $fileName

if (Test-Path $filePath) {
    $fileName = "$datePrefix-$slug-$(Get-Date -Format 'HHmmss').md"
    $filePath = Join-Path $postsDir $fileName
}

$escapedTitle = $title.Replace("'", "''")
$now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$content = @"
---
layout: post
title: '$escapedTitle'
date: $now +0800
categories: [$category]
tags: []
typora-copy-images-to: ../assets/images/`${filename}
---

## 一、背景 / 问题


## 二、核心概念


## 三、实现 / 案例


## 四、面试怎么回答


## 五、总结

"@

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)

Write-Host ''
Write-Host "文章已创建：$fileName" -ForegroundColor Green
Write-Host "分类：$category" -ForegroundColor Green
Write-Host ''

$typoraCandidates = @(
    "$env:LOCALAPPDATA\Programs\Typora\Typora.exe",
    "$env:ProgramFiles\Typora\Typora.exe",
    "${env:ProgramFiles(x86)}\Typora\Typora.exe"
)

$typora = $typoraCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

try {
    if ($typora) {
        Start-Process -FilePath $typora -ArgumentList ('"' + $filePath + '"')
    } else {
        Start-Process -FilePath $filePath
    }
    Write-Host '已尝试使用 Typora / 默认 Markdown 编辑器打开文章。' -ForegroundColor Cyan
} catch {
    Write-Host "文章已创建，但自动打开失败。请手动打开：$filePath" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2
