#!/bin/bash
set -e

STEAMCMD="/home/steam/steamcmd/steamcmd.sh"
SERVER_DIR="/home/steam/windrose"
LOG_DIR="/home/steam/logs"
APP_ID="4129620"
# SteamCMD cache location (where it sometimes installs despite force_install_dir)
STEAM_CACHE="/home/steam/Steam/steamapps/common"

echo "=========================================="
echo "[Windrose] Starte automatisches Setup..."
echo "=========================================="

# Log-Verzeichnis sicherstellen
mkdir -p "${LOG_DIR}"
mkdir -p "${SERVER_DIR}"

# Server-EXE suchen (rekursiv, da sie in einem Unterordner sein kann)
find_server_exe() {
    # Suche nach typischen UE5 Server-EXE Patterns
    local exe=""
    exe=$(find "${SERVER_DIR}" -maxdepth 5 -iname "*Server*.exe" 2>/dev/null | head -1)
    if [ -z "$exe" ]; then
        exe=$(find "${SERVER_DIR}" -maxdepth 5 -iname "*Shipping*.exe" 2>/dev/null | head -1)
    fi
    if [ -z "$exe" ]; then
        exe=$(find "${SERVER_DIR}" -maxdepth 5 -iname "*.exe" 2>/dev/null | grep -iv "CrashReport\|UE4\|EpicGames\|prereq\|vc_redist\|dotnet" | head -1)
    fi
    echo "$exe"
}

# Prüfe ob Server schon installiert ist
EXISTING_EXE=$(find_server_exe)

if [ -z "${EXISTING_EXE}" ]; then
    echo "[Windrose] Lade Windows Dedicated Server herunter..."
    echo "[Windrose] Das kann 5-15 Minuten dauern..."

    # Sicherstellen, dass das Verzeichnis dem steam-User gehört
    echo "[Windrose] Prüfe Berechtigungen: $(ls -la /home/steam/ | grep windrose)"

    ${STEAMCMD} \
        @sSteamCmdForcePlatformType windows \
        +force_install_dir "${SERVER_DIR}" \
        +login anonymous \
        +app_update ${APP_ID} validate \
        +quit

    echo "[Windrose] Download abgeschlossen."
    
    # DEBUG: Zeige wo die Dateien gelandet sind
    echo "[Windrose] === DEBUG: Inhalt von SERVER_DIR ==="
    ls -la "${SERVER_DIR}/" 2>/dev/null || echo "  SERVER_DIR leer oder nicht vorhanden"
    echo "[Windrose] === DEBUG: .exe Suche in SERVER_DIR ==="
    find "${SERVER_DIR}" -name "*.exe" 2>/dev/null | head -20 || echo "  Keine .exe gefunden"
    
    # Prüfe ob SteamCMD die Dateien in seinen Cache installiert hat
    echo "[Windrose] === DEBUG: Inhalt von SteamCMD Cache ==="
    ls -la "${STEAM_CACHE}/" 2>/dev/null || echo "  Steam Cache nicht vorhanden"
    
    # Auch den steamapps-Ordner direkt prüfen
    echo "[Windrose] === DEBUG: steamapps Inhalt ==="
    ls -la /home/steam/Steam/steamapps/ 2>/dev/null || echo "  steamapps nicht vorhanden"
    find /home/steam/Steam/steamapps/ -name "*.exe" 2>/dev/null | head -20 || echo "  Keine .exe in steamapps"
    
    # Falls Dateien im Steam Cache gelandet sind, verschiebe sie
    if [ -d "${STEAM_CACHE}" ]; then
        CACHE_EXE=$(find "${STEAM_CACHE}" -maxdepth 5 -iname "*.exe" 2>/dev/null | head -1)
        if [ -n "${CACHE_EXE}" ] && [ ! "$(ls -A ${SERVER_DIR} 2>/dev/null)" ]; then
            echo "[Windrose] Dateien im Steam-Cache gefunden! Verschiebe nach SERVER_DIR..."
            CACHE_DIR=$(dirname "${CACHE_EXE}")
            # Finde das Stammverzeichnis der App im Cache
            GAME_DIR=$(echo "${CACHE_DIR}" | grep -oP "${STEAM_CACHE}/[^/]+" | head -1)
            if [ -n "${GAME_DIR}" ] && [ -d "${GAME_DIR}" ]; then
                cp -r "${GAME_DIR}"/* "${SERVER_DIR}/" 2>/dev/null || true
                echo "[Windrose] Dateien verschoben."
            fi
        fi
    fi
    
    # Auch prüfen ob force_install_dir mit App-Unterordner installiert hat
    APPMANIFEST=$(find /home/steam/Steam/steamapps/ -name "appmanifest_${APP_ID}.acf" 2>/dev/null | head -1)
    if [ -n "${APPMANIFEST}" ]; then
        echo "[Windrose] === DEBUG: App Manifest gefunden ==="
        cat "${APPMANIFEST}"
        INSTALL_DIR=$(grep -oP '"installdir"\s*"\K[^"]+' "${APPMANIFEST}" 2>/dev/null)
        if [ -n "${INSTALL_DIR}" ]; then
            FULL_INSTALL="${STEAM_CACHE}/${INSTALL_DIR}"
            echo "[Windrose] Manifest sagt installdir: ${INSTALL_DIR}"
            echo "[Windrose] Vollständiger Pfad: ${FULL_INSTALL}"
            if [ -d "${FULL_INSTALL}" ] && [ ! "$(ls -A ${SERVER_DIR} 2>/dev/null)" ]; then
                echo "[Windrose] Verschiebe von ${FULL_INSTALL} nach ${SERVER_DIR}..."
                cp -r "${FULL_INSTALL}"/* "${SERVER_DIR}/" 2>/dev/null || true
                echo "[Windrose] Verschiebung abgeschlossen."
            fi
        fi
    fi
else
    echo "[Windrose] Server bereits installiert: $(basename ${EXISTING_EXE})"
    echo "[Windrose] Prüfe auf Updates..."
    ${STEAMCMD} \
        @sSteamCmdForcePlatformType windows \
        +force_install_dir "${SERVER_DIR}" \
        +login anonymous \
        +app_update ${APP_ID} \
        +quit
fi

# Server-EXE finden (nach Download/Update erneut suchen)
EXE_FILE=$(find_server_exe)

# Fallback: Irgendeine .exe im Hauptverzeichnis
if [ -z "${EXE_FILE}" ]; then
    EXE_FILE=$(find "${SERVER_DIR}" -maxdepth 1 -name "*.exe" 2>/dev/null | head -1)
fi

if [ -z "${EXE_FILE}" ]; then
    echo "=========================================="
    echo "[FEHLER] Keine Server .exe Datei gefunden!"
    echo "[FEHLER] Inhalt von ${SERVER_DIR}:"
    ls -la "${SERVER_DIR}/"
    echo ""
    echo "[FEHLER] Rekursive Suche (alle Dateien):"
    find "${SERVER_DIR}" -type f 2>/dev/null | head -50 || echo "  Keine Dateien gefunden"
    echo ""
    echo "[FEHLER] Suche in Steam-Verzeichnissen:"
    find /home/steam/Steam/steamapps/ -name "*.exe" 2>/dev/null | head -20 || echo "  Keine .exe in steamapps"
    echo "=========================================="
    exit 1
fi

echo "[Windrose] Gefundene Server-Datei: $(basename ${EXE_FILE})"

# ServerDescription.json erstellen/aktualisieren
# Windrose nutzt eine JSON-Konfigurationsdatei, keine CLI-Parameter
EXE_DIR=$(dirname "${EXE_FILE}")

# Prüfe ob R5-Ordner existiert (UE5 typisch), sonst Config im EXE-Verzeichnis
CONFIG_DIR="${EXE_DIR}"
if [ -d "${EXE_DIR}/R5" ]; then
    CONFIG_DIR="${EXE_DIR}/R5"
fi
mkdir -p "${CONFIG_DIR}"

# Erst starten falls ServerDescription.json noch nicht existiert
# (erster Start generiert sie manchmal selbst)
if [ ! -f "${CONFIG_DIR}/ServerDescription.json" ]; then
    echo "[Windrose] Erstelle ServerDescription.json..."
    cat > "${CONFIG_DIR}/ServerDescription.json" << EOF
{
    "ServerName": "${SERVER_NAME:-Windrose Server}",
    "MaxPlayers": ${MAX_PLAYERS:-16},
    "Port": ${SERVER_PORT:-7777},
    "QueryPort": ${QUERY_PORT:-27015},
    "Password": "${SERVER_PASSWORD:-}"
}
EOF
    echo "[Windrose] Konfiguration erstellt in: ${CONFIG_DIR}/ServerDescription.json"
else
    echo "[Windrose] ServerDescription.json existiert bereits."
    echo "[Windrose] Aktualisiere Servername und Spieleranzahl..."
    # Bestehende Config updaten mit sed (behält andere Einstellungen)
    sed -i "s/\"ServerName\": *\"[^\"]*\"/\"ServerName\": \"${SERVER_NAME:-Windrose Server}\"/" \
        "${CONFIG_DIR}/ServerDescription.json"
    sed -i "s/\"MaxPlayers\": *[0-9]*/\"MaxPlayers\": ${MAX_PLAYERS:-16}/" \
        "${CONFIG_DIR}/ServerDescription.json"
    sed -i "s/\"Port\": *[0-9]*/\"Port\": ${SERVER_PORT:-7777}/" \
        "${CONFIG_DIR}/ServerDescription.json"
    sed -i "s/\"QueryPort\": *[0-9]*/\"QueryPort\": ${QUERY_PORT:-27015}/" \
        "${CONFIG_DIR}/ServerDescription.json"
fi

echo "[Windrose] Aktuelle Konfiguration:"
cat "${CONFIG_DIR}/ServerDescription.json"
echo ""

echo "=========================================="
echo "[Windrose] Starte Server über Wine..."
echo "[Windrose] EXE: $(basename ${EXE_FILE})"
echo "=========================================="

# In das Verzeichnis der EXE wechseln (wichtig für relative Pfade)
cd "$(dirname ${EXE_FILE})"

# Server über Wine in virtuellem X-Server starten
# Wine-Debug-Ausgaben unterdrücken für saubere Logs
export WINEDEBUG=-all

xvfb-run --auto-servernum --server-args="-screen 0 1024x768x24" \
    wine "$(basename ${EXE_FILE})" \
    -log="${LOG_DIR}/windrose-server.log" \
    "$@" 2>&1 | tee "${LOG_DIR}/console.log"
