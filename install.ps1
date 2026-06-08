<#
.SYNOPSIS
  Installs OpenCode + Oh My OpenCode dotfiles to ~/.config/opencode
.DESCRIPTION
  Copies configuration files from this repo's opencode/ directory
  to the OpenCode config directory at $env:USERPROFILE\.config\opencode.
#>

$ErrorActionPreference = "Stop"

$sourceDir = Join-Path $PSScriptRoot "opencode"
$targetDir = "$env:USERPROFILE\.config\opencode"

# --- Create target directory if needed ---
Write-Host "==> Ensuring target directory exists..." -ForegroundColor Cyan
if (-not (Test-Path -LiteralPath $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Write-Host "    Created $targetDir" -ForegroundColor Yellow
} else {
    Write-Host "    $targetDir already exists" -ForegroundColor Green
}

# --- Copy config files ---
$files = @("opencode.jsonc", "oh-my-openagent.json", "tui.json", "package.json")

Write-Host "`n==> Copying configuration files..." -ForegroundColor Cyan
foreach ($file in $files) {
    $src = Join-Path $sourceDir $file
    $dst = Join-Path $targetDir $file

    if (Test-Path -LiteralPath $src) {
        Copy-Item -LiteralPath $src -Destination $dst -Force
        Write-Host "    Copied $file" -ForegroundColor Green
    } else {
        Write-Warning "    Source file not found: $src"
    }
}

Write-Host "`n==> Installing dependencies..." -ForegroundColor Cyan
Push-Location -LiteralPath $targetDir
try {
    npm install --silent
    Write-Host "    Dependencies installed" -ForegroundColor Green
} finally {
    Pop-Location
}

Write-Host "`n==> Done! OpenCode configuration has been installed." -ForegroundColor Cyan
Write-Host "    Restart OpenCode for the changes to take effect." -ForegroundColor Green
