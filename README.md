# Windrose Dedicated Server - Docker + Wine Setup

## ⚠️ Wichtig: Windows-Software auf Linux

Windrose Dedicated Server ist ein **Windows-Programm**. Wir nutzen **Wine** um es auf Linux auszuführen.

## 🚀 Schnellstart

```bash
# 1. Repo klonen
git clone https://github.com/Benjamin-Web/windrose-server.git
cd windrose-server

# 2. Alte Daten löschen (falls vorhanden)
rm -rf server-data/

# 3. Docker Image bauen (dauert 5-15 Minuten wegen Wine)
docker compose build --no-cache

# 4. Server starten (inkl. automatischer Download)
docker compose up -d

# 5. Logs beobachten
docker compose logs -f
```

## 🔧 Konfiguration

| Variable | Standard | Beschreibung |
|---|---|---|
| `SERVER_NAME` | `Windrose Server` | Name in der Serverliste |
| `SERVER_PORT` | `7777` | Game Port (UDP) |
| `QUERY_PORT` | `27015` | Query Port (UDP) |
| `MAX_PLAYERS` | `16` | Max Spieler |

## 📁 Verzeichnis-Struktur

```
windrose-server/
├── server-data/       # Spieldateien + Spielstände
├── logs/              # Server-Logs
├── Dockerfile
├── docker-compose.yml
├── start.sh
└── README.md
```

## ⚡ Erster Start

1. Docker Image wird gebaut (Wine wird installiert)
2. SteamCMD lädt automatisch App 4129620 (Windows Server) herunter
3. Server startet mit Wine + xvfb
4. **Kann 10-20 Minuten dauern beim ersten Mal**

## 🔄 Updates

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
docker compose logs -f
```

## ❓ Bekannte Probleme

**Langsamer Build:** Wine Installation dauert 5-10 Minuten

**Server startet nicht:** Prüfe Logs mit `docker compose logs`

**Wine-Fehler:** Manche Windows-Server funktionieren nicht 100% mit Wine

## 🛠️ Hilfreiche Befehle

| Befehl | Beschreibung |
|---|---|
| `docker compose logs -f` | Live Logs |
| `docker compose restart` | Neustart |
| `docker compose down` | Stoppen |
| `docker exec -it windrose bash` | Container betreten |
