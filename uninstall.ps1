# Uninstall steekell/dotfiles helpers — Windows PowerShell.
#
#   .\uninstall.ps1
#   .\uninstall.ps1 -ChezmoiOnly
#   .\uninstall.ps1 -Purge
#   .\uninstall.ps1 -Purge -Yes

[CmdletBinding(DefaultParameterSetName = 'Default')]
param(
    [Parameter(ParameterSetName = 'ChezmoiOnly')]
    [switch] $ChezmoiOnly,

    [Parameter(ParameterSetName = 'Purge')]
    [switch] $Purge,

    [Parameter(ParameterSetName = 'Purge')]
    [switch] $Yes
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info([string]$Message) { Write-Host $Message }
function Write-Warn([string]$Message) { Write-Warning $Message }

$StateDir = Join-Path $env:USERPROFILE '.config\dotfiles'
$ChezmoiCfg = Join-Path $env:USERPROFILE '.config\chezmoi'
$ChezmoiSrc = Join-Path $env:USERPROFILE '.local\share\chezmoi'
$ChezmoiCache = Join-Path $env:USERPROFILE '.cache\chezmoi'
$BinCandidate = Join-Path $env:USERPROFILE 'bin\chezmoi.exe'
$BinCandidateNoExt = Join-Path $env:USERPROFILE 'bin\chezmoi'

function Test-Chezmoi { return [bool](Get-Command chezmoi -ErrorAction SilentlyContinue) }

function Resolve-Source {
    if (Test-Chezmoi) {
        try {
            $p = & chezmoi source-path 2>$null
            if ($p) { $script:ChezmoiSrc = $p.Trim() }
        } catch {}
    }
}

function Stop-SetupServices {
    # Placeholder for future services created by bootstrap scripts.
}

function Resolve-ManagedPath([string]$Rel) {
    $Rel = "$Rel".Trim()
    if ($Rel -match '^[A-Za-z]:\\' -or $Rel.StartsWith('\\') -or $Rel.StartsWith('/')) {
        return $Rel
    }
    return Join-Path $env:USERPROFILE ($Rel -replace '/', '\')
}

function Remove-ManagedTargets {
    if (-not (Test-Chezmoi)) {
        Write-Warn 'chezmoi not on PATH — skip managed target removal'
        return
    }
    Resolve-Source
    Write-Info 'removing chezmoi-managed targets...'

    $files = @()
    try { $files = & chezmoi managed --include=files,symlinks 2>$null } catch { $files = @() }
    if (-not $files) {
        Write-Info 'no managed files/symlinks reported'
    } else {
        foreach ($rel in $files) {
            if (-not $rel) { continue }
            $target = Resolve-ManagedPath $rel
            if (Test-Path -LiteralPath $target) {
                $item = Get-Item -LiteralPath $target -Force
                if (-not $item.PSIsContainer) {
                    Remove-Item -LiteralPath $target -Force
                    Write-Info "  removed $target"
                }
            }
        }
    }

    # Directories chezmoi created for those files/symlinks. Never -Recurse:
    # only remove once empty, deepest first, so unmanaged content is kept.
    $dirs = @()
    try { $dirs = & chezmoi managed --include=dirs 2>$null } catch { $dirs = @() }
    if (-not $dirs) { return }
    $sorted = $dirs | Where-Object { $_ } |
        Sort-Object -Descending -Property @{ Expression = { ("$_" -split '[\\/]').Count } }
    foreach ($rel in $sorted) {
        $target = Resolve-ManagedPath $rel
        if (-not (Test-Path -LiteralPath $target)) { continue }
        try {
            Remove-Item -LiteralPath $target -Force -ErrorAction Stop
            Write-Info "  removed empty dir $target"
        } catch {
            Write-Warn "kept non-empty dir $target (contains unmanaged files)"
        }
    }
}

function Remove-Artefacts {
    Write-Info 'removing setup artefacts...'
    if (Test-Path -LiteralPath $StateDir) {
        Remove-Item -LiteralPath $StateDir -Recurse -Force
        Write-Info "  removed $StateDir"
    }
}

function Remove-PackagesFromSetup {
    $manifest = Join-Path $StateDir 'packages.manifest'
    if (-not (Test-Path -LiteralPath $manifest)) { return }

    Write-Info 'removing packages installed by setup...'
    $lines = Get-Content -LiteralPath $manifest | Where-Object { $_ -and -not $_.StartsWith('#') }
    foreach ($line in $lines) {
        $parts = $line.Split(':', 2)
        if ($parts.Count -lt 2) { continue }
        $pm = $parts[0]
        $id = $parts[1]
        switch ($pm) {
            'winget' {
                & winget uninstall --id $id -e --silent 2>$null
                if ($LASTEXITCODE -ne 0) { Write-Warn "winget uninstall failed for: $id" }
            }
            'choco' {
                & choco uninstall $id -y 2>$null
                if ($LASTEXITCODE -ne 0) { Write-Warn "choco uninstall failed for: $id" }
            }
            'scoop' {
                & scoop uninstall $id 2>$null
                if ($LASTEXITCODE -ne 0) { Write-Warn "scoop uninstall failed for: $id" }
            }
            default {
                Write-Warn "unknown package source '$pm' in manifest — remove manually: $id"
            }
        }
    }
}

function Remove-ChezmoiOnly {
    Resolve-Source
    Write-Info 'removing chezmoi source/config/cache (HOME targets left untouched)...'
    foreach ($p in @($ChezmoiSrc, $ChezmoiCfg, $ChezmoiCache, $StateDir)) {
        if (Test-Path -LiteralPath $p) {
            Remove-Item -LiteralPath $p -Recurse -Force
            Write-Info "  removed $p"
        }
    }
    foreach ($b in @($BinCandidate, $BinCandidateNoExt)) {
        if (Test-Path -LiteralPath $b) {
            Remove-Item -LiteralPath $b -Force
            Write-Info "  removed $b"
        }
    }
}

function Confirm-Purge {
    if ($Yes -or $env:DOTFILES_YES -eq '1') { return }
    $ans = Read-Host 'This will remove managed dotfiles AND chezmoi source/config. Continue? [y/N]'
    if ($ans -notmatch '^[yY](es)?$') {
        Write-Info 'aborted'
        exit 1
    }
}

if ($ChezmoiOnly) {
    Write-Info 'uninstall -ChezmoiOnly: source/config/binary; HOME targets kept'
    Remove-ChezmoiOnly
    Write-Info 'done. applied files in HOME were not removed.'
} elseif ($Purge) {
    Confirm-Purge
    Write-Info 'uninstall -Purge: full teardown'
    Stop-SetupServices
    Remove-PackagesFromSetup
    Remove-ManagedTargets
    Remove-Artefacts
    Remove-ChezmoiOnly
    Write-Info 'done.'
} else {
    Write-Info 'uninstall (default): managed targets + artefacts; keep chezmoi'
    Stop-SetupServices
    Remove-PackagesFromSetup
    Remove-ManagedTargets
    Remove-Artefacts
    Write-Info 'done. chezmoi binary and source kept (if present).'
}
