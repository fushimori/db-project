# app/movie.py
from fastapi import APIRouter, Depends, Query
from db.connection import Database
from app.auth import get_current_user  # Используем Depends для передачи токена

router = APIRouter()

@router.get("/")
async def get_movie(
    current_user: str = Depends(get_current_user)  # Используем Depends
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Базовый запрос, доступный всем
        base_query = "SELECT id, title, photo_path, type FROM media_content_movie"
        movie_list = await conn.fetch(base_query)

        if current_user:
            # Если пользователь авторизован, получаем расширенные данные
            extended_data = []
            for movie in movie_list:
                movie_dict = dict(movie)
                status_query = """
                SELECT status FROM UserMediaList
                WHERE user_id = (SELECT id FROM Users WHERE username = $1)
                AND media_id = $2
                """
                status_record = await conn.fetchrow(status_query, current_user, movie["id"])
                movie_dict["status"] = status_record["status"] if status_record else None
                extended_data.append(movie_dict)
            return {"movie": extended_data}

        # Для гостей возвращаем только базовую информацию
        return {"movie": [dict(movie) for movie in movie_list]}
    
@router.get("/search")
async def search_movie(
    query: str = Query(None, description="Search query"),
    current_user: str = Depends(get_current_user)
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Запрос для поиска аниме по названию
        base_query = """
        SELECT id, title, photo_path, type FROM media_content_movie
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



@router.get("/{movie_id}/")
async def get_movie_details(
    movie_id: int,
    current_user: str = Depends(get_current_user)
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Запрос для получения подробной информации о медиа
        query = """
        SELECT id, title, photo_path, description,
               type, release_date, avg_rating, status,
               end_date, chapter_count, episode_count
        FROM media_content_movie
        WHERE id = $1
        """
        movie_details = await conn.fetchrow(query, movie_id)
        if not movie_details:
            return {"error": "Media not found"}

        movie_details_dict = dict(movie_details)
        # Если пользователь авторизован, получаем его статус для этого медиа
        if current_user:
            status_query = """
            SELECT status FROM UserMediaList
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            status_record = await conn.fetchrow(status_query, current_user, movie_id)
            movie_details_dict["user_status"] = status_record["status"] if status_record else None

            # Получаем оценку пользователя для этого медиа
            rating_query = """
            SELECT score FROM ratings
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            rating_record = await conn.fetchrow(rating_query, current_user, movie_id)
            movie_details_dict["user_rating"] = rating_record["score"] if rating_record else None

            # Получаем отзыв пользователя для этого медиа
            review_query = """
            SELECT review_text FROM reviews
            WHERE user_id = (SELECT id FROM Users WHERE username = $1)
            AND media_id = $2
            """
            review_record = await conn.fetchrow(review_query, current_user, movie_id)
            movie_details_dict["user_review"] = review_record["review_text"] if review_record else None

        return {"movie_details": movie_details_dict}

