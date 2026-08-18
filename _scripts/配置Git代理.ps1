$ErrorActionPreference = 'SilentlyContinue'

function Clear-GitProxy {
    & git config --global --unset-all http.proxy 2>$null
    & git config --global --unset-all https.proxy 2>$null
}

function Get-ProxyTarget([string]$proxyServer) {
    if ([string]::IsNullOrWhiteSpace($proxyServer)) {
        return $null
    }

    $target = $null

    if ($proxyServer -match '(?:^|;)https=([^;]+)') {
        $target = $Matches[1]
    }
    elseif ($proxyServer -match '(?:^|;)http=([^;]+)') {
        $target = $Matches[1]
    }
    else {
        $target = ($proxyServer -split ';')[0]
    }

    if ([string]::IsNullOrWhiteSpace($target)) {
        return $null
    }

    $target = $target.Trim()

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
            if ($uri.Scheme -eq 'https') {
                $port = 443
            }
            else {
                $port = 80
            }
        }

        $client = New-Object System.Net.Sockets.TcpClient
        $async = $client.BeginConnect($uri.Host, $port, $null, $null)
        $connected = $async.AsyncWaitHandle.WaitOne(1000, $false)

        if (-not $connected) {
            $client.Close()
            return $false
        }

        $client.EndConnect($async)
        $client.Close()
        return $true
    }
    catch {
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
        Write-Host ('[PROXY] Windows proxy detected: ' + $proxyUrl) -ForegroundColor Green
        exit 0
    }

    Clear-GitProxy
    Write-Host ('[PROXY] Windows proxy is enabled but endpoint is unavailable: ' + $proxyUrl) -ForegroundColor Yellow
    Write-Host '[PROXY] Git proxy cleared. Direct connection will be tried.' -ForegroundColor Yellow
    exit 2
}

Clear-GitProxy

if ($settings.AutoConfigURL) {
    Write-Host '[PROXY] PAC proxy detected. Git will use direct connection.' -ForegroundColor Yellow
}
else {
    Write-Host '[PROXY] Windows proxy is disabled. Git will use direct connection.' -ForegroundColor Cyan
}

exit 0
