function Select-Many($Items,[string]$Title) {
    $arr=@($Items)
    if($arr.Count -eq 0){return @()}

    Write-Host ''
    Write-Host $Title -ForegroundColor Yellow
    Write-Host '0. 返回/取消'
    for($i=0;$i -lt $arr.Count;$i++){
        $name=Get-ObjectField $arr[$i] 'label'
        if([string]::IsNullOrWhiteSpace([string]$name)){$name=Get-ObjectField $arr[$i] 'title'}
        if([string]::IsNullOrWhiteSpace([string]$name)){$name=[string]$arr[$i]}
        $key=Get-ObjectField $arr[$i] 'key'
        if([string]::IsNullOrWhiteSpace([string]$key)){$key=Get-ObjectField $arr[$i] 'module_key'}
        if($null -eq $key){$key=''}
        Write-Host (('{0}. {1} [{2}]' -f ($i+1),$name,$key))
    }

    Write-Host ''
    Write-Host '支持多选：例如 1,3,5（也支持中文逗号）' -ForegroundColor DarkGray
    $raw=(Read-Host '请选择').Trim().Replace('，',',')
    if([string]::IsNullOrWhiteSpace($raw) -or $raw -eq '0'){return @()}

    $selected=New-Object System.Collections.ArrayList
    $seen=New-Object 'System.Collections.Generic.HashSet[int]'
    foreach($token in ($raw -split '[,\s]+')){
        if([string]::IsNullOrWhiteSpace($token)){continue}
        $n=0
        if(-not[int]::TryParse($token,[ref]$n)){throw ('无效编号：'+$token)}
        if($n -eq 0){throw '0 只能单独用于取消。'}
        if($n -lt 1 -or $n -gt $arr.Count){throw ('编号超出范围：'+$n)}
        if($seen.Add($n)){[void]$selected.Add($arr[$n-1])}
    }
    return @($selected)
}

function Get-CategoryUseCount([object]$Menu,[string]$Group,[string]$Subgroup=''){
    if($Menu.article_enabled){
        if([string]::IsNullOrWhiteSpace($Subgroup)){
            return @(Get-PostRefs|Where-Object{$_.module -eq $Menu.module_key -and $_.category -eq $Group}).Count
        }
        return @(Get-PostRefs|Where-Object{$_.module -eq $Menu.module_key -and $_.category -eq $Group -and $_.subcategory -eq $Subgroup}).Count
    }
    return Count-DataRefs $Menu.module_key $Group $Subgroup
}

function Test-ChildKeyExists([object]$Menu,[string]$Key){
    foreach($item in @($Menu.items)){
        foreach($child in @($item.children)){
            if($child.key -eq $Key){return $true}
        }
    }
    return $false
}

function Test-Level2KeyExists([object]$Menu,[string]$Key){
    return (@($Menu.items|Where-Object{$_.key -eq $Key}).Count -gt 0)
}

function Test-ChildUnderParent([object]$Menu,[string]$ParentKey,[string]$ChildKey){
    $parent=@($Menu.items|Where-Object{$_.key -eq $ParentKey})
    if($parent.Count -eq 0){return $false}
    return (@($parent[0].children|Where-Object{$_.key -eq $ChildKey}).Count -gt 0)
}

function Confirm-AdoptExistingRefs([object]$Menu,[string]$Group,[string]$Subgroup=''){
    $used=Get-CategoryUseCount $Menu $Group $Subgroup
    if($used -le 0){return $true}
    if([string]::IsNullOrWhiteSpace($Subgroup)){
        $msg="发现 $used 条已有文章/内容已经引用 key [$Group]，但当前分类配置里没有它。新增后这些内容会自动归入该分类。"
    }else{
        $msg="发现 $used 条已有文章/内容已经引用 [$Group → $Subgroup]，但当前分类配置里没有它。新增后这些内容会自动归入该分类。"
    }
    return Confirm-Delete $msg
}

function Add-Level2([object]$Menu) {
    $label=(Read-Host '二级分类名称').Trim()
    if([string]::IsNullOrWhiteSpace($label)){throw '分类名称不能为空。'}
    $key=Require-Key '二级分类 key'

    if(@($Menu.items|Where-Object{$_.key -eq $key -or $_.label -eq $label}).Count -gt 0){throw '同名或同 key 的二级分类已经存在。'}
    if(Test-ChildKeyExists $Menu $key){throw ('key ['+$key+'] 已经被三级分类使用。为避免文章引用歧义，请换一个 key。')}
    if(-not(Confirm-AdoptExistingRefs $Menu $key)){return}

    $lines=New-Object System.Collections.ArrayList
    [void]$lines.AddRange([string[]]((Read-Utf8 $Menu.file)-split "`r?`n"))
    $end=Find-FrontMatterEnd $lines
    $new=@('',('  - key: '+$key),('    label: '+$label))
    for($j=0;$j -lt $new.Count;$j++){$lines.Insert($end+$j,$new[$j])}
    Save-Lines $Menu.file $lines
    Write-Host ('已新增二级分类：'+$label+' ['+$key+']') -ForegroundColor Green
}

function Add-Level3([object]$Menu) {
    $parents=@($Menu.items|Where-Object{$_.key -ne 'all'})
    $parent=Select-One $parents '请选择要增加三级分类的二级分类'
    if($null -eq $parent){return}

    $label=(Read-Host '三级分类名称').Trim()
    if([string]::IsNullOrWhiteSpace($label)){throw '分类名称不能为空。'}
    $key=Require-Key '三级分类 key'

    if(Test-Level2KeyExists $Menu $key){throw ('key ['+$key+'] 已经被二级分类使用。为避免文章引用歧义，请换一个 key。')}
    if(Test-ChildKeyExists $Menu $key){throw ('key ['+$key+'] 已经被其他三级分类使用。三级 key 在同一模块内必须唯一。')}
    if(@($parent.children|Where-Object{$_.label -eq $label}).Count -gt 0){throw '当前二级分类下已经存在同名三级分类。'}
    if(-not(Confirm-AdoptExistingRefs $Menu $parent.key $key)){return}

    $lines=New-Object System.Collections.ArrayList
    [void]$lines.AddRange([string[]]((Read-Utf8 $Menu.file)-split "`r?`n"))
    $start=-1
    for($i=0;$i -lt $lines.Count;$i++){
        if($lines[$i] -match ('^  - key:\s*'+[regex]::Escape($parent.key)+'\s*$')){$start=$i;break}
    }
    if($start -lt 0){throw '没有找到对应二级分类。'}

    $fmEnd=Find-FrontMatterEnd $lines
    $end=$fmEnd
    for($i=$start+1;$i -lt $fmEnd;$i++){
        if($lines[$i] -match '^  - key:'){$end=$i;break}
    }

    $childrenLine=-1
    $slidesLine=-1
    for($i=$start+1;$i -lt $end;$i++){
        if($lines[$i] -match '^    children:\s*$'){$childrenLine=$i}
        if($lines[$i] -match '^    slides:\s*$' -and $slidesLine -lt 0){$slidesLine=$i}
    }

    if($childrenLine -lt 0){
        $labelLine=$start+1
        for($i=$start+1;$i -lt $end;$i++){
            if($lines[$i] -match '^    label:'){$labelLine=$i;break}
        }
        $insert=$labelLine+1
        $new=@('    children:',('      - key: '+$key),('        label: '+$label))
    }else{
        if($slidesLine -ge 0){$insert=$slidesLine}else{$insert=$end}
        $new=@(('      - key: '+$key),('        label: '+$label))
    }

    for($j=0;$j -lt $new.Count;$j++){$lines.Insert($insert+$j,$new[$j])}
    Save-Lines $Menu.file $lines
    Write-Host ('已新增三级分类：'+$parent.label+' → '+$label+' ['+$key+']') -ForegroundColor Green
}

function Remove-Level2([object]$Menu){
    $candidates=@($Menu.items|Where-Object{$_.key -ne 'all'})
    $selected=@(Select-Many $candidates '请选择要删除的二级分类')
    if($selected.Count -eq 0){return}

    $totalUsed=0
    $totalChildren=0
    Write-Host ''
    Write-Host '准备删除：' -ForegroundColor Yellow
    foreach($item in $selected){
        $used=Get-CategoryUseCount $Menu $item.key
        $childCount=@($item.children).Count
        $totalUsed+=$used
        $totalChildren+=$childCount
        Write-Host ('  - '+$item.label+' ['+$item.key+']  关联内容：'+$used+'  三级分类：'+$childCount)
    }

    if($selected.Count -gt 1 -or $totalUsed -gt 0 -or $totalChildren -gt 0){
        $message='将删除 '+$selected.Count+' 个二级分类'
        if($totalChildren -gt 0){$message+='，同时移除其中 '+$totalChildren+' 个三级分类配置'}
        if($totalUsed -gt 0){$message+='；仍有 '+$totalUsed+' 条文章/内容引用这些分类，内容文件不会被删除'}
        if(-not(Confirm-Delete($message+'。'))){return}
    }

    $lines=New-Object System.Collections.ArrayList
    [void]$lines.AddRange([string[]]((Read-Utf8 $Menu.file)-split "`r?`n"))
    foreach($item in $selected){
        $fm=Find-FrontMatterEnd $lines
        $start=-1
        $end=$fm
        for($i=0;$i -lt $fm;$i++){
            if($lines[$i] -match ('^  - key:\s*'+[regex]::Escape($item.key)+'\s*$')){$start=$i;break}
        }
        if($start -lt 0){continue}
        for($i=$start+1;$i -lt $fm;$i++){
            if($lines[$i] -match '^  - key:'){$end=$i;break}
        }
        for($i=$end-1;$i -ge $start;$i--){$lines.RemoveAt($i)}
    }
    Save-Lines $Menu.file $lines
    Write-Host ('已删除 '+$selected.Count+' 个二级分类。') -ForegroundColor Green
}

function Remove-Level3([object]$Menu){
    $parents=@($Menu.items|Where-Object{@($_.children).Count -gt 0})
    $parent=Select-One $parents '请选择三级分类所属的二级分类'
    if($null -eq $parent){return}

    $selected=@(Select-Many @($parent.children) ('请选择要删除的三级分类：'+$parent.label))
    if($selected.Count -eq 0){return}

    $totalUsed=0
    Write-Host ''
    Write-Host '准备删除：' -ForegroundColor Yellow
    foreach($child in $selected){
        $used=Get-CategoryUseCount $Menu $parent.key $child.key
        $totalUsed+=$used
        Write-Host ('  - '+$parent.label+' → '+$child.label+' ['+$child.key+']  关联内容：'+$used)
    }

    if($selected.Count -gt 1 -or $totalUsed -gt 0){
        $message='将删除 '+$selected.Count+' 个三级分类'
        if($totalUsed -gt 0){$message+='；仍有 '+$totalUsed+' 条文章/内容引用这些分类，内容文件不会被删除'}
        if(-not(Confirm-Delete($message+'。'))){return}
    }

    $lines=New-Object System.Collections.ArrayList
    [void]$lines.AddRange([string[]]((Read-Utf8 $Menu.file)-split "`r?`n"))
    foreach($child in $selected){
        for($i=0;$i -lt $lines.Count;$i++){
            if($lines[$i] -match ('^      - key:\s*'+[regex]::Escape($child.key)+'\s*$')){
                $lines.RemoveAt($i)
                if($i -lt $lines.Count -and $lines[$i] -match '^        label:'){$lines.RemoveAt($i)}
                break
            }
        }
    }

    if($selected.Count -eq @($parent.children).Count){
        $fm=Find-FrontMatterEnd $lines
        $parentStart=-1
        $parentEnd=$fm
        for($i=0;$i -lt $fm;$i++){
            if($lines[$i] -match ('^  - key:\s*'+[regex]::Escape($parent.key)+'\s*$')){$parentStart=$i;break}
        }
        if($parentStart -ge 0){
            for($i=$parentStart+1;$i -lt $fm;$i++){
                if($lines[$i] -match '^  - key:'){$parentEnd=$i;break}
            }
            for($i=$parentStart+1;$i -lt $parentEnd;$i++){
                if($lines[$i] -match '^    children:\s*$'){$lines.RemoveAt($i);break}
            }
        }
    }

    Save-Lines $Menu.file $lines
    Write-Host ('已删除 '+$selected.Count+' 个三级分类。') -ForegroundColor Green
}

function Set-PostCategory([string]$FilePath,[string]$ModuleKey,[string]$Group,[string]$Subgroup=''){
    $text=Read-Utf8 $FilePath
    if($text -match '(?m)^module:\s*.*$'){
        $text=[regex]::Replace($text,'(?m)^module:\s*.*$',('module: '+$ModuleKey),1)
    }
    if($text -match '(?m)^categories:\s*.*$'){
        $text=[regex]::Replace($text,'(?m)^categories:\s*.*$',('categories: ['+$Group+']'),1)
    }else{
        $text=[regex]::Replace($text,'(?m)^(module:\s*.*)$',('$1'+[Environment]::NewLine+'categories: ['+$Group+']'),1)
    }

    if([string]::IsNullOrWhiteSpace($Subgroup)){
        $text=[regex]::Replace($text,'(?m)^subcategory:\s*.*\r?\n?','',1)
    }elseif($text -match '(?m)^subcategory:\s*.*$'){
        $text=[regex]::Replace($text,'(?m)^subcategory:\s*.*$',('subcategory: '+$Subgroup),1)
    }else{
        $text=[regex]::Replace($text,'(?m)^(categories:\s*.*)$',('$1'+[Environment]::NewLine+'subcategory: '+$Subgroup),1)
    }
    Write-Utf8 $FilePath $text
}

function Get-BlockField([string]$Block,[string]$Field){
    $pattern='(?m)^\s*'+[regex]::Escape($Field)+':\s*(.*?)\s*$'
    if($Block -match $pattern){return $Matches[1].Trim().Trim('"').Trim("'")}
    return ''
}

function Set-BlockField([string]$Block,[string]$Field,[string]$Value){
    $pattern='(?m)^(\s*'+[regex]::Escape($Field)+':\s*).*$'
    $re=New-Object System.Text.RegularExpressions.Regex($pattern)
    if($re.IsMatch($Block)){
        return $re.Replace($Block,('${1}'+$Value),1)
    }
    $groupPattern='(?m)^(\s*group:\s*.*)$'
    if($Field -eq 'subgroup' -and $Block -match $groupPattern){
        return [regex]::Replace($Block,$groupPattern,('$1'+[Environment]::NewLine+'  subgroup: '+$Value),1)
    }
    return $Block
}

function Move-Level2Content([object]$Menu){
    $groups=@($Menu.items|Where-Object{$_.key -ne 'all'})
    if($groups.Count -lt 2){throw '至少需要两个二级分类才能迁移。'}

    $source=Select-One $groups '请选择来源二级分类'
    if($null -eq $source){return}
    $targets=@($groups|Where-Object{$_.key -ne $source.key})
    $target=Select-One $targets '请选择目标二级分类'
    if($null -eq $target){return}

    $count=Get-CategoryUseCount $Menu $source.key
    if($count -eq 0){Write-Host '来源分类没有可迁移的文章/内容。' -ForegroundColor Yellow;return}

    $targetChildren=@($target.children|ForEach-Object{$_.key})
    Write-Host ''
    Write-Host ('将迁移：'+$source.label+' ['+$source.key+'] → '+$target.label+' ['+$target.key+']') -ForegroundColor Yellow
    Write-Host ('影响内容：'+$count+' 条')
    Write-Host '如果原内容带三级分类，而目标二级分类不存在同 key 的三级分类，该内容的三级分类会被清空。' -ForegroundColor DarkYellow
    if(-not(Confirm-Delete '确认执行二级分类内容迁移。')){return}

    $changed=0
    if($Menu.article_enabled){
        $refs=@(Get-PostRefs|Where-Object{$_.module -eq $Menu.module_key -and $_.category -eq $source.key})
        foreach($ref in $refs){
            $newSub=$ref.subcategory
            if(-not[string]::IsNullOrWhiteSpace($newSub) -and $targetChildren -notcontains $newSub){$newSub=''}
            $file=Join-Path $script:PostsDir $ref.file
            Set-PostCategory $file $Menu.module_key $target.key $newSub
            $changed++
        }
    }else{
        $path=Get-DataPathForModule $Menu.module_key
        if(-not(Test-Path $path)){throw '数据文件不存在。'}
        $parts=(Read-Utf8 $path) -split '(?m)(?=^- title:)'
        $out=New-Object System.Collections.ArrayList
        foreach($part in $parts){
            $block=$part
            if((Get-BlockField $block 'group') -eq $source.key){
                $block=Set-BlockField $block 'group' $target.key
                $sub=Get-BlockField $block 'subgroup'
                if(-not[string]::IsNullOrWhiteSpace($sub) -and $targetChildren -notcontains $sub){$block=Set-BlockField $block 'subgroup' '""'}
                $changed++
            }
            [void]$out.Add($block)
        }
        Write-Utf8 $path (@($out)-join '')
    }
    Write-Host ('迁移完成：'+$changed+' 条内容。来源分类配置仍保留，可确认无误后再删除。') -ForegroundColor Green
}

function Move-Level3Content([object]$Menu){
    $parents=@($Menu.items|Where-Object{@($_.children).Count -gt 0})
    if($parents.Count -eq 0){throw '当前模块没有可迁移的三级分类。'}

    $sourceParent=Select-One $parents '请选择来源二级分类'
    if($null -eq $sourceParent){return}
    $sourceChild=Select-One @($sourceParent.children) '请选择来源三级分类'
    if($null -eq $sourceChild){return}

    $targetParent=Select-One $parents '请选择目标二级分类'
    if($null -eq $targetParent){return}
    $targetChildren=@($targetParent.children|Where-Object{ -not($targetParent.key -eq $sourceParent.key -and $_.key -eq $sourceChild.key) })
    if($targetChildren.Count -eq 0){throw '目标二级分类下没有其他三级分类，请先新增目标三级分类。'}
    $targetChild=Select-One $targetChildren '请选择目标三级分类'
    if($null -eq $targetChild){return}

    $count=Get-CategoryUseCount $Menu $sourceParent.key $sourceChild.key
    if($count -eq 0){Write-Host '来源三级分类没有可迁移的文章/内容。' -ForegroundColor Yellow;return}

    Write-Host ''
    Write-Host ('将迁移：'+$sourceParent.label+' → '+$sourceChild.label+'  到  '+$targetParent.label+' → '+$targetChild.label) -ForegroundColor Yellow
    Write-Host ('影响内容：'+$count+' 条')
    if(-not(Confirm-Delete '确认执行三级分类内容迁移。')){return}

    $changed=0
    if($Menu.article_enabled){
        $refs=@(Get-PostRefs|Where-Object{$_.module -eq $Menu.module_key -and $_.category -eq $sourceParent.key -and $_.subcategory -eq $sourceChild.key})
        foreach($ref in $refs){
            $file=Join-Path $script:PostsDir $ref.file
            Set-PostCategory $file $Menu.module_key $targetParent.key $targetChild.key
            $changed++
        }
    }else{
        $path=Get-DataPathForModule $Menu.module_key
        if(-not(Test-Path $path)){throw '数据文件不存在。'}
        $parts=(Read-Utf8 $path) -split '(?m)(?=^- title:)'
        $out=New-Object System.Collections.ArrayList
        foreach($part in $parts){
            $block=$part
            if((Get-BlockField $block 'group') -eq $sourceParent.key -and (Get-BlockField $block 'subgroup') -eq $sourceChild.key){
                $block=Set-BlockField $block 'group' $targetParent.key
                $block=Set-BlockField $block 'subgroup' $targetChild.key
                $changed++
            }
            [void]$out.Add($block)
        }
        Write-Utf8 $path (@($out)-join '')
    }
    Write-Host ('迁移完成：'+$changed+' 条内容。来源分类配置仍保留，可确认无误后再删除。') -ForegroundColor Green
}

function Move-CategoryContent([object]$Menu){
    while($true){
        Clear-Host
        Write-Host ('=== '+$Menu.label+' 分类迁移 ===') -ForegroundColor Cyan
        Write-Host '1. 二级分类内容迁移'
        Write-Host '2. 三级分类内容迁移'
        Write-Host '0. 返回'
        $c=Read-Host '请选择'
        try{
            switch($c){
                '1'{Move-Level2Content $Menu;Pause-Menu}
                '2'{Move-Level3Content $Menu;Pause-Menu}
                '0'{return}
                default{Write-Host '无效选项。';Pause-Menu}
            }
        }catch{Write-Host ('错误：'+$_.Exception.Message) -ForegroundColor Red;Pause-Menu}
        $Menu=Get-Menu $Menu.module_key
    }
}

function Manage-MenuCategories([string]$ModuleKey,[string]$Title){
    while($true){
        Clear-Host
        Write-Host ('=== '+$Title+'分类管理 ===') -ForegroundColor Cyan
        Write-Host '1. 查看分类'
        Write-Host '2. 新增二级分类（自动检查引用冲突）'
        Write-Host '3. 新增三级分类（自动检查引用冲突）'
        Write-Host '4. 删除二级分类（支持多选）'
        Write-Host '5. 删除三级分类（支持多选）'
        Write-Host '6. 分类内容迁移'
        Write-Host '0. 返回'
        $c=Read-Host '请选择'
        try{
            $menu=Get-Menu $ModuleKey
            if($null -eq $menu){throw ('找不到分类配置：'+$ModuleKey)}
            switch($c){
                '1'{Show-Tree $menu;Pause-Menu}
                '2'{Add-Level2 $menu;Pause-Menu}
                '3'{Add-Level3 $menu;Pause-Menu}
                '4'{Remove-Level2 $menu;Pause-Menu}
                '5'{Remove-Level3 $menu;Pause-Menu}
                '6'{Move-CategoryContent $menu}
                '0'{return}
                default{Write-Host '无效选项。';Pause-Menu}
            }
        }catch{Write-Host ('错误：'+$_.Exception.Message) -ForegroundColor Red;Pause-Menu}
    }
}
