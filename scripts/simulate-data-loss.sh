#!/usr/bin/env sh
set -eu

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

docker compose exec -T postgresql psql -U "${PG_USER:-authentik}" -d "${PG_DB:-authentik}" -c "delete from authentik_core_user where username = 'demo-user';"

echo "Simulated data loss by deleting demo-user from the authentik database."
echo "Restore with: ./scripts/restore-db.sh backups/<timestamp>/authentik.dump"
