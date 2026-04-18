#!/bin/bash

SERVER_DIR="/home/steam/windrose"
GAME_EXEC="WindroseServer.sh"

echo "[Windrose] Starte Server..."

# Prüfe ob Spieldateien vorhanden sind
if [ ! -f "${SERVER_DIR}/${GAME_EXEC}" ]; then
    echo "[FEHLER] Keine Spieldateien gefunden!"
    echo "[INFO] Bitte per FTP die Windrose Server-Dateien nach ${SERVER_DIR} hochladen."
    echo "[INFO] Starte nicht, da ${SERVER_DIR}/${GAME_EXEC} nicht existiert."
    exit 1
fi

# Wechsle in das Server-Verzeichnis
cd ${SERVER_DIR}

echo "[Windrose] Server startet..."
echo "[Windrose] Server Name: ${SERVER_NAME:-Windrose Server}"
echo "[Windrose] Game Port: ${SERVER_PORT:-7777}"
echo "[Windrose] Query Port: ${QUERY_PORT:-27015}"
echo "[Windrose] Max Players: ${MAX_PLAYERS:-16}"

# Server starten
exec ./${GAME_EXEC} \
    -ServerName="${SERVER_NAME:-Windrose Server}" \
    -Port="${SERVER_PORT:-7777}" \
    -QueryPort="${QUERY_PORT:-27015}" \
    -MaxPlayers="${MAX_PLAYERS:-16}" \
    -savepath=${SERVER_DIR}/saved \
    "$@"
