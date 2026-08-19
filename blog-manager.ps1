$ErrorActionPreference = 'Stop'

$script:BlogRoot = $env:BLOG_ROOT
if ([string]::IsNullOrWhiteSpace($script:BlogRoot)) {
    $script:BlogRoot = (Get-Location).Path
}
$script:BlogRoot = $script:BlogRoot.TrimEnd('\')

$moduleFiles = @(
    '_scripts\blog-manager-common.ps1',
    '_scripts\category-manager.ps1',
    '_scripts\article-manager.ps1',
    '_scripts\collection-manager.ps1',
    '_scripts\media-manager.ps1',
    '_scripts\check-manager.ps1'
)

foreach ($relative in $moduleFiles) {
    $path = Join-Path $script:BlogRoot $relative
    if (-not (Test-Path $path)) {
        throw ('缺少管理器模块：' + $relative + '。请先运行“同步博客.bat”。')
    }
    $code = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    Invoke-Expression $code
}
