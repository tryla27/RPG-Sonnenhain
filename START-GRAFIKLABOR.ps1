param([string]$ToolsRoot='E:\Sonnenhain-Tools')
$ErrorActionPreference='Stop'
$godot=Join-Path $ToolsRoot 'Godot\Godot_v4.7.2-stable_win64.exe'
if (-not (Test-Path -LiteralPath $godot)) { throw "Godot fehlt: $godot" }
& $godot --path $PSScriptRoot --resolution 1280x760 res://tools/quality_art_lab.tscn
