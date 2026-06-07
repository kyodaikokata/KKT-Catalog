function Read-CatalogConfig {
    param(
        [Parameter(Mandatory)]
        [string]$CatalogRoot
    )

    $path = Join-Path $CatalogRoot "catalog.json"
    if (-not (Test-Path $path)) {
        $example = Join-Path $CatalogRoot "catalog.json.example"
        if (Test-Path $example) {
            throw "catalog.json not found: $path. Copy catalog.json.example to catalog.json and set local paths (catalog.json is not pushed to Git)."
        }
        throw "catalog.json not found: $path"
    }

    $catalog = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $catalog.catalogRepo) {
        throw "catalog.json missing catalogRepo"
    }
    if (-not $catalog.plugins) {
        throw "catalog.json missing plugins array"
    }

    return $catalog
}

function Get-DefaultWorkInProgressRoot {
    param(
        [Parameter(Mandatory)]
        [string]$CatalogRoot
    )

    if ($env:KKT_WORK_IN_PROGRESS_ROOT) {
        return $env:KKT_WORK_IN_PROGRESS_ROOT
    }

    # Catalog lives at .../Release/KKT-Catalog -> WIP at .../WorkInProgress (not .../Release/WorkInProgress)
    $releaseRoot = Split-Path $CatalogRoot -Parent
    $projectRoot = Split-Path $releaseRoot -Parent
    return Join-Path $projectRoot "WorkInProgress"
}

function Resolve-PluginWorkRoot {
    param(
        [Parameter(Mandatory)]
        [string]$CatalogRoot,
        [Parameter(Mandatory)]
        [object]$Plugin,
        [string]$WorkInProgressRoot,
        [string]$DistDir
    )

    $candidates = New-Object System.Collections.Generic.List[string]

    if ($WorkInProgressRoot) {
        $candidates.Add($WorkInProgressRoot)
    }

    if ($DistDir) {
        $distFull = [System.IO.Path]::GetFullPath($DistDir)
        if ((Split-Path $distFull -Leaf) -ieq "dist") {
            $candidates.Add((Split-Path $distFull -Parent))
        }
    }

    $defaultWipRoot = Get-DefaultWorkInProgressRoot -CatalogRoot $CatalogRoot
    if ($Plugin.pluginFolder) {
        $candidates.Add((Join-Path $defaultWipRoot $Plugin.pluginFolder))
    }
    if ($Plugin.internalName -and $Plugin.internalName -ne $Plugin.pluginFolder) {
        $candidates.Add((Join-Path $defaultWipRoot $Plugin.internalName))
    }
    if ($Plugin.projectSubPath) {
        $candidates.Add((Join-Path $defaultWipRoot $Plugin.projectSubPath))
    }

    $envName = "KKT_WIP_$($Plugin.internalName)"
    $fromEnv = [Environment]::GetEnvironmentVariable($envName)
    if ($fromEnv) {
        $candidates.Add($fromEnv)
    }

    if ($Plugin.workInProgressPath) {
        $candidates.Add([string]$Plugin.workInProgressPath)
    }

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        $full = [System.IO.Path]::GetFullPath($candidate)
        $helpers = Join-Path $full "scripts\lib\PublishHelpers.ps1"
        if (Test-Path $helpers) {
            return $full
        }
    }

    throw "Could not resolve WIP root for '$($Plugin.internalName)'. Run publish-release.ps1 from WorkInProgress/<Plugin>/, set workInProgressPath in catalog.json, or env $envName / KKT_WORK_IN_PROGRESS_ROOT."
}

function Get-CatalogPlugin {
    param(
        [Parameter(Mandatory)]
        [object]$Catalog,
        [Parameter(Mandatory)]
        [string]$InternalName
    )

    $plugin = @($Catalog.plugins | Where-Object { $_.internalName -eq $InternalName -and $_.enabled -ne $false })
    if ($plugin.Count -ne 1) {
        throw "catalog.json must contain exactly one enabled plugin entry for InternalName '$InternalName'."
    }

    return $plugin[0]
}

function Get-RawBaseUrl {
    param(
        [Parameter(Mandatory)]
        [object]$Catalog
    )

    $branch = if ($Catalog.defaultBranch) { $Catalog.defaultBranch } else { "main" }
    return "https://raw.githubusercontent.com/$($Catalog.catalogRepo)/$branch"
}

function Read-PluginMasterEntries {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return @()
    }

    $raw = (Get-Content $Path -Raw -Encoding UTF8).Trim()
    if (-not $raw) {
        return @()
    }

    $parsed = $raw | ConvertFrom-Json
    if ($parsed -is [System.Array]) {
        return @($parsed)
    }

    return @($parsed)
}

function Merge-PluginMasterEntry {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [object]$Entry,
        [Parameter(Mandatory)]
        [string]$InternalName
    )

    $entries = @(Read-PluginMasterEntries -Path $Path)
    $others = @($entries | Where-Object { $_.InternalName -ne $InternalName })
    $merged = @($others) + @($Entry)
    Write-CatalogPluginMasterArray -Path $Path -Entries $merged
}

function Write-CatalogPluginMasterArray {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [object[]]$Entries
    )

    if ($Entries.Count -eq 0) {
        [System.IO.File]::WriteAllText($Path, "[]`r`n", [System.Text.UTF8Encoding]::new($false))
        return
    }

    if ($Entries.Count -eq 1) {
        $json = ($Entries[0] | ConvertTo-Json -Depth 12)
        [System.IO.File]::WriteAllText($Path, "[`r`n$json`r`n]", [System.Text.UTF8Encoding]::new($false))
        return
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("[")
    for ($i = 0; $i -lt $Entries.Count; $i++) {
        $json = ($Entries[$i] | ConvertTo-Json -Depth 12)
        if ($i -lt $Entries.Count - 1) {
            $lines.Add("$json,")
        } else {
            $lines.Add($json)
        }
    }
    $lines.Add("]")
    [System.IO.File]::WriteAllText($Path, ($lines -join "`r`n") + "`r`n", [System.Text.UTF8Encoding]::new($false))
}

function Set-EntryLastUpdate {
    param(
        [Parameter(Mandatory)]
        [object]$Entry
    )

    $Entry.LastUpdate = [string][int][double]::Parse((Get-Date -Date (Get-Date).ToUniversalTime() -UFormat %s))
}

function Read-PluginDraftEntry {
    param(
        [Parameter(Mandatory)]
        [string]$DraftPath,
        [Parameter(Mandatory)]
        [string]$InternalName
    )

    if (-not (Test-Path $DraftPath)) {
        throw "Plugin manifest draft not found: $DraftPath"
    }

    $entries = @(Read-PluginMasterEntries -Path $DraftPath)
    $match = @($entries | Where-Object { $_.InternalName -eq $InternalName })
    if ($match.Count -eq 1) {
        return $match[0]
    }
    if ($entries.Count -eq 1) {
        return $entries[0]
    }

    throw "Draft manifest '$DraftPath' does not contain an entry for '$InternalName'."
}

function Resolve-PluginIconSource {
    param(
        [Parameter(Mandatory)]
        [string]$WorkInProgressPath,
        [Parameter(Mandatory)]
        [string]$PluginFolder
    )

    $candidates = @(
        (Join-Path $WorkInProgressPath "images\$PluginFolder\icon.png"),
        (Join-Path $WorkInProgressPath "images\icon.png")
    )

    foreach ($path in $candidates) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}
