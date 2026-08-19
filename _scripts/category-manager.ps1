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

function Manage-MenuCategories([string]$ModuleKey,[string]$Title){
    while($true){
        Clear-Host
        Write-Host ('=== '+$Title+'分类管理 ===') -ForegroundColor Cyan
        Write-Host '1. 查看分类'
        Write-Host '2. 新增二级分类'
        Write-Host '3. 新增三级分类'
        Write-Host '4. 删除二级分类（支持多选）'
        Write-Host '5. 删除三级分类（支持多选）'
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
                '0'{return}
                default{Write-Host '无效选项。';Pause-Menu}
            }
        }catch{
            Write-Host ('错误：'+$_.Exception.Message) -ForegroundColor Red
            Pause-Menu
        }
    }
}
