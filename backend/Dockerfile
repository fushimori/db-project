# Используем официальный образ Python
FROM python:3.9-slim

# Рабочая директория
WORKDIR /app

# Копируем весь код в контейнер
COPY ./backend /app/
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Устанавливаем клиент PostgreSQL (для работы с pg_dump и psql)
RUN apt-get update && apt-get install -y postgresql-client

# Устанавливаем переменную окружения
ENV PYTHONPATH=/app

# Команда для запуска приложения
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
