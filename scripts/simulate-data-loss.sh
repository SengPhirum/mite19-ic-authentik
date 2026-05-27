#!/usr/bin/env sh
set -eu

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

docker compose exec -T postgresql psql \
  -U "${PG_USER:-authentik}" \
  -d "${PG_DB:-authentik}" \
  -v ON_ERROR_STOP=1 \
  -c "
  update authentik_core_user
  set name = 'BROKEN RESTORE TEST'
  where username = 'demo-user';

  select id, username, name
  from authentik_core_user
  where username = 'demo-user';
  "

echo "Simulated data loss by modifying demo-user in the authentik database."
echo "Restore with: ./scripts/restore-db.sh backups/<timestamp>/authentik.dump"