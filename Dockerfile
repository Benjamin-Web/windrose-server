# Windrose Dedicated Server Dockerfile
# App ID: 3041230
# 
# Verwendet: vaporapi/steamcmd - aktuelles SteamCMD Image

FROM vaporapi/steamcmd:latest

LABEL maintainer="Benjamin"
LABEL steam.app_id="3041230"

# Windrose installieren
RUN ./steamcmd.sh \
    +force_install_dir /windrose \
    +login anonymous \
    +app_update 3041230 \
    validate \
    +quit

# Server-Verzeichnisse erstellen
RUN mkdir -p /windrose/saved /windrose/logs && \
    chmod -R 755 /windrose

# Start-Script erstellen
RUN printf '#!/bin/bash\n\
cd /windrose\n\
exec ./WindroseServer.sh \
    -ServerName="${SERVER_NAME:-Windrose Server}" \
    -Port="${SERVER_PORT:-7777}" \
    -QueryPort="${QUERY_PORT:-27015}" \
    -MaxPlayers="${MAX_PLAYERS:-16}" \
    -savepath=/windrose/saved "$@"\n' > /windrose/start.sh && \
    chmod +x /windrose/start.sh

# Ports
EXPOSE 7777/udp 27015/tcp

WORKDIR /windrose

CMD ["/windrose/start.sh"]
