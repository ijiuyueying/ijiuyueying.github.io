$ErrorActionPreference = 'SilentlyContinue'

function Clear-GitProxy {
    & git config --global --unset-all http.proxy 2>$null
    & git config --global --unset-all https.proxy 2>$null
}

function Get-ProxyTarget([string]$proxyServer) {
    if ([string]::IsNullOrWhiteSpace($proxyServer)) { return $null }

    $target = $null
    if ($proxyServer -match '(?:^|;)https=([^;]+)') {
        $target = $Matches[1]
    } elseif ($proxyServer -match '(?:^|;)http=([^;]+)') {
        $target = $Matches[1]
    } else {
        $target = ($proxyServer -split ';')[0]
    }

    $target = $target.Trim()
    if ([string]::IsNullOrWhiteSpace($target)) { return $null }
    if ($target -notmatch '^[a-zA-Z][a-zA-Z0-9+.-]*://') {
        $target = 'http://' + $target
    }
    return $target
}

function Test-ProxyEndpoint([string]$proxyUrl) {
    try {
        $uri = [Uri]$proxyUrl
        $port = $uri.Port
        if ($port -le 0) {
            if ($uri.Scheme -eq 'https') { $port = 443 } else { $port = 80 }
        }

        $client = New-Object System.Net.Sockets.TcpClient
        $async = $client.BeginConnect($uri.Host, $port, $null, $null)
        $ok = $async.AsyncWaitHandle.WaitOne(1000, $false)
        if (-not $ok) {
            $client.Close()
            return $false
        }
        $client.EndConnect($async)
        $client.Close()
        return $true
    } catch {
        return $false
    }
}

$settings = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
$enabled = ($settings.ProxyEnable -eq 1)
$proxyUrl = Get-ProxyTarget ([string]$settings.ProxyServer)

if ($enabled -and $proxyUrl) {
    if (Test-ProxyEndpoint $proxyUrl) {
        & git config --global http.proxy $proxyUrl
        & git config --global https.proxy $proxyUrl
        Write-Host ('[代理] 已检测到 Windows 系统代理：' + $proxyUrl) -ForegroundColor Green
        exit 0
    }

    Clear-GitProxy
    Write-Host ('[代理] Windows 显示代理已开启，但端口不可用：' + $proxyUrl) -ForegroundColor Yellow
    Write-Host '[代理] 已临时清除 Git 代理，将尝试直连 GitHub。' -ForegroundColor Yellow
    exit 2
}

Clear-GitProxy
if ($settings.AutoConfigURL) {
    Write-Host '[代理] 检测到 PAC 自动代理，但 Git 无法直接读取 PAC；当前按直连方式处理。' -ForegroundColor Yellow
} else {
    Write-Host '[代理] Windows 系统代理未开启，Git 使用直连。' -ForegroundColor Cyan
}
exit 0
