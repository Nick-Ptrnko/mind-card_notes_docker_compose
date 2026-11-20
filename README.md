# Mind Card Notes

Application code, features and stack: see the template repository: https://github.com/Nick-Ptrnko/mind-card_notes.git

Docker Compose deployment: MySQL 9.7 + the web application. How to deploy: [INSTRUCTION.md](INSTRUCTION.md). This file describes the deployed application and how to use it.

## The ./db folder

Everything about the database that is not application code:

```
db/
├── init/              # one-time scripts, run only when the MySQL volume is empty
│   └── 01-test-db.sh  # creates the test database and grants rights
├── scripts-backup/    # maintenance scripts, run by hand
│   ├── backup.sh      # database -> db/backups/*.sql.gz
│   └── restore.sh     # dump -> database
└── backups/           # dumps; keep them out of git and out of the image
```

Add `db/backups/*` to .gitignore and `db/` to .dockerignore.

## Default names
If `container_name:`, `image:` and the volume `name:` are absent, Compose builds names from the project folder (here mind-card_notes_docker_compose) and the service name:

| What | Generated name |
|------|----------------|
| Application container | mind-card_notes_docker_compose-app-1 |
| Database container | mind-card_notes_docker_compose-mind_card_db-1 |
| Application image | mind-card_notes_docker_compose-app:latest |
| Volume | mind-card_notes_docker_compose_db_data |
| Network | mind-card_notes_docker_compose_default |

Such names depend on the folder name: rename the folder and you get new names, including a new empty volume.

## Everyday commands

```bash
docker compose ps                  # status
docker compose logs -f app         # application logs
docker compose restart app         # restart the application
docker compose up -d --build       # rebuild and start after code changes
docker compose down                # stop; the data stays in the volume
```

Never add `-v` to `down`: it deletes the volume with all notes.

## Backup and restore

```bash
./db/scripts-backup/backup.sh              # dump to db/backups/
./db/scripts-backup/restore.sh             # restore the newest dump (asks first)
./db/scripts-backup/restore.sh db/backups/FILE.sql.gz   # restore a chosen dump
```

The "Backup" and "Restore" buttons in the web UI use a separate JSON file, data/mind_card_backup.json. It is appended to on every backup.

## Working with Cyrillic in the database

```bash
docker exec -it mind_card_db mysql -uroot -p --default-character-set=utf8mb4 mind_card_notes
```

Without the flag the client prints `???` (the data itself is fine). Inside an open session:

```sql
SET NAMES utf8mb4;
SELECT id, title FROM notes;
SELECT id, HEX(title) FROM notes LIMIT 3;   -- D0../D1.. = valid UTF-8
```

Never INSERT or UPDATE Cyrillic in a session without the flag: real `?` would be stored.

## Tests

```bash
pip install -r requirements-dev.txt
DB_HOST=127.0.0.1 pytest      # port 3306 is open on 127.0.0.1 only; cleans only mind_card_notes_test
```
