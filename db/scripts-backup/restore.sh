#!/bin/bash
# Restore the database from a dump (.sql or .sql.gz).
# Usage: ./db/scripts-backup/restore.sh [dump_file]
# Without an argument the newest file from db/backups/ is used.
# Another container: CONTAINER=other_container ./db/scripts-backup/restore.sh
set -euo pipefail

cd "$(dirname "$0")/../.."   # repository root

CONTAINER="${CONTAINER:-mind_card_db}"
FILE="${1:-$(ls -t db/backups/*.sql.gz db/backups/*.sql 2>/dev/null | head -n 1 || true)}"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "No dump file found. Pass a file or put one into db/backups/." >&2
  exit 1
fi

echo "Dump: $FILE"
echo "Target: container $CONTAINER"
echo "The tables from the dump replace the current ones: notes created after the dump will be lost."
read -r -p "Continue? [y/N] " ANSWER
if [ "$ANSWER" != "y" ]; then
  echo "Cancelled."
  exit 1
fi

case "$FILE" in
  *.gz) gzip -dc "$FILE" ;;
  *)    cat "$FILE" ;;
esac | docker exec -i "$CONTAINER" sh -c \
  'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --default-character-set=utf8mb4'

echo "Restored from: $FILE"
