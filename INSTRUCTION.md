# Instruction: deployment with Docker Compose

## 1. Prepare the files

```
chmod +x db/scripts-backup/*.sh
chmod +x db/init/*.sh
```

Copy .env into work dir.

## 2. Does the data volume already exist?

```bash
docker volume ls
```

**No, it does not (default).** Leave docker-compose.yml as it is. On the first start Compose creates the volume, MySQL creates the main database and the user from .env, and db/init/01-test-db.sh creates the test database.

**Yes, it does.** In docker-compose.yml, in the `volumes:` block, comment out variant A and uncomment variant B. Then:

- MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD and db/init are ignored; the credentials stored in the volume apply.
- DB_ROOT_PASSWORD in .env must match the root password stored in the volume.
- The volume must contain data of the same MySQL version (9.7). For data from another server, make a dump there and restore it into a new volume:

```bash
CONTAINER=OLD_CONTAINER_NAME ./db/scripts-backup/backup.sh    # on the old server
./db/scripts-backup/restore.sh                                # after step 4, on the new one
```

## 3. Stop the old containers

Containers have fixed names and the application takes host port 80, so stop and remove any old stack that uses them. Never run two MySQL servers on one volume.

```bash
docker stop OLD_CONTAINER_NAME
docker rm OLD_CONTAINER_NAME
```

Removing a container does not delete its volume.

## 4. Run

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f app
```

The first start on a new volume takes longer. Open http://10.0.0.1 (or the address from APP_BIND_IP).

## 5. Check the databases

```bash
docker exec -it mind_card_db mysql -uroot -p --default-character-set=utf8mb4 -e "SHOW DATABASES;"
```

The main database and mind_card_notes_test must be listed. If the test database is missing (the volume was created without the init script):

```bash
docker exec -it mind_card_db mysql -uroot -p -e "CREATE DATABASE IF NOT EXISTS mind_card_notes_test CHARACTER SET utf8mb4; GRANT ALL ON mind_card_notes_test.* TO 'YOUR_DB_USER'@'%';"
```

## 6. Update

```bash
git pull
docker compose up -d --build
```

For a new release set APP_VERSION (for example 1.5) in .env first.

## 7. Connecting to mySQL from .venv

```
DB_HOST=127.0.0.1 pytest
```
