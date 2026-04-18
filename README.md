# Windrose Dedicated Server - Docker Setup

## ⚠️ Voraussetzungen

- **Docker** installiert (`docker --version`)
- **Docker Compose** installiert (`docker compose version`)
- **Steam Account** mit Windrose in der Bibliothek (oder anonymous für öffentliche Server)

## 📦 Bauen und Starten

```bash
# 1. In das Verzeichnis wechseln
cd windrose-server

# 2. Docker Image bauen
docker build -t windrose-server .

# 3. Server starten
docker compose up -d

# 4. Logs anzeigen
docker compose logs -f
```

## 🔧 Konfiguration

### Umgebungsvariablen (in docker-compose.yml)

| Variable | Standard | Beschreibung |
|---|---|---|
| `SERVER_NAME` | `Windrose Server` | Name in der Serverliste |
| `SERVER_PORT` | `7777` | Game Port (UDP) |
| `QUERY_PORT` | `27015` | Steam Query Port (TCP) |
| `MAX_PLAYERS` | `16` | Max Spieler |

### Ports

| Port | Protokoll | Beschreibung |
|---|---|---|
| `7777` | UDP | Haupt-Spielport |
| `7778` | UDP | Raw Packet Port |
| `27015` | TCP | Steam Query Port |

## 🛠️ Troubleshooting

### "SteamCMD not found"
```bash
docker build --no-cache .
```

### Server startet nicht
```bash
# Logs prüfen
docker compose logs

# Container manuell starten für Debugging
docker run -it windrose-server /bin/bash
```

### ports ändern
In `docker-compose.yml` die `ports` anpassen:
```yaml
ports:
  - "7777:7777/udp"
  - "7778:7778/udp"  
  - "27015:27015"
```

## 📁 Wichtige Pfade im Container

| Pfad | Beschreibung |
|---|---|
| `/windrose` | Server-Installationsverzeichnis |
| `/windrose/saved` | Spielstände |
| `/windrose/logs` | Server-Logs |

## 🔄 Updates

```bash
# Neu bauen = neueste Version
docker build --no-cache -t windrose-server .
docker compose down
docker compose up -d
```

## 💾 Daten persistieren

Die Spielstände werden in `./server-data` auf dem Host gespeichert (docker-compose.yml volumes).

## ⚡ Performance-Tipps

- **RAM:** Mindestens 4GB, empfohlen 8GB
- **CPU:** 4 Kerne minimum
- **Netzwerk:** Gute Upload-Leitung wichtig für Server

## ❓ Bekannte Probleme

1. **SteamCMD Timeout** → Internet-Verbindung prüfen, Firewall Ports 27015-27030 TCP/UDP erlauben
2. **Anonymous login failed** → Steam muss möglicherweise mit Account statt anonymous login
3. **Server nicht in Liste** → Query Port muss erreichbar sein, Firewall checken

## 📚 Mehr Info

- SteamDB: https://steamdb.info/app/3041230/
- Steam Store: https://store.steampowered.com/app/3041230/Windrose/
