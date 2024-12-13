# app/anime.py
import csv
from io import StringIO
from datetime import datetime
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, Query
from db.connection import Database
from app.auth import get_current_user, admin_required  # Используем Depends для передачи токена
router = APIRouter()

@router.get("/")
async def get_anime(
    current_user: str = Depends(get_current_user)  # Используем Depends
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Базовый запрос, доступный всем
        base_query = "SELECT id, title, photo_path, type FROM media_content_anime"
        anime_list = await conn.fetch(base_query)

        if current_user:
            # Если пользователь авторизован, получаем расширенные данные
            extended_data = []
            for anime in anime_list:
                anime_dict = dict(anime)
                status_query = """
                SELECT status FROM UserMediaList
                WHERE user_id = (SELECT id FROM Users WHERE username = $1)
                AND media_id = $2
                """
                status_record = await conn.fetchrow(status_query, current_user, anime["id"])
                anime_dict["status"] = status_record["status"] if status_record else None
                extended_data.append(anime_dict)
            return {"anime": extended_data}

        # Для гостей возвращаем только базовую информацию
        return {"anime": [dict(anime) for anime in anime_list]}

@router.get("/search")
async def search_anime(
    query: str = Query(None, description="Search query"),
    current_user: str = Depends(get_current_user)
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Запрос для поиска аниме по названию
        base_query = """
        SELECT id, title, photo_path, type FROM media_content_anime
        WHERE title ILIKE $1
        """
        search_results = await conn.fetch(base_query, f"%{query}%")

        if current_user:
            # Если пользователь авторизован, получаем расширенные данные
            extended_data = []
            for result in search_results:
                result_dict = dict(result)
                status_query = """
                SELECT status FROM UserMediaList
                WHERE user_id = (SELECT id FROM Users WHERE username = $1)
                AND media_id = $2
                """
                status_record = await conn.fetchrow(status_query, current_user, result["id"])
                result_dict["status"] = status_record["status"] if status_record else None
                extended_data.append(result_dict)
            return {"results": extended_data}

        # Для гостей возвращаем только базовую информацию
        return {"results": [dict(result) for result in search_results]}



@router.get("/{anime_id}/")
async def get_anime_details(
    anime_id: int,
    current_user: str = Depends(get_current_user)
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Запрос для получения подробной информации о медиа
        query = """
        SELECT id, title, photo_path, description,
               type, release_date, avg_rating, status,
               end_date, chapter_count, episode_count
        FROM media_content_anime
        WHERE id = $1
        """
        anime_details = await conn.fetchrow(query, anime_id)
        if not anime_details:
            return {"error": "Media not found"}

        anime_details_dict = dict(anime_details)
        # Если пользователь авторизован, получаем его статус для этого медиа
        if current_user:
            status_query = """
            SELECT status FROM UserMediaList
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            status_record = await conn.fetchrow(status_query, current_user, anime_id)
            anime_details_dict["user_status"] = status_record["status"] if status_record else None

            # Получаем оценку пользователя для этого медиа
            rating_query = """
            SELECT score FROM ratings
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            rating_record = await conn.fetchrow(rating_query, current_user, anime_id)
            anime_details_dict["user_rating"] = rating_record["score"] if rating_record else None

            # Получаем отзыв пользователя для этого медиа
            review_query = """
            SELECT review_text FROM reviews
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            review_record = await conn.fetchrow(review_query, current_user, anime_id)
            anime_details_dict["user_review"] = review_record["review_text"] if review_record else None

        return {"anime_details": anime_details_dict}

@router.post("/upload-csv")
async def upload_csv(file: UploadFile = File(...),
                     user: dict = Depends(admin_required)
):
    pool = await Database.get_connection()
    contents = await file.read()
    csv_file = StringIO(contents.decode('utf-8'))
    reader = csv.DictReader(csv_file)

    async with pool.acquire() as conn:
        for row in reader:
            # Преобразуем строки в данные для добавления в таблицу
            title = row['title']
            description = row['description']
            avg_rating = float(row['avg_rating']) if row['avg_rating'] and row['avg_rating'] != 'null' else None
            media_type = row['type']  # предполагаем, что это строка, которая соответствует enum
            release_date = datetime.strptime(row['release_date'], '%Y-%m-%d').date() if row['release_date'] and row['release_date'] != 'null' else None
            status = row['status']
            end_date = datetime.strptime(row['end_date'], '%Y-%m-%d').date() if row['end_date'] and row['end_date'] != 'null' else None
            chapter_count = int(row['chapter_count']) if row['chapter_count'] and row['chapter_count'] != 'null' else None
            episode_count = int(row['episode_count']) if row['episode_count'] and row['episode_count'] != 'null' else None
            photo_path = row['photo_path']

            # Вставка данных в таблицу
            await conn.execute(
                """
                INSERT INTO MediaContent (title, description, avg_rating, type, release_date, 
                                          status, end_date, chapter_count, episode_count, photo_path)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                """,
                title, description, avg_rating, media_type, release_date, status, end_date, chapter_count, episode_count, photo_path
            )

    return {"message": "CSV file uploaded successfully!"}


@router.delete("/delete-media/{media_id}")
async def delete_media(media_id: int):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Проверим, существует ли медиа с таким ID
        media = await conn.fetchrow("SELECT * FROM MediaContent WHERE id = $1", media_id)
        if not media:
            raise HTTPException(status_code=404, detail="Media not found")
        
        # Удаляем медиа
        await conn.execute("DELETE FROM MediaContent WHERE id = $1", media_id)

    return {"message": "Media deleted successfully"}