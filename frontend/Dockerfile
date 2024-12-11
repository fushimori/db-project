# Используем официальный образ Node.js
FROM node:16-slim

# Рабочая директория для приложения
WORKDIR /app

# Копируем package.json и package-lock.json
COPY frontend/my-app/package.json frontend/my-app/package-lock.json /app/

# Устанавливаем зависимости
RUN npm install

# Копируем весь проект
COPY frontend/my-app /app/

# Открываем порт для приложения React
EXPOSE 3000

# Запускаем приложение
CMD ["npm", "start"]
