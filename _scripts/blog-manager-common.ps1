$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:MenuDir = Join-Path $script:BlogRoot '_menu_defs'
$script:DataDir = Join-Path $script:BlogRoot '_data'
$script:PostsDir = Join-Path $script:BlogRoot '_posts'
$script:CollectionDefDir = Join-Path $script:BlogRoot '_collection_defs'

function Read-Utf8([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Write-Utf8([string]$Path, [string]$Text) {
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    [System.IO.File]::WriteAllText($Path, $Text, $script:Utf8NoBom)
}

function Append-Utf8([string]$Path, [string]$Text) {
    $old = if (Test-Path $Path) { Read-Utf8 $Path } else { '' }
    if ($old.Length -gt 0 -and -not $old.EndsWith("`n")) { $old += [Environment]::NewLine }
    Write-Utf8 $Path ($old + $Text)
}

function Pause-Menu { [void](Read-Host '按回车继续') }

function Yaml-Q([string]$Text) {
    if ($null -eq $Text) { $Text = '' }
    return '"' + $Text.Replace('\','\\').Replace('"','\"') + '"'
}

function Require-Key([string]$Prompt) {
    $key = (Read-Host $Prompt).Trim().ToLower()
    if ($key -notmatch '^[a-z0-9][a-z0-9-]*$') {
        throw 'key 只能使用英文小写、数字和短横线，例如 study、bigdata、hadoop-notes。'
    }
    return $key
}

function Find-FrontMatterEnd($Lines) {
    $seen = $false
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^---\s*$') {
            if (-not $seen) { $seen = $true } else { return $i }
        }
    }
    throw '没有找到 YAML front matter 结束标记。'
}

function Save-Lines([string]$Path, $Lines) {
    Write-Utf8 $Path ((@($Lines) -join [Environment]::NewLine).TrimEnd() + [Environment]::NewLine)
}

function Read-MenuDefinition([string]$FilePath) {
    $lines = (Read-Utf8 $FilePath) -split "`r?`n"
    $moduleKey=''; $topLabel=''; $topUrl=''; $articleEnabled=$false; $showTop=$false; $topOrder=9999
    $items = New-Object System.Collections.ArrayList
    $current=$null; $inChildren=$false; $inItems=$false; $inside=$false

    foreach ($line in $lines) {
        if (-not $inside -and $line -match '^---\s*$') { $inside=$true; continue }
        if ($inside -and $line -match '^---\s*$') {
            if ($null -ne $current) { [void]$items.Add($current) }
            break
        }
        if (-not $inside) { continue }

        if (-not $inItems) {
            if ($line -match '^module_key:\s*(.+?)\s*$') { $moduleKey=$Matches[1].Trim().Trim('"').Trim("'"); continue }
            if ($line -match '^top_label:\s*(.+?)\s*$') { $topLabel=$Matches[1].Trim().Trim('"').Trim("'"); continue }
            if ($line -match '^top_url:\s*(.+?)\s*$') { $topUrl=$Matches[1].Trim().Trim('"').Trim("'"); continue }
            if ($line -match '^article_enabled:\s*(true|false)\s*$') { $articleEnabled=($Matches[1].ToLower() -eq 'true'); continue }
            if ($line -match '^show_top:\s*(true|false)\s*$') { $showTop=($Matches[1].ToLower() -eq 'true'); continue }
            if ($line -match '^top_order:\s*(\d+)\s*$') { $topOrder=[int]$Matches[1]; continue }
            if ($line -match '^items:\s*$') { $inItems=$true; continue }
            continue
        }

        if ($line -match '^  - key:\s*(.+?)\s*$') {
            if ($null -ne $current) { [void]$items.Add($current) }
            $current=[pscustomobject]@{
                key=$Matches[1].Trim().Trim('"').Trim("'")
                label=''
                children=(New-Object System.Collections.ArrayList)
            }
            $inChildren=$false
            continue
        }
        if ($null -eq $current) { continue }
        if ($line -match '^    label:\s*(.+?)\s*$' -and -not $inChildren) { $current.label=$Matches[1].Trim().Trim('"').Trim("'"); continue }
        if ($line -match '^    children:\s*$') { $inChildren=$true; continue }
        if ($line -match '^    slides:\s*$') { $inChildren=$false; continue }
        if ($inChildren -and $line -match '^      - key:\s*(.+?)\s*$') {
            [void]$current.children.Add([pscustomobject]@{
                key=$Matches[1].Trim().Trim('"').Trim("'")
                label=''
            })
            continue
        }
        if ($inChildren -and $line -match '^        label:\s*(.+?)\s*$' -and $current.children.Count -gt 0) {
            $current.children[$current.children.Count-1].label=$Matches[1].Trim().Trim('"').Trim("'")
        }
    }

    if ([string]::IsNullOrWhiteSpace($moduleKey)) { return $null }
    if ([string]::IsNullOrWhiteSpace($topLabel)) { $topLabel=$moduleKey }
    return [pscustomobject]@{
        module_key=$moduleKey; label=$topLabel; top_url=$topUrl; article_enabled=$articleEnabled;
        show_top=$showTop; top_order=$topOrder; file=$FilePath; items=@($items)
    }
}

function Get-Menus {
    if (-not (Test-Path $script:MenuDir)) { throw '_menu_defs 目录不存在，请先运行同步博客.bat。' }
    $result = New-Object System.Collections.ArrayList
    Get-ChildItem $script:MenuDir -Filter '*.md' -File | ForEach-Object {
        $m = Read-MenuDefinition $_.FullName
        if ($null -ne $m) { [void]$result.Add($m) }
    }
    return @($result)
}

function Get-Menu([string]$ModuleKey) {
    $m = @(Get-Menus | Where-Object { $_.module_key -eq $ModuleKey })
    if ($m.Count -eq 0) { return $null }
    return $m[0]
}

function Get-ArticleMenus {
    return @(Get-Menus | Where-Object { $_.article_enabled } | Sort-Object top_order,label)
}

function Get-ObjectField($Object,[string]$Name) {
    if ($null -eq $Object) { return $null }
    if ($Object -is [System.Collections.IDictionary]) {
        if ($Object.Contains($Name)) { return $Object[$Name] }
    }
    $prop = $Object.PSObject.Properties[$Name]
    if ($null -ne $prop) { return $prop.Value }
    return $null
}

function Select-One($Items,[string]$Title,[bool]$AllowCancel=$true) {
    $arr=@($Items)
    if ($arr.Count -eq 0) { return $null }
    Write-Host ''
    Write-Host $Title -ForegroundColor Yellow
    if ($AllowCancel) { Write-Host '0. 返回/取消' }
    for($i=0;$i -lt $arr.Count;$i++) {
        $name = Get-ObjectField $arr[$i] 'label'
        if ([string]::IsNullOrWhiteSpace([string]$name)) { $name = Get-ObjectField $arr[$i] 'title' }
        if ([string]::IsNullOrWhiteSpace([string]$name)) { $name = [string]$arr[$i] }

        $key = Get-ObjectField $arr[$i] 'key'
        if ([string]::IsNullOrWhiteSpace([string]$key)) { $key = Get-ObjectField $arr[$i] 'module_key' }
        if ($null -eq $key) { $key = '' }

        Write-Host (('{0}. {1} [{2}]' -f ($i+1),$name,$key))
    }
    $raw=Read-Host '请选择'; $n=0
    if (-not [int]::TryParse($raw,[ref]$n)) { throw '请输入有效数字。' }
    if ($AllowCancel -and $n -eq 0) { return $null }
    if ($n -lt 1 -or $n -gt $arr.Count) { throw '选择超出范围。' }
    return $arr[$n-1]
}

function Show-Tree([object]$Menu) {
    Write-Host ''
    Write-Host ($Menu.label + ' [' + $Menu.module_key + ']') -ForegroundColor Cyan
    foreach($item in @($Menu.items)) {
        Write-Host ('  - ' + $item.label + ' [' + $item.key + ']')
        foreach($child in @($item.children)) { Write-Host ('      - ' + $child.label + ' [' + $child.key + ']') }
    }
}

function Add-Level2([object]$Menu) {
    $label=(Read-Host '二级分类名称').Trim()
    if ([string]::IsNullOrWhiteSpace($label)) { throw '分类名称不能为空。' }
    $key=Require-Key '二级分类 key'
    if (@($Menu.items | Where-Object { $_.key -eq $key -or $_.label -eq $label }).Count -gt 0) { throw '同名或同 key 的二级分类已经存在。' }

    $lines=New-Object System.Collections.ArrayList
    [void]$lines.AddRange([string[]]((Read-Utf8 $Menu.file) -split "`r?`n"))
    $end=Find-FrontMatterEnd $lines
    $new=@('', ('  - key: ' + $key), ('    label: ' + $label))
    for($j=0;$j -lt $new.Count;$j++) { $lines.Insert($end+$j,$new[$j]) }
    Save-Lines $Menu.file $lines
    Write-Host ('已新增二级分类：'+$label+' ['+$key+']') -ForegroundColor Green
}

function Add-Level3([object]$Menu) {
    $parents=@($Menu.items | Where-Object { $_.key -ne 'all' })
    $parent=Select-One $parents '请选择要增加三级分类的二级分类'
    if ($null -eq $parent) { return }
    $label=(Read-Host '三级分类名称').Trim()
    if ([string]::IsNullOrWhiteSpace($label)) { throw '分类名称不能为空。' }
    $key=Require-Key '三级分类 key'
    if (@($parent.children | Where-Object { $_.key -eq $key -or $_.label -eq $label }).Count -gt 0) { throw '同名或同 key 的三级分类已经存在。' }

    $lines=New-Object System.Collections.ArrayList
    [void]$lines.AddRange([string[]]((Read-Utf8 $Menu.file) -split "`r?`n"))
    $start=-1
    for($i=0;$i -lt $lines.Count;$i++) { if($lines[$i] -match ('^  - key:\s*'+[regex]::Escape($parent.key)+'\s*$')) { $start=$i; break } }
    if($start -lt 0) { throw '没有找到对应二级分类。' }
    $fmEnd=Find-FrontMatterEnd $lines; $end=$fmEnd
    for($i=$start+1;$i -lt $fmEnd;$i++) { if($lines[$i] -match '^  - key:') { $end=$i; break } }
    $childrenLine=-1; $slidesLine=-1
    for($i=$start+1;$i -lt $end;$i++) {
        if($lines[$i] -match '^    children:\s*$') { $childrenLine=$i }
        if($lines[$i] -match '^    slides:\s*$' -and $slidesLine -lt 0) { $slidesLine=$i }
    }
    if($childrenLine -lt 0) {
        $labelLine=$start+1
        for($i=$start+1;$i -lt $end;$i++) { if($lines[$i] -match '^    label:') { $labelLine=$i; break } }
        $insert=$labelLine+1
        $new=@('    children:', ('      - key: ' + $key), ('        label: ' + $label))
    } else {
        $insert=if($slidesLine -ge 0){$slidesLine}else{$end}
        $new=@(('      - key: ' + $key), ('        label: ' + $label))
    }
    for($j=0;$j -lt $new.Count;$j++) { $lines.Insert($insert+$j,$new[$j]) }
    Save-Lines $Menu.file $lines
    Write-Host ('已新增三级分类：'+$parent.label+' → '+$label+' ['+$key+']') -ForegroundColor Green
}

function Get-DataPathForModule([string]$ModuleKey) {
    if ($ModuleKey -eq 'nav') { return (Join-Path $script:DataDir 'site_links.yml') }
    return (Join-Path $script:DataDir ($ModuleKey + '.yml'))
}

function Count-DataRefs([string]$ModuleKey,[string]$Group,[string]$Subgroup='') {
    $path=Get-DataPathForModule $ModuleKey
    if (-not (Test-Path $path)) { return 0 }
    $text=Read-Utf8 $path
    $count=0
    $blocks=$text -split '(?m)(?=^- title:)'
    foreach($b in $blocks) {
        if($b -match ('(?m)^\s*group:\s*["'']?'+[regex]::Escape($Group)+'["'']?\s*$')) {
            if([string]::IsNullOrWhiteSpace($Subgroup) -or $b -match ('(?m)^\s*subgroup:\s*["'']?'+[regex]::Escape($Subgroup)+'["'']?\s*$')) { $count++ }
        }
    }
    return $count
}

function Get-PostRefs {
    $refs=New-Object System.Collections.ArrayList
    if(-not(Test-Path $script:PostsDir)){return @()}
    Get-ChildItem $script:PostsDir -Filter '*.md' -File | ForEach-Object {
        $text=Read-Utf8 $_.FullName; $module='project';$cat='';$sub=''
        if($text -match '(?m)^module:\s*([^\r\n]+)'){$module=$Matches[1].Trim()}
        if($text -match '(?m)^categories:\s*\[([^\]]+)\]'){$cat=($Matches[1].Split(',')[0]).Trim()}
        if($text -match '(?m)^subcategory:\s*([^\r\n]+)'){$sub=$Matches[1].Trim()}
        [void]$refs.Add([pscustomobject]@{file=$_.Name;module=$module;category=$cat;subcategory=$sub})
    }
    return @($refs)
}

function Confirm-Delete([string]$Message) {
    $r=(Read-Host ($Message+' 输入 YES 确认')).Trim()
    return ($r -eq 'YES')
}

function Remove-Level3([object]$Menu) {
    $parent=Select-One @($Menu.items|Where-Object{$_.children.Count -gt 0}) '请选择二级分类'
    if($null -eq $parent){return}
    $child=Select-One @($parent.children) '请选择要删除的三级分类'
    if($null -eq $child){return}

    $used = if ($Menu.article_enabled) {
        @(Get-PostRefs|Where-Object{$_.module -eq $Menu.module_key -and $_.category -eq $parent.key -and $_.subcategory -eq $child.key}).Count
    } else { Count-DataRefs $Menu.module_key $parent.key $child.key }
    if($used -gt 0 -and -not(Confirm-Delete("该三级分类被 $used 条内容使用。仍要删除分类配置吗？"))){return}

    $lines=New-Object System.Collections.ArrayList
    [void]$lines.AddRange([string[]]((Read-Utf8 $Menu.file)-split "`r?`n"))
    for($i=0;$i -lt $lines.Count;$i++) {
        if($lines[$i] -match ('^      - key:\s*'+[regex]::Escape($child.key)+'\s*$')) {
            $lines.RemoveAt($i)
            if($i -lt $lines.Count -and $lines[$i] -match '^        label:'){$lines.RemoveAt($i)}
            break
        }
    }
    Save-Lines $Menu.file $lines
    Write-Host '三级分类已删除。' -ForegroundColor Green
}

function Remove-Level2([object]$Menu) {
    $item=Select-One @($Menu.items|Where-Object{$_.key -ne 'all'}) '请选择要删除的二级分类'
    if($null -eq $item){return}
    $used = if ($Menu.article_enabled) {
        @(Get-PostRefs|Where-Object{$_.module -eq $Menu.module_key -and $_.category -eq $item.key}).Count
    } else { Count-DataRefs $Menu.module_key $item.key }
    if($used -gt 0 -and -not(Confirm-Delete("该二级分类被 $used 条内容使用。仍要删除分类配置吗？"))){return}

    $lines=New-Object System.Collections.ArrayList
    [void]$lines.AddRange([string[]]((Read-Utf8 $Menu.file)-split "`r?`n"))
    $fm=Find-FrontMatterEnd $lines; $start=-1; $end=$fm
    for($i=0;$i -lt $fm;$i++){if($lines[$i] -match ('^  - key:\s*'+[regex]::Escape($item.key)+'\s*$')){$start=$i;break}}
    if($start -lt 0){throw '找不到分类。'}
    for($i=$start+1;$i -lt $fm;$i++){if($lines[$i]-match '^  - key:'){$end=$i;break}}
    for($i=$end-1;$i -ge $start;$i--){$lines.RemoveAt($i)}
    Save-Lines $Menu.file $lines
    Write-Host '二级分类已删除。' -ForegroundColor Green
}

function Manage-MenuCategories([string]$ModuleKey,[string]$Title) {
    while($true) {
        Clear-Host; Write-Host ('=== '+$Title+'分类管理 ===') -ForegroundColor Cyan
        Write-Host '1. 查看分类'; Write-Host '2. 新增二级分类'; Write-Host '3. 新增三级分类'; Write-Host '4. 删除二级分类'; Write-Host '5. 删除三级分类'; Write-Host '0. 返回'
        $c=Read-Host '请选择'
        try {
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
        } catch { Write-Host ('错误：'+$_.Exception.Message) -ForegroundColor Red; Pause-Menu }
    }
}

function Select-Group([string]$ModuleKey) {
    $menu=Get-Menu $ModuleKey
    if($null -eq $menu){throw ('找不到分类配置：'+$ModuleKey)}
    $groups=@($menu.items|Where-Object{$_.key -ne 'all'})
    if($groups.Count -eq 0){throw '当前模块还没有二级分类，请先新增分类。'}
    $group=Select-One $groups '请选择二级分类'
    if($null -eq $group){return $null}
    $sub=$null
    if($group.children.Count -gt 0){$sub=Select-One @($group.children) '请选择三级分类（0 = 不选）'}
    return [pscustomobject]@{menu=$menu;group=$group;sub=$sub}
}

function Select-LocalFile([string]$Filter,[string]$Title) {
    Add-Type -AssemblyName System.Windows.Forms
    $d=New-Object System.Windows.Forms.OpenFileDialog
    $d.Filter=$Filter; $d.Title=$Title; $d.Multiselect=$false
    if($d.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK){return $null}
    return $d.FileName
}

function Copy-Media([string]$Source,[string]$RelativeDir,[string]$Prefix) {
    $sourceItem = Get-Item -LiteralPath $Source
    if ($sourceItem.Length -gt 90MB) {
        throw '文件超过 90MB，为避免 GitHub 推送失败，请压缩文件或改用外链。'
    }

    $dir=Join-Path $script:BlogRoot $RelativeDir
    if(-not(Test-Path $dir)){New-Item -ItemType Directory -Path $dir -Force|Out-Null}
    $ext=[System.IO.Path]::GetExtension($Source).ToLower()
    $name=$Prefix+'-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+(Get-Random -Minimum 1000 -Maximum 9999)+$ext
    $dest=Join-Path $dir $name
    Copy-Item -LiteralPath $Source -Destination $dest
    $rel=$dest.Substring($script:BlogRoot.Length).Replace('\','/')
    if(-not $rel.StartsWith('/')){$rel='/'+$rel}
    return $rel
}

function Read-CollectionDef([string]$FilePath) {
    $text=Read-Utf8 $FilePath
    $key='';$title='';$description='';$publicUrl='';$icon='';$order=9999;$managed=$false
    if($text -match '(?m)^key:\s*(.+?)\s*$'){$key=$Matches[1].Trim().Trim('"').Trim("'")}
    if($text -match '(?m)^title:\s*(.+?)\s*$'){$title=$Matches[1].Trim().Trim('"').Trim("'")}
    if($text -match '(?m)^description:\s*(.+?)\s*$'){$description=$Matches[1].Trim().Trim('"').Trim("'")}
    if($text -match '(?m)^public_url:\s*(.+?)\s*$'){$publicUrl=$Matches[1].Trim().Trim('"').Trim("'")}
    if($text -match '(?m)^icon:\s*(.+?)\s*$'){$icon=$Matches[1].Trim().Trim('"').Trim("'")}
    if($text -match '(?m)^order:\s*(\d+)\s*$'){$order=[int]$Matches[1]}
    if($text -match '(?m)^managed:\s*true\s*$'){$managed=$true}
    if([string]::IsNullOrWhiteSpace($key)){return $null}
    if([string]::IsNullOrWhiteSpace($title)){$title=$key}
    return [pscustomobject]@{key=$key;title=$title;description=$description;public_url=$publicUrl;icon=$icon;order=$order;managed=$managed;file=$FilePath}
}

function Get-CollectionDefs {
    if(-not(Test-Path $script:CollectionDefDir)){return @()}
    $r=New-Object System.Collections.ArrayList
    Get-ChildItem $script:CollectionDefDir -Filter '*.md' -File | ForEach-Object {
        $d=Read-CollectionDef $_.FullName
        if($null -ne $d){[void]$r.Add($d)}
    }
    return @($r|Sort-Object order,title)
}
