# Windrose Dedicated Server - Docker Setup

## ⚠️ Voraussetzungen

- Steam Account mit Windrose in der Bibliothek
- **KEIN Steam Guard (2FA)** auf dem Server-Account (würde automatischen Login blockieren)

## 🚀 Schnellstart

```bash
# 1. Repo klonen
git clone https://github.com/Benjamin-Web/windrose-server.git
cd windrose-server

# 2. .env Datei erstellen (Kopiere von .env.example)
cp .env.example .env
nano .env
# Trage ein:
# STEAM_USER=DeinSteamUsername
# STEAM_PASSWORD=DeinSteamPasswort

# 3. Docker Image bauen
docker build -t windrose-server .

# 4. Server starten
docker compose up -d

# 5. Logs beobachten (kann 5-15 Min beim ersten Mal dauern)
docker compose logs -f
```

## 🔐 Sicherheitshinweis

**Niemals** `.env` Dateien mit echten Credentials ins Repo pushen!

Die `.env` ist bereits in `.gitignore` – sie wird nicht gepusht.

Falls du mehrere Server-Instanzen betreibst, kannst du verschiedene `.env` Dateien nutzen:
```bash
docker compose --env-file .env.production up -d
```

## 📁 Wichtige Pfade im Container

| Pfad | Beschreibung |
|---|---|
| `/home/steam/windrose` | Server-Installationsverzeichnis |
| `/home/steam/windrose/saved` | Spielstände |
| `/home/steam/windrose/logs` | Server-Logs |

## 🔧 Konfiguration (.env)

| Variable | Standard | Beschreibung |
|---|---|---|
| `STEAM_USER` | **(required)** | Steam Username |
| `STEAM_PASSWORD` | **(required)** | Steam Passwort |
| `SERVER_NAME` | `Windrose Server` | Name in der Serverliste |
| `SERVER_PORT` | `7777` | Game Port (UDP) |
| `QUERY_PORT` | `27015` | Steam Query Port |
| `MAX_PLAYERS` | `16` | Max Spieler |

## ⚡ Erster Start

1. Docker Image bauen (wenige Sekunden)
2. Container startet → erkennt dass keine Dateien da sind
3. **Download der Spieldateien** (5-15 Minuten)
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

**"Invalid Password" Error:**
→ Falsche Steam-Credentials in .env, oder Steam Guard (2FA) aktiv

**"Missing configuration" Error:**
→ Account besitzt Windrose nicht

**Server nicht in Serverliste sichtbar:**
→ Firewall Ports 7777/udp und 27015/tcp prüfen

## 🛠️ Hilfreiche Befehle

| Befehl | Beschreibung |
|---|---|
| `docker compose logs -f` | Live Logs |
| `docker compose restart` | Neustart |
| `docker compose down` | Stoppen |
| `docker exec -it windrose-server bash` | Container betreten |
