@echo off
rem Maze 3D - Das Labyrinth der Schatten: Setup fuer Windows
rem Doppelklick genuegt. Laedt die neueste Version herunter, installiert sie fuer dich
rem (ohne Administrator-Rechte) und legt Verknuepfungen auf dem Desktop und im Startmenue an.
title Maze 3D - Setup
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s = Get-Content -LiteralPath '%~f0' -Raw -Encoding UTF8; Invoke-Expression ($s.Substring($s.IndexOf('#' + 'POWERSHELL#') + 12))"
echo.
pause
exit /b

#POWERSHELL#
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo = 'Appelschorle187/gevibecodeded-lybrint-spiel-download'
$dir  = Join-Path $env:LOCALAPPDATA 'Maze3D'
$exe  = Join-Path $dir 'maze3d.exe'

try {
    Write-Host ''
    Write-Host '  MAZE 3D - Das Labyrinth der Schatten' -ForegroundColor Red
    Write-Host ''
    Write-Host 'Suche die neueste Version ...'
    $rel = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -Headers @{ 'User-Agent' = 'maze3d-setup' }
    $asset = $rel.assets | Where-Object { $_.name -like '*windows*.zip' } | Select-Object -First 1
    if (-not $asset) { throw 'Keine Windows-Version im neuesten Release gefunden.' }

    if (Get-Process -Name maze3d -ErrorAction SilentlyContinue) {
        Write-Host 'Das Spiel laeuft gerade - bitte erst beenden und dann eine Taste druecken.' -ForegroundColor Yellow
        [void][Console]::ReadKey($true)
    }

    Write-Host "Lade Version $($rel.tag_name) herunter ($([math]::Round($asset.size / 1MB, 1)) MB) ..."
    $zip = Join-Path $env:TEMP 'maze3d-setup.zip'
    for ($try = 1; $try -le 5; $try++) {                         # bei Abbruch noch einmal versuchen
        try { Invoke-WebRequest $asset.browser_download_url -OutFile $zip -UseBasicParsing; break }
        catch { if ($try -eq 5) { throw } ; Write-Host "Download abgebrochen - neuer Versuch ($try/5) ..." -ForegroundColor Yellow; Start-Sleep 2 }
    }
    if ((Get-Item $zip).Length -ne $asset.size) { throw 'Die heruntergeladene Datei ist unvollstaendig. Bitte nochmal versuchen.' }

    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Expand-Archive -Path $zip -DestinationPath $dir -Force      # Spielstaende und Einstellungen im Ordner bleiben erhalten
    Remove-Item $zip -Force
    Unblock-File -Path $exe -ErrorAction SilentlyContinue
    Set-Content -Path (Join-Path $dir 'version.txt') -Value $rel.tag_name

    # Verknuepfungen (Desktop + Startmenue)
    $shell = New-Object -ComObject WScript.Shell
    $places = @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))
    foreach ($p in $places) {
        $lnk = $shell.CreateShortcut((Join-Path $p 'Maze 3D.lnk'))
        $lnk.TargetPath = $exe
        $lnk.WorkingDirectory = $dir
        $lnk.Description = 'Maze 3D - Das Labyrinth der Schatten'
        $lnk.Save()
    }

    # Deinstallation
    $un = @"
@echo off
echo Maze 3D wird entfernt (inklusive Spielstaenden und Einstellungen).
pause
del "$([Environment]::GetFolderPath('Desktop'))\Maze 3D.lnk" 2>nul
del "$([Environment]::GetFolderPath('Programs'))\Maze 3D.lnk" 2>nul
cd /d "%TEMP%"
rmdir /s /q "$dir" 2>nul
"@
    Set-Content -Path (Join-Path $dir 'Deinstallieren.bat') -Value $un -Encoding ASCII

    Write-Host ''
    Write-Host "Fertig! Maze 3D $($rel.tag_name) ist installiert." -ForegroundColor Green
    Write-Host '  Starten: Verknuepfung "Maze 3D" auf dem Desktop oder im Startmenue'
    Write-Host "  Spielordner: $dir"
    Write-Host '  Entfernen: Deinstallieren.bat im Spielordner'
    Write-Host '  Mehrspieler: beim ersten Hosten fragt die Windows-Firewall - "Zugriff zulassen" klicken.'
    Write-Host ''
    $answer = Read-Host 'Jetzt spielen? (J/n)'
    if ($answer -notmatch '^[nN]') { Start-Process -FilePath $exe -WorkingDirectory $dir }
}
catch {
    Write-Host ''
    Write-Host "Fehler: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'Pruefe die Internetverbindung und versuche es noch einmal.'
}