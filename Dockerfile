# Windrose Dedicated Server Dockerfile
# App ID: 3041230
# 
# Verwendet: SteamCMD direkt von Valve

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

# SteamCMD installieren (von Valve)
RUN mkdir -p /steamcmd && \
    cd /steamcmd && \
    wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd.tar.gz || \
    wget -q https://repo.steampowered.com/steamcmd/steamcmd.tar.gz || \
    curl -sL https://steamcdn-a.akamaihd.net/client/installer/steamcmd.tar.gz -o steamcmd.tar.gz || \
    curl -sL https://repo.steampowered.com/steamcmd/steamcmd.tar.gz -o steamcmd.tar.gz ; \
    if file steamcmd.tar.gz | grep -q gzip; then \
        tar -xzf steamcmd.tar.gz && rm steamcmd.tar.gz; \
    else \
        rm -f steamcmd.tar.gz; \
        echo "SteamCMD download failed, will retry at runtime"; \
    fi && \
    chmod +x /steamcmd/steamcmd.sh

# Windrose Server installieren (App ID 3041230)
RUN if [ -f /steamcmd/steamcmd.sh ]; then \
        /steamcmd/steamcmd.sh +force_install_dir /windrose +login anonymous +app_update 3041230 validate +quit; \
    else \
        echo "SteamCMD not available, will be installed at first start"; \
    fi

# Config-Verzeichnis erstellen
RUN mkdir -p /windrose/saved /windrose/logs && \
    chmod -R 755 /windrose

# Server-Startscript
RUN echo '#!/bin/bash\n\
echo "[Windrose] Server wird gestartet..."\n\
if [ ! -f /steamcmd/steamcmd.sh ]; then\n\
    echo "[Windrose] SteamCMD wird installiert..."\n\
    mkdir -p /steamcmd\n\
    curl -sL https://steamcdn-a.akamaihd.net/client/installer/steamcmd.tar.gz -o /steamcmd/steamcmd.tar.gz\n\
    tar -xzf /steamcmd/steamcmd.tar.gz -C /steamcmd\n\
    rm /steamcmd/steamcmd.tar.gz\n\
    chmod +x /steamcmd/steamcmd.sh\n\
fi\n\
if [ ! -d /windrose/WindroseServer ]; then\n\
    echo "[Windrose] Server wird heruntergeladen..."\n\
    /steamcmd/steamcmd.sh +force_install_dir /windrose +login anonymous +app_update 3041230 validate +quit\n\
fi\n\
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
