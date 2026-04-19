#!/bin/bash
# Entrypoint: Runs as root to fix volume permissions, then drops to steam user

echo "[Entrypoint] Fixe Berechtigungen für Volume-Mounts..."

# Fix ownership of mounted volumes (Docker creates them as root)
chown -R steam:steam /home/steam/windrose
chown -R steam:steam /home/steam/logs

echo "[Entrypoint] Berechtigungen gesetzt. Starte als steam-User..."

# Execute CMD as steam user
exec gosu steam "$@"
