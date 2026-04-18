# Windrose Dedicated Server Dockerfile
# App ID: 3041230

FROM ubuntu:22.04

LABEL maintainer="Benjamin"
LABEL steam.app_id="3041230"

ENV DEBIAN_FRONTEND=noninteractive
ENV STEAMCMD_DIR=/steamcmd
ENV SERVER_DIR=/windrose

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

# SteamCMD installieren
RUN mkdir -p ${STEAMCMD_DIR} && \
    cd ${STEAMCMD_DIR} && \
    echo "=== Variante 1: SteamCDN ===" && \
    curl -L "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -o steamcmd.zip && \
    echo "Size: $(stat -c%s steamcmd.zip 2>/dev/null || echo '0')" && \
    unzip -o steamcmd.zip && \
    chmod +x steamcmd.sh

# Falls Variante 1 fehlschlug
RUN cd ${STEAMCMD_DIR} && \
    if [ ! -f steamcmd.sh ]; then \
        echo "=== Variante 2: Repo.steampowered ===" && \
        curl -L "https://repo.steampowered.com/steamcmd/steamcmd.zip" -o steamcmd.zip && \
        unzip -o steamcmd.zip && \
        chmod +x steamcmd.sh; \
    fi

# Falls immer noch nicht
RUN cd ${STEAMCMD_DIR} && \
    if [ ! -f steamcmd.sh ]; then \
        echo "=== Variante 3: wget ===" && \
        wget -q "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" && \
        unzip -o steamcmd.zip && \
        chmod +x steamcmd.sh; \
    fi

# Windrose Server installieren
RUN echo "=== Installiere Windrose Server ===" && \
    ${STEAMCMD_DIR}/steamcmd.sh +force_install_dir ${SERVER_DIR} +login anonymous +app_update 3041230 validate +quit

# Server-Verzeichnisse
RUN mkdir -p ${SERVER_DIR}/saved ${SERVER_DIR}/logs && chmod -R 755 ${SERVER_DIR}

# Start-Script
RUN printf '#!/bin/bash\n\
cd %s\n\
./WindroseServer.sh \
    -ServerName="${SERVER_NAME:-Windrose Server}" \
    -Port="${SERVER_PORT:-7777}" \
    -QueryPort="${QUERY_PORT:-27015}" \
    -MaxPlayers="${MAX_PLAYERS:-16}" \
    -savepath=%s/saved "$@"\n' "${SERVER_DIR}" "${SERVER_DIR}" > ${SERVER_DIR}/start.sh && \
    chmod +x ${SERVER_DIR}/start.sh

# Ports
EXPOSE 7777/udp 27015/tcp

WORKDIR ${SERVER_DIR}

CMD ["./start.sh"]
