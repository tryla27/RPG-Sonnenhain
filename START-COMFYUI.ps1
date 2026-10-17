param([string]$ToolsRoot='E:\Sonnenhain-Tools')
$ErrorActionPreference='Stop'
$python=Join-Path $ToolsRoot 'ComfyUI-venv\Scripts\python.exe'
$backend=Join-Path $ToolsRoot 'ComfyUI-Backend\main.py'
if (-not (Test-Path -LiteralPath $python) -or -not (Test-Path -LiteralPath $backend)) { throw 'Lokale ComfyUI-Umgebung fehlt.' }
Write-Output 'ComfyUI wird lokal unter http://127.0.0.1:8188 gestartet. Mit Strg+C beenden.'
& $python $backend --listen 127.0.0.1 --port 8188 --disable-auto-launch --output-directory (Join-Path $PSScriptRoot 'build\comfy-output')
