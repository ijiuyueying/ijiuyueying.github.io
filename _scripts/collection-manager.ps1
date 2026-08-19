function New-CollectionModule {
    $title=(Read-Host '收藏模块名称').Trim()
    if([string]::IsNullOrWhiteSpace($title)){throw '名称不能为空。'}
    $key=Require-Key '收藏模块 key'

    if(@(Get-CollectionDefs | Where-Object{$_.key -eq $key -or $_.title -eq $title}).Count -gt 0){throw '同名收藏模块已经存在。'}

    $icon=(Read-Host '图标（可空，例如 📚）').Trim()
    $description=(Read-Host '模块说明（可空）').Trim()
    $orderText=(Read-Host '排序数字（可空）').Trim()
    $order=100
    if($orderText -ne ''){
        if(-not [int]::TryParse($orderText,[ref]$order)){throw '排序必须为数字。'}
    }

    $defDir=$script:CollectionDefDir
    if(-not(Test-Path $defDir)){New-Item -ItemType Directory -Path $defDir -Force|Out-Null}

    $defFile=Join-Path $defDir ($key+'.md')
    $pageFile=Join-Path $script:BlogRoot ($key+'.md')
    $dataFile=Join-Path $script:DataDir ($key+'.yml')

    $def=@"
---
key: $key
title: $title
icon: $icon
description: $description
public_url: /$key/
order: $order
managed: true
---
"@

    $page=@"
---
layout: collection
title: $title
permalink: /$key/
module_key: $key
data_key: $key
description: $description
---
"@

    if(-not(Test-Path $dataFile)){Write-Utf8 $dataFile "# $title 数据文件`n"}
    Write-Utf8 $defFile ($def.TrimStart()+[Environment]::NewLine)
    Write-Utf8 $pageFile ($page.TrimStart()+[Environment]::NewLine)

    Write-Host ''
    Write-Host ('收藏模块创建成功：'+$title+' ['+$key+']') -ForegroundColor Green
    Write-Host ('配置：'+$defFile)
    Write-Host ('页面：'+$pageFile)
    Write-Host ('数据：'+$dataFile)
}

function Remove-CollectionModule {
    $module=Select-One (Get-CollectionDefs | Where-Object{$_.managed}) '请选择要删除的收藏模块'
    if($null -eq $module){return}

    if(-not(Confirm-Delete('将删除模块配置和入口页面，数据文件保留。'))){return}

    Remove-Item -LiteralPath $module.file -Force
    $page=Join-Path $script:BlogRoot ($module.key+'.md')
    if(Test-Path $page){Remove-Item -LiteralPath $page -Force}

    Write-Host '收藏模块入口已删除，数据文件未删除。' -ForegroundColor Green
}

function Manage-CollectionModules {
    while($true){
        Clear-Host
        Write-Host '=== 收藏模块管理 ===' -ForegroundColor Cyan
        Write-Host '1. 查看收藏模块'
        Write-Host '2. 新增收藏模块'
        Write-Host '3. 删除收藏模块'
        Write-Host '0. 返回'
        $c=Read-Host '请选择'
        try{
            switch($c){
                '1'{Get-CollectionDefs|ForEach-Object{Write-Host ($_.icon+' '+$_.title+' ['+$_.key+']')};Pause-Menu}
                '2'{New-CollectionModule;Pause-Menu}
                '3'{Remove-CollectionModule;Pause-Menu}
                '0'{return}
                default{Write-Host '无效选项。';Pause-Menu}
            }
        }catch{Write-Host ('错误：'+$_.Exception.Message)-ForegroundColor Red;Pause-Menu}
    }
}
