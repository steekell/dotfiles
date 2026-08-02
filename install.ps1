# Start chezmoi only — does NOT configure the machine.
# Machine setup lives in .chezmoiscripts/ (run via chezmoi apply).
#
# Idempotent. Override: $env:DOTFILES_REPO, $env:DOTFILES_REF, $env:CHEZMOI_BIN_DIR
#
#   irm https://raw.githubusercontent.com/steekell/dotfiles/v0.1.19/install.ps1 | iex
#   $env:DOTFILES_REF = 'main'; irm .../install.ps1 | iex

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoUrl = if ($env:DOTFILES_REPO) { $env:DOTFILES_REPO } else { 'https://github.com/steekell/dotfiles.git' }
# Pin to this release by default (override: $env:DOTFILES_REF = 'main').
$DefaultRef = 'v0.1.19'
$Ref = if ($env:DOTFILES_REF) { $env:DOTFILES_REF } else { $DefaultRef }
$BinDir = if ($env:CHEZMOI_BIN_DIR) { $env:CHEZMOI_BIN_DIR } else {
    Join-Path $env:USERPROFILE 'bin'
}

function Write-Info([string]$Message) { Write-Host $Message }

function Request-InstallKanata {
    if ($env:DOTFILES_INSTALL_KANATA) { return }
    $ans = Read-Host 'Install kanata (keyboard remapper)? [y/N]'
    if ($ans -match '^[yY]') {
        $env:DOTFILES_INSTALL_KANATA = '1'
    } else {
        $env:DOTFILES_INSTALL_KANATA = '0'
    }
}

function Ensure-SessionPath {
    # Session only — permanent user PATH is machine config (.chezmoiscripts/windows).
    if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $BinDir })) {
        $env:PATH = "$BinDir;$env:PATH"
    }
}

function Test-Chezmoi {
    return [bool](Get-Command chezmoi -ErrorAction SilentlyContinue)
}

function Install-Chezmoi {
    if (Test-Chezmoi) {
        Write-Info "chezmoi already installed: $((Get-Command chezmoi).Source)"
        return
    }

    Write-Info "installing chezmoi into $BinDir..."
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
    Ensure-SessionPath

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        try {
            winget install --id twpayne.chezmoi -e --accept-source-agreements --accept-package-agreements | Out-Null
            Ensure-SessionPath
            if (Test-Chezmoi) { return }
        } catch {
            Write-Info 'winget install failed; falling back to official installer'
        }
    }

    $installer = Join-Path $env:TEMP 'chezmoi-install.ps1'
    Invoke-RestMethod -Uri 'https://get.chezmoi.io/ps1' -OutFile $installer
    & $installer -b $BinDir
    Ensure-SessionPath
    if (-not (Test-Chezmoi)) {
        throw 'chezmoi install failed'
    }
    Write-Info "chezmoi installed: $((Get-Command chezmoi).Source)"
}

function Get-SourcePath {
    try {
        $p = & chezmoi source-path 2>$null
        if ($p) { return $p.Trim() }
    } catch {}
    return (Join-Path $env:USERPROFILE '.local\share\chezmoi')
}

function Init-OrUpdate {
    $sp = Get-SourcePath
    $gitDir = Join-Path $sp '.git'

    if (Test-Path $gitDir) {
        Write-Info "existing chezmoi source at $sp — updating (ref=$Ref)..."
        if (Get-Command git -ErrorAction SilentlyContinue) {
            Push-Location $sp
            try {
                & git remote get-url origin 2>$null | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    & git remote add origin $RepoUrl 2>$null
                }
                & git fetch --tags origin 2>$null
                if ($LASTEXITCODE -ne 0) { & git fetch origin }
                & git rev-parse --verify "refs/tags/$Ref" 2>$null | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    & git checkout -q "tags/$Ref"
                } else {
                    & git rev-parse --verify "refs/remotes/origin/$Ref" 2>$null | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        & git checkout -q -B $Ref "origin/$Ref"
                    } else {
                        Write-Info "warning: ref '$Ref' not found; applying current source"
                    }
                }
            } finally {
                Pop-Location
            }
        }
        & chezmoi apply --keep-going
        return
    }

    Write-Info "initializing chezmoi from $RepoUrl (ref=$Ref)..."
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw 'git is required for chezmoi init'
    }
    & chezmoi init --apply --branch $Ref $RepoUrl
}

Request-InstallKanata
Write-Info "dotfiles install — start chezmoi only (repo=$RepoUrl ref=$Ref)"
Ensure-SessionPath
Install-Chezmoi
Init-OrUpdate
Write-Info 'done. machine config was applied by chezmoi scripts (if any).'
Write-Info 'open a new terminal if PATH still misses user bin.'
