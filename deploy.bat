@echo off
setlocal

set "DOTFILES_DIR=%~dp0"
:: Remove trailing backslash if present
if "%DOTFILES_DIR:~-1%"=="\" set "DOTFILES_DIR=%DOTFILES_DIR:~0,-1%"

set "HOME_DIR=%USERPROFILE%"

echo Deploying dotfiles from %DOTFILES_DIR% to %HOME_DIR%...

:: 1. Deploy tmux config
call :CreateSymlink "%DOTFILES_DIR%\tmux\.tmux.conf" "%HOME_DIR%\.tmux.conf"

:: 2. Deploy zsh config
call :CreateSymlink "%DOTFILES_DIR%\zsh\.zshrc" "%HOME_DIR%\.zshrc"

:: 3. Deploy Gemini guidelines
if not exist "%HOME_DIR%\.gemini" (
    echo Creating directory: %HOME_DIR%\.gemini
    mkdir "%HOME_DIR%\.gemini"
)
call :CreateSymlink "%DOTFILES_DIR%\gemini\GEMINI.md" "%HOME_DIR%\.gemini\GEMINI.md"

echo Deployment complete!
goto :eof

:CreateSymlink
set "TARGET=%~1"
set "LINK=%~2"

:: If a file or link already exists at the target location, back it up
if exist "%LINK%" (
    echo Backing up existing file or link: %LINK%
    move /Y "%LINK%" "%LINK%.backup_%RANDOM%" >nul
)

echo Creating symlink: %LINK% -^> %TARGET%
mklink "%LINK%" "%TARGET%"
goto :eof

:CreateDirectoryJunction
set "TARGET=%~1"
set "LINK=%~2"

:: If a directory or link already exists at the target location, back it up
if exist "%LINK%" (
    echo Backing up existing directory or link: %LINK%
    move /Y "%LINK%" "%LINK%.backup_%RANDOM%" >nul
)

echo Creating directory junction: %LINK% -^> %TARGET%
mklink /j "%LINK%" "%TARGET%"
goto :eof



