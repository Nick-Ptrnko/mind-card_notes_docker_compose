#!/bin/bash
# Dump the main database to db/backups/<db>_<date>.sql.gz
# Usage: ./db/scripts-backup/backup.sh
# Another container: CONTAINER=old_container ./db/scripts-backup/backup.sh
set -euo pipefail

cd "$(dirname "$0")/../.."   # repository root

# DB_NAME is taken from .env when present
if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

CONTAINER="${CONTAINER:-mind_card_db}"
DB_NAME="${DB_NAME:-mind_card_notes}"
OUT_DIR="db/backups"
FILE="$OUT_DIR/${DB_NAME}_$(date +%F_%H-%M-%S).sql.gz"

mkdir -p "$OUT_DIR"
trap 'rm -f "$FILE.tmp"' EXIT

# The root password is read inside the container (MYSQL_ROOT_PASSWORD)
docker exec -e DUMP_DB="$DB_NAME" "$CONTAINER" sh -c \
  'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --default-character-set=utf8mb4 --single-transaction --databases "$DUMP_DB"' \
  | gzip > "$FILE.tmp"

mv "$FILE.tmp" "$FILE"
echo "Backup saved: $FILE"
