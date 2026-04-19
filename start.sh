#!/bin/bash
set -e

STEAMCMD="/home/steam/steamcmd/steamcmd.sh"
SERVER_DIR="/home/steam/windrose"
LOG_DIR="/home/steam/logs"
APP_ID="4129620"

echo "=========================================="
echo "[Windrose] Starte automatisches Setup..."
echo "=========================================="

# Log-Verzeichnis sicherstellen
mkdir -p "${LOG_DIR}"

# Server-EXE suchen (rekursiv, da sie in einem Unterordner sein kann)
find_server_exe() {
    find "${SERVER_DIR}" -maxdepth 3 -iname "*Server*Win64*Shipping*.exe" 2>/dev/null | head -1
}

# Prüfe ob Server schon installiert ist
EXISTING_EXE=$(find_server_exe)

if [ -z "${EXISTING_EXE}" ]; then
    echo "[Windrose] Lade Windows Dedicated Server herunter..."
    echo "[Windrose] Das kann 5-15 Minuten dauern..."

    ${STEAMCMD} \
        @sSteamCmdForcePlatformType windows \
        +force_install_dir "${SERVER_DIR}" \
        +login anonymous \
        +app_update ${APP_ID} validate \
        +quit

    echo "[Windrose] Download abgeschlossen."
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
    echo "[FEHLER] Rekursive Suche:"
    find "${SERVER_DIR}" -name "*.exe" 2>/dev/null || echo "  Keine .exe gefunden"
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
