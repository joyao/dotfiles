$ErrorActionPreference = "Stop"

$dotfiles_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$home_dir = $env:USERPROFILE

Write-Host "Deploying dotfiles from $dotfiles_dir to $home_dir..." -ForegroundColor Cyan

function Create-Symlink {
    param (
        [string]$Target,
        [string]$Link
    )

    # Check if a file or link already exists at the target location
    if (Test-Path $Link) {
        # Check if it is a symbolic link
        $item = Get-Item $Link
        if ($item.Attributes -match "ReparsePoint") {
            Write-Host "Removing existing symlink: $Link"
            Remove-Item $Link -Force
        } else {
            # If it is a real file, back it up to prevent data loss
            $backup_name = "$Link.backup_" + (Get-Date -Format "yyyyMMdd_HHmmss")
            Write-Host "Backing up existing file $Link to $backup_name" -ForegroundColor Yellow
            Rename-Item -Path $Link -NewName (Split-Path $backup_name -Leaf)
        }
    }

    Write-Host "Creating symlink: $Link -> $Target"
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
}

# 1. Deploy tmux config
$tmux_link = Join-Path $home_dir ".tmux.conf"
$tmux_target = Join-Path $dotfiles_dir "tmux\.tmux.conf"
Create-Symlink -Target $tmux_target -Link $tmux_link

# 2. Deploy zsh config
$zshrc_link = Join-Path $home_dir ".zshrc"
$zshrc_target = Join-Path $dotfiles_dir "zsh\.zshrc"
Create-Symlink -Target $zshrc_target -Link $zshrc_link

# 3. Deploy Antigravity settings
$gemini_dir = Join-Path $home_dir ".gemini"
if (-not (Test-Path $gemini_dir)) {
    Write-Host "Creating directory: $gemini_dir"
    New-Item -ItemType Directory -Path $gemini_dir | Out-Null
}
$gemini_settings_link = Join-Path $gemini_dir "settings.json"
$gemini_settings_target = Join-Path $dotfiles_dir "gemini\settings.json"
Create-Symlink -Target $gemini_settings_target -Link $gemini_settings_link

Write-Host "Deployment complete!" -ForegroundColor Green
