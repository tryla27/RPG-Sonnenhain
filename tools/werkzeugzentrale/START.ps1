param([switch]$Status)
$ErrorActionPreference = 'Stop'
$runtime = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (-not (Test-Path -LiteralPath $runtime)) {
    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCommand) { throw 'Python 3 mit Tkinter benötigt. hub.py mit der gewünschten Python-Laufzeit starten.' }
    $runtime = $pythonCommand.Source
}
$mode = if ($Status) { 'status' } else { 'gui' }
& $runtime (Join-Path $PSScriptRoot 'hub.py') $mode
exit $LASTEXITCODE
