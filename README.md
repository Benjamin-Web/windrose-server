# Windrose Dedicated Server - Docker Setup

## ⚠️ Wichtig: Steam Account erforderlich

Windrose (App ID 3041230) unterstützt **kein anonymes Herunterladen**. Du brauchst einen Steam-Account der das Spiel in der Bibliothek hat.

## 📦 Bauen und Starten

```bash
# 1. Repo klonen
git clone https://github.com/Benjamin-Web/windrose-server.git
cd windrose-server

# 2. docker-compose.yml mit deinen Steam-Daten bearbeiten
nano docker-compose.yml
# Ersetze:
#   STEAM_USER=DEIN_STEAM_USERNAME
#   STEAM_PASS=DEIN_STEAM_PASSWORT

# 3. Docker Image bauen
docker build -t windrose-server .

# 4. Server starten
docker compose up -d

# 5. Logs beobachten (kann 5-15 Min beim ersten Mal dauern)
docker compose logs -f
```

## 🔐 Steam Guard / 2FA

Wenn dein Account Steam Guard (2-Faktor-Authentifizierung) hat, musst du nach dem ersten Start einen Code eingeben:

```bash
# Container betreten für Steam Guard Code
docker exec -it windrose-server /bin/bash

# Dann in der Shell:
/home/steam/steamcmd/steamcmd.sh +login USERNAME PASSWORD +quit
# → Du bekommst eine Meldung mit Code

# Oder prüfe Logs:
docker compose logs
```

## 📁 Wichtige Pfade

| Pfad | Beschreibung |
|---|---|
| `/windrose` | Server-Installationsverzeichnis |
| `/windrose/saved` | Spielstände |
| `/windrose/logs` | Server-Logs |

## 🔧 Konfiguration (docker-compose.yml)

| Variable | Standard | Beschreibung |
|---|---|---|
| `SERVER_NAME` | `Windrose Server` | Name in der Serverliste |
| `SERVER_PORT` | `7777` | Game Port (UDP) |
| `QUERY_PORT` | `27015` | Steam Query Port |
| `MAX_PLAYERS` | `16` | Max Spieler |
| `STEAM_USER` | **(required)** | Steam Username |
| `STEAM_PASS` | **(required)** | Steam Passwort |

## ⚡ Erster Start

1. Docker Image bauen (wenige Sekunden)
2. Container startet → erkennt dass keine Dateien da sind
3. **Download der Spieldateien** (5-15 Minuten, abhängig von Internetleitung)
4. Server startet automatisch

Danach: `docker compose up -d` startet in Sekunden.

## 🔄 Updates

```bash
docker compose down
docker build --no-cache -t windrose-server .
docker compose up -d
docker compose logs -f
```

## 💾 Daten persistieren

Spielstände werden in `./server-data` auf dem Host gespeichert.

## ❓ Bekannte Probleme

**"Missing configuration" Error:**
→ Account besitzt Windrose nicht oder falsche Login-Daten

**Steam Guard Code wird verlangt:**
→ Normal beim ersten Login, folgt der Anleitung oben

**Server nicht in Serverliste sichtbar:**
→ Firewall Ports 7777/udp und 27015/tcp prüfen
