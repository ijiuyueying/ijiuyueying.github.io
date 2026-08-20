function Test-GitStatus {
    try{
        $branch=(git branch --show-current 2>$null)
        $status=@(git status --porcelain 2>$null)
        if($branch -ne 'main'){
            return '当前Git分支不是main: '+$branch
        }
        if($status.Count -gt 0){
            return '存在未提交修改: '+$status.Count+' 个文件'
        }
        return 'Git状态正常'
    }catch{
        return 'Git检查失败: '+$_.Exception.Message
    }
}

function Test-Encoding {
    $bad=@()
    foreach($file in Get-ChildItem $script:BlogRoot -Recurse -Include *.md,*.yml,*.yaml -File -ErrorAction SilentlyContinue){
        try{
            $bytes=[System.IO.File]::ReadAllBytes($file.FullName)
            $text=[System.Text.Encoding]::UTF8.GetString($bytes)
            if($text -match '�'){
                [void]$bad.Add($file.FullName.Substring($script:BlogRoot.Length+1))
            }
        }catch{}
    }
    return $bad
}

function Test-OrphanPosts {
    $result=@()
    $menus=Get-Menus
    foreach($p in Get-PostRefs){
        $m=@($menus|Where-Object{$_.module_key -eq $p.module})
        if($m.Count -eq 0){$result+=$p.file+' module不存在';continue}
        $cat=@($m[0].items|Where-Object{$_.key -eq $p.category})
        if($cat.Count -eq 0){$result+=$p.file+' 分类不存在: '+$p.category}
    }
    return $result
}

function Test-AssetReferences {
    $missing=@()
    foreach($file in Get-ChildItem $script:BlogRoot -Recurse -Include *.md,*.yml,*.yaml -File -ErrorAction SilentlyContinue){
        foreach($line in Get-Content $file.FullName -Encoding UTF8){
            if($line -match '(\/assets\/[^\s"'']+)'){
                $path=Join-Path $script:BlogRoot ($Matches[1].TrimStart('/').Replace('/','\'))
                if(-not(Test-Path $path)){$missing+=$file.Name+' -> '+$Matches[1]}
            }
        }
    }
    return $missing
}

function Test-BlogConfiguration {
    $errors=@()
    $warnings=@()

    try{$menus=Get-Menus}catch{$errors+='分类配置读取失败: '+$_.Exception.Message;$menus=@()}

    $modules=@{}
    foreach($m in $menus){
        if($modules.ContainsKey($m.module_key)){$errors+='重复module_key: '+$m.module_key}else{$modules[$m.module_key]=$true}
        $keys=@{}
        foreach($item in @($m.items)){
            if($keys.ContainsKey($item.key)){$errors+=$m.module_key+'重复二级key: '+$item.key}else{$keys[$item.key]=$true}
            $children=@{}
            foreach($c in @($item.children)){
                if($children.ContainsKey($c.key)){$errors+=$m.module_key+'/'+$item.key+'重复三级key: '+$c.key}else{$children[$c.key]=$true}
            }
        }
    }

    foreach($x in Test-OrphanPosts){$warnings+=$x}
    foreach($x in Test-AssetReferences){$warnings+='资源缺失: '+$x}
    foreach($x in Test-Encoding){$warnings+='疑似编码异常: '+$x}

    $git=Test-GitStatus

    foreach($file in Get-ChildItem $script:BlogRoot -Recurse -File -ErrorAction SilentlyContinue){
        if($file.Length -gt 90MB -and $file.FullName -notmatch '\\.git\\'){
            $warnings+='大文件超过90MB: '+$file.Name
        }
    }

    Clear-Host
    Write-Host '=== 网站健康检查 ===' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '【分类检查】'
    Write-Host ('错误数量: '+$errors.Count)
    $errors|ForEach-Object{Write-Host (' - '+$_) -ForegroundColor Red}

    Write-Host ''
    Write-Host '【内容/资源检查】'
    Write-Host ('警告数量: '+$warnings.Count)
    $warnings|ForEach-Object{Write-Host (' - '+$_) -ForegroundColor Yellow}

    Write-Host ''
    Write-Host '【Git检查】'
    Write-Host $git

    Write-Host ''
    if($errors.Count -eq 0){Write-Host '核心检查通过，可以发布。' -ForegroundColor Green}else{Write-Host '存在错误，请修复后发布。' -ForegroundColor Red}
    Pause-Menu
}
