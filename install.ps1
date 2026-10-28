# Install this checkout's Vim configuration for native Windows Vim.
# The loader is a regular file; no administrator privileges or symlinks needed.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
    throw 'Install Vim first and ensure vim.exe is on PATH.'
}

$repo = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$source = Join-Path $repo 'vimrc'
$theme = Join-Path (Join-Path $repo 'colors') 'gruvbox.vim'
if (-not (Test-Path -LiteralPath $source -PathType Leaf) -or
    -not (Test-Path -LiteralPath $theme -PathType Leaf)) {
    throw 'Run this installer from a complete vim-config checkout.'
}

# _vimrc has priority over .vimrc on native Windows Vim.
$target = Join-Path $HOME '_vimrc'
$vimPath = $source.Replace('\', '/').Replace("'", "''")
$loader = "set nocompatible`nset encoding=utf-8`nexecute 'source ' . fnameescape('$vimPath')`n"

function Test-Entry([string]$path) {
    return $null -ne (Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue)
}

if (Test-Entry $target) {
    $old = [System.IO.File]::ReadAllText($target)
    if ($old -eq $loader) {
        Write-Host "Already installed: $target"
        exit 0
    }
}

$backup = $null
if (Test-Entry $target) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = "$target.backup.$stamp"
    $index = 1
    while (Test-Entry $backup) {
        $backup = "$target.backup.$stamp.$index"
        $index++
    }
    Move-Item -LiteralPath $target -Destination $backup
    Write-Host "Previous configuration backed up to: $backup"
}

try {
    # Windows PowerShell's -Encoding UTF8 adds a BOM, so write UTF-8 without BOM.
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($target, $loader, $utf8)
    Write-Host "Installed: $target"
    Write-Host "This loader reads: $source"
    Write-Host 'Future git pull updates this Vim setup on its next launch.'
} catch {
    if ($null -ne $backup) {
        if (Test-Entry $target) { Remove-Item -LiteralPath $target -Force }
        Move-Item -LiteralPath $backup -Destination $target
        Write-Warning 'Restored the previous configuration.'
    }
    throw
}
