#!/bin/bash
set -e

STEAMCMD="/home/steam/steamcmd/steamcmd.sh"
SERVER_DIR="/home/steam/windrose"
APP_ID="4129620"

echo "[Windrose] Starte automatisches Setup..."

# Prüfe ob Server schon installiert ist
if [ ! -f "${SERVER_DIR}/WindroseServer.exe" ] && [ ! -f "${SERVER_DIR}/WindroseServer.sh" ]; then
    echo "[Windrose] Lade Windows Dedicated Server herunter..."
    echo "[Windrose] Das kann 5-15 Minuten dauern..."

    ${STEAMCMD} \
        @sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${APP_ID} validate \
        +quit

    echo "[Windrose] Download abgeschlossen."
else
    echo "[Windrose] Server bereits installiert."
    echo "[Windrose] Prüfe auf Updates..."
    ${STEAMCMD} \
        @sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${APP_ID} \
        +quit
fi

# Finde die .exe Datei
cd ${SERVER_DIR}
EXE_FILE=$(ls *.exe 2>/dev/null | head -1)

if [ -z "$EXE_FILE" ]; then
    echo "[FEHLER] Keine .exe Datei gefunden in ${SERVER_DIR}"
    ls -la ${SERVER_DIR}/
    exit 1
fi

echo "[Windrose] Gefundene Datei: ${EXE_FILE}"
echo "[Windrose] Starte Server über Wine..."

# Server über Wine in virtuellem X-Server starten
xvfb-run --auto-servernum --server-args="-screen 0 1024x768x24" \
    wine ${EXE_FILE} \
    -ServerName="${SERVER_NAME:-Windrose Server}" \
    -Port="${SERVER_PORT:-7777}" \
    -QueryPort="${QUERY_PORT:-27015}" \
    -MaxPlayers="${MAX_PLAYERS:-16}" \
    -savepath=${SERVER_DIR}/saved \
    "$@"
