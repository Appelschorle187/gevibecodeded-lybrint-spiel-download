#!/usr/bin/env bash
# Maze 3D - Das Labyrinth der Schatten: Setup fuer Linux
# Laedt die neueste Version herunter, installiert sie fuer den aktuellen Benutzer
# und legt einen Eintrag im Anwendungsmenue (und auf dem Desktop) an.
#
#   bash setup-linux.sh               installieren / aktualisieren
#   bash setup-linux.sh --uninstall   wieder entfernen (Spielstaende werden mitgeloescht)
set -euo pipefail

REPO="Appelschorle187/gevibecodeded-lybrint-spiel-download"
DIR="${XDG_DATA_HOME:-$HOME/.local/share}/maze3d"
BIN="$HOME/.local/bin"
APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DESKTOP_DIR="$(command -v xdg-user-dir >/dev/null 2>&1 && xdg-user-dir DESKTOP || echo "$HOME/Desktop")"

if [ "${1:-}" = "--uninstall" ]; then
    rm -rf "$DIR" "$BIN/maze3d" "$APPS/maze3d.desktop" "$DESKTOP_DIR/maze3d.desktop"
    echo "Maze 3D wurde entfernt."
    exit 0
fi

for tool in curl tar; do
    command -v "$tool" >/dev/null 2>&1 || { echo "Fehler: '$tool' fehlt. Bitte zuerst installieren."; exit 1; }
done
[ "$(uname -m)" = "x86_64" ] || { echo "Fehler: Es gibt das Spiel nur fuer 64-Bit-PCs (x86_64)."; exit 1; }

echo "Suche die neueste Version ..."
RELEASE_JSON="$(curl -fsSL -H "Accept: application/vnd.github+json" "https://api.github.com/repos/$REPO/releases/latest")"
URL="$(printf '%s' "$RELEASE_JSON" | grep -o '"browser_download_url": *"[^"]*linux[^"]*\.tar\.gz"' | head -n1 | cut -d'"' -f4)"
VERSION="$(printf '%s' "$RELEASE_JSON" | grep -o '"tag_name": *"[^"]*"' | head -n1 | cut -d'"' -f4)"
[ -n "$URL" ] || { echo "Fehler: Keine Linux-Version im neuesten Release gefunden."; exit 1; }

if [ -f "$DIR/version.txt" ] && [ "$(cat "$DIR/version.txt")" = "$VERSION" ]; then
    echo "Version $VERSION ist schon installiert - wird neu eingerichtet."
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "Lade Version $VERSION herunter ..."
curl -fL --progress-bar "$URL" -o "$TMP/maze3d.tar.gz"

mkdir -p "$DIR" "$BIN" "$APPS"
tar -xzf "$TMP/maze3d.tar.gz" -C "$TMP"
install -m 755 "$TMP/maze3d" "$DIR/maze3d"            # Spielstaende und Einstellungen im Ordner bleiben erhalten
printf '%s\n' "$VERSION" > "$DIR/version.txt"

# Starter: das Spiel speichert alles im Ordner, aus dem es gestartet wird
cat > "$BIN/maze3d" <<LAUNCH
#!/bin/sh
cd "$DIR" && exec ./maze3d "\$@"
LAUNCH
chmod 755 "$BIN/maze3d"

cat > "$APPS/maze3d.desktop" <<ENTRY
[Desktop Entry]
Type=Application
Name=Maze 3D
Comment=Das Labyrinth der Schatten - Horror-Labyrinth
Exec=$BIN/maze3d
Path=$DIR
Icon=$DIR/monster_gesicht.png
Terminal=false
Categories=Game;
ENTRY
chmod 644 "$APPS/maze3d.desktop"
if [ -d "$DESKTOP_DIR" ]; then
    cp "$APPS/maze3d.desktop" "$DESKTOP_DIR/maze3d.desktop"
    chmod 755 "$DESKTOP_DIR/maze3d.desktop"
    command -v gio >/dev/null 2>&1 && gio set "$DESKTOP_DIR/maze3d.desktop" metadata::trusted true 2>/dev/null || true
fi
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" 2>/dev/null || true

echo
echo "Fertig! Maze 3D $VERSION ist installiert."
echo "  Starten: im Anwendungsmenue \"Maze 3D\" oder im Terminal: maze3d"
echo "  Spielordner: $DIR"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "  (Hinweis: $BIN ist nicht im PATH - im Terminal dann mit $BIN/maze3d starten)";; esac
echo "  Entfernen: bash setup-linux.sh --uninstall"
