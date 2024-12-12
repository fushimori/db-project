# app/search.py
from fastapi import APIRouter, Depends, Query
from db.connection import Database
from app.auth import get_current_user

router = APIRouter()

@router.get("/")
async def search(
    query: str = Query(None, description="Search query"),
    category: str = Query(None, description="Category to search in"),
    current_user: str = Depends(get_current_user)
):
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Базовый запрос, доступный всем
        if category == "person":
            base_query = f"""
            SELECT id, title, photo_path, type FROM persons
            WHERE title ILIKE '%{query}%'
            """
        else:
            base_query = f"""
            SELECT id, title, photo_path, type FROM media_content_{category}
            WHERE title ILIKE '%{query}%'
            """
        search_results = await conn.fetch(base_query)
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