<#
.SYNOPSIS
    Installs, updates or removes Mivtra Craft for Claude - one command, nothing to upload.

.DESCRIPTION
      irm https://raw.githubusercontent.com/mivtra/craft/main/install.ps1 | iex

    - Claude Code found (CLI, VS Code, JetBrains, or the Code tab of the Claude desktop app):
      installs the "mivtra-craft" plugin from the "mivtra" marketplace, or updates it.
    - Claude Code not found: installs the skills as personal skills in ~/.claude/skills,
      which Claude Code and the desktop Code tab load when they start.
    Running it again updates. Nothing is uploaded by hand.

    Options (pass them with the scriptblock form):
      & ([scriptblock]::Create((irm https://raw.githubusercontent.com/mivtra/craft/main/install.ps1))) -Uninstall
      -Uninstall   remove everything this script installed
      -Skills      force personal-skills mode even when Claude Code is found
      -Zip         also save mivtra-craft-<version>.zip in Downloads (for claude.ai chat upload)
      -ZipPath     install from a local zip instead of the latest release (testing)

    Windows PowerShell 5.1 or PowerShell 7. No administrator rights needed.
#>
[CmdletBinding()]
param(
    [switch]$Uninstall,
    [switch]$Skills,
    [switch]$Zip,
    [string]$ZipPath
)

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

$Repo        = 'mivtra/craft'
$Marketplace = 'mivtra'
$Plugin      = 'mivtra-craft'
$Prefix      = 'mivtra-craft-'
$ReleaseZip  = "https://github.com/$Repo/releases/latest/download/mivtra-craft.zip"
$ClaudeHome  = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
$SkillsDir   = Join-Path $ClaudeHome 'skills'
$StateFile   = Join-Path $ClaudeHome 'mivtra-craft\install.json'

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
    foreach ($c in @((Join-Path $env:USERPROFILE '.local\bin\claude.exe'), (Join-Path $env:APPDATA 'npm\claude.cmd'))) {
        if ($c -and (Test-Path $c)) { return $c }
    }
    $root = Join-Path $env:LOCALAPPDATA 'Claude-Data'          # CLI bundled with the Claude desktop app
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
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch { }
    try { Invoke-WebRequest -Uri $ReleaseZip -OutFile $tmp -UseBasicParsing }
    catch { Stop-Install "Could not download the latest release ($($_.Exception.Message))." "Check the internet connection, or see https://github.com/$Repo/releases" }
    return $tmp
}

function Expand-Release([string]$Zip) {
    $dir = Join-Path ([IO.Path]::GetTempPath()) ("mivtra-craft-" + [guid]::NewGuid().ToString('N'))
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [IO.Compression.ZipFile]::ExtractToDirectory($Zip, $dir)
    $manifest = Join-Path $dir '.claude-plugin\plugin.json'
    if (-not (Test-Path $manifest)) { Stop-Install 'The download is not a valid Claude plugin (no .claude-plugin/plugin.json).' "Report it at https://github.com/$Repo/issues" }
    $json = [IO.File]::ReadAllText($manifest, [Text.Encoding]::UTF8) | ConvertFrom-Json
    $names = @(Get-ChildItem (Join-Path $dir 'skills') -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } | ForEach-Object { $_.Name })
    if ($json.name -ne $Plugin -or $names.Count -lt 1) { Stop-Install 'The download does not contain the Mivtra Craft skills.' "Report it at https://github.com/$Repo/issues" }
    return [pscustomobject]@{ Dir = $dir; Version = $json.version; Skills = $names }
}

function Save-State($Mode, $Version, $Names) {
    New-Item -ItemType Directory -Force (Split-Path $StateFile) | Out-Null
    $state = [pscustomobject]@{ mode = $Mode; version = $Version; skills = $Names; installed = (Get-Date).ToString('s') }
    [IO.File]::WriteAllText($StateFile, ($state | ConvertTo-Json), (New-Object Text.UTF8Encoding($false)))
}

function Remove-PersonalSkills {
    $removed = 0
    if (Test-Path $SkillsDir) {
        Get-ChildItem $SkillsDir -Directory -Filter "$Prefix*" | ForEach-Object { Remove-Item $_.FullName -Recurse -Force; $removed++ }
    }
    return $removed
}

function Install-PersonalSkills($Release) {
    New-Item -ItemType Directory -Force $SkillsDir | Out-Null
    [void](Remove-PersonalSkills)                           # clean update: no stale files
    $utf8 = New-Object Text.UTF8Encoding($false)
    foreach ($name in $Release.Skills) {
        $dest = Join-Path $SkillsDir ($Prefix + $name)
        Copy-Item (Join-Path $Release.Dir "skills\$name") $dest -Recurse
        $md = Join-Path $dest 'SKILL.md'
        $text = [IO.File]::ReadAllText($md, [Text.Encoding]::UTF8)
        $text = [regex]::Replace($text, '(?m)^name:\s*"?[^"\r\n]+"?', "name: `"$Prefix$name`"", 1)
        [IO.File]::WriteAllText($md, $text, $utf8)
    }
}

# ---------------------------------------------------------------------------------------------
Write-Host ""
Write-Host "  Mivtra Craft - Arabic-first skills for Claude" -ForegroundColor White
Write-Host "  https://github.com/$Repo" -ForegroundColor DarkGray
Write-Host ""

$cli = Find-ClaudeCli

if ($Uninstall) {
    if ($cli) {
        $r = Invoke-Claude $cli @('plugin', 'uninstall', "$Plugin@$Marketplace")
        if ($r.Code -eq 0) { Write-Ok 'Plugin removed from Claude Code' }
        $r = Invoke-Claude $cli @('plugin', 'marketplace', 'remove', $Marketplace)
        if ($r.Code -eq 0) { Write-Ok "Marketplace '$Marketplace' removed" }
    }
    $n = Remove-PersonalSkills
    if ($n -gt 0) { Write-Ok "$n personal skills removed from $SkillsDir" }
    if (Test-Path $StateFile) { Remove-Item $StateFile -Force }
    Write-Host ""
    Write-Host '  Done. Your brand file (~/.claude/mivtra-craft/brand.md) was kept.' -ForegroundColor DarkGray
    Write-Host ""
    return
}

Write-Step 'Downloading the latest release'
$zipFile = Get-ReleaseZip
$release = Expand-Release $zipFile
Write-Ok "Mivtra Craft $($release.Version) - skills: $($release.Skills -join ', ')"

if ($cli -and -not $Skills) {
    Write-Step 'Installing into Claude Code'
    $list = Invoke-Claude $cli @('plugin', 'marketplace', 'list')
    if ($list.Text -match "(?m)\b$Marketplace\b") {
        $r = Invoke-Claude $cli @('plugin', 'marketplace', 'update', $Marketplace)
    } else {
        $r = Invoke-Claude $cli @('plugin', 'marketplace', 'add', $Repo)
    }
    if ($r.Code -ne 0) { Stop-Install "Could not reach the '$Marketplace' marketplace: $($r.Text)" 'Check that github.com is reachable, then run the command again.' }

    $installed = (Invoke-Claude $cli @('plugin', 'list')).Text -match [regex]::Escape("$Plugin@$Marketplace")
    if ($installed) { $r = Invoke-Claude $cli @('plugin', 'update', "$Plugin@$Marketplace") }
    else            { $r = Invoke-Claude $cli @('plugin', 'install', "$Plugin@$Marketplace") }
    if ($r.Code -ne 0) { Stop-Install "Claude Code refused the plugin: $($r.Text)" }

    $check = (Invoke-Claude $cli @('plugin', 'list')).Text
    if ($check -notmatch [regex]::Escape("$Plugin@$Marketplace")) { Stop-Install 'The plugin does not appear in Claude Code after installing.' 'Run the command again; if it persists, open an issue on GitHub.' }
    $n = Remove-PersonalSkills                               # never two copies of the same skills
    if ($n -gt 0) { Write-Ok "Removed $n older personal-skill copies" }
    Save-State 'plugin' $release.Version $release.Skills
    $verb = if ($installed) { 'updated' } else { 'installed' }
    Write-Ok "Plugin $Plugin $verb in Claude Code"
    $how = ($release.Skills | ForEach-Object { "/${Plugin}:$_" }) -join '  '
} else {
    if (-not $cli) { Write-Warn 'Claude Code CLI not found - installing as personal skills.' }
    Write-Step "Installing personal skills into $SkillsDir"
    Install-PersonalSkills $release
    Save-State 'skills' $release.Version $release.Skills
    Write-Ok "$($release.Skills.Count) skills installed"
    $how = ($release.Skills | ForEach-Object { "/$Prefix$_" }) -join '  '
}

if ($Zip) {
    $downloads = Join-Path $env:USERPROFILE 'Downloads'
    $target = Join-Path $downloads "mivtra-craft-$($release.Version).zip"
    Copy-Item $zipFile $target -Force
    Write-Ok "Zip for claude.ai chat saved: $target"
}
Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
Remove-Item $release.Dir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "  Ready. Start a new Claude Code session; the skills load by themselves." -ForegroundColor White
Write-Host "  Call one directly: $how" -ForegroundColor DarkGray
Write-Host '  First use: Claude asks for your brand once (saved in ~/.claude/mivtra-craft/brand.md).' -ForegroundColor DarkGray
Write-Host '  Update: run the same command again.   Remove: add -Uninstall (see README).' -ForegroundColor DarkGray
Write-Host ""
