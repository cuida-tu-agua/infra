#!/usr/bin/env bash
# Despliega UNA imagen ya publicada en GHCR: backup -> cambia el tag en .env -> pull -> up -> espera healthy.
# Si no queda healthy, vuelve al tag anterior y termina con error. Lo llama Jenkins por SSH (o tú a mano).
# Uso: bash scripts/deploy-service.sh <servicio> <VARIABLE_TAG> <tag>
#  ej: bash scripts/deploy-service.sh ms-valve MS_VALVE_TAG 1a2b3c4
set -euo pipefail
cd "$(dirname "$0")/.."
SERVICE=$1; TAG_VAR=$2; TAG=$3

set_tag() {
  if grep -q "^${TAG_VAR}=" .env; then sed -i "s|^${TAG_VAR}=.*|${TAG_VAR}=$1|" .env
  else echo "${TAG_VAR}=$1" >> .env; fi
}
apply() { docker compose pull "$SERVICE" && docker compose up -d --no-deps "$SERVICE"; }

echo "== Backup obligatorio"
bash scripts/backup.sh

PREV=$(grep "^${TAG_VAR}=" .env | cut -d= -f2- || true)
echo "== $SERVICE: ${PREV:-ninguno} -> $TAG"
set_tag "$TAG"
apply

echo "== Esperando healthy (max. 5 min)"
STATUS=unknown
for _ in $(seq 1 30); do
  STATUS=$(docker inspect -f '{{.State.Health.Status}}' "$(docker compose ps -q "$SERVICE")")
  if [ "$STATUS" = healthy ]; then echo "OK: $SERVICE:$TAG healthy"; exit 0; fi
  sleep 10
done

echo "!! $SERVICE no quedo healthy (estado: $STATUS)"
if [ -n "$PREV" ]; then echo "== Rollback a $PREV"; set_tag "$PREV"; apply; fi
exit 1