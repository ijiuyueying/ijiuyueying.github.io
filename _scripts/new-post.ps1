$ErrorActionPreference = 'Stop'

$script:BlogRoot = Split-Path -Parent $PSScriptRoot
$postsDir = Join-Path $script:BlogRoot '_posts'
$menuDir = Join-Path $script:BlogRoot '_menu_defs'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Make-Text([int[]]$codes) {
    return -join ($codes | ForEach-Object { [char]$_ })
}

function Read-MenuDefinition([string]$filePath) {
    $text = [System.IO.File]::ReadAllText($filePath