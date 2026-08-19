function Add-GalleryImage {
    $sel=Select-Group 'gallery'; if($null -eq $sel){return}
    $file=Select-LocalFile '图片|*.jpg;*.jpeg;*.png;*.webp;*.gif|所有文件|*.*' '选择图片'; if(-not $file){return}
    $sub=if($sel.sub){$sel.sub.key}else{''}
    $dir='assets\images\gallery\'+$sel.group.key; if($sub){$dir+='\'+$sub}
    $web=Copy-Media $file $dir 'img'
    $title=(Read-Host '图片标题').Trim(); if(!$title){$title=[IO.Path]::GetFileNameWithoutExtension($file)}
    $desc=(Read-Host '图片说明（可空）').Trim(); $source=(Read-Host '来源网址（可空）').Trim()
    $block="- title: $(Yaml-Q $title)`n  image: $(Yaml-Q $web)`n  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $sub`n"
    if($source){$block+="  source: $(Yaml-Q $source)`n"}; $block+="`n"
    Append-Utf8 (Join-Path $script:DataDir 'gallery.yml') $block
    Write-Host ('图片已复制并登记：'+$web) -ForegroundColor Green
}

function Manage-Gallery {
    while($true){
        Clear-Host; Write-Host '=== 图片收藏管理 ===' -ForegroundColor Cyan
        Write-Host '1. 图片分类管理'; Write-Host '2. 新增本地图片'; Write-Host '0. 返回'
        $c=Read-Host '请选择'
        try{switch($c){'1'{Manage-MenuCategories 'gallery' '图片'};'2'{Add-GalleryImage;Pause-Menu};'0'{return};default{Write-Host '无效选项';Pause-Menu}}}catch{Write-Host ('错误：'+$_.Exception.Message)-ForegroundColor Red;Pause-Menu}
    }
}

function Add-LocalVideo {
    $sel=Select-Group 'videos'; if($null -eq $sel){return}
    $file=Select-LocalFile '视频|*.mp4;*.webm;*.ogg;*.m4v|所有文件|*.*' '选择本地视频'; if(-not $file){return}
    $size=(Get-Item -LiteralPath $file).Length
    if($size -gt 90MB){throw '视频超过 90MB，不建议放入 GitHub。请改用在线视频链接。'}
    $web=Copy-Media $file 'assets\videos' 'video'
    $title=(Read-Host '视频标题').Trim(); if(!$title){$title=[IO.Path]::GetFileNameWithoutExtension($file)}
    $desc=(Read-Host '视频说明（可空）').Trim(); $sub=if($sel.sub){$sel.sub.key}else{''}
    $block="- title: $(Yaml-Q $title)`n  platform: local`n  video: $(Yaml-Q $web)`n  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $sub`n`n"
    Append-Utf8 (Join-Path $script:DataDir 'videos.yml') $block
    Write-Host ('本地视频已复制并登记：'+$web) -ForegroundColor Green
}

function Add-BilibiliVideo {
    $sel=Select-Group 'videos'; if($null -eq $sel){return}
    $input=(Read-Host 'B站视频地址或 BV 号').Trim(); if($input -notmatch '(BV[0-9A-Za-z]+)'){throw '没有识别到 BV 号。'}
    $bvid=$Matches[1]; $url=if($input -match '^https?://'){$input}else{'https://www.bilibili.com/video/'+$bvid+'/'}
    $title=(Read-Host '视频标题').Trim(); if(!$title){throw '标题不能为空。'}
    $desc=(Read-Host '视频说明（可空）').Trim(); $cover=(Read-Host '封面图片网址（可空）').Trim(); $sub=if($sel.sub){$sel.sub.key}else{''}
    $block="- title: $(Yaml-Q $title)`n  platform: bilibili`n  bvid: $bvid`n  url: $(Yaml-Q $url)`n"
    if($cover){$block+="  cover: $(Yaml-Q $cover)`n"}
    $block+="  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $sub`n`n"
    Append-Utf8 (Join-Path $script:DataDir 'videos.yml') $block
    Write-Host 'B站视频已登记。' -ForegroundColor Green
}

function Add-ExternalVideo {
    $sel=Select-Group 'videos'; if($null -eq $sel){return}
    $url=(Read-Host '在线视频/网页地址').Trim(); if($url -notmatch '^https?://'){throw '请输入 http/https 地址。'}
    $title=(Read-Host '视频标题').Trim(); if(!$title){throw '标题不能为空。'}
    $desc=(Read-Host '视频说明（可空）').Trim(); $platform=(Read-Host '平台名称（可空）').Trim(); if(!$platform){$platform='external'}
    $sub=if($sel.sub){$sel.sub.key}else{''}
    $block="- title: $(Yaml-Q $title)`n  platform: $(Yaml-Q $platform)`n  url: $(Yaml-Q $url)`n"
    if($url -match '\.(mp4|webm|ogg)(\?|$)'){$block+="  video: $(Yaml-Q $url)`n"}
    $block+="  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $sub`n`n"
    Append-Utf8 (Join-Path $script:DataDir 'videos.yml') $block
    Write-Host '在线视频已登记。' -ForegroundColor Green
}

function Manage-Videos {
    while($true){
        Clear-Host; Write-Host '=== 视频收藏管理 ===' -ForegroundColor Cyan
        Write-Host '1. 视频分类管理';Write-Host '2. 新增本地视频';Write-Host '3. 新增B站视频';Write-Host '4. 新增其他在线视频';Write-Host '0. 返回'
        $c=Read-Host '请选择'
        try{switch($c){'1'{Manage-MenuCategories 'videos' '视频'};'2'{Add-LocalVideo;Pause-Menu};'3'{Add-BilibiliVideo;Pause-Menu};'4'{Add-ExternalVideo;Pause-Menu};'0'{return};default{Write-Host '无效选项';Pause-Menu}}}catch{Write-Host ('错误：'+$_.Exception.Message)-ForegroundColor Red;Pause-Menu}
    }
}

function Add-LocalMusic {
    $sel=Select-Group 'music'; if($null -eq $sel){return}
    $file=Select-LocalFile '音频|*.mp3;*.m4a;*.ogg;*.wav;*.flac|所有文件|*.*' '选择你有权公开使用的本地音频'; if(-not $file){return}
    $size=(Get-Item -LiteralPath $file).Length; if($size -gt 90MB){throw '音频超过 90MB，请改用正版平台链接。'}
    $web=Copy-Media $file 'assets\audio' 'audio'
    $title=(Read-Host '歌曲标题').Trim(); if(!$title){$title=[IO.Path]::GetFileNameWithoutExtension($file)}
    $artist=(Read-Host '歌手/作者（可空）').Trim(); $desc=(Read-Host '说明（可空）').Trim(); $sub=if($sel.sub){$sel.sub.key}else{''}
    $cat=$sel.group.label; if($sel.sub){$cat+=' / '+$sel.sub.label}
    $block="- title: $(Yaml-Q $title)`n  artist: $(Yaml-Q $artist)`n  category: $(Yaml-Q $cat)`n  group: $($sel.group.key)`n  subgroup: $sub`n  description: $(Yaml-Q $desc)`n  file: $(Yaml-Q $web)`n  platform: 本地音频`n`n"
    Append-Utf8 (Join-Path $script:DataDir 'music.yml') $block
    Write-Host ('本地音频已复制并登记：'+$web) -ForegroundColor Green
}

function Add-OnlineMusic {
    $sel=Select-Group 'music'; if($null -eq $sel){return}
    $title=(Read-Host '歌曲标题').Trim(); if(!$title){throw '标题不能为空。'}
    $artist=(Read-Host '歌手/作者').Trim(); $url=(Read-Host '正版平台地址').Trim(); if($url -notmatch '^https?://'){throw '请输入 http/https 地址。'}
    $platform=(Read-Host '平台名称').Trim(); $desc=(Read-Host '说明（可空）').Trim(); $sub=if($sel.sub){$sel.sub.key}else{''}
    $cat=$sel.group.label; if($sel.sub){$cat+=' / '+$sel.sub.label}
    $block="- title: $(Yaml-Q $title)`n  artist: $(Yaml-Q $artist)`n  category: $(Yaml-Q $cat)`n  group: $($sel.group.key)`n  subgroup: $sub`n  description: $(Yaml-Q $desc)`n  url: $(Yaml-Q $url)`n  platform: $(Yaml-Q $platform)`n`n"
    Append-Utf8 (Join-Path $script:DataDir 'music.yml') $block
    Write-Host '在线歌曲已登记。' -ForegroundColor Green
}

function Manage-Music {
    while($true){
        Clear-Host;Write-Host '=== 歌曲管理 ===' -ForegroundColor Cyan
        Write-Host '1. 歌曲分类管理';Write-Host '2. 新增本地音乐';Write-Host '3. 新增在线歌曲';Write-Host '0. 返回'
        $c=Read-Host '请选择'
        try{switch($c){'1'{Manage-MenuCategories 'music' '歌曲'};'2'{Add-LocalMusic;Pause-Menu};'3'{Add-OnlineMusic;Pause-Menu};'0'{return};default{Write-Host '无效选项';Pause-Menu}}}catch{Write-Host ('错误：'+$_.Exception.Message)-ForegroundColor Red;Pause-Menu}
    }
}

function Add-SiteLink {
    $sel=Select-Group 'nav'; if($null -eq $sel){return}
    $title=(Read-Host '网站名称').Trim(); if(!$title){throw '网站名称不能为空。'}
    $url=(Read-Host '网址').Trim(); if($url -notmatch '^https?://'){throw '请输入 http/https 地址。'}
    $desc=(Read-Host '网站说明（可空）').Trim(); $sub=if($sel.sub){$sel.sub.key}else{''}
    $block="- title: $(Yaml-Q $title)`n  url: $(Yaml-Q $url)`n  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $sub`n`n"
    Append-Utf8 (Join-Path $script:DataDir 'site_links.yml') $block
    Write-Host '网址已登记。' -ForegroundColor Green
}

function Manage-Links {
    while($true){
        Clear-Host;Write-Host '=== 网址导航管理 ===' -ForegroundColor Cyan
        Write-Host '1. 网址分类管理';Write-Host '2. 新增网址';Write-Host '0. 返回'
        $c=Read-Host '请选择'
        try{switch($c){'1'{Manage-MenuCategories 'nav' '网址'};'2'{Add-SiteLink;Pause-Menu};'0'{return};default{Write-Host '无效选项';Pause-Menu}}}catch{Write-Host ('错误：'+$_.Exception.Message)-ForegroundColor Red;Pause-Menu}
    }
}

function Add-GenericCollectionItem {
    $modules=@(Get-CollectionDefs | Where-Object{$_.managed})
    $module=Select-One $modules '请选择自建收藏模块'; if($null -eq $module){return}
    $sel=Select-Group $module.key; if($null -eq $sel){return}
    $title=(Read-Host '标题').Trim(); if(!$title){throw '标题不能为空。'}
    $desc=(Read-Host '说明（可空）').Trim(); $url=(Read-Host '网址（可空）').Trim(); if($url -and $url -notmatch '^https?://'){throw '网址必须以 http/https 开头。'}
    $image=(Read-Host '图片网址（可空）').Trim(); $file=(Read-Host '文件网址/相对路径（可空）').Trim(); $sub=if($sel.sub){$sel.sub.key}else{''}
    $block="- title: $(Yaml-Q $title)`n  description: $(Yaml-Q $desc)`n  group: $($sel.group.key)`n  subgroup: $sub`n"
    if($url){$block+="  url: $(Yaml-Q $url)`n"};if($image){$block+="  image: $(Yaml-Q $image)`n"};if($file){$block+="  file: $(Yaml-Q $file)`n"};$block+="`n"
    Append-Utf8 (Get-DataPathForModule $module.key) $block
    Write-Host '自建收藏内容已登记。' -ForegroundColor Green
}
