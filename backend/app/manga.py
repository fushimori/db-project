# app/manga.py
from fastapi import APIRouter, Depends
from db.connection import Database
from app.auth import get_current_user  # Используем Depends для передачи токена

router = APIRouter()

@router.get("/")
async def get_manga(
    current_user: str = Depends(get_current_user)  # Используем Depends
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Базовый запрос, доступный всем
        base_query = "SELECT id, title, photo_path, type FROM media_content_manga"
        manga_list = await conn.fetch(base_query)

        if current_user:
            # Если пользователь авторизован, получаем расширенные данные
            extended_data = []
            for manga in manga_list:
                manga_dict = dict(manga)
                status_query = """
                SELECT status FROM UserMediaList
                WHERE user_id = (SELECT id FROM Users WHERE username = $1)
                AND media_id = $2
                """
                status_record = await conn.fetchrow(status_query, current_user, manga["id"])
                manga_dict["status"] = status_record["status"] if status_record else None
                extended_data.append(manga_dict)
            return {"manga": extended_data}

        # Для гостей возвращаем только базовую информацию
        return {"manga": [dict(manga) for manga in manga_list]}

@router.get("/{manga_id}")
async def get_manga_details(
    manga_id: int,
    current_user: str = Depends(get_current_user)
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Запрос для получения подробной информации о медиа
        query = """
        SELECT id, title, photo_path, description,
               type, release_date, avg_rating, status,
               end_date, chapter_count, episode_count
        FROM media_content_manga
        WHERE id = $1
        """
        manga_details = await conn.fetchrow(query, manga_id)
        print(manga_details)
        if not manga_details:
            return {"error": "Media not found"}

        manga_details_dict = dict(manga_details)
        # Если пользователь авторизован, получаем его статус для этого медиа
        if current_user:
            status_query = """
            SELECT status FROM UserMediaList
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            status_record = await conn.fetchrow(status_query, current_user, manga_id)
            manga_details_dict["user_status"] = status_record["status"] if status_record else None

            # Получаем оценку пользователя для этого медиа
            rating_query = """
            SELECT score FROM ratings
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            rating_record = await conn.fetchrow(rating_query, current_user, manga_id)
            manga_details_dict["user_rating"] = rating_record["score"] if rating_record else None

            # Получаем отзыв пользователя для этого медиа
            review_query = """
            SELECT review_text FROM reviews
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            review_record = await conn.fetchrow(review_query, current_user, manga_id)
            manga_details_dict["user_review"] = review_record["review_text"] if review_record else None

        return {"manga_details": manga_details_dict}
