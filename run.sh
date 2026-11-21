#!/bin/bash
set -e

IMAGE="quicklink-app"
CONTAINER="quicklink"
PORT=5000

cd "$(dirname "$0")"

if [ ! -f "links.json" ]; then
  echo "{}" > links.json
fi

echo "Build de l'image..."
docker build -t "$IMAGE" .

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Suppression de l'ancien conteneur..."
  docker rm -f "$CONTAINER" >/dev/null
fi

echo "Lancement du conteneur sur le port $PORT..."
docker run -d \
  --name "$CONTAINER" \
  -p "${PORT}:5000" \
  -v "$(pwd)/links.json:/app/links.json" \
  "$IMAGE"

echo "Connexion au conteneur (tape 'exit' pour quitter le shell)..."
docker exec -it "$CONTAINER" /bin/sh