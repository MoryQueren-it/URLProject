#!/bin/bash
set -e

IMAGE="quicklink-app"
CONTAINER="quicklink"
PORT=7000

cd "$(dirname "$0")"

echo "Build de l'image..."
docker build -t "$IMAGE" .

# Supprimer l'ancien conteneur s'il existe deja
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Suppression de l'ancien conteneur..."
  docker rm -f "$CONTAINER" >/dev/null
fi

echo "Lancement du conteneur sur le port $PORT..."
docker run -d \
  --name "$CONTAINER" \
  -p "${PORT}:7000" \
  "$IMAGE"