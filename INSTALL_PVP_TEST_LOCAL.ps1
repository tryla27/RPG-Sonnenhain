param(
    [string]$ProjectPath = "D:\SonnenhainRPG-Audio\game-v28-review"
)

$ErrorActionPreference = "Stop"
$target = Join-Path $ProjectPath "components\konflux_map.gd"
$backup = "$target.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$url = "https://raw.githubusercontent.com/tryla27/RPG-Sonnenhain/test/pvp-render-audit-fixes-2026-10-01/components/konflux_map.gd"

if (-not (Test-Path (Join-Path $ProjectPath "project.godot"))) {
    throw "Kein Godot-Projekt gefunden: $ProjectPath"
}

if (-not (Test-Path (Split-Path $target))) {
    New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
}

if (Test-Path $target) {
    Copy-Item $target $backup -Force
    Write-Host "Backup: $backup"
}

Invoke-WebRequest -Uri $url -OutFile $target

if (-not (Test-Path $target)) {
    throw "Download fehlgeschlagen."
}

$source = Get-Content $target -Raw
$checks = @(
    'CHUNKS_PER_PRELOAD_TICK := 2',
    'interior_furniture_rect',
    'int(state.get("rings",0))',
    'touch_chunk'
)

foreach ($check in $checks) {
    if (-not $source.Contains($check)) {
        throw "Pruefung fehlgeschlagen: $check fehlt."
    }
}

Write-Host ""
Write-Host "Sonnenhain PvP-Testupdate installiert." -ForegroundColor Green
Write-Host "Projekt: $ProjectPath"
Write-Host "Datei:   $target"
Write-Host ""
Write-Host "Jetzt in Godot 4.7.2 project.godot oeffnen und F6/F5 starten."
