# 🧭 Windrose Dedicated Server - Docker Setup

> ⚠️ **Wichtig:** Windrose Dedicated Server ist ein **Windows-Programm** (Unreal Engine).
> Wir nutzen **Wine** um es auf Linux/Docker auszuführen. Es gibt keinen offiziellen Linux-Support.

---

## 🚀 Schnellstart

```bash
# 1. Repo klonen
git clone https://github.com/Benjamin-Web/windrose-server.git
cd windrose-server

# 2. Konfiguration erstellen
cp .env.example .env
# Passe die Werte in .env an (Servername, Passwort, etc.)

# 3. Alte Daten löschen (falls vorhanden)
rm -rf server-data/

# 4. Docker Image bauen (dauert 5-15 Minuten wegen Wine + VC++ Runtimes)
docker compose build --no-cache

# 5. Server starten (inkl. automatischer Download der Serverdateien)
docker compose up -d

# 6. Logs beobachten
docker compose logs -f
```

---

## 🔧 Konfiguration

Erstelle eine `.env` Datei basierend auf `.env.example`:

| Variable | Standard | Beschreibung |
|----------|----------|--------------|
| `SERVER_NAME` | `Windrose Server` | Name deines Servers in der Serverliste |
| `SERVER_PORT` | `7777` | Game-Port (UDP) |
| `QUERY_PORT` | `27015` | Steam Query Port (UDP) |
| `MAX_PLAYERS` | `16` | Maximale Spieleranzahl |
| `SERVER_PASSWORD` | *(leer)* | Optionales Server-Passwort |

> Die Konfiguration wird automatisch in eine `ServerDescription.json` geschrieben,
> die vom Windrose Server gelesen wird.

---

## 📁 Verzeichnis-Struktur

```
windrose-server/
├── server-data/          # Spieldateien + Spielstände (SteamCMD Download)
├── logs/                 # Server-Logs (separat gemountet)
├── .env                  # Deine Server-Konfiguration
├── .env.example          # Vorlage für .env
├── Dockerfile            # Docker Image Definition
├── docker-compose.yml    # Docker Compose Konfiguration
├── start.sh              # Automatisches Setup + Start
└── README.md
```

---

## ⚡ Erster Start - Was passiert?

1. **Docker Image wird gebaut** – Wine + VC++ Runtimes werden installiert (~5-15 Min)
2. **SteamCMD** lädt automatisch App `4129620` (Windows Dedicated Server) herunter
3. **ServerDescription.json** wird mit deinen `.env`-Werten erstellt
4. **Server startet** mit Wine + xvfb (virtueller X-Server)
5. Erster Start kann **10-20 Minuten** dauern

---

## 🔄 Updates

```bash
# Server stoppen
docker compose down

# Image neu bauen (lädt auch Server-Updates)
docker compose build --no-cache

# Server starten
docker compose up -d

# Logs prüfen
docker compose logs -f
```

---

## 🛠️ Hilfreiche Befehle

| Befehl | Beschreibung |
|--------|--------------|
| `docker compose logs -f` | Live-Logs anzeigen |
| `docker compose restart` | Server neustarten |
| `docker compose down` | Server stoppen |
| `docker exec -it windrose bash` | Shell im Container öffnen |
| `cat logs/windrose-server.log` | Server-Log lesen |
| `cat logs/console.log` | Konsolen-Ausgabe lesen |

---

## ❓ Bekannte Probleme

| Problem | Lösung |
|---------|--------|
| Langsamer Build | Wine + VC++ Installation dauert 5-10 Minuten – normal! |
| Server startet nicht | Prüfe Logs: `docker compose logs` und `cat logs/console.log` |
| Wine-Fehler | Unreal Engine Server sind nicht 100% Wine-kompatibel. Falls es nicht geht, braucht man eine Windows VM. |
| `.exe` nicht gefunden | SteamCMD Download war unvollständig → `rm -rf server-data/` und neu starten |

---

## 📌 Hinweis zu Wine-Kompatibilität

Der Windrose Server basiert auf **Unreal Engine 5** und ist offiziell nur für **Windows** verfügbar.
Wine kann die meisten Funktionen emulieren, aber es gibt keine Garantie für 100% Kompatibilität.

**Alternativen falls Wine nicht funktioniert:**
- Server direkt auf einer Windows-Maschine laufen lassen
- Windows Server VM (z.B. über Proxmox, Hyper-V)
- Auf einen offiziellen Linux-Build warten
