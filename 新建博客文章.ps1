$ErrorActionPreference = 'Stop'

try {
    $repoRoot = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($repoRoot)) {
        throw '无法识别博客仓库目录。'
    }

    $postsDir = Join-Path $repoRoot '_posts'
    if (-not (Test-Path $postsDir)) {
        New-Item -ItemType Directory -Path $postsDir -Force | Out-Null
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
        throw '分类输入无效，请输入 1-6。'
    }

    $category = $categoryMap[$choice]
    $title = Read-Host '请输入文章标题'
    if ([string]::IsNullOrWhiteSpace($title)) {
        throw '文章标题不能为空。'
    }

    $slug = Read-Host '请输入文件名（建议英文，如 g01-overview；直接回车自动生成）'
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
    Write-Host "保存位置：$filePath" -ForegroundColor Green
    Write-Host "分类：$category" -ForegroundColor Green
    Write-Host ''

    $typoraCandidates = @(
        "$env:LOCALAPPDATA\Programs\Typora\Typora.exe",
        "$env:ProgramFiles\Typora\Typora.exe",
        "${env:ProgramFiles(x86)}\Typora\Typora.exe"
    )

    $typora = $typoraCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

    if ($typora) {
        Start-Process -FilePath $typora -ArgumentList @($filePath)
        Write-Host '已用 Typora 打开新文章。' -ForegroundColor Cyan
    } else {
        try {
            Start-Process -FilePath $filePath
            Write-Host '未找到 Typora 安装路径，已使用系统默认 Markdown 程序打开。' -ForegroundColor Yellow
        } catch {
            Write-Host '文章已创建，但未能自动打开。请手动在 Typora 中打开上述文件。' -ForegroundColor Yellow
        }
    }

    Start-Sleep -Milliseconds 800
    exit 0
}
catch {
    Write-Host ''
    Write-Host '========================================' -ForegroundColor Red
    Write-Host '新建文章过程中发生错误：' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host '========================================' -ForegroundColor Red
    Write-Host ''
    Read-Host '按回车键退出'
    exit 1
}
