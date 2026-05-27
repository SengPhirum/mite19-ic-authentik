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

if [ ! -f "$DUMP_PATH" ]; then
  echo "Dump file not found: $DUMP_PATH" >&2
  exit 1
fi

PG_USER="${PG_USER:-authentik}"
PG_DB="${PG_DB:-authentik}"

docker compose stop server worker grafana

docker compose exec -T postgresql dropdb \
  --if-exists \
  -U "$PG_USER" \
  "$PG_DB"

docker compose exec -T postgresql createdb \
  -U "$PG_USER" \
  "$PG_DB"

docker compose exec -T postgresql pg_restore \
  -U "$PG_USER" \
  -d "$PG_DB" \
  --clean \
  --if-exists \
  < "$DUMP_PATH"

docker compose up -d server worker grafana

echo "Database restored from $DUMP_PATH"