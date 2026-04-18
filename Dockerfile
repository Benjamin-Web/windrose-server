# Windrose Dedicated Server Dockerfile
# App ID: 3041230

FROM cm2network/steamcmd:latest

LABEL maintainer="Benjamin"
LABEL steam.app_id="3041230"

# Verzeichnisse im Home-Verzeichnis erstellen (User "steam" hat Schreibrechte)
RUN mkdir -p /home/steam/windrose/saved /home/steam/windrose/logs

# Start-Skript kopieren
COPY start.sh /home/steam/start.sh
RUN chmod +x /home/steam/start.sh

# Ports
EXPOSE 7777/udp 27015/tcp

WORKDIR /home/steam/windrose

ENTRYPOINT ["/home/steam/start.sh"]
