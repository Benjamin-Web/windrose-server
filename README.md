# Windrose Dedicated Server - Docker Setup

## 📋 Übersicht

Dieses Setup nutzt Docker, aber **ohne automatischen SteamCMD-Download**.
Die Spieldateien werden manuell per FTP hochgeladen.

**Vorteile:**
- ✅ Kein Steam Account nötig
- ✅ Kein Steam Guard Problem
- ✅ Download auf eigenem PC (schneller)

**Nachteil:**
- ❌ Manuelle Updates bei Patches

## 🚀 Schnellstart

### 1. Repo klonen & bauen

```bash
git clone https://github.com/Benjamin-Web/windrose-server.git
cd windrose-server
docker build -t windrose-server .
```

### 2. Spieldateien beschaffen

**Option A: Auf dem Server mit SteamCMD (ohne Docker)**

```bash
# SteamCMD direkt auf dem Server installieren
apt install steamcmd

# Windrose Server herunterladen
mkdir -p ~/windrose-server-files
cd ~/windrose-server-files
steamcmd +force_install_dir . +login anonymous +app_update 3041230 validate +quit
```

**Option B: Lokal auf Windows-PC**

1. Steam Client öffnen
2. "Tools" → "Dedicated Server" für Windrose suchen
3. Download starten (oft unter `C:\Program Files\Steam\steamapps\common\`)
4. Per FTP/SFTP die Dateien auf den Server in `~/windrose-server/server-data/` hochladen

### 3. Rechte anpassen

```bash
# Im windrose-server Verzeichnis:
sudo chown -R 1000:1000 server-data/
```

### 4. Server starten

```bash
docker compose up -d
docker compose logs -f
```

## 📁 Verzeichnis-Struktur

```
windrose-server/
├── server-data/          # <-- Hier kommen die Spieldateien rein
│   ├── WindroseServer.sh  # <-- Die Start-Datei MUSS hier sein
│   ├── Engine/
│   ├── Game/
│   └── ...
├── logs/                 # Server-Logs
├── docker-compose.yml
├── Dockerfile
└── start.sh
```

## 🔧 Konfiguration

### Environment Variablen (docker-compose.yml)

| Variable | Standard | Beschreibung |
|---|---|---|
| `SERVER_NAME` | `Windrose Server` | Name in der Serverliste |
| `SERVER_PORT` | `7777` | Game Port (UDP) |
| `QUERY_PORT` | `27015` | Steam Query Port |
| `MAX_PLAYERS` | `16` | Max Spieler |

### Ports

| Port | Protokoll | Beschreibung |
|---|---|---|
| `7777` | UDP | Haupt-Spielport |
| `7778` | UDP | Raw Packet Port |
| `27015` | TCP | Steam Query Port |

## 🔄 Updates

Wenn Windrose patches veröffentlicht:

1. Server stoppen: `docker compose down`
2. Lokal neuen Server über Steam downloaden
3. Per FTP alte Dateien in `server-data/` überschreiben
4. Server starten: `docker compose up -d`

## 💾 Daten-Persistenz

Spielstände werden in `./server-data/saved` gespeichert.

## ❓ Bekannte Probleme

**"Keine Spieldateien gefunden":**
→ Spieldateien wurden nicht nach `server-data/` hochgeladen oder falscher Dateiname

**Server nicht in Serverliste:**
→ Firewall Ports 7777/udp und 27015/tcp prüfen

## 🛠️ Hilfreiche Befehle

| Befehl | Beschreibung |
|---|---|
| `docker compose logs -f` | Live Logs |
| `docker compose restart` | Neustart |
| `docker compose down` | Stoppen |
| `docker exec -it windrose-server bash` | Container betreten |
