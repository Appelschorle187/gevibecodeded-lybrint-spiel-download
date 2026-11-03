# Maze 3D 

Ein Horror-Labyrinth in der Ego-Perspektive. Finde alle Schlüssel, öffne das Tor und entkomme, bevor dich der Wächter erwischt.
Allein oder mit bis zu 4 Spielern im Netzwerk, im Koop oder mit einem Spieler als Wächter.

## Installieren

### Windows
1. **[setup-windows.bat herunterladen](https://github.com/Appelschorle187/gevibecodeded-lybrint-spiel-download/raw/main/setup-windows.bat)**
2. Die Datei doppelklicken. Das Setup lädt die neueste Version herunter und legt „Maze 3D“ auf dem Desktop und im Startmenü an.

Es sind keine Administrator-Rechte nötig. Das Spiel landet in `%LOCALAPPDATA%\Maze3D`.
Warnt Windows („Der Computer wurde durch Windows geschützt“), klicke auf *Weitere Informationen → Trotzdem ausführen*. Das passiert, weil die Datei nicht signiert ist.

### Linux
Im Terminal:
```
curl -fsSLO https://raw.githubusercontent.com/Appelschorle187/gevibecodeded-lybrint-spiel-download/main/setup-linux.sh
bash setup-linux.sh
```
Danach steht „Maze 3D“ im Anwendungsmenü. Im Terminal startest du es mit `maze3d`. Das Spiel landet in `~/.local/share/maze3d`.

### Aktualisieren
Starte das Setup einfach noch einmal. Spielstände, Bestzeiten und Einstellungen bleiben erhalten.

### Entfernen
- Windows: `Deinstallieren.bat` im Spielordner (`%LOCALAPPDATA%\Maze3D`)
- Linux: `bash setup-linux.sh --uninstall`

## Steuerung

| Taste | Aktion |
|---|---|
| W A S D / Maus | laufen / umsehen |
| SHIFT | rennen (Ausdauer) |
| STRG / C | schleichen (leise) |
| F | Taschenlampe |
| Linksklick / E | Stein werfen |
| E (davor) | Notiz lesen, im Schrank verstecken, Sicherung umlegen, Stein aufheben |
| G / Q | Leuchtstab ablegen / Böller werfen |
| M | Karte (im Titelbild: Mehrspieler) |
| + / - · Bild auf / ab | Helligkeit · Lautstärke |
| F11 · ESC · BACKSPACE | Vollbild · Pause · Beenden |

## Mehrspieler
Im Titelbild **M** drücken. Einer **hostet** (H) und sieht seine IP-Adresse, die anderen **treten bei** (J) und geben diese IP ein.
Alle müssen im selben Netzwerk sein. Übers Internet geht es mit einer Portfreigabe (TCP 47474) beim Host oder mit einem VPN wie Tailscale oder ZeroTier.
Unter Windows fragt beim ersten Hosten die Firewall nach, dann *Zugriff zulassen* klicken.
Alle Spieler brauchen dieselbe Version.

## Eigenes Monster-Gesicht
Im Spielordner liegt `monster_gesicht.png`. Ersetze es durch ein eigenes Bild, das Spiel übernimmt es sofort.
