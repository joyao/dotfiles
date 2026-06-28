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

    if (Test-Path $Target -PathType Container) {
        Write-Host "Creating junction: $Link -> $Target"
        New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    } else {
        Write-Host "Creating symlink: $Link -> $Target"
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
    }
}

# 1. Deploy tmux config
$tmux_link = Join-Path $home_dir ".tmux.conf"
$tmux_target = Join-Path $dotfiles_dir "tmux\.tmux.conf"
Create-Symlink -Target $tmux_target -Link $tmux_link

# 2. Deploy zsh config
$zshrc_link = Join-Path $home_dir ".zshrc"
$zshrc_target = Join-Path $dotfiles_dir "zsh\.zshrc"
Create-Symlink -Target $zshrc_target -Link $zshrc_link

Write-Host "Deployment complete!" -ForegroundColor Green
