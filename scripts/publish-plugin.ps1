# Publish one plugin from WIP dist/ into KKT-Catalog (zip + icon + manifest merge).
param(
    [Parameter(Mandatory)]
    [string]$InternalName,
    [string]$CatalogRoot = (Join-Path $PSScriptRoot ".."),
    [string]$DistDir,
    [switch]$SkipGlobal,
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lib\CatalogHelpers.ps1"

function Exit-CatalogError {
    param([int]$Code, [string]$Message)
    Write-Error $Message
    exit $Code
}

try {
    $CatalogRoot = [System.IO.Path]::GetFullPath($CatalogRoot)
    $catalog = Read-CatalogConfig -CatalogRoot $CatalogRoot
    $plugin = Get-CatalogPlugin -Catalog $catalog -InternalName $InternalName

    $assemblyName = $plugin.assemblyName
    $pluginFolder = $plugin.pluginFolder
    $wipRoot = $plugin.workInProgressPath

    if (-not $wipRoot -or -not (Test-Path $wipRoot)) {
        Exit-CatalogError 1 "workInProgressPath not found for '$InternalName': $wipRoot"
    }

    if (-not $DistDir) {
        $DistDir = Join-Path $wipRoot "dist"
    }

    $helpersPath = Join-Path $wipRoot "scripts\lib\PublishHelpers.ps1"
    if (-not (Test-Path $helpersPath)) {
        Exit-CatalogError 1 "PublishHelpers.ps1 not found: $helpersPath"
    }

    . $helpersPath

    $cnZipSrc = Join-Path $DistDir "cn\latest.zip"
    if (-not (Test-Path $cnZipSrc)) {
        Exit-CatalogError 1 "CN zip not found: $cnZipSrc. Run the plugin's build-dual.ps1 first."
    }

    $publishGlobal = ($plugin.publishGlobal -ne $false) -and -not $SkipGlobal
    $globalZipSrc = Join-Path $DistDir "global\latest.zip"
    $hasGlobal = $publishGlobal -and (Test-Path $globalZipSrc)

    $pluginsDir = Join-Path $CatalogRoot "plugins\$pluginFolder"
    $imagesDir = Join-Path $CatalogRoot "images\$pluginFolder"
    $cnZipDest = Join-Path $pluginsDir "latest-cn.zip"
    $globalZipDest = Join-Path $pluginsDir "latest-global.zip"
    $iconDest = Join-Path $imagesDir "icon.png"

    $baseRaw = Get-RawBaseUrl -Catalog $catalog
    $zipCnUrl = "$baseRaw/plugins/$pluginFolder/latest-cn.zip"
    $zipGlobalUrl = "$baseRaw/plugins/$pluginFolder/latest-global.zip"
    $iconUrl = "$baseRaw/images/$pluginFolder/icon.png"

    Write-Host ""
    Write-Host "=== Publish $InternalName to KKT-Catalog ===" -ForegroundColor Cyan
    Write-Host "Catalog: $CatalogRoot"
    Write-Host "WIP:     $wipRoot"
    Write-Host "Dist:    $DistDir"

    $cnVersion = Assert-ValidPluginZip -ZipPath $cnZipSrc -AssemblyName $assemblyName
    if (-not $cnVersion) {
        Exit-CatalogError 2 "Could not read AssemblyVersion from CN zip."
    }
    Write-Host "CN AssemblyVersion: $cnVersion" -ForegroundColor Green

    if ($hasGlobal) {
        $globalVersion = Assert-ValidPluginZip -ZipPath $globalZipSrc -AssemblyName $assemblyName
        if ($globalVersion -and $globalVersion -ne $cnVersion) {
            Exit-CatalogError 2 "CN/Global AssemblyVersion mismatch: $cnVersion vs $globalVersion"
        }
        Write-Host "Global AssemblyVersion: $globalVersion" -ForegroundColor Green
    } elseif ($publishGlobal) {
        Write-Warning "Global zip not found; only latest-cn.zip will be published."
    }

    $draftCn = Read-PluginDraftEntry -DraftPath (Join-Path $wipRoot "pluginmaster.cn.json") -InternalName $InternalName
    $draftGlobal = Read-PluginDraftEntry -DraftPath (Join-Path $wipRoot "pluginmaster.global.json") -InternalName $InternalName

    $cnItem = [PSCustomObject]@{}
    $draftCn.PSObject.Properties | ForEach-Object { $cnItem | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value }
    $globalItem = [PSCustomObject]@{}
    $draftGlobal.PSObject.Properties | ForEach-Object { $globalItem | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value }

    $cnItem.AssemblyVersion = $cnVersion
    $globalItem.AssemblyVersion = $cnVersion
    $cnItem.RepoUrl = $plugin.sourceRepoUrl
    $globalItem.RepoUrl = $plugin.sourceRepoUrl
    $cnItem.InternalName = $InternalName
    $globalItem.InternalName = $InternalName

    $cnItem.DownloadLinkInstall = $zipCnUrl
    $cnItem.DownloadLinkUpdate = $zipCnUrl
    $cnItem.DownloadLinkTesting = $zipCnUrl
    $cnItem.IconUrl = $iconUrl

    $globalItem.DownloadLinkInstall = if ($hasGlobal) { $zipGlobalUrl } else { $zipCnUrl }
    $globalItem.DownloadLinkUpdate = $globalItem.DownloadLinkInstall
    $globalItem.DownloadLinkTesting = $globalItem.DownloadLinkInstall
    $globalItem.IconUrl = $iconUrl

    Set-EntryLastUpdate -Entry $cnItem
    Set-EntryLastUpdate -Entry $globalItem

    $iconSrc = Resolve-PluginIconSource -WorkInProgressPath $wipRoot -PluginFolder $pluginFolder
    if (-not $iconSrc) {
        Exit-CatalogError 1 "Plugin icon not found under $wipRoot\images\"
    }

    if ($WhatIf) {
        Write-Host "[WhatIf] Would copy CN zip -> $cnZipDest"
        if ($hasGlobal) { Write-Host "[WhatIf] Would copy Global zip -> $globalZipDest" }
        Write-Host "[WhatIf] Would copy icon -> $iconDest"
        Write-Host "[WhatIf] Would merge pluginmaster.cn.json / pluginmaster.global.json"
        exit 0
    }

    New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null
    New-Item -ItemType Directory -Force -Path $imagesDir | Out-Null

    Copy-Item -Force $cnZipSrc $cnZipDest
    Write-Host "Copied CN zip -> $cnZipDest" -ForegroundColor Green

    if ($hasGlobal) {
        Copy-Item -Force $globalZipSrc $globalZipDest
        Write-Host "Copied Global zip -> $globalZipDest" -ForegroundColor Green
    }

    Copy-Item -Force $iconSrc $iconDest
    Write-Host "Copied icon -> $iconDest" -ForegroundColor Green

    $masterCn = Join-Path $CatalogRoot "pluginmaster.cn.json"
    $masterGlobal = Join-Path $CatalogRoot "pluginmaster.global.json"
    Merge-PluginMasterEntry -Path $masterCn -Entry $cnItem -InternalName $InternalName
    Merge-PluginMasterEntry -Path $masterGlobal -Entry $globalItem -InternalName $InternalName
    Write-Host "Merged manifest entries for $InternalName" -ForegroundColor Green

    Write-Host ""
    Write-Host "Catalog publish ready: $CatalogRoot" -ForegroundColor Green
    Write-Host "CN install URL:     $baseRaw/pluginmaster.cn.json"
    Write-Host "Global install URL: $baseRaw/pluginmaster.global.json"
    Write-Host ""
    Write-Host "Next:"
    Write-Host "  cd `"$CatalogRoot`""
    Write-Host "  git add catalog.json pluginmaster.cn.json pluginmaster.global.json plugins/$pluginFolder/*.zip images/$pluginFolder/icon.png"
    Write-Host "  git commit -m `"Release $InternalName $cnVersion`""
    Write-Host "  git push"
}
catch {
    if ($_.Exception.Message -match 'zip|IconUrl|AssemblyVersion|manifest') {
        Exit-CatalogError 2 $_.Exception.Message
    }
    if ($_.Exception.Message -match 'catalog|Draft|workInProgress|PublishHelpers|icon') {
        Exit-CatalogError 1 $_.Exception.Message
    }
    Exit-CatalogError 3 $_.Exception.Message
}
