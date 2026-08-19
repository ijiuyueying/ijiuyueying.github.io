$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$postsDir = Join-Path $repoRoot '_posts'
$categoriesFile = Join-Path $repoRoot '_data\project_categories.yml'

function Load-ProjectCategories {
    if (-not (Test-Path $categoriesFile)) {
        throw 'Cannot find _data/project_categories.yml. Run sync first.'
    }

    $text = [System.IO.File]::ReadAllText($categoriesFile, [System.Text.Encoding]::UTF8)
    $lines = $text -split "`r?`n"
    $result = New-Object System.Collections.ArrayList
    $current = $null
    $inChildren = $false

    foreach ($line in $lines) {
        if ($line -match '^- key:\s*(.+?)\s*$') {
            if ($null -ne $current) { [void]$result.Add($current) }
            $current = [ordered]@{ key = $Matches[1].Trim(); label = ''; children = New-Object System.Collections.ArrayList }
            $inChildren = $false
            continue
        }
        if ($null -eq $current) { continue }

        if ($line -match '^  label:\s*(.+?)\s*$' -and -not $inChildren) {
            $current.label = $Matches[1].Trim()
            continue
        }
        if ($line -match '^  children:\s*$') {
            $inChildren = $true
            continue
        }
        if ($line -match '^  slides:\s*$') {
            $inChildren = $false
            continue
        }
        if ($inChildren -and $line -match '^    - key:\s*(.+?)\s*$') {
            $child = [ordered]@{ key = $Matches[1].Trim(); label = '' }
            [void]$current.children.Add($child)
            continue
        }
        if ($inChildren -and $line -match '^      label:\s*(.+?)\s*$' -and $current.children.Count -gt 0) {
            $current.children[$current.children.Count - 1].label = $Matches[1].Trim()
            continue
        }
    }
    if ($null -ne $current) { [void]$result.Add($current) }

    return @($result | Where-Object { $_.key -ne 'all' })
}

try {
    if (-not (Test-Path $postsDir)) {
        New-Item -ItemType Directory -Path $postsDir -Force | Out-Null
    }

    $categories = @(Load-ProjectCategories)
    if ($categories.Count -eq 0) { throw 'No project categories found.' }

    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host 'Jiuyueying Blog - New Project Post' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Level 1 Module: Project' -ForegroundColor DarkGray
    Write-Host ''
    Write-Host 'Choose Level 2 category:' -ForegroundColor Yellow

    for ($i = 0; $i -lt $categories.Count; $i++) {
        Write-Host (('{0}. {1}   [{2}]' -f ($i + 1), $categories[$i].label, $categories[$i].key))
    }

    $choiceText = Read-Host ('Enter 1-' + $categories.Count)
    $choice = 0
    if (-not [int]::TryParse($choiceText, [ref]$choice) -or $choice -lt 1 -or $choice -gt $categories.Count) {
        throw 'Invalid Level 2 category.'
    }

    $selected = $categories[$choice - 1]
    $category = $selected.key
    $categoryLabel = $selected.label
    $subcategory = ''
    $subcategoryLabel = ''

    if ($selected.children.Count -gt 0) {
        Write-Host ''
        Write-Host ('Level 2 selected: ' + $categoryLabel) -ForegroundColor Green
        Write-Host 'Choose Level 3 category:' -ForegroundColor Yellow
        Write-Host '0. No Level 3 category'
        for ($i = 0; $i -lt $selected.children.Count; $i++) {
            Write-Host (('{0}. {1}   [{2}]' -f ($i + 1), $selected.children[$i].label, $selected.children[$i].key))
        }

        $subText = Read-Host ('Enter 0-' + $selected.children.Count)
        $subChoice = 0
        if (-not [int]::TryParse($subText, [ref]$subChoice) -or $subChoice -lt 0 -or $subChoice -gt $selected.children.Count) {
            throw 'Invalid Level 3 category.'
        }
        if ($subChoice -gt 0) {
            $subcategory = $selected.children[$subChoice - 1].key
            $subcategoryLabel = $selected.children[$subChoice - 1].label
        }
    }

    Write-Host ''
    $title = Read-Host 'Enter post title'
    if ([string]::IsNullOrWhiteSpace($title)) { throw 'Post title cannot be empty.' }

    $slug = Read-Host 'Enter file name (English recommended; Enter for auto name)'
    if ([string]::IsNullOrWhiteSpace($slug)) { $slug = 'post-' + (Get-Date -Format 'HHmmss') }
    $slug = [regex]::Replace($slug.Trim(), '[\\/:*?"<>| ]+', '-').Trim('-')
    if ([string]::IsNullOrWhiteSpace($slug)) { $slug = 'post-' + (Get-Date -Format 'HHmmss') }

    $dateText = Get-Date -Format 'yyyy-MM-dd'
    $timeText = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $fileName = $dateText + '-' + $slug + '.md'
    $filePath = Join-Path $postsDir $fileName
    if (Test-Path $filePath) {
        $fileName = $dateText + '-' + $slug + '-' + (Get-Date -Format 'HHmmss') + '.md'
        $filePath = Join-Path $postsDir $fileName
    }

    $safeTitle = $title.Replace("'", "''")
    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add('---')
    [void]$lines.Add('layout: post')
    [void]$lines.Add("title: '$safeTitle'")
    [void]$lines.Add("date: $timeText +0800")
    [void]$lines.Add("categories: [$category]")
    if (-not [string]::IsNullOrWhiteSpace($subcategory)) { [void]$lines.Add("subcategory: $subcategory") }
    [void]$lines.Add('tags: []')
    [void]$lines.Add('typora-copy-images-to: ../assets/images/${filename}')
    [void]$lines.Add('---')
    [void]$lines.Add('')
    [void]$lines.Add('## 背景 / 问题')
    [void]$lines.Add('')
    [void]$lines.Add('')
    [void]$lines.Add('## 核心概念')
    [void]$lines.Add('')
    [void]$lines.Add('')
    [void]$lines.Add('## 实现 / 案例')
    [void]$lines.Add('')
    [void]$lines.Add('')
    [void]$lines.Add('## 面试怎么回答')
    [void]$lines.Add('')
    [void]$lines.Add('')
    [void]$lines.Add('## 总结')
    [void]$lines.Add('')

    $content = $lines -join [Environment]::NewLine
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($filePath, $content, $utf8)

    Write-Host ''
    Write-Host 'Post created successfully.' -ForegroundColor Green
    Write-Host ('Level 1: Project') -ForegroundColor Green
    Write-Host ('Level 2: ' + $categoryLabel + ' [' + $category + ']') -ForegroundColor Green
    if ($subcategory) { Write-Host ('Level 3: ' + $subcategoryLabel + ' [' + $subcategory + ']') -ForegroundColor Green }
    Write-Host ('File: ' + $filePath) -ForegroundColor Green
    Write-Host ''

    $typoraPath = $null
    $candidate1 = Join-Path $env:LOCALAPPDATA 'Programs\Typora\Typora.exe'
    $candidate2 = Join-Path $env:ProgramFiles 'Typora\Typora.exe'
    if (Test-Path $candidate1) { $typoraPath = $candidate1 }
    elseif (Test-Path $candidate2) { $typoraPath = $candidate2 }

    if ($typoraPath) { Start-Process -FilePath $typoraPath -ArgumentList $filePath }
    else { Start-Process $filePath }
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
