function New-CollectionModule {
    $title=(Read-Host '收藏模块名称').Trim()
    if([string]::IsNullOrWhiteSpace($title)){throw '名称不能为空。'}
    $key=Require-Key '收藏模块 key'
    if(@(Get-CollectionDefs | Where-Object{$_.key -eq $key -or $_.title -eq $title}).Count -gt 0){throw '同名收藏模块已经存在。'}
    if($null -ne (Get-Menu $key)){throw '同 key 的菜单模块已经存在。'}

    $icon=(Read-Host '图标（可空，例如 📚）').Trim()
    $description=(Read-Host '模块说明（可空）').Trim()
    $orderText=(Read-Host '右侧收藏排序数字（可空，默认100）').Trim()
    $order=100
    if($orderText -ne '' -and -not [int]::TryParse($orderText,[ref]$order)){throw '排序必须为数字。'}

    if(-not(Test-Path $script:CollectionDefDir)){New-Item -ItemType Directory -Path $script:CollectionDefDir -Force|Out-Null}
    $defFile=Join-Path $script:CollectionDefDir ($key+'.md')
    $menuFile=Join-Path $script:MenuDir ($key+'.md')
    $pageFile=Join-Path $script:BlogRoot ($key+'.md')
    $dataFile=Join-Path $script:DataDir ($key+'.yml')
    foreach($p in @($defFile,$menuFile,$pageFile)) { if(Test-Path $p){throw ('文件已存在，已停止创建：'+$p)} }

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

    $menu=@"
---
module_key: $key
show_top: false
article_enabled: false
top_label: $title
top_url: /$key/
top_order: 9999
items:
  - key: all
    label: 全部内容
---

# $title 分类配置
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
    Write-Utf8 $menuFile ($menu.TrimStart()+[Environment]::NewLine)
    Write-Utf8 $pageFile ($page.TrimStart()+[Environment]::NewLine)

    Write-Host ''
    Write-Host ('收藏模块创建成功：'+$title+' ['+$key+']') -ForegroundColor Green
    Write-Host ('分类：_menu_defs\'+$key+'.md')
    Write-Host ('入口：'+$key+'.md → /'+$key+'/')
    Write-Host ('数据：_data\'+$key+'.yml')
}

function Remove-CollectionModuleSafe {
    $module=Select-One (Get-CollectionDefs | Where-Object{$_.managed}) '请选择要删除的收藏模块'
    if($null -eq $module){return}
    $dataFile=Get-DataPathForModule $module.key
    $hasData=$false
    if(Test-Path $dataFile){$hasData=((Read-Utf8 $dataFile) -match '(?m)^- title:')}
    $msg=if($hasData){'该模块已有内容。只删除入口和分类配置，数据文件保留。'}else{'将删除入口和分类配置，数据文件保留。'}
    if(-not(Confirm-Delete $msg)){return}

    if(Test-Path $module.file){Remove-Item -LiteralPath $module.file -Force}
    $page=Join-Path $script:BlogRoot ($module.key+'.md')
    if(Test-Path $page){Remove-Item -LiteralPath $page -Force}
    $menu=Join-Path $script:MenuDir ($module.key+'.md')
    if(Test-Path $menu){Remove-Item -LiteralPath $menu -Force}
    Write-Host '收藏模块入口和分类配置已删除；数据文件仍保留。' -ForegroundColor Green
}

function Manage-CollectionModules {
    while($true){
        Clear-Host
        Write-Host '=== 收藏模块管理 ===' -ForegroundColor Cyan
        Write-Host '1. 查看收藏模块'
        Write-Host '2. 新增收藏模块'
        Write-Host '3. 管理收藏模块分类'
        Write-Host '4. 删除自建收藏模块'
        Write-Host '0. 返回'
        $c=Read-Host '请选择'
        try{
            switch($c){
                '1'{Get-CollectionDefs|ForEach-Object{Write-Host ($_.icon+' '+$_.title+' ['+$_.key+']')};Pause-Menu}
                '2'{New-CollectionModule;Pause-Menu}
                '3'{$module=Select-One (Get-CollectionDefs | Where-Object{$_.managed}) '请选择收藏模块';if($module){Manage-MenuCategories $module.key $module.title}}
                '4'{Remove-CollectionModuleSafe;Pause-Menu}
                '0'{return}
                default{Write-Host '无效选项。';Pause-Menu}
            }
        }catch{Write-Host ('错误：'+$_.Exception.Message)-ForegroundColor Red;Pause-Menu}
    }
}
