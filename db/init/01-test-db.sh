#!/bin/bash
# Runs once, on the first start of MySQL with an empty volume.
# The main database and the application user are created by the MYSQL_DATABASE,
# MYSQL_USER and MYSQL_PASSWORD variables; this script adds the test database.
set -e

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOSQL
CREATE DATABASE IF NOT EXISTS mind_card_notes_test CHARACTER SET utf8mb4;
GRANT ALL ON mind_card_notes_test.* TO '${MYSQL_USER}'@'%';
EOSQL
