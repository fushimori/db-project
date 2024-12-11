#!/bin/bash

# Путь к каталогу миграций
MIGRATION_DIR="/docker-entrypoint-initdb.d/migrations"

# Рекурсивно выполняем все SQL-файлы в каталоге и подкаталогах
for sql_file in $(find $MIGRATION_DIR -type f -name "*.sql" | sort); do
  echo "Running $sql_file"
  psql -U $POSTGRES_USER -d $POSTGRES_DB -f $sql_file
done
