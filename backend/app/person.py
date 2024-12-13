# app/person.py
from fastapi import APIRouter, Depends, Query
from db.connection import Database
# from app.auth import get_current_user  # Используем Depends для передачи токена

router = APIRouter()

@router.get("/")
async def get_person():
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Базовый запрос, доступный всем
        base_query = "SELECT id, name, photo_path FROM persons"
        person_list = await conn.fetch(base_query)

        # if current_user:
        #     # Если пользователь авторизован, получаем расширенные данные
        #     extended_data = []
        #     for person in person_list:
        #         person_dict = dict(person)
        #         status_query = """
        #         SELECT status FROM UserMediaList
        #         WHERE user_id = (SELECT id FROM Users WHERE username = $1)
        #         AND media_id = $2
        #         """
        #         status_record = await conn.fetchrow(status_query, current_user, person["id"])
        #         person_dict["status"] = status_record["status"] if status_record else None
        #         extended_data.append(person_dict)
        #     return {"person": extended_data}

        # Для гостей возвращаем только базовую информацию
        return {"person": [dict(person) for person in person_list]}

@router.get("/search")
async def search_person(
    query: str = Query(None, description="Search query")
):
    pool =await Database.get_connection()
    async with pool.acquire() as conn:
        # Базовый запрос, доступный всем
        base_query = """
        SELECT id, name, photo_path FROM persons
        WHERE name ILIKE $1
        """
        search_results = await conn.fetch(base_query, f"%{query}%")
        return {"results": [dict(result) for result in search_results]}


@router.get("/{person_id}/")
async def get_person_details( person_id: int):  # current_user: str = Depends(get_current_user)
    pool = await Database.get_connection()
    async with pool.acquire() as conn:
        # Запрос для получения подробной информации о медиа
        query = """
        SELECT id, name, photo_path, nationality, main_role, birth_date
        FROM persons
        WHERE id = $1
        """
        person_details = await conn.fetchrow(query, person_id)
        if not person_details:
            return {"error": "Media not found"}

        person_details_dict = dict(person_details)

        return {"person_details": person_details_dict}
