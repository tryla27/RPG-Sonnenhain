# Speicher- und Build-Strategie

## Builds

Build-Artefakte werden nicht versioniert. CI/CD erzeugt Web- und Server-Builds aus den Quellen und lädt sie als Artefakte bzw. direkt auf die Zielsysteme.

Lokale Ausgabeziele:

- `build/web/`
- `build/server/`
- `build/ci/`
- `build/site/`

## Große Binärdateien

Für zukünftige große Quelldateien wie PSD, KRA, BLEND oder unkomprimierte Master-Audiodateien soll Git LFS nur gezielt eingeführt werden. Bestehende Runtime-Assets werden nicht automatisch umgestellt, solange CI/CD und lokale Entwicklerumgebungen nicht gemeinsam auf LFS vorbereitet sind.

## Git-Historie

Das Entfernen großer generierter Dateien aus dem aktuellen Branch verhindert weiteres Wachstum. Bereits vorhandene große Dateien bleiben zunächst in älteren Commits erhalten.

Eine echte Verkleinerung der gesamten Repository-Historie erfordert später eine kontrollierte History-Rewrite-Aktion, zum Beispiel mit `git filter-repo`, inklusive Force-Push und Neu-Klonen aller Arbeitskopien. Das sollte separat geplant werden.
