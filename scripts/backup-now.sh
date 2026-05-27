#!/usr/bin/env sh
set -eu

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

STAMP="${1:-$(date -u +%Y%m%dT%H%M%SZ)}"
OUT_DIR="backups/$STAMP"

mkdir -p "$OUT_DIR"
docker compose exec -T postgresql pg_dump -U "${PG_USER:-authentik}" -d "${PG_DB:-authentik}" -Fc -f "/backups/$STAMP/authentik.dump"
tar -czf "$OUT_DIR/static.tar.gz" data certs custom-templates blueprints

echo "Backup written to $OUT_DIR"
echo "Database dump: $OUT_DIR/authentik.dump"
echo "Static archive: $OUT_DIR/static.tar.gz"
