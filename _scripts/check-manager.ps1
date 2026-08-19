function Test-BlogConfiguration {
    $errors=New-Object System.Collections.ArrayList
    $warnings=New-Object System.Collections.ArrayList

    try{$menus=Get-Menus}catch{[void]$errors.Add($_.Exception.Message);$menus=@()}

    $moduleKeys=@{}
    foreach($m in $menus){
        if($moduleKeys.ContainsKey($m.module_key)){[void]$errors.Add('重复 module_key: '+$m.module_key)}else{$moduleKeys[$m.module_key]=$true}

        $keys=@{}
        foreach($it in @($m.items)){
            if($keys.ContainsKey($it.key)){[void]$errors.Add($m.module_key+' 重复二级 key: '+$it.key)}else{$keys[$it.key]=$true}
            $childKeys=@{}
            foreach($ch in @($it.children)){
                if($childKeys.ContainsKey($ch.key)){[void]$errors.Add($m.module_key+'/'+$it.key+' 重复三级 key: '+$ch.key)}else{$childKeys[$ch.key]=$true}
            }
        }

        if($m.article_enabled){
            if($m.module_key -ne 'project'){
                $page=Join-Path $script:BlogRoot ($m.module_key+'.md')
                if(-not(Test-Path $page)){[void]$errors.Add('一级文章大类缺少入口页面: '+$m.module_key+'.md')}
            }
        }
    }

    foreach($p in Get-PostRefs){
        $m=@($menus|Where-Object{$_.module_key -eq $p.module})
        if($m.Count -eq 0){[void]$errors.Add($p.file+' 的 module 不存在: '+$p.module);continue}
        if($p.category){
            $it=@($m[0].items|Where-Object{$_.key -eq $p.category})
            if($it.Count -eq 0){[void]$warnings.Add($p.file+' 的二级分类不存在: '+$p.category)}
            elseif($p.subcategory -and @($it[0].children|Where-Object{$_.key -eq $p.subcategory}).Count -eq 0){[void]$warnings.Add($p.file+' 的三级分类不存在: '+$p.subcategory)}
        }
    }

    $defs=Get-CollectionDefs
    foreach($d in $defs){
        $pageKey=$d.key
        $page=Join-Path $script:BlogRoot ($pageKey+'.md')
        if(-not(Test-Path $page)){[void]$warnings.Add('收藏模块缺少入口页面: '+$pageKey+'.md')}
        if($d.managed){
            $menu=Join-Path $script:MenuDir ($pageKey+'.md')
            if(-not(Test-Path $menu)){[void]$errors.Add('自建收藏模块缺少分类配置: _menu_defs/'+$pageKey+'.md')}
            $data=Join-Path $script:DataDir ($pageKey+'.yml')
            if(-not(Test-Path $data)){[void]$errors.Add('自建收藏模块缺少数据文件: _data/'+$pageKey+'.yml')}
        }
    }

    foreach($pair in @(@('gallery.yml','image'),@('music.yml','file'),@('videos.yml','video'))){
        $path=Join-Path $script:DataDir $pair[0]
        if(Test-Path $path){
            foreach($line in (Read-Utf8 $path)-split "`r?`n"){
                if($line -match ('^\s*'+$pair[1]+':\s*["'']?(/[^"'']+)["'']?\s*$')){
                    $web=$Matches[1]
                    $local=Join-Path $script:BlogRoot ($web.TrimStart('/').Replace('/','\'))
                    if(-not(Test-Path $local)){[void]$warnings.Add($pair[0]+' 本地文件不存在: '+$web)}
                }
            }
        }
    }

    foreach($file in Get-ChildItem $script:BlogRoot -Recurse -File -ErrorAction SilentlyContinue){
        if($file.Length -gt 90MB -and $file.FullName -notmatch '\\.git\\'){
            [void]$warnings.Add(('大文件超过90MB: '+$file.FullName.Substring($script:BlogRoot.Length+1)))
        }
    }

    Clear-Host
    Write-Host '=== 配置检查结果 ===' -ForegroundColor Cyan
    if($errors.Count -eq 0){Write-Host '错误：0' -ForegroundColor Green}else{Write-Host ('错误：'+$errors.Count) -ForegroundColor Red;$errors|ForEach-Object{Write-Host ('  - '+$_)-ForegroundColor Red}}
    if($warnings.Count -eq 0){Write-Host '警告：0' -ForegroundColor Green}else{Write-Host ('警告：'+$warnings.Count) -ForegroundColor Yellow;$warnings|ForEach-Object{Write-Host ('  - '+$_)-ForegroundColor Yellow}}
    Write-Host ''
    if($errors.Count -eq 0){Write-Host '核心配置检查通过。' -ForegroundColor Green}else{Write-Host '请先修复错误再发布。' -ForegroundColor Red}
    Pause-Menu
}
