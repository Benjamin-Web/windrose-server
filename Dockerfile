# Windrose Dedicated Server Dockerfile
# App ID: 3041230
#
# Erstellt von Assistant für Benjamin
# Verwendet: Ubuntu 22.04 + SteamCMD

FROM ubuntu:22.04

LABEL maintainer="Benjamin"
LABEL steam.app_id="3041230"

# System-Pakete
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    xz-utils \
    lib32gcc-s1 \
    lib32stdc++6 \
    lib32z1 \
    lib32ncurses6 \
    lib32tinfo6 \
    curl \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# SteamCMD installieren
RUN apt-get update && apt-get install -y steamcmd 2>/dev/null || \
    (mkdir -p /steamcmd && \
    cd /steamcmd && \
    curl -sL https://steamcdn-a.akamaihd.net/client/installer/steamcmd.tar.gz -o steamcmd.tar.gz && \
    tar -xzf steamcmd.tar.gz && \
    rm steamcmd.tar.gz && \
    chmod +x steamcmd.sh)

# Windrose Server installieren (App ID 3041230)
RUN /steamcmd/steamcmd.sh \
    +force_install_dir /windrose \
    +login anonymous \
    +app_update 3041230 \
    +quit

# Config-Verzeichnis
RUN mkdir -p /windrose/saved /windrose/logs && \
    chmod -R 755 /windrose

# Server-Startscript
RUN echo '#!/bin/bash\n\
echo "[Windrose] Server wird gestartet..."\n\
cd /windrose\n\
exec ./WindroseServer.sh \
    -ServerName="${SERVER_NAME:-Windrose Server}" \
    -Port="${SERVER_PORT:-7777}" \
    -QueryPort="${QUERY_PORT:-27015}" \
    -MaxPlayers="${MAX_PLAYERS:-16}" \
    -savepath=/windrose/saved \
    "$@"\n' > /windrose/start.sh && \
    chmod +x /windrose/start.sh

# Ports
EXPOSE 7777/udp 7778/udp 27015/tcp

WORKDIR /windrose

# Server starten
CMD ["/windrose/start.sh"]
