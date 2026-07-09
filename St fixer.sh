<#
.SYNOPSIS
    Steam Manifest Downloader - AARYAN CHEATS Professional Depot Manifest Acquisition System
    Windows PowerShell 5.1 Compatible Version
#>

[CmdletBinding()]
param(
    [string]$ApiKey,
    [string]$MorrenusApiKey,
    [string]$AppId,
    [ValidateSet('github', 'github+morrenus', 'github+manifesthub')]
    [string]$Mode,
    [string]$OutputDirectory,
    [ValidateSet('Debug', 'Info', 'Warning', 'Error', 'None')]
    [string]$LogLevel = 'Info',
    [ValidateRange(1, 10)]
    [int]$RetryCount = 5,
    [ValidateRange(1, 30)]
    [int]$RetryDelay = 3,
    [ValidateRange(30, 600)]
    [int]$Timeout = 120,
    [switch]$Quiet
)

#region Initialization & Configuration
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Console Configuration
if (-not $Quiet) {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $Host.UI.RawUI.WindowTitle = "AARYAN CHEATS - Steam Manifest Downloader v2.0"
}

# Logging System
$script:LogLevels = @{
    'Debug'   = 0
    'Info'    = 1
    'Warning' = 2
    'Error'   = 3
    'None'    = 4
}
$script:CurrentLogLevel = $script:LogLevels[$LogLevel]

function Write-Log {
    [CmdletBinding()]
    param(
        [string]$Message,
        [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
        [string]$Level = 'Info',
        [ConsoleColor]$ForegroundColor
    )

    if ($Quiet) { return }

    $levelValue = $script:LogLevels[$Level]
    if ($levelValue -lt $script:CurrentLogLevel) { return }

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $levelPrefix = switch ($Level) {
        'Debug'   { '[DBG]' }
        'Info'    { '[INF]' }
        'Warning' { '[WRN]' }
        'Error'   { '[ERR]' }
        default   { '[???]' }
    }

    if ($ForegroundColor) {
        Write-Host "[$timestamp] $levelPrefix $Message" -ForegroundColor $ForegroundColor
    } else {
        $defaultColor = switch ($Level) {
            'Debug'   { 'DarkGray' }
            'Info'    { 'White' }
            'Warning' { 'Yellow' }
            'Error'   { 'Red' }
            default   { 'White' }
        }
        Write-Host "[$timestamp] $levelPrefix $Message" -ForegroundColor $defaultColor
    }
}

function Write-Header {
    param([string]$CurrentMode = "github")

    if ($Quiet) { return }

    Clear-Host
    $modeDisplay = switch ($CurrentMode) {
        'github'              { 'GitHub Mirror (Primary)' }
        'github+morrenus'     { 'GitHub + Morrenus (Enterprise)' }
        'github+manifesthub'  { 'GitHub + ManifestHub (Enterprise)' }
        default               { 'Unknown Mode' }
    }

    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║            AARYAN CHEATS - STEAM MANIFEST SYSTEM                ║" -ForegroundColor Cyan
    Write-Host "  ║                         v2.0.0                                  ║" -ForegroundColor Cyan
    Write-Host "  ║                                                                  ║" -ForegroundColor Cyan
    Write-Host "  ║  Mode: $(' ' * (35 - $modeDisplay.Length))$modeDisplay ║" -ForegroundColor Cyan
    Write-Host "  ║  ──────────────────────────────────────────────────────────────────── ║" -ForegroundColor DarkGray
    Write-Host "  ║  Enterprise-grade manifest acquisition for SteamTools              ║" -ForegroundColor DarkGray
    Write-Host "  ║  Developed Exclusively for AARYAN CHEATS                          ║" -ForegroundColor DarkGray
    Write-Host "  ╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Label = "Progress",
        [int]$Width = 40,
        [ConsoleColor]$Color = "Cyan"
    )

    if ($Quiet) { return }

    $percent = if ($Total -gt 0) { [math]::Round(($Current / $Total) * 100) } else { 0 }
    $filled = [math]::Floor(($Current / [math]::Max($Total, 1)) * $Width)
    $empty = $Width - $filled

    $barFilled = "█" * $filled
    $barEmpty = "░" * $empty

    Write-Host "`r  $Label [$barFilled" -NoNewline
    Write-Host $barEmpty -NoNewline -ForegroundColor DarkGray
    Write-Host "] $percent% ($Current/$Total)" -NoNewline
}

function Write-Divider {
    param([string]$Character = "─", [int]$Length = 62, [ConsoleColor]$Color = "DarkGray")
    if (-not $Quiet) {
        Write-Host "  $($Character * $Length)" -ForegroundColor $Color
    }
}

function Exit-WithPrompt {
    if ($Quiet) { exit 1 }
    Write-Host ""
    Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
#endregion

#region Core Functions
function Get-SteamPath {
    $registryPaths = @(
        "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam",
        "HKLM:\SOFTWARE\Valve\Steam",
        "HKCU:\SOFTWARE\Valve\Steam"
    )

    foreach ($path in $registryPaths) {
        try {
            $steamPath = (Get-ItemProperty -Path $path -ErrorAction SilentlyContinue).InstallPath
            if ($steamPath -and (Test-Path $steamPath)) {
                Write-Log "Steam installation located via registry: $steamPath" -Level Debug
                return $steamPath
            }
        } catch {
            Write-Log ("Registry check failed for $path : " + $_.Exception.Message) -Level Debug
        }
    }

    $commonPaths = @(
        "$env:ProgramFiles\Steam",
        "${env:ProgramFiles(x86)}\Steam",
        "$env:LOCALAPPDATA\Steam"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            Write-Log "Steam installation located via common path: $path" -Level Debug
            return $path
        }
    }

    Write-Log "Steam installation not found" -Level Error -ForegroundColor Red
    return $null
}

function Get-DepotIdsFromLua {
    param([string]$LuaPath)

    Write-Log "Parsing Lua file: $LuaPath" -Level Debug

    if (-not (Test-Path $LuaPath)) {
        Write-Log "Lua file not found: $LuaPath" -Level Error -ForegroundColor Red
        return @()
    }

    try {
        $content = Get-Content -Path $LuaPath -Encoding UTF8 -ErrorAction Stop
        $depots = New-Object System.Collections.Generic.List[string]

        foreach ($line in $content) {
            if ($line -match 'addappid\s*\(\s*(\d+)\s*,\s*\d+\s*,\s*"[a-fA-F0-9]+"') {
                $depotId = $matches[1]
                if (-not $depots.Contains($depotId)) {
                    $depots.Add($depotId)
                    Write-Log "Found depot ID: $depotId" -Level Debug
                }
            }
        }

        Write-Log ("Extracted " + $depots.Count + " unique depot IDs") -Level Debug
        return $depots.ToArray()
    } catch {
        Write-Log ("Error parsing Lua file: " + $_.Exception.Message) -Level Error -ForegroundColor Red
        return @()
    }
}

function Get-AppInfo {
    param([string]$AppId)

    $url = "https://api.steamcmd.net/v1/info/$AppId"

    Write-Log "Fetching application information from SteamCMD API" -Level Debug

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 30 -ErrorAction Stop
        if ($response.status -eq 'success') {
            Write-Log "Application information retrieved successfully" -Level Debug
            return $response
        } else {
            Write-Log ("API returned non-success status: " + $response.status) -Level Warning
            return $null
        }
    } catch {
        Write-Log ("Failed to retrieve application information: " + $_.Exception.Message) -Level Error
        return $null
    }
}

function Get-ManifestIdForDepot {
    param(
        [object]$AppInfo,
        [string]$AppId,
        [string]$DepotId
    )

    try {
        $depots = $AppInfo.data.$AppId.depots
        if ($depots.$DepotId -and $depots.$DepotId.manifests -and $depots.$DepotId.manifests.public) {
            $manifestId = $depots.$DepotId.manifests.public.gid
            Write-Log ("Retrieved manifest ID $manifestId for depot $DepotId") -Level Debug
            return $manifestId
        } else {
            Write-Log ("No manifest found for depot $DepotId") -Level Debug
            return $null
        }
    } catch {
        Write-Log ("Error retrieving manifest ID for depot $DepotId : " + $_.Exception.Message) -Level Error
        return $null
    }
}

function Invoke-Download {
    param(
        [string]$Url,
        [string]$OutputFile,
        [int]$RetryCount = 5,
        [int]$RetryDelay = 3,
        [int]$Timeout = 120,
        [string]$Source = 'Unknown'
    )

    $lastError = $null

    for ($attempt = 1; $attempt -le $RetryCount; $attempt++) {
        try {
            if (Test-Path $OutputFile) {
                Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue
            }

            Write-Log ("Download attempt $attempt/$RetryCount from $Source") -Level Debug

            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec $Timeout -OutFile $OutputFile -ErrorAction Stop

            if (Test-Path $OutputFile) {
                $fileInfo = Get-Item $OutputFile
                if ($fileInfo.Length -gt 0) {
                    Write-Log ("Successfully downloaded " + $fileInfo.Length + " bytes from $Source") -Level Debug
                    return @{
                        Success  = $true
                        Size     = $fileInfo.Length
                        Attempts = $attempt
                        Is404    = $false
                    }
                } else {
                    $lastError = "Empty file received"
                    Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue
                }
            }

            $lastError = "File not created or empty"
        } catch {
            $statusCode = $null
            if ($_.Exception.Response) {
                $statusCode = [int]$_.Exception.Response.StatusCode
            }

            if ($statusCode -eq 404) {
                Write-Log ("Resource not found (404) at $Source") -Level Debug
                if (Test-Path $OutputFile) {
                    Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue
                }
                return @{
                    Success  = $false
                    Is404    = $true
                    Error    = "Resource not found (404)"
                    Attempts = $attempt
                }
            }

            $lastError = $_.Exception.Message
            Write-Log ("Attempt $attempt failed: $lastError") -Level Debug
        }

        if ($attempt -lt $RetryCount) {
            Write-Log ("Retrying in $RetryDelay seconds...") -Level Debug
            Start-Sleep -Seconds $RetryDelay
        }
    }

    return @{
        Success  = $false
        Is404    = $false
        Error    = $lastError
        Attempts = $RetryCount
    }
}

function Download-Manifest {
    param(
        [string]$DepotId,
        [string]$ManifestId,
        [string]$OutputPath,
        [string]$Mode = 'github',
        [string]$ApiKey = $null,
        [int]$RetryCount = 5,
        [int]$RetryDelay = 3,
        [int]$Timeout = 120
    )

    $outputFile = Join-Path $OutputPath "${DepotId}_${ManifestId}.manifest"
    $githubUrl = "https://raw.githubusercontent.com/qwe213312/k25FCdfEOoEJ42S6/main/${DepotId}_${ManifestId}.manifest"

    Write-Log ("Processing depot $DepotId (Manifest: $ManifestId)") -Level Debug

    $githubResult = Invoke-Download -Url $githubUrl -OutputFile $outputFile -RetryCount 2 -RetryDelay $RetryDelay -Timeout $Timeout -Source "GitHub"

    if ($githubResult.Success) {
        Write-Log "Successfully downloaded from GitHub mirror" -Level Info
        return @{
            Success     = $true
            Source      = 'GitHub'
            FilePath    = $outputFile
            Size        = $githubResult.Size
            Attempts    = $githubResult.Attempts
            IsFallback  = $false
        }
    }

    if ($Mode -ne 'github' -and $ApiKey) {
        $secondaryConfig = switch ($Mode) {
            'github+morrenus' {
                @{
                    Url = "https://hubcapmanifest.com/api/v1/generate/manifest?depot_id=${DepotId}&manifest_id=${ManifestId}&api_key=${ApiKey}"
                    Source = 'Morrenus'
                }
            }
            'github+manifesthub' {
                @{
                    Url = "https://api.manifesthub1.filegear-sg.me/manifest?apikey=${ApiKey}&depotid=${DepotId}&manifestid=${ManifestId}"
                    Source = 'ManifestHub'
                }
            }
            default { $null }
        }

        if ($secondaryConfig) {
            Write-Log ("Attempting fallback download from " + $secondaryConfig.Source + "...") -Level Warning

            $fallbackResult = Invoke-Download -Url $secondaryConfig.Url -OutputFile $outputFile -RetryCount $RetryCount -RetryDelay $RetryDelay -Timeout $Timeout -Source $secondaryConfig.Source

            if ($fallbackResult.Success) {
                Write-Log ("Successfully downloaded from " + $secondaryConfig.Source + " fallback") -Level Info
                return @{
                    Success     = $true
                    Source      = $secondaryConfig.Source
                    FilePath    = $outputFile
                    Size        = $fallbackResult.Size
                    Attempts    = $fallbackResult.Attempts
                    IsFallback  = $true
                }
            } else {
                Write-Log ("Fallback download from " + $secondaryConfig.Source + " failed: " + $fallbackResult.Error) -Level Error
            }
        }
    } else {
        Write-Log "No fallback source configured or API key missing" -Level Debug
    }

    return @{
        Success  = $false
        Source   = 'None'
        Error    = $githubResult.Error
        Attempts = $githubResult.Attempts
        Is404    = $githubResult.Is404
    }
}

function Format-FileSize {
    param([long]$Bytes)

    if ($Bytes -ge 1GB) {
        return ("{0:N2} GB" -f ($Bytes / 1GB))
    } elseif ($Bytes -ge 1MB) {
        return ("{0:N2} MB" -f ($Bytes / 1MB))
    } elseif ($Bytes -ge 1KB) {
        return ("{0:N2} KB" -f ($Bytes / 1KB))
    } else {
        return ("$Bytes B")
    }
}

function Validate-ApiKey {
    param(
        [string]$Key,
        [string]$Service
    )

    if (-not $Key) {
        Write-Log ("$Service API key is required") -Level Error -ForegroundColor Red
        return $false
    }

    switch ($Service) {
        'Morrenus' {
            if ($Key -notmatch '^smm_[0-9a-f]{96}$') {
                Write-Log "Invalid Morrenus API key format" -Level Error -ForegroundColor Red
                Write-Log "Expected: smm_ followed by 96 hex characters" -Level Info
                return $false
            }
            try {
                Write-Log "Validating Morrenus API key..." -Level Info
                $response = Invoke-RestMethod -Uri "https://hubcapmanifest.com/api/v1/user/stats?api_key=$Key" -Method Get -TimeoutSec 15 -ErrorAction Stop
                if (-not $response.can_make_requests) {
                    Write-Log ("Morrenus API key has reached daily limit: " + $response.daily_usage + "/" + $response.daily_limit) -Level Warning -ForegroundColor Yellow
                    return $false
                }
                Write-Log ("Morrenus API key validated successfully. Welcome " + $response.username + "!") -Level Info -ForegroundColor Green
                return $true
            } catch {
                $statusCode = $null
                if ($_.Exception.Response) { $statusCode = [int]$_.Exception.Response.StatusCode }
                $errorMsg = "Morrenus API key validation failed"
                if ($statusCode -in 401, 403, 404) {
                    $errorMsg += ": Invalid or expired key"
                } else {
                    $errorMsg += (": " + $_.Exception.Message)
                }
                Write-Log $errorMsg -Level Error -ForegroundColor Red
                return $false
            }
        }
        'ManifestHub' {
            if ($Key -match '^[a-zA-Z0-9_-]+$') {
                Write-Log "ManifestHub API key validated" -Level Info
                return $true
            } else {
                Write-Log "ManifestHub API key format appears invalid" -Level Warning
                return $true
            }
        }
        default { return $true }
    }
}
#endregion

#region Main Execution
try {
    $resolvedMode = if ($Mode) { $Mode } else { $env:MANIFEST_MODE }

    if (-not $resolvedMode) {
        if (-not $Quiet) {
            Write-Host ""
            Write-Host "  ┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
            Write-Host "  │              AARYAN CHEATS - MODE SELECTION                 │" -ForegroundColor Cyan
            Write-Host "  ├─────────────────────────────────────────────────────────────┤" -ForegroundColor DarkGray
            Write-Host "  │  1. GitHub Mirror Only    (No authentication required)      │" -ForegroundColor White
            Write-Host "  │  2. GitHub + Morrenus     (Enterprise-grade fallback)       │" -ForegroundColor White
            Write-Host "  │  3. GitHub + ManifestHub  (Community-driven fallback)       │" -ForegroundColor White
            Write-Host "  └─────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
            Write-Host ""

            do {
                $modeChoice = Read-Host "  Enter selection (1-3)"
            } while ($modeChoice -notin @("1", "2", "3"))

            $resolvedMode = switch ($modeChoice) {
                "1" { "github" }
                "2" { "github+morrenus" }
                "3" { "github+manifesthub" }
            }
        } else {
            $resolvedMode = "github"
            Write-Log "Operating in quiet mode - defaulting to GitHub-only" -Level Info
        }
    }

    if (-not $Quiet) {
        Write-Header -CurrentMode $resolvedMode
    } else {
        Write-Log "Starting AARYAN CHEATS Steam Manifest Downloader v2.0" -Level Info
        Write-Log ("Mode: $resolvedMode") -Level Info
    }

    $activeApiKey = $null

    switch ($resolvedMode) {
        'github' {
            Write-Log "Operating in GitHub-only mode" -Level Info
            Write-Log "No API authentication required" -Level Info
        }
        'github+morrenus' {
            Write-Log "Operating in GitHub+Morrenus mode" -Level Info
            $activeApiKey = if ($MorrenusApiKey) { $MorrenusApiKey } else { $env:MORRENUS_API_KEY }

            if (-not $activeApiKey -and -not $Quiet) {
                Write-Host ""
                Write-Host "  ┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
                Write-Host "  │              MORRENUS API KEY REQUIRED                      │" -ForegroundColor Yellow
                Write-Host "  ├─────────────────────────────────────────────────────────────┤" -ForegroundColor DarkGray
                Write-Host "  │  Get your free API key from:                               │" -ForegroundColor White
                Write-Host "  │  https://hubcapmanifest.com/                              │" -ForegroundColor White
                Write-Host "  │                                                             │" -ForegroundColor White
                Write-Host "  │  Format: smm_ followed by 96 hex characters               │" -ForegroundColor White
                Write-Host "  └─────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
                Write-Host ""
                $activeApiKey = Read-Host "  Enter Morrenus API Key"
            }

            if (-not $activeApiKey) {
                Write-Log "Morrenus API key is required for this mode" -Level Error -ForegroundColor Red
                Exit-WithPrompt
            }

            if (-not (Validate-ApiKey -Key $activeApiKey -Service 'Morrenus')) {
                Exit-WithPrompt
            }
        }
        'github+manifesthub' {
            Write-Log "Operating in GitHub+ManifestHub mode" -Level Info
            $activeApiKey = if ($ApiKey) { $ApiKey } else { $env:MH_API_KEY }

            if (-not $activeApiKey -and -not $Quiet) {
                Write-Host ""
                Write-Host "  ┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
                Write-Host "  │              MANIFESTHUB API KEY REQUIRED                   │" -ForegroundColor Yellow
                Write-Host "  ├─────────────────────────────────────────────────────────────┤" -ForegroundColor DarkGray
                Write-Host "  │  Get your free API key from:                               │" -ForegroundColor White
                Write-Host "  │  https://manifesthub1.filegear-sg.me/                     │" -ForegroundColor White
                Write-Host "  └─────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
                Write-Host ""
                $activeApiKey = Read-Host "  Enter ManifestHub API Key"
            }

            if (-not $activeApiKey) {
                Write-Log "ManifestHub API key is required for this mode" -Level Error -ForegroundColor Red
                Exit-WithPrompt
            }

            if (-not (Validate-ApiKey -Key $activeApiKey -Service 'ManifestHub')) {
                Exit-WithPrompt
            }
        }
    }

    if (-not $AppId) {
        $AppId = $env:APP_ID
    }

    while (-not $AppId) {
        if ($Quiet) {
            Write-Log "App ID not specified and running in quiet mode" -Level Error -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        $AppId = Read-Host "  Enter Steam Application ID"

        if (-not $AppId -or $AppId -notmatch '^\d+$') {
            Write-Log "Invalid App ID. Please enter a numeric value." -Level Error -ForegroundColor Red
            $AppId = $null
        }
    }

    Write-Log ("Processing Application ID: $AppId") -Level Info

    Write-Log "Locating Steam installation..." -Level Info
    $steamPath = Get-SteamPath

    if (-not $steamPath) {
        Write-Log "Steam installation not found" -Level Error -ForegroundColor Red
        Exit-WithPrompt
    }

    Write-Log ("Steam installation found: $steamPath") -Level Info -ForegroundColor Green

    $luaPath = Join-Path $steamPath "config\stplug-in\$AppId.lua"
    Write-Log ("Checking Lua configuration: $luaPath") -Level Debug

    if (-not (Test-Path $luaPath)) {
        Write-Log ("Lua configuration not found for App ID $AppId") -Level Error -ForegroundColor Red
        Write-Log ("Expected location: $luaPath") -Level Info
        Exit-WithPrompt
    }

    Write-Log "Parsing depot IDs from Lua configuration..." -Level Info
    $depotIds = Get-DepotIdsFromLua -LuaPath $luaPath

    if ($depotIds.Count -eq 0) {
        Write-Log "No depot IDs found in Lua configuration" -Level Error -ForegroundColor Red
        Exit-WithPrompt
    }

    Write-Log ("Found " + $depotIds.Count + " depot IDs") -Level Info -ForegroundColor Green

    if (-not $Quiet) {
        Write-Divider
        Write-Host "  │ DEPOT IDS FOUND" -ForegroundColor DarkGray
        Write-Divider
        $depotList = ($depotIds -join ", ")
        if ($depotList.Length -gt 55) {
            $depotList = $depotList.Substring(0, 52) + "..."
        }
        Write-Host ("  │ " + $depotList.PadRight(60) + "│") -ForegroundColor White
        Write-Divider
        Write-Host ""
    }

    Write-Log "Fetching application information from SteamCMD API..." -Level Info
    $appInfo = Get-AppInfo -AppId $AppId

    if (-not $appInfo) {
        Write-Log "Failed to retrieve application information" -Level Error -ForegroundColor Red
        Exit-WithPrompt
    }

    Write-Log "Building download queue..." -Level Info
    $downloadQueue = New-Object System.Collections.Generic.List[PSObject]

    foreach ($depotId in $depotIds) {
        $manifestId = Get-ManifestIdForDepot -AppInfo $appInfo -AppId $AppId -DepotId $depotId

        if ($manifestId) {
            $downloadQueue.Add([PSCustomObject]@{
                DepotId = $depotId
                ManifestId = $manifestId
            })
            Write-Log ("Queued depot $depotId with manifest $manifestId") -Level Debug
        } else {
            Write-Log ("No manifest available for depot $depotId") -Level Warning
        }
    }

    if ($downloadQueue.Count -eq 0) {
        Write-Log "No depots with available manifests found" -Level Error -ForegroundColor Red
        Exit-WithPrompt
    }

    Write-Log ("$($downloadQueue.Count) depots queued for download") -Level Info -ForegroundColor Green

    $depotCachePath = if ($OutputDirectory) {
        $OutputDirectory
    } else {
        Join-Path $steamPath "depotcache"
    }

    if (-not (Test-Path $depotCachePath)) {
        New-Item -ItemType Directory -Path $depotCachePath -Force | Out-Null
        Write-Log ("Created output directory: $depotCachePath") -Level Debug
    }

    Write-Log ("Output directory: $depotCachePath") -Level Info

    if (-not $Quiet) {
        Write-Host ""
        Write-Divider
        Write-Host "  │ AARYAN CHEATS - DOWNLOADING MANIFESTS" -ForegroundColor Cyan
        Write-Divider
        Write-Host ""
    }

    $successCount = 0
    $skippedCount = 0
    $fallbackCount = 0
    $failedDepots = New-Object System.Collections.Generic.List[PSObject]
    $totalSize = 0
    $startTime = Get-Date

    for ($i = 0; $i -lt $downloadQueue.Count; $i++) {
        $item = $downloadQueue[$i]
        $depotId = $item.DepotId
        $manifestId = $item.ManifestId

        if (-not $Quiet) {
            Write-ProgressBar -Current $i -Total $downloadQueue.Count -Label "Overall Progress" -Color Cyan
            Write-Host ""
            Write-Host ""
        }

        $existingFile = Join-Path $depotCachePath "${depotId}_${manifestId}.manifest"
        if (Test-Path $existingFile) {
            $existingSize = (Get-Item $existingFile).Length
            if ($existingSize -gt 0) {
                $skippedCount++
                Write-Log ("Depot $depotId : File already exists and is valid (" + (Format-FileSize -Bytes $existingSize) + ")") -Level Info
                if (-not $Quiet) {
                    Write-Host ("  [SKIP] Depot $depotId - File is current (" + (Format-FileSize -Bytes $existingSize) + ")") -ForegroundColor DarkCyan
                }
                continue
            }
        }

        if (-not $Quiet) {
            Write-Divider
            Write-Host ("  │ Processing Depot: $depotId") -ForegroundColor Yellow
            Write-Host ("  │ Manifest ID: $manifestId") -ForegroundColor White
            Write-Divider
        }

        $result = Download-Manifest -DepotId $depotId -ManifestId $manifestId -OutputPath $depotCachePath -Mode $resolvedMode -ApiKey $activeApiKey -RetryCount $RetryCount -RetryDelay $RetryDelay -Timeout $Timeout

        if ($result.Success) {
            $successCount++
            $totalSize += $result.Size

            if ($result.IsFallback) {
                $fallbackCount++
            }

            $sourceLabel = if ($result.IsFallback) { ("via " + $result.Source + " fallback") } else { ("from " + $result.Source) }
            $sizeStr = Format-FileSize -Bytes $result.Size
            $attemptInfo = if ($result.Attempts -gt 1) { (" (" + $result.Attempts + " attempts)") } else { "" }

            Write-Log ("Depot $depotId : Downloaded successfully $sourceLabel ($sizeStr)$attemptInfo") -Level Info
            if (-not $Quiet) {
                Write-Host ("  [OK]   Depot $depotId - Downloaded $sourceLabel ($sizeStr)$attemptInfo") -ForegroundColor Green
            }
        } else {
            $failedDepots.Add([PSCustomObject]@{
                DepotId = $depotId
                ManifestId = $manifestId
                Error = $result.Error
            })
            Write-Log ("Depot $depotId : Download failed - " + $result.Error) -Level Error
            if (-not $Quiet) {
                Write-Host ("  [FAIL] Depot $depotId - " + $result.Error) -ForegroundColor Red
            }
        }
    }

    if (-not $Quiet) {
        Write-Host ""
        Write-ProgressBar -Current $downloadQueue.Count -Total $downloadQueue.Count -Label "Overall Progress" -Color Cyan
        Write-Host ""
    }

    $endTime = Get-Date
    $elapsed = $endTime - $startTime

    if (-not $Quiet) {
        Write-Host ""
        Write-Divider
        Write-Host "  │ AARYAN CHEATS - DOWNLOAD SUMMARY" -ForegroundColor Cyan
        Write-Divider
        Write-Host "  │ STATUS" -ForegroundColor White
        Write-Host "  │"
        Write-Host ("  │   Successful:   $successCount depots") -ForegroundColor Green
        Write-Host ("  │   Skipped:      $skippedCount depots (up-to-date)") -ForegroundColor DarkCyan
        if ($fallbackCount -gt 0) {
            Write-Host ("  │   Fallback:     $fallbackCount depots (retrieved from secondary source)") -ForegroundColor Yellow
        }
        $failedColor = if ($failedDepots.Count -gt 0) { "Red" } else { "Green" }
        Write-Host ("  │   Failed:       " + $failedDepots.Count + " depots") -ForegroundColor $failedColor
        Write-Host "  │"
        Write-Host ("  │   Total Size:   " + (Format-FileSize -Bytes $totalSize)) -ForegroundColor White
        Write-Host ("  │   Time Elapsed: " + $elapsed.ToString('mm\:ss')) -ForegroundColor White
        Write-Host "  │"
        Write-Host "  │ OUTPUT" -ForegroundColor White
        Write-Host ("  │   Directory: $depotCachePath") -ForegroundColor White
        Write-Divider

        if ($failedDepots.Count -gt 0) {
            Write-Host ""
            Write-Host "  ┌─────────────────────────────────────────────────────────────┐" -ForegroundColor Red
            Write-Host "  │              AARYAN CHEATS - FAILED DOWNLOADS               │" -ForegroundColor Red
            Write-Host "  ├─────────────────────────────────────────────────────────────┤" -ForegroundColor DarkGray
            foreach ($failed in $failedDepots) {
                $errorMsg = $failed.Error
                if ($errorMsg.Length -gt 55) { $errorMsg = $errorMsg.Substring(0, 52) + "..." }
                Write-Host ("  │  Depot " + $failed.DepotId + " -> " + $errorMsg).PadRight(61) -ForegroundColor Red
            }
            Write-Host "  └─────────────────────────────────────────────────────────────┘" -ForegroundColor Red
        }
    } else {
        Write-Log ("Download complete: $successCount succeeded, $skippedCount skipped, " + $failedDepots.Count + " failed") -Level Info
        Write-Log ("Total size: " + (Format-FileSize -Bytes $totalSize)) -Level Info
        Write-Log ("Time elapsed: " + $elapsed.ToString('mm\:ss')) -Level Info
    }

    if (-not $Quiet) {
        Write-Host ""
        Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }

    exit 0

} catch {
    Write-Log ("Unhandled exception: " + $_.Exception.Message) -Level Error -ForegroundColor Red
    Write-Log ("Stack trace: " + $_.ScriptStackTrace) -Level Debug
    if (-not $Quiet) {
        Exit-WithPrompt
    }
    exit 1
}
#endregion
