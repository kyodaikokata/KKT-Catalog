# Sync WorkInProgress plugin source into the local GitHub mirror clone (source repo).
param(
    [Parameter(Mandatory)]
    [string]$InternalName,
    [string]$CatalogRoot = (Join-Path $PSScriptRoot ".."),
    [string]$WorkInProgressRoot,
    [string]$SourceRepoRoot,
    [string]$DistDir,
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lib\CatalogHelpers.ps1"

function Exit-SourceSyncError {
    param([int]$Code, [string]$Message)
    Write-Error $Message
    exit $Code
}

try {
    $CatalogRoot = [System.IO.Path]::GetFullPath($CatalogRoot)
    $catalog = Read-CatalogConfig -CatalogRoot $CatalogRoot
    $plugin = Get-CatalogPlugin -Catalog $catalog -InternalName $InternalName

    $wipRoot = Resolve-PluginWorkRoot `
        -CatalogRoot $CatalogRoot `
        -Plugin $plugin `
        -WorkInProgressRoot $WorkInProgressRoot `
        -DistDir $DistDir

    $sourceRoot = Resolve-SourceRepoRoot `
        -CatalogRoot $CatalogRoot `
        -Plugin $plugin `
        -SourceRepoRoot $SourceRepoRoot

    $projectSubPath = if ($plugin.projectSubPath) { $plugin.projectSubPath } else { $plugin.assemblyName }
    $assemblyName = $plugin.assemblyName
    # csproj / source manifest basename may differ from assembly output (e.g. HeelsToggle.csproj -> HeelsDesignLinker.dll)
    $projectFileBase = if ($plugin.projectFileBase) { $plugin.projectFileBase } else { $assemblyName }

    Write-Host ""
    Write-Host "=== Sync source repo: $InternalName ===" -ForegroundColor Cyan
    Write-Host "WIP:    $wipRoot"
    Write-Host "Source: $sourceRoot"

    $version = $null
    if ($DistDir) {
        $helpersPath = Join-Path $wipRoot "scripts\lib\PublishHelpers.ps1"
        if (Test-Path $helpersPath) {
            . $helpersPath
            $cnZip = Join-Path $DistDir "cn\latest.zip"
            if (Test-Path $cnZip) {
                $version = Assert-ValidPluginZip -ZipPath $cnZip -AssemblyName $assemblyName
            }
        }
    }

    $copied = 0
    $projectSrc = Join-Path $wipRoot $projectSubPath
    $projectDst = Join-Path $sourceRoot $projectSubPath
    if (-not (Test-Path $projectSrc)) {
        Exit-SourceSyncError 1 "Project directory not found under WIP: $projectSrc"
    }

    $copied += Copy-WipTreeToSourceRepo -SourceRoot $projectSrc -DestinationRoot $projectDst -WhatIf:$WhatIf

    $imagesSrc = Join-Path $wipRoot "images"
    if (Test-Path $imagesSrc) {
        $copied += Copy-WipTreeToSourceRepo `
            -SourceRoot $imagesSrc `
            -DestinationRoot (Join-Path $sourceRoot "images") `
            -WhatIf:$WhatIf
    }

    $scriptsSrc = Join-Path $wipRoot "scripts"
    if (Test-Path $scriptsSrc) {
        $copied += Copy-WipTreeToSourceRepo `
            -SourceRoot $scriptsSrc `
            -DestinationRoot (Join-Path $sourceRoot "scripts") `
            -WhatIf:$WhatIf
    }

    $rootFiles = @(
        "*.sln",
        "README.md",
        "KNOWN_ISSUES.md",
        "DESIGN.md",
        "LICENSE",
        ".gitignore",
        ".gitattributes",
        "pluginmaster.cn.json",
        "pluginmaster.global.json",
        "sync.py"
    )

    foreach ($pattern in $rootFiles) {
        Get-ChildItem -Path $wipRoot -Filter $pattern -File -ErrorAction SilentlyContinue | ForEach-Object {
            $target = Join-Path $sourceRoot $_.Name
            if ($WhatIf) {
                Write-Host "[WhatIf] $($_.FullName) -> $target"
            } else {
                Copy-Item -LiteralPath $_.FullName -Destination $target -Force
                $copied++
            }
        }
    }

    $required = @(
        (Join-Path $sourceRoot "$projectSubPath\$projectFileBase.csproj"),
        (Join-Path $sourceRoot "$projectSubPath\$projectFileBase.json")
    )

    $icon = Resolve-PluginIconSource -WorkInProgressPath $wipRoot -PluginFolder $plugin.pluginFolder
    if ($icon) {
        $iconRel = $icon.Substring($wipRoot.Length).TrimStart("\", "/")
        $required += Join-Path $sourceRoot $iconRel
    }

    if ($plugin.syncRequiredFiles) {
        foreach ($rel in @($plugin.syncRequiredFiles)) {
            $required += Join-Path $sourceRoot ($rel -replace "/", "\")
        }
    }

    if (-not $WhatIf) {
        $marker = @{
            syncedAt = (Get-Date).ToUniversalTime().ToString("o")
            source   = $wipRoot
            filesCopied = $copied
            assemblyVersion = $version
        } | ConvertTo-Json -Depth 4

        [System.IO.File]::WriteAllText(
            (Join-Path $sourceRoot ".sync-complete"),
            $marker,
            [System.Text.UTF8Encoding]::new($false)
        )
    }

    Write-Host "Synced $copied file(s) into source repo." -ForegroundColor Green

    foreach ($path in $required) {
        $ok = $WhatIf -or (Test-Path $path)
        Write-Host "  $(if ($ok) { 'OK' } else { 'MISSING' }): $path" -ForegroundColor $(if ($ok) { "Green" } else { "Red" })
        if (-not $ok) {
            Exit-SourceSyncError 2 "Required source file missing after sync: $path"
        }
    }

    if ($WhatIf) {
        Write-Host "[WhatIf] Would write .sync-complete and print git commands." -ForegroundColor Yellow
        exit 0
    }

    Write-Host ""
    Write-Host "Next (source repo):" -ForegroundColor Green
    Write-Host "  cd `"$sourceRoot`""
    $commitLabel = if ($version) { "$InternalName $version" } else { $InternalName }
    Write-Host "  git add -A"
    Write-Host "  git commit -m `"Sync $commitLabel from WIP`""
    Write-Host "  git push"
}
catch {
    if ($_.Exception.Message -match 'catalog|WIP|source repo|Sync source|Required source') {
        Exit-SourceSyncError 1 $_.Exception.Message
    }
    Exit-SourceSyncError 3 $_.Exception.Message
}
