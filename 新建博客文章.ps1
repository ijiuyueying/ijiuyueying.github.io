$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$postsDir = Join-Path $repoRoot '_posts'

try {
    if (-not (Test-Path $postsDir)) {
        New-Item -ItemType Directory -Path $postsDir -Force | Out-Null
    }

    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host 'Jiuyueying Blog - New Post' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '1. Bank / Regulatory Reporting     bank'
    Write-Host '2. Manufacturing DW                manufacturing'
    Write-Host '3. E-commerce Analysis             ecommerce'
    Write-Host '4. SQL / Hive                      sql-hive'
    Write-Host '5. Python                          python'
    Write-Host '6. Git / GitHub                    git'
    Write-Host ''

    $choice = Read-Host 'Choose category 1-6'

    switch ($choice) {
        '1' { $category = 'bank' }
        '2' { $category = 'manufacturing' }
        '3' { $category = 'ecommerce' }
        '4' { $category = 'sql-hive' }
        '5' { $category = 'python' }
        '6' { $category = 'git' }
        default { throw 'Invalid category. Enter 1-6.' }
    }

    $title = Read-Host 'Enter post title'
    if ([string]::IsNullOrWhiteSpace($title)) {
        throw 'Post title cannot be empty.'
    }

    $slug = Read-Host 'Enter file name (English recommended, e.g. g01-overview; Enter for auto name)'
    if ([string]::IsNullOrWhiteSpace($slug)) {
        $slug = 'post-' + (Get-Date -Format 'HHmmss')
    }

    $slug = $slug.Trim()
    $slug = [regex]::Replace($slug, '[\\/:*?"<>| ]+', '-')
    $slug = $slug.Trim('-')

    if ([string]::IsNullOrWhiteSpace($slug)) {
        $slug = 'post-' + (Get-Date -Format 'HHmmss')
    }

    $dateText = Get-Date -Format 'yyyy-MM-dd'
    $timeText = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $fileName = $dateText + '-' + $slug + '.md'
    $filePath = Join-Path $postsDir $fileName

    if (Test-Path $filePath) {
        $fileName = $dateText + '-' + $slug + '-' + (Get-Date -Format 'HHmmss') + '.md'
        $filePath = Join-Path $postsDir $fileName
    }

    $safeTitle = $title.Replace("'", "''")
    $lines = @(
        '---',
        'layout: post',
        "title: '$safeTitle'",
        "date: $timeText +0800",
        "categories: [$category]",
        'tags: []',
        'typora-copy-images-to: ../assets/images/${filename}',
        '---',
        '',
        '## Background / Question',
        '',
        '',
        '## Core Concepts',
        '',
        '',
        '## Implementation / Example',
        '',
        '',
        '## Interview Notes',
        '',
        '',
        '## Summary',
        ''
    )

    $content = $lines -join [Environment]::NewLine
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($filePath, $content, $utf8)

    Write-Host ''
    Write-Host 'Post created successfully.' -ForegroundColor Green
    Write-Host ('Title: ' + $title) -ForegroundColor Green
    Write-Host ('Category: ' + $category) -ForegroundColor Green
    Write-Host ('File: ' + $filePath) -ForegroundColor Green
    Write-Host ''

    $typoraPath = $null
    $candidate1 = Join-Path $env:LOCALAPPDATA 'Programs\Typora\Typora.exe'
    $candidate2 = Join-Path $env:ProgramFiles 'Typora\Typora.exe'

    if (Test-Path $candidate1) {
        $typoraPath = $candidate1
    }
    elseif (Test-Path $candidate2) {
        $typoraPath = $candidate2
    }

    if ($typoraPath) {
        Start-Process -FilePath $typoraPath -ArgumentList $filePath
        Write-Host 'Opened with Typora.' -ForegroundColor Cyan
    }
    else {
        Start-Process $filePath
        Write-Host 'Typora path not found. Opened with default Markdown app.' -ForegroundColor Yellow
    }

    exit 0
}
catch {
    Write-Host ''
    Write-Host '========================================' -ForegroundColor Red
    Write-Host 'Failed to create post' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host '========================================' -ForegroundColor Red
    Write-Host ''
    Read-Host 'Press Enter to exit'
    exit 1
}
