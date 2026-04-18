#!/bin/bash
set -e

STEAMCMD="/home/steam/steamcmd/steamcmd.sh"
SERVER_DIR="/windrose"
APP_ID="3041230"

echo "[Windrose] Starte Server-Setup..."

# Prüfe ob Server schon installiert ist
if [ ! -f "${SERVER_DIR}/WindroseServer.sh" ]; then
    echo "[Windrose] Server nicht gefunden. Installiere jetzt..."
    echo "[Windrose] Download kann 5-15 Minuten dauern..."
    
    ${STEAMCMD} +force_install_dir ${SERVER_DIR} +login anonymous +app_update ${APP_ID} validate +quit
    
    echo "[Windrose] Installation abgeschlossen."
else
    echo "[Windrose] Server bereits installiert."
    
    # Optional: Check for Updates
    echo "[Windrose] Prüfe auf Updates..."
    ${STEAMCMD} +force_install_dir ${SERVER_DIR} +login anonymous +app_update ${APP_ID} +quit
fi

# Server starten
echo "[Windrose] Starte Windrose Server..."
cd ${SERVER_DIR}

exec ./WindroseServer.sh \
    -ServerName="${SERVER_NAME:-Windrose Server}" \
    -Port="${SERVER_PORT:-7777}" \
    -QueryPort="${QUERY_PORT:-27015}" \
    -MaxPlayers="${MAX_PLAYERS:-16}" \
    -savepath=${SERVER_DIR}/saved \
    "$@"
