function New-BlogBackup {
    $backupRoot = Join-Path $script:BlogRoot '_backup'
    if(-not(Test-Path $backupRoot)){New-Item -ItemType Directory -Path $backupRoot | Out-Null}

    $folder = Get-Date -Format 'yyyyMMdd_HHmmss'
    $target = Join-Path $backupRoot $folder
    New-Item -ItemType Directory -Path $target | Out-Null

    $targets=@(
        '_menu_defs',
        '_data',
        '_posts',
        'assets'
    )

    foreach($item in $targets){
        $source=Join-Path $script:BlogRoot $item
        if(Test-Path $source){
            Copy-Item $source $target -Recurse -Force
        }
    }

    Write-Host ('备份完成：'+$target) -ForegroundColor Green
}

function Show-BackupMenu {
    Clear-Host
    Write-Host '=== 博客备份管理 ===' -ForegroundColor Cyan
    Write-Host '1. 创建完整备份'
    Write-Host '2. 查看已有备份'
    Write-Host '0. 返回'

    $c=Read-Host '请选择'
    switch($c){
        '1'{New-BlogBackup;Pause-Menu}
        '2'{
            $dir=Join-Path $script:BlogRoot '_backup'
            if(Test-Path $dir){Get-ChildItem $dir | Sort-Object Name -Descending | ForEach-Object{Write-Host $_.Name}}
            else{Write-Host '暂无备份'}
            Pause-Menu
        }
        default{return}
    }
}

function Invoke-SafeBackup([string]$Reason='manual'){
    $backupRoot = Join-Path $script:BlogRoot '_backup'
    if(-not(Test-Path $backupRoot)){New-Item -ItemType Directory -Path $backupRoot | Out-Null}
    $target=Join-Path $backupRoot ((Get-Date -Format 'yyyyMMdd_HHmmss')+'_'+$Reason)
    New-Item -ItemType Directory -Path $target | Out-Null
    foreach($item in @('_menu_defs','_data','_posts')){
        $source=Join-Path $script:BlogRoot $item
        if(Test-Path $source){Copy-Item $source $target -Recurse -Force}
    }
    return $target
}
