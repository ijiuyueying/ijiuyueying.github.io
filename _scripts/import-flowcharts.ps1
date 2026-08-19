$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $repoRoot 'assets\images\gallery\data-warehouse'
$tempDir = Join-Path $env:TEMP ('jiuyueying-flowcharts-' + [Guid]::NewGuid().ToString('N'))

function Find-Extractor {
    $candidates = @(
        @{ Path = (Join-Path $env:ProgramFiles '7-Zip\7z.exe'); Type = '7z' },
        @{ Path = (Join-Path ${env:ProgramFiles(x86)} '7-Zip\7z.exe'); Type = '7z' },
        @{ Path = (Join-Path $env:ProgramFiles 'WinRAR\UnRAR.exe'); Type = 'unrar' },
        @{ Path = (Join-Path ${env:ProgramFiles(x86)} 'WinRAR\UnRAR.exe'); Type = 'unrar' },
        @{ Path = (Join-Path $env:ProgramFiles 'WinRAR\WinRAR.exe'); Type = 'winrar' },
        @{ Path = (Join-Path ${env:ProgramFiles(x86)} 'WinRAR\WinRAR.exe'); Type = 'winrar' }
    )
    foreach ($c in $candidates) {
        if ($c.Path -and (Test-Path $c.Path)) { return $c }
    }
    return $null
}

function Select-RarFile {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Select flowchart RAR file'
    $dialog.Filter = 'RAR files (*.rar)|*.rar|All files (*.*)|*.*'
    $dialog.Multiselect = $false
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $dialog.FileName }
    return $null
}

function Save-Jpeg([string]$sourcePath, [string]$destPath) {
    Add-Type -AssemblyName System.Drawing
    $src = [System.Drawing.Image]::FromFile($sourcePath)
    try {
        $maxWidth = 1600
        $maxHeight = 1800
        $scale = [Math]::Min(1.0, [Math]::Min($maxWidth / $src.Width, $maxHeight / $src.Height))
        $w = [Math]::Max(1, [int]($src.Width * $scale))
        $h = [Math]::Max(1, [int]($src.Height * $scale))
        $bmp = New-Object System.Drawing.Bitmap($w, $h)
        try {
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            try {
                $g.Clear([System.Drawing.Color]::White)
                $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $g.DrawImage($src, 0, 0, $w, $h)
            } finally { $g.Dispose() }

            $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' } | Select-Object -First 1
            $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]84)
            $bmp.Save($destPath, $encoder, $params)
        } finally { $bmp.Dispose() }
    } finally { $src.Dispose() }
}

$names = @{
    '01' = '01-overview.jpg'
    '02' = '02-full-pipeline.jpg'
    '03' = '03-data-governance.jpg'
    '04' = '04-data-quality.jpg'
    '05' = '05-anomaly-overview.jpg'
    '06' = '06-task-failure.jpg'
    '07' = '07-performance-optimization.jpg'
    '08' = '08-sql-hive-optimization.jpg'
    '09' = '09-hive-optimization.jpg'
    '10' = '10-oracle-optimization.jpg'
    '11' = '11-data-skew.jpg'
    '12' = '12-small-files.jpg'
    '13' = '13-purchase-report.jpg'
    '14' = '14-dolphinscheduler.jpg'
    '15' = '15-yarn-hadoop.jpg'
    '16' = '16-datax-sync.jpg'
    '17' = '17-finereport.jpg'
}

try {
    $rarPath = Select-RarFile
    if (-not $rarPath) { exit 0 }

    $extractor = Find-Extractor
    if (-not $extractor) {
        throw '7-Zip or WinRAR was not found. Install either one, then run this script again.'
    }

    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null

    Write-Host '[1/3] Extracting RAR...' -ForegroundColor Cyan
    if ($extractor.Type -eq '7z') {
        & $extractor.Path x -y "-o$tempDir" $rarPath | Out-Null
    } elseif ($extractor.Type -eq 'unrar') {
        & $extractor.Path x -y $rarPath ($tempDir + '\') | Out-Null
    } else {
        & $extractor.Path x -ibck -y $rarPath ($tempDir + '\') | Out-Null
    }
    if ($LASTEXITCODE -ne 0) { throw 'RAR extraction failed.' }

    Write-Host '[2/3] Converting images for web...' -ForegroundColor Cyan
    Add-Type -AssemblyName System.Drawing
    $files = Get-ChildItem -Path $tempDir -Recurse -File | Where-Object { $_.Extension -match '^\.(png|jpg|jpeg)$' }
    $count = 0

    foreach ($file in $files) {
        $targetName = $null
        if ($file.BaseName -match '^(\d{2})') {
            $key = $Matches[1]
            if ($names.ContainsKey($key)) { $targetName = $names[$key] }
        } elseif ($file.BaseName -like 'ChatGPT*') {
            continue
        } else {
            $img = [System.Drawing.Image]::FromFile($file.FullName)
            try {
                if ($img.Width -gt 2000) { $targetName = '18-performance-troubleshooting.jpg' }
                elseif ($img.Width -eq 1195 -and $img.Height -eq 1316) { $targetName = '19-data-anomaly-category.jpg' }
                elseif ($img.Width -eq 1254 -and $img.Height -eq 1254) { $targetName = '20-data-anomaly.jpg' }
            } finally { $img.Dispose() }
        }

        if ($targetName) {
            $dest = Join-Path $outDir $targetName
            Save-Jpeg $file.FullName $dest
            $count++
            Write-Host ('  -> ' + $targetName)
        }
    }

    Write-Host '[3/3] Done.' -ForegroundColor Green
    Write-Host ('Imported ' + $count + ' images to:') -ForegroundColor Green
    Write-Host $outDir -ForegroundColor Green
    Write-Host ''
    Write-Host 'Next: run publish-blog.bat (or your publish shortcut) to upload them to GitHub.' -ForegroundColor Yellow
}
catch {
    Write-Host ''
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
}
finally {
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Host ''
    Read-Host 'Press Enter to exit'
}
