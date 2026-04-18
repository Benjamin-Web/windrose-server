# Windrose Dedicated Server Dockerfile
# App ID: 3041230
#
# Verwendet: Ubuntu 22.04 + Gameserver Manager steamcmd image

FROM ubuntu:22.04

LABEL maintainer="Benjamin"
LABEL steam.app_id="3041230"

ENV DEBIAN_FRONTEND=noninteractive
ENV STEAMCMD_DIR=/steamcmd
ENV SERVER_DIR=/windrose
ENV SERVER_NAME=Windrose Server
ENV SERVER_PORT=7777
ENV QUERY_PORT=27015
ENV MAX_PLAYERS=16

# System aktualisieren und grundlegende Tools
RUN apt-get update && \
    apt-get install -y \
    wget \
    curl \
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

# SteamCMD manuell herunterladen und installieren
RUN mkdir -p ${STEAMCMD_DIR} && \
    cd ${STEAMCMD_DIR} && \
    echo "Installiere SteamCMD..." && \
    # Offizielle Valve SteamCMD URL mit explizitem Output
    curl -L \
        "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" \
        -o steamcmd.zip 2>&1 || \
    curl -L \
        "https://repo.steampowered.com/steamcmd/steamcmd.zip" \
        -o steamcmd.zip 2>&1 || \
    echo "Download fehlgeschlagen - versuche tar.gz..." && \
    curl -L \
        "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.tar.gz" \
        -o steamcmd.tar.gz 2>&1 || true && \
    # Entpacken was auch immer kam
    (unzip -o steamcmd.zip 2>/dev/null || tar -xzf steamcmd.tar.gz 2>/dev/null || true) && \
    chmod +x steamcmd.sh && \
    ls -la

# Windrose Server installieren
RUN echo "Installiere Windrose Server (App 3041230)..." && \
    ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update 3041230 \
        validate \
        +quit

# Server-Verzeichnisse erstellen
RUN mkdir -p ${SERVER_DIR}/saved ${SERVER_DIR}/logs && \
    chmod -R 755 ${SERVER_DIR}

# Start-Script erstellen
RUN printf '#!/bin/bash\n\
echo "[Windrose] Server wird gestartet..."\n\
cd %s\n\
./WindroseServer.sh \
    -ServerName="%%s" \
    -Port=%%s \
    -QueryPort=%%s \
    -MaxPlayers=%%s \
    -savepath=%s/saved \
    "$@"\n' \
    "${SERVER_DIR}" \
    "${SERVER_NAME}" \
    "${SERVER_PORT}" \
    "${QUERY_PORT}" \
    "${MAX_PLAYERS}" \
    "${SERVER_DIR}" \
    > ${SERVER_DIR}/start.sh && \
    chmod +x ${SERVER_DIR}/start.sh

# Ports
EXPOSE ${SERVER_PORT}/udp ${QUERY_PORT}/tcp

WORKDIR ${SERVER_DIR}

CMD ["./start.sh"]
