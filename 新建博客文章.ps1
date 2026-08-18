$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$postsDir = Join-Path $repoRoot '_posts'

try {
    if (-not (Test-Path $postsDir)) {
        New-Item -ItemType Directory -Path $postsDir -Force | Out-Null
    }

    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '九月影博客 - 新建文章' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '1. 银行监管报送     bank'
    Write-Host '2. 制造业数仓       manufacturing'
    Write-Host '3. 电商数据分析     ecommerce'
    Write-Host '4. SQL / Hive       sql-hive'
    Write-Host '5. Python           python'
    Write-Host '6. Git / GitHub     git'
    Write-Host ''

    $choice = Read-Host '请选择分类 1-6'

    switch ($choice) {
        '1' { $category = 'bank' }
        '2' { $category = 'manufacturing' }
        '3' { $category = 'ecommerce' }
        '4' { $category = 'sql-hive' }
        '5' { $category = 'python' }
        '6' { $category = 'git' }
        default { throw '分类无效，请输入 1-6。' }
    }

    $title = Read-Host '请输入文章标题'
    if ([string]::IsNullOrWhiteSpace($title)) {
        throw '文章标题不能为空。'
    }

    $slug = Read-Host '请输入文件名（建议英文，如 g01-overview；直接回车自动生成）'
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
        '## 一、背景 / 问题',
        '',
        '',
        '## 二、核心概念',
        '',
        '',
        '## 三、实现 / 案例',
        '',
        '',
        '## 四、面试怎么回答',
        '',
        '',
        '## 五、总结',
        ''
    )

    $content = $lines -join [Environment]::NewLine
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($filePath, $content, $utf8)

    Write-Host ''
    Write-Host '文章创建成功。' -ForegroundColor Green
    Write-Host ('标题：' + $title) -ForegroundColor Green
    Write-Host ('分类：' + $category) -ForegroundColor Green
    Write-Host ('文件：' + $filePath) -ForegroundColor Green
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
        Write-Host '已自动用 Typora 打开。' -ForegroundColor Cyan
    }
    else {
        Start-Process $filePath
        Write-Host '已使用系统默认 Markdown 程序打开。' -ForegroundColor Yellow
    }

    exit 0
}
catch {
    Write-Host ''
    Write-Host '========================================' -ForegroundColor Red
    Write-Host '新建文章失败' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host '========================================' -ForegroundColor Red
    Write-Host ''
    Read-Host '按回车退出'
    exit 1
}
