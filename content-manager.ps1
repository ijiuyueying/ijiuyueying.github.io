$ErrorActionPreference = 'Stop'

$root = $env:BLOG_ROOT
if ([string]::IsNullOrWhiteSpace($root)) { $root = (Get-Location).Path }
$root = $root.TrimEnd('\')
$utf8 = New-Object System.Text.UTF8Encoding($false)
$menuDir = Join-Path $root '_menu_defs'
$dataDir = Join-Path $root '_data'
$postsDir = Join-Path $root '_posts'

function Read-Utf8([string]$path) { return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8) }
function Write-Utf8([string]$path, [string]$text) { [System.IO.File]::WriteAllText($path, $text, $utf8) }
function Pause-Menu { [void](Read-Host '按回车继续') }
function Yaml-Q([string]$text) { if ($null -eq $text) { $text = '' }; return '"' + $text.Replace('\','\\').Replace('"','\"') + '"' }
function Require-Key([string]$prompt) {
    $key = (Read-Host $prompt).Trim().ToLower()
    if ($key -notmatch '^[a-z0-9][a-z0-9-]*$') { throw 'key 只能使用英文小写、数字和短横线，例如 study、bigdata、hadoop-notes。' }
    return $key
}
function Append-Utf8([string]$path, [string]$text) {
    $old = if (Test-Path $path) { Read-Utf8 $path } else { '' }
    if ($old.Length -gt 0 -and -not $old.EndsWith("`n")) { $old += [Environment]::NewLine }
    Write-Utf8 $path ($old + $text)
}

function Read-MenuDefinition([string]$filePath) {
    $lines = (Read-Utf8 $filePath) -split "`r?`n"
    $moduleKey=''; $topLabel=''; $topUrl=''; $articleEnabled=$false; $showTop=$false; $topOrder=9999
    $items = New-Object System.Collections.ArrayList
    $current=$null; $inChildren=$false; $inItems=$false; $inside=$false
    foreach ($line in $lines) {
        if (-not $inside -and $line -match '^---\s*$') { $inside=$true; continue }
        if ($inside -and $line -match '^---\s*$') { if ($null -ne $current) { [void]$items.Add($current) }; break }
        if (-not $inside) { continue }
        if (-not $inItems) {
            if ($line -match '^module_key:\s*(.+?)\s*$') { $moduleKey=$Matches[1].Trim(); continue }
            if ($line -match '^top_label:\s*(.+?)\s*$') { $topLabel=$Matches[1].Trim(); continue }
            if ($line -match '^top_url:\s*(.+?)\s*$') { $topUrl=$Matches[1].Trim().Trim('"').Trim("'"); continue }
            if ($line -match '^article_enabled:\s*(true|false)\s*$') { $articleEnabled=($Matches[1].ToLower() -eq 'true'); continue }
            if ($line -match '^show_top:\s*(true|false)\s*$') { $showTop=($Matches[1].ToLower() -eq 'true'); continue }
            if ($line -match '^top_order:\s*(\d+)\s*$') { $topOrder=[int]$Matches[1]; continue }
            if ($line -match '^items:\s*$') { $inItems=$true; continue }
            continue
        }
        if ($line -match '^  - key:\s*(.+?)\s*$') {
            if ($null -ne $current) { [void]$items.Add($current) }
            $current=[ordered]@{key=$Matches[1].Trim();label='';children=New-Object System.Collections.ArrayList}
            $inChildren=$false; continue
        }
        if ($null -eq $current) { continue }
        if ($line -match '^    label:\s*(.+?)\s*$' -and -not $inChildren) { $current.label=$Matches[1].Trim(); continue }
        if ($line -match '^    children:\s*$') { $inChildren=$true; continue }
        if ($line -match '^    slides:\s*$') { $inChildren=$false; continue }
        if ($inChildren -and $line -match '^      - key:\s*(.+?)\s*$') { [void]$current.children.Add([ordered]@{key=$Matches[1].Trim();label=''}); continue }
        if ($inChildren -and $line -match '^        label:\s*(.+?)\s*$' -and $current.children.Count -gt 0) { $current.children[$current.children.Count-1].label=$Matches[1].Trim(); continue }
    }
    if ([string]::IsNullOrWhiteSpace($moduleKey)) { return $null }
    if ([string]::IsNullOrWhiteSpace($topLabel)) { $topLabel=$moduleKey }
    return [pscustomobject]@{module_key=$moduleKey;label=$topLabel;top_url=$topUrl;article_enabled=$articleEnabled;show_top=$showTop;top_order=$topOrder;file=$filePath;items=@($items)}
}

function Get-Menus {
    if (-not (Test-Path $menuDir)) { throw '_menu_defs 目录不存在，请先运行同步博客.bat。' }
    $result=New-Object System.Collections.ArrayList
    Get-ChildItem $menuDir -Filter '*.md' -File | ForEach-Object { $m=Read-MenuDefinition $_.FullName; if ($null -ne $m) { [void]$result.Add($m) } }
    return @($result)
}
function Get-Menu([string]$moduleKey) { return @(Get-Menus | Where-Object { $_.module_key -eq $moduleKey })[0] }
function Get-ArticleMenus { return @(Get-Menus | Where-Object { $_.article_enabled } | Sort-Object top_order,label) }
function Select-One($items,[string]$title,[bool]$allowCancel=$true) {
    $arr=@($items); if ($arr.Count -eq 0) { return $null }
    Write-Host ''; Write-Host $title -ForegroundColor Yellow
    if ($allowCancel) { Write-Host '0. 返回/取消' }
    for($i=0;$i -lt $arr.Count;$i++){ Write-Host (('{0}. {1} [{2}]' -f ($i+1),$arr[$i].label,$arr[$i].key)) }
    $raw=Read-Host '请选择'; $n=0
    if (-not [int]::TryParse($raw,[ref]$n)) { throw '请输入有效数字。' }
    if ($allowCancel -and $n -eq 0) { return $null }
    if ($n -lt 1 -or $n -gt $arr.Count) { throw '选择超出范围。' }
    return $arr[$n-1]
}
function Find-FrontMatterEnd($lines) {
    $seen=$false
    for($i=0;$i -lt $lines.Count;$i++){
        if ($lines[$i] -match '^---\s*$') { if (-not $seen) { $seen=$true } else { return $i } }
    }
    throw '没有找到 YAML front matter 结束标记。'
}
function Save-Lines([string]$path,$lines) { Write-Utf8 $path ((@($lines) -join [Environment]::NewLine).TrimEnd()+[Environment]::NewLine) }

function Show-Tree([object]$menu) {
    Write-Host ''; Write-Host ($menu.label + ' [' + $menu.module_key + ']') -ForegroundColor Cyan
    foreach($item in @($menu.items)){
        Write-Host ('  - ' + $item.label + ' [' + $item.key + ']')
        foreach($child in @($item.children)){ Write-Host ('      - ' + $child.label + ' [' + $child.key + ']') }
    }
}

function Add-Level2([object]$menu) {
    $label=(Read-Host '二级分类中文名称').Trim(); if ([string]::IsNullOrWhiteSpace($label)) { throw '分类名称不能为空。' }
    $key=Require-Key '二级分类 key'
    if (@($menu.items | Where-Object { $_.key -eq $key -or $_.label -eq $label }).Count -gt 0) { throw '同名或同 key 的二级分类已经存在。' }
    $lines=New-Object System.Collections.ArrayList; [void]$lines.AddRange([string[]]((Read-Utf8 $menu.file) -split "`r?`n"))
    $end=Find-FrontMatterEnd $lines
    $new=@('','  - key: '+$key,'    label: '+$label)
    for($j=0;$j -lt $new.Count;$j++){ $lines.Insert($end+$j,$new[$j]) }
    Save-Lines $menu.file $lines
    Write-Host ('已新增二级分类：'+$label+' ['+$key+']') -ForegroundColor Green
}

function Add-Level3([object]$menu) {
    $parents=@($menu.items | Where-Object { $_.key -ne 'all' }); $parent=Select-One $parents '请选择要增加三级分类的二级分类'
    if ($null -eq $parent) { return }
    $label=(Read-Host '三级分类中文名称').Trim(); if ([string]::IsNullOrWhiteSpace($label)) { throw '分类名称不能为空。' }
    $key=Require-Key '三级分类 key'
    if (@($parent.children | Where-Object { $_.key -eq $key -or $_.label -eq $label }).Count -gt 0) { throw '同名或同 key 的三级分类已经存在。' }
    $lines=New-Object System.Collections.ArrayList; [void]$lines.AddRange([string[]]((Read-Utf8 $menu.file) -split "`r?`n"))
    $start=-1; for($i=0;$i -lt $lines.Count;$i++){ if($lines[$i] -match ('^  - key:\s*'+[regex]::Escape($parent.key)+'\s*$')){$start=$i;break} }
    if($start -lt 0){throw '没有找到对应二级分类。'}
    $fmEnd=Find-FrontMatterEnd $lines; $end=$fmEnd
    for($i=$start+1;$i -lt $fmEnd;$i++){ if($lines[$i] -match '^  - key:'){ $end=$i;break } }
    $childrenLine=-1; $slidesLine=-1
    for($i=$start+1;$i -lt $end;$i++){ if($lines[$i] -match '^    children:\s*$'){$childrenLine=$i}; if($lines[$i] -match '^    slides:\s*$' -and $slidesLine -lt 0){$slidesLine=$i} }
    if($childrenLine -lt 0){
        $labelLine=$start+1; for($i=$start+1;$i -lt $end;$i++){ if($lines[$i] -match '^    label:'){ $labelLine=$i;break } }
        $insert=$labelLine+1; $new=@('    children:','      - key: '+$key,'        label: '+$label)
    } else {
        $insert=if($slidesLine -ge 0){$slidesLine}else{$end}; $new=@('      - key: '+$key,'        label: '+$label)
    }
    for($j=0;$j -lt $new.Count;$j++){ $lines.Insert($insert+$j,$new[$j]) }
    Save-Lines $menu.file $lines
    Write-Host ('已新增三级分类：'+$parent.label+' → '+$label+' ['+$key+']') -ForegroundColor Green
}

function Get-PostRefs {
    $refs=New-Object System.Collections.ArrayList
    if(-not(Test-Path $postsDir)){return @()}
    Get-ChildItem $postsDir -Filter '*.md' -File | ForEach-Object {
        $text=Read-Utf8 $_.FullName; $module='project';$cat='';$sub=''
        if($text -match '(?m)^module:\s*([^\r\n]+)'){$module=$Matches[1].Trim()}
        if($text -match '(?m)^categories:\s*\[([^\]]+)\]'){$cat=($Matches[1].Split(',')[0]).Trim()}
        if($text -match '(?m)^subcategory:\s*([^\r\n]+)'){$sub=$Matches[1].Trim()}
        [void]$refs.Add([pscustomobject]@{file=$_.Name;module=$module;category=$cat;subcategory=$sub})
    }
    return @($refs)
}
function Confirm-Delete([string]$message){ $r=(Read-Host ($message+' 输入 YES 确认')).Trim(); return ($r -eq 'YES') }

function Remove-Level3([object]$menu) {
    $parent=Select-One @($menu.items|Where-Object{$_.children.Count -gt 0}) '请选择二级分类'; if($null -eq $parent){return}
    $child=Select-One @($parent.children) '请选择要删除的三级分类'; if($null -eq $child){return}
    $used=@(Get-PostRefs|Where-Object{$_.module -eq $menu.module_key -and $_.category -eq $parent.key -and $_.subcategory -eq $child.key})
    if($used.Count -gt 0 -and -not(Confirm-Delete("该三级分类被 $($used.Count) 篇文章使用。仍要删除分类配置吗？"))){return}
    $lines=New-Object System.Collections.ArrayList; [void]$lines.AddRange([string[]]((Read-Utf8 $menu.file)-split "`r?`n"))
    for($i=0;$i -lt $lines.Count;$i++){
        if($lines[$i] -match ('^      - key:\s*'+[regex]::Escape($child.key)+'\s*$')){ $lines.RemoveAt($i); if($i -lt $lines.Count -and $lines[$i] -match '^        label:'){$lines.RemoveAt($i)}; break }
    }
    Save-Lines $menu.file $lines; Write-Host '三级分类已删除。' -ForegroundColor Green
}
function Remove-Level2([object]$menu) {
    $item=Select-One @($menu.items|Where-Object{$_.key -ne 'all'}) '请选择要删除的二级分类'; if($null -eq $item){return}
    $used=@(Get-PostRefs|Where-Object{$_.module -eq $menu.module_key -and $_.category -eq $item.key})
    if($used.Count -gt 0 -and -not(Confirm-Delete("该二级分类被 $($used.Count) 篇文章使用。仍要删除分类配置吗？"))){return}
    $lines=New-Object System.Collections.ArrayList; [void]$lines.AddRange([string[]]((Read-Utf8 $menu.file)-split "`r?`n"))
    $start=-1;$end=-1;$fm=Find-FrontMatterEnd $lines
    for($i=0;$i -lt $fm;$i++){ if($lines[$i] -match ('^  - key:\s*'+[regex]::Escape($item.key)+'\s*$')){$start=$i;break} }
    if($start -lt 0){throw '找不到分类。'}; $end=$fm
    for($i=$start+1;$i -lt $fm;$i++){if($lines[$i]-match '^  - key:'){$end=$i;break}}
    for($i=$end-1;$i -ge $start;$i--){$lines.RemoveAt($i)}
    Save-Lines $menu.file $lines; Write-Host '二级分类已删除。' -ForegroundColor Green
}

function New-ArticleModule {
    $label=(Read-Host '一级大类中文名称').Trim(); if([string]::IsNullOrWhiteSpace($label)){throw '名称不能为空。'}
    $key=Require-Key '一级大类 key'
    $menus=Get-Menus
    if(@($menus|Where-Object{$_.module_key -eq $key -or $_.label -eq $label}).Count -gt 0){throw '同名或同 key 的一级大类已经存在。'}
    $menuFile=Join-Path $menuDir ($key+'.md'); $pageFile=Join-Path $root ($key+'.md')
    if(Test-Path $menuFile){throw '对应菜单文件已经存在。'}; if(Test-Path $pageFile){throw '对应页面文件已经存在。'}
    $orders=@($menus|Where-Object{$_.show_top}|ForEach-Object{$_.top_order}); $defaultOrder=if($orders.Count){([int](($orders|Measure-Object -Maximum).Maximum)+10)}else{10}
    $orderText=(Read-Host ("顶部排序数字（回车默认 $defaultOrder）")).Trim(); $order=$defaultOrder
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
    Write-Utf8 $menuFile ($menu.TrimStart()+[Environment]::NewLine); Write-Utf8 $pageFile ($page.TrimStart()+[Environment]::NewLine)
    Write-Host ''; Write-Host ('一级大类创建成功：'+$label+' ['+$key+']') -ForegroundColor Green
    Write-Host ('已创建：_menu_defs\'+$key+'.md')
    Write-Host ('已创建：'+$key+'.md → /'+$key+'/')
    Write-Host '新建博客文章.bat 下次启动会自动识别这个一级大类。' -ForegroundColor Green
}

function Remove-ArticleModule {
    $menu=Select-One @(Get-ArticleMenus|Where-Object{$_.module_key -ne 'project'}) '请选择要删除的一级文章大类'; if($null -eq $menu){return}
    $used=@(Get-PostRefs|Where-Object{$_.module -eq $menu.module_key})
    if($used.Count -gt 0 -and -not(Confirm-Delete("该一级大类被 $($used.Count) 篇文章使用。仍要删除分类配置和入口页面吗？"))){return}
    if($used.Count -eq 0 -and -not(Confirm-Delete('将删除一级分类配置和对应入口页面。'))){return}
    Remove-Item -LiteralPath $menu.file -Force
    $page=Join-Path $root ($menu.module_key+'.md'); if(Test-Path $page){Remove-Item -LiteralPath $page -Force}
    Write-Host '一级大类已删除（文章文件未删除）。' -ForegroundColor Green
}

function Manage-ArticleCategories {
    while($true){
        Clear-Host; Write-Host '=== 文章分类管理 ===' -ForegroundColor Cyan
        Write-Host '1. 查看当前文章分类';Write-Host '2. 新增一级文章大类';Write-Host '3. 新增二级分类';Write-Host '4. 新增三级分类';Write-Host '5. 删除一级大类';Write-Host '6. 删除二级分类';Write-Host '7. 删除三级分类';Write-Host '0. 返回'
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

function Select-Group([string]$moduleKey) {
    $menu=Get-Menu $moduleKey; if($null -eq $menu){throw ('找不到分类配置：'+$moduleKey)}
    $group=Select-One @($menu.items|Where-Object{$_.key -ne 'all'}) '请选择二级分类'; if($null -eq $group){return $null}
    $sub=$null; if($group.children.Count -gt 0){$sub=Select-One @($group.children) '请选择三级分类（0 = 不选）'}
    return [pscustomobject]@{menu=$menu;group=$group;sub=$sub}
}
function Manage-CollectionCategories([string]$moduleKey,[string]$title) {
    while($true){
        Clear-Host;Write-Host ('=== '+$title+'分类管理 ===') -ForegroundColor Cyan
        Write-Host '1. 查看分类';Write-Host '2. 新增二级分类';Write-Host '3. 新增三级分类';Write-Host '4. 删除二级分类';Write-Host '5. 删除三级分类';Write-Host '0. 返回'
        $c=Read-Host '请选择'; try{
            $menu=Get-Menu $moduleKey
            switch($c){'1'{Show-Tree $menu;Pause-Menu};'2'{Add-Level2 $menu;Pause-Menu};'3'{Add-Level3 $menu;Pause-Menu};'4'{Remove-Level2 $menu;Pause-Menu};'5'{Remove-Level3 $menu;Pause-Menu};'0'{return};default{Write-Host '无效选项。';Pause-Menu}}
        }catch{Write-Host ('错误：'+$_.Exception.Message) -ForegroundColor Red;Pause-Menu}
    }
}

function Select-LocalFile([string]$filter,[string]$title) {
    Add-Type -AssemblyName System.Windows.Forms
    $d=New-Object System.Windows.Forms.OpenFileDialog; $d.Filter=$filter; $d.Title=$title; $d.Multiselect=$false
    if($d.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK){return $null}; return $d.FileName
}
function Copy-Media([string]$source,[string]$relativeDir,[string]$prefix) {
    $dir=Join-Path $root $relativeDir; if(-not(Test-Path $dir)){New-Item -ItemType Directory -Path $dir -Force|Out-Null}
    $ext=[System.IO.Path]::GetExtension($source).ToLower(); $name=$prefix+'-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+(Get-Random -Minimum 1000 -Maximum 9999)+$ext
    $dest=Join-Path $dir $name; Copy-Item -LiteralPath $source -Destination $dest
    $rel=$dest.Substring($root.Length).Replace('\','/'); if(-not $rel.StartsWith('/')){$rel='/'+$rel}; return $rel
}

function Add-GalleryImage {
    $sel=Select-Group 'gallery'; if($null -eq $sel){return}; $file=Select-LocalFile '图片|*.jpg;*.jpeg;*.png;*.webp;*.gif|所有文件|*.*' '选择要加入图片收藏的图片'; if(-not $file){return}
    $subKey=if($sel.sub){$sel.sub.key}else{''}; $dir='assets\images\gallery\'+$sel.group.key; if($subKey){$dir+='\'+$subKey}
    $web=Copy-Media $file $dir 'img'; $title=(Read-Host '图片标题').Trim(); if(!$title){$title=[IO.Path]::GetFileNameWithoutExtension($file)}; $desc=(Read-Host '图片说明（可空）').Trim();$source=(Read-Host '来源网址（可空）').Trim()
    $block="- title: $(Yaml-Q $title)`n  image: $(Yaml-Q $web)`n  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $subKey`n"; if($source){$block+="  source: $(Yaml-Q $source)`n"};$block+="`n"
    Append-Utf8 (Join-Path $dataDir 'gallery.yml') $block; Write-Host ('图片已复制并登记：'+$web) -ForegroundColor Green
}
function Manage-Gallery {
    while($true){Clear-Host;Write-Host '=== 图片收藏管理 ===' -ForegroundColor Cyan;Write-Host '1. 图片分类管理';Write-Host '2. 新增本地图片';Write-Host '0. 返回';$c=Read-Host '请选择';try{switch($c){'1'{Manage-CollectionCategories 'gallery' '图片'};'2'{Add-GalleryImage;Pause-Menu};'0'{return};default{Write-Host '无效选项';Pause-Menu}}}catch{Write-Host ('错误：'+$_.Exception.Message) -ForegroundColor Red;Pause-Menu}}
}

function Add-LocalVideo {
    $sel=Select-Group 'videos';if($null -eq $sel){return};$file=Select-LocalFile '视频|*.mp4;*.webm;*.ogg;*.m4v|所有文件|*.*' '选择本地视频';if(-not$file){return}
    $web=Copy-Media $file 'assets\videos' 'video';$title=(Read-Host '视频标题').Trim();if(!$title){$title=[IO.Path]::GetFileNameWithoutExtension($file)};$desc=(Read-Host '视频说明（可空）').Trim();$sub=if($sel.sub){$sel.sub.key}else{''}
    $block="- title: $(Yaml-Q $title)`n  platform: local`n  video: $(Yaml-Q $web)`n  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $sub`n`n";Append-Utf8 (Join-Path $dataDir 'videos.yml') $block;Write-Host ('本地视频已复制并登记：'+$web) -ForegroundColor Green
}
function Add-BilibiliVideo {
    $sel=Select-Group 'videos';if($null -eq $sel){return};$url=(Read-Host 'B站视频地址或 BV 号').Trim();if($url -notmatch '(BV[0-9A-Za-z]+)'){throw '没有识别到 BV 号。'};$bvid=$Matches[1];if($url -notmatch '^https?://'){$url='https://www.bilibili.com/video/'+$bvid+'/'}
    $title=(Read-Host '视频标题').Trim();if(!$title){throw '标题不能为空。'};$desc=(Read-Host '视频说明（可空）').Trim();$cover=(Read-Host '封面图片网址（可空）').Trim();$sub=if($sel.sub){$sel.sub.key}else{''}
    $block="- title: $(Yaml-Q $title)`n  platform: bilibili`n  bvid: $bvid`n  url: $(Yaml-Q $url)`n";if($cover){$block+="  cover: $(Yaml-Q $cover)`n"};$block+="  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $sub`n`n";Append-Utf8 (Join-Path $dataDir 'videos.yml') $block;Write-Host 'B站视频已登记。' -ForegroundColor Green
}
function Add-ExternalVideo {
    $sel=Select-Group 'videos';if($null -eq $sel){return};$url=(Read-Host '在线视频/网页地址').Trim();if($url -notmatch '^https?://'){throw '请输入 http/https 地址。'};$title=(Read-Host '视频标题').Trim();if(!$title){throw '标题不能为空。'};$desc=(Read-Host '视频说明（可空）').Trim();$sub=if($sel.sub){$sel.sub.key}else{''};$platform=(Read-Host '平台名称（可空）').Trim();if(!$platform){$platform='external'}
    $block="- title: $(Yaml-Q $title)`n  platform: $(Yaml-Q $platform)`n  url: $(Yaml-Q $url)`n";if($url -match '\.(mp4|webm|ogg)(\?|$)'){$block+="  video: $(Yaml-Q $url)`n"};$block+="  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $sub`n`n";Append-Utf8 (Join-Path $dataDir 'videos.yml') $block;Write-Host '在线视频已登记。' -ForegroundColor Green
}
function Manage-Videos {
    while($true){Clear-Host;Write-Host '=== 视频收藏管理 ===' -ForegroundColor Cyan;Write-Host '1. 视频分类管理';Write-Host '2. 新增本地视频';Write-Host '3. 新增B站视频';Write-Host '4. 新增其他在线视频';Write-Host '0. 返回';$c=Read-Host '请选择';try{switch($c){'1'{Manage-CollectionCategories 'videos' '视频'};'2'{Add-LocalVideo;Pause-Menu};'3'{Add-BilibiliVideo;Pause-Menu};'4'{Add-ExternalVideo;Pause-Menu};'0'{return};default{Write-Host '无效选项';Pause-Menu}}}catch{Write-Host ('错误：'+$_.Exception.Message)-ForegroundColor Red;Pause-Menu}}
}

function Add-LocalMusic {
    $sel=Select-Group 'music';if($null -eq $sel){return};$file=Select-LocalFile '音频|*.mp3;*.m4a;*.ogg;*.wav;*.flac|所有文件|*.*' '选择你有权公开使用的本地音频';if(-not$file){return};$web=Copy-Media $file 'assets\audio' 'audio';$title=(Read-Host '歌曲标题').Trim();if(!$title){$title=[IO.Path]::GetFileNameWithoutExtension($file)};$artist=(Read-Host '歌手/作者（可空）').Trim();$desc=(Read-Host '说明（可空）').Trim();$sub=if($sel.sub){$sel.sub.key}else{''};$cat=$sel.group.label;if($sel.sub){$cat+=' / '+$sel.sub.label}
    $block="- title: $(Yaml-Q $title)`n  artist: $(Yaml-Q $artist)`n  category: $(Yaml-Q $cat)`n  group: $($sel.group.key)`n  subgroup: $sub`n  description: $(Yaml-Q $desc)`n  file: $(Yaml-Q $web)`n  platform: 本地音频`n`n";Append-Utf8 (Join-Path $dataDir 'music.yml') $block;Write-Host ('本地音频已复制并登记：'+$web) -ForegroundColor Green
}
function Add-OnlineMusic {
    $sel=Select-Group 'music';if($null -eq $sel){return};$title=(Read-Host '歌曲标题').Trim();if(!$title){throw '标题不能为空。'};$artist=(Read-Host '歌手/作者').Trim();$url=(Read-Host '正版平台地址').Trim();if($url -notmatch '^https?://'){throw '请输入 http/https 地址。'};$platform=(Read-Host '平台名称').Trim();$desc=(Read-Host '说明（可空）').Trim();$sub=if($sel.sub){$sel.sub.key}else{''};$cat=$sel.group.label;if($sel.sub){$cat+=' / '+$sel.sub.label}
    $block="- title: $(Yaml-Q $title)`n  artist: $(Yaml-Q $artist)`n  category: $(Yaml-Q $cat)`n  group: $($sel.group.key)`n  subgroup: $sub`n  description: $(Yaml-Q $desc)`n  url: $(Yaml-Q $url)`n  platform: $(Yaml-Q $platform)`n`n";Append-Utf8 (Join-Path $dataDir 'music.yml') $block;Write-Host '在线歌曲已登记。' -ForegroundColor Green
}
function Manage-Music {
    while($true){Clear-Host;Write-Host '=== 歌曲管理 ===' -ForegroundColor Cyan;Write-Host '1. 歌曲分类管理';Write-Host '2. 新增本地音乐';Write-Host '3. 新增在线歌曲';Write-Host '0. 返回';$c=Read-Host '请选择';try{switch($c){'1'{Manage-CollectionCategories 'music' '歌曲'};'2'{Add-LocalMusic;Pause-Menu};'3'{Add-OnlineMusic;Pause-Menu};'0'{return};default{Write-Host '无效选项';Pause-Menu}}}catch{Write-Host ('错误：'+$_.Exception.Message)-ForegroundColor Red;Pause-Menu}}
}

function Add-SiteLink {
    $sel=Select-Group 'nav';if($null -eq $sel){return};$title=(Read-Host '网站名称').Trim();if(!$title){throw '网站名称不能为空。'};$url=(Read-Host '网址').Trim();if($url -notmatch '^https?://'){throw '请输入 http/https 地址。'};$desc=(Read-Host '网站说明（可空）').Trim();$sub=if($sel.sub){$sel.sub.key}else{''}
    $block="- title: $(Yaml-Q $title)`n  url: $(Yaml-Q $url)`n  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $sub`n`n";Append-Utf8 (Join-Path $dataDir 'site_links.yml') $block;Write-Host '网址已登记。' -ForegroundColor Green
}
function Manage-Links {
    while($true){Clear-Host;Write-Host '=== 网址导航管理 ===' -ForegroundColor Cyan;Write-Host '1. 网址分类管理';Write-Host '2. 新增网址';Write-Host '0. 返回';$c=Read-Host '请选择';try{switch($c){'1'{Manage-CollectionCategories 'nav' '网址'};'2'{Add-SiteLink;Pause-Menu};'0'{return};default{Write-Host '无效选项';Pause-Menu}}}catch{Write-Host ('错误：'+$_.Exception.Message)-ForegroundColor Red;Pause-Menu}}
}

function Test-Config {
    $errors=New-Object System.Collections.ArrayList;$warnings=New-Object System.Collections.ArrayList
    try{$menus=Get-Menus}catch{[void]$errors.Add($_.Exception.Message);$menus=@()}
    $moduleKeys=@{};foreach($m in $menus){if($moduleKeys.ContainsKey($m.module_key)){[void]$errors.Add('重复 module_key: '+$m.module_key)}else{$moduleKeys[$m.module_key]=$true};$keys=@{};foreach($it in @($m.items)){if($keys.ContainsKey($it.key)){[void]$errors.Add($m.module_key+' 重复二级 key: '+$it.key)}else{$keys[$it.key]=$true};$ck=@{};foreach($ch in @($it.children)){if($ck.ContainsKey($ch.key)){[void]$errors.Add($m.module_key+'/'+$it.key+' 重复三级 key: '+$ch.key)}else{$ck[$ch.key]=$true}}};if($m.article_enabled){$page=Join-Path $root ($m.module_key+'.md');if($m.module_key -ne 'project' -and -not(Test-Path $page)){[void]$errors.Add('一级文章大类缺少入口页面: '+$m.module_key+'.md')}}}
    foreach($p in Get-PostRefs){$m=@($menus|Where-Object{$_.module_key -eq $p.module});if($m.Count -eq 0){[void]$errors.Add($p.file+' 的 module 不存在: '+$p.module);continue};if($p.category){$it=@($m[0].items|Where-Object{$_.key -eq $p.category});if($it.Count -eq 0){[void]$warnings.Add($p.file+' 的二级分类不存在: '+$p.category)}elseif($p.subcategory -and @($it[0].children|Where-Object{$_.key -eq $p.subcategory}).Count -eq 0){[void]$warnings.Add($p.file+' 的三级分类不存在: '+$p.subcategory)}}}
    foreach($pair in @(@('gallery.yml','image'),@('music.yml','file'),@('videos.yml','video'))){$path=Join-Path $dataDir $pair[0];if(Test-Path $path){foreach($line in (Read-Utf8 $path)-split "`r?`n"){if($line -match ('^\s*'+$pair[1]+':\s*["'']?(/[^"'']+)["'']?\s*$')){$web=$Matches[1];if($web -notmatch '^//'){ $local=Join-Path $root ($web.TrimStart('/').Replace('/','\'));if(-not(Test-Path $local)){[void]$warnings.Add($pair[0]+' 本地文件不存在: '+$web)}}}}}}
    Clear-Host;Write-Host '=== 配置检查结果 ===' -ForegroundColor Cyan
    if($errors.Count -eq 0){Write-Host '错误：0' -ForegroundColor Green}else{Write-Host ('错误：'+$errors.Count) -ForegroundColor Red;$errors|ForEach-Object{Write-Host ('  - '+$_) -ForegroundColor Red}}
    if($warnings.Count -eq 0){Write-Host '警告：0' -ForegroundColor Green}else{Write-Host ('警告：'+$warnings.Count) -ForegroundColor Yellow;$warnings|ForEach-Object{Write-Host ('  - '+$_) -ForegroundColor Yellow}}
    Write-Host '';if($errors.Count -eq 0){Write-Host '核心配置检查通过。' -ForegroundColor Green}else{Write-Host '请先修复错误再发布。' -ForegroundColor Red};Pause-Menu
}

function Show-MainMenu {
    Clear-Host;Write-Host '========================================' -ForegroundColor Cyan;Write-Host ' 九月影博客 - 网站内容管理' -ForegroundColor Cyan;Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '1. 文章分类管理';Write-Host '2. 图片收藏管理';Write-Host '3. 视频收藏管理';Write-Host '4. 歌曲管理';Write-Host '5. 网址导航管理';Write-Host '6. 配置检查';Write-Host '0. 退出'
}

while($true){
    Show-MainMenu;$choice=Read-Host '请选择'
    switch($choice){'1'{Manage-ArticleCategories};'2'{Manage-Gallery};'3'{Manage-Videos};'4'{Manage-Music};'5'{Manage-Links};'6'{Test-Config};'0'{exit 0};default{Write-Host '无效选项。';Pause-Menu}}
}
