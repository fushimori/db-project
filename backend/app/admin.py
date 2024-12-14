import subprocess
import os
from fastapi import APIRouter, Depends, HTTPException
from app.auth import admin_required

router = APIRouter()

DATABASE_URL = os.getenv("DATABASE_URL")
BACKUP_PATH = os.getenv("BACKUP_PATH", "./backup.sql")  # Путь для сохранения бэкапа

# Функция для выполнения бэкапа
def backup_database():
    try:
        # Команда pg_dump для создания дампа базы данных
        subprocess.run(["pg_dump", "--file", BACKUP_PATH, "--format=custom", DATABASE_URL], check=True)
    except subprocess.CalledProcessError:
        raise HTTPException(status_code=500, detail="Error during database backup")

# Функция для восстановления базы данных
def restore_database():
    try:
        # Команда pg_restore для восстановления базы данных из дампа
        subprocess.run(["pg_restore", "--clean", "--no-owner", "--dbname", DATABASE_URL, BACKUP_PATH], check=True)
    except subprocess.CalledProcessError:
        raise HTTPException(status_code=500, detail="Error during database restore")

@router.post("/backup")
async def backup(user: dict = Depends(admin_required)):
    # Создаем бэкап базы данных
    backup_database()
    return {"message": "Database backup completed successfully"}

@router.post("/restore")
async def restore(user: dict = Depends(admin_required)):
    # Восстанавливаем базу данных из дампа
    restore_database()
    return {"message": "Database restore completed successfully"}
