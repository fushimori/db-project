# app/series.py
from fastapi import APIRouter, Depends, Query
from db.connection import Database
from app.auth import get_current_user  # Используем Depends для передачи токена

router = APIRouter()

@router.get("/")
async def get_series(
    current_user: str = Depends(get_current_user)  # Используем Depends
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Базовый запрос, доступный всем
        base_query = "SELECT id, title, photo_path, type FROM media_content_series"
        series_list = await conn.fetch(base_query)

        if current_user:
            # Если пользователь авторизован, получаем расширенные данные
            extended_data = []
            for series in series_list:
                series_dict = dict(series)
                status_query = """
                SELECT status FROM UserMediaList
                WHERE user_id = (SELECT id FROM Users WHERE username = $1)
                AND media_id = $2
                """
                status_record = await conn.fetchrow(status_query, current_user, series["id"])
                series_dict["status"] = status_record["status"] if status_record else None
                extended_data.append(series_dict)
            return {"series": extended_data}

        # Для гостей возвращаем только базовую информацию
        return {"series": [dict(series) for series in series_list]}

    
@router.get("/search")
async def search_series(
    query: str = Query(None, description="Search query"),
    current_user: str = Depends(get_current_user)
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Запрос для поиска аниме по названию
        base_query = """
        SELECT id, title, photo_path, type FROM media_content_series
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



@router.get("/{series_id}/")
async def get_series_details(
    series_id: int,
    current_user: str = Depends(get_current_user)
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Запрос для получения подробной информации о медиа
        query = """
        SELECT id, title, photo_path, description,
               type, release_date, avg_rating, status,
               end_date, chapter_count, episode_count
        FROM media_content_series
        WHERE id = $1
        """
        series_details = await conn.fetchrow(query, series_id)
        if not series_details:
            return {"error": "Media not found"}

        series_details_dict = dict(series_details)
        # Если пользователь авторизован, получаем его статус для этого медиа
        if current_user:
            status_query = """
            SELECT status FROM UserMediaList
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            status_record = await conn.fetchrow(status_query, current_user, series_id)
            series_details_dict["user_status"] = status_record["status"] if status_record else None

            # Получаем оценку пользователя для этого медиа
            rating_query = """
            SELECT score FROM ratings
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            rating_record = await conn.fetchrow(rating_query, current_user, series_id)
            series_details_dict["user_rating"] = rating_record["score"] if rating_record else None

            # Получаем отзыв пользователя для этого медиа
            review_query = """
            SELECT review_text FROM reviews
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            review_record = await conn.fetchrow(review_query, current_user, series_id)
            series_details_dict["user_review"] = review_record["review_text"] if review_record else None

        return {"series_details": series_details_dict}

