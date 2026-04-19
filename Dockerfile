# Windrose Dedicated Server - Docker mit Wine
# App ID: 4129620 (Windows Dedicated Server)

FROM cm2network/steamcmd:latest

# 1. Zu Root wechseln für Paketinstallation
USER root

# 2. 32-Bit Architektur und Wine installieren
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    wine \
    wine32 \
    xvfb \
    winbind \
    && rm -rf /var/lib/apt/lists/*

# 3. Zurück zum sicheren Steam-User
USER steam

# 4. Verzeichnisse erstellen
RUN mkdir -p /home/steam/windrose/saved /home/steam/windrose/logs

# 5. Start-Skript kopieren und Rechte setzen
COPY --chown=steam:steam start.sh /home/steam/start.sh
RUN chmod +x /home/steam/start.sh

# 6. Arbeitsverzeichnis setzen
WORKDIR /home/steam/windrose

# 7. Ports
EXPOSE 7777/udp 27015/udp

# 8. Startbefehl
CMD ["/home/steam/start.sh"]
