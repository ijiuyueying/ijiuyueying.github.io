$ErrorActionPreference = 'Stop'

$script:BlogRoot = $env:BLOG_ROOT
if ([string]::IsNullOrWhiteSpace($script:BlogRoot)) {
    $script:BlogRoot = (Get-Location).Path
}
$script:BlogRoot = $script:BlogRoot.TrimEnd('\')

$moduleFiles = @(
    '_scripts\blog-manager-common.ps1',
    '_scripts\article-manager.ps1',
    '_scripts\collection-manager-final.ps1',
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

function Show-MainMenu {
    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ' 九月影博客 - 网站内容管理' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '1. 文章分类管理'
    Write-Host '2. 收藏模块管理'
    Write-Host '3. 图片收藏管理'
    Write-Host '4. 视频收藏管理'
    Write-Host '5. 歌曲管理'
    Write-Host '6. 网址导航管理'
    Write-Host '7. 给自建收藏模块新增内容'
    Write-Host '8. 检查网站配置'
    Write-Host '0. 退出'
}

while ($true) {
    Show-MainMenu
    $choice = Read-Host '请选择'
    try {
        switch ($choice) {
            '1' { Manage-ArticleCategories }
            '2' { Manage-CollectionModules }
            '3' { Manage-Gallery }
            '4' { Manage-Videos }
            '5' { Manage-Music }
            '6' { Manage-Links }
            '7' { Add-GenericCollectionItem; Pause-Menu }
            '8' { Test-BlogConfiguration }
            '0' { exit 0 }
            default { Write-Host '无效选项。' -ForegroundColor Yellow; Pause-Menu }
        }
    }
    catch {
        Write-Host ('错误：' + $_.Exception.Message) -ForegroundColor Red
        Pause-Menu
    }
}
