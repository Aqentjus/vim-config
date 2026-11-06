# Native Windows Vim installer. Nothing is linked to the Git checkout.
# Requirements: Vim >= 9.0.0438, Node.js >= 22.15, npm and Git.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

foreach ($tool in @('vim', 'node', 'npm', 'git')) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "Missing $tool. Install it and put it on PATH first."
    }
}
& vim -Nu NONE -n -es -c "if !has('patch-9.0.0438') | cquit 1 | endif" -c 'qa!'
if ($LASTEXITCODE -ne 0) { throw 'coc.nvim requires Vim 9.0.0438 or newer.' }
$nodeVersion = (& node -p 'process.versions.node').Trim()
if ([version]$nodeVersion -lt [version]'22.15.0') {
    throw "coc.nvim requires Node.js 22.15.0 or newer (found $nodeVersion)."
}

$repo = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$sourceRoot = Join-Path $repo 'config'
$root = Join-Path $HOME '.vim-config'
$target = Join-Path $HOME '_vimrc'
foreach ($source in @('vimrc', 'coc-settings.json', 'colors/gruvbox.vim')) {
    if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot $source) -PathType Leaf)) {
        throw "Incomplete checkout: config/$source is missing."
    }
}
New-Item -ItemType Directory -Path (Join-Path $root 'pack/coc/start') -Force | Out-Null
$plugin = Join-Path $root 'pack/coc/start/coc.nvim'
if (Test-Path -LiteralPath $plugin) {
    if (-not (Test-Path -LiteralPath (Join-Path $plugin 'plugin/coc.vim') -PathType Leaf)) {
        throw "Existing coc.nvim installation appears incomplete: $plugin"
    }
    Write-Host "Keeping installed coc.nvim: $plugin"
} else {
    $temporaryPlugin = Join-Path $root ("pack/coc/start/.coc.nvim.install.$PID")
    try {
        & git clone --depth 1 --branch release 'https://github.com/neoclide/coc.nvim.git' $temporaryPlugin
        if ($LASTEXITCODE -ne 0) { throw 'coc.nvim clone failed.' }
        Move-Item -LiteralPath $temporaryPlugin -Destination $plugin
    } catch {
        if (Test-Path -LiteralPath $temporaryPlugin) {
            Remove-Item -LiteralPath $temporaryPlugin -Recurse -Force
        }
        throw
    }
    Write-Host "Installed coc.nvim: $plugin"
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $root "backups/$stamp"
$index = 1
while (Test-Path -LiteralPath $backupRoot) {
    $backupRoot = Join-Path $root "backups/$stamp.$index"
    $index++
}

function Copy-ManagedFile([string]$source, [string]$destination, [string]$backupName) {
    $existing = Get-Item -LiteralPath $destination -Force -ErrorAction SilentlyContinue
    if ($null -ne $existing -and $existing.PSIsContainer) {
        throw "Refusing to replace a directory: $destination"
    }
    if ($null -ne $existing -and
        -not ($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -and
        (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -eq
        (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash) {
        return
    }
    New-Item -ItemType Directory -Path (Split-Path -Path $destination -Parent) -Force | Out-Null
    $temporaryFile = "$destination.install.$PID"
    Copy-Item -LiteralPath $source -Destination $temporaryFile -Force
    $backup = Join-Path $backupRoot $backupName
    $movedOld = $false
    try {
        if ($null -ne $existing) {
            New-Item -ItemType Directory -Path (Split-Path -Path $backup -Parent) -Force | Out-Null
            Move-Item -LiteralPath $destination -Destination $backup
            $movedOld = $true
        }
        Move-Item -LiteralPath $temporaryFile -Destination $destination
    } catch {
        if (Test-Path -LiteralPath $temporaryFile) { Remove-Item -LiteralPath $temporaryFile -Force }
        if ($movedOld -and -not (Test-Path -LiteralPath $destination)) {
            Move-Item -LiteralPath $backup -Destination $destination
        }
        throw
    }
    if ($movedOld) { Write-Host "Backed up previous file: $backup" }
    Write-Host "Installed: $destination"
}

Copy-ManagedFile (Join-Path $sourceRoot 'vimrc') $target '_vimrc'
foreach ($folder in @('colors', 'extensions')) {
    Get-ChildItem -LiteralPath (Join-Path $sourceRoot $folder) -File -Recurse | ForEach-Object {
        $relative = $_.FullName.Substring($sourceRoot.Length + 1)
        Copy-ManagedFile $_.FullName (Join-Path $root $relative) $relative
    }
}
$cocSettings = Join-Path $root 'coc-settings.json'
if (-not (Test-Path -LiteralPath $cocSettings)) {
    Copy-ManagedFile (Join-Path $sourceRoot 'coc-settings.json') $cocSettings 'coc-settings.json'
} else {
    Write-Host 'Keeping existing coc-settings.json; custom settings are preserved.'
}

Write-Host ''
Write-Host 'Installed. You can now move or delete the Git checkout.'
Write-Host 'On first Vim start, CoC installs coc-clangd and coc-pyright (internet required).'
Write-Host 'In Vim run :CocInfo to check completion and language servers.'
