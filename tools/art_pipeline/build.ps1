param([string]$ToolsRoot='E:\Sonnenhain-Tools')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$godot=Join-Path $ToolsRoot 'Godot\Godot_v4.7.2-stable_win64_console.exe'
$blender=Join-Path $ToolsRoot 'Blender\blender.exe'
$krita=Join-Path $ToolsRoot 'Krita\bin\krita.exe'
$inkscape=Join-Path $ToolsRoot 'Inkscape-Portable\PFiles64\Inkscape\bin\inkscape.com'
$python=Join-Path $ToolsRoot 'ComfyUI-venv\Scripts\python.exe'
foreach ($tool in @($godot,$blender,$krita,$inkscape,$python)) {
    if (-not (Test-Path -LiteralPath $tool)) { throw "Werkzeug fehlt: $tool" }
}
& $godot --headless --path $projectRoot --script res://tools/art_pipeline/export_map_data.gd
if ($LASTEXITCODE -ne 0) { throw 'Kartenexport fehlgeschlagen' }
& $python (Join-Path $PSScriptRoot 'build_vector_assets.py') --inkscape $inkscape
if ($LASTEXITCODE -ne 0) { throw 'Vektorexport fehlgeschlagen' }
foreach ($name in @('stone','wood','moss')) {
    $ora=Join-Path $projectRoot "art\source\krita\material_$name.ora"
    $kra=Join-Path $projectRoot "art\source\krita\material_$name.kra"
    $png=Join-Path $projectRoot "art\textures\quality_v1\${name}_krita.png"
    foreach ($pair in @(@($ora,$kra),@($kra,$png))) {
        $proc=Start-Process $krita -ArgumentList @('--nosplash','--export','--export-filename',('"'+$pair[1]+'"'),('"'+$pair[0]+'"')) -WindowStyle Hidden -Wait -PassThru
        if ($proc.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $pair[1])) { throw "Krita-Export fehlgeschlagen: $($pair[1])" }
    }
}
& $blender --background --factory-startup --python (Join-Path $PSScriptRoot 'build_blender_assets.py')
if ($LASTEXITCODE -ne 0) { throw 'Blender-Export fehlgeschlagen' }
& $blender --background --factory-startup --python (Join-Path $PSScriptRoot 'render_item_icons.py')
if ($LASTEXITCODE -ne 0) { throw 'Gegenstandsbilder fehlgeschlagen' }
& $godot --headless --path $projectRoot --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot-Import fehlgeschlagen' }
& $godot --headless --path $projectRoot --script res://tests/rendering/check_quality_assets.gd
if ($LASTEXITCODE -ne 0) { throw 'Assetprüfung fehlgeschlagen' }
Write-Output 'ART_PIPELINE_COMPLETE'
