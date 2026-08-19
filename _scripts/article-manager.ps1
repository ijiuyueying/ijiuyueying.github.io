function New-ArticleModule {
    $label=(Read-Host '一级大类中文名称').Trim()
    if([string]::IsNullOrWhiteSpace($label)){throw '名称不能为空。'}
    $key=Require-Key '一级大类 key'
    $menus=Get-Menus
    if(@($menus|Where-Object{$_.module_key -eq $key -or $_.label -eq $label}).Count -gt 0){throw '同名或同 key 的一级大类已经存在。'}

    $menuFile=Join-Path $script:MenuDir ($key+'.md')
    $pageFile=Join-Path $script:BlogRoot ($key+'.md')
    if(Test-Path $menuFile){throw '对应菜单文件已经存在。'}
    if(Test-Path $pageFile){throw '对应页面文件已经存在。'}

    $orders=@($menus|Where-Object{$_.show_top}|ForEach-Object{$_.top_order})
    $defaultOrder=if($orders.Count){([int](($orders|Measure-Object -Maximum).Maximum)+10)}else{10}
    $orderText=(Read-Host ("顶部排序数字（回车默认 $defaultOrder）")).Trim()
    $order=$defaultOrder
    if($orderText -ne '' -and -not [int]::TryParse($orderText,[ref]$order)){throw '排序必须是整数。'}

    $menu=@"
---
module_key: $key
show_top: true
article_enabled: true
top_label: $label
top_url: /$key/
top_order: $order
items:
  - key: all
    label: 全部文章
---

# $label 分类配置

通过“网站内容管理.bat”维护二级、三级分类。
"@

    $page=@"
---
layout: module
title: $label
permalink: /$key/
module_key: $key
nav_key: $key
description: $label 文章与学习记录。
---
"@

    Write-Utf8 $menuFile ($menu.TrimStart()+[Environment]::NewLine)
    Write-Utf8 $pageFile ($page.TrimStart()+[Environment]::NewLine)

    Write-Host ''
    Write-Host ('一级文章大类创建成功：'+$label+' ['+$key+']') -ForegroundColor Green
    Write-Host ('已创建：_menu_defs\'+$key+'.md')
    Write-Host ('已创建：'+$key+'.md → /'+$key+'/')
    Write-Host '新建博客文章.bat 下次启动会自动识别。' -ForegroundColor Green
}

function Remove-ArticleModule {
    $menu=Select-One @(Get-ArticleMenus|Where-Object{$_.module_key -ne 'project'}) '请选择要删除的一级文章大类'
    if($null -eq $menu){return}
    $used=@(Get-PostRefs|Where-Object{$_.module -eq $menu.module_key})
    if($used.Count -gt 0 -and -not(Confirm-Delete("该一级大类被 $($used.Count) 篇文章使用。仍要删除分类配置和入口页面吗？"))){return}
    if($used.Count -eq 0 -and -not(Confirm-Delete('将删除一级分类配置和对应入口页面。'))){return}

    Remove-Item -LiteralPath $menu.file -Force
    $page=Join-Path $script:BlogRoot ($menu.module_key+'.md')
    if(Test-Path $page){Remove-Item -LiteralPath $page -Force}
    Write-Host '一级大类已删除（文章文件未删除）。' -ForegroundColor Green
}

function Manage-ArticleCategories {
    while($true){
        Clear-Host
        Write-Host '=== 文章分类管理 ===' -ForegroundColor Cyan
        Write-Host '1. 查看当前文章分类'
        Write-Host '2. 新增一级文章大类'
        Write-Host '3. 新增二级分类'
        Write-Host '4. 新增三级分类'
        Write-Host '5. 删除一级大类'
        Write-Host '6. 删除二级分类'
        Write-Host '7. 删除三级分类'
        Write-Host '0. 返回'
        $c=Read-Host '请选择'
        try{
            switch($c){
                '1'{Get-ArticleMenus|ForEach-Object{Show-Tree $_};Pause-Menu}
                '2'{New-ArticleModule;Pause-Menu}
                '3'{$m=Select-One (Get-ArticleMenus) '请选择一级文章大类';if($m){Add-Level2 $m};Pause-Menu}
                '4'{$m=Select-One (Get-ArticleMenus) '请选择一级文章大类';if($m){Add-Level3 $m};Pause-Menu}
                '5'{Remove-ArticleModule;Pause-Menu}
                '6'{$m=Select-One (Get-ArticleMenus) '请选择一级文章大类';if($m){Remove-Level2 $m};Pause-Menu}
                '7'{$m=Select-One (Get-ArticleMenus) '请选择一级文章大类';if($m){Remove-Level3 $m};Pause-Menu}
                '0'{return}
                default{Write-Host '无效选项。';Pause-Menu}
            }
        }catch{Write-Host ('错误：'+$_.Exception.Message) -ForegroundColor Red;Pause-Menu}
    }
}
