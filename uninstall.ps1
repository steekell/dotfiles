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

function Remove-ManagedTargets {
    if (-not (Test-Chezmoi)) {
        Write-Warn 'chezmoi not on PATH — skip managed target removal'
        return
    }
    Resolve-Source
    Write-Info 'removing chezmoi-managed targets...'
    $list = @()
    try {
        $list = & chezmoi managed --include=files,symlinks 2>$null
    } catch {
        $list = @()
    }
    if (-not $list) {
        Write-Info 'no managed files/symlinks reported'
        return
    }
    foreach ($rel in $list) {
        if (-not $rel) { continue }
        $rel = "$rel".Trim()
        if ($rel -match '^[A-Za-z]:\\' -or $rel.StartsWith('\\')) {
            $target = $rel
        } elseif ($rel.StartsWith('/')) {
            # WSL-style path unlikely on native Windows chezmoi
            $target = $rel
        } else {
            $target = Join-Path $env:USERPROFILE ($rel -replace '/', '\')
        }
        if (Test-Path -LiteralPath $target) {
            $item = Get-Item -LiteralPath $target -Force
            if (-not $item.PSIsContainer) {
                Remove-Item -LiteralPath $target -Force
                Write-Info "  removed $target"
            } else {
                try {
                    Remove-Item -LiteralPath $target -Force -ErrorAction Stop
                    Write-Info "  removed dir $target"
                } catch {
                    # non-empty — leave it
                }
            }
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
    if (Test-Path -LiteralPath $manifest) {
        Write-Warn 'packages.manifest present but automatic package removal is not implemented yet'
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
