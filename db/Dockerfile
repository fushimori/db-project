# Используем официальный образ PostgreSQL
FROM postgres:13

# Копируем миграции в docker-entrypoint-initdb.d
COPY ./db/migrations /docker-entrypoint-initdb.d/migrations

# Копируем скрипт для выполнения всех SQL файлов
COPY ./db/run_migrations.sh /docker-entrypoint-initdb.d/

# Устанавливаем переменные окружения для Postgres
ENV POSTGRES_USER=mori
ENV POSTGRES_PASSWORD=mori
ENV POSTGRES_DB=postgres
