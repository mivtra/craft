<#
.SYNOPSIS
    Installs, updates or removes Mivtra Craft (free core) for Claude.

.DESCRIPTION
    One command, safe to run again at any time:
      irm https://raw.githubusercontent.com/mivtra/craft/main/install.ps1 | iex

    1. Downloads the latest release and checks it is a valid Claude plugin.
    2. Claude Code found  -> adds the "mivtra" marketplace and installs or updates "mivtra-craft".
    3. Always             -> saves mivtra-craft-<version>.zip in Downloads for the Claude app
                             (claude.ai / desktop: Settings -> Plugins -> Upload).

    With options:
      & ([scriptblock]::Create((irm https://raw.githubusercontent.com/mivtra/craft/main/install.ps1))) -Uninstall
    Options: -Uninstall  -ZipOnly  -NoOpen  -ZipPath <local zip, for testing>

    Works on Windows PowerShell 5.1 and PowerShell 7. Needs no administrator rights.
#>
[CmdletBinding()]
param(
    [switch]$Uninstall,
    [switch]$ZipOnly,
    [switch]$NoOpen,
    [string]$ZipPath
)

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'   # Invoke-WebRequest is 10x slower with the progress bar

$Repo        = 'mivtra/craft'
$Marketplace = 'mivtra'
$Plugin      = 'mivtra-craft'
$ReleaseZip  = "https://github.com/$Repo/releases/latest/download/mivtra-craft.zip"

function Write-Step([string]$Text) { Write-Host "  -> $Text" -ForegroundColor Cyan }
function Write-Ok([string]$Text)   { Write-Host "  [OK] $Text" -ForegroundColor Green }
function Write-Warn([string]$Text) { Write-Host "  [!]  $Text" -ForegroundColor Yellow }
function Stop-Install([string]$Text, [string]$Fix) {
    Write-Host ""
    Write-Host "  [X]  $Text" -ForegroundColor Red
    if ($Fix) { Write-Host "       Fix: $Fix" -ForegroundColor Red }
    Write-Host ""
    throw "Mivtra Craft: $Text"
}

function Find-ClaudeCli {
    $cmd = Get-Command claude -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) { return $cmd.Source }
    $candidates = @(
        (Join-Path $env:USERPROFILE '.local\bin\claude.exe'),
        (Join-Path $env:APPDATA 'npm\claude.cmd')
    )
    foreach ($c in $candidates) { if ($c -and (Test-Path $c)) { return $c } }
    # Claude Code bundled with the Claude desktop app (newest version first)
    $root = Join-Path $env:LOCALAPPDATA 'Claude-Data'
    if (Test-Path $root) {
        $exe = Get-ChildItem $root -Recurse -Filter claude.exe -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match '\\claude-code\\' } |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($exe) { return $exe.FullName }
    }
    return $null
}

function Invoke-Claude([string]$Cli, [string[]]$Arguments) {
    $out = & $Cli @Arguments 2>&1 | Out-String
    return [pscustomobject]@{ Code = $LASTEXITCODE; Text = $out.Trim() }
}

function Get-ReleaseZip {
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("mivtra-craft-" + [guid]::NewGuid().ToString('N') + '.zip')
    if ($ZipPath) {
        if (-not (Test-Path $ZipPath)) { Stop-Install "Local zip not found: $ZipPath" }
        Copy-Item $ZipPath $tmp
        return $tmp
    }
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    } catch { }
    try {
        Invoke-WebRequest -Uri $ReleaseZip -OutFile $tmp -UseBasicParsing
    } catch {
        Stop-Install "Could not download the latest release ($($_.Exception.Message))." `
            "Check the internet connection, or download it from https://github.com/$Repo/releases"
    }
    return $tmp
}

function Read-PluginVersion([string]$Zip) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::OpenRead($Zip)
    try {
        $entry = $archive.Entries | Where-Object { $_.FullName -eq '.claude-plugin/plugin.json' } | Select-Object -First 1
        if (-not $entry) { Stop-Install 'The download is not a valid Claude plugin (no .claude-plugin/plugin.json).' "Report it at https://github.com/$Repo/issues" }
        $reader = New-Object IO.StreamReader($entry.Open(), [Text.Encoding]::UTF8)
        try { $json = $reader.ReadToEnd() | ConvertFrom-Json } finally { $reader.Dispose() }
        $skills = @($archive.Entries | Where-Object { $_.FullName -match '^skills/[^/]+/SKILL\.md$' }).Count
        if ($json.name -ne $Plugin -or $skills -lt 1) { Stop-Install 'The download does not contain the Mivtra Craft skills.' "Report it at https://github.com/$Repo/issues" }
        return [pscustomobject]@{ Version = $json.version; Skills = $skills }
    } finally { $archive.Dispose() }
}

function Get-DownloadsFolder {
    try {
        $p = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
        if ($p -and (Test-Path $p)) { return $p }
    } catch { }
    $p = Join-Path $env:USERPROFILE 'Downloads'
    if (-not (Test-Path $p)) { New-Item -ItemType Directory $p | Out-Null }
    return $p
}

# ---------------------------------------------------------------------------------------------
Write-Host ""
Write-Host "  Mivtra Craft - Arabic-first skills for Claude" -ForegroundColor White
Write-Host "  https://github.com/$Repo" -ForegroundColor DarkGray
Write-Host ""

$cli = $null
if (-not $ZipOnly) { $cli = Find-ClaudeCli }

if ($Uninstall) {
    if (-not $cli) { Stop-Install 'Claude Code was not found, so there is nothing to remove here.' 'In the Claude app: Settings -> Plugins -> mivtra-craft -> Remove.' }
    Write-Step "Removing $Plugin from Claude Code"
    $r = Invoke-Claude $cli @('plugin', 'uninstall', "$Plugin@$Marketplace")
    if ($r.Code -eq 0) { Write-Ok 'Plugin removed' } else { Write-Warn "Plugin was not installed ($($r.Text))" }
    $r = Invoke-Claude $cli @('plugin', 'marketplace', 'remove', $Marketplace)
    if ($r.Code -eq 0) { Write-Ok 'Marketplace removed' } else { Write-Warn "Marketplace was not added ($($r.Text))" }
    Write-Host ""
    Write-Host '  In the Claude app, remove it from Settings -> Plugins as well.' -ForegroundColor DarkGray
    Write-Host ""
    return
}

Write-Step 'Downloading the latest release'
$zip  = Get-ReleaseZip
$info = Read-PluginVersion $zip
Write-Ok "Mivtra Craft $($info.Version) - $($info.Skills) skills, valid plugin"

# 1. Claude Code (CLI, VS Code, JetBrains, desktop Code tab)
if ($cli) {
    Write-Step "Claude Code found: $cli"
    $list = Invoke-Claude $cli @('plugin', 'marketplace', 'list')
    if ($list.Text -match "(?m)\b$Marketplace\b") {
        $r = Invoke-Claude $cli @('plugin', 'marketplace', 'update', $Marketplace)
        if ($r.Code -ne 0) { Stop-Install "Could not update the '$Marketplace' marketplace: $($r.Text)" }
        Write-Ok "Marketplace '$Marketplace' updated"
    } else {
        $r = Invoke-Claude $cli @('plugin', 'marketplace', 'add', $Repo)
        if ($r.Code -ne 0) { Stop-Install "Could not add the '$Marketplace' marketplace: $($r.Text)" 'Check that github.com is reachable, then run the command again.' }
        Write-Ok "Marketplace '$Marketplace' added"
    }
    $plugins = Invoke-Claude $cli @('plugin', 'list')
    if ($plugins.Text -match [regex]::Escape("$Plugin@$Marketplace")) {
        $r = Invoke-Claude $cli @('plugin', 'update', "$Plugin@$Marketplace")
        if ($r.Code -ne 0) { Stop-Install "Could not update $($Plugin): $($r.Text)" }
        Write-Ok "$Plugin updated to the latest version"
    } else {
        $r = Invoke-Claude $cli @('plugin', 'install', "$Plugin@$Marketplace")
        if ($r.Code -ne 0) { Stop-Install "Could not install $($Plugin): $($r.Text)" }
        Write-Ok "$Plugin installed in Claude Code"
    }
} elseif (-not $ZipOnly) {
    Write-Warn 'Claude Code not found - skipped (only needed for Claude Code).'
}

# 2. Claude app (claude.ai / desktop chat): plugins are uploaded from Settings
$downloads = Get-DownloadsFolder
$target = Join-Path $downloads "mivtra-craft-$($info.Version).zip"
Copy-Item $zip $target -Force
Remove-Item $zip -Force -ErrorAction SilentlyContinue
Write-Ok "Saved for the Claude app: $target"

Write-Host ""
Write-Host '  Next, in the Claude app (claude.ai or desktop):' -ForegroundColor White
Write-Host '    Settings -> Plugins -> Upload -> choose the zip above.'
Write-Host '    Already installed? Plugins -> mivtra-craft -> ... -> Upload new version.'
if ($cli) {
    Write-Host '  Claude Code: restart it, then the skills appear as mivtra-craft:code, :design, :studio.'
}
Write-Host ""
Write-Host '  First use: Claude asks for your brand once and saves it in' -ForegroundColor DarkGray
Write-Host '  ~/.claude/mivtra-craft/brand.md.' -ForegroundColor DarkGray
Write-Host ""

if (-not $NoOpen) {
    try { Start-Process explorer.exe "/select,`"$target`"" } catch { }
}
