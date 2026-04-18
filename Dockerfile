# Windrose Dedicated Server Dockerfile
# App ID: 3041230

FROM cm2network/steamcmd:latest

LABEL maintainer="Benjamin"
LABEL steam.app_id="3041230"

# KEINE Spieldownloads im Build! Das passiert zur Laufzeit.

# Verzeichnisse erstellen
RUN mkdir -p /windrose/saved /windrose/logs
RUN chmod -R 755 /windrose

# Spieldateien werden beim Start heruntergeladen/aktualisiert
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Ports
EXPOSE 7777/udp 27015/tcp

WORKDIR /windrose

ENTRYPOINT ["/start.sh"]
