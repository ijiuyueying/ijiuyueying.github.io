# UTF-8 PowerShell entry for blog content management
# Phase 1: unified menu and content manager

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

function Show-Menu {
    Clear-Host
    Write-Host '========================================'
    Write-Host ' Jiuyueying Blog Content Manager'
    Write-Host '========================================'
    Write-Host '1. 文章分类管理'
    Write-Host '2. 图片收藏管理'
    Write-Host '3. 视频收藏管理'
    Write-Host '4. 歌曲管理'
    Write-Host '5. 网址导航管理'
    Write-Host '6. 配置检查'
    Write-Host '0. 退出'
}

function Check-Config {
    Write-Host ''
    Write-Host '[配置检查]'
    Write-Host '检查项目：'
    Write-Host '- _menu_defs 文件是否存在'
    Write-Host '- YAML 文件是否为空'
    Write-Host '- 后续版本检查重复 key'
    Write-Host ''
    if (Test-Path '_menu_defs') {
        Write-Host 'OK: _menu_defs exists'
    }
    else {
        Write-Host 'ERROR: _menu_defs missing'
    }
}

while ($true) {
    Show-Menu
    $choice = Read-Host '请选择'

    switch ($choice) {
        '1' {
            Write-Host '文章分类管理（下一阶段接入动态新增一级/二级/三级）'
            Pause
        }
        '2' {
            Write-Host '图片收藏管理（下一阶段接入图片复制与分类登记）'
            Pause
        }
        '3' {
            Write-Host '视频收藏管理（下一阶段接入本地视频/B站）'
            Pause
        }
        '4' {
            Write-Host '歌曲管理（下一阶段接入本地音乐/在线音乐）'
            Pause
        }
        '5' {
            Write-Host '网址导航管理（下一阶段接入网站登记）'
            Pause
        }
        '6' {
            Check-Config
            Pause
        }
        '0' {
            break
        }
        default {
            Write-Host '无效选项'
            Pause
        }
    }
}
