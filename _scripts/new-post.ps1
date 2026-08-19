$ErrorActionPreference = 'Stop'

$script:BlogRoot = $env:BLOG_ROOT
if ([string]::IsNullOrWhiteSpace($script:BlogRoot)) {
    $script:BlogRoot = (Get-Location).Path
}
$script:BlogRoot = $script:BlogRoot.TrimEnd('\')

$postsDir = Join-Path $script:BlogRoot '_posts'
$menuDir = Join-Path $script:BlogRoot '_menu_defs'
$utf8 = New-Object System.Text.UTF8Encoding($false)

try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch {}

function Read-Utf8([string]$path) {
    return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

function Read-MenuDefinition([string]$filePath) {
    $text = Read-Utf8 $filePath
    $lines = $text -split "`r?`n"

    $moduleKey = ''
    $topLabel = ''
    $articleEnabled = $false
    $topOrder = 9999
    $items = New-Object System.Collections.ArrayList
    $current = $null
    $inChildren = $false
    $inItems = $false
    $insideFrontMatter = $false

    foreach ($line in $lines) {
        if (-not $insideFrontMatter -and $line -match '^---\s*$') {
            $insideFrontMatter = $true
            continue
        }
        if ($insideFrontMatter -and $line -match '^---\s*$') {
            if ($null -ne $current) {
                [void]$items.Add($current)
                $current = $null
            }
            break
        }
        if (-not $insideFrontMatter) { continue }

        if (-not $inItems) {
            if ($line -match '^module_key:\s*(.+?)\s*$') {
                $moduleKey = $Matches[1].Trim().Trim('"').Trim("'")
                continue
            }
            if ($line -match '^top_label:\s*(.+?)\s*$') {
                $topLabel = $Matches[1].Trim().Trim('"').Trim("'")
                continue
            }
            if ($line -match '^article_enabled:\s*(true|false)\s*$') {
                $articleEnabled = ($Matches[1].ToLower() -eq 'true')
                continue
            }
            if ($line -match '^top_order:\s*(\d+)\s*$') {
                $topOrder = [int]$Matches[1]
                continue
            }
            if ($line -match '^items:\s*$') {
                $inItems = $true
                continue
            }
            continue
        }

        if ($line -match '^  - key:\s*(.+?)\s*$') {
            if ($null -ne $current) { [void]$items.Add($current) }
            $current = [ordered]@{
                key = $Matches[1].Trim().Trim('"').Trim("'")
                label = ''
                children = New-Object System.Collections.ArrayList
            }
            $inChildren = $false
            continue
        }

        if ($null -eq $current) { continue }

        if ($line -match '^    label:\s*(.+?)\s*$' -and -not $inChildren) {
            $current.label = $Matches[1].Trim().Trim('"').Trim("'")
            continue
        }

        if ($line -match '^    children:\s*$') {
            $inChildren = $true
            continue
        }

        if ($line -match '^    slides:\s*$') {
            $inChildren = $false
            continue
        }

        if ($inChildren -and $line -match '^      - key:\s*(.+?)\s*$') {
            [void]$current.children.Add([ordered]@{
                key = $Matches[1].Trim().Trim('"').Trim("'")
                label = ''
            })
            continue
        }

        if ($inChildren -and $line -match '^        label:\s*(.+?)\s*$' -and $current.children.Count -gt 0) {
            $current.children[$current.children.Count - 1].label = $Matches[1].Trim().Trim('"').Trim("'")
            continue
        }
    }

    if ($null -ne $current) { [void]$items.Add($current) }

    if ([string]::IsNullOrWhiteSpace($moduleKey)) { return $null }
    if ([string]::IsNullOrWhiteSpace($topLabel)) { $topLabel = $moduleKey }

    return [pscustomobject]@{
        module_key = $moduleKey
        label = $topLabel
        article_enabled = $articleEnabled
        top_order = $topOrder
        file = $filePath
        items = @($items | Where-Object { $_.key -ne 'all' })
    }
}

function Load-ArticleModules {
    if (-not (Test-Path $menuDir)) {
        throw 'Cannot find _menu_defs directory. Run sync first.'
    }

    $modules = New-Object System.Collections.ArrayList
    Get-ChildItem -Path $menuDir -Filter '*.md' -File | ForEach-Object {
        $def = Read-MenuDefinition $_.FullName
        if ($null -ne $def -and $def.article_enabled) {
            [void]$modules.Add($def)
        }
    }

    return @($modules | Sort-Object top_order, label)
}

function Read-Choice([string]$prompt, [int]$min, [int]$max) {
    $raw = Read-Host $prompt
    $number = 0
    if (-not [int]::TryParse($raw, [ref]$number) -or $number -lt $min -or $number -gt $max) {
        throw ('Invalid choice. Please enter ' + $min + '-' + $max + '.')
    }
    return $number
}

try {
    if (-not (Test-Path $postsDir)) {
        New-Item -ItemType Directory -Path $postsDir -Force | Out-Null
    }

    $modules = @(Load-ArticleModules)
    if ($modules.Count -eq 0) {
        throw 'No article-enabled modules found. Add article_enabled: true to a _menu_defs/*.md file.'
    }

    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host 'Jiuyueying Blog - New Post' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Choose Level 1 module:' -ForegroundColor Yellow

    for ($i = 0; $i -lt $modules.Count; $i++) {
        Write-Host (('{0}. {1}   [{2}]' -f ($i + 1), $modules[$i].label, $modules[$i].module_key))
    }

    $moduleChoice = Read-Choice ('Enter 1-' + $modules.Count) 1 $modules.Count
    $selectedModule = $modules[$moduleChoice - 1]
    $moduleKey = $selectedModule.module_key
    $moduleLabel = $selectedModule.label
    $categories = @($selectedModule.items)

    if ($categories.Count -eq 0) {
        throw ('No Level 2 categories found in module: ' + $moduleLabel)
    }

    Write-Host ''
    Write-Host ('Level 1 selected: ' + $moduleLabel) -ForegroundColor Green
    Write-Host 'Choose Level 2 category:' -ForegroundColor Yellow

    for ($i = 0; $i -lt $categories.Count; $i++) {
        Write-Host (('{0}. {1}   [{2}]' -f ($i + 1), $categories[$i].label, $categories[$i].key))
    }

    $choice = Read-Choice ('Enter 1-' + $categories.Count) 1 $categories.Count
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

        $subChoice = Read-Choice ('Enter 0-' + $selected.children.Count) 0 $selected.children.Count
        if ($subChoice -gt 0) {
            $subcategory = $selected.children[$subChoice - 1].key
            $subcategoryLabel = $selected.children[$subChoice - 1].label
        }
    }

    Write-Host ''
    $title = (Read-Host 'Enter post title').Trim()
    if ([string]::IsNullOrWhiteSpace($title)) {
        throw 'Post title cannot be empty.'
    }

    $slug = (Read-Host 'Enter file name (English recommended; Enter for auto name)').Trim()
    if ([string]::IsNullOrWhiteSpace($slug)) {
        $slug = 'post-' + (Get-Date -Format 'HHmmss')
    }

    $slug = [regex]::Replace($slug, '[\\/:*?"<>| ]+', '-').Trim('-')
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
    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add('---')
    [void]$lines.Add('layout: post')
    [void]$lines.Add("title: '$safeTitle'")
    [void]$lines.Add("date: $timeText +0800")
    [void]$lines.Add("module: $moduleKey")
    [void]$lines.Add("categories: [$category]")
    if (-not [string]::IsNullOrWhiteSpace($subcategory)) {
        [void]$lines.Add("subcategory: $subcategory")
    }
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
    [System.IO.File]::WriteAllText($filePath, $content, $utf8)

    Write-Host ''
    Write-Host 'Post created successfully.' -ForegroundColor Green
    Write-Host ('Level 1: ' + $moduleLabel + ' [' + $moduleKey + ']') -ForegroundColor Green
    Write-Host ('Level 2: ' + $categoryLabel + ' [' + $category + ']') -ForegroundColor Green
    if ($subcategory) {
        Write-Host ('Level 3: ' + $subcategoryLabel + ' [' + $subcategory + ']') -ForegroundColor Green
    }
    Write-Host ('File: ' + $filePath) -ForegroundColor Green
    Write-Host ''

    $typoraPath = $null
    $candidate1 = Join-Path $env:LOCALAPPDATA 'Programs\Typora\Typora.exe'
    $candidate2 = Join-Path $env:ProgramFiles 'Typora\Typora.exe'

    if (Test-Path $candidate1) { $typoraPath = $candidate1 }
    elseif (Test-Path $candidate2) { $typoraPath = $candidate2 }

    if ($typoraPath) {
        Start-Process -FilePath $typoraPath -ArgumentList ('"' + $filePath + '"')
    } else {
        Start-Process -FilePath $filePath
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
