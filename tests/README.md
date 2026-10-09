# Tests

Dieses Verzeichnis enthält ausführbare Godot-Regressionstests. Die Migration aus `tools/` erfolgt schrittweise, damit bestehende CI- und Deploy-Pfade nicht gleichzeitig umgebaut werden müssen.

## Struktur

- `fusion/` – Fusionsregeln, Identität, Trefferregeln und reine Fusionsmodule.
- `network/` – zustandslose Netzwerk-Hilfen: Einladungscodes, Bereinigung fremder Quest-/Ereigniszeilen, Belohnungs-Payloads.

Weitere Bereiche werden erst verschoben, wenn ihre Aufrufer in CI/Deploy bekannt und angepasst sind.

## Konvention

- Ausführbare Regressionstests heißen weiterhin `check_*.gd`.
- Tests dürfen Runtime-Code laden, verändern aber keine Produktionspfade.
- CI führt während der Migration Tests aus `tools/` und `tests/` aus.
- Runtime-, Save-, Netzwerk- und Exportverhalten wird durch reine Testverschiebungen nicht verändert.
