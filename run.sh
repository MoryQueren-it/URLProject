#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="quicklink-app"
CONTAINER_NAME="quicklink"
PORT="5000"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_FILE="$SCRIPT_DIR/links.json"

if [ ! -f "$DATA_FILE" ]; then
  echo "{}" > "$DATA_FILE"
fi

echo "1) Construction de l'image Docker '$IMAGE_NAME'..."
docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"

if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
  echo "2) Suppression de l'ancien conteneur '$CONTAINER_NAME'..."
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

echo "3) Démarrage du conteneur '$CONTAINER_NAME' sur le port $PORT..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "${PORT}:5000" \
  -v "${DATA_FILE}:/app/links.json" \
  "$IMAGE_NAME"

echo "4) Exécution d'un shell interactif dans '$CONTAINER_NAME'..."
docker exec -it "$CONTAINER_NAME" /bin/sh