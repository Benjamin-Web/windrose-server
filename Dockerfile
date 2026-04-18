# Windrose Dedicated Server Dockerfile
# App ID: 3041230

FROM ubuntu:22.04

LABEL maintainer="Benjamin"
LABEL steam.app_id="3041230"

# System-Pakete
RUN apt-get update && \
    apt-get install -y \
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
    gzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SteamCMD Verzeichnis
RUN mkdir -p /steamcmd

# SteamCMD installieren - verschiedene Quellen probieren
WORKDIR /steamcmd

# Variante 1: Direkt von Valve
RUN curl -sL https://steamcdn-a.akamaihd.net/client/installer/steamcmd.tar.gz -o steamcmd.tar.gz && \
    tar -xzf steamcmd.tar.gz && rm steamcmd.tar.gz || true

# Falls Variante 1 fehlschlug - Variante 2
RUN if [ ! -f steamcmd.sh ]; then \
    curl -sL https://repo.steampowered.com/steamcmd/steamcmd.tar.gz -o steamcmd.tar.gz && \
    tar -xzf steamcmd.tar.gz && rm steamcmd.tar.gz; \
    fi

# Falls immer noch nicht da - vom Backup Mirror
RUN if [ ! -f steamcmd.sh ]; then \
    wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd.tar.gz -O steamcmd.tar.gz && \
    tar -xzf steamcmd.tar.gz && rm steamcmd.tar.gz; \
    fi

RUN chmod +x /steamcmd/steamcmd.sh

# Prüfen ob SteamCMD installiert ist
RUN if [ ! -f /steamcmd/steamcmd.sh ]; then \
    echo "WARNING: SteamCMD nicht gefunden - wird beim Start installiert"; \
    fi

# Windrose Server vorinstallieren (optional - kann beim Start nachgeholt werden)
WORKDIR /steamcmd
RUN ./steamcmd.sh +force_install_dir /windrose +login anonymous +app_update 3041230 validate +quit || \
    echo "Windrose Download beim Build uebersprungen - wird beim Start nachgeholt"

# Verzeichnisse erstellen
RUN mkdir -p /windrose/saved /windrose/logs && chmod -R 755 /windrose

# Start-Script erstellen
RUN printf '#!/bin/bash\n\
if [ ! -f /steamcmd/steamcmd.sh ]; then\n\
    echo "[SteamCMD] Installiere SteamCMD..."\n\
    mkdir -p /steamcmd\n\
    curl -sL https://steamcdn-a.akamaihd.net/client/installer/steamcmd.tar.gz -o /steamcmd/steamcmd.tar.gz\n\
    tar -xzf /steamcmd/steamcmd.tar.gz -C /steamcmd\n\
    rm /steamcmd/steamcmd.tar.gz\n\
    chmod +x /steamcmd/steamcmd.sh\n\
fi\n\
if [ ! -d /windrose/WindroseServer ]; then\n\
    echo "[Windrose] Lade Server herunter..."\n\
    /steamcmd/steamcmd.sh +force_install_dir /windrose +login anonymous +app_update 3041230 validate +quit\n\
fi\n\
cd /windrose\nexec ./WindroseServer.sh -ServerName="${SERVER_NAME:-Windrose Server}" -Port="${SERVER_PORT:-7777}" -QueryPort="${QUERY_PORT:-27015}" -MaxPlayers="${MAX_PLAYERS:-16}" -savepath=/windrose/saved "$@"\n' > /windrose/start.sh && chmod +x /windrose/start.sh

# Ports
EXPOSE 7777/udp 7778/udp 27015/tcp

WORKDIR /windrose

CMD ["/windrose/start.sh"]
