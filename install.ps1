# Base install: system Vim only. Optional completion is explicitly requested.
param([switch]$WithCoc, [switch]$Check, [switch]$DryRun)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if (-not (Get-Command vim -ErrorAction SilentlyContinue)) { throw 'Install your system Vim package first.' }
$repo = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$sourceRoot = Join-Path $repo 'config'
$root = Join-Path $HOME '.vim-config'
$target = Join-Path $HOME '_vimrc'
foreach ($source in @('vimrc', 'core/options.vim', 'core/theme.vim', 'core/explorer.vim', 'core/icons.vim', 'core/search.vim', 'core/clipboard.vim', 'core/terminal.vim', 'core/runner.vim', 'core/completion.vim', 'core/help.vim', 'core/doctor.vim', 'core/extensions.vim', 'colors/kanagawa-dragon.vim', 'local.vim.example', 'coc-settings.json')) {
    if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot $source) -PathType Leaf)) { throw "Incomplete checkout: config/$source is missing." }
}
Write-Host "Vim: $((Get-Command vim).Source)"
Write-Host "Config: $root"
if ($WithCoc) {
    foreach ($tool in @('node', 'npm', 'git')) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { throw "Optional CoC needs $tool on PATH." }
    }
    & vim -Nu NONE -i NONE -n -es -c "if !has('patch-9.0.0438') | cquit 1 | endif" -c 'qa!'
    if ($LASTEXITCODE -ne 0) { throw 'Optional CoC needs Vim 9.0.0438+. Omit -WithCoc for the basic editor.' }
    $nodeVersion = (& node -p 'process.versions.node').Trim()
    if ($LASTEXITCODE -ne 0 -or [version]$nodeVersion -lt [version]'22.15.0') { throw 'Optional CoC needs Node 22.15+.' }
} else { Write-Host 'Basic install: no Node, npm, Git, Python, compiler or downloads required.' }
if ($Check) { Write-Host 'Check complete; nothing changed.'; exit 0 }
if ($DryRun) {
    Write-Host "Would copy config modules/themes/extensions to $root and loader to $target."
    Write-Host 'Changed files would be backed up; local.vim and coc-settings.json preserved.'
    if ($WithCoc) { Write-Host 'Would install/enable CoC; no language extensions selected.' }
    exit 0
}
foreach ($directory in @($root, (Join-Path $root 'core'), (Join-Path $root 'colors'), (Join-Path $root 'extensions'))) {
    $item = Get-Item -LiteralPath $directory -Force -ErrorAction SilentlyContinue
    if ($null -ne $item -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) { throw "Use a real configuration directory: $directory" }
}
if ($WithCoc) {
    $plugin = Join-Path $root 'pack/coc/opt/coc.nvim'
    $legacy = Join-Path $root 'pack/coc/start/coc.nvim'
    if (Test-Path -LiteralPath (Join-Path $legacy 'plugin/coc.vim')) { $plugin = $legacy }
    if (Test-Path -LiteralPath $plugin) {
        if (-not (Test-Path -LiteralPath (Join-Path $plugin 'plugin/coc.vim'))) { throw "Incomplete CoC installation: $plugin" }
        Write-Host "Keeping installed CoC: $plugin"
    } else {
        New-Item -ItemType Directory -Path (Split-Path $plugin -Parent) -Force | Out-Null
        $temporaryPlugin = "$plugin.install.$PID"
        try {
            & git clone --depth 1 --branch release 'https://github.com/neoclide/coc.nvim.git' $temporaryPlugin
            if ($LASTEXITCODE -ne 0) { throw 'CoC download failed.' }
            Move-Item -LiteralPath $temporaryPlugin -Destination $plugin
        } catch {
            if (Test-Path -LiteralPath $temporaryPlugin) { Remove-Item -LiteralPath $temporaryPlugin -Recurse -Force }
            throw
        }
    }
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

foreach ($folder in @('core', 'colors', 'extensions')) {
    Get-ChildItem -LiteralPath (Join-Path $sourceRoot $folder) -File -Recurse | Where-Object { $_.Extension -ne '.pyc' } | ForEach-Object {
        $relative = $_.FullName.Substring($sourceRoot.Length + 1)
        Copy-ManagedFile $_.FullName (Join-Path $root $relative) $relative
    }
}
Copy-ManagedFile (Join-Path $sourceRoot 'vimrc') $target '_vimrc'
foreach ($file in @('coc-settings.json', 'local.vim')) {
    $destination = Join-Path $root $file
    if ($null -eq (Get-Item -LiteralPath $destination -Force -ErrorAction SilentlyContinue)) {
        $sourceName = if ($file -eq 'local.vim') { 'local.vim.example' } else { $file }
        Copy-ManagedFile (Join-Path $sourceRoot $sourceName) $destination $file
    } else { Write-Host "Keeping personal $file" }
}
if ($WithCoc) {
    New-Item -ItemType File -Path (Join-Path $root 'completion-enabled') -Force | Out-Null
    Write-Host 'CoC enabled. Choose languages explicitly with :CocInstall extension-name.'
}
Write-Host 'Installed. The checkout can be moved/deleted. Space h: help; :ConfigDoctor: optional tools.'
