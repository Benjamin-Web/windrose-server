# Windrose Dedicated Server - Docker mit Wine
# App ID: 4129620 (Windows Dedicated Server)

FROM cm2network/steamcmd:latest

# 1. Zu Root wechseln für Paketinstallation
USER root

# 2. 32-Bit Architektur und Wine installieren (inkl. wine64 für UE Server)
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    wine \
    wine32 \
    wine64 \
    xvfb \
    winbind \
    cabextract \
    wget \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# 3. Winetricks installieren (für VC++ Runtimes etc.)
RUN wget -q -O /usr/local/bin/winetricks \
    https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/local/bin/winetricks

# 4. Zurück zum sicheren Steam-User für Wine-Init
USER steam

# 5. Wine initialisieren und VC++ Runtime installieren
RUN WINEDEBUG=-all wineboot --init 2>/dev/null && \
    WINEDEBUG=-all winetricks -q vcrun2019 2>/dev/null || true

# 6. Verzeichnisse erstellen
RUN mkdir -p /home/steam/windrose /home/steam/logs

# 7. Start-Skript und Entrypoint kopieren
USER root
COPY --chown=steam:steam start.sh /home/steam/start.sh
COPY --chown=root:root entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /home/steam/start.sh /usr/local/bin/entrypoint.sh

# 8. Arbeitsverzeichnis setzen
WORKDIR /home/steam/windrose

# 9. Ports (Game + Game+1 + Query)
EXPOSE 7777/udp 7778/udp 27015/udp

# 10. Entrypoint fixiert Berechtigungen, dann startet start.sh als steam
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/home/steam/start.sh"]
