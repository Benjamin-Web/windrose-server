# Windrose Dedicated Server Dockerfile
# App ID: 3041230
#
# Achtung: SteamCMD und Server werden BEIM START heruntergeladen
# Das erste Starten dauert 10-30 Minuten!

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# System-Pakete
RUN apt-get update && \
    apt-get install -y \
    wget \
    curl \
    unzip \
    tar \
    xz-utils \
    gzip \
    lib32gcc-s1 \
    lib32stdc++6 \
    lib32z1 \
    lib32ncurses6 \
    lib32tinfo6 \
    netcat-openbsd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verzeichnisse erstellen
RUN mkdir -p /steamcmd /windrose/saved /windrose/logs
RUN chmod -R 755 /steamcmd /windrose

# SteamCMD Installations-Script beim Start
# Dieses Script wird nur beim ersten Start ausgeführt
RUN printf '#!/bin/bash\n\
set -e\n\
echo "[SteamCMD] Prüfe Installation..."\n\
if [ ! -f /steamcmd/steamcmd.sh ]; then\n\
    echo "[SteamCMD] Installiere SteamCMD..."\n\
    mkdir -p /steamcmd\n\
    cd /steamcmd\n\
    curl -L "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -o steamcmd.zip\n\
    unzip -o steamcmd.zip\n\
    rm -f steamcmd.zip\n\
    chmod +x steamcmd.sh\n\
    echo "[SteamCMD] Installation abgeschlossen"\nelse\n\
    echo "[SteamCMD] Bereits installiert"\nfi\n\
if [ ! -d /windrose/WindroseServer ]; then\n\
    echo "[Windrose] Lade Windrose Server herunter (erstes Mal: 10-30 Min)..."\n\
    /steamcmd/steamcmd.sh +force_install_dir /windrose +login anonymous +app_update 3041230 validate +quit\n\
    echo "[Windrose] Download abgeschlossen"\nelse\n\
    echo "[Windrose] Server bereits installiert"\nfi\n\
' > /install-steamcmd.sh && chmod +x /install-steamcmd.sh

# Start-Script
RUN printf '#!/bin/bash\n\
set -e\n\
echo "[Windrose] Starte Server..."\n\
cd /windrose\n\
exec ./WindroseServer.sh \
    -ServerName="${SERVER_NAME:-Windrose Server}" \
    -Port="${SERVER_PORT:-7777}" \
    -QueryPort="${QUERY_PORT:-27015}" \
    -MaxPlayers="${MAX_PLAYERS:-16}" \
    -savepath=/windrose/saved "$@"\n\
' > /windrose/start.sh && chmod +x /windrose/start.sh

# Ports
EXPOSE 7777/udp 27015/tcp

WORKDIR /

# Zuerst installieren, dann starten
CMD ["/bin/bash", "-c", "/install-steamcmd.sh && /windrose/start.sh"]
