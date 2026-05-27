#!/usr/bin/env sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 backups/<timestamp>/authentik.dump" >&2
  exit 1
fi

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

DUMP_PATH="$1"
BACKUP_DIR="$(basename "$(dirname "$DUMP_PATH")")"
CONTAINER_DUMP="/backups/$BACKUP_DIR/$(basename "$DUMP_PATH")"

if [ ! -f "$DUMP_PATH" ]; then
  echo "Dump file not found: $DUMP_PATH" >&2
  exit 1
fi

docker compose stop server worker grafana
docker compose exec -T postgresql dropdb --if-exists -U "${PG_USER:-authentik}" "${PG_DB:-authentik}"
docker compose exec -T postgresql createdb -U "${PG_USER:-authentik}" "${PG_DB:-authentik}"
docker compose exec -T postgresql pg_restore -U "${PG_USER:-authentik}" -d "${PG_DB:-authentik}" --clean --if-exists "$CONTAINER_DUMP"
docker compose up -d server worker grafana

echo "Database restored from $DUMP_PATH"
